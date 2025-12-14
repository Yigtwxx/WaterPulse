import requests
import json

def test_add_water():
    url = "http://127.0.0.1:8000/api/v1/water/log"
    payload = {
        "user_id": 1,
        "amount_ml": 200
    }
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
    except Exception as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    test_add_water()
