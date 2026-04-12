"""
V2 finalize manifest and replay ledger.
"""

import uuid

from sqlalchemy import Column, DateTime, ForeignKey, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripCommitManifest(Base):
    """Session finalize manifest and replay checkpoint container."""

    __tablename__ = "trip_commit_manifest"

    manifest_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_server_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    session_server_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_session_raw.session_server_id", ondelete="CASCADE"),
        nullable=False,
    )
    client_session_id = Column(String(128), nullable=False)
    client_job_id = Column(String(128), nullable=False)
    session_commit_token = Column(String(128), nullable=False, unique=True)
    idempotency_key = Column(String(128), nullable=False)
    operation_kind = Column(String(32), nullable=False)
    status = Column(String(32), nullable=False)
    phase = Column(String(32), nullable=False)
    schema_version = Column(Integer, nullable=False)
    request_fingerprint = Column(String(128), nullable=False)
    response_fingerprint = Column(String(128), nullable=True)
    session_summary = Column(JSONB, nullable=False, default=dict)
    media_manifest = Column(JSONB, nullable=False, default=list)
    media_manifest_digest = Column(String(128), nullable=False)
    accepted_media_refs = Column(JSONB, nullable=False, default=dict)
    payload_chunks = Column(JSONB, nullable=False, default=dict)
    step_idempotency = Column(JSONB, nullable=False, default=dict)
    payload_total_bytes = Column(Integer, nullable=False, default=0)
    error_code = Column(String(64), nullable=True)
    error_message = Column(Text, nullable=True)
    raw_ingest_completed_at = Column(DateTime(timezone=True), nullable=True)
    projection_compiled_at = Column(DateTime(timezone=True), nullable=True)
    committed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "trip_server_id",
            "operation_kind",
            "idempotency_key",
            name="uq_trip_commit_manifest_trip_operation_key",
        ),
        Index("idx_trip_commit_manifest_trip_created", "trip_server_id", "created_at"),
        Index("idx_trip_commit_manifest_session_status", "session_server_id", "status"),
    )
