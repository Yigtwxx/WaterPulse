# backend/app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.db.session import Base, engine
from app.db.init_db import init_db
from app.api.v1 import api_router
from app import models  # noqa: F401 - ensure models are imported for metadata

import os

@asynccontextmanager
async def lifespan(app: FastAPI):
    if os.getenv("TESTING"):
        yield
        return
    # Tabloları oluştur
    Base.metadata.create_all(bind=engine)
    # Varsayılan kullanıcıyı oluştur
    init_db()
    yield

app = FastAPI(title=settings.PROJECT_NAME, lifespan=lifespan)

# Geliştirme için CORS (Flutter web / emulator için)
origins = [
    "http://localhost:3000",
    "http://localhost:4000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:4000",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme için geniş tuttuk, prod'da daralt
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
def read_root():
    return {"message": "WaterPulse API is running"}
