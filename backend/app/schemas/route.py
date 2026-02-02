"""
Pydantic schemas for route operations.

Schemas for route CRUD requests and responses per Phase A2 PRD.
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, Literal
from datetime import datetime
from uuid import UUID


class RouteBase(BaseModel):
    """Base route schema with common fields."""
    name: Optional[str] = None
    description: Optional[str] = None
    transport_mode: Literal['car', 'bike', 'foot', 'air', 'bus', 'train']
    route_category: Literal['ground', 'air']
    start_place_id: Optional[UUID] = None
    end_place_id: Optional[UUID] = None
    order_in_trip: int = Field(default=0, ge=0)


class RouteCreate(RouteBase):
    """
    Route creation schema.

    Must include valid GeoJSON LineString.
    """
    route_geojson: dict = Field(..., description="Must be valid GeoJSON LineString")

    @validator('route_geojson')
    def validate_geojson(cls, v):
        """Validate GeoJSON is a LineString."""
        if not isinstance(v, dict):
            raise ValueError('route_geojson must be a dict')
        if v.get('type') != 'LineString':
            raise ValueError('route_geojson must be a LineString')
        if 'coordinates' not in v:
            raise ValueError('route_geojson must have coordinates')
        return v


class RouteUpdate(BaseModel):
    """Route update schema (partial updates)."""
    name: Optional[str] = None
    description: Optional[str] = None
    route_geojson: Optional[dict] = None
    order_in_trip: Optional[int] = Field(None, ge=0)

    @validator('route_geojson')
    def validate_geojson(cls, v):
        """Validate GeoJSON if provided."""
        if v is not None:
            if not isinstance(v, dict):
                raise ValueError('route_geojson must be a dict')
            if v.get('type') != 'LineString':
                raise ValueError('route_geojson must be a LineString')
            if 'coordinates' not in v:
                raise ValueError('route_geojson must have coordinates')
        return v


class RouteResponse(RouteBase):
    """Route response schema."""
    id: UUID
    trip_id: UUID
    user_id: UUID
    route_geojson: dict
    polyline_encoded: Optional[str] = None
    distance_km: Optional[float] = None
    duration_mins: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class RouteListResponse(BaseModel):
    """Paginated route list response."""
    routes: list[RouteResponse]
    total: int


class RouteGenerateRequest(BaseModel):
    """Request schema for /routes/generate endpoint."""
    coordinates: list[tuple[float, float]] = Field(..., min_items=2, description="[(lng, lat), ...]")
    mode: Literal['driving', 'walking', 'cycling'] = 'driving'

    @validator('coordinates')
    def validate_coordinates(cls, v):
        """Validate coordinates are valid lng/lat pairs."""
        for coord in v:
            if len(coord) != 2:
                raise ValueError('Each coordinate must be (lng, lat)')
            lng, lat = coord
            if not (-180 <= lng <= 180):
                raise ValueError(f'Longitude {lng} out of range (-180 to 180)')
            if not (-90 <= lat <= 90):
                raise ValueError(f'Latitude {lat} out of range (-90 to 90)')
        return v


class RouteGenerateResponse(BaseModel):
    """Response schema for /routes/generate endpoint."""
    route_geojson: dict
    distance_km: float
    duration_mins: int
    polyline_encoded: Optional[str] = None
