
import sys
import os
sys.path.append(os.getcwd())
from app.db.session import SessionLocal
from app.models import user

def find_user():
    db = SessionLocal()
    users = db.query(user.User).all()
    for u in users:
        print(f"ID: {u.id}, Name: {u.name} {u.surname}, Goal: {u.daily_goal_ml}, Email: {u.email}")
    db.close()

if __name__ == "__main__":
    find_user()
