# backend/app/api/v1/routes_water.py
from datetime import date
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.water_schemas import (
    WaterLogCreate,
    WaterLogOut,
    DailyTotalOut,
)

router = APIRouter(prefix="/water", tags=["water"])


@router.post("/log", response_model=WaterLogOut)
def add_water_log(
    log_in: WaterLogCreate, db: Session = Depends(get_db)
):
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
    return log


@router.get("/daily-total/{user_id}", response_model=DailyTotalOut)
def get_daily_total(
    user_id: int,
    date_str: Optional[str] = Query(default=None, description="YYYY-MM-DD"),
    db: Session = Depends(get_db),
):
    # Tarih verilmezse bugün
    if date_str:
        target_date = date.fromisoformat(date_str)
    else:
        target_date = date.today()

    q = (
        db.query(
            func.date(models.water_log.WaterLog.timestamp).label("d"),
            func.coalesce(func.sum(models.water_log.WaterLog.amount_ml), 0),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(func.date(models.water_log.WaterLog.timestamp) == target_date)
        .group_by("d")
        .first()
    )

    total = q[1] if q else 0

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
            func.date(models.water_log.WaterLog.timestamp).label("d"),
            func.sum(models.water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(func.date(models.water_log.WaterLog.timestamp) >= start)
        .filter(func.date(models.water_log.WaterLog.timestamp) <= end)
        .group_by("d")
        .order_by("d")
        .all()
    )

    return [DailyTotalOut(date=r[0], total_ml=r[1]) for r in rows]
