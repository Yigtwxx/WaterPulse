from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_db
from app.schemas.avatar_schemas import AvatarSkinCreate, AvatarSkinOut
from app.services import avatar_service

router = APIRouter(prefix="/avatar", tags=["avatar"])


@router.get("/skins/{user_id}", response_model=List[AvatarSkinOut])
def list_skins(user_id: int, db: Session = Depends(get_db)):
    return avatar_service.list_user_skins(db, user_id)


@router.post("/skins", response_model=AvatarSkinOut)
def create_skin(payload: AvatarSkinCreate, db: Session = Depends(get_db)):
    return avatar_service.create_skin(db, payload)


@router.post("/skins/{skin_id}/unlock", response_model=AvatarSkinOut)
def unlock_skin(skin_id: int, db: Session = Depends(get_db)):
    return avatar_service.unlock_skin(db, skin_id)


@router.post("/skins/{skin_id}/activate", response_model=AvatarSkinOut)
def activate_skin(skin_id: int, db: Session = Depends(get_db)):
    return avatar_service.activate_skin(db, skin_id)
