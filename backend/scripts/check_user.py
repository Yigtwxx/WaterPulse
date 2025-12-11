
import sqlite3
import os

# Use absolute path to ensure we are checking the right file
db_path = r'c:\Users\Asus\Desktop\WaterPulse\backend\waterpulse.db'
print(f"Checking {db_path}...")

try:
    if not os.path.exists(db_path):
        print("ERROR: Database file not found at path!")
    else:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        email_to_check = "gwenn07437@gmail.com"
        cursor.execute("SELECT id, email, name FROM users WHERE email = ?", (email_to_check,))
        user = cursor.fetchone()
        
        if user:
            print(f"User FOUND with ID: {user[0]}")
        else:
            print(f"User NOT FOUND: {email_to_check}")
            
        cursor.execute("SELECT email FROM users")
        all_users = cursor.fetchall()
        print("All users:")
        for u in all_users:
            try:
                print(f" - {u[0]}")
            except:
                print(" - (encoding error)")
        
        conn.close()
except Exception as e:
    print(f"Error: {e}")
