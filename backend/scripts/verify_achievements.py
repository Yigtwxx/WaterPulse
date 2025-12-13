
import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from dotenv import load_dotenv
load_dotenv("backend/.env")

from sqlalchemy import text
from app.db.session import SessionLocal
from app.models import user, water_log, friend, achievement
from app.api.v1.routes_achievements import list_achievements
from app.core.security import get_password_hash
from datetime import datetime, timedelta
import random

def verify_sync():
    db = SessionLocal()
    try:
        # Create a fresh test user
        suffix = random.randint(1000, 9999)
        email = f"sync_test_{suffix}@example.com"
        print(f"Creating user {email}...")
        u = user.User(
            email=email, 
            hashed_password=get_password_hash("test"),
            name="SyncTest",
            daily_goal_ml=2000
        )
        db.add(u)
        db.commit()
        db.refresh(u)
        uid = u.id

        # 1. Trigger Volume Badges (5000ml total)
        print("Logging 5000ml to trigger Volume Badges...")
        db.add(water_log.WaterLog(user_id=uid, amount_ml=2500))
        db.add(water_log.WaterLog(user_id=uid, amount_ml=2500))
        db.commit()

        # 2. Trigger Night Owl (Log at 2 AM)
        print("Logging at 2 AM for Night Owl...")
        # Create a log with explicit timestamp (need to handle timezone or just raw insert if flexible)
        # Using raw SQL to force timestamp easily or model if datetime allowed
        night_log = water_log.WaterLog(user_id=uid, amount_ml=100)
        # We need to manually set timestamp. 
        # CAUTION: server_default=func.now() might override if we don't set it explicitly on object?
        # SQLAlchemy usually allows explicit set.
        night_time = datetime.now().replace(hour=2, minute=0, second=0)
        night_log.timestamp = night_time
        db.add(night_log)
        db.commit()
        
        # 3. Trigger Early Bird (Log at 6 AM)
        print("Logging at 6 AM for Early Bird...")
        morning_time = datetime.now().replace(hour=6, minute=30, second=0)
        morning_log = water_log.WaterLog(user_id=uid, amount_ml=100)
        morning_log.timestamp = morning_time
        db.add(morning_log)
        db.commit()

        # 4. Trigger Social (Add 1 friend)
        # Need another user
        f_email = f"friend_{suffix}@example.com"
        f_user = user.User(email=f_email, hashed_password="x", name="Friend")
        db.add(f_user)
        db.commit()
        db.refresh(f_user)
        
        print("Adding a friend...")
        fr = friend.Friend(user_id=uid, friend_user_id=f_user.id, status='accepted')
        db.add(fr)
        db.commit()

        # SYNC
        print("Running sync...")
        # Calling backend logic
        from app.services import achievement_service
        achievement_service.sync_achievements(db, uid)
        
        # Verify
        achievements = db.query(achievement.Achievement).filter(achievement.Achievement.user_id == uid).all()
        titles = [a.title for a in achievements]
        print("Unlocked Titles:")
        for t in titles:
            print(f" - {t}")
            
        expected = [
            "Camel Mode 🐪", 
            "Hydration Hippo 🦛", 
            "Tsunami Tamer 🌊", 
            "Night Owl 🦉", 
            "Early Bird 🌅", 
            "Social Butterfly 🦋"
        ]
        
        missing = [t for t in expected if t not in titles]
        if not missing:
            print("SUCCESS: All expected achievements unlocked!")
        else:
            print(f"FAILURE: Missing: {missing}")

    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    verify_sync()
