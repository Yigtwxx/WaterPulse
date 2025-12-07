import sys
import os
# Fix imports because we are running from backend dir
sys.path.append(os.getcwd())

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import water_log, achievement
from app.services.achievement_service import sync_achievements

DB_PATH = "sqlite:///./waterpulse.db"
engine = create_engine(DB_PATH, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

from sqlalchemy import text

def force_unlock_for_latest_user():
    db = SessionLocal()
    try:
        # Get latest user
        result = db.execute(text("SELECT id, email FROM users ORDER BY id DESC LIMIT 1")).fetchone()
        if not result:
            print("No user found")
            return
            
        user_id = result[0]
        email = result[1]
        print(f"Target User: {email} (ID: {user_id})")
        
        # 1. Add Water Log
        print("Injecting 250ml water log...")
        log = water_log.WaterLog(user_id=user_id, amount_ml=250)
        db.add(log)
        db.commit()
        
        # 2. Sync
        print("Running sync_achievements...")
        sync_achievements(db, user_id)
        
        # 3. Check result
        ach = db.query(achievement.Achievement).filter(achievement.Achievement.user_id == user_id).all()
        print(f"Achievements after sync: {len(ach)}")
        for a in ach:
            print(f" - {a.title} (Unlocked)")
            
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    force_unlock_for_latest_user()
