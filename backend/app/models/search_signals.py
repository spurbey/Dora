"""
Search signal models for behavioral data collection.

Tables:
    - SearchEvent: User search queries and parameters
    - PlaceView: Place detail views (clicks from search)
    - PlaceSave: Place saves to trips (strongest signal)

These tables form the moat - unique behavioral dataset that improves
search ranking and enables personalization.
"""

from sqlalchemy import Column, String, Text, Float, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class SearchEvent(Base):
    """
    User search event log.

    Tracks every search query to identify:
    - Trending searches
    - Missing places (high search, low results)
    - Geographic patterns

    Attributes:
        id: UUID primary key
        user_id: Foreign key to users table
        query: Search text (normalized)
        lat: Search center latitude
        lng: Search center longitude
        radius_km: Search radius
        results_count: Number of results returned
        created_at: Timestamp when search occurred
    """

    __tablename__ = "search_events"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=func.gen_random_uuid(),
        comment="Primary key"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="User who performed search"
    )
    query = Column(
        Text,
        nullable=False,
        comment="Search query text (normalized)"
    )
    lat = Column(
        Float,
        nullable=False,
        comment="Search center latitude"
    )
    lng = Column(
        Float,
        nullable=False,
        comment="Search center longitude"
    )
    radius_km = Column(
        Float,
        nullable=False,
        comment="Search radius in kilometers"
    )
    results_count = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Number of results returned"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
        comment="When search occurred"
    )

    def __repr__(self):
        return f"<SearchEvent(id={self.id}, query='{self.query}', results={self.results_count})>"


class PlaceView(Base):
    """
    Place detail view event log.

    Tracks when users click on search results to view details.
    Quality signal: which results are interesting enough to click.

    Attributes:
        id: UUID primary key
        user_id: Foreign key to users table
        place_id: Foreign key to trip_places table (nullable for external)
        source: Where result came from ("local" or "foursquare")
        created_at: Timestamp when view occurred
    """

    __tablename__ = "place_views"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=func.gen_random_uuid(),
        comment="Primary key"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="User who viewed place"
    )
    place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="CASCADE"),
        nullable=True,  # Nullable for external results
        index=True,
        comment="Place that was viewed (null for external)"
    )
    source = Column(
        String(50),
        nullable=False,
        comment="Result source: local, foursquare, etc."
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="When view occurred"
    )

    def __repr__(self):
        return f"<PlaceView(id={self.id}, place_id={self.place_id}, source='{self.source}')>"


class PlaceSave(Base):
    """
    Place save event log.

    Tracks when users add places to their trips.
    Strongest signal: user took action, invested time.

    Attributes:
        id: UUID primary key
        user_id: Foreign key to users table
        place_id: Foreign key to trip_places table
        created_at: Timestamp when save occurred
    """

    __tablename__ = "place_saves"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=func.gen_random_uuid(),
        comment="Primary key"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="User who saved place"
    )
    place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Place that was saved"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="When save occurred"
    )

    def __repr__(self):
        return f"<PlaceSave(id={self.id}, place_id={self.place_id})>"
