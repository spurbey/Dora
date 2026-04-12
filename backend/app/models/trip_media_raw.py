"""
V2 canonical raw media storage.
"""

import uuid

from sqlalchemy import Column, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class TripMediaRaw(Base):
    """Canonical server-side media row for V2 tracking."""

    __tablename__ = "trip_media_raw"

    media_server_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_server_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    session_server_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_session_raw.session_server_id", ondelete="CASCADE"),
        nullable=False,
    )
    event_server_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_event_raw.event_server_id", ondelete="CASCADE"),
        nullable=False,
    )
    client_media_id = Column(String(128), nullable=False)
    captured_at = Column(DateTime(timezone=True), nullable=False)
    media_type = Column(String(32), nullable=False)
    storage_ref = Column(String(512), nullable=False)
    mime_type = Column(String(128), nullable=True)
    bytes_size = Column(Integer, nullable=True)
    width_px = Column(Integer, nullable=True)
    height_px = Column(Integer, nullable=True)
    duration_ms = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "trip_server_id",
            "client_media_id",
            name="uq_trip_media_raw_trip_client_media",
        ),
        Index("idx_trip_media_raw_trip_captured", "trip_server_id", "captured_at"),
        Index("idx_trip_media_raw_event", "event_server_id"),
    )
