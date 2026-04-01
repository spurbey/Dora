"""
Trip tracking event media model.

Stores live-capture media markers synced from mobile runtime.
This is metadata-first and supports both place-bound and route-geotag media.
"""

import uuid

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    Float,
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


class TripTrackingEventMedia(Base):
    """Live-capture media metadata row tied to tracking events."""

    __tablename__ = "trip_tracking_event_media"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Media row ID")
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
    event_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_tracking_events.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owning tracking event row ID",
    )
    client_media_id = Column(
        UUID(as_uuid=True),
        nullable=False,
        comment="Client-generated idempotent media identity",
    )
    client_event_id = Column(
        UUID(as_uuid=True),
        nullable=False,
        comment="Client-generated event identity this media belongs to",
    )
    media_type = Column(
        String(16),
        nullable=False,
        comment="photo|media",
    )
    bind_mode = Column(
        String(16),
        nullable=False,
        comment="place|route",
    )
    trip_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
        comment="Bound trip place for place-mode media",
    )
    captured_at = Column(DateTime(timezone=True), nullable=False, comment="Original media capture timestamp")
    anchor_latitude = Column(Float, nullable=True, comment="Route anchor latitude for route-mode")
    anchor_longitude = Column(Float, nullable=True, comment="Route anchor longitude for route-mode")
    upload_ref = Column(Text, nullable=False, comment="Opaque upload/file reference from client")
    mime_type = Column(String(128), nullable=True)
    file_size_bytes = Column(Integer, nullable=True)
    payload = Column(
        JSONB,
        nullable=False,
        default=dict,
        comment="Additional media metadata payload",
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
            "user_id",
            "client_media_id",
            name="uq_tracking_event_media_trip_user_client_media",
        ),
        CheckConstraint(
            "media_type IN ('photo', 'media')",
            name="check_trip_tracking_event_media_type",
        ),
        CheckConstraint(
            "bind_mode IN ('place', 'route')",
            name="check_trip_tracking_event_media_bind_mode",
        ),
        CheckConstraint(
            "(bind_mode != 'place') OR trip_place_id IS NOT NULL",
            name="check_trip_tracking_event_media_place_mode",
        ),
        CheckConstraint(
            "(bind_mode != 'route') OR "
            "(anchor_latitude IS NOT NULL AND anchor_longitude IS NOT NULL)",
            name="check_trip_tracking_event_media_route_mode",
        ),
        CheckConstraint(
            "anchor_latitude IS NULL OR (anchor_latitude >= -90 AND anchor_latitude <= 90)",
            name="check_trip_tracking_event_media_anchor_latitude",
        ),
        CheckConstraint(
            "anchor_longitude IS NULL OR (anchor_longitude >= -180 AND anchor_longitude <= 180)",
            name="check_trip_tracking_event_media_anchor_longitude",
        ),
        Index("idx_trip_tracking_event_media_trip_captured_at", "trip_id", "captured_at"),
        Index("idx_trip_tracking_event_media_user_captured_at", "user_id", "captured_at"),
        Index("idx_trip_tracking_event_media_event_captured_at", "event_id", "captured_at"),
        Index("idx_trip_tracking_event_media_bind_mode_captured_at", "bind_mode", "captured_at"),
    )
