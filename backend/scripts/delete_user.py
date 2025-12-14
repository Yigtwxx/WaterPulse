import sys
import os

# Add current directory to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app.models.user import User

def delete_user(email):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"User with email '{email}' not found.")
            return

        print(f"Deleting user: {user.email} (ID: {user.id})")
        db.delete(user)
        db.commit()
        print("User deleted successfully.")

    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        email = sys.argv[1]
    else:
        email = "gwenn07437@gmail.com"
    delete_user(email)
