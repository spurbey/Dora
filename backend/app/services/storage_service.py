"""
Storage service for Supabase Storage operations.

Handles:
    - File uploads to Supabase Storage buckets
    - File deletion from storage
    - Public URL generation
    - File validation (type, size)
"""

import re
from urllib.parse import urlparse

from supabase import create_client, Client
from fastapi import UploadFile, HTTPException, status
from typing import Optional
from uuid import UUID, uuid4

from app.config import settings


JWT_COMPATIBLE_SUPABASE_KEY_RE = re.compile(
    r"^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$"
)


def _strip_wrapping_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def _normalize_secret(value: str) -> tuple[str, bool]:
    trimmed = value.strip()
    unquoted = _strip_wrapping_quotes(trimmed)
    return unquoted, unquoted != value


def _normalize_url(value: str) -> tuple[str, bool]:
    trimmed = value.strip()
    unquoted = _strip_wrapping_quotes(trimmed)
    normalized = unquoted.rstrip("/")
    return normalized, normalized != value


def detect_supabase_key_format(value: str) -> str:
    if not value:
        return "empty"
    if value.startswith("sb_secret_"):
        return "sb_secret"
    if JWT_COMPATIBLE_SUPABASE_KEY_RE.match(value):
        return "jwt"
    return "invalid"


def validate_supabase_runtime_configuration(
    *,
    environment: str,
    supabase_url: str,
    service_role_key: str,
    strict: bool,
) -> dict[str, str | bool]:
    """
    Validate runtime Supabase settings used by the Python storage client.

    Returns non-sensitive diagnostics for observability and raises RuntimeError
    in strict mode when configuration is incompatible.
    """
    normalized_url, url_sanitized = _normalize_url(supabase_url or "")
    normalized_key, key_sanitized = _normalize_secret(service_role_key or "")
    parsed_url = urlparse(normalized_url) if normalized_url else None
    url_is_valid = bool(parsed_url and parsed_url.scheme in {"http", "https"} and parsed_url.netloc)
    key_format = detect_supabase_key_format(normalized_key)

    diagnostics: dict[str, str | bool] = {
        "environment": environment,
        "supabase_host": parsed_url.netloc if parsed_url else "",
        "url_valid": url_is_valid,
        "key_format": key_format,
        "url_sanitized": url_sanitized,
        "key_sanitized": key_sanitized,
    }

    if strict:
        errors: list[str] = []
        if not url_is_valid:
            errors.append("SUPABASE_URL must be a valid http(s) URL")
        if key_format == "empty":
            errors.append("SUPABASE_SERVICE_ROLE_KEY is missing")
        elif key_format == "sb_secret":
            errors.append(
                "SUPABASE_SERVICE_ROLE_KEY uses sb_secret format, but backend currently uses supabase-py "
                "validation that requires JWT-style keys"
            )
        elif key_format != "jwt":
            errors.append("SUPABASE_SERVICE_ROLE_KEY has invalid format")
        if errors:
            raise RuntimeError("; ".join(errors))

    return diagnostics


class StorageConfigurationError(RuntimeError):
    """Raised when storage client configuration is missing or invalid."""


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

        normalized_url, _ = _normalize_url(settings.SUPABASE_URL or "")
        normalized_key, _ = _normalize_secret(settings.SUPABASE_SERVICE_ROLE_KEY or "")
        key_format = detect_supabase_key_format(normalized_key)

        if not normalized_key:
            raise StorageConfigurationError(
                "SUPABASE_SERVICE_ROLE_KEY is missing in environment"
            )

        if key_format != "jwt":
            raise StorageConfigurationError(
                "SUPABASE_SERVICE_ROLE_KEY format is not compatible with current backend storage client"
            )

        try:
            self.supabase: Client = create_client(
                normalized_url,
                normalized_key
            )
        except Exception as exc:
            raise StorageConfigurationError(
                "Failed to initialize Supabase storage client"
            ) from exc
    
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
        max_size_mb: int = 10,
        contents: Optional[bytes] = None,
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
        
        # Read file contents if caller didn't provide preloaded bytes.
        # This allows upstream services to avoid duplicate full-file reads.
        if contents is None:
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

    def build_thumbnail_url(
        self,
        base_url: str,
        width: int = 200,
        height: int = 200
    ) -> str:
        """
        Build thumbnail URL with Supabase image transformations.

        Args:
            base_url: Base URL (public or signed)
            width: Thumbnail width in pixels
            height: Thumbnail height in pixels

        Returns:
            str: URL with transformation parameters
        """
        separator = "&" if "?" in base_url else "?"
        return f"{base_url}{separator}width={width}&height={height}"

    def get_signed_url(
        self,
        bucket: str,
        file_path: str,
        expires_in: int = 3600
    ) -> str:
        """
        Get signed URL for private access.

        Args:
            bucket: Storage bucket name
            file_path: File path within bucket
            expires_in: Expiration time in seconds

        Returns:
            str: Signed URL
        """
        try:
            response = self.supabase.storage.from_(bucket).create_signed_url(
                file_path,
                expires_in
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Signed URL generation failed: {str(e)}"
            )

        signed_url = None
        if isinstance(response, dict):
            signed_url = (
                response.get("signedURL")
                or response.get("signedUrl")
                or response.get("signed_url")
            )
        elif isinstance(response, str):
            signed_url = response

        if not signed_url:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Signed URL generation failed"
            )

        return signed_url
    
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
        return self.build_thumbnail_url(base_url, width=width, height=height)
