import logging
import os
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database import check_database, create_tables, get_db
from models import Item
from redis_client import check_redis, redis_client
from schemas import (
    CheckResponse,
    DependencyStatus,
    HealthResponse,
    ItemCreate,
    ItemRead,
    VisitResponse,
)


logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger("kubestate-api")

SERVICE_NAME = os.getenv("APP_NAME", "KubeState Recovery Lab API")
VISIT_COUNTER_KEY = os.getenv("VISIT_COUNTER_KEY", "kubestate:visits")


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        create_tables()
        logger.info("Database schema check completed")
    except SQLAlchemyError:
        logger.exception("Database schema check failed; readiness will report unhealthy")

    yield


app = FastAPI(
    title=SERVICE_NAME,
    description="Simple API for proving PostgreSQL and Redis state in Kubernetes.",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok", service=SERVICE_NAME)


@app.get("/ready", response_model=DependencyStatus)
def ready(response: Response) -> DependencyStatus:
    postgres_status = "ok"
    redis_status = "ok"

    try:
        check_database()
    except Exception:
        logger.exception("PostgreSQL readiness check failed")
        postgres_status = "error"

    try:
        check_redis()
    except Exception:
        logger.exception("Redis readiness check failed")
        redis_status = "error"

    overall_status = "ready" if postgres_status == "ok" and redis_status == "ok" else "not_ready"
    if overall_status != "ready":
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE

    return DependencyStatus(
        status=overall_status,
        postgres=postgres_status,
        redis=redis_status,
    )


@app.post("/items", response_model=ItemRead, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate, db: Session = Depends(get_db)) -> Item:
    db_item = Item(name=item.name, description=item.description)
    try:
        db.add(db_item)
        db.commit()
        db.refresh(db_item)
    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to create item")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="PostgreSQL write failed",
        ) from exc

    return db_item


@app.get("/items", response_model=list[ItemRead])
def list_items(db: Session = Depends(get_db)) -> list[Item]:
    try:
        return list(db.scalars(select(Item).order_by(Item.id.desc())).all())
    except SQLAlchemyError as exc:
        logger.exception("Failed to list items")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="PostgreSQL read failed",
        ) from exc


@app.post("/visits", response_model=VisitResponse)
def increment_visits() -> VisitResponse:
    try:
        visits = redis_client.incr(VISIT_COUNTER_KEY)
        return VisitResponse(visits=int(visits))
    except Exception as exc:
        logger.exception("Failed to increment Redis visit counter")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Redis write failed",
        ) from exc


@app.get("/visits", response_model=VisitResponse)
def get_visits() -> VisitResponse:
    try:
        visits = redis_client.get(VISIT_COUNTER_KEY) or 0
        return VisitResponse(visits=int(visits))
    except Exception as exc:
        logger.exception("Failed to read Redis visit counter")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Redis read failed",
        ) from exc


@app.get("/db-check", response_model=CheckResponse)
def db_check() -> CheckResponse:
    try:
        check_database()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="PostgreSQL connection failed",
        ) from exc

    return CheckResponse(status="ok", detail="PostgreSQL connection successful")


@app.get("/redis-check", response_model=CheckResponse)
def redis_check() -> CheckResponse:
    try:
        check_redis()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Redis connection failed",
        ) from exc

    return CheckResponse(status="ok", detail="Redis connection successful")
