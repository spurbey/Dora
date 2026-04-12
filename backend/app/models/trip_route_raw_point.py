"""
V2 canonical raw route point storage.
"""

import uuid

from sqlalchemy import Column, DateTime, Float, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID

from app.database import Base


class TripRouteRawPoint(Base):
    """Canonical server-side route point row for V2 tracking."""

    __tablename__ = "trip_route_raw_point"

    point_server_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
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
    client_point_id = Column(String(128), nullable=True)
    captured_at = Column(DateTime(timezone=True), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    accuracy_m = Column(Float, nullable=True)
    speed_mps = Column(Float, nullable=True)
    bearing_deg = Column(Float, nullable=True)
    altitude_m = Column(Float, nullable=True)
    source = Column(String(32), nullable=True)
    point_seq = Column(Integer, nullable=False)

    __table_args__ = (
        UniqueConstraint(
            "session_server_id",
            "point_seq",
            name="uq_trip_route_raw_point_session_seq",
        ),
        Index("idx_trip_route_raw_point_trip_captured", "trip_server_id", "captured_at"),
        Index("idx_trip_route_raw_point_session_seq", "session_server_id", "point_seq"),
    )
