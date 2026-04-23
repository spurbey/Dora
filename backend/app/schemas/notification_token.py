"""
Pydantic schemas for notification device token lifecycle endpoints.
"""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field


PushPlatform = Literal["ios", "android", "web"]


class DeviceTokenRegisterRequest(BaseModel):
    client_event_id: str = Field(..., min_length=1, max_length=128)
    platform: PushPlatform
    push_token: str = Field(..., min_length=1, max_length=512)
    seen_at: datetime | None = None
    device_id: str | None = Field(default=None, max_length=128)
    app_version: str | None = Field(default=None, max_length=32)
    locale: str | None = Field(default=None, max_length=32)


class DeviceTokenDeactivateRequest(BaseModel):
    client_event_id: str = Field(..., min_length=1, max_length=128)
    push_token: str = Field(..., min_length=1, max_length=512)
    deactivated_at: datetime | None = None


class DeviceTokenPayload(BaseModel):
    id: UUID
    user_id: UUID
    platform: PushPlatform
    is_active: bool
    failure_count: int
    last_seen_at: datetime
    created_at: datetime
    updated_at: datetime


class DeviceTokenMutationResponse(BaseModel):
    token: DeviceTokenPayload | None = None
    idempotency_replayed: bool = False
