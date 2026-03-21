"""
Tombstones for deleted auto-generated entities.

Prevents immediate regeneration of deleted inferred places/routes.
"""

import uuid

from sqlalchemy import Column, String, DateTime, ForeignKey, Index, UniqueConstraint, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class TripAutoEntityTombstone(Base):
    """Cooldown tombstone for auto-generated entity suppression."""

    __tablename__ = "trip_auto_entity_tombstones"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Tombstone ID")
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Trip ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    entity_type = Column(
        String(32),
        nullable=False,
        comment="place|route|moment_link",
    )
    entity_fingerprint = Column(
        String(128),
        nullable=False,
        comment="Fingerprint used to suppress regeneration",
    )
    deleted_entity_id = Column(UUID(as_uuid=True), nullable=True, comment="Original entity ID if available")
    cooldown_expires_at = Column(DateTime(timezone=True), nullable=False, comment="Suppression expiry")
    reason = Column(String(128), nullable=True, comment="Deletion reason")
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "trip_id",
            "user_id",
            "entity_type",
            "entity_fingerprint",
            name="uq_tombstone_trip_user_type_fp",
        ),
        CheckConstraint(
            "entity_type IN ('place', 'route', 'moment_link')",
            name="check_tombstone_entity_type",
        ),
        Index("idx_tombstones_trip_cooldown", "trip_id", "cooldown_expires_at"),
    )
