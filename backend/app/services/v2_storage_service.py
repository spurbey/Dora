"""
Provider-neutral storage adapter contract for V2 trip publish.
"""

from typing import Optional
from dataclasses import dataclass
from uuid import UUID

from fastapi import HTTPException

from app.config import settings
from app.services.storage_service import StorageConfigurationError, StorageService


@dataclass(frozen=True)
class V2UploadTarget:
    client_media_id: str
    storage_provider: str
    storage_ref: str
    bucket: str
    object_key: str


class V2StorageService:
    """Issue deterministic upload targets without coupling callers to Supabase URLs."""

    STORAGE_PROVIDER = "supabase"
    DEFAULT_BUCKET = "photos"

    def __init__(
        self,
        require_existence_check: Optional[bool] = None,
        bucket: Optional[str] = None,
    ):
        self.require_existence_check = (
            settings.V2_STORAGE_REQUIRE_EXISTENCE_CHECK
            if require_existence_check is None
            else bool(require_existence_check)
        )
        resolved_bucket = (bucket or settings.V2_STORAGE_BUCKET).strip()
        self.bucket = resolved_bucket if resolved_bucket else self.DEFAULT_BUCKET
        self._storage_service: Optional[StorageService] = None

    def build_upload_target(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_commit_token: str,
        client_media_id: str,
    ) -> V2UploadTarget:
        object_key = f"{user_id}/{trip_id}/{session_commit_token}/{client_media_id}"
        storage_ref = f"storage://{self.STORAGE_PROVIDER}/{self.bucket}/{object_key}"
        return V2UploadTarget(
            client_media_id=client_media_id,
            storage_provider=self.STORAGE_PROVIDER,
            storage_ref=storage_ref,
            bucket=self.bucket,
            object_key=object_key,
        )

    def verify_storage_ref(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_commit_token: str,
        client_media_id: str,
        storage_ref: str,
    ) -> bool:
        expected = self.build_upload_target(
            trip_id=trip_id,
            user_id=user_id,
            session_commit_token=session_commit_token,
            client_media_id=client_media_id,
        )
        if expected.storage_ref != storage_ref:
            return False
        if not self.require_existence_check:
            return True
        return self._storage_object_exists(
            bucket=expected.bucket,
            object_key=expected.object_key,
        )

    def _get_storage_service(self) -> StorageService:
        if self._storage_service is None:
            self._storage_service = StorageService()
        return self._storage_service

    def _storage_object_exists(self, *, bucket: str, object_key: str) -> bool:
        try:
            storage = self._get_storage_service()
        except StorageConfigurationError:
            return False
        try:
            signed_url = storage.get_signed_url(
                bucket=bucket,
                file_path=object_key,
                expires_in=60,
            )
            return bool(signed_url and signed_url.strip())
        except HTTPException:
            return False
        except Exception:
            return False
