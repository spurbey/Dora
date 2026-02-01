"""
Media API endpoints.

Endpoints:
    - POST /media/upload: Upload photo to a place
    - GET /media/{id}: Get media detail
    - DELETE /media/{id}: Delete media
"""

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from uuid import UUID
from typing import Optional
from datetime import datetime

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.schemas.media import MediaCreate, MediaResponse
from app.services.media_service import MediaService


router = APIRouter(prefix="/media", tags=["Media"])


@router.post("/upload", response_model=MediaResponse, status_code=status.HTTP_201_CREATED)
async def upload_media(
    file: UploadFile = File(..., description="Photo file to upload"),
    trip_place_id: UUID = Form(..., description="Place ID to attach media to"),
    caption: Optional[str] = Form(None, description="Photo caption"),
    taken_at: Optional[datetime] = Form(None, description="When photo was taken (ISO format)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Upload photo to a place.
    
    **Authentication:** Required
    
    **Permissions:** User must own the place (via trip ownership)
    
    **Request:**
    - Content-Type: multipart/form-data
    - file: Image file (required)
    - trip_place_id: UUID of place (required)
    - caption: Photo caption (optional, max 500 chars)
    - taken_at: When photo was taken (optional, ISO datetime)
    
    **Returns:**
    Created media with file URLs
    
    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "user_id": "987e6543-e21b-12d3-a456-426614174000",
        "trip_place_id": "456e7890-e12b-12d3-a456-426614174000",
        "file_url": "https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg",
        "file_type": "photo",
        "file_size_bytes": 245678,
        "mime_type": "image/jpeg",
        "width": 1920,
        "height": 1080,
        "thumbnail_url": "https://xxx.supabase.co/.../file.jpg?width=200&height=200",
        "caption": "Beautiful sunset at Eiffel Tower",
        "taken_at": "2025-06-15T18:30:00Z",
        "created_at": "2025-01-26T10:00:00Z"
    }
```
    
    **Errors:**
    - 400: Invalid file type or size
    - 401: Not authenticated
    - 403: User does not own place
    - 404: Place not found
    
    **Business Logic:**
    - File stored in Supabase Storage: photos/{user_id}/{uuid}.{ext}
    - Thumbnail auto-generated via Supabase transformations
    - Image dimensions extracted via PIL
    - Free tier: max 10MB per photo
    - Premium tier: max 100MB per photo
    - Allowed types: image/jpeg, image/png, image/webp
    """
    service = MediaService(db)
    
    # Create media data object
    media_data = MediaCreate(
        trip_place_id=trip_place_id,
        caption=caption,
        taken_at=taken_at
    )
    
    # Upload photo
    media = await service.upload_photo(
        file=file,
        user_id=current_user.id,
        media_data=media_data,
        is_premium=current_user.is_premium
    )

    # Use build_media_response to include trip_id
    return service.build_media_response(media)


@router.get("/{media_id}", response_model=MediaResponse)
async def get_media(
    media_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get media detail by ID.
    
    **Authentication:** Required
    
    **Permissions:**
    - Owner can always view
    - Non-owner can view if trip is public/unlisted
    
    **Path Parameters:**
    - media_id: Media UUID
    
    **Returns:**
    Media details with file URLs
    
    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "user_id": "987e6543-e21b-12d3-a456-426614174000",
        "trip_place_id": "456e7890-e12b-12d3-a456-426614174000",
        "file_url": "https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg",
        "thumbnail_url": "https://xxx.supabase.co/.../file.jpg?width=200&height=200",
        "caption": "Beautiful sunset",
        "created_at": "2025-01-26T10:00:00Z"
    }
```
    
    **Errors:**
    - 401: Not authenticated
    - 403: Trip is private and user is not owner
    - 404: Media not found
    
    **Business Logic:**
    - Access control based on parent trip's visibility
    - Private trip media only visible to owner
    - Public/unlisted trip media visible to anyone
    """
    service = MediaService(db)
    
    # Fetch media
    media = service.get_media_by_id(media_id)
    if not media:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Media not found"
        )
    
    # Check access via parent trip
    # First get the place, then get the trip
    from app.models.place import TripPlace
    place = db.query(TripPlace).filter(TripPlace.id == media.trip_place_id).first()
    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent place not found"
        )

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
            detail="You do not have permission to view this media"
        )
    
    use_signed = trip.visibility == "private"
    return service.build_media_response(media, signed=use_signed)


@router.delete("/{media_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_media(
    media_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete media.
    
    **Authentication:** Required
    
    **Permissions:** Only owner can delete
    
    **Path Parameters:**
    - media_id: Media UUID
    
    **Returns:**
    204 No Content on success
    
    **Errors:**
    - 401: Not authenticated
    - 403: User does not own media
    - 404: Media not found
    
    **Business Logic:**
    - Ownership check prevents unauthorized deletion
    - Deletes file from Supabase Storage
    - Deletes metadata from database
    - Permanent deletion (no soft delete)
    
    **Warning:**
    - This action is irreversible
    - File will be deleted from storage
    """
    service = MediaService(db)
    service.delete_media(media_id, current_user.id)
    # No return value for 204 No Content
