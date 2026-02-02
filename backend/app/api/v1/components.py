"""
Component API endpoints for unified timeline.

Implements 3 endpoints:
- GET /trips/{trip_id}/components (list timeline)
- PATCH /trips/{trip_id}/components/reorder (bulk reorder)
- GET /trips/{trip_id}/components/{component_id} (get details)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.models.trip_component import TripComponent
from app.schemas.trip_component import (
    TripComponentListResponse,
    TripComponentResponse,
    TripComponentDetailResponse,
    ComponentReorderRequest,
    ComponentReorderResponse
)
from app.services.component_service import ComponentService


router = APIRouter(tags=["Components"])


# ============================================================================
# COMPONENT ENDPOINTS (3)
# ============================================================================

@router.get(
    "/trips/{trip_id}/components",
    response_model=TripComponentListResponse,
    summary="Get unified timeline",
    description="Fetch all places and routes for a trip in chronological order"
)
async def get_components(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get unified timeline of places + routes for a trip.

    Returns items sorted by order_in_trip (chronological order).
    Lightweight response without full entity details.

    Access:
    - Owner: Always allowed
    - Non-owner: Only if trip is public or unlisted

    Returns:
        TripComponentListResponse with components array, total count, trip_id
    """
    # Verify trip exists
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    # Check access (owner or public/unlisted trip)
    is_owner = trip.user_id == current_user.id
    is_accessible = trip.visibility in ['public', 'unlisted']

    if not is_owner and not is_accessible:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )

    # Query view with explicit ORDER BY (view doesn't guarantee order)
    components = db.query(TripComponent)\
        .filter(TripComponent.trip_id == trip_id)\
        .order_by(TripComponent.order_in_trip)\
        .all()

    return TripComponentListResponse(
        components=[TripComponentResponse.model_validate(c) for c in components],
        total=len(components),
        trip_id=trip_id
    )


@router.patch(
    "/trips/{trip_id}/components/reorder",
    response_model=ComponentReorderResponse,
    summary="Bulk reorder components",
    description="Reorder places and routes with automatic normalization to 0,1,2,3..."
)
async def reorder_components(
    trip_id: UUID,
    request: ComponentReorderRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Bulk reorder components with automatic normalization.

    Ensures clean sequential ordering: 0, 1, 2, 3... (no gaps, no duplicates).
    Input order values are relative - they'll be normalized to sequential integers.

    Access:
    - Owner only

    Example:
        Input:  [place(5), route(2), place(8)]
        Result: [route(0), place(1), place(2)]

    Returns:
        ComponentReorderResponse with success message and updated count
    """
    # Verify trip exists and check ownership
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    if trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized - only trip owner can reorder"
        )

    # Validate all components belong to this trip
    for item in request.items:
        component = db.query(TripComponent).filter(
            TripComponent.id == item.id,
            TripComponent.trip_id == trip_id
        ).first()

        if not component:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Component {item.id} not found in trip {trip_id}"
            )

    # Reorder with normalization via service
    service = ComponentService(db)
    updated_count = await service.reorder_components(
        trip_id,
        [item.model_dump() for item in request.items]
    )

    return ComponentReorderResponse(
        message='Components reordered successfully',
        updated_count=updated_count
    )


@router.get(
    "/trips/{trip_id}/components/{component_id}",
    response_model=TripComponentDetailResponse,
    summary="Get component details",
    description="Get full details of a place or route component (auto-detects type)"
)
async def get_component_details(
    trip_id: UUID,
    component_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get full details of a component (place or route).

    Auto-detects type from view (no type parameter needed).
    Returns full entity data with polymorphic response.

    Access:
    - Owner: Always allowed
    - Non-owner: Only if trip is public or unlisted

    Returns:
        TripComponentDetailResponse with:
        - id, component_type, order_in_trip
        - place_data (if place) or None
        - route_data (if route) or None
    """
    # Verify trip exists and check access
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    is_owner = trip.user_id == current_user.id
    is_accessible = trip.visibility in ['public', 'unlisted']

    if not is_owner and not is_accessible:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )

    # Get details via service (auto-detects type)
    service = ComponentService(db)
    details = await service.get_component_details(trip_id, component_id)

    if not details:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Component not found"
        )

    return TripComponentDetailResponse(**details)
