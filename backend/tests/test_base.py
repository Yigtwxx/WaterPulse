from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db.session import Base, get_db
from app.main import app
from app.models import user as user_model


def get_test_client():
    engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(
        autocommit=False, autoflush=False, bind=engine
    )
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    with TestingSessionLocal() as db:
        if not db.query(user_model.User).filter(user_model.User.id == 1).first():
            db.add(
                user_model.User(
                    id=1,
                    username="seed_user",
                    daily_goal_ml=2400,
                    preferred_cup_ml=250,
                    language="en",
                )
            )
            db.commit()

    client = TestClient(app)
    return client, TestingSessionLocal


def test_root_alive():
    client, _ = get_test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.json().get("message") is not None
