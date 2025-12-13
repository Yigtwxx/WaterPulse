
import sys
import os
from datetime import date, timedelta

sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app.models import user, water_log, avatar_skin
from app.services import streak_service
from sqlalchemy import func, cast, Date

def check_state():
    db = SessionLocal()
    try:
        user_id = 1
        print(f"--- Checking State for User {user_id} ---")
        
        # 1. Check User
        u = db.query(user.User).filter(user.User.id == user_id).first()
        if not u:
            print("User not found")
            return
        print(f"User: {u.name}, Goal: {u.daily_goal_ml}")

        # 2. Daily Totals for last 8 days
        print("\n--- Daily Totals (Last 8 Days) ---")
        today = date.today()
        start_date = today - timedelta(days=7)
        
        rows = (
            db.query(
                cast(water_log.WaterLog.timestamp, Date).label("d"),
                func.sum(water_log.WaterLog.amount_ml).label("total"),
            )
            .filter(water_log.WaterLog.user_id == user_id)
            .filter(water_log.WaterLog.timestamp >= start_date)
            .group_by("d")
            .order_by("d")
            .all()
        )
        
        totals = {r.d: r.total for r in rows}
        
        for i in range(8):
            d = start_date + timedelta(days=i)
            total = totals.get(d, 0)
            status = "MET" if total >= u.daily_goal_ml else "MISS"
            print(f"{d}: {total} ml ({status})")

        # 3. Calculated Streak
        print("\n--- Calculated Streak ---")
        current, best, today_val, _, _ = streak_service.calculate_streaks(db, user_id)
        print(f"Current Streak: {current}")
        print(f"Best Streak: {best}")
        print(f"Today Total: {today_val}")

        # 4. Avatar Skins
        print("\n--- Avatar Skins ---")
        skins = db.query(avatar_skin.AvatarSkin).filter(avatar_skin.AvatarSkin.user_id == user_id).all()
        if not skins:
            print("No skins found in DB!")
        else:
            for s in skins:
                print(f"Skin: {s.name}, Unlocked: {s.is_unlocked}, Active: {s.is_active}")

    finally:
        db.close()

if __name__ == "__main__":
    check_state()
