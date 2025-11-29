from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_db
from app.schemas.streak_schemas import StreakCreate, StreakOut, StreakSummary
from app.services import streak_service

router = APIRouter(prefix="/streaks", tags=["streaks"])


@router.get("/{user_id}/summary", response_model=StreakSummary)
def streak_summary(user_id: int, db: Session = Depends(get_db)):
    return streak_service.get_streak_summary(db, user_id)


@router.get("/records/{user_id}", response_model=List[StreakOut])
def list_records(user_id: int, db: Session = Depends(get_db)):
    return streak_service.list_records(db, user_id)


@router.post("/records", response_model=StreakOut)
def create_record(payload: StreakCreate, db: Session = Depends(get_db)):
    return streak_service.create_record(db, payload)
