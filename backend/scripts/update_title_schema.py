import os
import sys

# Adjusted for scripts/ directory
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)
from dotenv import load_dotenv
load_dotenv(os.path.join(project_root, ".env"))

from app.db.session import engine
from sqlalchemy import text

def update_schema():
    print("Updating database schema...")
    with engine.connect() as conn:
        conn.execution_options(isolation_level="AUTOCOMMIT")
        
        # Check if column exists
        result = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='selected_title'"))
        if not result.fetchone():
            print("Adding selected_title column...")
            conn.execute(text("ALTER TABLE users ADD COLUMN selected_title VARCHAR DEFAULT NULL"))
        else:
            print("Column selected_title already exists.")
            
    print("Schema update complete.")

if __name__ == "__main__":
    update_schema()
