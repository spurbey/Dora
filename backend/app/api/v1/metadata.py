"""
Metadata CRUD endpoints for trips and places.

Endpoints:
    Trip Metadata:
    - POST /trips/{trip_id}/metadata: Create trip metadata
    - GET /trips/{trip_id}/metadata: Get trip metadata
    - PATCH /trips/{trip_id}/metadata: Update trip metadata
    - DELETE /trips/{trip_id}/metadata: Delete trip metadata

    Place Metadata:
    - POST /places/{place_id}/metadata: Create place metadata
    - GET /places/{place_id}/metadata: Get place metadata
    - PATCH /places/{place_id}/metadata: Update place metadata
    - DELETE /places/{place_id}/metadata: Delete place metadata
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.trip_metadata import TripMetadata
from app.models.place_metadata import PlaceMetadata
from app.schemas.trip_metadata import TripMetadataCreate, TripMetadataUpdate, TripMetadataResponse
from app.schemas.place_metadata import PlaceMetadataCreate, PlaceMetadataUpdate, PlaceMetadataResponse


router = APIRouter(tags=["Metadata"])


# ============================================================================
# TRIP METADATA ENDPOINTS
# ============================================================================

@router.post("/trips/{trip_id}/metadata", response_model=TripMetadataResponse, status_code=status.HTTP_201_CREATED)
async def create_trip_metadata(
    trip_id: UUID,
    metadata_data: TripMetadataCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create metadata for a trip.

    **Authentication:** Required

    **Permissions:** Trip owner only

    **Request Body:**
    - traveler_type: Array of traveler types (solo, couple, family, group)
    - age_group: Target age group (gen-z, millennial, gen-x, boomer)
    - travel_style: Array of travel styles (adventure, luxury, budget, cultural, relaxed)
    - difficulty_level: Overall difficulty (easy, moderate, challenging, extreme)
    - budget_category: Budget level (budget, mid-range, luxury)
    - activity_focus: Array of activity types (hiking, food, photography, nightlife, beaches)
    - is_discoverable: Whether trip can be found in public search (default: false)
    - tags: User-defined tags

    **Returns:**
    Created trip metadata

    **Errors:**
    - 404: Trip not found
    - 403: User doesn't own this trip
    - 409: Metadata already exists (use PATCH to update)
    - 422: Invalid enum values
    """
    # Check trip exists and user owns it
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    if trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this trip"
        )

    # Check metadata doesn't already exist
    existing_metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == trip_id).first()
    if existing_metadata:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Metadata already exists for this trip. Use PATCH to update."
        )

    # Create metadata
    metadata = TripMetadata(
        trip_id=trip_id,
        **metadata_data.model_dump()
    )
    db.add(metadata)
    db.commit()
    db.refresh(metadata)

    return TripMetadataResponse.model_validate(metadata)


@router.get("/trips/{trip_id}/metadata", response_model=TripMetadataResponse)
async def get_trip_metadata(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get metadata for a trip.

    **Authentication:** Required

    **Permissions:**
    - Trip owner: Always allowed
    - Others: Only if trip is public or unlisted

    **Returns:**
    Trip metadata

    **Errors:**
    - 404: Trip or metadata not found
    - 403: Trip is private and user is not owner
    """
    # Check trip exists
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )

    # Check access permissions
    is_owner = trip.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Trip is private and you are not the owner"
        )

    # Get metadata
    metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == trip_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this trip"
        )

    return TripMetadataResponse.model_validate(metadata)


@router.patch("/trips/{trip_id}/metadata", response_model=TripMetadataResponse)
async def update_trip_metadata(
    trip_id: UUID,
    metadata_data: TripMetadataUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update metadata for a trip (partial update).

    **Authentication:** Required

    **Permissions:** Trip owner only

    **Request Body:**
    All fields are optional. Only provided fields will be updated.

    **Returns:**
    Updated trip metadata

    **Errors:**
    - 404: Trip or metadata not found
    - 403: User doesn't own this trip
    - 422: Invalid enum values
    """
    # Check trip exists and user owns it
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    if trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this trip"
        )

    # Get metadata
    metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == trip_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this trip"
        )

    # Update only provided fields
    update_data = metadata_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(metadata, field, value)

    db.commit()
    db.refresh(metadata)

    return TripMetadataResponse.model_validate(metadata)


@router.delete("/trips/{trip_id}/metadata", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip_metadata(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete metadata for a trip.

    **Authentication:** Required

    **Permissions:** Trip owner only

    **Returns:**
    204 No Content on success

    **Errors:**
    - 404: Trip or metadata not found
    - 403: User doesn't own this trip

    **Note:**
    Trip itself is NOT deleted, only its metadata.
    """
    # Check trip exists and user owns it
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    if trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this trip"
        )

    # Get and delete metadata
    metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == trip_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this trip"
        )

    db.delete(metadata)
    db.commit()


# ============================================================================
# PLACE METADATA ENDPOINTS
# ============================================================================

@router.post("/places/{place_id}/metadata", response_model=PlaceMetadataResponse, status_code=status.HTTP_201_CREATED)
async def create_place_metadata(
    place_id: UUID,
    metadata_data: PlaceMetadataCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Create metadata for a place.

    **Authentication:** Required

    **Permissions:** Place owner only

    **Request Body:**
    - component_type: Type of component (city, place, activity, accommodation, food, transport)
    - experience_tags: Array of experience descriptors
    - best_for: Array of audience types
    - budget_per_person: Estimated cost per person (USD)
    - duration_hours: Recommended time to spend (hours)
    - difficulty_rating: Physical difficulty (1-5)
    - physical_demand: Physical demand level (low, medium, high)
    - best_time: Optimal time to visit
    - is_public: Whether place can be discovered publicly (default: false)

    **Returns:**
    Created place metadata

    **Errors:**
    - 404: Place not found
    - 403: User doesn't own this place
    - 409: Metadata already exists (use PATCH to update)
    - 422: Invalid enum values or ranges
    """
    # Check place exists and user owns it
    place = db.query(TripPlace).filter(TripPlace.id == place_id).first()
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Place not found"
        )
    if place.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this place"
        )

    # Check metadata doesn't already exist
    existing_metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == place_id).first()
    if existing_metadata:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Metadata already exists for this place. Use PATCH to update."
        )

    # Create metadata
    metadata = PlaceMetadata(
        place_id=place_id,
        **metadata_data.model_dump()
    )
    db.add(metadata)
    db.commit()
    db.refresh(metadata)

    return PlaceMetadataResponse.model_validate(metadata)


@router.get("/places/{place_id}/metadata", response_model=PlaceMetadataResponse)
async def get_place_metadata(
    place_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get metadata for a place.

    **Authentication:** Required

    **Permissions:**
    - Place owner: Always allowed
    - Others: Only if parent trip is public or unlisted

    **Returns:**
    Place metadata

    **Errors:**
    - 404: Place or metadata not found
    - 403: Trip is private and user is not owner
    """
    # Check place exists
    place = db.query(TripPlace).filter(TripPlace.id == place_id).first()
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Place not found"
        )

    # Get parent trip for access check
    trip = db.query(Trip).filter(Trip.id == place.trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent trip not found"
        )

    # Check access permissions
    is_owner = place.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Trip is private and you are not the owner"
        )

    # Get metadata
    metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == place_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this place"
        )

    return PlaceMetadataResponse.model_validate(metadata)


@router.patch("/places/{place_id}/metadata", response_model=PlaceMetadataResponse)
async def update_place_metadata(
    place_id: UUID,
    metadata_data: PlaceMetadataUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update metadata for a place (partial update).

    **Authentication:** Required

    **Permissions:** Place owner only

    **Request Body:**
    All fields are optional. Only provided fields will be updated.

    **Returns:**
    Updated place metadata

    **Errors:**
    - 404: Place or metadata not found
    - 403: User doesn't own this place
    - 422: Invalid enum values or ranges
    """
    # Check place exists and user owns it
    place = db.query(TripPlace).filter(TripPlace.id == place_id).first()
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Place not found"
        )
    if place.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this place"
        )

    # Get metadata
    metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == place_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this place"
        )

    # Update only provided fields
    update_data = metadata_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(metadata, field, value)

    db.commit()
    db.refresh(metadata)

    return PlaceMetadataResponse.model_validate(metadata)


@router.delete("/places/{place_id}/metadata", status_code=status.HTTP_204_NO_CONTENT)
async def delete_place_metadata(
    place_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete metadata for a place.

    **Authentication:** Required

    **Permissions:** Place owner only

    **Returns:**
    204 No Content on success

    **Errors:**
    - 404: Place or metadata not found
    - 403: User doesn't own this place

    **Note:**
    Place itself is NOT deleted, only its metadata.
    """
    # Check place exists and user owns it
    place = db.query(TripPlace).filter(TripPlace.id == place_id).first()
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Place not found"
        )
    if place.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't own this place"
        )

    # Get and delete metadata
    metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == place_id).first()
    if not metadata:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Metadata not found for this place"
        )

    db.delete(metadata)
    db.commit()
