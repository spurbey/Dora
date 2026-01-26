"""
MediaFile model for photo/video metadata.

Stores metadata for media files uploaded to Supabase Storage.
Actual files stored in Supabase Storage bucket, this table tracks metadata.
"""

from sqlalchemy import Column, String, Text, Integer, BigInteger, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class MediaFile(Base):
    """
    Media file metadata model.
    
    Attributes:
        id: UUID primary key
        user_id: Owner user ID (foreign key to users)
        trip_place_id: Associated place ID (foreign key to trip_places)
        file_url: Full URL to file in Supabase Storage
        file_type: Type of media (photo or video)
        file_size_bytes: Size of file in bytes
        mime_type: MIME type (image/jpeg, image/png, etc.)
        width: Image/video width in pixels (optional)
        height: Image/video height in pixels (optional)
        thumbnail_url: URL to thumbnail version
        caption: User-provided caption (optional)
        taken_at: When photo/video was taken (optional)
        created_at: When record was created
        
    Business Rules:
        - Files stored in Supabase Storage: photos/{user_id}/{uuid}.{ext}
        - Only owner can upload/delete media
        - Media must belong to a place the user owns
        - File type must be photo or video
        
    Relationships:
        - Belongs to User (cascade delete when user deleted)
        - Belongs to TripPlace (cascade delete when place deleted)
    """
    
    __tablename__ = "media_files"
    
    # Primary key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Media file ID"
    )
    
    # Foreign keys
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Owner user ID"
    )
    trip_place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Associated place ID"
    )
    
    # File metadata
    file_url = Column(
        Text,
        nullable=False,
        comment="Full URL to file in Supabase Storage"
    )
    file_type = Column(
        String(20),
        nullable=False,
        comment="Type: photo or video"
    )
    file_size_bytes = Column(
        BigInteger,
        comment="File size in bytes"
    )
    mime_type = Column(
        String(100),
        comment="MIME type (image/jpeg, image/png, video/mp4, etc.)"
    )
    
    # Image/video dimensions
    width = Column(
        Integer,
        comment="Width in pixels"
    )
    height = Column(
        Integer,
        comment="Height in pixels"
    )
    
    # Thumbnails and captions
    thumbnail_url = Column(
        Text,
        comment="URL to thumbnail (for photos)"
    )
    caption = Column(
        Text,
        comment="User-provided caption"
    )
    
    # Timestamps
    taken_at = Column(
        DateTime(timezone=True),
        comment="When photo/video was taken"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="When record was created"
    )
    
    def __repr__(self):
        return f"<MediaFile(id={self.id}, type={self.file_type}, place_id={self.trip_place_id})>"