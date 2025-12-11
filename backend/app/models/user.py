# backend/app/models/user.py
from sqlalchemy import Column, Integer, String, Float, Boolean
from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    name = Column(String, nullable=True)
    surname = Column(String, nullable=True)
    is_verified = Column(Boolean, default=False)
    verification_code = Column(String, nullable=True)
    friend_code = Column(String, unique=True, index=True, nullable=True)

    # Profil bilgileri
    weight_kg = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)  # "male", "female", "other" vs.
    activity_level = Column(String, nullable=True)  # "low", "medium", "high"

    # Uygulama ayarları
    daily_goal_ml = Column(Integer, default=2000)
    preferred_cup_ml = Column(Integer, default=250)
    quick_add_1_ml = Column(Integer, default=250)
    quick_add_2_ml = Column(Integer, default=500)
    language = Column(String, default="tr")
    subscription_plan = Column(String, default="basic")

    # Notification Config
    notifications_enabled = Column(Boolean, default=True)
    notification_interval = Column(Integer, default=105) # minutes
    notification_start_hour = Column(Integer, default=9)
    notification_end_hour = Column(Integer, default=23)
    notification_aggressiveness = Column(String, default="normal") # gentle, normal, aggressive
    selected_title = Column(String, nullable=True)
