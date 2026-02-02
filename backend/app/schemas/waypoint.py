"""
Pydantic schemas for waypoint operations.

Schemas for waypoint CRUD requests and responses per Phase A2 PRD.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, Literal
from datetime import datetime
from uuid import UUID


class WaypointBase(BaseModel):
    """Base waypoint schema with common fields."""
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)
    name: str = Field(..., min_length=1, max_length=255)
    waypoint_type: Literal['stop', 'note', 'photo', 'poi']
    notes: Optional[str] = None
    order_in_route: int = Field(..., ge=0)
    stopped_at: Optional[datetime] = None


class WaypointCreate(WaypointBase):
    """
    Waypoint creation schema.

    Used for POST /routes/{route_id}/waypoints endpoint.
    route_id is taken from URL path parameter.
    """
    pass


class WaypointUpdate(BaseModel):
    """
    Waypoint update schema (partial updates).

    All fields are optional.
    """
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    waypoint_type: Optional[Literal['stop', 'note', 'photo', 'poi']] = None
    notes: Optional[str] = None
    order_in_route: Optional[int] = Field(None, ge=0)
    stopped_at: Optional[datetime] = None


class WaypointResponse(WaypointBase):
    """Waypoint response schema."""
    id: UUID
    route_id: UUID
    trip_id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class WaypointListResponse(BaseModel):
    """Waypoint list response."""
    waypoints: list[WaypointResponse]
    total: int
