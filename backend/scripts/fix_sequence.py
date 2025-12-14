
import sys
import os
from sqlalchemy import text

# Add project root to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal

def fix_sequences():
    db = SessionLocal()
    try:
        print("Fixing sequences...")
        
        # List of tables to fix
        tables = ["water_logs", "achievements", "streaks", "users", "avatar_skins"]
        
        for table in tables:
            try:
                # Postgres specific sequence reset
                # This sets the sequence to the MAX(id) of the table
                sql = text(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), coalesce(max(id), 0) + 1, false) FROM {table};")
                db.execute(sql)
                db.commit()
                print(f"Fixed sequence for {table}")
            except Exception as e:
                print(f"Error fixing {table}: {e}")
                db.rollback()
                
        print("Done.")
    finally:
        db.close()

if __name__ == "__main__":
    fix_sequences()
