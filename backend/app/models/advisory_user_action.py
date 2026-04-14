"""
AdvisoryUserAction model — append-only log of user engagement with advisories.

Separate from TripAdvisory.status (which tracks delivery lifecycle only).
This table stores all user reactions for preference learning and
cross-user recommendation scoring.
"""

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    String,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class AdvisoryUserAction(Base):
    __tablename__ = "advisory_user_actions"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    advisory_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_advisories.id", ondelete="CASCADE"),
        nullable=False,
    )

    action = Column(
        String(32),
        nullable=False,
        comment="dismissed|liked|saved|acted_on|converted_to_place",
    )
    action_metadata = Column(
        JSONB,
        nullable=True,
        comment="Extra context, e.g. which place the user saved it to",
    )
    trip_metadata_snapshot = Column(
        JSONB,
        nullable=False,
        comment="Snapshot of TripMetadata at action time for similarity matching",
    )

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    __table_args__ = (
        CheckConstraint(
            "action IN ('dismissed', 'liked', 'saved', 'acted_on', 'converted_to_place')",
            name="check_advisory_action_type",
        ),
        Index("idx_advisory_action_user", "user_id", "action"),
        Index("idx_advisory_action_advisory", "advisory_id"),
        Index("idx_advisory_action_trip", "trip_id"),
    )

    def __repr__(self) -> str:
        return f"<AdvisoryUserAction(id={self.id}, action={self.action})>"
