from datetime import date
from typing import Tuple

from fastapi import HTTPException
from sqlalchemy import func
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
            func.date(water_log.WaterLog.timestamp).label("d"),
            func.sum(water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(water_log.WaterLog.user_id == user_id)
        .group_by("d")
        .all()
    )

    totals = {r.d: int(r.total) for r in rows}

    current = 0
    today = date.today()
    last_completed_date = None

    # Calculate current streak backwards from today
    probe = today
    while True:
        if totals.get(probe, 0) >= user_obj.daily_goal_ml:
            current += 1
            last_completed_date = probe
            probe = probe.fromordinal(probe.toordinal() - 1)
        else:
            break

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
