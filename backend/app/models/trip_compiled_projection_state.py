"""
Compiled projection state per trip.

Tracks whether projection artifacts need recompilation and stores
lightweight drift counters for observability.
"""

import uuid

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.database import Base


class TripCompiledProjectionState(Base):
    """Compiler state row keyed by trip."""

    __tablename__ = "trip_compiled_projection_state"

    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        primary_key=True,
        comment="Trip ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Owner user ID",
    )
    compiler_version = Column(
        Integer,
        nullable=False,
        default=1,
        comment="Projection compiler contract version",
    )
    dirty = Column(
        Boolean,
        nullable=False,
        default=True,
        comment="True when projection should be recomputed",
    )
    stale = Column(
        Boolean,
        nullable=False,
        default=False,
        comment="True when latest compile attempt failed and last good snapshot is served",
    )
    raw_event_count = Column(Integer, nullable=False, default=0)
    compiled_event_count = Column(Integer, nullable=False, default=0)
    raw_point_count = Column(Integer, nullable=False, default=0)
    compiled_route_segment_count = Column(Integer, nullable=False, default=0)
    last_compiled_at = Column(DateTime(timezone=True), nullable=True)
    last_error = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

