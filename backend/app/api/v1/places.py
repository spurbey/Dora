"""
Place CRUD endpoints.

Endpoints:
    - POST /places: Create new place in a trip
    - GET /places: List places for a trip
    - GET /places/{id}: Get place detail
    - PATCH /places/{id}: Update place
    - DELETE /places/{id}: Delete place
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import Optional

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.schemas.place import PlaceCreate, PlaceUpdate, PlaceResponse, PlaceListResponse
from app.services.place_service import PlaceService


router = APIRouter(prefix="/places", tags=["Places"])


@router.post("", response_model=PlaceResponse, status_code=status.HTTP_201_CREATED)
async def create_place(
    place_data: PlaceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create a new place in a trip.

    **Authentication:** Required

    **Permissions:** User must own the trip

    **Request Body:**
    - trip_id: Parent trip ID (required)
    - name: Place name (required, 1-255 chars)
    - lat: Latitude (required, -90 to 90)
    - lng: Longitude (required, -180 to 180)
    - place_type: Category (restaurant, hotel, attraction, etc.)
    - user_notes: Personal notes
    - user_rating: Rating 1-5 (optional)
    - visit_date: Date of visit (optional)
    - order_in_trip: Position in itinerary (optional, auto-set if not provided)

    **Returns:**
    Created place with generated ID

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "trip_id": "987e6543-e21b-12d3-a456-426614174000",
        "user_id": "456e7890-e12b-12d3-a456-426614174000",
        "name": "Eiffel Tower",
        "place_type": "attraction",
        "lat": 48.8584,
        "lng": 2.2945,
        "user_notes": "Must visit at night!",
        "user_rating": 5,
        "visit_date": "2025-06-15",
        "photos": [],
        "videos": [],
        "order_in_trip": 0,
        "created_at": "2025-01-25T10:30:00Z",
        "updated_at": "2025-01-25T10:30:00Z"
    }
```

    **Errors:**
    - 400: Invalid coordinates or rating
    - 401: Not authenticated
    - 403: User does not own trip
    - 404: Trip not found

    **Business Logic:**
    - user_id is automatically set from authenticated user
    - lat/lng converted to PostGIS Geography POINT (SRID=4326;POINT(lng lat))
    - If order_in_trip not provided, auto-set to max + 1
    - Trip ownership validated before creation
    """
    service = PlaceService(db)
    place = service.create_place(current_user.id, place_data)
    return PlaceResponse.model_validate(place)


@router.get("", response_model=PlaceListResponse)
async def list_places(
    trip_id: UUID = Query(..., description="Trip ID to list places for"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    List all places for a trip.

    **Authentication:** Required

    **Permissions:**
    - Trip owner can always view
    - Non-owner can view if trip is public/unlisted

    **Query Parameters:**
    - trip_id: Trip ID (required)

    **Returns:**
    List of places ordered by order_in_trip (itinerary order)

    **Response Example:**
```json
    {
        "places": [
            {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "name": "Eiffel Tower",
                "lat": 48.8584,
                "lng": 2.2945,
                "order_in_trip": 0,
                ...
            },
            {
                "id": "987e6543-e21b-12d3-a456-426614174000",
                "name": "Louvre Museum",
                "lat": 48.8606,
                "lng": 2.3376,
                "order_in_trip": 1,
                ...
            }
        ],
        "total": 2,
        "trip_id": "987e6543-e21b-12d3-a456-426614174000"
    }
```

    **Errors:**
    - 401: Not authenticated
    - 403: Trip is private and user is not owner
    - 404: Trip not found

    **Business Logic:**
    - Access control based on trip visibility
    - Results ordered by order_in_trip ASC (itinerary order)
    - Empty list if trip has no places
    """
    service = PlaceService(db)
    result = service.list_trip_places(trip_id, current_user.id)
    return result


@router.get("/nearby", response_model=PlaceListResponse)
async def get_nearby_places(
    lat: float = Query(..., description="Search center latitude"),
    lng: float = Query(..., description="Search center longitude"),
    radius: float = Query(5.0, ge=0.1, le=50.0, description="Search radius in kilometers"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Find places near a location using PostGIS spatial query.

    **Authentication:** Required

    **Query Parameters:**
    - lat: Center latitude (required, -90 to 90)
    - lng: Center longitude (required, -180 to 180)
    - radius: Search radius in km (default: 5.0, max: 50.0)

    **Returns:**
    List of user's places within radius, ordered by distance

    **Response Example:**
```json
    {
        "places": [
            {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "name": "Eiffel Tower",
                "lat": 48.8584,
                "lng": 2.2945,
                "distance_km": 0.0,
                ...
            },
            {
                "id": "987e6543-e21b-12d3-a456-426614174000",
                "name": "Arc de Triomphe",
                "lat": 48.8738,
                "lng": 2.2950,
                "distance_km": 2.1,
                ...
            }
        ],
        "total": 2,
        "search_center": {"lat": 48.8584, "lng": 2.2945},
        "radius_km": 5.0
    }
```

    **Errors:**
    - 400: Invalid coordinates or radius
    - 401: Not authenticated

    **Business Logic:**
    - Only returns current user's places
    - Uses PostGIS ST_DWithin for efficient spatial search
    - Results ordered by distance (closest first)
    - Maximum radius capped at 50km
    - Uses GIST spatial index for fast queries

    **PostGIS Query:**
    - ST_DWithin: Find places within radius
    - ST_Distance: Calculate distance for ordering
    - Geography type: Accurate ellipsoidal calculations
    """
    service = PlaceService(db)

    # Get places within radius (already filtered by user_id)
    places = service.get_places_near_location(
        lat=lat,
        lng=lng,
        radius_km=radius,
        user_id=current_user.id
    )

    return PlaceListResponse(
        places=[PlaceResponse.model_validate(place) for place in places],
        total=len(places),
        trip_id=None  # Not filtering by trip
    )


@router.get("/{place_id}", response_model=PlaceResponse)
async def get_place(
    place_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get place detail by ID.

    **Authentication:** Required

    **Permissions:**
    - Trip owner can always view
    - Non-owner can view if trip is public/unlisted
    - Private trips only visible to owner

    **Path Parameters:**
    - place_id: Place UUID

    **Returns:**
    Place details with photos and metadata

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "trip_id": "987e6543-e21b-12d3-a456-426614174000",
        "user_id": "456e7890-e12b-12d3-a456-426614174000",
        "name": "Eiffel Tower",
        "place_type": "attraction",
        "lat": 48.8584,
        "lng": 2.2945,
        "user_notes": "Visited at sunset - amazing views!",
        "user_rating": 5,
        "visit_date": "2025-06-15",
        "photos": [
            {"url": "https://...", "caption": "From the top", "order": 0}
        ],
        "videos": [],
        "order_in_trip": 0,
        "created_at": "2025-01-25T10:30:00Z",
        "updated_at": "2025-01-25T10:30:00Z"
    }
```

    **Errors:**
    - 401: Not authenticated
    - 403: Trip is private and user is not owner
    - 404: Place not found

    **Business Logic:**
    - Access control based on parent trip's visibility
    - Returns full place data including photos/videos
    """
    service = PlaceService(db)

    # Fetch place
    place = service.get_place_by_id(place_id)
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Place not found"
        )

    # Check access via parent trip
    trip = db.query(Trip).filter(Trip.id == place.trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent trip not found"
        )

    # Access control
    is_owner = trip.user_id == current_user.id
    if not is_owner and trip.visibility == "private":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this place"
        )

    return PlaceResponse.model_validate(place)


@router.patch("/{place_id}", response_model=PlaceResponse)
async def update_place(
    place_id: UUID,
    place_update: PlaceUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update an existing place.

    **Authentication:** Required

    **Permissions:** Only trip owner can update

    **Path Parameters:**
    - place_id: Place UUID

    **Request Body:**
    All fields are optional (partial update):
    - name: New place name (1-255 chars)
    - place_type: New category
    - lat: New latitude (-90 to 90)
    - lng: New longitude (-180 to 180)
    - user_notes: New notes
    - user_rating: New rating (1-5)
    - visit_date: New visit date
    - order_in_trip: New position in itinerary

    **Returns:**
    Updated place

    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "name": "Eiffel Tower - Updated",
        "user_notes": "Updated notes",
        ...
    }
```

    **Errors:**
    - 400: Invalid coordinates or rating
    - 401: Not authenticated
    - 403: User does not own trip
    - 404: Place not found

    **Business Logic:**
    - Only updates provided fields (partial update)
    - Ownership check prevents unauthorized updates
    - If lat/lng updated, Geography column automatically recalculated
    - Cannot update trip_id or user_id
    - updated_at timestamp automatically updated
    """
    service = PlaceService(db)
    updated_place = service.update_place(place_id, current_user.id, place_update)
    return PlaceResponse.model_validate(updated_place)


@router.delete("/{place_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_place(
    place_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete a place.

    **Authentication:** Required

    **Permissions:** Only trip owner can delete

    **Path Parameters:**
    - place_id: Place UUID

    **Returns:**
    204 No Content on success

    **Errors:**
    - 401: Not authenticated
    - 403: User does not own trip
    - 404: Place not found

    **Business Logic:**
    - Ownership check prevents unauthorized deletion
    - Permanent deletion (no soft delete)
    - Order gaps are okay (reordering is separate operation)

    **Warning:**
    - This action is irreversible
    - Place data including photos metadata will be deleted
    """
    service = PlaceService(db)
    service.delete_place(place_id, current_user.id)
    # No return value for 204 No Content
