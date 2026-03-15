from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config import settings

engine = create_engine(
    settings.SUPABASE_DB_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    # Fail fast on unreachable DB instead of hanging for 7+ minutes
    connect_args={"connect_timeout": 10},
    pool_recycle=300,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()