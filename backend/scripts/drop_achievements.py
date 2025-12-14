
import psycopg2
import os
from dotenv import load_dotenv

# Load .env
load_dotenv("backend/.env")
url = os.getenv("DATABASE_URL")

try:
    print("Connecting to DB...")
    conn = psycopg2.connect(url)
    cur = conn.cursor()
    
    # Drop table
    print("Dropping 'achievements' table...")
    cur.execute("DROP TABLE IF EXISTS achievements CASCADE;")
    conn.commit()
    print("Dropped.")
    
    conn.close()
except Exception as e:
    print(f"Error: {e}")
