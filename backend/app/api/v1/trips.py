"""
Trip CRUD endpoints.

Endpoints:
    - POST /trips: Create new trip
    - GET /trips: List user's trips with pagination
    - GET /trips/{id}: Get trip detail
    - PATCH /trips/{id}: Update trip
    - DELETE /trips/{id}: Delete trip
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import Optional

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.schemas.trip import TripCreate, TripUpdate, TripResponse, TripListResponse
from app.services.trip_service import TripService


router = APIRouter(prefix="/trips", tags=["Trips"])


@router.post("", response_model=TripResponse, status_code=status.HTTP_201_CREATED)
async def create_trip(
    trip_data: TripCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create a new trip.

    **Authentication:** Required

    **Permissions:** Any authenticated user

    **Request Body:**
    - title: Trip title (required, 1-255 chars)
    - description: Optional trip description
    - start_date: Optional trip start date (YYYY-MM-DD)
    - end_date: Optional trip end date (YYYY-MM-DD)
    - cover_photo_url: Optional cover photo URL
    - visibility: private | unlisted | public (default: private)

    **Returns:**
    Created trip with generated ID

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "user_id": "987e6543-e21b-12d3-a456-426614174000",
        "title": "Summer Europe Trip",
        "description": "Backpacking across Europe",
        "start_date": "2025-06-01",
        "end_date": "2025-06-30",
        "visibility": "private",
        "views_count": 0,
        "saves_count": 0,
        "created_at": "2025-01-25T10:30:00Z",
        "updated_at": "2025-01-25T10:30:00Z"
    }
```

    **Errors:**
    - 400: Invalid date range (end_date < start_date) or invalid visibility
    - 401: Not authenticated
    - 403: Free tier limit reached (3 trips max)

    **Business Logic:**
    - user_id is automatically set from authenticated user
    - Free tier users: max 3 trips
    - Premium users: unlimited trips
    - Default visibility is "private"
    - views_count and saves_count initialized to 0
    """
    service = TripService(db)
    trip = service.create_trip(current_user.id, trip_data)
    return TripResponse.model_validate(trip)


@router.get("", response_model=TripListResponse)
async def list_trips(
    page: int = Query(1, ge=1, description="Page number (1-indexed)"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page (max 100)"),
    visibility: Optional[str] = Query(None, description="Filter by visibility (private|unlisted|public)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    List current user's trips with pagination.

    **Authentication:** Required

    **Permissions:** Any authenticated user (only sees own trips)

    **Query Parameters:**
    - page: Page number (default: 1, min: 1)
    - page_size: Items per page (default: 20, max: 100)
    - visibility: Optional filter by visibility (private|unlisted|public)

    **Returns:**
    Paginated list of trips with metadata

    **Response Example:**
```json
    {
        "trips": [
            {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "title": "Summer Europe Trip",
                ...
            },
            {
                "id": "987e6543-e21b-12d3-a456-426614174000",
                "title": "Winter Japan Trip",
                ...
            }
        ],
        "total": 15,
        "page": 1,
        "page_size": 20,
        "total_pages": 1
    }
```

    **Errors:**
    - 401: Not authenticated

    **Business Logic:**
    - Only returns trips owned by current user
    - Results ordered by created_at DESC (newest first)
    - Page size automatically capped at 100
    - Empty list if user has no trips
    """
    service = TripService(db)
    result = service.list_user_trips(
        user_id=current_user.id,
        page=page,
        page_size=page_size,
        visibility_filter=visibility
    )
    return result


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get trip detail by ID.

    **Authentication:** Required

    **Permissions:**
    - Owner can always view their trip
    - Non-owners can view if trip is public or unlisted
    - Private trips only visible to owner

    **Path Parameters:**
    - trip_id: Trip UUID

    **Returns:**
    Trip details

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "user_id": "987e6543-e21b-12d3-a456-426614174000",
        "title": "Summer Europe Trip",
        "description": "Backpacking across Europe",
        "start_date": "2025-06-01",
        "end_date": "2025-06-30",
        "visibility": "public",
        "views_count": 142,
        "saves_count": 23,
        "created_at": "2025-01-25T10:30:00Z",
        "updated_at": "2025-01-25T10:30:00Z"
    }
```

    **Errors:**
    - 401: Not authenticated
    - 403: Trip is private and user is not owner
    - 404: Trip not found

    **Business Logic:**
    - Increments views_count if viewer is NOT the owner
    - Access control based on visibility:
      - private: Only owner can view
      - unlisted: Owner + anyone with link can view
      - public: Anyone can view
    """
    service = TripService(db)

    # Fetch trip
    trip = service.get_trip_by_id(trip_id)
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    # Access control: Check visibility
    is_owner = trip.user_id == current_user.id

    if not is_owner and trip.visibility == "private":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this trip"
        )

    # Increment views if not owner
    if not is_owner:
        trip.views_count += 1
        db.commit()
        db.refresh(trip)

    return TripResponse.model_validate(trip)


@router.patch("/{trip_id}", response_model=TripResponse)
async def update_trip(
    trip_id: UUID,
    trip_update: TripUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update an existing trip.

    **Authentication:** Required

    **Permissions:** Only trip owner can update

    **Path Parameters:**
    - trip_id: Trip UUID

    **Request Body:**
    All fields are optional (partial update):
    - title: New trip title (1-255 chars)
    - description: New description
    - start_date: New start date
    - end_date: New end date
    - cover_photo_url: New cover photo URL
    - visibility: New visibility (private|unlisted|public)

    **Returns:**
    Updated trip

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "title": "Updated Trip Title",
        "description": "Updated description",
        ...
    }
```

    **Errors:**
    - 400: Invalid date range (end_date < start_date)
    - 401: Not authenticated
    - 403: User does not own trip
    - 404: Trip not found

    **Business Logic:**
    - Only updates provided fields (partial update)
    - Ownership check prevents unauthorized updates
    - Date validation ensures end_date >= start_date
    - Cannot update user_id or engagement metrics (views, saves)
    - updated_at timestamp automatically updated
    """
    service = TripService(db)
    updated_trip = service.update_trip(trip_id, current_user.id, trip_update)
    return TripResponse.model_validate(updated_trip)


@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete a trip.

    **Authentication:** Required

    **Permissions:** Only trip owner can delete

    **Path Parameters:**
    - trip_id: Trip UUID

    **Returns:**
    204 No Content on success

    **Errors:**
    - 401: Not authenticated
    - 403: User does not own trip
    - 404: Trip not found

    **Business Logic:**
    - Ownership check prevents unauthorized deletion
    - Cascades to related records:
      - All trip_places deleted (via ON DELETE CASCADE)
      - All trip_routes deleted (via ON DELETE CASCADE)
    - Permanent deletion (no soft delete)

    **Warning:**
    - This action is irreversible
    - All associated places and routes will be deleted
    """
    service = TripService(db)
    service.delete_trip(trip_id, current_user.id)
    # No return value for 204 No Content


@router.get("/{trip_id}/bounds")
async def get_trip_bounds(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get geographic bounding box for a trip based on its places.

    **Authentication:** Required

    **Permissions:**
    - Trip owner can always view
    - Non-owner can view if trip is public/unlisted

    **Path Parameters:**
    - trip_id: Trip UUID

    **Returns:**
    Bounding box with min/max coordinates and center point, or null if no places

    **Response Example:**
```json
    {
        "min_lat": 48.8530,
        "min_lng": 2.2945,
        "max_lat": 48.8738,
        "max_lng": 2.3499,
        "center_lat": 48.8634,
        "center_lng": 2.3222
    }
```

    **Null Response (no places):**
```json
    null
```

    **Errors:**
    - 401: Not authenticated
    - 403: Trip is private and user is not owner
    - 404: Trip not found

    **Business Logic:**
    - Calculates bounding box from all places in trip
    - Returns null if trip has no places
    - Access control based on trip visibility
    - Useful for auto-centering map on trip
    - Center is simple average of bounds (not geographic centroid)

    **Use Cases:**
    - Auto-fit map to show all places in trip
    - Calculate zoom level for trip map view
    - Determine trip geographic span
    """
    service = TripService(db)

    # Get trip to check access
    trip = service.get_trip_by_id(trip_id)
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    # Access control
    is_owner = trip.user_id == current_user.id
    if not is_owner and trip.visibility == "private":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this trip"
        )

    # Calculate bounds
    bounds = service.calculate_trip_bounds(trip_id)

    return bounds
