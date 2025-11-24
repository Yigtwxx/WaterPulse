# backend/app/schemas/user_schemas.py
from pydantic import BaseModel, Field
from typing import Optional


class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=32)
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None          # "male", "female", "other"
    activity_level: Optional[str] = None  # "low", "medium", "high"
    daily_goal_ml: int = 2000
    preferred_cup_ml: int = 250
    language: str = "tr"


class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    activity_level: Optional[str] = None
    daily_goal_ml: Optional[int] = None
    preferred_cup_ml: Optional[int] = None
    language: Optional[str] = None


class UserOut(UserBase):
    id: int

    class Config:
        orm_mode = True
