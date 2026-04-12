"""
Pydantic schemas for strict V2 ingest and projection APIs.
"""

from datetime import datetime
from typing import Any, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, Field


ManifestStatus = Literal[
    "started",
    "failed_retryable",
    "failed_terminal",
    "idempotency_conflict",
    "committed",
]
ManifestPhase = Literal[
    "start_received",
    "media_verified",
    "chunks_complete",
    "raw_ingest_completed",
    "projection_compiled",
    "finalized",
]


class V2SessionStartRequest(BaseModel):
    client_session_id: str = Field(..., min_length=1, max_length=128)
    started_at: datetime
    timezone: Optional[str] = Field(default=None, max_length=64)
    device_context: dict[str, Any] = Field(default_factory=dict)


class V2SessionStopRequest(BaseModel):
    seal_version: int = Field(..., ge=1)
    stop_client_event_id: str = Field(..., min_length=1, max_length=128)
    stopped_at: datetime
    reason: Optional[str] = Field(default=None, max_length=128)
    client_session_id: Optional[str] = Field(default=None, min_length=1, max_length=128)


class V2SessionResponse(BaseModel):
    session_server_id: UUID
    trip_id: UUID
    client_session_id: str
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    stop_server_pending: bool
    stop_client_event_id: Optional[str] = None
    seal_version: int
    timezone: Optional[str] = None
    commit_token: Optional[str] = None


class V2SessionSummary(BaseModel):
    snapshot_hash: str = Field(..., min_length=1, max_length=128)
    event_count: int = Field(..., ge=0)
    media_count: int = Field(..., ge=0)
    point_count: int = Field(..., ge=0)
    payload_bytes: int = Field(..., ge=0)
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None


class V2MediaManifestItem(BaseModel):
    client_media_id: str = Field(..., min_length=1, max_length=128)
    mime_type: Optional[str] = Field(default=None, max_length=128)
    size_bytes: Optional[int] = Field(default=None, ge=0)
    media_content_hash: str = Field(..., min_length=1, max_length=128)


class V2FinalizeStartRequest(BaseModel):
    client_job_id: str = Field(..., min_length=1, max_length=128)
    schema_version: int = Field(..., ge=1)
    session_summary: V2SessionSummary
    media_manifest: list[V2MediaManifestItem] = Field(default_factory=list)
    media_manifest_digest: str = Field(..., min_length=1, max_length=128)


class V2UploadTarget(BaseModel):
    client_media_id: str
    storage_provider: str
    storage_ref: str
    bucket: str
    object_key: str


class V2FinalizeStartResponse(BaseModel):
    session_commit_token: str
    manifest_status: ManifestStatus
    manifest_phase: ManifestPhase
    accepted_media_count: int
    upload_targets: list[V2UploadTarget] = Field(default_factory=list)


class V2UploadedMediaRef(BaseModel):
    client_media_id: str = Field(..., min_length=1, max_length=128)
    storage_ref: str = Field(..., min_length=1, max_length=512)


class V2FinalizeMediaCompleteRequest(BaseModel):
    session_commit_token: str = Field(..., min_length=1, max_length=128)
    uploaded_media: list[V2UploadedMediaRef] = Field(default_factory=list)


class V2FinalizeMediaCompleteResponse(BaseModel):
    session_commit_token: str
    manifest_status: ManifestStatus
    manifest_phase: ManifestPhase
    accepted_media_count: int


class V2PayloadChunkRequest(BaseModel):
    session_commit_token: str = Field(..., min_length=1, max_length=128)
    chunk_index: int = Field(..., ge=0)
    total_chunks: int = Field(..., ge=1)
    chunk_content_hash: str = Field(..., min_length=1, max_length=128)
    chunk_json: str = Field(..., min_length=1)


class V2PayloadChunkResponse(BaseModel):
    session_commit_token: str
    manifest_status: ManifestStatus
    manifest_phase: ManifestPhase
    chunk_index: int
    total_chunks: int
    accepted_total_bytes: int


class V2FinalizeCommitRequest(BaseModel):
    session_commit_token: str = Field(..., min_length=1, max_length=128)
    schema_version: int = Field(..., ge=1)


class V2FinalizeCommitResponse(BaseModel):
    session_commit_token: str
    manifest_status: ManifestStatus
    manifest_phase: ManifestPhase
    session_server_id: UUID
    accepted_event_count: int
    accepted_media_count: int
    accepted_point_count: int
    compiled_at: datetime


class V2TimelineEntryResponse(BaseModel):
    entry_id: str
    entry_kind: str
    source_server_id: UUID
    captured_at: datetime
    bucket_type: str
    place_bind_name: Optional[str] = None
    place_bind_id: Optional[str] = None
    decision_source: Optional[str] = None
    manual_lock: bool
    anchor_latitude: float
    anchor_longitude: float
    route_segment_key: Optional[str] = None
    route_distance_m: Optional[float] = None
    title: str
    subtitle: Optional[str] = None
    render_payload_json: Optional[dict[str, Any]] = None


class V2TimelineResponse(BaseModel):
    entries: list[V2TimelineEntryResponse] = Field(default_factory=list)
    next_cursor: Optional[str] = None
    has_more: bool
    compiled_at: Optional[datetime] = None
    compiler_version: int


class V2RoutePointResponse(BaseModel):
    latitude: float
    longitude: float
    captured_at: Optional[datetime] = None


class V2RouteSegmentResponse(BaseModel):
    segment_key: str
    session_server_id: UUID
    started_at: datetime
    ended_at: datetime
    point_count: int
    raw_point_count: int
    is_simplified: bool
    points: list[V2RoutePointResponse] = Field(default_factory=list)


class V2RouteResponse(BaseModel):
    segments: list[V2RouteSegmentResponse] = Field(default_factory=list)
    has_more: bool
    next_cursor: Optional[str] = None
    compiled_at: Optional[datetime] = None
    compiler_version: int
