"""
Pydantic schemas for trip component operations.

Schemas for unified timeline operations (list, detail, reorder).
"""

from pydantic import BaseModel, ConfigDict, Field
from uuid import UUID
from datetime import datetime
from typing import Literal, Optional

# Import existing schemas for polymorphic responses
from app.schemas.place import PlaceResponse
from app.schemas.route import RouteResponse


class TripComponentBase(BaseModel):
    """Base component schema with common fields."""
    id: UUID
    trip_id: UUID
    component_type: Literal['place', 'route']
    name: str
    order_in_trip: int
    created_at: datetime


class TripComponentResponse(TripComponentBase):
    """
    Lightweight timeline item for list views.

    Use this for displaying the unified timeline without full entity details.
    """
    model_config = ConfigDict(from_attributes=True)


class TripComponentListResponse(BaseModel):
    """Response for GET /trips/{trip_id}/components."""
    components: list[TripComponentResponse]
    total: int
    trip_id: UUID


class TripComponentDetailResponse(BaseModel):
    """
    Full component details with polymorphic data.

    Returns the component metadata plus the full entity data
    (either place_data OR route_data, never both).

    Example:
        For a place component:
        {
            "id": "uuid",
            "component_type": "place",
            "order_in_trip": 2,
            "place_data": {...full PlaceResponse...},
            "route_data": null
        }

        For a route component:
        {
            "id": "uuid",
            "component_type": "route",
            "order_in_trip": 3,
            "place_data": null,
            "route_data": {...full RouteResponse...}
        }
    """
    id: UUID
    component_type: Literal['place', 'route']
    order_in_trip: int

    # Polymorphic data (one will be None)
    place_data: Optional[PlaceResponse] = None
    route_data: Optional[RouteResponse] = None


class ComponentReorderItem(BaseModel):
    """Single item in bulk reorder request."""
    id: UUID
    component_type: Literal['place', 'route']
    new_order: int = Field(..., ge=0, description="New order position (will be normalized)")


class ComponentReorderRequest(BaseModel):
    """
    Bulk reorder request.

    The service will normalize the order to sequential integers (0,1,2,3...)
    regardless of input values. You can send [5,2,8] and it will become [0,1,2].

    Example:
        {
            "items": [
                {"id": "place-uuid", "component_type": "place", "new_order": 2},
                {"id": "route-uuid", "component_type": "route", "new_order": 0},
                {"id": "place-uuid-2", "component_type": "place", "new_order": 1}
            ]
        }

        After normalization, the order will be: route(0), place-2(1), place(2)
    """
    items: list[ComponentReorderItem]


class ComponentReorderResponse(BaseModel):
    """Response for reorder operation."""
    message: str
    updated_count: int
