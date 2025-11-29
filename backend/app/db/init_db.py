from app.db.session import SessionLocal
from app import models


def init_db() -> None:
    """
    Uygulama ilk kez ayağa kalktığında demo kullanıcıyı oluşturur.
    Frontend varsayılan olarak user_id=1 ile konuştuğu için
    kayıt yoksa burada yaratıyoruz. Var olan veriye dokunmuyoruz.
    """
    db = SessionLocal()
    try:
        existing = db.query(models.user.User).filter(models.user.User.id == 1).first()
        if existing:
            return

        demo_user = models.user.User(
            username="waterpulse_demo",
            weight_kg=70,
            height_cm=175,
            age=28,
            gender="other",
            activity_level="medium",
            daily_goal_ml=2400,
            preferred_cup_ml=250,
            language="en",
        )
        db.add(demo_user)
        db.commit()
    finally:
        db.close()
