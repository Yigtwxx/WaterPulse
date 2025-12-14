import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from dotenv import load_dotenv
load_dotenv("backend/.env")


from app.db.session import SessionLocal
from app.models import user, water_log
from app.api.v1.routes_achievements import list_achievements
from app.schemas.user_schemas import UserCreate
from app.core.security import get_password_hash

def test_flow():
    db = SessionLocal()
    try:
        # 1. Create unique test user
        import random
        rand_id = random.randint(10000, 99999)
        email = f"test_ach_{rand_id}@test.com"
        
        print(f"Creating user {email}...")
        
        user_obj = user.User(
            email=email, hashed_password=get_password_hash("password"),
            daily_goal_ml=2000, name="Test"
        )
        db.add(user_obj)
        db.commit()
        db.refresh(user_obj)
        user_id = user_obj.id
        print(f"User created with ID: {user_id}")

        # 2. Log Water (Should trigger First Splash)
        print("Logging 250ml water...")
        
        log = water_log.WaterLog(user_id=user_id, amount_ml=250)
        db.add(log)
        db.commit()
        
        # 3. List Achievements (Should trigger sync)
        print("Listing achievements (triggers sync)...")
        achievements = list_achievements(user_id, db)
        
        print(f"Found {len(achievements)} achievements:")
        for a in achievements:
            print(f" - {a.title}: {a.description}")
            
        has_first = any(a.title == "First Water Log" for a in achievements)
        if has_first:
            print("SUCCESS: 'First Water Log' found.")
        else:
            print("FAILURE: 'First Water Log' missing.")
            
        # 4. Log more water to hit 500ml
        print("Logging another 300ml (total 550)...")
        log2 = water_log.WaterLog(user_id=user_id, amount_ml=300)
        db.add(log2)
        db.commit()
        
        print("Listing achievements again...")
        achievements_2 = list_achievements(user_id, db)
        for a in achievements_2:
            print(f" - {a.title}")
            
        has_500 = any(a.title == "500ml Badge" for a in achievements_2)
        if has_500:
             print("SUCCESS: '500ml Badge' found.")
        else:
             print("FAILURE: '500ml Badge' missing.")

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    test_flow()
