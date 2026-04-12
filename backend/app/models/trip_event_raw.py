"""
V2 canonical raw event storage.
"""

import uuid

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripEventRaw(Base):
    """Canonical server-side event row for V2 tracking."""

    __tablename__ = "trip_event_raw"

    event_server_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
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
    client_event_id = Column(String(128), nullable=False)
    event_type = Column(String(32), nullable=False)
    captured_at = Column(DateTime(timezone=True), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    resolver_state = Column(String(32), nullable=False)
    decision_source = Column(String(64), nullable=True)
    manual_lock = Column(Boolean, nullable=False, default=False)
    place_bind_kind = Column(String(32), nullable=True)
    place_bind_id = Column(String(128), nullable=True)
    place_bind_name = Column(String(255), nullable=True)
    geotag_final_reason = Column(String(64), nullable=True)
    payload_json = Column(JSONB, nullable=True)
    event_seq = Column(Integer, nullable=True)
    captured_while_paused = Column(Boolean, nullable=False, default=False)
    candidate_set_version = Column(Integer, nullable=False, default=0)
    resolved_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "trip_server_id",
            "client_event_id",
            name="uq_trip_event_raw_trip_client_event",
        ),
        Index("idx_trip_event_raw_trip_captured", "trip_server_id", "captured_at"),
        Index(
            "idx_trip_event_raw_trip_resolver_captured",
            "trip_server_id",
            "resolver_state",
            "captured_at",
        ),
    )
