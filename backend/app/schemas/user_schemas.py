# backend/app/schemas/user_schemas.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional


class UserBase(BaseModel):
    email: EmailStr
    name: Optional[str] = None
    surname: Optional[str] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None          # "male", "female", "other"
    activity_level: Optional[str] = None  # "low", "medium", "high"
    daily_goal_ml: int = 2000
    preferred_cup_ml: int = 250
    language: str = "tr"
    subscription_plan: str = "basic"


class UserCreate(UserBase):
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    name: Optional[str] = None
    surname: Optional[str] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    activity_level: Optional[str] = None
    daily_goal_ml: Optional[int] = None
    preferred_cup_ml: Optional[int] = None
    language: Optional[str] = None
    subscription_plan: Optional[str] = None


class UserOut(UserBase):
    id: int

    class Config:
        orm_mode = True
