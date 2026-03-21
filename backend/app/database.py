from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config import settings

# Keep schema resolution deterministic across local/dev/clone connections.
DEFAULT_DB_CONNECT_ARGS = {
    "connect_timeout": 10,
    "options": "-c search_path=public,extensions",
}


def create_db_engine(database_url: str, **kwargs):
    connect_args = dict(DEFAULT_DB_CONNECT_ARGS)
    extra_connect_args = kwargs.pop("connect_args", None)
    if extra_connect_args:
        connect_args.update(extra_connect_args)
    return create_engine(database_url, connect_args=connect_args, **kwargs)


engine = create_db_engine(
    settings.SUPABASE_DB_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
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
