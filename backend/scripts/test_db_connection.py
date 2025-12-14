
import os
import sys
from sqlalchemy import create_engine

# Add current directory to python path
sys.path.append(os.getcwd())
from app.core.config import settings

def test_connection():
    url = settings.DATABASE_URL
    print(f"Testing connection to: {url}")
    
    try:
        engine = create_engine(url)
        with engine.connect() as conn:
            print("Successfully connected!")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    test_connection()
