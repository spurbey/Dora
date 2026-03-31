"""
Compiled route segment artifacts for editor overlays.
"""

import uuid

from sqlalchemy import CheckConstraint, Column, DateTime, Float, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripCompiledRouteSegment(Base):
    """Route segment generated from tracking points."""

    __tablename__ = "trip_compiled_route_segments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    segment_key = Column(String(160), nullable=False, comment="Deterministic segment identity")
    session_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_tracking_sessions.id", ondelete="SET NULL"),
        nullable=True,
    )
    started_at = Column(DateTime(timezone=True), nullable=False)
    ended_at = Column(DateTime(timezone=True), nullable=False)
    distance_m = Column(Float, nullable=False, default=0.0)
    raw_point_count = Column(Integer, nullable=False, default=0)
    simplified_point_count = Column(Integer, nullable=False, default=0)
    geometry = Column(JSONB, nullable=False, default=dict, comment="GeoJSON-like route payload")
    compiler_version = Column(Integer, nullable=False, default=1)
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
            "segment_key",
            "compiler_version",
            name="uq_trip_compiled_route_segments_trip_key_version",
        ),
        CheckConstraint(
            "distance_m >= 0",
            name="check_compiled_route_segment_distance",
        ),
        CheckConstraint(
            "raw_point_count >= 0",
            name="check_compiled_route_segment_raw_points",
        ),
        CheckConstraint(
            "simplified_point_count >= 0",
            name="check_compiled_route_segment_simplified_points",
        ),
        Index("idx_compiled_route_segments_trip_start", "trip_id", "started_at"),
        Index("idx_compiled_route_segments_trip_session", "trip_id", "session_id"),
    )

