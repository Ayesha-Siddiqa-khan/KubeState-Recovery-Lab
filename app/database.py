import os
from collections.abc import Generator
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


class Base(DeclarativeBase):
    pass


def _database_url() -> str:
    explicit_url = os.getenv("DATABASE_URL")
    if explicit_url:
        return explicit_url

    user = quote_plus(os.getenv("POSTGRES_USER", "appuser"))
    password = quote_plus(os.getenv("POSTGRES_PASSWORD", "CHANGE_ME_POSTGRES_PASSWORD"))
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    database = os.getenv("POSTGRES_DB", "kubestate")

    return f"postgresql+psycopg://{user}:{password}@{host}:{port}/{database}"


engine = create_engine(
    _database_url(),
    pool_pre_ping=True,
    pool_size=int(os.getenv("DB_POOL_SIZE", "5")),
    max_overflow=int(os.getenv("DB_MAX_OVERFLOW", "10")),
)

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_tables() -> None:
    Base.metadata.create_all(bind=engine)


def check_database() -> bool:
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
    return True

