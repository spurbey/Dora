"""
Media service layer for business logic.

Handles:
    - Media upload to Supabase Storage
    - Media metadata storage in database
    - Ownership validation
    - Media deletion (storage + database)
"""

from sqlalchemy.orm import Session
from fastapi import UploadFile, HTTPException, status
from typing import Optional
from uuid import UUID
from PIL import Image
from io import BytesIO

from app.models.media import MediaFile
from app.models.place import TripPlace
from app.models.trip import Trip
from app.schemas.media import MediaCreate, MediaResponse
from app.services.storage_service import StorageService


class MediaService:
    """
    Service layer for media operations.
    
    Attributes:
        db: Database session
        storage_service: Supabase Storage service
        
    Methods:
        upload_photo: Upload photo to storage and save metadata
        get_media_by_id: Get media by UUID
        delete_media: Delete media from storage and database
        _check_place_ownership: Validate user owns the place
        _get_image_dimensions: Extract width/height from image
    """
    
    def __init__(self, db: Session):
        """
        Initialize media service.
        
        Args:
            db: SQLAlchemy database session
        """
        self.db = db
        self.storage_service = StorageService()
    
    def _check_place_ownership(self, place_id: UUID, user_id: UUID) -> TripPlace:
        """
        Verify user owns the place (via trip ownership).
        
        Args:
            place_id: Place UUID
            user_id: User ID to check
            
        Returns:
            TripPlace object if ownership verified
            
        Raises:
            HTTPException 404: Place not found
            HTTPException 403: User does not own place's trip
            
        Security:
            - Prevents users from adding media to others' places
            - Must be called before any create/delete operation
        """
        place = self.db.query(TripPlace).filter(TripPlace.id == place_id).first()
        if not place:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Place not found"
            )
        
        # Check if user owns the trip (and thus the place)
        trip = self.db.query(Trip).filter(Trip.id == place.trip_id).first()
        if not trip or trip.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to add media to this place"
            )
        
        return place
    
    def _get_image_dimensions(self, file_bytes: bytes) -> tuple[Optional[int], Optional[int]]:
        """
        Extract image dimensions using PIL.
        
        Args:
            file_bytes: Image file bytes
            
        Returns:
            Tuple of (width, height) or (None, None) if extraction fails
            
        Note:
            Uses PIL to open image and read dimensions.
            Returns None for both if image cannot be opened.
        """
        try:
            img = Image.open(BytesIO(file_bytes))
            return img.width, img.height
        except Exception:
            return None, None
    
    async def upload_photo(
        self,
        file: UploadFile,
        user_id: UUID,
        media_data: MediaCreate,
        is_premium: bool = False
    ) -> MediaFile:
        """
        Upload photo to Supabase Storage and save metadata.
        
        Args:
            file: Uploaded file
            user_id: Owner user ID
            media_data: Media metadata (place_id, caption, taken_at)
            is_premium: Whether user is premium (affects file size limit)
            
        Returns:
            Created MediaFile object
            
        Raises:
            HTTPException 400: Invalid file type or size
            HTTPException 403: User does not own place
            HTTPException 404: Place not found
            HTTPException 500: Upload failed
            
        Business Logic:
            1. Validate user owns the place
            2. Upload file to Supabase Storage (validates type/size)
            3. Extract image dimensions
            4. Generate thumbnail URL
            5. Save metadata to database
            6. Return MediaFile object
            
        File Storage:
            - Bucket: photos
            - Path: {user_id}/{uuid}.{ext}
            - Thumbnail: Same URL with ?width=200&height=200
        """
        # Check place ownership
        place = self._check_place_ownership(media_data.trip_place_id, user_id)
        
        # Read file contents (needed for dimensions + storage)
        file_bytes = await file.read()
        await file.seek(0)  # Reset file pointer for storage service
        
        # Upload to Supabase Storage
        # This validates file type and size
        file_url = await self.storage_service.upload_file(
            file=file,
            bucket="photos",
            user_id=user_id,
            is_premium=is_premium,
            allowed_types=["image/jpeg", "image/png", "image/webp"],
            max_size_mb=10
        )
        
        # Extract file path from URL for thumbnail
        # URL: https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg
        file_path = file_url.split('/storage/v1/object/public/photos/')[1].split("?")[0]
        
        # Get image dimensions
        width, height = self._get_image_dimensions(file_bytes)
        
        # Generate thumbnail URL
        thumbnail_url = self.storage_service.get_thumbnail_url(
            bucket="photos",
            file_path=file_path,
            width=200,
            height=200
        )
        
        # Create media record
        media = MediaFile(
            user_id=user_id,
            trip_place_id=media_data.trip_place_id,
            file_url=file_url,
            file_type="photo",
            file_size_bytes=len(file_bytes),
            mime_type=file.content_type,
            width=width,
            height=height,
            thumbnail_url=thumbnail_url,
            caption=media_data.caption,
            taken_at=media_data.taken_at
        )
        
        self.db.add(media)
        self.db.commit()
        self.db.refresh(media)
        
        return media
    
    def get_media_by_id(self, media_id: UUID) -> Optional[MediaFile]:
        """
        Get media by ID.
        
        Args:
            media_id: Media UUID
            
        Returns:
            MediaFile object or None if not found
            
        Usage:
            Used by detail and delete endpoints.
            Caller is responsible for access control checks.
        """
        return self.db.query(MediaFile).filter(MediaFile.id == media_id).first()
    
    def delete_media(self, media_id: UUID, user_id: UUID) -> None:
        """
        Delete media from storage and database.
        
        Args:
            media_id: Media UUID
            user_id: User ID (for ownership check)
            
        Raises:
            HTTPException 404: Media not found
            HTTPException 403: User does not own media
            HTTPException 500: Deletion failed
            
        Business Logic:
            1. Fetch media by ID
            2. Check ownership
            3. Delete from Supabase Storage
            4. Delete from database
            
        Side Effects:
            - Deletes file from Supabase Storage bucket
            - Deletes media_files table row
        """
        # Fetch media
        media = self.get_media_by_id(media_id)
        if not media:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Media not found"
            )
        
        # Check ownership
        if media.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to delete this media"
            )
        
        # Extract file path from URL
        # URL: https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg
        try:
            file_path = media.file_url.split('/storage/v1/object/public/photos/')[1].split("?")[0]
            
            # Delete from Supabase Storage
            self.storage_service.delete_file("photos", file_path)
            
        except Exception as e:
            # Log error but continue with database deletion
            print(f"Warning: Failed to delete file from storage: {e}")
        
        # Delete from database
        self.db.delete(media)
        self.db.commit()