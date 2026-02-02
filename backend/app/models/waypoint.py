"""
Waypoint model for points along routes.

Stores waypoints with coordinates, types, and user notes.
Follows Phase A2 PRD specification.
"""

from sqlalchemy import Column, Text, Integer, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class Waypoint(Base):
    """
    Waypoint along a route.

    Attributes:
        id: UUID primary key
        route_id: Foreign key to routes table
        trip_id: Foreign key to trips table
        user_id: Foreign key to users table
        lat: Latitude (-90 to 90)
        lng: Longitude (-180 to 180)
        name: Waypoint label (required)
        waypoint_type: Type (stop, note, photo, poi)
        notes: User notes (optional)
        order_in_route: Position along route (required, >= 0)
        stopped_at: When user stopped here (optional)
        created_at: Creation timestamp

    Business Rules:
        - waypoint_type must be one of: stop, note, photo, poi
        - lat must be between -90 and 90
        - lng must be between -180 and 180
        - order_in_route is required (not nullable)
        - When route deleted, waypoint cascade deleted
    """

    __tablename__ = "waypoints"

    # Primary key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Waypoint ID"
    )

    # Foreign keys
    route_id = Column(
        UUID(as_uuid=True),
        ForeignKey("routes.id", ondelete="CASCADE"),
        nullable=False,
        comment="FK to routes"
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="FK to trips"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="FK to users"
    )

    # Coordinates
    lat = Column(
        Float,
        nullable=False,
        comment="Latitude"
    )
    lng = Column(
        Float,
        nullable=False,
        comment="Longitude"
    )

    # Waypoint details
    name = Column(
        Text,
        nullable=False,
        comment="Waypoint label"
    )
    waypoint_type = Column(
        Text,
        nullable=False,
        comment="stop, note, photo, poi"
    )
    notes = Column(
        Text,
        nullable=True,
        comment="User notes"
    )

    # Order in route
    order_in_route = Column(
        Integer,
        nullable=False,
        comment="Position along route"
    )

    # Time tracking
    stopped_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When user stopped here"
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Creation timestamp"
    )

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "waypoint_type IN ('stop', 'note', 'photo', 'poi')",
            name="check_waypoint_type"
        ),
        CheckConstraint(
            "lat >= -90 AND lat <= 90",
            name="check_lat_range"
        ),
        CheckConstraint(
            "lng >= -180 AND lng <= 180",
            name="check_lng_range"
        ),
        CheckConstraint(
            "order_in_route >= 0",
            name="check_waypoint_order_positive"
        ),
    )

    def __repr__(self):
        return f"<Waypoint(id={self.id}, route_id={self.route_id}, name={self.name})>"
