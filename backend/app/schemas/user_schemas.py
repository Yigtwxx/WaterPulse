# backend/app/schemas/user_schemas.py
from pydantic import BaseModel, Field


class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=32)
    daily_goal_ml: int = 2000
    language: str = "tr"


class UserOut(BaseModel):
    id: int
    username: str
    daily_goal_ml: int
    language: str

    class Config:
        orm_mode = True
