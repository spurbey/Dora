"""
Legacy trip tracking session model.

This table is still referenced by several V1/V1.5 models (routes, tracking
events, location points). Keep this model registered so SQLAlchemy can resolve
foreign keys during mapper flush ordering.
"""

import uuid

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    String,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripTrackingSession(Base):
    """Live-tracking session row used by legacy tracking and route inference."""

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
        comment="Client session identifier",
    )
    state = Column(
        String(20),
        nullable=False,
        server_default="active",
        comment="active|paused|ended|abandoned",
    )
    started_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    paused_at = Column(DateTime(timezone=True), nullable=True)
    resumed_at = Column(DateTime(timezone=True), nullable=True)
    ended_at = Column(DateTime(timezone=True), nullable=True)
    abandoned_at = Column(DateTime(timezone=True), nullable=True)
    last_point_at = Column(DateTime(timezone=True), nullable=True)
    timezone = Column(String(64), nullable=True)
    device_context = Column(
        JSONB,
        nullable=False,
        default=dict,
        server_default=text("'{}'::jsonb"),
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
        Index("idx_tracking_sessions_trip_state", "trip_id", "state"),
        Index("idx_tracking_sessions_user_state", "user_id", "state"),
    )
