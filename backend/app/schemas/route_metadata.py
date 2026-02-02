"""
Pydantic schemas for route metadata operations.

Schemas for route metadata CRUD requests and responses per Phase A2 PRD.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, Literal
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class RouteMetadataBase(BaseModel):
    """Base route metadata schema with common fields."""
    route_quality: Optional[Literal['scenic', 'fastest', 'offbeat']] = None
    road_condition: Optional[Literal['excellent', 'good', 'poor', 'offroad']] = None
    scenic_rating: Optional[int] = Field(None, ge=1, le=5)
    safety_rating: int = Field(default=3, ge=1, le=5)
    solo_safe: bool = True
    fuel_cost: Optional[Decimal] = Field(None, ge=0)
    toll_cost: Optional[Decimal] = Field(None, ge=0)
    highlights: Optional[list[str]] = None
    is_public: bool = False


class RouteMetadataCreate(RouteMetadataBase):
    """
    Route metadata creation schema.

    Used for POST /routes/{route_id}/metadata endpoint.
    route_id is taken from URL path parameter.
    """
    pass


class RouteMetadataUpdate(BaseModel):
    """
    Route metadata update schema (partial updates).

    All fields are optional.
    """
    route_quality: Optional[Literal['scenic', 'fastest', 'offbeat']] = None
    road_condition: Optional[Literal['excellent', 'good', 'poor', 'offroad']] = None
    scenic_rating: Optional[int] = Field(None, ge=1, le=5)
    safety_rating: Optional[int] = Field(None, ge=1, le=5)
    solo_safe: Optional[bool] = None
    fuel_cost: Optional[Decimal] = Field(None, ge=0)
    toll_cost: Optional[Decimal] = Field(None, ge=0)
    highlights: Optional[list[str]] = None
    is_public: Optional[bool] = None


class RouteMetadataResponse(RouteMetadataBase):
    """Route metadata response schema."""
    route_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
