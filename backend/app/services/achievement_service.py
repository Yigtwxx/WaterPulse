from sqlalchemy.orm import Session

from app.models import achievement
from app.schemas.achievement_schemas import AchievementCreate


def list_achievements(db: Session, user_id: int):
    return (
        db.query(achievement.Achievement)
        .filter(achievement.Achievement.user_id == user_id)
        .order_by(achievement.Achievement.unlocked_at.desc())
        .all()
    )


def create_achievement(db: Session, payload: AchievementCreate):
    record = achievement.Achievement(
        user_id=payload.user_id,
        title=payload.title,
        description=payload.description,
        points=payload.points,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


def ensure_unique_title(db: Session, user_id: int, title: str) -> bool:
    """Check if the user already has an achievement with the same title."""
    existing = (
        db.query(achievement.Achievement)
        .filter(achievement.Achievement.user_id == user_id)
        .filter(achievement.Achievement.title == title)
        .first()
    )
    return existing is None
