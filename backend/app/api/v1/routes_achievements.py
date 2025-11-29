from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.deps import get_db
from app.schemas.achievement_schemas import AchievementCreate, AchievementOut
from app.services import achievement_service

router = APIRouter(prefix="/achievements", tags=["achievements"])


@router.get("/{user_id}", response_model=List[AchievementOut])
def list_achievements(user_id: int, db: Session = Depends(get_db)):
    return achievement_service.list_achievements(db, user_id)


@router.post("/", response_model=AchievementOut)
def create_achievement(payload: AchievementCreate, db: Session = Depends(get_db)):
    if not achievement_service.ensure_unique_title(db, payload.user_id, payload.title):
        raise HTTPException(status_code=400, detail="Achievement already exists")
    return achievement_service.create_achievement(db, payload)
