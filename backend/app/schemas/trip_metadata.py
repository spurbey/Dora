"""
Pydantic schemas for trip metadata operations.

Schemas for trip metadata CRUD requests and responses.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class TripMetadataBase(BaseModel):
    """
    Base trip metadata schema with common fields.

    Attributes:
        traveler_type: Array of traveler types (solo, couple, family, group)
        age_group: Target age group (gen-z, millennial, gen-x, boomer)
        travel_style: Array of travel styles (adventure, luxury, budget, cultural, relaxed)
        difficulty_level: Overall difficulty (easy, moderate, challenging, extreme)
        budget_category: Budget level (budget, mid-range, luxury)
        activity_focus: Array of activity types (hiking, food, photography, nightlife, beaches)
        is_discoverable: Whether trip can be found in public search
        tags: User-defined tags for categorization

    Business Rules:
        - All fields except is_discoverable are optional
        - Enum fields validated by validators
        - Array fields can be empty lists or None
    """
    traveler_type: Optional[list[str]] = None
    age_group: Optional[str] = None
    travel_style: Optional[list[str]] = None
    difficulty_level: Optional[str] = None
    budget_category: Optional[str] = None
    activity_focus: Optional[list[str]] = None
    is_discoverable: bool = False
    tags: Optional[list[str]] = None

    @validator('age_group')
    def validate_age_group(cls, v: Optional[str]) -> Optional[str]:
        """Validate age_group is one of allowed values."""
        if v is not None:
            allowed = ["gen-z", "millennial", "gen-x", "boomer"]
            if v not in allowed:
                raise ValueError(f'age_group must be one of: {", ".join(allowed)}')
        return v

    @validator('difficulty_level')
    def validate_difficulty_level(cls, v: Optional[str]) -> Optional[str]:
        """Validate difficulty_level is one of allowed values."""
        if v is not None:
            allowed = ["easy", "moderate", "challenging", "extreme"]
            if v not in allowed:
                raise ValueError(f'difficulty_level must be one of: {", ".join(allowed)}')
        return v

    @validator('budget_category')
    def validate_budget_category(cls, v: Optional[str]) -> Optional[str]:
        """Validate budget_category is one of allowed values."""
        if v is not None:
            allowed = ["budget", "mid-range", "luxury"]
            if v not in allowed:
                raise ValueError(f'budget_category must be one of: {", ".join(allowed)}')
        return v


class TripMetadataCreate(TripMetadataBase):
    """
    Trip metadata creation schema.

    Inherits all fields from TripMetadataBase.
    Used for POST /trips/{trip_id}/metadata endpoint.

    Business Logic:
        - trip_id is taken from URL path parameter
        - All fields are optional except is_discoverable (defaults to False)
    """
    pass


class TripMetadataUpdate(BaseModel):
    """
    Trip metadata update schema.

    All fields are optional for partial updates.

    Attributes:
        traveler_type: New traveler types
        age_group: New age group
        travel_style: New travel styles
        difficulty_level: New difficulty level
        budget_category: New budget category
        activity_focus: New activity focus
        is_discoverable: New discoverable setting
        tags: New tags

    Business Rules:
        - Only owner can update
        - Only provided fields are updated
        - quality_score cannot be updated (system-managed)
    """
    traveler_type: Optional[list[str]] = None
    age_group: Optional[str] = None
    travel_style: Optional[list[str]] = None
    difficulty_level: Optional[str] = None
    budget_category: Optional[str] = None
    activity_focus: Optional[list[str]] = None
    is_discoverable: Optional[bool] = None
    tags: Optional[list[str]] = None

    @validator('age_group')
    def validate_age_group(cls, v: Optional[str]) -> Optional[str]:
        """Validate age_group if provided."""
        if v is not None:
            allowed = ["gen-z", "millennial", "gen-x", "boomer"]
            if v not in allowed:
                raise ValueError(f'age_group must be one of: {", ".join(allowed)}')
        return v

    @validator('difficulty_level')
    def validate_difficulty_level(cls, v: Optional[str]) -> Optional[str]:
        """Validate difficulty_level if provided."""
        if v is not None:
            allowed = ["easy", "moderate", "challenging", "extreme"]
            if v not in allowed:
                raise ValueError(f'difficulty_level must be one of: {", ".join(allowed)}')
        return v

    @validator('budget_category')
    def validate_budget_category(cls, v: Optional[str]) -> Optional[str]:
        """Validate budget_category if provided."""
        if v is not None:
            allowed = ["budget", "mid-range", "luxury"]
            if v not in allowed:
                raise ValueError(f'budget_category must be one of: {", ".join(allowed)}')
        return v


class TripMetadataResponse(TripMetadataBase):
    """
    Trip metadata response schema.

    Attributes:
        trip_id: Trip UUID
        traveler_type: Array of traveler types
        age_group: Target age group
        travel_style: Array of travel styles
        difficulty_level: Overall difficulty
        budget_category: Budget level
        activity_focus: Array of activity types
        is_discoverable: Whether trip can be found in public search
        quality_score: System-calculated quality score (0-1)
        tags: User-defined tags
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    trip_id: UUID
    quality_score: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
