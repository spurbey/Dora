"""
Pydantic schemas for live-tracking Phase 2 API contracts.
"""

from datetime import datetime
from typing import Any, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, Field


SessionState = Literal["active", "paused", "ended", "abandoned"]
TripTrackingStatus = Literal[
    "planned",
    "tracking_active",
    "tracking_paused",
    "review_pending",
    "completed",
    "shared",
]
CheckinStatus = Literal["pending", "confirmed", "rejected", "snoozed", "expired"]
DevicePlatform = Literal["ios", "android", "web"]


class TrackingStartRequest(BaseModel):
    client_session_id: str = Field(..., min_length=1, max_length=64)
    started_at: datetime
    timezone: Optional[str] = Field(None, max_length=64)
    device_context: dict[str, Any] = Field(default_factory=dict)


class TrackingPauseRequest(BaseModel):
    client_event_id: UUID
    session_id: Optional[UUID] = None
    paused_at: datetime
    reason: Optional[str] = None


class TrackingResumeRequest(BaseModel):
    client_event_id: UUID
    session_id: Optional[UUID] = None
    resumed_at: datetime


class TrackingStopRequest(BaseModel):
    client_event_id: UUID
    session_id: Optional[UUID] = None
    stopped_at: datetime
    reason: Optional[str] = None


class TrackingSessionResponse(BaseModel):
    session_id: UUID
    trip_id: UUID
    user_id: UUID
    state: SessionState
    client_session_id: str
    started_at: datetime
    paused_at: Optional[datetime] = None
    resumed_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    abandoned_at: Optional[datetime] = None
    last_point_at: Optional[datetime] = None
    timezone: Optional[str] = None
    device_context: dict[str, Any] = Field(default_factory=dict)
    trip_status: TripTrackingStatus
    tracking_enabled: bool
    tracking_started_at: Optional[datetime] = None
    tracking_ended_at: Optional[datetime] = None


class TrackingPointInput(BaseModel):
    point_id: UUID
    recorded_at: datetime
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    accuracy_m: Optional[float] = Field(default=None, ge=0)
    speed_mps: Optional[float] = Field(default=None, ge=0)
    heading_deg: Optional[float] = Field(default=None, ge=0, le=360)
    altitude_m: Optional[float] = None
    provider: Optional[str] = Field(default=None, max_length=32)


class TrackingPointsBatchRequest(BaseModel):
    session_id: UUID
    client_batch_id: UUID
    sent_at: datetime
    points: list[TrackingPointInput] = Field(default_factory=list)


class TrackingPointsBatchResponse(BaseModel):
    trip_id: UUID
    session_id: UUID
    client_batch_id: UUID
    accepted_points: int
    duplicate_points: int
    ingest_job_id: UUID
    idempotency_replayed: bool


class TrackingEventInput(BaseModel):
    client_event_id: str = Field(..., min_length=1, max_length=128)
    event_type: str = Field(..., min_length=1, max_length=32)
    captured_at: Any
    session_id: Optional[str] = Field(default=None, max_length=128)
    note: Optional[str] = None
    location: Optional[dict[str, Any]] = None
    payload: Optional[dict[str, Any]] = None


class TrackingEventsBatchRequest(BaseModel):
    events: list[TrackingEventInput] = Field(default_factory=list, max_length=250)


class TrackingEventAcceptedResponse(BaseModel):
    client_event_id: str
    event_id: UUID
    duplicate: bool


class TrackingEventRejectedResponse(BaseModel):
    client_event_id: Optional[str] = None
    reason_code: str
    message: str


class TrackingEventsBatchResponse(BaseModel):
    trip_id: UUID
    accepted: list[TrackingEventAcceptedResponse]
    rejected: list[TrackingEventRejectedResponse]
    accepted_count: int
    rejected_count: int
    idempotency_replayed: bool


TrackingMediaBindMode = Literal["place", "route"]
TrackingMediaType = Literal["photo", "media"]


class TrackingMediaInput(BaseModel):
    client_media_id: str = Field(..., min_length=1, max_length=128)
    client_event_id: str = Field(..., min_length=1, max_length=128)
    media_type: TrackingMediaType
    bind_mode: TrackingMediaBindMode
    captured_at: Any
    trip_place_id: Optional[str] = Field(default=None, max_length=128)
    location: Optional[dict[str, Any]] = None
    upload_ref: str = Field(..., min_length=1, max_length=2048)
    mime_type: Optional[str] = Field(default=None, max_length=128)
    file_size_bytes: Optional[int] = Field(default=None, ge=0)
    payload: Optional[dict[str, Any]] = None


class TrackingMediaBatchRequest(BaseModel):
    media: list[TrackingMediaInput] = Field(default_factory=list, max_length=100)


class TrackingMediaAcceptedResponse(BaseModel):
    client_media_id: str
    media_id: UUID
    duplicate: bool


class TrackingMediaRejectedResponse(BaseModel):
    client_media_id: Optional[str] = None
    reason_code: str
    message: str


class TrackingMediaBatchResponse(BaseModel):
    trip_id: UUID
    accepted: list[TrackingMediaAcceptedResponse]
    rejected: list[TrackingMediaRejectedResponse]
    accepted_count: int
    rejected_count: int
    idempotency_replayed: bool


class TrackingMediaUploadResponse(BaseModel):
    trip_id: UUID
    upload_ref: str
    mime_type: Optional[str] = None
    file_size_bytes: int


class TrackingPathPointResponse(BaseModel):
    recorded_at: datetime
    latitude: float
    longitude: float
    accuracy_m: Optional[float] = None
    speed_mps: Optional[float] = None


class TrackingPathResponse(BaseModel):
    trip_id: UUID
    session_id: UUID
    points_count: int
    points: list[TrackingPathPointResponse]


class CheckinCandidateResponse(BaseModel):
    id: UUID
    trip_id: UUID
    user_id: UUID
    session_id: Optional[UUID] = None
    fingerprint: str
    status: CheckinStatus
    confidence: float
    suggested_name: Optional[str] = None
    suggested_latitude: Optional[float] = None
    suggested_longitude: Optional[float] = None
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    confirmed_trip_place_id: Optional[UUID] = None
    rejected_reason: Optional[str] = None
    snoozed_until: Optional[datetime] = None
    cooldown_until: Optional[datetime] = None
    payload: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PendingCheckinsResponse(BaseModel):
    candidates: list[CheckinCandidateResponse]
    total: int


class CheckinPlaceOverride(BaseModel):
    trip_place_id: Optional[UUID] = None
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    latitude: Optional[float] = Field(default=None, ge=-90, le=90)
    longitude: Optional[float] = Field(default=None, ge=-180, le=180)


class CheckinConfirmRequest(BaseModel):
    client_event_id: UUID
    confirmed_at: datetime
    place_override: Optional[CheckinPlaceOverride] = None


class CheckinRejectRequest(BaseModel):
    client_event_id: UUID
    rejected_at: datetime
    reason: Optional[str] = Field(default=None, max_length=255)


class CheckinSnoozeRequest(BaseModel):
    client_event_id: UUID
    snoozed_until: datetime


class CheckinActionResponse(BaseModel):
    candidate: CheckinCandidateResponse
    idempotency_replayed: bool


class MomentLocation(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class MomentCreateRequest(BaseModel):
    client_event_id: UUID
    captured_at: datetime
    note: Optional[str] = None
    location: Optional[MomentLocation] = None
    media_refs: list[dict[str, Any]] = Field(default_factory=list)
    linked_trip_place_id: Optional[UUID] = None
    extra_payload: dict[str, Any] = Field(default_factory=dict)


class MomentUpdateRequest(BaseModel):
    client_event_id: UUID
    captured_at: Optional[datetime] = None
    note: Optional[str] = None
    location: Optional[MomentLocation] = None
    media_refs: Optional[list[dict[str, Any]]] = None
    linked_trip_place_id: Optional[UUID] = None
    extra_payload: Optional[dict[str, Any]] = None


class MomentResponse(BaseModel):
    id: UUID
    trip_id: UUID
    user_id: UUID
    candidate_id: Optional[UUID] = None
    linked_trip_place_id: Optional[UUID] = None
    source: Literal["manual", "auto", "edited_auto"]
    confidence: Optional[float] = None
    captured_at: datetime
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    note: Optional[str] = None
    media_refs: list[dict[str, Any]] = Field(default_factory=list)
    extra_payload: dict[str, Any] = Field(default_factory=dict)
    locked_fields: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MomentListResponse(BaseModel):
    moments: list[MomentResponse]
    total: int


class AutoFinalizeCommitRequest(BaseModel):
    client_event_id: UUID
    committed_at: datetime


class AutoFinalizeCommitResponse(BaseModel):
    trip_id: UUID
    status: TripTrackingStatus
    tracking_enabled: bool
    tracking_started_at: Optional[datetime] = None
    tracking_ended_at: Optional[datetime] = None
    idempotency_replayed: bool


class DeviceTokenRegisterRequest(BaseModel):
    client_event_id: UUID
    platform: DevicePlatform
    push_token: str = Field(..., min_length=8, max_length=512)
    device_id: Optional[str] = Field(default=None, max_length=128)
    app_version: Optional[str] = Field(default=None, max_length=32)
    locale: Optional[str] = Field(default=None, max_length=32)
    seen_at: datetime


class DeviceTokenDeactivateRequest(BaseModel):
    client_event_id: UUID
    push_token: str = Field(..., min_length=8, max_length=512)
    deactivated_at: datetime


class DeviceTokenResponse(BaseModel):
    id: UUID
    user_id: UUID
    platform: DevicePlatform
    device_id: Optional[str] = None
    app_version: Optional[str] = None
    locale: Optional[str] = None
    token_hint: Optional[str] = None
    is_active: bool
    failure_count: int
    last_seen_at: datetime
    last_sent_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime


class DeviceTokenActionResponse(BaseModel):
    token: DeviceTokenResponse
    idempotency_replayed: bool
