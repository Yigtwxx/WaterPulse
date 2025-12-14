
import sys
import os
from sqlalchemy import text

# Add project root to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal

def update_schema():
    db = SessionLocal()
    try:
        print("Updating schema to add notification columns...")
        
        # We'll use raw SQL to add columns if they don't exist
        # SQLite vs Postgres syntax is slightly different for checking existence, 
        # but ADD COLUMN IF NOT EXISTS is standard in Postgres 9.6+.
        # For simplicity in this script without extensive detection, we'll try to add and ignore "duplicate column" error
        
        columns = [
            ("notifications_enabled", "BOOLEAN DEFAULT TRUE"),
            ("notification_interval", "INTEGER DEFAULT 105"),
            ("notification_start_hour", "INTEGER DEFAULT 9"),
            ("notification_end_hour", "INTEGER DEFAULT 23"),
        ]
        
        for col_name, col_def in columns:
            try:
                # Postgres Syntax
                sql = text(f"ALTER TABLE users ADD COLUMN IF NOT EXISTS {col_name} {col_def};")
                db.execute(sql)
                db.commit()
                print(f"Added column {col_name}")
            except Exception as e:
                print(f"Error adding {col_name} (might already exist): {e}")
                db.rollback()
                
        print("Schema update complete.")
    finally:
        db.close()

if __name__ == "__main__":
    update_schema()
