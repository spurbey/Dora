"""
User device push token model.

Stores per-user push transport tokens used by live-tracking notifications.
"""

import uuid

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class UserDeviceToken(Base):
    """Push token registration per user/device/platform."""

    __tablename__ = "user_device_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Device token row ID")
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    platform = Column(
        String(16),
        nullable=False,
        comment="ios|android|web",
    )
    push_token = Column(
        String(512),
        nullable=False,
        comment="Platform push token (FCM/APNs)",
    )
    device_id = Column(
        String(128),
        nullable=True,
        comment="Client device identifier",
    )
    app_version = Column(
        String(32),
        nullable=True,
        comment="Client app version",
    )
    locale = Column(
        String(32),
        nullable=True,
        comment="Client locale",
    )
    is_active = Column(
        Boolean,
        nullable=False,
        default=True,
        comment="Whether token is active for dispatch",
    )
    last_seen_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Last token refresh/seen timestamp",
    )
    last_sent_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Last successful send timestamp",
    )
    failure_count = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Consecutive delivery failure count",
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
            "user_id",
            "push_token",
            name="uq_user_device_tokens_user_token",
        ),
        CheckConstraint(
            "platform IN ('ios', 'android', 'web')",
            name="check_user_device_tokens_platform",
        ),
        CheckConstraint(
            "failure_count >= 0",
            name="check_user_device_tokens_failure_count",
        ),
        Index("idx_user_device_tokens_user_active", "user_id", "is_active"),
        Index("idx_user_device_tokens_last_seen", "last_seen_at"),
    )
