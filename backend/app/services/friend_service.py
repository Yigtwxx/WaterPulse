from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models import friend


def send_request(db: Session, user_id: int, friend_user_id: int):
    if user_id == friend_user_id:
        raise HTTPException(status_code=400, detail="Cannot add yourself as friend")

    exists = (
        db.query(friend.Friend)
        .filter(friend.Friend.user_id == user_id)
        .filter(friend.Friend.friend_user_id == friend_user_id)
        .first()
    )
    if exists:
        return exists

    relation = friend.Friend(
        user_id=user_id,
        friend_user_id=friend_user_id,
        status="pending",
    )
    db.add(relation)
    db.commit()
    db.refresh(relation)
    return relation


def accept_request(db: Session, relation_id: int):
    relation = (
        db.query(friend.Friend)
        .filter(friend.Friend.id == relation_id)
        .first()
    )
    if not relation:
        raise HTTPException(status_code=404, detail="Friend relation not found")

    relation.status = "accepted"
    db.commit()
    db.refresh(relation)
    return relation


def list_friends(db: Session, user_id: int):
    relations = (
        db.query(friend.Friend)
        .filter(friend.Friend.status == "accepted")
        .filter(
            (friend.Friend.user_id == user_id)
            | (friend.Friend.friend_user_id == user_id)
        )
        .all()
    )
    return relations
