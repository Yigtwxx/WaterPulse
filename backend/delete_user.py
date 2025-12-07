import sqlite3
import os

DB_PATH = "waterpulse.db"

def delete_user(email):
    if not os.path.exists(DB_PATH):
        print(f"Database not found at {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        # Check if user exists first
        cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
        user = cursor.fetchone()
        
        if not user:
            print(f"User with email '{email}' not found.")
            return

        user_id = user[0]
        
        # Delete related data first (optional depending on FK constraints, but safer)
        # Assuming cascade might not be set up or just to be clean
        cursor.execute("DELETE FROM water_logs WHERE user_id = ?", (user_id,))
        cursor.execute("DELETE FROM achievements WHERE user_id = ?", (user_id,))
        cursor.execute("DELETE FROM streaks WHERE user_id = ?", (user_id,))
        
        # Delete the user
        cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
        
        if cursor.rowcount > 0:
            print(f"User '{email}' (ID: {user_id}) and related data deleted successfully.")
            conn.commit()
        else:
            print("Failed to delete user.")
                
    except Exception as e:
        print(f"Error querying database: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    delete_user("gwenn07437@gmail.com")
