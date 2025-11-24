# backend/app/schemas/friend_schemas.py
from datetime import date
from pydantic import BaseModel
from typing import List


class FriendCompareRequest(BaseModel):
    user_id: int
    friend_ids: List[int]
    date: date


class FriendDailyTotal(BaseModel):
    user_id: int
    username: str
    total_ml: int
