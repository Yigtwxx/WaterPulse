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
    daily_goal_ml: int = 2000
    preferred_cup_ml: int = 250
    quick_add_1_ml: int = 250
    quick_add_2_ml: int = 500
    language: str = "tr"
    language: str = "tr"
    subscription_plan: str = "basic"
    
    # Notification Config
    notifications_enabled: bool = True
    notification_interval: int = 105
    notification_start_hour: int = 9
    notification_end_hour: int = 23
    notification_aggressiveness: str = "normal"
    selected_title: Optional[str] = None


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
    quick_add_1_ml: Optional[int] = None
    quick_add_2_ml: Optional[int] = None
    language: Optional[str] = None
    subscription_plan: Optional[str] = None
    
    notifications_enabled: Optional[bool] = None
    notification_interval: Optional[int] = None
    notification_start_hour: Optional[int] = None
    notification_end_hour: Optional[int] = None
    notification_aggressiveness: Optional[str] = None
    selected_title: Optional[str] = None


class UserOut(UserBase):
    id: int
    is_verified: bool = False
    friend_code: Optional[str] = None

    class Config:
        orm_mode = True
