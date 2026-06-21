from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class HealthResponse(BaseModel):
    status: str
    service: str


class DependencyStatus(BaseModel):
    status: str
    postgres: str
    redis: str


class ItemCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=500)


class ItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    created_at: datetime


class VisitResponse(BaseModel):
    visits: int


class CheckResponse(BaseModel):
    status: str
    detail: str

