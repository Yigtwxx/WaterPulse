from datetime import datetime, timedelta

from sqlalchemy import func

from app.db.session import SessionLocal
from app import models


def init_db() -> None:
    """
    Uygulama ilk kez ayağa kalktığında demo verileri oluşturur.
    Var olan verilere dokunmaz; eksikleri tamamlar.
    """
    db = SessionLocal()
    try:
        # Kullanıcılar
        users = [
            dict(
                id=1,
                username="waterpulse_demo",
                weight_kg=70,
                height_cm=175,
                age=28,
                gender="other",
                activity_level="medium",
                daily_goal_ml=2400,
                preferred_cup_ml=250,
                language="en",
            ),
            dict(
                id=2,
                username="friend_anna",
                daily_goal_ml=2000,
                preferred_cup_ml=200,
                language="en",
            ),
            dict(
                id=3,
                username="friend_bob",
                daily_goal_ml=2200,
                preferred_cup_ml=250,
                language="en",
            ),
        ]

        for u in users:
            existing = db.query(models.user.User).filter(models.user.User.id == u["id"]).first()
            if not existing:
                db.add(models.user.User(**u))
        db.commit()

        # Avatar görünümleri
        if not db.query(models.avatar_skin.AvatarSkin).first():
            skins = [
                dict(user_id=1, name="Ocean Blue", color="#3B82F6", is_unlocked=True, is_active=True),
                dict(user_id=1, name="Sunrise", color="#F59E0B", is_unlocked=True, is_active=False),
                dict(user_id=1, name="Mint Breeze", color="#10B981", is_unlocked=False, is_active=False),
            ]
            db.add_all(models.avatar_skin.AvatarSkin(**s) for s in skins)
            db.commit()

        # Başarımlar
        if not db.query(models.achievement.Achievement).first():
            achievements = [
                dict(user_id=1, title="Day One", description="First water log", points=10),
                dict(user_id=1, title="Hydration Rookie", description="500 ml in a day", points=20),
            ]
            db.add_all(models.achievement.Achievement(**a) for a in achievements)
            db.commit()

        # Su logları (streak için)
        today = datetime.utcnow().date()
        for delta in range(0, 5):
            day = today - timedelta(days=delta)
            existing_log = (
                db.query(models.water_log.WaterLog)
                .filter(models.water_log.WaterLog.user_id == 1)
                .filter(func.date(models.water_log.WaterLog.timestamp) == day)
                .first()
            )
            if not existing_log:
                db.add(
                    models.water_log.WaterLog(
                        user_id=1,
                        amount_ml=2600,
                        timestamp=datetime.combine(day, datetime.min.time()),
                    )
                )
        db.commit()

        # Arkadaş ilişkisi örneği
        if not db.query(models.friend.Friend).first():
            db.add(models.friend.Friend(user_id=1, friend_user_id=2, status="accepted"))
            db.add(models.friend.Friend(user_id=1, friend_user_id=3, status="pending"))
            db.commit()
    finally:
        db.close()
