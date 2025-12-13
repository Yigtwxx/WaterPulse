import sys
import os
from dotenv import load_dotenv

# Adjusted for scripts/ directory
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)

# Load .env explicitly
load_dotenv(os.path.join(project_root, ".env"))
if not os.getenv("DATABASE_URL"):
    print("Error: DATABASE_URL not found in .env")
    print("Please set DATABASE_URL (e.g., postgresql://user:pass@localhost:5432/db)")
    sys.exit(1)

from app.db.session import engine, Base
from app.db.session import engine, Base
# Import all models to ensure they are registered with Base.metadata
from app.models import User, WaterLog, Achievement, Friend, Streak, AvatarSkin, Poke

def create_tables():
    print("Creating all tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully.")

if __name__ == "__main__":
    create_tables()
