
import sys
import os
from datetime import datetime, timedelta, date

sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app import models
from sqlalchemy import func

def fix_data():
    db = SessionLocal()
    try:
        print("Fixing Data...")
        
        # 1. Fix Avatar Skins (Null created_at)
        skins = db.query(models.avatar_skin.AvatarSkin).filter(models.avatar_skin.AvatarSkin.created_at == None).all()
        print(f"Found {len(skins)} skins with null created_at")
        for s in skins:
            s.created_at = datetime.utcnow()
        db.commit()
        print("Fixed Skins.")

        # 2. Fix Streak (Update last 7 days logs to match goal)
        user_id = 1
        u = db.query(models.user.User).filter(models.user.User.id == user_id).first()
        if u:
            print(f"User Goal: {u.daily_goal_ml}")
            
            # Get last 7 days logs
            today = date.today()
            start_date = today - timedelta(days=6) # 7 days including today
            
            logs = (
                db.query(models.water_log.WaterLog)
                .filter(models.water_log.WaterLog.user_id == user_id)
                .filter(func.date(models.water_log.WaterLog.timestamp) >= start_date)
                .all()
            )
            
            for log in logs:
                if log.amount_ml < u.daily_goal_ml:
                    print(f"Upgrading log {log.timestamp.date()}: {log.amount_ml} -> {u.daily_goal_ml + 50}")
                    log.amount_ml = u.daily_goal_ml + 50
            
            db.commit()
            print("Fixed Streak Logs.")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_data()
