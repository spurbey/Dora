"""
Trip Component model for unified timeline view.

Read-only model mapped to trip_components_view.
Combines places and routes for chronological display.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text
from sqlalchemy.dialects.postgresql import UUID

from app.database import Base


class TripComponent(Base):
    """
    Read-only model for trip_components_view.

    This model maps to a database VIEW that combines trip_places and routes
    into a unified timeline. It's read-only - no INSERT/UPDATE/DELETE operations.

    Use this model for:
    - Fetching unified timelines (places + routes together)
    - Displaying chronological order of trip components
    - Type detection (place vs route)

    For modifications, update the source tables (trip_places, routes) directly.

    Attributes:
        id: Component UUID (from source table)
        trip_id: Parent trip UUID
        user_id: Owner UUID
        component_type: 'place' or 'route'
        name: Display name
        order_in_trip: Sort order (0-indexed)
        created_at: Creation timestamp
        updated_at: Last modified timestamp
        source_table: 'trip_places' or 'routes'
        source_id: Original record UUID (same as id)

    Important:
        - NO ORDER BY in view definition
        - Always use .order_by(TripComponent.order_in_trip) in queries
        - This is a VIEW, not a table - data stays in source tables
    """

    __tablename__ = 'trip_components_view'

    # Primary key (from source table)
    id = Column(UUID, primary_key=True)

    # Foreign keys
    trip_id = Column(UUID, nullable=False)
    user_id = Column(UUID, nullable=False)

    # Component metadata
    component_type = Column(String, nullable=False)  # 'place' or 'route'
    name = Column(Text, nullable=False)
    order_in_trip = Column(Integer, nullable=False)

    # Timestamps
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime, nullable=False)

    # Source tracking
    source_table = Column(String, nullable=False)  # 'trip_places' or 'routes'
    source_id = Column(UUID, nullable=False)  # Original record ID
