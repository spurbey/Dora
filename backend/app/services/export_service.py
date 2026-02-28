"""
Service layer for export job control-plane operations.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import hashlib
import json
from typing import Any, Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.export_job import ExportJob
from app.models.trip import Trip
from app.schemas.export import ExportCreateRequest


SNAPSHOT_MAX_BYTES = 500 * 1024
DOWNLOAD_TTL_SECONDS = 3600
SHARE_TTL_SECONDS = 604800


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
        download_url = job.output_url or f"https://downloads.dora.local/exports/{job.id}.mp4"
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

        expires_at = datetime.now(timezone.utc) + timedelta(seconds=SHARE_TTL_SECONDS)
        share_token = hashlib.sha256(f"{job.id}:{job.user_id}:{expires_at.isoformat()}".encode("utf-8")).hexdigest()[:24]
        return {
            "share_url": f"https://api.dora.app/api/v1/shares/{share_token}",
            "expires_at": expires_at,
            "ttl_seconds": SHARE_TTL_SECONDS,
        }

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
        snapshot = {
            "trip": {
                "id": str(trip.id),
                "user_id": str(trip.user_id),
                "title": trip.title,
                "visibility": trip.visibility,
                "start_date": trip.start_date.isoformat() if trip.start_date else None,
                "end_date": trip.end_date.isoformat() if trip.end_date else None,
            },
            "timeline": [],
            "routes": [],
            "places": [],
            "media": [],
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

    def _compute_snapshot_hash(self, snapshot: dict[str, Any]) -> str:
        normalized = self._normalize_snapshot(snapshot=snapshot)
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

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
