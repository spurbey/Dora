"""
Compiled timeline projection entries.
"""

import uuid

from sqlalchemy import CheckConstraint, Column, Date, DateTime, Float, ForeignKey, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class TripCompiledProjectionItem(Base):
    """Editor-friendly timeline projection entry generated from source artifacts."""

    __tablename__ = "trip_compiled_projection_items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    entry_id = Column(String(160), nullable=False, comment="Deterministic projection entry identity")
    source_kind = Column(String(32), nullable=False, comment="tracking_event|tracking_event_media")
    source_id = Column(UUID(as_uuid=True), nullable=False, comment="Source row UUID")
    event_type = Column(String(32), nullable=False, comment="note|warn|tag|photo|media")
    captured_at = Column(DateTime(timezone=True), nullable=False)
    day_key = Column(Date, nullable=False)
    bucket_type = Column(String(32), nullable=False, comment="place|on_route")
    place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
    )
    place_name = Column(String(255), nullable=True)
    bind_source = Column(String(16), nullable=False, default="none", comment="auto|manual|none")
    bind_confidence = Column(Float, nullable=True)
    reason_code = Column(String(64), nullable=True)
    title = Column(String(255), nullable=False)
    subtitle = Column(Text, nullable=True)
    payload = Column(JSONB, nullable=False, default=dict)
    order_index = Column(Integer, nullable=False, default=0)
    compiler_version = Column(Integer, nullable=False, default=1)
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
            "entry_id",
            "compiler_version",
            name="uq_trip_compiled_projection_items_trip_entry_version",
        ),
        CheckConstraint(
            "source_kind IN ('tracking_event', 'tracking_event_media')",
            name="check_compiled_projection_source_kind",
        ),
        CheckConstraint(
            "event_type IN ('note', 'warn', 'tag', 'photo', 'media')",
            name="check_compiled_projection_event_type",
        ),
        CheckConstraint(
            "bucket_type IN ('place', 'on_route')",
            name="check_compiled_projection_bucket_type",
        ),
        CheckConstraint(
            "bind_source IN ('auto', 'manual', 'none')",
            name="check_compiled_projection_bind_source",
        ),
        Index("idx_compiled_projection_items_trip_day_order", "trip_id", "day_key", "order_index"),
        Index("idx_compiled_projection_items_trip_captured", "trip_id", "captured_at"),
        Index("idx_compiled_projection_items_trip_bucket", "trip_id", "bucket_type"),
    )
