from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class AchievementBase(BaseModel):
    title: str
    description: Optional[str] = None
    points: int = 0


class AchievementCreate(AchievementBase):
    user_id: int


class AchievementOut(AchievementBase):
    id: int
    user_id: int
    unlocked_at: datetime

    class Config:
        orm_mode = True
