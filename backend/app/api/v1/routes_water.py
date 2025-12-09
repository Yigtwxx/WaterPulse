# backend/app/api/v1/routes_water.py
from datetime import date, datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, cast, Date
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.water_schemas import (
    WaterLogCreate,
    WaterLogOut,
    WaterLogOut,
    DailyTotalOut,
)
from app.services import achievement_service
from app.schemas.achievement_schemas import AchievementCreate

router = APIRouter(prefix="/water", tags=["water"])


@router.post("/log", response_model=WaterLogOut)
def add_water_log(
    log_in: WaterLogCreate, db: Session = Depends(get_db)
):
    try:
        user = db.query(models.user.User).filter(models.user.User.id == log_in.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        log = models.water_log.WaterLog(
            user_id=log_in.user_id,
            amount_ml=log_in.amount_ml,
        )
        db.add(log)
        db.commit()
        db.refresh(log)

        # Check for daily goal achievement
        today = date.today()
        daily_total = (
            db.query(func.sum(models.water_log.WaterLog.amount_ml))
            .filter(models.water_log.WaterLog.user_id == log_in.user_id)
            .filter(cast(models.water_log.WaterLog.timestamp, Date) == today)
            .scalar()
        ) or 0

        if daily_total >= user.daily_goal_ml:
            try:
                # 1. Daily Goal Achievement
                achievement_title = f"Daily Goal Reached: {today.isoformat()}"
                if achievement_service.ensure_unique_title(db, log_in.user_id, achievement_title):
                    achievement_service.create_achievement(
                        db,
                        AchievementCreate(
                            user_id=log_in.user_id,
                            title=achievement_title,
                            description="You reached your daily water intake goal!",
                            points=10
                        )
                    )

                # 2. Streak Achievements
                # Calculate current streak
                from app.services import streak_service
                current_streak, _, _, _, _ = streak_service.calculate_streaks(db, log_in.user_id)
                
                # Define milestones
                streak_milestones = {
                    1: ("Streak 1 day", "Complete goal 1 day in a row", 30),
                    7: ("Streak 7 days", "Complete goal 7 days in a row", 50),
                    30: ("Streak 30 days", "Complete goal 30 days in a row", 80),
                    90: ("Streak 90 days", "Complete goal 90 days in a row", 120),
                }

                # Check all milestones <= current_streak
                for days_req, (title, desc, points) in streak_milestones.items():
                    if current_streak >= days_req:
                        if achievement_service.ensure_unique_title(db, log_in.user_id, title):
                            achievement_service.create_achievement(
                                db,
                                AchievementCreate(
                                    user_id=log_in.user_id,
                                    title=title,
                                    description=desc,
                                    points=points
                                )
                            )

            except Exception as e:
                print(f"Failed to create achievement: {e}")
                # Do not fail the request, as water log is already saved
        
        # Check for other achievements (First Log, 500ml)
        try:
            # First Log Achievement
            if achievement_service.ensure_unique_title(db, log_in.user_id, "First Water Log"):
                achievement_service.create_achievement(
                    db,
                    AchievementCreate(
                        user_id=log_in.user_id,
                        title="First Water Log",
                        description="First water log recorded!",
                        points=10
                    )
                )

            # 500ml Achievement
            # Check today's total including this log
            current_daily_total = (
                db.query(func.sum(models.water_log.WaterLog.amount_ml))
                .filter(models.water_log.WaterLog.user_id == log_in.user_id)
                .filter(cast(models.water_log.WaterLog.timestamp, Date) == today)
                .scalar()
            ) or 0
            
            if current_daily_total >= 500:
                if achievement_service.ensure_unique_title(db, log_in.user_id, "500ml Badge"):
                    achievement_service.create_achievement(
                        db,
                        AchievementCreate(
                            user_id=log_in.user_id,
                            title="500ml Badge",
                            description="You drank 500 ml in a day!",
                            points=15
                        )
                    )

        except Exception as e:
             print(f"Failed to create extra achievements: {e}")

        return log
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise e


@router.get("/logs/{user_id}", response_model=List[WaterLogOut])
@router.get("/logs/{user_id}", response_model=List[WaterLogOut])
def list_logs(
    user_id: int,
    date_str: Optional[str] = Query(default=None, description="Specific date YYYY-MM-DD"),
    start_date: Optional[str] = Query(default=None, description="Start date YYYY-MM-DD"),
    end_date: Optional[str] = Query(default=None, description="End date YYYY-MM-DD"),
    db: Session = Depends(get_db),
):
    """
    Fetch logs for a specific day OR a date range.
    If date_str is provided, returns logs for that specific day.
    If start_date and end_date are provided, returns logs within that range (inclusive).
    If nothing is provided, defaults to today.
    """
    if start_date and end_date:
        # Range query
        s_date = date.fromisoformat(start_date)
        e_date = date.fromisoformat(end_date)
        start_dt = datetime.combine(s_date, datetime.min.time())
        end_dt = datetime.combine(e_date, datetime.max.time())
    elif date_str:
        # Single day query
        target_date = date.fromisoformat(date_str)
        start_dt = datetime.combine(target_date, datetime.min.time())
        end_dt = datetime.combine(target_date, datetime.max.time())
    else:
        # Default to today
        target_date = date.today()
        start_dt = datetime.combine(target_date, datetime.min.time())
        end_dt = datetime.combine(target_date, datetime.max.time())

    logs = (
        db.query(models.water_log.WaterLog)
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(models.water_log.WaterLog.timestamp >= start_dt)
        .filter(models.water_log.WaterLog.timestamp <= end_dt)
        .order_by(models.water_log.WaterLog.timestamp.asc())
        .all()
    )

    return logs


@router.get("/daily-total/{user_id}", response_model=DailyTotalOut)
def get_daily_total(
    user_id: int,
    date_str: Optional[str] = Query(default=None, description="YYYY-MM-DD"),
    db: Session = Depends(get_db),
):
    if date_str:
        target_date = date.fromisoformat(date_str)
    else:
        target_date = date.today()

    q = (
        db.query(
            cast(models.water_log.WaterLog.timestamp, Date).label("d"),
            func.coalesce(func.sum(models.water_log.WaterLog.amount_ml), 0),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(cast(models.water_log.WaterLog.timestamp, Date) == target_date)
        .group_by("d")
        .first()
    )

    total = int(q[1]) if q else 0

    return DailyTotalOut(date=target_date, total_ml=total)


@router.get("/calendar/{user_id}", response_model=List[DailyTotalOut])
def get_calendar_totals(
    user_id: int,
    start_date: str,
    end_date: str,
    db: Session = Depends(get_db),
):
    start = date.fromisoformat(start_date)
    end = date.fromisoformat(end_date)

    rows = (
        db.query(
            cast(models.water_log.WaterLog.timestamp, Date).label("d"),
            func.sum(models.water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(cast(models.water_log.WaterLog.timestamp, Date) >= start)
        .filter(cast(models.water_log.WaterLog.timestamp, Date) <= end)
        .group_by("d")
        .order_by("d")
        .all()
    )

    return [DailyTotalOut(date=r[0], total_ml=int(r[1])) for r in rows]
