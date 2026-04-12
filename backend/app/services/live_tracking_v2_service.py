"""
Strict V2 ingest and projection service.
"""

from __future__ import annotations

import base64
import hashlib
import io
import json
import tempfile
import time
import uuid
from bisect import bisect_left
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Callable, Iterable, Optional
from uuid import UUID

from fastapi import HTTPException, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy import and_, func, or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.api_idempotency_record import ApiIdempotencyRecord
from app.models.trip import Trip
from app.models.trip_commit_manifest import TripCommitManifest
from app.models.trip_event_raw import TripEventRaw
from app.models.trip_media_raw import TripMediaRaw
from app.models.trip_route_projection_v2 import TripRouteProjectionV2
from app.models.trip_route_raw_point import TripRouteRawPoint
from app.models.trip_session_raw import TripSessionRaw
from app.models.trip_timeline_projection_v2 import TripTimelineProjectionV2
from app.services.v2_storage_service import V2StorageService
from app.utils.geo import haversine_distance


IDEMPOTENCY_TTL_HOURS = 72
SUPPORTED_SCHEMA_VERSIONS = {1}
MAX_CHUNK_BYTES = 128 * 1024
MAX_TOTAL_PAYLOAD_BYTES = 64 * 1024 * 1024
MAX_EVENTS = 10_000
MAX_MEDIA = 2_000
MAX_POINTS = 200_000
MAX_PROJECTION_COMPILE_MS = 10_000
TIMELINE_COMPILER_VERSION = 1
ROUTE_COMPILER_VERSION = 1
TIMELINE_LIMIT_MIN = 1
TIMELINE_LIMIT_MAX = 200
ROUTE_LIMIT_SEGMENTS_DEFAULT = 10
ROUTE_LIMIT_SEGMENTS_MAX = 20
ROUTE_MAX_POINTS_RETURNED = 5_000
ROUTE_ASSOCIATION_THRESHOLD_M = 100.0
ROUTE_ASSOCIATION_PRIMARY_WINDOW_SECONDS = 3 * 60
ROUTE_ASSOCIATION_FALLBACK_WINDOW_SECONDS = 10 * 60
ROUTE_ASSOCIATION_CANDIDATE_CAP = 20
MANIFEST_OPERATION_KIND = "session_finalize"
TERMINAL_MANIFEST_STATUSES = {"committed", "failed_terminal", "idempotency_conflict"}

MANIFEST_TRANSITIONS: set[tuple[tuple[str, str], tuple[str, str]]] = {
    (("started", "start_received"), ("started", "media_verified")),
    (("started", "media_verified"), ("started", "chunks_complete")),
    (("started", "chunks_complete"), ("started", "raw_ingest_completed")),
    (("started", "raw_ingest_completed"), ("started", "projection_compiled")),
    (("started", "projection_compiled"), ("committed", "finalized")),
    (("failed_retryable", "start_received"), ("started", "start_received")),
    (("failed_retryable", "media_verified"), ("started", "media_verified")),
    (("failed_retryable", "chunks_complete"), ("started", "chunks_complete")),
    (("failed_retryable", "raw_ingest_completed"), ("started", "raw_ingest_completed")),
    (("failed_retryable", "projection_compiled"), ("started", "projection_compiled")),
}


@dataclass(frozen=True)
class IdempotencyResult:
    status_code: int
    body: dict[str, Any]
    replayed: bool


@dataclass(frozen=True)
class _SessionPoint:
    captured_at: datetime
    latitude: float
    longitude: float
    point_seq: int


@dataclass(frozen=True)
class _RouteAssociation:
    segment_key: Optional[str]
    distance_m: Optional[float]


class LiveTrackingV2Service:
    """Owns the strict V2 backend lane."""

    def __init__(self, db: Session, storage_service: Optional[V2StorageService] = None):
        self.db = db
        self.storage_service = storage_service or V2StorageService()

    @staticmethod
    def _utcnow() -> datetime:
        return datetime.now(timezone.utc)

    @staticmethod
    def _to_utc(value: datetime) -> datetime:
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    @staticmethod
    def _canonical_json(value: Any) -> str:
        return json.dumps(value, sort_keys=True, separators=(",", ":"), default=str)

    @classmethod
    def _sha256(cls, value: Any) -> str:
        if not isinstance(value, str):
            value = cls._canonical_json(value)
        return hashlib.sha256(value.encode("utf-8")).hexdigest()

    @staticmethod
    def _error(status_code: int, error_code: str, message: str) -> None:
        raise HTTPException(
            status_code=status_code,
            detail={
                "error_code": error_code,
                "message": message,
            },
        )

    @staticmethod
    def _parse_uuid(value: Any) -> Optional[UUID]:
        if value is None:
            return None
        if isinstance(value, UUID):
            return value
        try:
            return UUID(str(value))
        except (TypeError, ValueError):
            return None

    def _normalize_media_manifest(self, manifest: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
        rows = [dict(item) for item in manifest]
        rows.sort(key=lambda item: item.get("client_media_id", ""))
        return rows

    def _normalize_session_summary(self, summary: dict[str, Any]) -> dict[str, Any]:
        return {
            "snapshot_hash": summary.get("snapshot_hash"),
            "event_count": int(summary.get("event_count", 0)),
            "media_count": int(summary.get("media_count", 0)),
            "point_count": int(summary.get("point_count", 0)),
            "payload_bytes": int(summary.get("payload_bytes", 0)),
            "started_at": summary.get("started_at"),
            "ended_at": summary.get("ended_at"),
        }

    def _request_fingerprint(self, payload: dict[str, Any]) -> str:
        return self._sha256(payload)

    def _extract_constraint_name(self, error: IntegrityError) -> Optional[str]:
        orig = getattr(error, "orig", None)
        diag = getattr(orig, "diag", None)
        if diag is not None:
            return getattr(diag, "constraint_name", None)
        message = str(orig or error)
        known = (
            "uq_idempotency_user_endpoint_key",
            "uq_trip_session_raw_trip_client_session",
            "uq_trip_commit_manifest_trip_operation_key",
            "uq_trip_route_raw_point_session_seq",
            "uq_trip_event_raw_trip_client_event",
            "uq_trip_media_raw_trip_client_media",
        )
        for name in known:
            if name in message:
                return name
        return None

    def _idempotency_conflict(self) -> None:
        self._error(
            status.HTTP_409_CONFLICT,
            "idempotency_conflict",
            "Idempotency-Key was reused with a different payload.",
        )

    def _run_idempotent_mutation(
        self,
        *,
        user_id: UUID,
        endpoint_signature: str,
        idempotency_key: str,
        request_payload: dict[str, Any],
        operation: Callable[[], tuple[int, dict[str, Any]]],
    ) -> IdempotencyResult:
        now = self._utcnow()
        payload = jsonable_encoder(request_payload)
        request_hash = self._sha256(payload)

        record = (
            self.db.query(ApiIdempotencyRecord)
            .filter(
                ApiIdempotencyRecord.user_id == user_id,
                ApiIdempotencyRecord.endpoint_signature == endpoint_signature,
                ApiIdempotencyRecord.idempotency_key == idempotency_key,
            )
            .first()
        )
        if record:
            if record.expires_at <= now:
                self.db.delete(record)
                self.db.flush()
            else:
                if record.request_hash != request_hash:
                    self._idempotency_conflict()
                record.replay_count += 1
                record.last_replayed_at = now
                self.db.commit()
                return IdempotencyResult(record.response_status, record.response_body or {}, True)

        try:
            status_code, body = operation()
            encoded = jsonable_encoder(body)
            self.db.add(
                ApiIdempotencyRecord(
                    user_id=user_id,
                    endpoint_signature=endpoint_signature,
                    idempotency_key=idempotency_key,
                    request_hash=request_hash,
                    response_status=status_code,
                    response_body=encoded,
                    replay_count=0,
                    first_seen_at=now,
                    expires_at=now + timedelta(hours=IDEMPOTENCY_TTL_HOURS),
                )
            )
            self.db.commit()
            return IdempotencyResult(status_code, encoded, False)
        except HTTPException:
            self.db.rollback()
            raise
        except IntegrityError as exc:
            constraint_name = self._extract_constraint_name(exc)
            self.db.rollback()
            if constraint_name == "uq_idempotency_user_endpoint_key":
                replay = (
                    self.db.query(ApiIdempotencyRecord)
                    .filter(
                        ApiIdempotencyRecord.user_id == user_id,
                        ApiIdempotencyRecord.endpoint_signature == endpoint_signature,
                        ApiIdempotencyRecord.idempotency_key == idempotency_key,
                    )
                    .first()
                )
                if replay is None:
                    self._error(status.HTTP_409_CONFLICT, "idempotency_retry_pending", "Idempotent request is still being resolved.")
                if replay.request_hash != request_hash:
                    self._idempotency_conflict()
                replay.replay_count += 1
                replay.last_replayed_at = now
                self.db.commit()
                return IdempotencyResult(replay.response_status, replay.response_body or {}, True)
            raise

    def _get_owned_trip(self, *, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if trip is None:
            self._error(status.HTTP_404_NOT_FOUND, "trip_not_found", "Trip not found.")
        if trip.user_id != user_id:
            self._error(status.HTTP_403_FORBIDDEN, "auth_forbidden", "You do not own this trip.")
        return trip

    def _require_v2_trip(self, *, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        if not trip.v2_backend_enabled:
            self._error(
                status.HTTP_409_CONFLICT,
                "trip_not_v2_enabled",
                "Trip is not enabled for the V2 backend lane.",
            )
        return trip

    def _require_supported_schema(self, schema_version: int) -> None:
        if schema_version not in SUPPORTED_SCHEMA_VERSIONS:
            self._error(
                status.HTTP_422_UNPROCESSABLE_ENTITY,
                "unsupported_schema",
                f"schema_version {schema_version} is not supported.",
            )

    def _get_session(self, *, trip_id: UUID, user_id: UUID, client_session_id: str) -> TripSessionRaw:
        session = (
            self.db.query(TripSessionRaw)
            .filter(
                TripSessionRaw.trip_server_id == trip_id,
                TripSessionRaw.user_id == user_id,
                TripSessionRaw.client_session_id == client_session_id,
            )
            .first()
        )
        if session is None:
            self._error(status.HTTP_404_NOT_FOUND, "session_not_found", "Session not found.")
        return session

    def _require_manifest(self, *, trip_id: UUID, user_id: UUID, client_session_id: str, session_commit_token: str) -> TripCommitManifest:
        manifest = (
            self.db.query(TripCommitManifest)
            .filter(
                TripCommitManifest.trip_server_id == trip_id,
                TripCommitManifest.user_id == user_id,
                TripCommitManifest.client_session_id == client_session_id,
                TripCommitManifest.session_commit_token == session_commit_token,
            )
            .first()
        )
        if manifest is None:
            self._error(status.HTTP_404_NOT_FOUND, "session_not_found", "Finalize manifest not found.")
        return manifest

    def _session_response(self, row: TripSessionRaw) -> dict[str, Any]:
        return {
            "session_server_id": row.session_server_id,
            "trip_id": row.trip_server_id,
            "client_session_id": row.client_session_id,
            "status": row.status,
            "started_at": row.started_at,
            "ended_at": row.ended_at,
            "stop_server_pending": row.stop_server_pending,
            "stop_client_event_id": row.stop_client_event_id,
            "seal_version": row.seal_version,
            "timezone": row.timezone,
            "commit_token": row.commit_token,
        }

    def start_session(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        started_at: datetime,
        timezone_name: Optional[str],
        device_context: dict[str, Any],
        idempotency_key: str,
    ) -> IdempotencyResult:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)

        def _operation() -> tuple[int, dict[str, Any]]:
            existing = (
                self.db.query(TripSessionRaw)
                .filter(
                    TripSessionRaw.trip_server_id == trip.id,
                    TripSessionRaw.user_id == user_id,
                    TripSessionRaw.client_session_id == client_session_id,
                )
                .first()
            )
            if existing is not None:
                return status.HTTP_200_OK, self._session_response(existing)

            row = TripSessionRaw(
                trip_server_id=trip.id,
                user_id=user_id,
                client_session_id=client_session_id,
                timezone=timezone_name,
                device_id=str(device_context.get("device_id")) if device_context.get("device_id") is not None else None,
                device_context=device_context or {},
                started_at=self._to_utc(started_at),
                status="active",
                stop_server_pending=False,
                seal_version=0,
            )
            self.db.add(row)
            self.db.flush()
            return status.HTTP_200_OK, self._session_response(row)

        return self._run_idempotent_mutation(
            user_id=user_id,
            endpoint_signature="POST:/api/v2/trips/{trip_id}/sessions:start",
            idempotency_key=idempotency_key,
            request_payload={
                "trip_id": str(trip.id),
                "client_session_id": client_session_id,
                "started_at": self._to_utc(started_at).isoformat(),
                "timezone": timezone_name,
                "device_context": device_context or {},
            },
            operation=_operation,
        )

    def stop_session(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        seal_version: int,
        stop_client_event_id: str,
        stopped_at: datetime,
        reason: Optional[str],
        echoed_client_session_id: Optional[str],
        idempotency_key: str,
    ) -> IdempotencyResult:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        if echoed_client_session_id is not None and echoed_client_session_id != client_session_id:
            self._error(status.HTTP_400_BAD_REQUEST, "session_path_body_mismatch", "client_session_id in body does not match path.")

        def _operation() -> tuple[int, dict[str, Any]]:
            row = self._get_session(trip_id=trip.id, user_id=user_id, client_session_id=client_session_id)
            incoming_stopped_at = self._to_utc(stopped_at)
            if row.seal_version > seal_version:
                self._error(status.HTTP_409_CONFLICT, "invalid_payload", "seal_version regressed for stop request.")
            if row.seal_version == seal_version and row.stop_client_event_id == stop_client_event_id and row.ended_at is not None:
                return status.HTTP_200_OK, self._session_response(row)

            row.seal_version = seal_version
            row.stop_client_event_id = stop_client_event_id
            row.ended_at = incoming_stopped_at
            row.status = "sealed"
            row.stop_server_pending = False
            row.stop_reason = reason
            row.updated_at = self._utcnow()
            self.db.flush()
            return status.HTTP_200_OK, self._session_response(row)

        return self._run_idempotent_mutation(
            user_id=user_id,
            endpoint_signature="POST:/api/v2/trips/{trip_id}/sessions/{client_session_id}:stop",
            idempotency_key=idempotency_key,
            request_payload={
                "trip_id": str(trip.id),
                "client_session_id": client_session_id,
                "seal_version": seal_version,
                "stop_client_event_id": stop_client_event_id,
                "stopped_at": self._to_utc(stopped_at).isoformat(),
                "reason": reason,
            },
            operation=_operation,
        )

    def _assert_manifest_step_key(
        self,
        *,
        manifest: TripCommitManifest,
        step_name: str,
        idempotency_key: str,
        fingerprint: str,
    ) -> None:
        entries = dict(manifest.step_idempotency or {})
        entry = entries.get(step_name)
        if entry and entry.get("idempotency_key") == idempotency_key and entry.get("fingerprint") != fingerprint:
            self._idempotency_conflict()
        entries[step_name] = {
            "idempotency_key": idempotency_key,
            "fingerprint": fingerprint,
        }
        manifest.step_idempotency = entries

    def _set_manifest_state(self, manifest: TripCommitManifest, status_value: str, phase_value: str) -> None:
        current = (manifest.status, manifest.phase)
        target = (status_value, phase_value)
        if current == target:
            return
        if manifest.status in TERMINAL_MANIFEST_STATUSES:
            self._error(status.HTTP_409_CONFLICT, "invalid_manifest_state", "Manifest is terminal and cannot transition further.")
        if manifest.status == "failed_retryable" and status_value == "started" and manifest.phase == phase_value:
            manifest.status = status_value
            manifest.phase = phase_value
            return
        if manifest.status == "started" and status_value in {"failed_retryable", "failed_terminal", "idempotency_conflict"} and manifest.phase == phase_value:
            manifest.status = status_value
            manifest.phase = phase_value
            return
        if (current, target) not in MANIFEST_TRANSITIONS:
            self._error(status.HTTP_409_CONFLICT, "invalid_manifest_state", f"Illegal manifest transition {current} -> {target}.")
        manifest.status = target[0]
        manifest.phase = target[1]

    def _mark_manifest_failure(
        self,
        *,
        manifest: TripCommitManifest,
        retryable: bool,
        error_code: str,
        error_message: str,
    ) -> None:
        manifest.error_code = error_code
        manifest.error_message = error_message
        self._set_manifest_state(
            manifest,
            "failed_retryable" if retryable else "failed_terminal",
            manifest.phase,
        )
        manifest.updated_at = self._utcnow()

    def _build_upload_targets(self, *, trip_id: UUID, user_id: UUID, manifest: TripCommitManifest) -> list[dict[str, Any]]:
        targets = []
        for item in manifest.media_manifest or []:
            target = self.storage_service.build_upload_target(
                trip_id=trip_id,
                user_id=user_id,
                session_commit_token=manifest.session_commit_token,
                client_media_id=item["client_media_id"],
            )
            targets.append(
                {
                    "client_media_id": target.client_media_id,
                    "storage_provider": target.storage_provider,
                    "storage_ref": target.storage_ref,
                    "bucket": target.bucket,
                    "object_key": target.object_key,
                }
            )
        return targets

    def finalize_start(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        client_job_id: str,
        schema_version: int,
        session_summary: dict[str, Any],
        media_manifest: list[dict[str, Any]],
        media_manifest_digest: str,
        idempotency_key: str,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        self._require_supported_schema(schema_version)
        session = self._get_session(trip_id=trip.id, user_id=user_id, client_session_id=client_session_id)

        normalized_summary = self._normalize_session_summary(session_summary)
        normalized_manifest = self._normalize_media_manifest(media_manifest)
        expected_digest = self._sha256(normalized_manifest)
        if media_manifest_digest != expected_digest:
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "media_manifest_digest does not match media_manifest.")
        if len(normalized_manifest) > MAX_MEDIA:
            self._error(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "payload_too_large", "Media manifest exceeds the allowed size.")

        fingerprint = self._request_fingerprint(
            {
                "trip_id": str(trip.id),
                "client_session_id": client_session_id,
                "client_job_id": client_job_id,
                "schema_version": schema_version,
                "session_summary": normalized_summary,
                "media_manifest": normalized_manifest,
                "media_manifest_digest": media_manifest_digest,
            }
        )
        existing = (
            self.db.query(TripCommitManifest)
            .filter(
                TripCommitManifest.trip_server_id == trip.id,
                TripCommitManifest.operation_kind == MANIFEST_OPERATION_KIND,
                TripCommitManifest.idempotency_key == idempotency_key,
            )
            .first()
        )
        if existing is not None:
            if existing.request_fingerprint != fingerprint:
                self._idempotency_conflict()
            return status.HTTP_200_OK, {
                "session_commit_token": existing.session_commit_token,
                "manifest_status": existing.status,
                "manifest_phase": existing.phase,
                "accepted_media_count": len(existing.media_manifest or []),
                "upload_targets": self._build_upload_targets(trip_id=trip.id, user_id=user_id, manifest=existing),
            }

        manifest = TripCommitManifest(
            trip_server_id=trip.id,
            user_id=user_id,
            session_server_id=session.session_server_id,
            client_session_id=client_session_id,
            client_job_id=client_job_id,
            session_commit_token=uuid.uuid4().hex,
            idempotency_key=idempotency_key,
            operation_kind=MANIFEST_OPERATION_KIND,
            status="started",
            phase="start_received",
            schema_version=schema_version,
            request_fingerprint=fingerprint,
            session_summary=normalized_summary,
            media_manifest=normalized_manifest,
            media_manifest_digest=media_manifest_digest,
            accepted_media_refs={},
            payload_chunks={},
            step_idempotency={
                "finalize:start": {
                    "idempotency_key": idempotency_key,
                    "fingerprint": fingerprint,
                }
            },
            payload_total_bytes=0,
        )
        session.commit_token = manifest.session_commit_token
        session.schema_version = schema_version
        session.updated_at = self._utcnow()
        self.db.add(manifest)
        self.db.commit()
        return status.HTTP_200_OK, {
            "session_commit_token": manifest.session_commit_token,
            "manifest_status": manifest.status,
            "manifest_phase": manifest.phase,
            "accepted_media_count": len(normalized_manifest),
            "upload_targets": self._build_upload_targets(trip_id=trip.id, user_id=user_id, manifest=manifest),
        }

    def finalize_media_complete(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        session_commit_token: str,
        uploaded_media: list[dict[str, Any]],
        idempotency_key: str,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        manifest = self._require_manifest(
            trip_id=trip.id,
            user_id=user_id,
            client_session_id=client_session_id,
            session_commit_token=session_commit_token,
        )
        normalized_media = self._normalize_media_manifest(uploaded_media)
        fingerprint = self._request_fingerprint(
            {
                "session_commit_token": session_commit_token,
                "uploaded_media": normalized_media,
            }
        )
        self._assert_manifest_step_key(
            manifest=manifest,
            step_name="finalize:media-complete",
            idempotency_key=idempotency_key,
            fingerprint=fingerprint,
        )
        if manifest.status == "committed" and manifest.phase == "finalized":
            return status.HTTP_200_OK, {
                "session_commit_token": manifest.session_commit_token,
                "manifest_status": manifest.status,
                "manifest_phase": manifest.phase,
                "accepted_media_count": len(manifest.accepted_media_refs or {}),
            }

        manifest_lookup = {item["client_media_id"]: item for item in (manifest.media_manifest or [])}
        uploaded_lookup = {item["client_media_id"]: item for item in normalized_media}
        if set(uploaded_lookup.keys()) != set(manifest_lookup.keys()):
            self._mark_manifest_failure(
                manifest=manifest,
                retryable=False,
                error_code="media_ref_invalid",
                error_message="Uploaded media refs do not match the stored media manifest.",
            )
            self.db.commit()
            self._error(status.HTTP_400_BAD_REQUEST, "media_ref_invalid", "Uploaded media refs do not match the stored media manifest.")

        accepted_refs: dict[str, dict[str, Any]] = {}
        for client_media_id in sorted(manifest_lookup.keys()):
            storage_ref = uploaded_lookup[client_media_id]["storage_ref"]
            if not self.storage_service.verify_storage_ref(
                trip_id=trip.id,
                user_id=user_id,
                session_commit_token=session_commit_token,
                client_media_id=client_media_id,
                storage_ref=storage_ref,
            ):
                self._mark_manifest_failure(
                    manifest=manifest,
                    retryable=False,
                    error_code="media_ref_invalid",
                    error_message=f"storage_ref is invalid for media {client_media_id}.",
                )
                self.db.commit()
                self._error(status.HTTP_400_BAD_REQUEST, "media_ref_invalid", f"storage_ref is invalid for media {client_media_id}.")
            accepted_refs[client_media_id] = {
                "storage_ref": storage_ref,
                "mime_type": manifest_lookup[client_media_id].get("mime_type"),
                "size_bytes": manifest_lookup[client_media_id].get("size_bytes"),
                "media_content_hash": manifest_lookup[client_media_id].get("media_content_hash"),
            }

        manifest.accepted_media_refs = accepted_refs
        self._set_manifest_state(manifest, "started", "media_verified")
        manifest.updated_at = self._utcnow()
        self.db.commit()
        return status.HTTP_200_OK, {
            "session_commit_token": manifest.session_commit_token,
            "manifest_status": manifest.status,
            "manifest_phase": manifest.phase,
            "accepted_media_count": len(accepted_refs),
        }

    def finalize_payload_chunk(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        session_commit_token: str,
        chunk_index: int,
        total_chunks: int,
        chunk_content_hash: str,
        chunk_json: str,
        idempotency_key: str,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        manifest = self._require_manifest(
            trip_id=trip.id,
            user_id=user_id,
            client_session_id=client_session_id,
            session_commit_token=session_commit_token,
        )
        if manifest.phase not in {"media_verified", "chunks_complete"} and not (
            manifest.status == "failed_retryable" and manifest.phase == "chunks_complete"
        ):
            self._error(status.HTTP_409_CONFLICT, "invalid_manifest_state", "Chunks can only be accepted after media verification.")

        chunk_bytes = len(chunk_json.encode("utf-8"))
        if chunk_bytes > MAX_CHUNK_BYTES:
            self._mark_manifest_failure(
                manifest=manifest,
                retryable=False,
                error_code="payload_too_large",
                error_message="Chunk exceeds the 128KB limit.",
            )
            self.db.commit()
            self._error(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "payload_too_large", "Chunk exceeds the 128KB limit.")

        fingerprint = self._request_fingerprint(
            {
                "session_commit_token": session_commit_token,
                "chunk_index": chunk_index,
                "total_chunks": total_chunks,
                "chunk_content_hash": chunk_content_hash,
                "chunk_json": chunk_json,
            }
        )
        self._assert_manifest_step_key(
            manifest=manifest,
            step_name=f"finalize:payload-chunk:{chunk_index}",
            idempotency_key=idempotency_key,
            fingerprint=fingerprint,
        )

        chunks = dict(manifest.payload_chunks or {})
        existing = chunks.get(str(chunk_index))
        if existing is not None:
            if existing.get("chunk_content_hash") != chunk_content_hash:
                self._idempotency_conflict()
        else:
            chunks[str(chunk_index)] = {
                "chunk_index": chunk_index,
                "total_chunks": total_chunks,
                "chunk_content_hash": chunk_content_hash,
                "chunk_json": chunk_json,
                "byte_size": chunk_bytes,
            }

        all_totals = {chunk.get("total_chunks") for chunk in chunks.values()}
        if len(all_totals) != 1 or total_chunks not in all_totals:
            self._mark_manifest_failure(
                manifest=manifest,
                retryable=False,
                error_code="invalid_payload",
                error_message="Chunk set disagrees on total_chunks.",
            )
            self.db.commit()
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Chunk set disagrees on total_chunks.")

        payload_total_bytes = sum(int(chunk.get("byte_size", 0)) for chunk in chunks.values())
        if payload_total_bytes > MAX_TOTAL_PAYLOAD_BYTES:
            self._mark_manifest_failure(
                manifest=manifest,
                retryable=False,
                error_code="payload_too_large",
                error_message="Finalize payload exceeds the 64MB limit.",
            )
            self.db.commit()
            self._error(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "payload_too_large", "Finalize payload exceeds the 64MB limit.")

        manifest.payload_chunks = chunks
        manifest.payload_total_bytes = payload_total_bytes
        if len(chunks) == total_chunks and all(str(idx) in chunks for idx in range(total_chunks)):
            self._set_manifest_state(manifest, "started", "chunks_complete")
        manifest.updated_at = self._utcnow()
        self.db.commit()
        return status.HTTP_200_OK, {
            "session_commit_token": manifest.session_commit_token,
            "manifest_status": manifest.status,
            "manifest_phase": manifest.phase,
            "chunk_index": chunk_index,
            "total_chunks": total_chunks,
            "accepted_total_bytes": payload_total_bytes,
        }

    def _materialize_payload(self, manifest: TripCommitManifest) -> dict[str, Any]:
        chunks = dict(manifest.payload_chunks or {})
        if not chunks:
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Finalize payload chunks are missing.")

        total_chunks = next(iter(chunks.values())).get("total_chunks")
        if total_chunks is None or len(chunks) != total_chunks or any(str(idx) not in chunks for idx in range(total_chunks)):
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Finalize payload chunks are incomplete.")

        with tempfile.SpooledTemporaryFile(max_size=1024 * 1024, mode="w+b") as temp_file:
            for idx in range(total_chunks):
                temp_file.write(chunks[str(idx)]["chunk_json"].encode("utf-8"))
            temp_file.seek(0)
            text_wrapper = io.TextIOWrapper(temp_file, encoding="utf-8")
            return json.load(text_wrapper)

    def _bulk_replace_session_rows(
        self,
        *,
        manifest: TripCommitManifest,
        session: TripSessionRaw,
        payload: dict[str, Any],
    ) -> tuple[int, int, int]:
        events = list(payload.get("events") or [])
        media = list(payload.get("media") or [])
        points = list(payload.get("route_points") or [])

        if len(events) > MAX_EVENTS or len(media) > MAX_MEDIA or len(points) > MAX_POINTS:
            self._error(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "payload_too_large", "Finalize snapshot exceeds backend safety limits.")

        summary = manifest.session_summary or {}
        if len(events) != int(summary.get("event_count", len(events))):
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Event count does not match session summary.")
        if len(media) != int(summary.get("media_count", len(media))):
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Media count does not match session summary.")
        if len(points) != int(summary.get("point_count", len(points))):
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Point count does not match session summary.")

        session.schema_version = manifest.schema_version
        session.stop_server_pending = False
        session.commit_token = manifest.session_commit_token
        session.seal_version = int(payload.get("seal_version") or session.seal_version or 0)
        session.stop_client_event_id = payload.get("stop_client_event_id") or session.stop_client_event_id
        if payload.get("ended_at"):
            session.ended_at = self._to_utc(datetime.fromisoformat(str(payload["ended_at"]).replace("Z", "+00:00")))
        if payload.get("started_at"):
            session.started_at = self._to_utc(datetime.fromisoformat(str(payload["started_at"]).replace("Z", "+00:00")))
        session.device_id = payload.get("device_id") or session.device_id
        session.status = "sealed"
        session.updated_at = self._utcnow()

        self.db.query(TripMediaRaw).filter(TripMediaRaw.session_server_id == session.session_server_id).delete()
        self.db.query(TripEventRaw).filter(TripEventRaw.session_server_id == session.session_server_id).delete()
        self.db.query(TripRouteRawPoint).filter(TripRouteRawPoint.session_server_id == session.session_server_id).delete()
        self.db.flush()

        event_id_map: dict[str, UUID] = {}
        event_rows: list[dict[str, Any]] = []
        for item in events:
            client_event_id = str(item["event_id"])
            server_event_id = uuid.uuid4()
            event_id_map[client_event_id] = server_event_id
            event_rows.append(
                {
                    "event_server_id": server_event_id,
                    "trip_server_id": session.trip_server_id,
                    "session_server_id": session.session_server_id,
                    "client_event_id": client_event_id,
                    "event_type": item["event_type"],
                    "captured_at": self._to_utc(datetime.fromisoformat(str(item["captured_at"]).replace("Z", "+00:00"))),
                    "latitude": float(item["latitude"]),
                    "longitude": float(item["longitude"]),
                    "resolver_state": item["resolver_state"],
                    "decision_source": item.get("decision_source"),
                    "manual_lock": bool(item.get("manual_lock", 0)),
                    "place_bind_kind": item.get("place_bind_kind"),
                    "place_bind_id": item.get("place_bind_id"),
                    "place_bind_name": item.get("place_bind_name"),
                    "geotag_final_reason": item.get("geotag_final_reason"),
                    "payload_json": item.get("payload_json"),
                    "event_seq": item.get("event_seq"),
                    "captured_while_paused": bool(item.get("captured_while_paused", 0)),
                    "candidate_set_version": int(item.get("candidate_set_version", 0)),
                    "resolved_at": self._to_utc(datetime.fromisoformat(str(item["resolved_at"]).replace("Z", "+00:00"))) if item.get("resolved_at") else None,
                    "created_at": self._to_utc(datetime.fromisoformat(str(item["created_at"]).replace("Z", "+00:00"))),
                    "updated_at": self._to_utc(datetime.fromisoformat(str(item["updated_at"]).replace("Z", "+00:00"))),
                }
            )

        if event_rows:
            self.db.bulk_insert_mappings(TripEventRaw, event_rows)

        accepted_media_refs = dict(manifest.accepted_media_refs or {})
        media_rows: list[dict[str, Any]] = []
        for item in media:
            client_media_id = str(item["media_id"])
            client_event_id = str(item["event_id"])
            event_server_id = event_id_map.get(client_event_id)
            accepted_media = accepted_media_refs.get(client_media_id)
            if event_server_id is None or accepted_media is None:
                self._error(status.HTTP_400_BAD_REQUEST, "media_ref_invalid", f"Media {client_media_id} does not map to an accepted event/storage ref.")
            media_rows.append(
                {
                    "media_server_id": uuid.uuid4(),
                    "trip_server_id": session.trip_server_id,
                    "session_server_id": session.session_server_id,
                    "event_server_id": event_server_id,
                    "client_media_id": client_media_id,
                    "captured_at": self._to_utc(datetime.fromisoformat(str(item["captured_at"]).replace("Z", "+00:00"))),
                    "media_type": item["media_type"],
                    "storage_ref": accepted_media["storage_ref"],
                    "mime_type": item.get("mime_type"),
                    "bytes_size": item.get("bytes_size"),
                    "width_px": item.get("width_px"),
                    "height_px": item.get("height_px"),
                    "duration_ms": item.get("duration_ms"),
                    "created_at": self._to_utc(datetime.fromisoformat(str(item["created_at"]).replace("Z", "+00:00"))),
                    "updated_at": self._to_utc(datetime.fromisoformat(str(item["updated_at"]).replace("Z", "+00:00"))),
                }
            )
        if media_rows:
            self.db.bulk_insert_mappings(TripMediaRaw, media_rows)

        point_rows: list[dict[str, Any]] = []
        for item in points:
            point_rows.append(
                {
                    "point_server_id": uuid.uuid4(),
                    "trip_server_id": session.trip_server_id,
                    "session_server_id": session.session_server_id,
                    "client_point_id": item.get("point_id"),
                    "captured_at": self._to_utc(datetime.fromisoformat(str(item["captured_at"]).replace("Z", "+00:00"))),
                    "latitude": float(item["latitude"]),
                    "longitude": float(item["longitude"]),
                    "accuracy_m": item.get("accuracy_m"),
                    "speed_mps": item.get("speed_mps"),
                    "bearing_deg": item.get("bearing_deg"),
                    "altitude_m": item.get("altitude_m"),
                    "source": item.get("source"),
                    "point_seq": int(item["point_seq"]),
                }
            )
        if point_rows:
            self.db.bulk_insert_mappings(TripRouteRawPoint, point_rows)

        manifest.raw_ingest_completed_at = self._utcnow()
        self._set_manifest_state(manifest, "started", "raw_ingest_completed")
        manifest.updated_at = self._utcnow()
        return len(event_rows), len(media_rows), len(point_rows)

    def _bucket_type_for_event(self, resolver_state: str) -> str:
        if resolver_state == "place_bound":
            return "place"
        if resolver_state in {"review_required", "geotag_unresolved"}:
            return "needs_review"
        return "on_route"

    def _title_for_event(self, event: TripEventRaw, media_count: int) -> str:
        if event.place_bind_name:
            return event.place_bind_name
        if event.event_type == "photo" and media_count > 0:
            return "Photo capture"
        if event.event_type == "media" and media_count > 0:
            return "Media capture"
        return event.event_type.replace("_", " ").title()

    def _subtitle_for_event(self, event: TripEventRaw, media_count: int) -> Optional[str]:
        payload = event.payload_json or {}
        note = payload.get("note") if isinstance(payload, dict) else None
        if isinstance(note, str) and note.strip():
            return note.strip()
        if media_count > 0:
            return f"{media_count} linked media item(s)"
        if event.resolver_state == "review_required":
            return "Needs review"
        if event.resolver_state == "geotag_unresolved":
            return "Geotag unresolved"
        return None

    def _simplify_points(self, points: list[_SessionPoint], max_points: int) -> tuple[list[_SessionPoint], bool]:
        if len(points) <= max_points:
            return points, False
        if max_points <= 2:
            return [points[0], points[-1]], True
        step = (len(points) - 1) / float(max_points - 1)
        simplified = [points[0]]
        for idx in range(1, max_points - 1):
            simplified.append(points[int(round(idx * step))])
        simplified.append(points[-1])
        return simplified, True

    def _route_association(
        self,
        *,
        event: TripEventRaw,
        session_key: str,
        timestamps: list[datetime],
        points: list[_SessionPoint],
    ) -> _RouteAssociation:
        if not points:
            return _RouteAssociation(segment_key=None, distance_m=None)

        captured_at = self._to_utc(event.captured_at)
        idx = bisect_left(timestamps, captured_at)
        candidate_indexes = {max(0, min(len(points) - 1, idx))}
        if idx > 0:
            candidate_indexes.add(idx - 1)

        def _collect(window_seconds: int) -> list[_SessionPoint]:
            candidates: list[_SessionPoint] = []
            for point_idx in candidate_indexes:
                left = point_idx
                while left > 0 and abs((timestamps[left - 1] - captured_at).total_seconds()) <= window_seconds:
                    left -= 1
                right = point_idx
                while right + 1 < len(points) and abs((timestamps[right + 1] - captured_at).total_seconds()) <= window_seconds:
                    right += 1
                for scan in range(left, right + 1):
                    candidates.append(points[scan])
            unique: dict[tuple[datetime, int], _SessionPoint] = {}
            for point in candidates:
                unique[(point.captured_at, point.point_seq)] = point
            ordered = sorted(
                unique.values(),
                key=lambda point: abs((point.captured_at - captured_at).total_seconds()),
            )
            return ordered[:ROUTE_ASSOCIATION_CANDIDATE_CAP]

        candidates = _collect(ROUTE_ASSOCIATION_PRIMARY_WINDOW_SECONDS)
        if len(candidates) < 2:
            candidates = _collect(ROUTE_ASSOCIATION_FALLBACK_WINDOW_SECONDS)
        if not candidates:
            return _RouteAssociation(segment_key=None, distance_m=None)

        min_distance = min(
            haversine_distance(
                event.latitude,
                event.longitude,
                point.latitude,
                point.longitude,
            )
            for point in candidates
        )
        if min_distance > ROUTE_ASSOCIATION_THRESHOLD_M:
            return _RouteAssociation(segment_key=None, distance_m=min_distance)
        return _RouteAssociation(segment_key=session_key, distance_m=min_distance)

    def _compile_trip_projection(self, *, trip_id: UUID, user_id: UUID) -> datetime:
        started = time.monotonic()
        compiled_at = self._utcnow()

        sessions = (
            self.db.query(TripSessionRaw)
            .filter(
                TripSessionRaw.trip_server_id == trip_id,
                TripSessionRaw.user_id == user_id,
            )
            .order_by(TripSessionRaw.started_at.asc(), TripSessionRaw.client_session_id.asc())
            .all()
        )
        events = (
            self.db.query(TripEventRaw)
            .filter(TripEventRaw.trip_server_id == trip_id)
            .order_by(TripEventRaw.captured_at.asc(), TripEventRaw.client_event_id.asc())
            .all()
        )
        media = (
            self.db.query(TripMediaRaw)
            .filter(TripMediaRaw.trip_server_id == trip_id)
            .order_by(TripMediaRaw.captured_at.asc(), TripMediaRaw.client_media_id.asc())
            .all()
        )
        points = (
            self.db.query(TripRouteRawPoint)
            .filter(TripRouteRawPoint.trip_server_id == trip_id)
            .order_by(TripRouteRawPoint.session_server_id.asc(), TripRouteRawPoint.point_seq.asc())
            .all()
        )

        self.db.query(TripTimelineProjectionV2).filter(TripTimelineProjectionV2.trip_server_id == trip_id).delete()
        self.db.query(TripRouteProjectionV2).filter(TripRouteProjectionV2.trip_server_id == trip_id).delete()
        self.db.flush()

        session_points: dict[UUID, list[_SessionPoint]] = {}
        route_rows: list[TripRouteProjectionV2] = []
        session_segment_key: dict[UUID, str] = {}
        for index, session in enumerate(sessions):
            raw_points = [
                _SessionPoint(
                    captured_at=self._to_utc(point.captured_at),
                    latitude=float(point.latitude),
                    longitude=float(point.longitude),
                    point_seq=int(point.point_seq),
                )
                for point in points
                if point.session_server_id == session.session_server_id
            ]
            session_points[session.session_server_id] = raw_points
            if not raw_points:
                continue
            segment_key = f"session:{session.client_session_id}"
            session_segment_key[session.session_server_id] = segment_key
            simplified, simplified_flag = self._simplify_points(raw_points, ROUTE_MAX_POINTS_RETURNED)
            route_rows.append(
                TripRouteProjectionV2(
                    trip_server_id=trip_id,
                    session_server_id=session.session_server_id,
                    segment_key=segment_key,
                    segment_index=index,
                    started_at=raw_points[0].captured_at,
                    ended_at=raw_points[-1].captured_at,
                    point_count=len(simplified),
                    raw_point_count=len(raw_points),
                    geometry_json={
                        "points": [
                            {
                                "latitude": point.latitude,
                                "longitude": point.longitude,
                                "captured_at": point.captured_at.isoformat(),
                            }
                            for point in simplified
                        ]
                    },
                    is_simplified=simplified_flag,
                    compiler_version=ROUTE_COMPILER_VERSION,
                    compiled_at=compiled_at,
                )
            )

        if route_rows:
            self.db.add_all(route_rows)
            self.db.flush()

        media_by_event: dict[UUID, list[TripMediaRaw]] = {}
        for item in media:
            media_by_event.setdefault(item.event_server_id, []).append(item)

        timeline_rows: list[TripTimelineProjectionV2] = []
        seen_media: set[UUID] = set()
        for event in events:
            if (time.monotonic() - started) * 1000 > MAX_PROJECTION_COMPILE_MS:
                raise TimeoutError("projection compile exceeded the 10s timeout")
            linked_media = media_by_event.get(event.event_server_id, [])
            seen_media.update(item.media_server_id for item in linked_media)
            segment_key = session_segment_key.get(event.session_server_id)
            points_for_session = session_points.get(event.session_server_id, [])
            timestamps = [point.captured_at for point in points_for_session]
            association = self._route_association(
                event=event,
                session_key=segment_key or "",
                timestamps=timestamps,
                points=points_for_session,
            )
            timeline_rows.append(
                TripTimelineProjectionV2(
                    trip_server_id=trip_id,
                    session_server_id=event.session_server_id,
                    entry_id=f"event:{event.client_event_id}",
                    entry_kind="event",
                    source_server_id=event.event_server_id,
                    captured_at=self._to_utc(event.captured_at),
                    bucket_type=self._bucket_type_for_event(event.resolver_state),
                    place_bind_name=event.place_bind_name,
                    place_bind_id=event.place_bind_id,
                    decision_source=event.decision_source,
                    manual_lock=bool(event.manual_lock),
                    anchor_latitude=float(event.latitude),
                    anchor_longitude=float(event.longitude),
                    route_segment_key=association.segment_key,
                    route_distance_m=association.distance_m,
                    title=self._title_for_event(event, len(linked_media)),
                    subtitle=self._subtitle_for_event(event, len(linked_media)),
                    render_payload_json={
                        "event_type": event.event_type,
                        "resolver_state": event.resolver_state,
                        "payload": event.payload_json,
                        "media": [
                            {
                                "client_media_id": item.client_media_id,
                                "media_type": item.media_type,
                                "storage_ref": item.storage_ref,
                                "mime_type": item.mime_type,
                                "bytes_size": item.bytes_size,
                            }
                            for item in linked_media
                        ],
                    },
                    compiler_version=TIMELINE_COMPILER_VERSION,
                    compiled_at=compiled_at,
                )
            )

        for item in media:
            if item.media_server_id in seen_media:
                continue
            timeline_rows.append(
                TripTimelineProjectionV2(
                    trip_server_id=trip_id,
                    session_server_id=item.session_server_id,
                    entry_id=f"media:{item.client_media_id}",
                    entry_kind="media",
                    source_server_id=item.media_server_id,
                    captured_at=self._to_utc(item.captured_at),
                    bucket_type="on_route",
                    place_bind_name=None,
                    place_bind_id=None,
                    decision_source=None,
                    manual_lock=False,
                    anchor_latitude=0.0,
                    anchor_longitude=0.0,
                    route_segment_key=session_segment_key.get(item.session_server_id),
                    route_distance_m=None,
                    title=item.media_type.replace("_", " ").title(),
                    subtitle=item.mime_type,
                    render_payload_json={
                        "client_media_id": item.client_media_id,
                        "storage_ref": item.storage_ref,
                        "mime_type": item.mime_type,
                        "bytes_size": item.bytes_size,
                    },
                    compiler_version=TIMELINE_COMPILER_VERSION,
                    compiled_at=compiled_at,
                )
            )

        if timeline_rows:
            self.db.add_all(timeline_rows)
            self.db.flush()
        return compiled_at

    def finalize_commit(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        session_commit_token: str,
        schema_version: int,
        idempotency_key: str,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        server_trip_id = trip.id
        self._require_supported_schema(schema_version)
        manifest = self._require_manifest(
            trip_id=server_trip_id,
            user_id=user_id,
            client_session_id=client_session_id,
            session_commit_token=session_commit_token,
        )
        session = self._get_session(trip_id=server_trip_id, user_id=user_id, client_session_id=client_session_id)
        fingerprint = self._request_fingerprint(
            {
                "session_commit_token": session_commit_token,
                "schema_version": schema_version,
                "accepted_media_refs": manifest.accepted_media_refs,
                "payload_chunk_hashes": {
                    key: value.get("chunk_content_hash")
                    for key, value in sorted((manifest.payload_chunks or {}).items(), key=lambda item: int(item[0]))
                },
            }
        )
        self._assert_manifest_step_key(
            manifest=manifest,
            step_name="finalize:commit",
            idempotency_key=idempotency_key,
            fingerprint=fingerprint,
        )
        if manifest.schema_version != schema_version:
            self._error(status.HTTP_422_UNPROCESSABLE_ENTITY, "unsupported_schema", "schema_version does not match the manifest.")
        if manifest.status == "committed" and manifest.phase == "finalized":
            compiled_at = manifest.committed_at or manifest.projection_compiled_at or self._utcnow()
            counts = manifest.session_summary or {}
            return status.HTTP_200_OK, {
                "session_commit_token": manifest.session_commit_token,
                "manifest_status": manifest.status,
                "manifest_phase": manifest.phase,
                "session_server_id": session.session_server_id,
                "accepted_event_count": int(counts.get("event_count", 0)),
                "accepted_media_count": int(counts.get("media_count", 0)),
                "accepted_point_count": int(counts.get("point_count", 0)),
                "compiled_at": compiled_at,
            }
        if manifest.phase not in {"chunks_complete", "raw_ingest_completed"} and not (
            manifest.status == "failed_retryable" and manifest.phase == "raw_ingest_completed"
        ):
            self._error(status.HTTP_409_CONFLICT, "invalid_manifest_state", "Manifest is not ready for finalize:commit.")

        event_count = 0
        media_count = 0
        point_count = 0
        if manifest.phase != "raw_ingest_completed":
            payload = self._materialize_payload(manifest)
            try:
                event_count, media_count, point_count = self._bulk_replace_session_rows(
                    manifest=manifest,
                    session=session,
                    payload=payload,
                )
                self.db.commit()
            except HTTPException:
                self.db.rollback()
                manifest = self._require_manifest(
                    trip_id=server_trip_id,
                    user_id=user_id,
                    client_session_id=client_session_id,
                    session_commit_token=session_commit_token,
                )
                self._mark_manifest_failure(
                    manifest=manifest,
                    retryable=False,
                    error_code="invalid_payload",
                    error_message="Finalize payload validation failed during raw ingest.",
                )
                self.db.commit()
                raise
        else:
            counts = manifest.session_summary or {}
            event_count = int(counts.get("event_count", 0))
            media_count = int(counts.get("media_count", 0))
            point_count = int(counts.get("point_count", 0))

        manifest = self._require_manifest(
            trip_id=server_trip_id,
            user_id=user_id,
            client_session_id=client_session_id,
            session_commit_token=session_commit_token,
        )
        if manifest.status == "failed_retryable":
            self._set_manifest_state(manifest, "started", manifest.phase)
            self.db.commit()
            manifest = self._require_manifest(
                trip_id=server_trip_id,
                user_id=user_id,
                client_session_id=client_session_id,
                session_commit_token=session_commit_token,
            )

        try:
            with self.db.begin_nested():
                compiled_at = self._compile_trip_projection(trip_id=server_trip_id, user_id=user_id)
                manifest.projection_compiled_at = compiled_at
                self._set_manifest_state(manifest, "started", "projection_compiled")
                manifest.response_fingerprint = fingerprint
                manifest.committed_at = compiled_at
                session.status = "committed"
                session.updated_at = compiled_at
                self._set_manifest_state(manifest, "committed", "finalized")
                manifest.updated_at = compiled_at
            self.db.commit()
        except TimeoutError as exc:
            manifest = self._require_manifest(
                trip_id=server_trip_id,
                user_id=user_id,
                client_session_id=client_session_id,
                session_commit_token=session_commit_token,
            )
            self._mark_manifest_failure(
                manifest=manifest,
                retryable=True,
                error_code="projection_retryable",
                error_message=str(exc),
            )
            self.db.commit()
            self._error(status.HTTP_503_SERVICE_UNAVAILABLE, "projection_retryable", str(exc))

        return status.HTTP_200_OK, {
            "session_commit_token": manifest.session_commit_token,
            "manifest_status": manifest.status,
            "manifest_phase": manifest.phase,
            "session_server_id": session.session_server_id,
            "accepted_event_count": event_count,
            "accepted_media_count": media_count,
            "accepted_point_count": point_count,
            "compiled_at": manifest.committed_at,
        }

    def _encode_cursor(self, payload: dict[str, Any]) -> str:
        return base64.urlsafe_b64encode(self._canonical_json(payload).encode("utf-8")).decode("utf-8")

    def _decode_cursor(self, cursor: Optional[str]) -> Optional[dict[str, Any]]:
        if not cursor:
            return None
        try:
            raw = base64.urlsafe_b64decode(cursor.encode("utf-8")).decode("utf-8")
            return json.loads(raw)
        except Exception:
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_cursor", "Cursor is invalid.")

    def get_timeline(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        cursor: Optional[str],
        limit: int,
    ) -> dict[str, Any]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        if limit < TIMELINE_LIMIT_MIN or limit > TIMELINE_LIMIT_MAX:
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "Timeline limit must be between 1 and 200.")
        query = self.db.query(TripTimelineProjectionV2).filter(
            TripTimelineProjectionV2.trip_server_id == trip.id
        )
        decoded = self._decode_cursor(cursor)
        if decoded:
            captured_at = self._to_utc(datetime.fromisoformat(decoded["captured_at"].replace("Z", "+00:00")))
            entry_id = decoded["entry_id"]
            query = query.filter(
                or_(
                    TripTimelineProjectionV2.captured_at > captured_at,
                    and_(
                        TripTimelineProjectionV2.captured_at == captured_at,
                        TripTimelineProjectionV2.entry_id > entry_id,
                    ),
                )
            )
        rows = (
            query
            .order_by(TripTimelineProjectionV2.captured_at.asc(), TripTimelineProjectionV2.entry_id.asc())
            .limit(limit + 1)
            .all()
        )
        has_more = len(rows) > limit
        visible = rows[:limit]
        next_cursor = None
        if has_more and visible:
            last = visible[-1]
            next_cursor = self._encode_cursor(
                {
                    "captured_at": self._to_utc(last.captured_at).isoformat(),
                    "entry_id": last.entry_id,
                }
            )
        compiled_at = (
            self.db.query(func.max(TripTimelineProjectionV2.compiled_at))
            .filter(TripTimelineProjectionV2.trip_server_id == trip.id)
            .scalar()
        )
        return {
            "entries": [
                {
                    "entry_id": row.entry_id,
                    "entry_kind": row.entry_kind,
                    "source_server_id": row.source_server_id,
                    "captured_at": row.captured_at,
                    "bucket_type": row.bucket_type,
                    "place_bind_name": row.place_bind_name,
                    "place_bind_id": row.place_bind_id,
                    "decision_source": row.decision_source,
                    "manual_lock": bool(row.manual_lock),
                    "anchor_latitude": row.anchor_latitude,
                    "anchor_longitude": row.anchor_longitude,
                    "route_segment_key": row.route_segment_key,
                    "route_distance_m": row.route_distance_m,
                    "title": row.title,
                    "subtitle": row.subtitle,
                    "render_payload_json": row.render_payload_json,
                }
                for row in visible
            ],
            "next_cursor": next_cursor,
            "has_more": has_more,
            "compiled_at": compiled_at,
            "compiler_version": TIMELINE_COMPILER_VERSION,
        }

    def get_route(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        cursor: Optional[str],
        limit_segments: int,
    ) -> dict[str, Any]:
        trip = self._require_v2_trip(trip_id=trip_id, user_id=user_id)
        if limit_segments < 1 or limit_segments > ROUTE_LIMIT_SEGMENTS_MAX:
            self._error(status.HTTP_400_BAD_REQUEST, "invalid_payload", "limit_segments must be between 1 and 20.")
        query = self.db.query(TripRouteProjectionV2).filter(
            TripRouteProjectionV2.trip_server_id == trip.id
        )
        decoded = self._decode_cursor(cursor)
        if decoded:
            segment_index = int(decoded["segment_index"])
            segment_key = decoded["segment_key"]
            query = query.filter(
                or_(
                    TripRouteProjectionV2.segment_index > segment_index,
                    and_(
                        TripRouteProjectionV2.segment_index == segment_index,
                        TripRouteProjectionV2.segment_key > segment_key,
                    ),
                )
            )
        rows = (
            query
            .order_by(TripRouteProjectionV2.segment_index.asc(), TripRouteProjectionV2.segment_key.asc())
            .limit(limit_segments + 1)
            .all()
        )
        has_more = len(rows) > limit_segments
        visible = rows[:limit_segments]
        next_cursor = None
        if has_more and visible:
            last = visible[-1]
            next_cursor = self._encode_cursor(
                {
                    "segment_index": last.segment_index,
                    "segment_key": last.segment_key,
                }
            )
        total_segments = max(len(visible), 1)
        per_segment_budget = max(2, ROUTE_MAX_POINTS_RETURNED // total_segments)
        segments: list[dict[str, Any]] = []
        for row in visible:
            raw_points = [
                _SessionPoint(
                    captured_at=self._to_utc(datetime.fromisoformat(str(point["captured_at"]).replace("Z", "+00:00"))) if point.get("captured_at") else row.started_at,
                    latitude=float(point["latitude"]),
                    longitude=float(point["longitude"]),
                    point_seq=index,
                )
                for index, point in enumerate((row.geometry_json or {}).get("points", []))
            ]
            simplified, response_simplified = self._simplify_points(raw_points, per_segment_budget)
            segments.append(
                {
                    "segment_key": row.segment_key,
                    "session_server_id": row.session_server_id,
                    "started_at": row.started_at,
                    "ended_at": row.ended_at,
                    "point_count": len(simplified),
                    "raw_point_count": row.raw_point_count,
                    "is_simplified": bool(row.is_simplified or response_simplified),
                    "points": [
                        {
                            "latitude": point.latitude,
                            "longitude": point.longitude,
                            "captured_at": point.captured_at,
                        }
                        for point in simplified
                    ],
                }
            )
        compiled_at = (
            self.db.query(func.max(TripRouteProjectionV2.compiled_at))
            .filter(TripRouteProjectionV2.trip_server_id == trip.id)
            .scalar()
        )
        return {
            "segments": segments,
            "has_more": has_more,
            "next_cursor": next_cursor,
            "compiled_at": compiled_at,
            "compiler_version": ROUTE_COMPILER_VERSION,
        }
