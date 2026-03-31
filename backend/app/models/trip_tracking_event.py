"""
Trip tracking event model.

Stores local-first capture artifacts synced from mobile runtime:
note, warn, tag, photo, media markers.
"""

import uuid

from sqlalchemy import CheckConstraint, Column, DateTime, Float, ForeignKey, Index, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripTrackingEvent(Base):
    """Live-capture event persisted per trip/session."""

    __tablename__ = "trip_tracking_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Tracking event ID")
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Parent trip ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    session_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_tracking_sessions.id", ondelete="SET NULL"),
        nullable=True,
        comment="Optional tracking session ID",
    )
    client_event_id = Column(
        UUID(as_uuid=True),
        nullable=False,
        comment="Client-generated idempotent event identity",
    )
    event_type = Column(
        String(32),
        nullable=False,
        comment="note|warn|tag|photo|media",
    )
    captured_at = Column(DateTime(timezone=True), nullable=False, comment="Original capture timestamp")
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    note = Column(Text, nullable=True)
    payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Type-specific metadata payload",
    )

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "trip_id",
            "user_id",
            "client_event_id",
            name="uq_tracking_event_trip_user_client_event",
        ),
        CheckConstraint(
            "event_type IN ('note', 'warn', 'tag', 'photo', 'media')",
            name="check_trip_tracking_event_type",
        ),
        CheckConstraint(
            "latitude IS NULL OR (latitude >= -90 AND latitude <= 90)",
            name="check_trip_tracking_event_latitude",
        ),
        CheckConstraint(
            "longitude IS NULL OR (longitude >= -180 AND longitude <= 180)",
            name="check_trip_tracking_event_longitude",
        ),
        Index("idx_trip_tracking_events_trip_captured_at", "trip_id", "captured_at"),
        Index("idx_trip_tracking_events_user_captured_at", "user_id", "captured_at"),
        Index("idx_trip_tracking_events_session_captured_at", "session_id", "captured_at"),
        Index("idx_trip_tracking_events_type_captured_at", "event_type", "captured_at"),
    )
