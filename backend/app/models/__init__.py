# backend/app/models/__init__.py
from .user import User
from .water_log import WaterLog
from .achievement import Achievement
from .avatar_skin import AvatarSkin
from .friend import Friend
from .streak import Streak

__all__ = ["User", "WaterLog", "Achievement", "AvatarSkin", "Friend", "Streak"]
