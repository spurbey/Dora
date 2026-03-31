"""
Manual projection override records.

Stores user-issued place bind/unbind choices so compiler reruns
preserve manual intent.
"""

import uuid

from sqlalchemy import CheckConstraint, Column, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class TripCompiledProjectionOverride(Base):
    """Manual bind override for a source projection artifact."""

    __tablename__ = "trip_compiled_projection_overrides"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    source_kind = Column(String(32), nullable=False, comment="tracking_event")
    source_id = Column(UUID(as_uuid=True), nullable=False)
    action = Column(String(16), nullable=False, comment="bind|unbind")
    trip_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
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
            "trip_id",
            "source_kind",
            "source_id",
            name="uq_trip_compiled_projection_overrides_source",
        ),
        CheckConstraint(
            "source_kind IN ('tracking_event')",
            name="check_compiled_projection_override_source_kind",
        ),
        CheckConstraint(
            "action IN ('bind', 'unbind')",
            name="check_compiled_projection_override_action",
        ),
    )

