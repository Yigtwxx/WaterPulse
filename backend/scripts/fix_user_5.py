
import sys
import os
from datetime import datetime, timedelta, date

sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app import models
from sqlalchemy import func

def fix_user_5():
    db = SessionLocal()
    try:
        user_id = 5
        u = db.query(models.user.User).filter(models.user.User.id == user_id).first()
        if not u:
            print(f"User {user_id} not found! Listing users...")
            users = db.query(models.user.User).all()
            for usr in users:
                print(f"User ID: {usr.id}, Goal: {usr.daily_goal_ml}")
            return
        
        print(f"Fixing User {u.id} ({u.name}), Goal: {u.daily_goal_ml}")
        
        # 1. Add Default Skins if missing
        existing_skins = db.query(models.avatar_skin.AvatarSkin).filter(models.avatar_skin.AvatarSkin.user_id == user_id).all()
        if not existing_skins:
            print("Adding default skins...")
            skins = [
                dict(user_id=user_id, name="Ocean Blue", color="#3B82F6", is_unlocked=True, is_active=True),
                dict(user_id=user_id, name="Sunrise", color="#F59E0B", is_unlocked=True, is_active=False),
                dict(user_id=user_id, name="Mint Breeze", color="#10B981", is_unlocked=False, is_active=False),
            ]
            for s in skins:
                db.add(models.avatar_skin.AvatarSkin(**s))
            db.commit()
            print("Skins added.")
        else:
            print("Skins already exist.")
            
        # 2. Fix Water Logs (Last 7 days -> Goal + 50)
        today = date.today()
        start_date = today - timedelta(days=6)
        
        # Need to ensure logs exist for all 7 days
        for i in range(7):
            d = start_date + timedelta(days=i)
            # Find log
            log = (
                db.query(models.water_log.WaterLog)
                .filter(models.water_log.WaterLog.user_id == user_id)
                .filter(func.date(models.water_log.WaterLog.timestamp) == d)
                .first()
            )
            
            if log:
                if log.amount_ml < u.daily_goal_ml:
                    print(f"Updating {d}: {log.amount_ml} -> {u.daily_goal_ml + 50}")
                    log.amount_ml = u.daily_goal_ml + 50
                    db.add(log)
            else:
                 # Create log if missing (to ensure streak)
                 print(f"Creating missing log for {d}: {u.daily_goal_ml + 50}")
                 new_log = models.water_log.WaterLog(
                     user_id=user_id,
                     amount_ml=u.daily_goal_ml + 50,
                     timestamp=datetime.combine(d, datetime.min.time()) + timedelta(hours=12) # Noon
                 )
                 db.add(new_log)
        
        db.commit()
        print("Logs fixed.")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_user_5()
