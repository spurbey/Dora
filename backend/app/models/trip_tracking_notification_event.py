"""
Append-only notification event history for live-tracking auditability.
"""

import uuid

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripTrackingNotificationEvent(Base):
    """Immutable per-transition event for candidate notification channels."""

    __tablename__ = "trip_tracking_notification_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Notification event row ID")
    notification_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_tracking_notifications.id", ondelete="CASCADE"),
        nullable=False,
        comment="Parent notification snapshot row",
    )
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
        ForeignKey("trip_checkin_candidates.id", ondelete="CASCADE"),
        nullable=False,
        comment="Linked check-in candidate ID",
    )
    channel = Column(
        String(16),
        nullable=False,
        comment="inbox|push",
    )
    event_type = Column(
        String(24),
        nullable=False,
        comment="handoff|dispatch|action",
    )
    delivery_state = Column(
        String(32),
        nullable=False,
        comment="Snapshot state at this event transition",
    )
    attempt_count = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Attempt count at this event transition",
    )
    last_error = Column(
        Text,
        nullable=True,
        comment="Error snapshot at this event transition",
    )
    payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Transition payload snapshot",
    )
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Transition timestamp",
    )

    __table_args__ = (
        CheckConstraint(
            "channel IN ('inbox', 'push')",
            name="check_tracking_notification_events_channel",
        ),
        CheckConstraint(
            "event_type IN ('handoff', 'dispatch', 'action')",
            name="check_tracking_notification_events_event_type",
        ),
        CheckConstraint(
            "attempt_count >= 0",
            name="check_tracking_notification_events_attempt_count",
        ),
        Index("idx_tracking_notification_events_notification_created", "notification_id", "created_at"),
        Index("idx_tracking_notification_events_user_created", "user_id", "created_at"),
        Index("idx_tracking_notification_events_candidate_created", "candidate_id", "created_at"),
    )

