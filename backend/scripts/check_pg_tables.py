
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv("backend/.env")
url = os.getenv("DATABASE_URL")

try:
    print(f"Connecting to: {url}")
    conn = psycopg2.connect(url)
    cur = conn.cursor()
    
    # Check columns
    cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'achievements';")
    cols = cur.fetchall()
    print("Columns in 'achievements':")
    for c in cols:
        print(f" - {c[0]} ({c[1]})")
        
    conn.close()
except Exception as e:
    print(f"Error: {e}")
