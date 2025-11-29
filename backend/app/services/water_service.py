from datetime import date, datetime
from typing import List, Optional

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models import user, water_log


def add_log(db: Session, user_id: int, amount_ml: int):
    user_obj = (
        db.query(user.User)
        .filter(user.User.id == user_id)
        .first()
    )
    if not user_obj:
        raise HTTPException(status_code=404, detail="User not found")

    log = water_log.WaterLog(user_id=user_id, amount_ml=amount_ml)
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


def list_logs(
    db: Session,
    user_id: int,
    target_date: Optional[date] = None,
) -> List[models.water_log.WaterLog]:
    if target_date is None:
        target_date = date.today()

    start_dt = datetime.combine(target_date, datetime.min.time())
    end_dt = datetime.combine(target_date, datetime.max.time())

    return (
        db.query(water_log.WaterLog)
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(water_log.WaterLog.timestamp >= start_dt)
        .filter(water_log.WaterLog.timestamp <= end_dt)
        .order_by(water_log.WaterLog.timestamp.asc())
        .all()
    )


def daily_total(db: Session, user_id: int, target_date: Optional[date] = None) -> int:
    if target_date is None:
        target_date = date.today()

    row = (
        db.query(
            func.coalesce(func.sum(water_log.WaterLog.amount_ml), 0)
        )
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(func.date(water_log.WaterLog.timestamp) == target_date)
        .first()
    )
    return int(row[0]) if row else 0


def calendar_totals(
    db: Session, user_id: int, start: date, end: date
):
    rows = (
        db.query(
            func.date(water_log.WaterLog.timestamp).label("d"),
            func.sum(water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(func.date(water_log.WaterLog.timestamp) >= start)
        .filter(func.date(water_log.WaterLog.timestamp) <= end)
        .group_by("d")
        .order_by("d")
        .all()
    )
    return {r.d: int(r.total) for r in rows}
