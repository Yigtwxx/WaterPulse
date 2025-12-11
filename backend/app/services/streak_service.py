from datetime import date
from typing import Tuple

from fastapi import HTTPException
from sqlalchemy import func, cast, Date
from sqlalchemy.orm import Session

from app.models import streak, user, water_log
from app.schemas.streak_schemas import StreakCreate, StreakSummary


def calculate_streaks(db: Session, user_id: int) -> Tuple[int, int, int, int, date | None]:
    user_obj = (
        db.query(user.User)
        .filter(user.User.id == user_id)
        .first()
    )
    if not user_obj:
        raise HTTPException(status_code=404, detail="User not found")

    rows = (
        db.query(
            cast(water_log.WaterLog.timestamp, Date).label("d"),
            func.sum(water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(water_log.WaterLog.user_id == user_id)
        .group_by("d")
        .all()
    )


    totals = {}
    for r in rows:
        d_val = r.d
        if isinstance(d_val, str):
            d_val = date.fromisoformat(d_val)
        totals[d_val] = int(r.total)

    current = 0
    today = date.today()
    last_completed_date = None

    # Calculate current streak
    # Logic:
    # 1. Calculate streak ending yesterday.
    # 2. If today is met, streak = yesterday_streak + 1
    # 3. If today is NOT met, streak = yesterday_streak (it's still alive until midnight)
    
    probe = today.fromordinal(today.toordinal() - 1) # Start from yesterday
    streak_yesterday = 0
    while True:
        if totals.get(probe, 0) >= user_obj.daily_goal_ml:
            streak_yesterday += 1
            last_completed_date = probe
            probe = probe.fromordinal(probe.toordinal() - 1)
        else:
            break
    
    today_met = totals.get(today, 0) >= user_obj.daily_goal_ml
    if today_met:
        current = streak_yesterday + 1
        last_completed_date = today
    else:
        current = streak_yesterday

    # Calculate best streak over all historical days
    best = 0
    running = 0
    prev = None
    for d in sorted(totals.keys()):
        if totals[d] >= user_obj.daily_goal_ml:
            if prev and (d - prev).days == 1:
                running += 1
            else:
                running = 1
            prev = d
            best = max(best, running)
        else:
            running = 0
            prev = d

    today_total = totals.get(today, 0)
    return current, best, today_total, user_obj.daily_goal_ml, last_completed_date


def get_streak_summary(db: Session, user_id: int) -> StreakSummary:
    current, best, today_total, goal_ml, last_completed_date = calculate_streaks(
        db, user_id
    )
    return StreakSummary(
        user_id=user_id,
        current_streak=current,
        best_streak=best,
        today_total_ml=today_total,
        goal_ml=goal_ml,
        last_completed_date=last_completed_date,
    )


def create_record(db: Session, payload: StreakCreate):
    user_obj = (
        db.query(user.User)
        .filter(user.User.id == payload.user_id)
        .first()
    )
    if not user_obj:
        raise HTTPException(status_code=404, detail="User not found")

    record = streak.Streak(
        user_id=payload.user_id,
        start_date=payload.start_date,
        end_date=payload.end_date,
        length_days=payload.length_days,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


def list_records(db: Session, user_id: int):
    return (
        db.query(streak.Streak)
        .filter(streak.Streak.user_id == user_id)
        .order_by(streak.Streak.start_date.desc())
        .all()
    )


def calculate_mutual_streak(db: Session, user1_id: int, user2_id: int) -> int:
    """
    Calculates the current mutual streak between two users.
    Mutual streak = consecutive days (backwards from today/yesterday) 
    where BOTH users achieved their daily goal.
    """
    # 1. Get daily totals for both users
    # We can reuse the logic from calculate_streaks but we need raw data for both.
    
    # Helper to get met dates for a user
    def get_met_dates(uid: int) -> set[date]:
        u_obj = db.query(user.User).filter(user.User.id == uid).first()
        if not u_obj:
            return set()
            
        rows = (
            db.query(
                cast(water_log.WaterLog.timestamp, Date).label("d"),
                func.sum(water_log.WaterLog.amount_ml).label("total"),
            )
            .filter(water_log.WaterLog.user_id == uid)
            .group_by("d")
            .all()
        )
        met_dates = set()
        for r in rows:
            d_val = r.d
            if isinstance(d_val, str):
                d_val = date.fromisoformat(d_val)
            if r.total >= u_obj.daily_goal_ml:
                met_dates.add(d_val)
        return met_dates

    dates1 = get_met_dates(user1_id)
    dates2 = get_met_dates(user2_id)
    
    # Common dates where both met the goal
    common_dates = dates1.intersection(dates2)
    
    # Calculate streak from today backwards
    today = date.today()
    streak_count = 0
    
    # Check if today is a common met day. 
    # If YES, streak might include today.
    # If NO, streak continues from yesterday? 
    # STANDARD LOGIC: 
    # If today is met -> count = 1 + check yesterday...
    # If today not met -> check yesterday. If yesterday met -> streak is alive.
    
    # Let's check yesterday first to establish base streak
    probe = today.fromordinal(today.toordinal() - 1)
    while probe in common_dates:
        streak_count += 1
        probe = probe.fromordinal(probe.toordinal() - 1)
        
    # If today is also met, add 1
    if today in common_dates:
        streak_count += 1
        
    return streak_count
