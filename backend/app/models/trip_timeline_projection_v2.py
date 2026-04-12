"""
V2 derived timeline projection entries.
"""

import uuid

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripTimelineProjectionV2(Base):
    """Derived timeline projection entry for remote V2 reads."""

    __tablename__ = "trip_timeline_projection_v2"

    projection_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
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
    entry_id = Column(String(160), nullable=False)
    entry_kind = Column(String(32), nullable=False)
    source_server_id = Column(UUID(as_uuid=True), nullable=False)
    captured_at = Column(DateTime(timezone=True), nullable=False)
    bucket_type = Column(String(32), nullable=False)
    place_bind_name = Column(String(255), nullable=True)
    place_bind_id = Column(String(128), nullable=True)
    decision_source = Column(String(64), nullable=True)
    manual_lock = Column(Boolean, nullable=False, default=False)
    anchor_latitude = Column(Float, nullable=False)
    anchor_longitude = Column(Float, nullable=False)
    route_segment_key = Column(String(128), nullable=True)
    route_distance_m = Column(Float, nullable=True)
    title = Column(Text, nullable=False)
    subtitle = Column(Text, nullable=True)
    render_payload_json = Column(JSONB, nullable=True)
    compiler_version = Column(Integer, nullable=False, default=1)
    compiled_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "trip_server_id",
            "entry_id",
            name="uq_trip_timeline_projection_v2_trip_entry",
        ),
        Index("idx_trip_timeline_projection_v2_trip_captured_entry", "trip_server_id", "captured_at", "entry_id"),
        Index("idx_trip_timeline_projection_v2_trip_bucket_captured", "trip_server_id", "bucket_type", "captured_at"),
    )
