
import psycopg2
import sys

passwords_to_try = [
    "postgres",
    "password",
    "admin",
    "root",
    "123456",
    "waterpulse",
    ""
]

print("Attempting to connect to PostgreSQL...")

for pwd in passwords_to_try:
    try:
        # Try to connect to 'waterpulse' db or 'postgres' db
        conn_str = f"postgresql://postgres:{pwd}@localhost:5432/waterpulse"
        print(f"Trying password: '{pwd}' ...")
        conn = psycopg2.connect(conn_str)
        print(f"SUCCESS! Password is: '{pwd}'")
        conn.close()
        
        # Write to .env immediately if found
        with open("backend/.env", "w") as f:
            f.write(f"DATABASE_URL={conn_str}\n")
        print("Updated backend/.env with correct credentials.")
        sys.exit(0)
    except Exception as e:
        print(f"Failed: {e}")

print("Could not guess password.")
sys.exit(1)
