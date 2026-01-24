"""
Pydantic schemas for trip operations.

Schemas for trip CRUD requests and responses.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime, date
from uuid import UUID


class TripBase(BaseModel):
    """
    Base trip schema with common fields.

    Attributes:
        title: Trip title (required, 1-255 chars)
        description: Optional trip description
        start_date: Optional trip start date
        end_date: Optional trip end date
        cover_photo_url: URL to cover photo
        visibility: private | unlisted | public (default: private)

    Business Rules:
        - Title is required and cannot be empty
        - If both dates provided, end_date must be >= start_date
        - Visibility must be one of: private, unlisted, public
    """
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    cover_photo_url: Optional[str] = None
    visibility: str = Field(default="private")

    @validator('visibility')
    def validate_visibility(cls, v: str) -> str:
        """
        Validate visibility is one of allowed values.

        Args:
            v: Visibility value

        Returns:
            str: Validated visibility value

        Raises:
            ValueError: If visibility is not valid
        """
        allowed = ["private", "unlisted", "public"]
        if v not in allowed:
            raise ValueError(f'Visibility must be one of: {", ".join(allowed)}')
        return v

    @validator('end_date')
    def validate_dates(cls, v: Optional[date], values) -> Optional[date]:
        """
        Validate end_date is after or equal to start_date.

        Args:
            v: End date value
            values: All field values (to access start_date)

        Returns:
            Optional[date]: Validated end date

        Raises:
            ValueError: If end_date is before start_date
        """
        if v is not None and 'start_date' in values:
            start_date = values['start_date']
            if start_date is not None and v < start_date:
                raise ValueError('end_date must be after or equal to start_date')
        return v


class TripCreate(TripBase):
    """
    Trip creation schema.

    Inherits all fields from TripBase.
    Used for POST /trips endpoint.

    Business Logic:
        - user_id is automatically set from authenticated user
        - Free tier users: max 3 trips (enforced in service layer)
        - Premium users: unlimited trips
    """
    pass


class TripUpdate(BaseModel):
    """
    Trip update schema.

    All fields are optional for partial updates.

    Attributes:
        title: New trip title
        description: New description
        start_date: New start date
        end_date: New end date
        cover_photo_url: New cover photo URL
        visibility: New visibility setting

    Business Rules:
        - Only owner can update
        - If updating dates, end_date must still be >= start_date
        - Cannot update user_id or engagement metrics
    """
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    cover_photo_url: Optional[str] = None
    visibility: Optional[str] = None

    @validator('visibility')
    def validate_visibility(cls, v: Optional[str]) -> Optional[str]:
        """Validate visibility if provided."""
        if v is not None:
            allowed = ["private", "unlisted", "public"]
            if v not in allowed:
                raise ValueError(f'Visibility must be one of: {", ".join(allowed)}')
        return v


class TripResponse(BaseModel):
    """
    Trip response schema.

    Attributes:
        id: Trip UUID
        user_id: Owner user ID
        title: Trip title
        description: Trip description
        start_date: Trip start date
        end_date: Trip end date
        cover_photo_url: Cover photo URL
        visibility: Visibility setting
        views_count: Number of views
        saves_count: Number of saves
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    cover_photo_url: Optional[str] = None
    visibility: str
    views_count: int
    saves_count: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class TripListResponse(BaseModel):
    """
    Paginated trip list response.

    Attributes:
        trips: List of trips
        total: Total number of trips (before pagination)
        page: Current page number (1-indexed)
        page_size: Number of items per page
        total_pages: Total number of pages

    Used for GET /trips endpoint with pagination.
    """
    trips: list[TripResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
