import sys
import os
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(project_root)
from dotenv import load_dotenv
load_dotenv(os.path.join(project_root, ".env"))

from app.db.session import engine, Base
from app.models.poke import Poke

print("Creating pokes table...")
Base.metadata.create_all(bind=engine)
print("Done.")
