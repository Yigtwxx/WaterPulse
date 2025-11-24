# backend/app/schemas/water_schemas.py
from datetime import date, datetime
from pydantic import BaseModel
from typing import Optional


class WaterLogBase(BaseModel):
  user_id: int
  amount_ml: int


class WaterLogCreate(WaterLogBase):
  pass


class WaterLogOut(WaterLogBase):
  id: int
  timestamp: datetime

  class Config:
    orm_mode = True


class DailyTotalOut(BaseModel):
  date: date
  total_ml: int
