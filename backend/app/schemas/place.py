"""
Pydantic schemas for place operations.

Schemas for place CRUD requests and responses.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any, Union
from datetime import datetime, date
from uuid import UUID


class PlaceBase(BaseModel):
    """
    Base place schema with common fields.

    Attributes:
        name: Place name (required, 1-255 chars)
        place_type: Category (restaurant, hotel, attraction, etc.)
        lat: Latitude (-90 to 90)
        lng: Longitude (-180 to 180)
        user_notes: Personal notes about the place
        user_rating: Rating 1-5 (optional)
        visit_date: Date of visit (optional)

    Business Rules:
        - name is required
        - lat must be between -90 and 90 (WGS84)
        - lng must be between -180 and 180 (WGS84)
        - user_rating must be 1-5 if provided
    """
    name: str = Field(..., min_length=1, max_length=255)
    place_type: Optional[str] = Field(None, max_length=50)
    lat: float = Field(..., ge=-90, le=90, description="Latitude (WGS84)")
    lng: float = Field(..., ge=-180, le=180, description="Longitude (WGS84)")
    user_notes: Optional[str] = None
    user_rating: Optional[int] = Field(None, ge=1, le=5, description="Rating 1-5")
    visit_date: Optional[date] = None

    @validator('user_rating')
    def validate_rating(cls, v: Optional[int]) -> Optional[int]:
        """
        Validate rating is between 1 and 5.

        Args:
            v: Rating value

        Returns:
            Optional[int]: Validated rating

        Raises:
            ValueError: If rating is not 1-5
        """
        if v is not None and (v < 1 or v > 5):
            raise ValueError('user_rating must be between 1 and 5')
        return v


class PlaceCreate(PlaceBase):
    """
    Place creation schema.

    Inherits all fields from PlaceBase and adds trip-specific fields.
    Used for POST /places endpoint.

    Attributes:
        trip_id: ID of parent trip (required)
        order_in_trip: Position in trip itinerary (optional, auto-set if not provided)

    Business Logic:
        - trip_id must reference an existing trip
        - user_id is automatically set from authenticated user
        - location (Geography) is automatically created from lat/lng
        - If order_in_trip not provided, set to max + 1
    """
    trip_id: UUID
    order_in_trip: Optional[int] = None


class PlaceUpdate(BaseModel):
    """
    Place update schema.

    All fields are optional for partial updates.

    Attributes:
        name: New place name
        place_type: New category
        lat: New latitude
        lng: New longitude
        user_notes: New notes
        user_rating: New rating (1-5)
        visit_date: New visit date
        order_in_trip: New position

    Business Rules:
        - Only owner can update
        - If lat/lng updated, Geography column is automatically updated
        - Cannot update trip_id or user_id
    """
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    place_type: Optional[str] = Field(None, max_length=50)
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)
    user_notes: Optional[str] = None
    user_rating: Optional[int] = Field(None, ge=1, le=5)
    visit_date: Optional[date] = None
    order_in_trip: Optional[int] = None

    @validator('user_rating')
    def validate_rating(cls, v: Optional[int]) -> Optional[int]:
        """Validate rating if provided."""
        if v is not None and (v < 1 or v > 5):
            raise ValueError('user_rating must be between 1 and 5')
        return v


class PhotoMetadata(BaseModel):
    """
    Photo metadata schema.

    Attributes:
        url: Photo URL (from Supabase Storage)
        caption: Optional caption
        order: Display order (optional)
    """
    url: str
    caption: Optional[str] = None
    order: Optional[int] = None


class VideoMetadata(BaseModel):
    """
    Video metadata schema.

    Attributes:
        url: Video URL (from Supabase Storage)
        caption: Optional caption
        order: Display order (optional)
    """
    url: str
    caption: Optional[str] = None
    order: Optional[int] = None


class PlaceResponse(BaseModel):
    """
    Place response schema.

    Attributes:
        id: Place UUID
        trip_id: Parent trip ID
        user_id: Owner user ID
        name: Place name
        place_type: Category
        lat: Latitude
        lng: Longitude
        user_notes: Personal notes
        user_rating: Rating 1-5
        visit_date: Date of visit
        photos: Array of photo metadata or media objects
        videos: Array of video metadata
        external_data: Cached API data
        order_in_trip: Position in itinerary
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    id: UUID
    trip_id: UUID
    user_id: UUID
    name: str
    place_type: Optional[str] = None
    lat: float
    lng: float
    user_notes: Optional[str] = None
    user_rating: Optional[int] = None
    visit_date: Optional[date] = None
    photos: List[Union[UUID, Dict[str, Any]]] = []
    videos: List[Dict[str, Any]] = []
    external_data: Optional[Dict[str, Any]] = None
    order_in_trip: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PlaceListResponse(BaseModel):
    """
    List of places (typically for a single trip).

    Attributes:
        places: List of places
        total: Total number of places
        trip_id: Parent trip ID (for context), None for nearby queries

    Used for GET /places?trip_id={trip_id} and GET /places/nearby endpoints.
    """
    places: List[PlaceResponse]
    total: int
    trip_id: Optional[UUID] = None
