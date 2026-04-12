"""
V2 canonical raw session storage.
"""

import uuid

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripSessionRaw(Base):
    """Canonical server-side session row for V2 tracking."""

    __tablename__ = "trip_session_raw"

    session_server_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
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
    client_session_id = Column(String(128), nullable=False)
    timezone = Column(String(64), nullable=True)
    device_id = Column(String(128), nullable=True)
    device_context = Column(JSONB, nullable=False, default=dict)
    started_at = Column(DateTime(timezone=True), nullable=False)
    ended_at = Column(DateTime(timezone=True), nullable=True)
    status = Column(String(32), nullable=False, default="active")
    commit_token = Column(String(128), nullable=True)
    stop_client_event_id = Column(String(128), nullable=True)
    seal_version = Column(Integer, nullable=False, default=0)
    stop_server_pending = Column(Boolean, nullable=False, default=False)
    stop_reason = Column(String(128), nullable=True)
    schema_version = Column(Integer, nullable=True)
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
            "client_session_id",
            name="uq_trip_session_raw_trip_client_session",
        ),
        Index("idx_trip_session_raw_trip_started", "trip_server_id", "started_at"),
        Index("idx_trip_session_raw_trip_status", "trip_server_id", "status"),
    )
