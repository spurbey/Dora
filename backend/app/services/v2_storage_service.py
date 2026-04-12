"""
Provider-neutral storage adapter contract for V2 commit finalize.
"""

from dataclasses import dataclass
from uuid import UUID


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
    BUCKET = "tracking-v2"

    def build_upload_target(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_commit_token: str,
        client_media_id: str,
    ) -> V2UploadTarget:
        object_key = f"{user_id}/{trip_id}/{session_commit_token}/{client_media_id}"
        storage_ref = f"storage://{self.STORAGE_PROVIDER}/{self.BUCKET}/{object_key}"
        return V2UploadTarget(
            client_media_id=client_media_id,
            storage_provider=self.STORAGE_PROVIDER,
            storage_ref=storage_ref,
            bucket=self.BUCKET,
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
        return expected.storage_ref == storage_ref
