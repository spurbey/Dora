"""
Pydantic schemas for place metadata operations.

Schemas for place metadata CRUD requests and responses.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class PlaceMetadataBase(BaseModel):
    """
    Base place metadata schema with common fields.

    Attributes:
        component_type: Type of component (city, place, activity, accommodation, food, transport)
        experience_tags: Array of experience descriptors (romantic, adventurous, peaceful, crowded, instagram-worthy)
        best_for: Array of audience types (solo-travelers, couples, families, photographers, foodies)
        budget_per_person: Estimated cost per person in USD
        duration_hours: Recommended time to spend in hours
        difficulty_rating: Physical difficulty rating (1-5)
        physical_demand: Physical demand level (low, medium, high)
        best_time: Optimal time to visit (sunrise, morning, afternoon, sunset, night, anytime)
        is_public: Whether place can be discovered publicly

    Business Rules:
        - All fields except is_public are optional
        - Enum fields validated by validators
        - Array fields can be empty lists or None
    """
    component_type: Optional[str] = "place"
    experience_tags: Optional[list[str]] = None
    best_for: Optional[list[str]] = None
    budget_per_person: Optional[Decimal] = None
    duration_hours: Optional[float] = None
    difficulty_rating: Optional[int] = None
    physical_demand: Optional[str] = None
    best_time: Optional[str] = None
    is_public: bool = False

    @validator('component_type')
    def validate_component_type(cls, v: Optional[str]) -> Optional[str]:
        """Validate component_type is one of allowed values."""
        if v is not None:
            allowed = ["city", "place", "activity", "accommodation", "food", "transport"]
            if v not in allowed:
                raise ValueError(f'component_type must be one of: {", ".join(allowed)}')
        return v

    @validator('physical_demand')
    def validate_physical_demand(cls, v: Optional[str]) -> Optional[str]:
        """Validate physical_demand is one of allowed values."""
        if v is not None:
            allowed = ["low", "medium", "high"]
            if v not in allowed:
                raise ValueError(f'physical_demand must be one of: {", ".join(allowed)}')
        return v

    @validator('best_time')
    def validate_best_time(cls, v: Optional[str]) -> Optional[str]:
        """Validate best_time is one of allowed values."""
        if v is not None:
            allowed = ["sunrise", "morning", "afternoon", "sunset", "night", "anytime"]
            if v not in allowed:
                raise ValueError(f'best_time must be one of: {", ".join(allowed)}')
        return v

    @validator('difficulty_rating')
    def validate_difficulty_rating(cls, v: Optional[int]) -> Optional[int]:
        """Validate difficulty_rating is between 1 and 5."""
        if v is not None:
            if v < 1 or v > 5:
                raise ValueError('difficulty_rating must be between 1 and 5')
        return v

    @validator('duration_hours')
    def validate_duration_hours(cls, v: Optional[float]) -> Optional[float]:
        """Validate duration_hours is positive."""
        if v is not None and v <= 0:
            raise ValueError('duration_hours must be positive')
        return v

    @validator('budget_per_person')
    def validate_budget_per_person(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        """Validate budget_per_person is non-negative."""
        if v is not None and v < 0:
            raise ValueError('budget_per_person must be non-negative')
        return v


class PlaceMetadataCreate(PlaceMetadataBase):
    """
    Place metadata creation schema.

    Inherits all fields from PlaceMetadataBase.
    Used for POST /places/{place_id}/metadata endpoint.

    Business Logic:
        - place_id is taken from URL path parameter
        - All fields are optional except is_public (defaults to False)
    """
    pass


class PlaceMetadataUpdate(BaseModel):
    """
    Place metadata update schema.

    All fields are optional for partial updates.

    Attributes:
        component_type: New component type
        experience_tags: New experience tags
        best_for: New best_for tags
        budget_per_person: New budget estimate
        duration_hours: New duration estimate
        difficulty_rating: New difficulty rating
        physical_demand: New physical demand level
        best_time: New best time to visit
        is_public: New public setting

    Business Rules:
        - Only owner can update
        - Only provided fields are updated
        - contribution_score cannot be updated (system-managed)
    """
    component_type: Optional[str] = None
    experience_tags: Optional[list[str]] = None
    best_for: Optional[list[str]] = None
    budget_per_person: Optional[Decimal] = None
    duration_hours: Optional[float] = None
    difficulty_rating: Optional[int] = None
    physical_demand: Optional[str] = None
    best_time: Optional[str] = None
    is_public: Optional[bool] = None

    @validator('component_type')
    def validate_component_type(cls, v: Optional[str]) -> Optional[str]:
        """Validate component_type if provided."""
        if v is not None:
            allowed = ["city", "place", "activity", "accommodation", "food", "transport"]
            if v not in allowed:
                raise ValueError(f'component_type must be one of: {", ".join(allowed)}')
        return v

    @validator('physical_demand')
    def validate_physical_demand(cls, v: Optional[str]) -> Optional[str]:
        """Validate physical_demand if provided."""
        if v is not None:
            allowed = ["low", "medium", "high"]
            if v not in allowed:
                raise ValueError(f'physical_demand must be one of: {", ".join(allowed)}')
        return v

    @validator('best_time')
    def validate_best_time(cls, v: Optional[str]) -> Optional[str]:
        """Validate best_time if provided."""
        if v is not None:
            allowed = ["sunrise", "morning", "afternoon", "sunset", "night", "anytime"]
            if v not in allowed:
                raise ValueError(f'best_time must be one of: {", ".join(allowed)}')
        return v

    @validator('difficulty_rating')
    def validate_difficulty_rating(cls, v: Optional[int]) -> Optional[int]:
        """Validate difficulty_rating if provided."""
        if v is not None:
            if v < 1 or v > 5:
                raise ValueError('difficulty_rating must be between 1 and 5')
        return v

    @validator('duration_hours')
    def validate_duration_hours(cls, v: Optional[float]) -> Optional[float]:
        """Validate duration_hours if provided."""
        if v is not None and v <= 0:
            raise ValueError('duration_hours must be positive')
        return v

    @validator('budget_per_person')
    def validate_budget_per_person(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        """Validate budget_per_person if provided."""
        if v is not None and v < 0:
            raise ValueError('budget_per_person must be non-negative')
        return v


class PlaceMetadataResponse(PlaceMetadataBase):
    """
    Place metadata response schema.

    Attributes:
        place_id: Place UUID
        component_type: Type of component
        experience_tags: Array of experience descriptors
        best_for: Array of audience types
        budget_per_person: Estimated cost per person
        duration_hours: Recommended time to spend
        difficulty_rating: Physical difficulty rating
        physical_demand: Physical demand level
        best_time: Optimal time to visit
        is_public: Whether place can be discovered publicly
        contribution_score: Quality score for this component (0-1)
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    place_id: UUID
    contribution_score: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
