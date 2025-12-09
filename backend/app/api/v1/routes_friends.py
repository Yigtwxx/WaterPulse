# backend/app/api/v1/routes_friends.py
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.session import get_db
from app import models
from app.schemas.friend_schemas import (
    FriendCompareRequest, 
    FriendDailyTotal,
    FriendWithStats,
    PokeRequest,
    PokeResponse
)

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
            models.user.User.name,
            models.user.User.daily_goal_ml,
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
        .group_by(models.user.User.id, models.user.User.name, models.user.User.daily_goal_ml)
        .all()
    )

    # Arkadaş listesinde olup hiç water_log'u olmayanlar da gelsin
    existing_ids = {r.id for r in rows}
    missing_ids = set(user_ids) - existing_ids

    for uid in missing_ids:
        u = db.query(models.user.User).filter(models.user.User.id == uid).first()
        if u:
            rows.append(type("R", (), {"id": u.id, "name": u.name, "daily_goal_ml": u.daily_goal_ml, "total": 0}))

    return [
        FriendDailyTotal(
            user_id=r.id,
            username=r.name or "Unknown",
            total_ml=int(r.total),
            daily_goal_ml=r.daily_goal_ml or 2000,
        )
        for r in rows
    ]


class AddFriendRequest(BaseModel):
    user_id: int
    friend_code: str


@router.post("/add")
def add_friend(
    payload: AddFriendRequest,
    db: Session = Depends(get_db),
):
    # 1. Find friend by code
    friend = db.query(models.user.User).filter(models.user.User.friend_code == payload.friend_code).first()
    if not friend:
        raise HTTPException(status_code=404, detail="Friend code not found")

    if friend.id == payload.user_id:
        raise HTTPException(status_code=400, detail="You cannot add yourself")

    # 2. Check if already friends (For now, we don't have a Friends table, 
    # we just rely on the frontend storing friend IDs list. 
    # BUT, to make this robust, we should return the friend's ID so frontend can add it to its list)
    
    return {
        "message": "Friend found",
        "friend_id": friend.id,
        "friend_name": friend.name
    }


@router.get("/list/{user_id}", response_model=list[FriendWithStats])
def list_friends(
    user_id: int,
    db: Session = Depends(get_db),
):
    """
    Returns the user's friends with calculated mutual streaks and today's water uptake.
    NOTE: Currently mimics "friends" by just finding all other users for demo if no friends table populated.
    In a real app, we would query the Friend association table.
    """
    # 1. Get friend IDs (For this task, we will try to find actual friends if they exist, 
    # but fall back to "all other users" if the Friends table is empty for better demo experience)
    
    friend_links = db.query(models.friend.Friend).filter(
        (models.friend.Friend.user_id == user_id) | (models.friend.Friend.friend_user_id == user_id)
    ).all()
    
    friend_ids = set()
    for link in friend_links:
        if link.user_id == user_id:
            friend_ids.add(link.friend_user_id)
        else:
            friend_ids.add(link.user_id)
            
    # Fallback for demo: if no friends, show some other users (limit 5)
    if not friend_ids:
         others = db.query(models.user.User).filter(models.user.User.id != user_id).limit(5).all()
         friend_ids = {u.id for u in others}

    friends_data = []
    today = date.today()
    
    from app.services.streak_service import calculate_mutual_streak
    from app.services.water_service import get_daily_total
    
    for fid in friend_ids:
        f_user = db.query(models.user.User).filter(models.user.User.id == fid).first()
        if not f_user:
            continue
            
        # Calc mutual streak
        m_streak = calculate_mutual_streak(db, user_id, fid)
        
        # Get today's logs
        total = get_daily_total(db, fid, today)
        
        # Check if poked today? (Optional optimization)
        
        friends_data.append(
            FriendWithStats(
                id=f_user.id,
                username=f_user.name or f"User {f_user.id}",
                avatar_url=None, # Add if avatar field exists
                daily_goal_ml=f_user.daily_goal_ml or 2000,
                today_total_ml=total,
                mutual_streak_days=m_streak,
                has_poked_today=False # Implement if needed
            )
        )
        
    return friends_data


@router.post("/poke", response_model=PokeResponse)
def poke_friend(
    payload: PokeRequest,
    db: Session = Depends(get_db),
):
    # Check if already poked recently? (Rate limiting)
    # For now, just create the poke
    
    new_poke = models.poke.Poke(
        sender_id=payload.sender_id,
        receiver_id=payload.receiver_id,
        is_read=False
    )
    db.add(new_poke)
    db.commit()
    db.refresh(new_poke)
    return new_poke


@router.get("/pokes/{user_id}", response_model=list[PokeResponse])
def get_pending_pokes(
    user_id: int,
    db: Session = Depends(get_db),
):
    return (
        db.query(models.poke.Poke)
        .filter(models.poke.Poke.receiver_id == user_id)
        .filter(models.poke.Poke.is_read == False)
        .order_by(models.poke.Poke.created_at.desc())
        .all()
    )
