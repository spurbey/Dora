"""
Stories service layer.
"""

from __future__ import annotations

import math
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID, uuid4

from fastapi import HTTPException, UploadFile, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.story import Story, StoryAuthorMute, StoryReport, StoryView
from app.services.storage_service import StorageConfigurationError, StorageService
from app.config import settings

PHOTO_MAX_BYTES = 10 * 1024 * 1024
VIDEO_MAX_BYTES = 100 * 1024 * 1024
VIDEO_MAX_DURATION_MS = 60_000
STORY_TTL_HOURS = 24
STORY_PURGE_GRACE_HOURS = 24
STORY_ROW_RETENTION_DAYS = 30

PHOTO_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/heic",
}
VIDEO_MIME_TYPES = {
    "video/mp4",
    "video/quicktime",
    "video/x-m4v",
}


class StoryService:
    def __init__(self, db: Session):
        self.db = db
        self._storage_service: Optional[StorageService] = None

    def _get_storage_service(self) -> StorageService:
        if self._storage_service is None:
            try:
                self._storage_service = StorageService()
            except StorageConfigurationError as exc:
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Storage service misconfigured",
                ) from exc
        return self._storage_service

    def _now(self) -> datetime:
        return datetime.now(timezone.utc)

    @property
    def _stories_bucket(self) -> str:
        return settings.STORIES_STORAGE_BUCKET.strip() or "stories"

    def _moderator_id_set(self) -> set[str]:
        raw = settings.STORIES_MODERATOR_USER_IDS.strip()
        if not raw:
            return set()
        return {item.strip() for item in raw.split(",") if item.strip()}

    def _is_moderator(self, user_id: UUID) -> bool:
        return str(user_id) in self._moderator_id_set()

    async def _read_upload_bytes_bounded(self, file: UploadFile, *, max_bytes: int) -> bytes:
        chunks: list[bytes] = []
        total = 0
        while True:
            chunk = await file.read(1024 * 1024)
            if not chunk:
                break
            total += len(chunk)
            if total > max_bytes:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Story media exceeds size cap",
                )
            chunks.append(chunk)
        if total == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty",
            )
        return b"".join(chunks)

    def _parse_storage_path(self, file_url: str, *, bucket: str) -> str:
        marker = f"/storage/v1/object/public/{bucket}/"
        if marker not in file_url:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Invalid story storage URL",
            )
        return file_url.split(marker, 1)[1].split("?", 1)[0]

    def _distance_km(self, *, lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        r = 6371.0
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = (
            math.sin(dlat / 2) ** 2
            + math.cos(math.radians(lat1))
            * math.cos(math.radians(lat2))
            * math.sin(dlng / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return r * c

    async def publish_story(
        self,
        *,
        user_id: UUID,
        client_story_id: str,
        media_type: str,
        center_lat: float,
        center_lng: float,
        file: UploadFile,
        duration_ms: Optional[int] = None,
    ) -> Story:
        media_type = media_type.strip().lower()
        if media_type not in {"photo", "video"}:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="media_type must be 'photo' or 'video'",
            )

        existing = (
            self.db.query(Story)
            .filter(
                Story.client_story_id == client_story_id,
                Story.author_user_id == user_id,
            )
            .first()
        )
        if existing is not None:
            return existing

        if media_type == "video":
            if duration_ms is not None and duration_ms > VIDEO_MAX_DURATION_MS:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Video must be 60 seconds or less",
                )
            allowed_types = VIDEO_MIME_TYPES
            max_bytes = VIDEO_MAX_BYTES
        else:
            allowed_types = PHOTO_MIME_TYPES
            max_bytes = PHOTO_MAX_BYTES

        content_type = (file.content_type or "").lower().strip()
        if content_type not in allowed_types:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported story media MIME type",
            )

        media_bytes = await self._read_upload_bytes_bounded(file, max_bytes=max_bytes)
        now = self._now()
        expires_at = now + timedelta(hours=STORY_TTL_HOURS)
        story_id = uuid4()
        ext = "jpg"
        if "." in (file.filename or ""):
            ext = (file.filename or "").rsplit(".", 1)[1].lower()
        elif content_type == "video/mp4":
            ext = "mp4"
        elif content_type == "video/quicktime":
            ext = "mov"
        elif content_type == "video/x-m4v":
            ext = "m4v"
        elif content_type == "image/png":
            ext = "png"
        elif content_type == "image/webp":
            ext = "webp"
        elif content_type == "image/heic":
            ext = "heic"

        object_path = f"{user_id}/{story_id}.{ext}"
        thumb_object_path = f"{user_id}/{story_id}_thumb.jpg"
        storage = self._get_storage_service()
        media_url = await storage.upload_file(
            file=file,
            bucket=self._stories_bucket,
            user_id=user_id,
            allowed_types=list(allowed_types),
            max_size_mb=100,
            contents=media_bytes,
            object_key=object_path,
            cache_control_seconds=86400,
        )
        thumbnail_url: Optional[str] = None
        thumbnail_path: Optional[str] = None

        if media_type == "photo":
            # For MVP, generate canonical thumbnail URL from source photo.
            thumbnail_url = storage.get_thumbnail_url(
                bucket=self._stories_bucket,
                file_path=object_path,
                width=360,
                height=640,
            )
            thumbnail_path = thumb_object_path

        story = Story(
            id=story_id,
            client_story_id=client_story_id,
            author_user_id=user_id,
            media_type=media_type,
            media_url=media_url,
            thumbnail_url=thumbnail_url,
            duration_ms=duration_ms if media_type == "video" else None,
            center_lat=center_lat,
            center_lng=center_lng,
            status="published",
            published_at=now,
            expires_at=expires_at,
            deleted_at=None,
            view_count=0,
            storage_object_path=object_path,
            thumbnail_object_path=thumbnail_path,
            created_at=now,
            updated_at=now,
        )
        self.db.add(story)
        self.db.commit()
        self.db.refresh(story)
        return story

    def list_feed(
        self,
        *,
        user_id: UUID,
        viewer_lat: Optional[float],
        viewer_lng: Optional[float],
        radius_km: Optional[float],
        cursor: Optional[str],
        limit: int,
    ) -> tuple[list[tuple[Story, Optional[float], bool]], Optional[str]]:
        now = self._now()
        offset = 0
        if cursor:
            try:
                offset = max(0, int(cursor))
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid cursor",
                )

        muted_author_ids = {
            row[0]
            for row in self.db.query(StoryAuthorMute.muted_author_id)
            .filter(StoryAuthorMute.user_id == user_id)
            .all()
        }

        q = (
            self.db.query(Story)
            .filter(
                Story.deleted_at.is_(None),
                Story.status == "published",
                Story.published_at.isnot(None),
                Story.expires_at.isnot(None),
                Story.expires_at > now,
            )
            .order_by(Story.published_at.desc(), Story.id.desc())
            .limit(500)
        )
        rows = q.all()

        filtered: list[tuple[Story, Optional[float], bool]] = []
        for row in rows:
            is_own = row.author_user_id == user_id
            if not is_own and row.author_user_id in muted_author_ids:
                continue
            distance_km: Optional[float] = None
            if not is_own and radius_km is not None:
                if viewer_lat is None or viewer_lng is None:
                    continue
                distance_km = self._distance_km(
                    lat1=viewer_lat,
                    lng1=viewer_lng,
                    lat2=row.center_lat,
                    lng2=row.center_lng,
                )
                if distance_km > radius_km:
                    continue
            elif viewer_lat is not None and viewer_lng is not None:
                distance_km = self._distance_km(
                    lat1=viewer_lat,
                    lng1=viewer_lng,
                    lat2=row.center_lat,
                    lng2=row.center_lng,
                )
            filtered.append((row, distance_km, is_own))

        filtered.sort(
            key=lambda entry: (
                0 if entry[2] else 1,
                -(entry[0].published_at.timestamp() if entry[0].published_at else 0),
            )
        )
        page = filtered[offset : offset + limit]
        next_cursor = str(offset + limit) if (offset + limit) < len(filtered) else None
        return page, next_cursor

    def get_story_for_viewer(self, *, story_id: UUID, user_id: UUID) -> Story:
        now = self._now()
        story = self.db.query(Story).filter(Story.id == story_id).first()
        if story is None or story.deleted_at is not None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")

        is_owner = story.author_user_id == user_id
        if story.status == "moderation_hidden" and not (is_owner or self._is_moderator(user_id)):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")

        if not is_owner and (
            story.status != "published"
            or story.expires_at is None
            or story.expires_at <= now
        ):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")
        return story

    def delete_story(self, *, story_id: UUID, user_id: UUID) -> Story:
        story = self.db.query(Story).filter(Story.id == story_id).first()
        if story is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")
        if story.author_user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not story owner")

        now = self._now()
        story.status = "deleted"
        story.deleted_at = now
        story.updated_at = now
        self.db.add(story)
        self.db.commit()
        self.db.refresh(story)
        return story

    def report_story(
        self,
        *,
        story_id: UUID,
        reporter_user_id: UUID,
        reason: str,
        details: Optional[str],
    ) -> StoryReport:
        story = self.db.query(Story).filter(Story.id == story_id).first()
        if story is None or story.deleted_at is not None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")

        report = StoryReport(
            story_id=story_id,
            reporter_user_id=reporter_user_id,
            reason=reason.strip().lower(),
            details=details.strip() if details else None,
        )
        self.db.add(report)
        self.db.commit()
        self.db.refresh(report)
        return report

    def mute_author(self, *, user_id: UUID, muted_author_id: UUID) -> StoryAuthorMute:
        if user_id == muted_author_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot mute yourself",
            )
        existing = (
            self.db.query(StoryAuthorMute)
            .filter(
                StoryAuthorMute.user_id == user_id,
                StoryAuthorMute.muted_author_id == muted_author_id,
            )
            .first()
        )
        if existing is not None:
            return existing

        row = StoryAuthorMute(user_id=user_id, muted_author_id=muted_author_id)
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        return row

    def record_view(self, *, story_id: UUID, viewer_user_id: UUID) -> Story:
        story = self.get_story_for_viewer(story_id=story_id, user_id=viewer_user_id)
        if story.author_user_id != viewer_user_id:
            already_viewed = (
                self.db.query(StoryView.id)
                .filter(
                    StoryView.story_id == story.id,
                    StoryView.viewer_user_id == viewer_user_id,
                )
                .first()
            )
            if already_viewed is None:
                now = self._now()
                self.db.add(
                    StoryView(
                        story_id=story.id,
                        viewer_user_id=viewer_user_id,
                    )
                )
                story.view_count = int(story.view_count or 0) + 1
                story.updated_at = now
                self.db.add(story)
                try:
                    self.db.commit()
                except IntegrityError:
                    self.db.rollback()
                story = self.get_story_for_viewer(story_id=story_id, user_id=viewer_user_id)
        return story

    def moderation_hide(self, *, story_id: UUID, moderator_user_id: UUID) -> Story:
        if not self._is_moderator(moderator_user_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Moderator access required",
            )
        story = self.db.query(Story).filter(Story.id == story_id).first()
        if story is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found")
        story.status = "moderation_hidden"
        story.updated_at = self._now()
        self.db.add(story)
        self.db.commit()
        self.db.refresh(story)
        return story

    def run_retention_cleanup(self) -> dict[str, int]:
        now = self._now()
        grace_cutoff = now - timedelta(hours=STORY_PURGE_GRACE_HOURS)
        row_cutoff = now - timedelta(days=STORY_ROW_RETENTION_DAYS)

        expired_rows = (
            self.db.query(Story)
            .filter(
                Story.status == "published",
                Story.expires_at.isnot(None),
                Story.expires_at <= now,
            )
            .all()
        )
        for row in expired_rows:
            row.status = "expired"
            row.updated_at = now

        purge_candidates = (
            self.db.query(Story)
            .filter(
                Story.expires_at.isnot(None),
                Story.expires_at <= grace_cutoff,
                Story.media_purged_at.is_(None),
            )
            .all()
        )

        purged_count = 0
        storage = None
        for row in purge_candidates:
            if not row.storage_object_path:
                row.media_purged_at = now
                row.thumbnail_purged_at = now
                continue
            if storage is None:
                storage = self._get_storage_service()
            try:
                storage.delete_file(self._stories_bucket, row.storage_object_path)
            except Exception:
                pass
            if row.thumbnail_object_path:
                try:
                    storage.delete_file(self._stories_bucket, row.thumbnail_object_path)
                except Exception:
                    pass
            row.media_purged_at = now
            row.thumbnail_purged_at = now
            purged_count += 1

        deleted_count = (
            self.db.query(Story)
            .filter(
                Story.created_at <= row_cutoff,
                Story.media_purged_at.isnot(None),
                Story.status.in_(("expired", "deleted", "moderation_hidden")),
            )
            .delete(synchronize_session=False)
        )
        self.db.commit()
        return {
            "expired_marked": len(expired_rows),
            "media_purged": purged_count,
            "rows_deleted": int(deleted_count),
        }
