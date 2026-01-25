"""
Storage service for Supabase Storage operations.

Handles:
    - File uploads to Supabase Storage buckets
    - File deletion from storage
    - Public URL generation
    - File validation (type, size)
"""

from supabase import create_client, Client
from fastapi import UploadFile, HTTPException, status
from typing import Optional
from uuid import UUID, uuid4

from app.config import settings


class StorageService:
    """
    Service layer for Supabase Storage operations.
    
    Attributes:
        supabase: Supabase client instance
        
    Methods:
        upload_file: Upload file to storage bucket
        delete_file: Delete file from storage
        get_public_url: Get public URL for file
        _validate_file_type: Validate file MIME type
        _validate_file_size: Validate file size limits
    """
    
    def __init__(self):
        """
        Initialize storage service with Supabase client.
        
        Uses credentials from settings (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY).
        """

        if not settings.SUPABASE_SERVICE_ROLE_KEY:
            raise RuntimeError(
                "SUPABASE_SERVICE_ROLE_KEY is missing in environment"
            )

        # CHANGED: use service role key
        self.supabase: Client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_ROLE_KEY
        )
    
    def _validate_file_type(self, file: UploadFile, allowed_types: list[str]) -> None:
        """
        Validate file MIME type.
        
        Args:
            file: Uploaded file
            allowed_types: List of allowed MIME types
            
        Raises:
            HTTPException 400: If file type not allowed
            
        Example:
            _validate_file_type(file, ["image/jpeg", "image/png"])
        """
        if file.content_type not in allowed_types:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid file type. Allowed types: {', '.join(allowed_types)}"
            )
    
    def _validate_file_size(
        self, 
        file_size: int, 
        max_size_mb: int,
        is_premium: bool = False
    ) -> None:
        """
        Validate file size based on user tier.
        
        Args:
            file_size: File size in bytes
            max_size_mb: Maximum size in MB for free tier
            is_premium: Whether user is premium
            
        Raises:
            HTTPException 400: If file too large
            
        Business Rules:
            - Free tier: max_size_mb limit (default 10MB for photos)
            - Premium tier: 10x limit (100MB for photos)
        """
        max_bytes = max_size_mb * 1024 * 1024
        
        # Premium users get 10x limit
        if is_premium:
            max_bytes *= 10
        
        if file_size > max_bytes:
            tier = "Premium" if is_premium else "Free"
            max_mb = (max_bytes / 1024 / 1024)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{tier} tier file size limit: {max_mb:.0f}MB. Your file: {file_size / 1024 / 1024:.1f}MB"
            )
    
    async def upload_file(
        self,
        file: UploadFile,
        bucket: str,
        user_id: UUID,
        is_premium: bool = False,
        allowed_types: Optional[list[str]] = None,
        max_size_mb: int = 10
    ) -> str:
        """
        Upload file to Supabase Storage.
        
        Args:
            file: File to upload
            bucket: Storage bucket name (e.g., "photos")
            user_id: User UUID (for folder organization)
            is_premium: Whether user has premium subscription
            allowed_types: List of allowed MIME types
            max_size_mb: Max file size in MB (free tier)
            
        Returns:
            str: Public URL of uploaded file
            
        Raises:
            HTTPException 400: Invalid file type or size
            HTTPException 500: Upload failed
            
        File Structure:
            {bucket}/{user_id}/{uuid}.{ext}
            
        Example:
            photos/123e4567-e89b-12d3-a456-426614174000/a1b2c3d4.jpg
        """
        # Default allowed types for images
        if allowed_types is None:
            allowed_types = ["image/jpeg", "image/png", "image/webp"]
        
        # Validate file type
        self._validate_file_type(file, allowed_types)
        
        # Read file contents
        contents = await file.read()
        file_size = len(contents)
        
        # Validate file size
        self._validate_file_size(file_size, max_size_mb, is_premium)

        if file_size == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty"
            )
        
        # Generate unique filename
        ext = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        unique_filename = f"{uuid4()}.{ext}"
        
        # Construct file path
        file_path = f"{user_id}/{unique_filename}"
        
        try:
            # Upload to Supabase Storage
            self.supabase.storage.from_(bucket).upload(
                path=file_path,
                file=contents,
                file_options={
                    "content-type": file.content_type,
                    "cache-control": "3600",
                    "upsert": "false"
                }
            )
            
            url = self.get_public_url(bucket, file_path)
            
            return url
            
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"File upload failed: {str(e)}"
            )
    
    def delete_file(self, bucket: str, file_path: str) -> None:
        """
        Delete file from Supabase Storage.
        
        Args:
            bucket: Storage bucket name
            file_path: File path within bucket (user_id/filename)
            
        Raises:
            HTTPException 500: Deletion failed
            
        Example:
            delete_file("photos", "123e4567.../a1b2c3d4.jpg")
        """
        try:
            self.supabase.storage.from_(bucket).remove([file_path])
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"File deletion failed: {str(e)}"
            )
    
    def get_public_url(self, bucket: str, file_path: str) -> str:
        """
        Get public URL for file.
        
        Args:
            bucket: Storage bucket name
            file_path: File path within bucket
            
        Returns:
            str: Public URL
            
        Example URL:
            https://xxxxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg
        """
        response = self.supabase.storage.from_(bucket).get_public_url(file_path)

        # CHANGED: remove trailing "?"
        return response.rstrip("?") if response.endswith("?") else response
    
    def get_thumbnail_url(
        self, 
        bucket: str, 
        file_path: str, 
        width: int = 200, 
        height: int = 200
    ) -> str:
        """
        Get thumbnail URL with Supabase image transformations.
        
        Args:
            bucket: Storage bucket name
            file_path: File path within bucket
            width: Thumbnail width in pixels
            height: Thumbnail height in pixels
            
        Returns:
            str: URL with transformation parameters
            
        Example:
            https://.../photos/file.jpg?width=200&height=200
            
        Note:
            Supabase automatically generates thumbnails on-the-fly.
        """
        base_url = self.get_public_url(bucket, file_path)

        # CHANGED: avoid ??
        separator = "&" if "?" in base_url else "?"

        return f"{base_url}{separator}width={width}&height={height}"
