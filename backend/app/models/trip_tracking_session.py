"""
Live-tracking session model.

Represents tracking lifecycle for a specific user-trip pair.
"""

import uuid

from sqlalchemy import Column, String, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func

from app.database import Base


class TripTrackingSession(Base):
    """Tracking session state container for live trip capture."""

    __tablename__ = "trip_tracking_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Session ID")
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Tracked trip ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )

    client_session_id = Column(
        String(64),
        nullable=False,
        comment="Client-generated stable session identifier",
    )
    state = Column(
        String(20),
        nullable=False,
        default="active",
        comment="active|paused|ended|abandoned",
    )

    started_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    paused_at = Column(DateTime(timezone=True))
    resumed_at = Column(DateTime(timezone=True))
    ended_at = Column(DateTime(timezone=True))
    abandoned_at = Column(DateTime(timezone=True))
    last_point_at = Column(DateTime(timezone=True), comment="Latest ingested point timestamp")

    timezone = Column(String(64), comment="IANA timezone")
    device_context = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Device context metadata for diagnostics and policy",
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
            "state IN ('active', 'paused', 'ended', 'abandoned')",
            name="check_tracking_session_state",
        ),
    )
