
import os
import sys
from sqlalchemy import create_engine, text
from urllib.parse import urlparse, urlunparse

# Add current directory to python path
sys.path.append(os.getcwd())
try:
    from app.core.config import settings
except Exception:
    # If pydantic fails, just load env manually roughly or fail
    pass

def create_database():
    target_url = settings.DATABASE_URL
    
    # Check if target is postgres
    if "postgresql" not in target_url:
        print("Not a postgres URL, skipping creation.")
        return

    # Parse the URL and switch database to 'postgres' to perform administration
    # Format: postgresql://user:pass@host:port/dbname
    # We want to connect to 'postgres' db
    
    # Simple string manipulation to be safe with dependencies
    base_url = target_url.rsplit('/', 1)[0]
    db_name = target_url.rsplit('/', 1)[1]
    
    admin_url = f"{base_url}/postgres"
    
    print(f"Connecting to admin DB: {admin_url}")
    
    try:
        engine = create_engine(admin_url, isolation_level="AUTOCOMMIT")
        with engine.connect() as conn:
            # Check if db exists
            result = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}'"))
            if result.fetchone():
                print(f"Database '{db_name}' already exists.")
            else:
                print(f"Creating database '{db_name}'...")
                conn.execute(text(f"CREATE DATABASE {db_name}"))
                print("Database created successfully!")
                
    except Exception as e:
        print(f"Failed to create database: {e}")

if __name__ == "__main__":
    create_database()
