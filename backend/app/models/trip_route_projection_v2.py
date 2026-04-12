"""
V2 derived route projection segments.
"""

import uuid

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripRouteProjectionV2(Base):
    """Derived route projection segment for remote V2 reads."""

    __tablename__ = "trip_route_projection_v2"

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
    segment_key = Column(String(128), nullable=False)
    segment_index = Column(Integer, nullable=False, default=0)
    started_at = Column(DateTime(timezone=True), nullable=False)
    ended_at = Column(DateTime(timezone=True), nullable=False)
    point_count = Column(Integer, nullable=False, default=0)
    raw_point_count = Column(Integer, nullable=False, default=0)
    geometry_json = Column(JSONB, nullable=False, default=dict)
    is_simplified = Column(Boolean, nullable=False, default=False)
    compiler_version = Column(Integer, nullable=False, default=1)
    compiled_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "trip_server_id",
            "segment_key",
            name="uq_trip_route_projection_v2_trip_segment",
        ),
        Index("idx_trip_route_projection_v2_trip_segment_index", "trip_server_id", "segment_index"),
        Index("idx_trip_route_projection_v2_trip_session", "trip_server_id", "session_server_id"),
    )
