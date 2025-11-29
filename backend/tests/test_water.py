from backend.tests.test_base import get_test_client


def test_add_water_log_and_total():
    client, _ = get_test_client()

    res = client.post(
        "/api/v1/water/log",
        json={"user_id": 1, "amount_ml": 300},
    )
    assert res.status_code == 200

    res_total = client.get("/api/v1/water/daily-total/1")
    assert res_total.status_code == 200
    body = res_total.json()
    assert body["total_ml"] >= 300


def test_streak_summary_endpoint():
    client, _ = get_test_client()
    res = client.get("/api/v1/streaks/1/summary")
    assert res.status_code == 200
    data = res.json()
    assert {"current_streak", "best_streak", "goal_ml"}.issubset(data.keys())
