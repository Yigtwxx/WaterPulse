from datetime import datetime, timedelta

from sqlalchemy import func

from app.db.session import SessionLocal
from app import models


from app.core.security import get_password_hash

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
                email="demo@waterpulse.com",
                hashed_password=get_password_hash("123456"),
                name="Demo",
                surname="User",
                weight_kg=70,
                height_cm=175,
                age=28,
                gender="other",
                activity_level="medium",
                daily_goal_ml=2400,
                preferred_cup_ml=250,
                language="en",
                subscription_plan="basic",
            ),
            dict(
                id=2,
                email="anna@example.com",
                hashed_password=get_password_hash("123456"),
                name="Anna",
                surname="Friend",
                daily_goal_ml=2000,
                preferred_cup_ml=200,
                language="en",
                subscription_plan="plus",
            ),
            dict(
                id=3,
                email="bob@example.com",
                hashed_password=get_password_hash("123456"),
                name="Bob",
                surname="Friend",
                daily_goal_ml=2200,
                preferred_cup_ml=250,
                language="en",
                subscription_plan="pro",
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
                dict(user_id=1, title="Streak 1 day", description="Complete goal 1 day in a row", points=30),
                dict(user_id=1, title="Streak 7 days", description="Complete goal 7 days in a row", points=50),
                dict(user_id=1, title="Streak 30 days", description="Complete goal 30 days in a row", points=80),
                dict(user_id=1, title="Streak 90 days", description="Complete goal 90 days in a row", points=120),
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
        # 1 günlük streak anında olsun diye bugüne ekstra kayıt
        extra_today = db.query(models.water_log.WaterLog).filter(
            models.water_log.WaterLog.user_id == 1,
            func.date(models.water_log.WaterLog.timestamp) == today,
        ).first()
        if not extra_today:
            db.add(
                models.water_log.WaterLog(
                    user_id=1,
                    amount_ml=1200,
                    timestamp=datetime.combine(today, datetime.min.time()),
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
