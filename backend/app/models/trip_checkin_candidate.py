"""
Check-in candidate model.

Represents inferred candidate stays requiring user confirmation.
"""

import uuid

from sqlalchemy import Column, String, Text, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func

from app.database import Base


class TripCheckinCandidate(Base):
    """Inferred candidate check-in with confirmation lifecycle."""

    __tablename__ = "trip_checkin_candidates"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Candidate ID")
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
        comment="Origin session ID",
    )

    fingerprint = Column(String(128), nullable=False, comment="Dedup fingerprint")
    status = Column(
        String(20),
        nullable=False,
        default="pending",
        comment="pending|confirmed|rejected|snoozed|expired",
    )
    confidence = Column(Float, nullable=False, comment="0..1 confidence score")

    suggested_name = Column(Text, comment="Suggested place name")
    suggested_latitude = Column(Float, comment="Suggested latitude")
    suggested_longitude = Column(Float, comment="Suggested longitude")
    started_at = Column(DateTime(timezone=True), comment="Inferred stay start time")
    ended_at = Column(DateTime(timezone=True), comment="Inferred stay end time")

    confirmed_trip_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
        comment="Chosen place after user confirmation",
    )
    rejected_reason = Column(Text)
    snoozed_until = Column(DateTime(timezone=True))
    cooldown_until = Column(DateTime(timezone=True))
    payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Candidate feature payload used by scoring/inference",
    )

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('pending', 'confirmed', 'rejected', 'snoozed', 'expired')",
            name="check_checkin_candidate_status",
        ),
        CheckConstraint(
            "confidence >= 0 AND confidence <= 1",
            name="check_checkin_candidate_confidence",
        ),
        CheckConstraint(
            "suggested_latitude IS NULL OR (suggested_latitude >= -90 AND suggested_latitude <= 90)",
            name="check_checkin_candidate_latitude",
        ),
        CheckConstraint(
            "suggested_longitude IS NULL OR (suggested_longitude >= -180 AND suggested_longitude <= 180)",
            name="check_checkin_candidate_longitude",
        ),
    )
