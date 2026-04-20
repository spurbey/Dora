"""
Pydantic schemas for stories APIs.
"""

from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class StoryResponse(BaseModel):
    id: UUID
    client_story_id: str
    author_user_id: UUID
    media_type: str
    media_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    duration_ms: Optional[int] = None
    center_lat: float
    center_lng: float
    status: str
    published_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None
    view_count: int = 0
    created_at: datetime
    updated_at: datetime
    distance_km: Optional[float] = None
    is_own: bool = False

    class Config:
        from_attributes = True


class StoryFeedResponse(BaseModel):
    stories: list[StoryResponse]
    next_cursor: Optional[str] = None


class StoryReportRequest(BaseModel):
    reason: str = Field(..., min_length=2, max_length=64)
    details: Optional[str] = Field(default=None, max_length=1000)


class StoryMuteResponse(BaseModel):
    muted_author_id: UUID
    muted: bool


class StoryModerationResponse(BaseModel):
    story_id: UUID
    status: str
