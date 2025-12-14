import sys
import os
from passlib.context import CryptContext

# Add current directory to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app.models.user import User

# Setup hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def reset_password(email):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"User {email} not found.")
            return

        new_password = "123456"
        user.hashed_password = pwd_context.hash(new_password)
        db.commit()
        print(f"Success! Password for {email} reset to '{new_password}'")

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
    reset_password(email)
