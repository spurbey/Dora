"""
Stories domain models.

MVP scope:
    - Published story rows (plus lifecycle states)
    - Per-user author mute records
    - Story reports for moderation intake
"""

from __future__ import annotations

import uuid

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


STORY_STATUSES = (
    "draft",
    "publishing",
    "published",
    "failed",
    "expired",
    "deleted",
    "moderation_hidden",
)


class Story(Base):
    __tablename__ = "stories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # Forever-idempotent key provided by client.
    client_story_id = Column(String(64), nullable=False, unique=True, index=True)
    author_user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    media_type = Column(String(16), nullable=False)
    media_url = Column(Text, nullable=True)
    thumbnail_url = Column(Text, nullable=True)
    duration_ms = Column(BigInteger, nullable=True)

    center_lat = Column(Float, nullable=False)
    center_lng = Column(Float, nullable=False)

    status = Column(String(32), nullable=False, default="draft", index=True)
    published_at = Column(DateTime(timezone=True), nullable=True, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=True, index=True)
    deleted_at = Column(DateTime(timezone=True), nullable=True, index=True)

    view_count = Column(BigInteger, nullable=False, default=0)

    last_error_code = Column(String(64), nullable=True)
    last_error_message = Column(Text, nullable=True)

    storage_object_path = Column(Text, nullable=True)
    thumbnail_object_path = Column(Text, nullable=True)
    media_purged_at = Column(DateTime(timezone=True), nullable=True)
    thumbnail_purged_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    __table_args__ = (
        CheckConstraint("media_type IN ('photo', 'video')", name="ck_stories_media_type"),
        CheckConstraint(
            "status IN ('draft', 'publishing', 'published', 'failed', 'expired', 'deleted', 'moderation_hidden')",
            name="ck_stories_status",
        ),
        Index("idx_stories_author_status_published", "author_user_id", "status", "published_at"),
        Index("idx_stories_active_window", "status", "published_at", "expires_at"),
    )

    def __repr__(self) -> str:
        return f"<Story(id={self.id}, author={self.author_user_id}, status={self.status})>"


class StoryAuthorMute(Base):
    __tablename__ = "story_author_mutes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    muted_author_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "muted_author_id", name="uq_story_author_mutes_user_author"),
    )

    def __repr__(self) -> str:
        return f"<StoryAuthorMute(user={self.user_id}, muted={self.muted_author_id})>"


class StoryReport(Base):
    __tablename__ = "story_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    story_id = Column(
        UUID(as_uuid=True),
        ForeignKey("stories.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    reporter_user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    reason = Column(String(64), nullable=False)
    details = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    __table_args__ = (
        Index("idx_story_reports_story_created", "story_id", "created_at"),
    )

    def __repr__(self) -> str:
        return f"<StoryReport(story={self.story_id}, reporter={self.reporter_user_id})>"
