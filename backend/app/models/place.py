"""
TripPlace model with PostGIS Geography support.

Stores places within trips with geospatial data for map display and queries.
Uses PostGIS Geography type for accurate distance calculations.
"""

from sqlalchemy import Column, String, Text, Date, Integer, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from geoalchemy2 import Geography
from sqlalchemy.sql import func
import uuid

from app.database import Base


class TripPlace(Base):
    """
    Place within a trip with geospatial data.
    
    Attributes:
        id: UUID primary key
        trip_id: Foreign key to trips table
        user_id: Foreign key to users table (for ownership checks)
        name: Place name (required)
        place_type: Category (restaurant, hotel, attraction, etc.)
        location: PostGIS Geography point (SRID 4326)
        lat: Latitude (convenience, duplicates location)
        lng: Longitude (convenience, duplicates location)
        user_notes: Personal notes about place
        user_rating: Rating 1-5
        visit_date: Date of visit
        photos: JSONB array of photo metadata
        videos: JSONB array of video metadata
        external_data: JSONB for cached API data (Foursquare, etc.)
        order_in_trip: Order position in itinerary
        created_at: Creation timestamp
        updated_at: Last update timestamp
        
    PostGIS Usage:
        - location column: Geography(Point, 4326) for accurate distance
        - Spatial index: GIST on location column
        - Distance queries: ST_Distance, ST_DWithin
        
    Business Rules:
        - location is source of truth (lat/lng are convenience copies)
        - GIST index enables fast radius searches
        - User can only modify places in their own trips
        - Photos/videos stored as JSONB arrays of {url, caption, order}
    """
    
    __tablename__ = "trip_places"
    
    # Primary key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Place ID"
    )
    
    # Foreign keys
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Parent trip ID"
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID"
    )
    
    # Place info
    name = Column(
        String(255),
        nullable=False,
        comment="Place name"
    )
    place_type = Column(
        String(50),
        comment="Category: restaurant, hotel, attraction, etc."
    )
    
    # Geospatial data (PostGIS)
    location = Column(
        Geography(geometry_type="POINT", srid=4326),
        nullable=False,
        comment="PostGIS Geography point (WGS84)"
    )
    # Convenience columns (duplicate of location for easy access)
    lat = Column(
        Float,
        nullable=False,
        comment="Latitude (WGS84)"
    )
    lng = Column(
        Float,
        nullable=False,
        comment="Longitude (WGS84)"
    )
    
    # User content
    user_notes = Column(
        Text,
        comment="Personal notes"
    )
    user_rating = Column(
        Integer,
        comment="Rating 1-5"
    )
    visit_date = Column(
        Date,
        comment="Date of visit"
    )
    
    # Media (JSONB arrays)
    photos = Column(
        JSONB,
        default=list,
        comment="Array of photo objects: [{url, caption, order}]"
    )
    videos = Column(
        JSONB,
        default=list,
        comment="Array of video objects: [{url, caption, order}]"
    )
    
    # External API data cache
    external_data = Column(
        JSONB,
        comment="Cached data from Foursquare, Mapbox, etc."
    )
    
    # Ordering
    order_in_trip = Column(
        Integer,
        comment="Position in trip itinerary"
    )
    
    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Creation time"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update time"
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint(
            "user_rating IS NULL OR (user_rating >= 1 AND user_rating <= 5)",
            name="check_rating"
        ),
    )
    
    def __repr__(self):
        return f"<TripPlace(id={self.id}, name={self.name}, trip_id={self.trip_id})>"