from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class AvatarSkinBase(BaseModel):
    user_id: int
    name: str
    color: Optional[str] = "#60A5FA"
    is_unlocked: bool = False
    is_active: bool = False


class AvatarSkinCreate(AvatarSkinBase):
    pass


class AvatarSkinUpdate(BaseModel):
    color: Optional[str] = None
    is_unlocked: Optional[bool] = None
    is_active: Optional[bool] = None


class AvatarSkinOut(AvatarSkinBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True
