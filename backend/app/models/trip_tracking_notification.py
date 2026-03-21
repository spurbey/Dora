"""
Trip tracking notification audit/inbox model.

Stores per-candidate notification state for push transport and inbox parity.
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
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripTrackingNotification(Base):
    """Notification audit and inbox delivery status for inferred candidates."""

    __tablename__ = "trip_tracking_notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Notification row ID")
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
    delivery_state = Column(
        String(32),
        nullable=False,
        default="pending",
        comment="pending|sent|retryable_failure|transport_unavailable|no_tokens|terminal_failure|acted",
    )
    attempt_count = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Total push attempts recorded for this channel/candidate",
    )
    last_error = Column(
        Text,
        nullable=True,
        comment="Latest error message (if any)",
    )
    payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Auxiliary metadata for delivery/inbox routing",
    )
    last_attempt_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Most recent push dispatch attempt time",
    )
    delivered_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When notification channel reached sent/delivered state",
    )
    acknowledged_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When user acted on the candidate in-app",
    )
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        UniqueConstraint(
            "candidate_id",
            "channel",
            name="uq_tracking_notifications_candidate_channel",
        ),
        CheckConstraint(
            "channel IN ('inbox', 'push')",
            name="check_tracking_notifications_channel",
        ),
        CheckConstraint(
            (
                "delivery_state IN ("
                "'pending',"
                "'sent',"
                "'retryable_failure',"
                "'transport_unavailable',"
                "'no_tokens',"
                "'terminal_failure',"
                "'acted'"
                ")"
            ),
            name="check_tracking_notifications_delivery_state",
        ),
        CheckConstraint(
            "attempt_count >= 0",
            name="check_tracking_notifications_attempt_count",
        ),
        Index("idx_tracking_notifications_user_created", "user_id", "created_at"),
        Index("idx_tracking_notifications_trip_created", "trip_id", "created_at"),
        Index("idx_tracking_notifications_channel_state", "channel", "delivery_state", "created_at"),
    )

