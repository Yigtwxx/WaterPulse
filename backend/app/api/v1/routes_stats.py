from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.stats_service import StatsService

router = APIRouter()

@router.get("/heatmap/day/{user_id}")
def get_day_heatmap(
    user_id: int,
    db: Session = Depends(get_db),
):
    service = StatsService(db)
    image_bytes = service.generate_day_heatmap(user_id)
    return Response(content=image_bytes, media_type="image/png")

@router.get("/heatmap/week/{user_id}")
def get_week_heatmap(
    user_id: int,
    db: Session = Depends(get_db),
):
    service = StatsService(db)
    image_bytes = service.generate_week_heatmap(user_id)
    return Response(content=image_bytes, media_type="image/png")

@router.get("/heatmap/month/{user_id}")
def get_month_heatmap(
    user_id: int,
    db: Session = Depends(get_db),
):
    service = StatsService(db)
    image_bytes = service.generate_month_heatmap(user_id)
    return Response(content=image_bytes, media_type="image/png")
