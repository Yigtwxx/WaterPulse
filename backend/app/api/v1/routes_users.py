# backend/app/api/v1/routes_users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.user_schemas import UserCreate, UserOut

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/", response_model=UserOut)
def create_user(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = (
        db.query(models.user.User)
        .filter(models.user.User.username == user_in.username)
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="Username already exists")

    user = models.user.User(
        username=user_in.username,
        daily_goal_ml=user_in.daily_goal_ml,
        language=user_in.language,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
