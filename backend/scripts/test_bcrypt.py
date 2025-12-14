import sys
import os
sys.path.append(os.getcwd())
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

try:
    hash = pwd_context.hash("123456")
    print(f"Hash success: {hash}")
except Exception as e:
    print(f"Hash failed: {e}")
