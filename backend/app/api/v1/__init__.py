# backend/app/api/v1/__init__.py
from fastapi import APIRouter

from . import routes_users, routes_water, routes_friends

api_router = APIRouter()
api_router.include_router(routes_users.router)
api_router.include_router(routes_water.router)
api_router.include_router(routes_friends.router)
