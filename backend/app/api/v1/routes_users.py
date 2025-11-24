# backend/app/api/v1/routes_users.py
from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.user_schemas import UserCreate, UserOut, UserUpdate
from app.utils.calc_water_goal import calculate_daily_goal_ml

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/", response_model=UserOut)
def create_user(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = (
        db.query(models.user.User)
        .filter(models.user.User.username == user_in.username)
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="Username already exists")

    # Eğer weight_kg varsa ve daily_goal explicitly gönderilmemişse otomatik hesapla
    daily_goal = user_in.daily_goal_ml
    if user_in.weight_kg is not None and user_in.daily_goal_ml == 2000:
        daily_goal = calculate_daily_goal_ml(
            user_in.weight_kg, user_in.activity_level
        )

    user = models.user.User(
        username=user_in.username,
        weight_kg=user_in.weight_kg,
        height_cm=user_in.height_cm,
        age=user_in.age,
        gender=user_in.gender,
        activity_level=user_in.activity_level,
        daily_goal_ml=daily_goal,
        preferred_cup_ml=user_in.preferred_cup_ml,
        language=user_in.language,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{user_id}", response_model=UserOut)
def update_user(
    user_id: int, user_in: UserUpdate, db: Session = Depends(get_db)
):
    user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    data = user_in.dict(exclude_unset=True)
    for field, value in data.items():
        setattr(user, field, value)

    # Eğer weight veya activity güncellendiyse, daily_goal otomatik hesapla (manuel override yoksa)
    if ("weight_kg" in data or "activity_level" in data) and "daily_goal_ml" not in data:
        user.daily_goal_ml = calculate_daily_goal_ml(
            user.weight_kg, user.activity_level
        )

    db.commit()
    db.refresh(user)
    return user


@router.get("/{user_id}/summary")
def get_user_daily_summary(user_id: int, db: Session = Depends(get_db)):
    """
    Kullanıcı + bugünkü toplam su + hedef + yüzdelik oran + streak
    Frontend bu endpoint'i home screen için kullanabilir.
    """
    user = db.query(models.user.User).filter(models.user.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    today = date.today()

    q = (
        db.query(
            func.coalesce(
                func.sum(models.water_log.WaterLog.amount_ml), 0
            ).label("total"),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .filter(func.date(models.water_log.WaterLog.timestamp) == today)
        .first()
    )
    total_today = int(q.total) if q else 0

    # Basit streak hesabı (arka arkaya hedefi geçen günler)
    streak = _calculate_streak(db, user_id, user.daily_goal_ml)

    percent = (
        total_today / user.daily_goal_ml * 100 if user.daily_goal_ml > 0 else 0
    )

    return {
        "user": UserOut.from_orm(user),
        "today_total_ml": total_today,
        "daily_goal_ml": user.daily_goal_ml,
        "completion_percent": round(percent, 1),
        "streak_days": streak,
    }


def _calculate_streak(db: Session, user_id: int, goal_ml: int) -> int:
    """
    Bugünden geriye doğru giderek arka arkaya kaç gün
    hedefine ulaşmış bakıyoruz.
    """
    # Son 60 günü çekelim, yeter
    rows = (
        db.query(
            func.date(models.water_log.WaterLog.timestamp).label("d"),
            func.sum(models.water_log.WaterLog.amount_ml).label("total"),
        )
        .filter(models.water_log.WaterLog.user_id == user_id)
        .group_by("d")
        .order_by(func.date(models.water_log.WaterLog.timestamp).desc())
        .limit(60)
        .all()
    )

    totals_by_date = {r.d: int(r.total) for r in rows}

    streak = 0
    current = date.today()

    # Bugünden geriye doğru, hedefine ulaştığın her gün için streak++
    while True:
        total = totals_by_date.get(current, 0)
        if total >= goal_ml:
            streak += 1
            current = current.fromordinal(current.toordinal() - 1)
        else:
            break

    return streak
