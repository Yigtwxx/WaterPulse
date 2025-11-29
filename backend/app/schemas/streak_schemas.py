from datetime import date, datetime
from pydantic import BaseModel
from typing import Optional


class StreakBase(BaseModel):
    user_id: int
    start_date: date
    end_date: date
    length_days: int


class StreakCreate(StreakBase):
    pass


class StreakOut(StreakBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True


class StreakSummary(BaseModel):
    user_id: int
    current_streak: int
    best_streak: int
    today_total_ml: int
    goal_ml: int
    last_completed_date: Optional[date] = None
