
import sys
import os
from datetime import datetime

# Add project root to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app.models import user, water_log
from app.schemas.water_schemas import WaterLogCreate
from app.api.v1.routes_water import add_water_log

def reproduce():
    db = SessionLocal()
    try:
        # Get User 1 (Demo)
        u = db.query(user.User).filter(user.User.id == 1).first()
        if not u:
            print("User 1 not found!")
            return

        print(f"User found: {u.name}, Goal: {u.daily_goal_ml}")
        
        # Simulate adding water until crash
        current_total = 0 # This is approximation, actual total is in DB
        
        # Payload
        payload = WaterLogCreate(user_id=u.id, amount_ml=500)
        
        print("Attempting to add water log...")
        try:
            # We call the route function directly. 
            # Note: This bypasses FastAPI dependency injection for 'db', so we pass it explicitly if possible.
            # But the function signature is: def add_water_log(log_in: WaterLogCreate, db: Session = Depends(get_db)):
            # So we can pass db as kwarg.
            
            result = add_water_log(log_in=payload, db=db)
            print("Success! Log added:", result.id)
            
        except Exception as e:
            print("CAUGHT EXCEPTION:")
            import traceback
            traceback.print_exc()

    finally:
        db.close()

if __name__ == "__main__":
    reproduce()
