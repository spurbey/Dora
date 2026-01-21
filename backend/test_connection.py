from app.database import engine
from sqlalchemy import text

def test_connection():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            print("✅ Database connection successful!")
            
            result = conn.execute(text("SELECT PostGIS_version()"))
            version = result.fetchone()[0]
            print(f"✅ PostGIS version: {version}")
            
    except Exception as e:
        print(f"❌ Database connection failed: {e}")

if __name__ == "__main__":
    test_connection()