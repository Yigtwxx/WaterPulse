# backend/app/api/v1/routes_friends.py
from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.friend_schemas import FriendCompareRequest, FriendDailyTotal

router = APIRouter(prefix="/friends", tags=["friends"])


@router.post("/compare", response_model=list[FriendDailyTotal])
def compare_with_friends(
    payload: FriendCompareRequest,
    db: Session = Depends(get_db),
):
    """
    Bir gün için (payload.date) user + friend_ids için toplamları döner.
    Frontend arkadaş karşılaştırma ekranında kullanabilir.
    """

    user_ids = [payload.user_id] + payload.friend_ids

    rows = (
        db.query(
            models.user.User.id,
            models.user.User.username,
            func.coalesce(
                func.sum(models.water_log.WaterLog.amount_ml), 0
            ).label("total"),
        )
        .join(
            models.water_log.WaterLog,
            models.water_log.WaterLog.user_id == models.user.User.id,
            isouter=True,
        )
        .filter(models.user.User.id.in_(user_ids))
        .filter(
            func.date(models.water_log.WaterLog.timestamp) == payload.date
        )
        .group_by(models.user.User.id, models.user.User.username)
        .all()
    )

    # Arkadaş listesinde olup hiç water_log'u olmayanlar da gelsin
    existing_ids = {r.id for r in rows}
    missing_ids = set(user_ids) - existing_ids

    for uid in missing_ids:
        u = db.query(models.user.User).filter(models.user.User.id == uid).first()
        if u:
            rows.append(type("R", (), {"id": u.id, "username": u.username, "total": 0}))

    return [
        FriendDailyTotal(
            user_id=r.id,
            username=r.username,
            total_ml=int(r.total),
        )
        for r in rows
    ]
