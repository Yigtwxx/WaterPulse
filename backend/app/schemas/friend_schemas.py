# backend/app/schemas/friend_schemas.py
from datetime import date, datetime
from pydantic import BaseModel
from typing import List, Optional


class FriendCompareRequest(BaseModel):
    user_id: int
    friend_ids: List[int]
    date: date


class FriendDailyTotal(BaseModel):
    user_id: int
    username: str
    total_ml: int
    daily_goal_ml: int = 2000


class FriendWithStats(BaseModel):
    id: int
    username: str
    avatar_url: Optional[str] = None
    daily_goal_ml: int
    today_total_ml: int
    mutual_streak_days: int
    has_poked_today: bool = False


class PokeRequest(BaseModel):
    sender_id: int
    receiver_id: int


class PokeResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    created_at: datetime
    is_read: bool

    class Config:
        orm_mode = True
