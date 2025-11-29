from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models import avatar_skin
from app.schemas.avatar_schemas import AvatarSkinCreate


def list_user_skins(db: Session, user_id: int):
    return (
        db.query(avatar_skin.AvatarSkin)
        .filter(avatar_skin.AvatarSkin.user_id == user_id)
        .order_by(avatar_skin.AvatarSkin.created_at.desc())
        .all()
    )


def create_skin(db: Session, payload: AvatarSkinCreate):
    skin = avatar_skin.AvatarSkin(
        user_id=payload.user_id,
        name=payload.name,
        color=payload.color,
        is_unlocked=payload.is_unlocked,
        is_active=payload.is_active,
    )
    db.add(skin)
    db.commit()
    db.refresh(skin)
    return skin


def unlock_skin(db: Session, skin_id: int):
    skin = (
        db.query(avatar_skin.AvatarSkin)
        .filter(avatar_skin.AvatarSkin.id == skin_id)
        .first()
    )
    if not skin:
        raise HTTPException(status_code=404, detail="Skin not found")

    skin.is_unlocked = True
    db.commit()
    db.refresh(skin)
    return skin


def activate_skin(db: Session, skin_id: int):
    skin = (
        db.query(avatar_skin.AvatarSkin)
        .filter(avatar_skin.AvatarSkin.id == skin_id)
        .first()
    )
    if not skin:
        raise HTTPException(status_code=404, detail="Skin not found")

    # Deactivate other skins for this user
    db.query(avatar_skin.AvatarSkin).filter(
        avatar_skin.AvatarSkin.user_id == skin.user_id
    ).update({"is_active": False})

    skin.is_active = True
    db.commit()
    db.refresh(skin)
    return skin
