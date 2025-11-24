# backend/app/models/user.py
from sqlalchemy import Column, Integer, String
from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    # Şimdilik sade dursun, ileride password hash ekleriz
    daily_goal_ml = Column(Integer, default=2000)
    language = Column(String, default="tr")
