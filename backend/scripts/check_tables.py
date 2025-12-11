import os
import sys
from dotenv import load_dotenv

# Load .env explicitly before importing settings
# Adjusted for scripts/ directory
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)
load_dotenv(os.path.join(project_root, ".env"))

from sqlalchemy import create_engine, inspect
from app.core.config import settings

db_url = os.getenv("DATABASE_URL")
print(f"Checking DB: {db_url}")

engine = create_engine(db_url)
inspector = inspect(engine)
tables = inspector.get_table_names()
print(f"Tables found: {tables}")
