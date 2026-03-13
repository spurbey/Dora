"""
Service layer for export job control-plane operations.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import hashlib
import json
import logging
import os
import secrets
from typing import Any, Optional
from urllib.parse import urlparse
from uuid import UUID

import boto3
from fastapi import HTTPException, status
from sqlalchemy import and_, or_
from sqlalchemy.orm import Session

from app.config import settings
from app.models.export_job import ExportJob
from app.models.export_share_token import ExportShareToken
from app.models.media import MediaFile
from app.models.place import TripPlace
from app.models.route import Route
from app.models.trip import Trip
from app.schemas.export import ExportCreateRequest


SNAPSHOT_MAX_BYTES = 500 * 1024
DOWNLOAD_TTL_SECONDS = 3600
SHARE_TTL_SECONDS = 604800
SHARE_REDIRECT_TTL_SECONDS = 60
QUALITY_RANK = {"480p": 0, "720p": 1, "1080p": 2}

logger = logging.getLogger(__name__)


def _env_int(name: str, default: int) -> int:
    value = os.getenv(name)
    if value is None or value == "":
        return default
    try:
        return int(value)
    except ValueError:
        logger.warning("Invalid int for %s=%s; using default=%s", name, value, default)
        return default


def _env_str(name: str, default: str) -> str:
    value = os.getenv(name)
    if value is None or value == "":
        return default
    return value


@dataclass
class CancelJobResult:
    response_status: str
    http_status: int


class ExportService:
    def __init__(self, db: Session):
        self.db = db

    def create_export_job(
        self,
        user_id: UUID,
        trip_id: UUID,
        request: ExportCreateRequest,
    ) -> ExportJob:
        trip = self._get_trip_for_owner(trip_id=trip_id, user_id=user_id)
        self._validate_preconditions(trip=trip, user_id=user_id)
        self._validate_service_limits(user_id=user_id, request=request)

        snapshot = self._build_snapshot(trip=trip, request=request)
        snapshot_hash = self._compute_snapshot_hash(snapshot=snapshot)
        existing_job = self._find_duplicate_job(
            user_id=user_id,
            trip_id=trip_id,
            request=request,
            snapshot_hash=snapshot_hash,
        )
        if existing_job:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={
                    "error": "duplicate_job",
                    "existing_job_id": str(existing_job.id),
                    "detail": "An identical export is already queued or processing.",
                },
            )

        job = ExportJob(
            user_id=user_id,
            trip_id=trip_id,
            status="queued",
            stage=None,
            progress=0.0,
            template=request.template.value,
            aspect_ratio=request.aspect_ratio.value,
            duration_sec=request.duration_sec,
            quality=request.quality.value,
            fps=request.fps,
            snapshot_json=snapshot,
            snapshot_hash=snapshot_hash,
            retry_count=0,
            max_retries=3,
            next_attempt_at=None,
        )
        self.db.add(job)
        self.db.commit()
        self.db.refresh(job)
        logger.info(
            "[EXPORT_JOB] created job_id=%s user_id=%s quality=%s aspect_ratio=%s duration_sec=%s",
            job.id,
            user_id,
            job.quality,
            job.aspect_ratio,
            job.duration_sec,
        )
        return job

    def get_export_job(self, user_id: UUID, job_id: UUID) -> ExportJob:
        job = self.db.query(ExportJob).filter(ExportJob.id == job_id).first()
        if not job:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Export job not found",
            )
        if job.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to access this export",
            )
        return job

    def list_export_jobs(
        self,
        user_id: UUID,
        *,
        page: int = 1,
        page_size: int = 20,
        status_filter: Optional[str] = None,
        trip_id: Optional[UUID] = None,
    ) -> dict[str, Any]:
        query = (
            self.db.query(ExportJob, Trip.title.label("trip_title"))
            .join(Trip, Trip.id == ExportJob.trip_id)
            .filter(ExportJob.user_id == user_id)
        )

        if status_filter:
            query = query.filter(ExportJob.status == status_filter)
        if trip_id:
            query = query.filter(ExportJob.trip_id == trip_id)

        total = query.count()
        offset = (page - 1) * page_size
        rows = (
            query.order_by(ExportJob.created_at.desc())
            .offset(offset)
            .limit(page_size)
            .all()
        )

        exports = [
            self._to_export_summary(job=row[0], trip_title=row[1])
            for row in rows
        ]
        total_pages = (total + page_size - 1) // page_size if total > 0 else 0

        return {
            "exports": exports,
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": total_pages,
        }

    def cancel_export_job(self, user_id: UUID, job_id: UUID) -> CancelJobResult:
        job = self.get_export_job(user_id=user_id, job_id=job_id)
        now = datetime.now(timezone.utc)

        if job.status == "queued":
            job.status = "canceled"
            job.completed_at = now
            job.error_code = "canceled_by_user"
            job.error_message = "Canceled before processing began"
            self.db.commit()
            return CancelJobResult(response_status="canceled", http_status=status.HTTP_200_OK)

        if job.status == "processing":
            job.status = "cancel_requested"
            self.db.commit()
            return CancelJobResult(
                response_status="cancel_requested",
                http_status=status.HTTP_202_ACCEPTED,
            )

        if job.status == "cancel_requested":
            return CancelJobResult(
                response_status="cancel_requested",
                http_status=status.HTTP_202_ACCEPTED,
            )

        if job.status in {"completed", "blocked", "canceled"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={
                    "error": "invalid_transition",
                    "current_status": job.status,
                },
            )

        # failed jobs are not active and cannot be canceled
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "error": "invalid_transition",
                "current_status": job.status,
            },
        )

    def build_download_response(self, user_id: UUID, job_id: UUID) -> dict[str, Any]:
        job = self.get_export_job(user_id=user_id, job_id=job_id)
        if job.status != "completed":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Download URL is only available for completed exports",
            )

        expires_at = datetime.now(timezone.utc) + timedelta(seconds=DOWNLOAD_TTL_SECONDS)
        output_url = job.output_url or ""
        if output_url.startswith("s3://"):
            parsed = urlparse(output_url)
            bucket = parsed.netloc
            key = parsed.path.lstrip("/")
            if not bucket or not key:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Invalid S3 output path for completed export",
                )
            s3 = boto3.client(
                "s3",
                region_name=_env_str("AWS_REGION", settings.AWS_REGION),
            )
            download_url = s3.generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": key},
                ExpiresIn=DOWNLOAD_TTL_SECONDS,
            )
        else:
            download_url = output_url or f"https://downloads.dora.local/exports/{job.id}.mp4"
        return {
            "download_url": download_url,
            "expires_at": expires_at,
            "ttl_seconds": DOWNLOAD_TTL_SECONDS,
        }

    def build_share_response(self, user_id: UUID, job_id: UUID) -> dict[str, Any]:
        job = self.get_export_job(user_id=user_id, job_id=job_id)
        if job.status != "completed":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Share URL is only available for completed exports",
            )
        trip = self.db.query(Trip).filter(Trip.id == job.trip_id).first()
        if not trip or trip.visibility == "private":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Sharing is disabled for this trip",
            )
        if not (job.output_url or "").startswith("s3://"):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Share URL is only available for cloud-backed exports",
            )

        now = datetime.now(timezone.utc)
        active_token = (
            self.db.query(ExportShareToken)
            .filter(ExportShareToken.job_id == job.id)
            .filter(ExportShareToken.user_id == user_id)
            .filter(ExportShareToken.revoked_at.is_(None))
            .filter(ExportShareToken.expires_at > now)
            .order_by(ExportShareToken.created_at.desc())
            .first()
        )
        if active_token:
            token_row = active_token
        else:
            expires_at = now + timedelta(seconds=SHARE_TTL_SECONDS)
            token_row = ExportShareToken(
                token=self._generate_unique_share_token(),
                user_id=user_id,
                trip_id=job.trip_id,
                job_id=job.id,
                expires_at=expires_at,
            )
            self.db.add(token_row)
            self.db.commit()
            self.db.refresh(token_row)

        base_url = _env_str("EXPORT_SHARE_BASE_URL", "https://api.dora.app").rstrip("/")
        return {
            "share_url": f"{base_url}/api/v1/shares/{token_row.token}",
            "expires_at": token_row.expires_at,
            "ttl_seconds": SHARE_TTL_SECONDS,
        }

    def resolve_share_redirect(self, token: str) -> str:
        now = datetime.now(timezone.utc)
        token_row = (
            self.db.query(ExportShareToken)
            .filter(ExportShareToken.token == token)
            .first()
        )
        if not token_row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Share link not found",
            )
        if token_row.revoked_at is not None or token_row.expires_at <= now:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Share link is expired or revoked",
            )

        job = self.db.query(ExportJob).filter(ExportJob.id == token_row.job_id).first()
        if not job or job.status != "completed":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Shared export is unavailable",
            )

        trip = self.db.query(Trip).filter(Trip.id == token_row.trip_id).first()
        if not trip or trip.visibility == "private":
            revoke_time = now
            (
                self.db.query(ExportShareToken)
                .filter(ExportShareToken.job_id == token_row.job_id)
                .filter(ExportShareToken.revoked_at.is_(None))
                .update({"revoked_at": revoke_time}, synchronize_session=False)
            )
            self.db.commit()
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Sharing is disabled for this trip",
            )

        output_url = job.output_url or ""
        if output_url.startswith("s3://"):
            parsed = urlparse(output_url)
            bucket = parsed.netloc
            key = parsed.path.lstrip("/")
            if not bucket or not key:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Invalid S3 output path for completed export",
                )
            s3 = boto3.client(
                "s3",
                region_name=_env_str("AWS_REGION", settings.AWS_REGION),
            )
            return s3.generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": key},
                ExpiresIn=SHARE_REDIRECT_TTL_SECONDS,
            )

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Shared export artifact is not cloud-backed",
        )

    def _get_trip_for_owner(self, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found",
            )
        if trip.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to export this trip",
            )
        return trip

    def _validate_preconditions(self, trip: Trip, user_id: UUID) -> None:
        # 6A only has server-side hooks for these checks. Flutter performs the
        # authoritative local queue pre-submit guard before calling this API.
        if self._has_pending_media(trip_id=trip.id, user_id=user_id):
            self._raise_precondition_failed(
                reason="pending_media",
                detail="Upload all media before exporting.",
            )
        if self._has_blocking_sync(trip_id=trip.id, user_id=user_id):
            self._raise_precondition_failed(
                reason="pending_sync",
                detail="Trip changes are still syncing.",
            )

    def _validate_service_limits(self, user_id: UUID, request: ExportCreateRequest) -> None:
        max_concurrent_per_user = _env_int(
            "EXPORT_MAX_CONCURRENT_PER_USER",
            settings.EXPORT_MAX_CONCURRENT_PER_USER,
        )
        global_queue_cap = _env_int(
            "EXPORT_GLOBAL_QUEUE_CAP",
            settings.EXPORT_GLOBAL_QUEUE_CAP,
        )
        free_tier_max_duration_sec = _env_int(
            "EXPORT_FREE_TIER_MAX_DURATION_SEC",
            settings.EXPORT_FREE_TIER_MAX_DURATION_SEC,
        )
        free_tier_max_quality = _env_str(
            "EXPORT_FREE_TIER_MAX_QUALITY",
            settings.EXPORT_FREE_TIER_MAX_QUALITY,
        )

        active_count = (
            self.db.query(ExportJob)
            .filter(ExportJob.user_id == user_id)
            .filter(ExportJob.status.in_(["queued", "processing", "cancel_requested"]))
            .count()
        )
        if active_count >= max_concurrent_per_user:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    f"You already have {max_concurrent_per_user} active exports. "
                    "Wait for one to finish."
                ),
            )

        global_active = (
            self.db.query(ExportJob)
            .filter(ExportJob.status.in_(["queued", "processing", "cancel_requested"]))
            .count()
        )
        if global_active >= global_queue_cap:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Export queue is at capacity. Please try again shortly.",
            )

        free_quality_rank = QUALITY_RANK.get(free_tier_max_quality, QUALITY_RANK["720p"])
        requested_quality_rank = QUALITY_RANK.get(request.quality.value, QUALITY_RANK["1080p"])
        if requested_quality_rank > free_quality_rank:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"{request.quality.value} exports require a paid plan.",
            )
        if request.duration_sec > free_tier_max_duration_sec:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Exports longer than {free_tier_max_duration_sec}s require a paid plan."
                ),
            )

    def _raise_precondition_failed(self, reason: str, detail: str) -> None:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "error": "export_precondition_failed",
                "reason": reason,
                "detail": detail,
            },
        )

    def _has_pending_media(self, trip_id: UUID, user_id: UUID) -> bool:
        # 6A backend has no durable upload queue table yet.
        return False

    def _has_blocking_sync(self, trip_id: UUID, user_id: UUID) -> bool:
        # 6A backend has no durable sync queue table yet.
        return False

    def _build_snapshot(self, trip: Trip, request: ExportCreateRequest) -> dict[str, Any]:
        max_snapshot_places = max(1, _env_int("EXPORT_SNAPSHOT_MAX_PLACES", 12))
        max_media_per_place = max(1, _env_int("EXPORT_SNAPSHOT_MAX_MEDIA_PER_PLACE", 3))
        max_snapshot_routes = max(0, _env_int("EXPORT_SNAPSHOT_MAX_ROUTES", 24))

        places = (
            self.db.query(TripPlace)
            .filter(TripPlace.trip_id == trip.id)
            .filter(TripPlace.user_id == trip.user_id)
            .order_by(TripPlace.order_in_trip.asc(), TripPlace.created_at.asc())
            .all()
        )
        selected_places = places[:max_snapshot_places]
        place_ids = [place.id for place in selected_places]
        selected_place_ids = set(place_ids)

        media_rows_by_place: dict[UUID, list[MediaFile]] = {}
        if place_ids:
            media_rows = (
                self.db.query(MediaFile)
                .filter(MediaFile.user_id == trip.user_id)
                .filter(MediaFile.trip_place_id.in_(place_ids))
                .order_by(MediaFile.trip_place_id.asc(), MediaFile.created_at.asc())
                .all()
            )
            for media in media_rows:
                media_rows_by_place.setdefault(media.trip_place_id, []).append(media)

        media_by_place: dict[UUID, list[dict[str, Any]]] = {}
        flat_media: list[dict[str, Any]] = []
        places_payload: list[dict[str, Any]] = []
        for place in selected_places:
            ordered_media_rows = self._prioritize_media_rows(media_rows_by_place.get(place.id, []))
            selected_media_rows = ordered_media_rows[:max_media_per_place]
            selected_media_payload = [self._serialize_media(media) for media in selected_media_rows]
            media_by_place[place.id] = selected_media_payload
            flat_media.extend(selected_media_payload)

            external_data = place.external_data if isinstance(place.external_data, dict) else {}
            places_payload.append(
                {
                    "id": str(place.id),
                    "name": place.name,
                    "place_type": place.place_type,
                    "lat": place.lat,
                    "lng": place.lng,
                    "destination": external_data.get("formatted_address"),
                    "city": external_data.get("city") or external_data.get("locality"),
                    "visit_date": place.visit_date.isoformat() if place.visit_date else None,
                    "order_in_trip": int(place.order_in_trip or 0),
                    "user_notes": place.user_notes,
                    "media": selected_media_payload,
                }
            )

        routes_query = (
            self.db.query(Route)
            .filter(Route.trip_id == trip.id)
            .filter(Route.user_id == trip.user_id)
        )
        if selected_place_ids:
            routes_query = routes_query.filter(
                or_(
                    Route.start_place_id.is_(None),
                    Route.end_place_id.is_(None),
                    and_(
                        Route.start_place_id.in_(place_ids),
                        Route.end_place_id.in_(place_ids),
                    ),
                )
            )
        routes = routes_query.order_by(Route.order_in_trip.asc(), Route.created_at.asc()).all()
        if max_snapshot_routes:
            routes = routes[:max_snapshot_routes]
        else:
            routes = []

        routes_payload: list[dict[str, Any]] = []
        for route in routes:
            routes_payload.append(
                {
                    "id": str(route.id),
                    "name": route.name or "Route",
                    "transport_mode": route.transport_mode,
                    "route_category": route.route_category,
                    "start_place_id": str(route.start_place_id) if route.start_place_id else None,
                    "end_place_id": str(route.end_place_id) if route.end_place_id else None,
                    "distance_km": route.distance_km,
                    "duration_mins": route.duration_mins,
                    "order_in_trip": int(route.order_in_trip or 0),
                    "route_geojson": self._simplify_route_geojson(route.route_geojson),
                }
            )

        timeline = self._build_timeline(places=places_payload, routes=routes_payload)

        snapshot = {
            "trip": {
                "id": str(trip.id),
                "user_id": str(trip.user_id),
                "title": trip.title,
                "description": trip.description,
                "cover_photo_url": trip.cover_photo_url,
                "visibility": trip.visibility,
                "start_date": trip.start_date.isoformat() if trip.start_date else None,
                "end_date": trip.end_date.isoformat() if trip.end_date else None,
            },
            "timeline": timeline,
            "routes": routes_payload,
            "places": places_payload,
            "media": flat_media,
            "config": {
                "template": request.template.value,
                "aspect_ratio": request.aspect_ratio.value,
                "duration_sec": request.duration_sec,
                "quality": request.quality.value,
                "fps": request.fps,
            },
        }
        self._validate_snapshot_size(snapshot=snapshot)
        return snapshot

    def _prioritize_media_rows(self, media_rows: list[MediaFile]) -> list[MediaFile]:
        """Prefer image assets first so image-only templates do not pick video URLs."""
        photos: list[MediaFile] = []
        non_photos: list[MediaFile] = []
        for media in media_rows:
            if self._is_photo_media(media):
                photos.append(media)
            else:
                non_photos.append(media)
        return photos + non_photos

    def _is_photo_media(self, media: MediaFile) -> bool:
        file_type = (media.file_type or "").lower()
        if file_type == "photo":
            return True
        mime_type = (media.mime_type or "").lower()
        return mime_type.startswith("image/")

    def _serialize_media(self, media: MediaFile) -> dict[str, Any]:
        return {
            "id": str(media.id),
            "trip_place_id": str(media.trip_place_id),
            "url": media.file_url,
            "thumbnail_url": media.thumbnail_url,
            "width": media.width,
            "height": media.height,
            "mime_type": media.mime_type,
            "file_size_bytes": media.file_size_bytes,
            "file_type": media.file_type,
            "caption": media.caption,
            "taken_at": media.taken_at.isoformat() if media.taken_at else None,
        }

    def _build_timeline(
        self,
        *,
        places: list[dict[str, Any]],
        routes: list[dict[str, Any]],
    ) -> list[dict[str, Any]]:
        timeline: list[dict[str, Any]] = []
        for place in places:
            timeline.append(
                {
                    "component_type": "place",
                    "id": place["id"],
                    "name": place["name"],
                    "order_in_trip": int(place.get("order_in_trip") or 0),
                    "lat": place.get("lat"),
                    "lng": place.get("lng"),
                    "destination": place.get("destination"),
                    "city": place.get("city"),
                    "media": place.get("media", []),
                }
            )
        for route in routes:
            timeline.append(
                {
                    "component_type": "route",
                    "id": route["id"],
                    "name": route["name"],
                    "order_in_trip": int(route.get("order_in_trip") or 0),
                    "transport_mode": route.get("transport_mode"),
                    "route_category": route.get("route_category"),
                    "route_geojson": route.get("route_geojson"),
                }
            )

        timeline.sort(
            key=lambda item: (
                int(item.get("order_in_trip") or 0),
                0 if item.get("component_type") == "place" else 1,
            )
        )
        return timeline

    def _simplify_route_geojson(
        self,
        route_geojson: Any,
        *,
        max_points: int = 500,
    ) -> Any:
        if not isinstance(route_geojson, dict):
            return route_geojson
        if route_geojson.get("type") != "LineString":
            return route_geojson

        coordinates = route_geojson.get("coordinates")
        if not isinstance(coordinates, list) or len(coordinates) <= max_points:
            return route_geojson

        step = max(1, (len(coordinates) - 1) // (max_points - 1))
        sampled = [coordinates[index] for index in range(0, len(coordinates), step)]
        if sampled[-1] != coordinates[-1]:
            sampled.append(coordinates[-1])
        if len(sampled) > max_points:
            sampled = sampled[: max_points - 1] + [coordinates[-1]]

        simplified = dict(route_geojson)
        simplified["coordinates"] = sampled
        return simplified

    def _validate_snapshot_size(self, snapshot: dict[str, Any]) -> None:
        serialized = self._normalize_snapshot(snapshot=snapshot)
        size_bytes = len(serialized.encode("utf-8"))
        if size_bytes > SNAPSHOT_MAX_BYTES:
            self._raise_precondition_failed(
                reason="snapshot_too_large",
                detail=f"Snapshot payload exceeds {SNAPSHOT_MAX_BYTES} bytes.",
            )

    def _normalize_snapshot(self, snapshot: dict[str, Any]) -> str:
        return json.dumps(snapshot, separators=(",", ":"), sort_keys=True)

    def _generate_unique_share_token(self) -> str:
        while True:
            token = secrets.token_urlsafe(36)
            exists = (
                self.db.query(ExportShareToken.id)
                .filter(ExportShareToken.token == token)
                .first()
            )
            if not exists:
                return token

    def _compute_snapshot_hash(self, snapshot: dict[str, Any]) -> str:
        normalized = self._normalize_snapshot(snapshot=snapshot)
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

    def _to_export_summary(self, *, job: ExportJob, trip_title: Optional[str]) -> dict[str, Any]:
        return {
            "job_id": job.id,
            "trip_id": job.trip_id,
            "trip_title": trip_title,
            "template": job.template,
            "status": job.status,
            "stage": job.stage,
            "progress": job.progress,
            "output_url": job.output_url,
            "thumbnail_url": job.thumbnail_url,
            "error_code": job.error_code,
            "error_message": job.error_message,
            "created_at": job.created_at,
            "completed_at": job.completed_at,
        }

    def _find_duplicate_job(
        self,
        user_id: UUID,
        trip_id: UUID,
        request: ExportCreateRequest,
        snapshot_hash: str,
    ) -> Optional[ExportJob]:
        return (
            self.db.query(ExportJob)
            .filter(ExportJob.user_id == user_id)
            .filter(ExportJob.trip_id == trip_id)
            .filter(ExportJob.snapshot_hash == snapshot_hash)
            .filter(ExportJob.quality == request.quality.value)
            .filter(ExportJob.aspect_ratio == request.aspect_ratio.value)
            .filter(ExportJob.status.in_(["queued", "processing", "cancel_requested"]))
            .order_by(ExportJob.created_at.desc())
            .first()
        )
