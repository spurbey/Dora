"""
Pydantic schemas for media operations.

Schemas for media upload, retrieval, and management.
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from uuid import UUID


class MediaBase(BaseModel):
    """
    Base media schema with common fields.
    
    Attributes:
        caption: User-provided caption (optional)
        taken_at: When photo/video was taken (optional)
    """
    caption: Optional[str] = Field(None, max_length=500)
    taken_at: Optional[datetime] = None


class MediaCreate(MediaBase):
    """
    Media creation schema (via form data).
    
    Note: File itself is sent as multipart/form-data UploadFile.
    This schema is for the metadata fields.
    
    Attributes:
        trip_place_id: Place to attach media to (required)
        caption: Photo/video caption (optional)
        taken_at: When photo/video was taken (optional)
        
    Business Logic:
        - User must own the place
        - File uploaded separately as UploadFile
    """
    trip_place_id: UUID = Field(..., description="Place ID to attach media to")


class MediaResponse(BaseModel):
    """
    Media response schema.
    
    Attributes:
        id: Media file UUID
        user_id: Owner user ID
        trip_place_id: Associated place ID
        file_url: Full URL to file in Supabase Storage
        file_type: Type (photo or video)
        file_size_bytes: File size in bytes
        mime_type: MIME type
        width: Image/video width in pixels
        height: Image/video height in pixels
        thumbnail_url: URL to thumbnail (200x200)
        caption: User caption
        taken_at: When photo/video was taken
        created_at: When uploaded
        
    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    id: UUID
    user_id: UUID
    trip_place_id: UUID
    file_url: str
    file_type: str
    file_size_bytes: Optional[int] = None
    mime_type: Optional[str] = None
    width: Optional[int] = None
    height: Optional[int] = None
    thumbnail_url: Optional[str] = None
    caption: Optional[str] = None
    taken_at: Optional[datetime] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class MediaListResponse(BaseModel):
    """
    List of media files (for a place or trip).
    
    Attributes:
        media: List of media files
        total: Total number of media files
        place_id: Associated place ID (optional, for context)
    """
    media: list[MediaResponse]
    total: int
    place_id: Optional[UUID] = None