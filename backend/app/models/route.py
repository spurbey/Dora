"""
Route model for travel paths between places.

Stores routes with GeoJSON LineStrings, transport modes, and route metadata.
Follows Phase A2 PRD specification.
"""

from sqlalchemy import Column, Text, Integer, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
import uuid

from app.database import Base


class Route(Base):
    """
    Route between places in a trip.

    Attributes:
        id: UUID primary key
        trip_id: Foreign key to trips table
        user_id: Foreign key to users table (owner)
        route_geojson: GeoJSON LineString (required)
        polyline_encoded: Google-encoded polyline (optional)
        start_place_id: Starting place (nullable)
        end_place_id: Ending place (nullable)
        transport_mode: Mode of transport (car, bike, foot, air, bus, train)
        route_category: Category (ground, air)
        distance_km: Distance in kilometers (auto-calculated)
        duration_mins: Duration in minutes (auto-calculated)
        order_in_trip: Display order (required, >= 0)
        name: Optional route name
        description: User notes
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Business Rules:
        - route_geojson must be valid GeoJSON LineString
        - transport_mode must be one of: car, bike, foot, air, bus, train
        - route_category must be: ground or air
        - order_in_trip is required (not nullable)
        - When places deleted, FK set to NULL
        - When trip deleted, route cascade deleted
    """

    __tablename__ = "routes"

    # Primary key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Route ID"
    )

    # Foreign keys
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="FK to trips"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="FK to users"
    )
    start_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
        comment="FK to trip_places"
    )
    end_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="SET NULL"),
        nullable=True,
        comment="FK to trip_places"
    )

    # Route geometry
    route_geojson = Column(
        JSONB,
        nullable=False,
        comment="GeoJSON LineString"
    )
    polyline_encoded = Column(
        Text,
        nullable=True,
        comment="Google-encoded polyline (optional)"
    )

    # Route details
    transport_mode = Column(
        Text,
        nullable=False,
        comment="car, bike, foot, air, bus, train"
    )
    route_category = Column(
        Text,
        nullable=False,
        comment="ground, air"
    )
    distance_km = Column(
        Float,
        nullable=True,
        comment="Auto-calculated"
    )
    duration_mins = Column(
        Integer,
        nullable=True,
        comment="Auto-calculated"
    )

    # Display order
    order_in_trip = Column(
        Integer,
        nullable=False,
        comment="Display order"
    )

    # Optional metadata
    name = Column(
        Text,
        nullable=True,
        comment="Optional route name"
    )
    description = Column(
        Text,
        nullable=True,
        comment="User notes"
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Creation timestamp"
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update timestamp"
    )

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "transport_mode IN ('car', 'bike', 'foot', 'air', 'bus', 'train')",
            name="check_transport_mode"
        ),
        CheckConstraint(
            "route_category IN ('ground', 'air')",
            name="check_route_category"
        ),
        CheckConstraint(
            "distance_km >= 0 OR distance_km IS NULL",
            name="check_distance_positive"
        ),
        CheckConstraint(
            "duration_mins >= 0 OR duration_mins IS NULL",
            name="check_duration_positive"
        ),
        CheckConstraint(
            "order_in_trip >= 0",
            name="check_order_positive"
        ),
    )

    def __repr__(self):
        return f"<Route(id={self.id}, trip_id={self.trip_id}, transport_mode={self.transport_mode})>"
