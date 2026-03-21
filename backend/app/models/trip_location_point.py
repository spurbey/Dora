"""
Raw trip tracking points.

Stores deduplicated location observations captured during a tracking session.
"""

import uuid

from sqlalchemy import (
    Column,
    String,
    Float,
    DateTime,
    ForeignKey,
    CheckConstraint,
    Index,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class TripLocationPoint(Base):
    """Raw ingested GPS point for a tracking session."""

    __tablename__ = "trip_location_points"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Row ID")
    session_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_tracking_sessions.id", ondelete="CASCADE"),
        nullable=False,
        comment="Tracking session ID",
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Trip ID for query convenience",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )

    client_batch_id = Column(UUID(as_uuid=True), nullable=False, comment="Client batch identifier")
    point_id = Column(UUID(as_uuid=True), nullable=False, comment="Client point identifier")
    recorded_at = Column(DateTime(timezone=True), nullable=False, comment="Device timestamp for point")

    latitude = Column(Float, nullable=False, comment="WGS84 latitude")
    longitude = Column(Float, nullable=False, comment="WGS84 longitude")
    accuracy_m = Column(Float, comment="Horizontal accuracy in meters")
    speed_mps = Column(Float, comment="Speed in m/s")
    heading_deg = Column(Float, comment="Heading in degrees")
    altitude_m = Column(Float, comment="Altitude in meters")
    provider = Column(String(32), comment="gps|network|fused|unknown")

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint("session_id", "point_id", name="uq_tracking_point_session_point"),
        CheckConstraint("latitude >= -90 AND latitude <= 90", name="check_tracking_point_latitude"),
        CheckConstraint("longitude >= -180 AND longitude <= 180", name="check_tracking_point_longitude"),
        CheckConstraint("accuracy_m IS NULL OR accuracy_m >= 0", name="check_tracking_point_accuracy"),
        CheckConstraint("speed_mps IS NULL OR speed_mps >= 0", name="check_tracking_point_speed"),
        CheckConstraint(
            "heading_deg IS NULL OR (heading_deg >= 0 AND heading_deg <= 360)",
            name="check_tracking_point_heading",
        ),
        Index("idx_tracking_points_trip_time", "trip_id", "recorded_at"),
        Index("idx_tracking_points_session_time", "session_id", "recorded_at"),
    )
