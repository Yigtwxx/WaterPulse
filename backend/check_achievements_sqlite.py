import sqlite3
import os

DB_PATH = "waterpulse.db"

def check_latest_user_achievements():
    if not os.path.exists(DB_PATH):
        print(f"Database not found at {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        # Get latest user
        cursor.execute("SELECT id, email FROM users ORDER BY id DESC LIMIT 1")
        user = cursor.fetchone()
        
        if not user:
            print("No users found.")
            return

        user_id = user[0]
        email = user[1]
        print(f"Latest User: ID={user_id}, Email={email}")
        
        # Check achievements
        cursor.execute("SELECT title, description, unlocked_at FROM achievements WHERE user_id = ?", (user_id,))
        achievements = cursor.fetchall()
        
        if achievements:
            print(f"Found {len(achievements)} achievements:")
            for a in achievements:
                print(f" - {a[0]}: {a[1]} (Unlocked: {a[2]})")
        else:
            print("No achievements found for this user.")
            
            # Check water logs to see if they SHOULD have achievements
            cursor.execute("SELECT COUNT(*), SUM(amount_ml) FROM water_logs WHERE user_id = ?", (user_id,))
            logs = cursor.fetchone()
            print(f"Water Logs: Count={logs[0]}, Total Volume={logs[1]}")
            
    except Exception as e:
        print(f"Error querying database: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    check_latest_user_achievements()
