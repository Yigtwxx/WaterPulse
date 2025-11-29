from app.models import user as user_model
from backend.tests.test_base import get_test_client


def test_create_and_get_user():
    client, session_local = get_test_client()

    payload = {
        "username": "new_user",
        "daily_goal_ml": 2100,
        "preferred_cup_ml": 250,
        "language": "en",
    }

    res = client.post("/api/v1/users/", json=payload)
    assert res.status_code == 200
    created = res.json()
    assert created["username"] == "new_user"
    new_id = created["id"]

    res_get = client.get(f"/api/v1/users/{new_id}")
    assert res_get.status_code == 200
    assert res_get.json()["id"] == new_id

    # Verify it persisted in the test DB
    with session_local() as db:
        stored = db.query(user_model.User).filter(user_model.User.id == new_id).first()
        assert stored is not None
