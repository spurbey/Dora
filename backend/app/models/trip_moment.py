"""
Trip moment model.

Stores user or system created moments that can later be linked to places.
"""

import uuid

from sqlalchemy import Column, String, Text, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func

from app.database import Base


class TripMoment(Base):
    """Moment captured during tracking or manual editing."""

    __tablename__ = "trip_moments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Moment ID")
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
    candidate_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_checkin_candidates.id", ondelete="SET NULL"),
        nullable=True,
        comment="Origin candidate ID for auto moments",
    )
    linked_trip_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
        comment="Linked place ID",
    )

    source = Column(
        String(20),
        nullable=False,
        default="manual",
        comment="manual|auto|edited_auto",
    )
    confidence = Column(Float, comment="Inference confidence for auto moments")
    captured_at = Column(DateTime(timezone=True), nullable=False, comment="Original capture timestamp")

    latitude = Column(Float)
    longitude = Column(Float)
    note = Column(Text)
    media_refs = Column(
        JSONB,
        nullable=False,
        default=list,
        comment="List of related media references",
    )
    extra_payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Additional metadata payload for inference/debug",
    )
    locked_fields = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Manual lock markers for auto-updatable fields",
    )

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        CheckConstraint("source IN ('manual', 'auto', 'edited_auto')", name="check_trip_moment_source"),
        CheckConstraint(
            "confidence IS NULL OR (confidence >= 0 AND confidence <= 1)",
            name="check_trip_moment_confidence",
        ),
        CheckConstraint(
            "latitude IS NULL OR (latitude >= -90 AND latitude <= 90)",
            name="check_trip_moment_latitude",
        ),
        CheckConstraint(
            "longitude IS NULL OR (longitude >= -180 AND longitude <= 180)",
            name="check_trip_moment_longitude",
        ),
    )
