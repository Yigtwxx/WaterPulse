# backend/app/api/v1/__init__.py
# router'ları burada birleştirip main.py'de kullanacağız.
from fastapi import APIRouter

from . import routes_users, routes_water

api_router = APIRouter()
api_router.include_router(routes_users.router)
api_router.include_router(routes_water.router)
