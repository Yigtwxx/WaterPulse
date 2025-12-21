from fastapi.testclient import TestClient
from app.main import app
from app.core.security import create_access_token

client = TestClient(app)

def test_get_recommendations(db_session):
    # 1. Create a user
    email = "sport_user@example.com"
    password = "password123"
    
    # Register
    client.post("/api/v1/users/", json={
        "email": email,
        "password": password,
        "weight_kg": 70,
        "height_cm": 175,
        "age": 30,
        "gender": "male",
        "activity_level": "medium"
    })
    
    # Login to get ID
    login_res = client.post("/api/v1/users/login", json={"email": email, "password": password})
    user_id = login_res.json()["id"]
    
    # 2. Get Recommendations
    response = client.get(f"/api/v1/users/{user_id}/recommendations")
    assert response.status_code == 200
    data = response.json()
    
    # Check fields
    assert "bmi" in data
    assert "bmi_status" in data
    assert "recommendations" in data
    assert len(data["recommendations"]) > 0
    
    # Check if logic works (BMI for 70kg, 1.75m -> ~22.9 -> Normal)
    assert data["bmi_status"] == "Normal"

def test_recommendation_underweight(db_session):
    # Create user with low weight
    email = "thin_user@example.com"
    password = "password123"
    
    res = client.post("/api/v1/users/", json={
        "email": email,
        "password": password,
        "weight_kg": 45,
        "height_cm": 170
    })
    user_id = res.json()["id"]

    response = client.get(f"/api/v1/users/{user_id}/recommendations")
    data = response.json()
    assert data["bmi_status"] == "Zayıf"

