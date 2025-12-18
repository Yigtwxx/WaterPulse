import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.db.session import Base
from app.models import user, achievement, streak, water_log

@pytest.fixture(scope="function")
def db_session():
    engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(
        autocommit=False, autoflush=False, bind=engine
    )
    Base.metadata.create_all(bind=engine)
    
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
