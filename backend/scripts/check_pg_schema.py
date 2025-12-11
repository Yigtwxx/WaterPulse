
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv("backend/.env")
url = os.getenv("DATABASE_URL")

try:
    conn = psycopg2.connect(url)
    cur = conn.cursor()
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'achievements';")
    cols = [c[0] for c in cur.fetchall()]
    print(f"Columns: {cols}")
    conn.close()
except Exception as e:
    print(f"Error: {e}")
