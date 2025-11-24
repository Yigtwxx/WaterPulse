# backend/app/models/user.py
from sqlalchemy import Column, Integer, String, Float
from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)

    # Profil bilgileri
    weight_kg = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)  # "male", "female", "other" vs.
    activity_level = Column(String, nullable=True)  # "low", "medium", "high"

    # Uygulama ayarları
    daily_goal_ml = Column(Integer, default=2000)
    preferred_cup_ml = Column(Integer, default=250)
    language = Column(String, default="tr")
