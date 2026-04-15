"""
Service layer for live-tracking Phase 2 APIs.
"""

from __future__ import annotations

import hashlib
import json
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Callable, Optional
from uuid import UUID

from fastapi import HTTPException, UploadFile, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy import and_, desc, func, or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.config import settings
from app.models.api_idempotency_record import ApiIdempotencyRecord
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.trip_checkin_candidate import TripCheckinCandidate
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_moment import TripMoment
from app.models.trip_tracking_event import TripTrackingEvent
from app.models.trip_tracking_notification import TripTrackingNotification
from app.models.trip_tracking_notification_event import TripTrackingNotificationEvent
from app.models.trip_tracking_session import TripTrackingSession
from app.models.trip_tracking_event_media import TripTrackingEventMedia
from app.models.user import User
from app.models.user_device_token import UserDeviceToken
from app.services.storage_service import StorageConfigurationError, StorageService
from app.services.trip_projection_compiler import TripProjectionCompilerService
from app.utils.geo import haversine_distance


IDEMPOTENCY_TTL_HOURS = 72
REJECT_COOLDOWN_HOURS = 24
TRACKING_EVENT_TYPES = {"note", "warn", "tag", "photo", "media"}
TRACKING_MEDIA_TYPES = {"photo", "media"}
TRACKING_MEDIA_BIND_MODES = {"place", "route"}
TRACKING_MEDIA_UPLOAD_ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "video/mp4",
    "video/quicktime",
    "video/webm",
}


@dataclass
class IdempotencyResult:
    status_code: int
    body: dict[str, Any]
    replayed: bool


class LiveTrackingService:
    """Business logic for live-tracking APIs."""

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def _utcnow() -> datetime:
        return datetime.now(timezone.utc)

    @staticmethod
    def _to_utc(value: datetime) -> datetime:
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    @staticmethod
    def _parse_uuid(value: Any) -> Optional[UUID]:
        if value is None:
            return None
        if isinstance(value, UUID):
            return value
        raw = str(value).strip()
        if not raw:
            return None
        try:
            return UUID(raw)
        except (ValueError, TypeError, AttributeError):
            return None

    def _coerce_datetime(self, value: Any) -> Optional[datetime]:
        if value is None:
            return None
        if isinstance(value, datetime):
            return self._to_utc(value)
        if isinstance(value, str):
            raw = value.strip()
            if not raw:
                return None
            normalized = raw[:-1] + "+00:00" if raw.endswith("Z") else raw
            try:
                parsed = datetime.fromisoformat(normalized)
            except ValueError:
                return None
            return self._to_utc(parsed)
        return None

    @staticmethod
    def _json_hash(payload: dict[str, Any]) -> str:
        normalized = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str)
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

    @staticmethod
    def _is_valid_coordinate(*, latitude: float, longitude: float) -> bool:
        return -90.0 <= latitude <= 90.0 and -180.0 <= longitude <= 180.0

    def _idempotency_conflict(self) -> None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "error_code": "idempotency_conflict",
                "message": "X-Idempotency-Key was reused with a different payload.",
                "request_id": str(uuid.uuid4()),
            },
        )

    @staticmethod
    def _extract_constraint_name(error: IntegrityError) -> Optional[str]:
        orig = getattr(error, "orig", None)
        diag = getattr(orig, "diag", None)
        if diag is not None:
            constraint_name = getattr(diag, "constraint_name", None)
            if constraint_name:
                return constraint_name

        message = str(orig or error)
        known_constraints = (
            "uq_idempotency_user_endpoint_key",
            "uq_tracking_session_active_trip_user",
            "uq_tracking_point_session_point",
            "uq_checkin_candidate_active_fingerprint",
            "uq_user_device_tokens_push_token",
            "uq_user_device_tokens_user_token",
            "uq_tracking_event_trip_user_client_event",
            "uq_tracking_event_media_trip_user_client_media",
        )
        for constraint in known_constraints:
            if constraint in message:
                return constraint
        return None

    def run_idempotent_mutation(
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
        request_hash = self._json_hash(payload)

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
                return IdempotencyResult(
                    status_code=record.response_status,
                    body=record.response_body or {},
                    replayed=True,
                )

        try:
            status_code, response_body = operation()
            encoded_body = jsonable_encoder(response_body)
            self.db.add(
                ApiIdempotencyRecord(
                    user_id=user_id,
                    endpoint_signature=endpoint_signature,
                    idempotency_key=idempotency_key,
                    request_hash=request_hash,
                    response_status=status_code,
                    response_body=encoded_body,
                    replay_count=0,
                    first_seen_at=now,
                    expires_at=now + timedelta(hours=IDEMPOTENCY_TTL_HOURS),
                )
            )
            self.db.commit()
            return IdempotencyResult(
                status_code=status_code,
                body=encoded_body,
                replayed=False,
            )
        except HTTPException:
            self.db.rollback()
            raise
        except IntegrityError as exc:
            constraint_name = self._extract_constraint_name(exc)
            self.db.rollback()

            if constraint_name == "uq_idempotency_user_endpoint_key":
                # Race on idempotency key insert. Replay canonical record.
                replay = (
                    self.db.query(ApiIdempotencyRecord)
                    .filter(
                        ApiIdempotencyRecord.user_id == user_id,
                        ApiIdempotencyRecord.endpoint_signature == endpoint_signature,
                        ApiIdempotencyRecord.idempotency_key == idempotency_key,
                    )
                    .first()
                )
                if not replay:
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail="Idempotent request is still being resolved, retry shortly",
                    )
                if replay.request_hash != request_hash:
                    self._idempotency_conflict()
                replay.replay_count += 1
                replay.last_replayed_at = now
                self.db.commit()
                return IdempotencyResult(
                    status_code=replay.response_status,
                    body=replay.response_body or {},
                    replayed=True,
                )

            if constraint_name == "uq_tracking_session_active_trip_user":
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Tracking session already active for trip",
                )

            if constraint_name in {
                "uq_tracking_point_session_point",
                "uq_checkin_candidate_active_fingerprint",
                "uq_user_device_tokens_push_token",
                "uq_user_device_tokens_user_token",
                "uq_tracking_event_trip_user_client_event",
                "uq_tracking_event_media_trip_user_client_media",
            }:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Concurrent mutation conflict, retry with a new idempotency key",
                )

            raise

    def _get_owned_trip(self, *, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
        if trip.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not own this trip")
        return trip

    def _session_payload(self, *, session: TripTrackingSession, trip: Trip) -> dict[str, Any]:
        return {
            "session_id": session.id,
            "trip_id": session.trip_id,
            "user_id": session.user_id,
            "state": session.state,
            "client_session_id": session.client_session_id,
            "started_at": session.started_at,
            "paused_at": session.paused_at,
            "resumed_at": session.resumed_at,
            "ended_at": session.ended_at,
            "abandoned_at": session.abandoned_at,
            "last_point_at": session.last_point_at,
            "timezone": session.timezone,
            "device_context": session.device_context or {},
            "trip_status": trip.status,
            "tracking_enabled": trip.tracking_enabled,
            "tracking_started_at": trip.tracking_started_at,
            "tracking_ended_at": trip.tracking_ended_at,
        }

    def _candidate_payload(self, candidate: TripCheckinCandidate) -> dict[str, Any]:
        return {
            "id": candidate.id,
            "trip_id": candidate.trip_id,
            "user_id": candidate.user_id,
            "session_id": candidate.session_id,
            "fingerprint": candidate.fingerprint,
            "status": candidate.status,
            "confidence": candidate.confidence,
            "suggested_name": candidate.suggested_name,
            "suggested_latitude": candidate.suggested_latitude,
            "suggested_longitude": candidate.suggested_longitude,
            "started_at": candidate.started_at,
            "ended_at": candidate.ended_at,
            "confirmed_trip_place_id": candidate.confirmed_trip_place_id,
            "rejected_reason": candidate.rejected_reason,
            "snoozed_until": candidate.snoozed_until,
            "cooldown_until": candidate.cooldown_until,
            "payload": candidate.payload or {},
            "created_at": candidate.created_at,
            "updated_at": candidate.updated_at,
        }

    def _moment_payload(self, moment: TripMoment) -> dict[str, Any]:
        return {
            "id": moment.id,
            "trip_id": moment.trip_id,
            "user_id": moment.user_id,
            "candidate_id": moment.candidate_id,
            "linked_trip_place_id": moment.linked_trip_place_id,
            "source": moment.source,
            "confidence": moment.confidence,
            "captured_at": moment.captured_at,
            "latitude": moment.latitude,
            "longitude": moment.longitude,
            "note": moment.note,
            "media_refs": moment.media_refs or [],
            "extra_payload": moment.extra_payload or {},
            "locked_fields": moment.locked_fields or {},
            "created_at": moment.created_at,
            "updated_at": moment.updated_at,
        }

    def _device_token_payload(self, token_row: UserDeviceToken) -> dict[str, Any]:
        hint = token_row.push_token[-8:] if token_row.push_token and len(token_row.push_token) >= 8 else token_row.push_token
        return {
            "id": token_row.id,
            "user_id": token_row.user_id,
            "platform": token_row.platform,
            "device_id": token_row.device_id,
            "app_version": token_row.app_version,
            "locale": token_row.locale,
            "is_active": token_row.is_active,
            "failure_count": token_row.failure_count,
            "last_seen_at": token_row.last_seen_at,
            "last_sent_at": token_row.last_sent_at,
            "created_at": token_row.created_at,
            "updated_at": token_row.updated_at,
            "token_hint": hint,
        }

    def _mark_candidate_inbox_acted(
        self,
        *,
        candidate: TripCheckinCandidate,
        acted_at: datetime,
    ) -> None:
        acted_at_utc = self._to_utc(acted_at)
        notifications = (
            self.db.query(TripTrackingNotification)
            .filter(
                TripTrackingNotification.candidate_id == candidate.id,
                TripTrackingNotification.channel == "inbox",
            )
            .all()
        )
        for notification in notifications:
            notification.delivery_state = "acted"
            notification.acknowledged_at = acted_at_utc
            notification.last_error = None
            payload = dict(notification.payload or {})
            payload["candidate_status"] = candidate.status
            payload["acted_at"] = acted_at_utc.isoformat()
            notification.payload = payload
            self.db.add(
                TripTrackingNotificationEvent(
                    notification_id=notification.id,
                    trip_id=notification.trip_id,
                    user_id=notification.user_id,
                    candidate_id=notification.candidate_id,
                    channel=notification.channel,
                    event_type="action",
                    delivery_state=notification.delivery_state,
                    attempt_count=int(notification.attempt_count or 0),
                    last_error=notification.last_error,
                    payload=dict(notification.payload or {}),
                    created_at=acted_at_utc,
                )
            )

    def _get_event_session(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: Optional[UUID],
        allowed_states: tuple[str, ...],
    ) -> TripTrackingSession:
        query = self.db.query(TripTrackingSession).filter(
            TripTrackingSession.trip_id == trip_id,
            TripTrackingSession.user_id == user_id,
        )
        if session_id is not None:
            session = query.filter(TripTrackingSession.id == session_id).first()
            if not session:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking session not found")
        else:
            session = (
                query.filter(TripTrackingSession.state.in_(allowed_states))
                .order_by(desc(TripTrackingSession.started_at))
                .first()
            )
        if not session or session.state not in allowed_states:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="No session available for this transition",
            )
        return session

    def start_tracking(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        client_session_id: str,
        started_at: datetime,
        timezone_name: Optional[str],
        device_context: dict[str, Any],
    ) -> tuple[int, dict[str, Any]]:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)

        active = (
            self.db.query(TripTrackingSession)
            .filter(
                TripTrackingSession.trip_id == trip_id,
                TripTrackingSession.user_id == user_id,
                TripTrackingSession.state == "active",
            )
            .first()
        )
        if active:
            return status.HTTP_200_OK, self._session_payload(session=active, trip=trip)

        started_at_utc = self._to_utc(started_at)
        session = TripTrackingSession(
            trip_id=trip_id,
            user_id=user_id,
            client_session_id=client_session_id,
            state="active",
            started_at=started_at_utc,
            timezone=timezone_name,
            device_context=device_context or {},
        )
        self.db.add(session)

        trip.tracking_enabled = True
        if trip.tracking_started_at is None:
            trip.tracking_started_at = started_at_utc
        if timezone_name:
            trip.timezone = timezone_name

        self.db.flush()

        # Advisory brain enrich — best-effort, must not break tracking start.
        try:
            import asyncio
            from app.services.trip_brain_service import TripBrainService
            loop = asyncio.get_event_loop()
            if loop.is_running():
                loop.create_task(
                    TripBrainService(self.db).enrich_on_tracking_start(trip_id)
                )
            else:
                TripBrainService(self.db).ensure_brain(trip_id, user_id)
        except Exception:  # noqa: BLE001
            pass

        return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

    def pause_tracking(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: Optional[UUID],
        paused_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        session = self._get_event_session(
            trip_id=trip_id,
            user_id=user_id,
            session_id=session_id,
            allowed_states=("active", "paused"),
        )

        if session.state == "paused":
            return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

        session.state = "paused"
        session.paused_at = self._to_utc(paused_at)

        self.db.flush()
        return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

    def resume_tracking(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: Optional[UUID],
        resumed_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        session = self._get_event_session(
            trip_id=trip_id,
            user_id=user_id,
            session_id=session_id,
            allowed_states=("active", "paused"),
        )

        if session.state == "active":
            return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

        session.state = "active"
        session.resumed_at = self._to_utc(resumed_at)

        self.db.flush()
        return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

    def stop_tracking(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: Optional[UUID],
        stopped_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        session = self._get_event_session(
            trip_id=trip_id,
            user_id=user_id,
            session_id=session_id,
            allowed_states=("active", "paused", "ended"),
        )

        if session.state == "ended":
            return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

        ended_at = self._to_utc(stopped_at)
        session.state = "ended"
        session.ended_at = ended_at
        trip.tracking_ended_at = ended_at

        self.db.flush()
        return status.HTTP_200_OK, self._session_payload(session=session, trip=trip)

    def ingest_points_batch(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: UUID,
        client_batch_id: UUID,
        points: list[dict[str, Any]],
    ) -> tuple[int, dict[str, Any]]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        session = (
            self.db.query(TripTrackingSession)
            .filter(
                TripTrackingSession.id == session_id,
                TripTrackingSession.trip_id == trip_id,
                TripTrackingSession.user_id == user_id,
            )
            .first()
        )
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking session not found")
        if session.state not in {"active", "paused"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Cannot ingest points for ended/abandoned session",
            )

        point_ids = [item["point_id"] for item in points]
        existing_ids = set()
        if point_ids:
            rows = (
                self.db.query(TripLocationPoint.point_id)
                .filter(
                    TripLocationPoint.session_id == session_id,
                    TripLocationPoint.point_id.in_(point_ids),
                )
                .all()
            )
            existing_ids = {row[0] for row in rows}

        accepted = 0
        duplicates = 0
        latest_recorded: Optional[datetime] = session.last_point_at
        earliest_accepted_recorded: Optional[datetime] = None

        for item in points:
            point_id = item["point_id"]
            recorded_at = self._to_utc(item["recorded_at"])
            if point_id in existing_ids:
                duplicates += 1
            else:
                existing_ids.add(point_id)
                accepted += 1
                self.db.add(
                    TripLocationPoint(
                        session_id=session_id,
                        trip_id=trip_id,
                        user_id=user_id,
                        client_batch_id=client_batch_id,
                        point_id=point_id,
                        recorded_at=recorded_at,
                        latitude=item["latitude"],
                        longitude=item["longitude"],
                        accuracy_m=item.get("accuracy_m"),
                        speed_mps=item.get("speed_mps"),
                        heading_deg=item.get("heading_deg"),
                        altitude_m=item.get("altitude_m"),
                        provider=item.get("provider"),
                    )
                )
                if earliest_accepted_recorded is None or recorded_at < earliest_accepted_recorded:
                    earliest_accepted_recorded = recorded_at
            if latest_recorded is None or recorded_at > latest_recorded:
                latest_recorded = recorded_at

        session.last_point_at = latest_recorded
        if accepted > 0 and earliest_accepted_recorded is not None:
            existing_marker = session.oldest_uninferred_point_at
            if existing_marker is None or earliest_accepted_recorded < self._to_utc(existing_marker):
                session.oldest_uninferred_point_at = earliest_accepted_recorded
            TripProjectionCompilerService(self.db).mark_dirty(
                trip_id=trip_id,
                user_id=user_id,
                reason="points_batch_ingested",
            )
        self.db.flush()

        return status.HTTP_202_ACCEPTED, {
            "trip_id": trip_id,
            "session_id": session_id,
            "client_batch_id": client_batch_id,
            "accepted_points": accepted,
            "duplicate_points": duplicates,
            "ingest_job_id": uuid.uuid4(),
        }

    def ingest_events_batch(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        events: list[dict[str, Any]],
    ) -> tuple[int, dict[str, Any]]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)

        accepted: list[dict[str, Any]] = []
        rejected: list[dict[str, Any]] = []
        session_cache: dict[UUID, Optional[TripTrackingSession]] = {}
        created_events = 0

        for raw_event in events:
            item = dict(raw_event or {})
            client_event_raw = item.get("client_event_id")
            client_event_text = str(client_event_raw).strip() if client_event_raw is not None else ""
            if not client_event_text:
                rejected.append(
                    {
                        "client_event_id": None,
                        "reason_code": "missing_client_event_id",
                        "message": "client_event_id is required",
                    }
                )
                continue

            client_event_id = self._parse_uuid(client_event_text)
            if client_event_id is None:
                rejected.append(
                    {
                        "client_event_id": client_event_text,
                        "reason_code": "invalid_client_event_id",
                        "message": "client_event_id must be a valid UUID",
                    }
                )
                continue

            event_type = str(item.get("event_type") or "").strip().lower()
            if event_type not in TRACKING_EVENT_TYPES:
                rejected.append(
                    {
                        "client_event_id": client_event_text,
                        "reason_code": "invalid_event_type",
                        "message": "event_type must be one of note|warn|tag|photo|media",
                    }
                )
                continue

            captured_at = self._coerce_datetime(item.get("captured_at"))
            if captured_at is None:
                rejected.append(
                    {
                        "client_event_id": client_event_text,
                        "reason_code": "invalid_captured_at",
                        "message": "captured_at must be an ISO-8601 datetime",
                    }
                )
                continue

            session_id: Optional[UUID] = None
            session_raw = item.get("session_id")
            if session_raw is not None and str(session_raw).strip():
                session_id = self._parse_uuid(session_raw)
                if session_id is None:
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_session_id",
                            "message": "session_id must be a valid UUID when provided",
                        }
                    )
                    continue
                if session_id not in session_cache:
                    session_cache[session_id] = (
                        self.db.query(TripTrackingSession)
                        .filter(
                            TripTrackingSession.id == session_id,
                            TripTrackingSession.trip_id == trip_id,
                            TripTrackingSession.user_id == user_id,
                        )
                        .first()
                    )
                if session_cache[session_id] is None:
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_session",
                            "message": "session_id does not belong to this trip",
                        }
                    )
                    continue

            note = item.get("note")
            if note is not None and not isinstance(note, str):
                note = str(note)
            if isinstance(note, str):
                note = note.strip() or None
                if note is not None and len(note) > 4000:
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_note",
                            "message": "note length must be <= 4000 characters",
                        }
                    )
                    continue

            latitude: Optional[float] = None
            longitude: Optional[float] = None
            location = item.get("location")
            if location is not None:
                if not isinstance(location, dict):
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_location",
                            "message": "location must be an object with latitude and longitude",
                        }
                    )
                    continue
                latitude_raw = location.get("latitude")
                longitude_raw = location.get("longitude")
                try:
                    latitude = float(latitude_raw) if latitude_raw is not None else None
                    longitude = float(longitude_raw) if longitude_raw is not None else None
                except (TypeError, ValueError):
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_location",
                            "message": "location latitude/longitude must be numeric values",
                        }
                    )
                    continue
                if (latitude is None) != (longitude is None):
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_location",
                            "message": "location must include both latitude and longitude",
                        }
                    )
                    continue
                if latitude is not None and not self._is_valid_coordinate(latitude=latitude, longitude=longitude):
                    rejected.append(
                        {
                            "client_event_id": client_event_text,
                            "reason_code": "invalid_location",
                            "message": "location coordinates are out of range",
                        }
                    )
                    continue

            payload = item.get("payload")
            if payload is None:
                payload = {}
            if not isinstance(payload, dict):
                rejected.append(
                    {
                        "client_event_id": client_event_text,
                        "reason_code": "invalid_payload",
                        "message": "payload must be an object",
                    }
                )
                continue

            existing = (
                self.db.query(TripTrackingEvent)
                .filter(
                    TripTrackingEvent.trip_id == trip_id,
                    TripTrackingEvent.user_id == user_id,
                    TripTrackingEvent.client_event_id == client_event_id,
                )
                .first()
            )
            if existing is not None:
                accepted.append(
                    {
                        "client_event_id": str(client_event_id),
                        "event_id": str(existing.id),
                        "duplicate": True,
                    }
                )
                continue

            event = TripTrackingEvent(
                trip_id=trip_id,
                user_id=user_id,
                session_id=session_id,
                client_event_id=client_event_id,
                event_type=event_type,
                captured_at=captured_at,
                latitude=latitude,
                longitude=longitude,
                note=note,
                payload=payload,
            )
            self.db.add(event)
            self.db.flush()
            created_events += 1
            accepted.append(
                {
                    "client_event_id": str(client_event_id),
                    "event_id": str(event.id),
                    "duplicate": False,
                }
            )

        if created_events > 0:
            TripProjectionCompilerService(self.db).mark_dirty(
                trip_id=trip_id,
                user_id=user_id,
                reason="tracking_events_ingested",
            )

        return status.HTTP_202_ACCEPTED, {
            "trip_id": trip_id,
            "accepted": accepted,
            "rejected": rejected,
            "accepted_count": len(accepted),
            "rejected_count": len(rejected),
        }

    def ingest_media_batch(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        media: list[dict[str, Any]],
    ) -> tuple[int, dict[str, Any]]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)

        accepted: list[dict[str, Any]] = []
        rejected: list[dict[str, Any]] = []
        created_media = 0

        for raw_item in media:
            item = dict(raw_item or {})
            client_media_raw = item.get("client_media_id")
            client_media_text = str(client_media_raw).strip() if client_media_raw is not None else ""
            if not client_media_text:
                rejected.append(
                    {
                        "client_media_id": None,
                        "reason_code": "missing_client_media_id",
                        "message": "client_media_id is required",
                    }
                )
                continue
            client_media_id = self._parse_uuid(client_media_text)
            if client_media_id is None:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_client_media_id",
                        "message": "client_media_id must be a valid UUID",
                    }
                )
                continue

            client_event_raw = item.get("client_event_id")
            client_event_text = str(client_event_raw).strip() if client_event_raw is not None else ""
            if not client_event_text:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "missing_client_event_id",
                        "message": "client_event_id is required",
                    }
                )
                continue
            client_event_id = self._parse_uuid(client_event_text)
            if client_event_id is None:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_client_event_id",
                        "message": "client_event_id must be a valid UUID",
                    }
                )
                continue

            event = (
                self.db.query(TripTrackingEvent)
                .filter(
                    TripTrackingEvent.trip_id == trip_id,
                    TripTrackingEvent.user_id == user_id,
                    TripTrackingEvent.client_event_id == client_event_id,
                )
                .first()
            )
            if event is None:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "event_not_synced",
                        "message": "client_event_id is not available on server for this trip",
                    }
                )
                continue

            media_type = str(item.get("media_type") or "").strip().lower()
            if media_type not in TRACKING_MEDIA_TYPES:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_media_type",
                        "message": "media_type must be one of photo|media",
                    }
                )
                continue

            bind_mode = str(item.get("bind_mode") or "").strip().lower()
            if bind_mode not in TRACKING_MEDIA_BIND_MODES:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_bind_mode",
                        "message": "bind_mode must be one of place|route",
                    }
                )
                continue

            captured_at = self._coerce_datetime(item.get("captured_at"))
            if captured_at is None:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_captured_at",
                        "message": "captured_at must be an ISO-8601 datetime",
                    }
                )
                continue

            trip_place_id: Optional[UUID] = None
            anchor_latitude: Optional[float] = None
            anchor_longitude: Optional[float] = None
            if bind_mode == "place":
                trip_place_id = self._parse_uuid(item.get("trip_place_id"))
                if trip_place_id is None:
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "missing_trip_place_id",
                            "message": "trip_place_id is required for place bind_mode",
                        }
                    )
                    continue
                try:
                    self._get_owned_trip_place(
                        place_id=trip_place_id,
                        trip_id=trip_id,
                        user_id=user_id,
                    )
                except HTTPException:
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_trip_place_id",
                            "message": "trip_place_id does not belong to this trip",
                        }
                    )
                    continue
            else:
                location = item.get("location")
                if not isinstance(location, dict):
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_location",
                            "message": "location is required for route bind_mode",
                        }
                    )
                    continue
                try:
                    anchor_latitude = float(location.get("latitude"))
                    anchor_longitude = float(location.get("longitude"))
                except (TypeError, ValueError):
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_location",
                            "message": "location latitude/longitude must be numeric values",
                        }
                    )
                    continue
                if not self._is_valid_coordinate(
                    latitude=anchor_latitude,
                    longitude=anchor_longitude,
                ):
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_location",
                            "message": "location coordinates are out of range",
                        }
                    )
                    continue

            upload_ref = str(item.get("upload_ref") or "").strip()
            if not upload_ref:
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "missing_upload_ref",
                        "message": "upload_ref is required",
                    }
                )
                continue

            mime_type = item.get("mime_type")
            if mime_type is not None:
                mime_type = str(mime_type).strip() or None
            file_size_bytes = item.get("file_size_bytes")
            if file_size_bytes is not None:
                try:
                    file_size_bytes = int(file_size_bytes)
                except (TypeError, ValueError):
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_file_size_bytes",
                            "message": "file_size_bytes must be an integer when provided",
                        }
                    )
                    continue
                if file_size_bytes < 0:
                    rejected.append(
                        {
                            "client_media_id": client_media_text,
                            "reason_code": "invalid_file_size_bytes",
                            "message": "file_size_bytes must be >= 0",
                        }
                    )
                    continue

            payload = item.get("payload")
            if payload is None:
                payload = {}
            if not isinstance(payload, dict):
                rejected.append(
                    {
                        "client_media_id": client_media_text,
                        "reason_code": "invalid_payload",
                        "message": "payload must be an object",
                    }
                )
                continue

            existing = (
                self.db.query(TripTrackingEventMedia)
                .filter(
                    TripTrackingEventMedia.trip_id == trip_id,
                    TripTrackingEventMedia.user_id == user_id,
                    TripTrackingEventMedia.client_media_id == client_media_id,
                )
                .first()
            )
            if existing is not None:
                accepted.append(
                    {
                        "client_media_id": str(client_media_id),
                        "media_id": str(existing.id),
                        "duplicate": True,
                    }
                )
                continue

            media_row = TripTrackingEventMedia(
                trip_id=trip_id,
                user_id=user_id,
                event_id=event.id,
                client_media_id=client_media_id,
                client_event_id=client_event_id,
                media_type=media_type,
                bind_mode=bind_mode,
                trip_place_id=trip_place_id,
                captured_at=captured_at,
                anchor_latitude=anchor_latitude,
                anchor_longitude=anchor_longitude,
                upload_ref=upload_ref,
                mime_type=mime_type,
                file_size_bytes=file_size_bytes,
                payload=payload,
            )
            self.db.add(media_row)
            self.db.flush()
            created_media += 1
            accepted.append(
                {
                    "client_media_id": str(client_media_id),
                    "media_id": str(media_row.id),
                    "duplicate": False,
                }
            )

        if created_media > 0:
            TripProjectionCompilerService(self.db).mark_dirty(
                trip_id=trip_id,
                user_id=user_id,
                reason="tracking_media_ingested",
            )

        return status.HTTP_202_ACCEPTED, {
            "trip_id": trip_id,
            "accepted": accepted,
            "rejected": rejected,
            "accepted_count": len(accepted),
            "rejected_count": len(rejected),
        }

    async def upload_tracking_media_binary(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        file: UploadFile,
    ) -> dict[str, Any]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        if file.content_type is None or file.content_type.strip() == "":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="file content type is required",
            )
        content_type = file.content_type.strip().lower()
        if content_type not in TRACKING_MEDIA_UPLOAD_ALLOWED_MIME_TYPES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    "Invalid file type. Allowed types: "
                    + ", ".join(sorted(TRACKING_MEDIA_UPLOAD_ALLOWED_MIME_TYPES))
                ),
            )

        file_bytes = await file.read()
        if not file_bytes:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty",
            )

        if file.filename is None or not str(file.filename).strip():
            file.filename = "tracking-media.bin"

        is_premium = bool(
            self.db.query(User.is_premium).filter(User.id == user_id).scalar()
        )
        try:
            storage_service = StorageService()
        except StorageConfigurationError as exc:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Storage service misconfigured",
            ) from exc

        upload_ref = await storage_service.upload_file(
            file=file,
            bucket="photos",
            user_id=user_id,
            is_premium=is_premium,
            allowed_types=list(TRACKING_MEDIA_UPLOAD_ALLOWED_MIME_TYPES),
            max_size_mb=25,
            contents=file_bytes,
        )

        return {
            "trip_id": trip_id,
            "upload_ref": upload_ref,
            "mime_type": content_type,
            "file_size_bytes": len(file_bytes),
        }

    def get_tracking_path(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        session_id: Optional[UUID],
        limit: int = 5000,
    ) -> dict[str, Any]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        clamped_limit = max(1, min(10000, int(limit)))

        session_query = self.db.query(TripTrackingSession).filter(
            TripTrackingSession.trip_id == trip_id,
            TripTrackingSession.user_id == user_id,
        )
        if session_id is not None:
            session = session_query.filter(TripTrackingSession.id == session_id).first()
        else:
            session = session_query.order_by(desc(TripTrackingSession.started_at)).first()

        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking session not found")

        rows = (
            self.db.query(TripLocationPoint)
            .filter(
                TripLocationPoint.trip_id == trip_id,
                TripLocationPoint.user_id == user_id,
                TripLocationPoint.session_id == session.id,
            )
            .order_by(TripLocationPoint.recorded_at.desc())
            .limit(clamped_limit)
            .all()
        )
        rows.sort(key=lambda row: row.recorded_at)

        max_accuracy = float(settings.TRACKING_POINT_MAX_ACCURACY_M)
        max_speed_mps = 55.0
        min_move_m = 2.0
        points: list[dict[str, Any]] = []
        previous: Optional[dict[str, Any]] = None

        for row in rows:
            if not self._is_valid_coordinate(latitude=row.latitude, longitude=row.longitude):
                continue
            if row.accuracy_m is not None and row.accuracy_m > max_accuracy:
                continue

            point_payload = {
                "recorded_at": self._to_utc(row.recorded_at),
                "latitude": row.latitude,
                "longitude": row.longitude,
                "accuracy_m": row.accuracy_m,
                "speed_mps": row.speed_mps,
            }
            if previous is not None:
                distance_m = haversine_distance(
                    previous["latitude"],
                    previous["longitude"],
                    point_payload["latitude"],
                    point_payload["longitude"],
                )
                if distance_m <= min_move_m:
                    continue

                delta_seconds = (point_payload["recorded_at"] - previous["recorded_at"]).total_seconds()
                if delta_seconds <= 0:
                    continue
                inferred_speed = distance_m / delta_seconds
                observed_speed = point_payload.get("speed_mps")
                if inferred_speed > max_speed_mps and distance_m >= 80.0:
                    continue
                if observed_speed is not None and observed_speed > (max_speed_mps * 1.2) and distance_m >= 40.0:
                    continue

            points.append(point_payload)
            previous = point_payload

        return {
            "trip_id": trip_id,
            "session_id": session.id,
            "points_count": len(points),
            "points": points,
        }

    def list_pending_checkins(self, *, trip_id: UUID, user_id: UUID) -> dict[str, Any]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        now = self._utcnow()
        candidates = (
            self.db.query(TripCheckinCandidate)
            .filter(
                TripCheckinCandidate.trip_id == trip_id,
                TripCheckinCandidate.user_id == user_id,
                or_(
                    TripCheckinCandidate.status == "pending",
                    and_(
                        TripCheckinCandidate.status == "snoozed",
                        or_(
                            TripCheckinCandidate.snoozed_until.is_(None),
                            TripCheckinCandidate.snoozed_until <= now,
                        ),
                    ),
                ),
            )
            .order_by(desc(TripCheckinCandidate.created_at))
            .all()
        )
        return {
            "candidates": [self._candidate_payload(candidate) for candidate in candidates],
            "total": len(candidates),
        }

    def _get_owned_candidate(self, *, candidate_id: UUID, user_id: UUID) -> TripCheckinCandidate:
        candidate = (
            self.db.query(TripCheckinCandidate)
            .filter(
                TripCheckinCandidate.id == candidate_id,
                TripCheckinCandidate.user_id == user_id,
            )
            .first()
        )
        if not candidate:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Check-in candidate not found")
        self._get_owned_trip(trip_id=candidate.trip_id, user_id=user_id)
        return candidate

    def _get_owned_trip_place(self, *, place_id: UUID, trip_id: UUID, user_id: UUID) -> TripPlace:
        place = (
            self.db.query(TripPlace)
            .filter(
                TripPlace.id == place_id,
                TripPlace.trip_id == trip_id,
                TripPlace.user_id == user_id,
            )
            .first()
        )
        if not place:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="linked place must belong to this trip",
            )
        return place

    def _next_place_order(self, *, trip_id: UUID) -> int:
        max_order = (
            self.db.query(func.max(TripPlace.order_in_trip))
            .filter(TripPlace.trip_id == trip_id)
            .scalar()
        )
        return 0 if max_order is None else max_order + 1

    def assert_candidate_fingerprint_available(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        fingerprint: str,
        at_time: Optional[datetime] = None,
    ) -> None:
        now = self._to_utc(at_time or self._utcnow())
        in_cooldown = (
            self.db.query(TripCheckinCandidate)
            .filter(
                TripCheckinCandidate.trip_id == trip_id,
                TripCheckinCandidate.user_id == user_id,
                TripCheckinCandidate.fingerprint == fingerprint,
                TripCheckinCandidate.status == "rejected",
                TripCheckinCandidate.cooldown_until.is_not(None),
                TripCheckinCandidate.cooldown_until > now,
            )
            .first()
        )
        if in_cooldown:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Candidate fingerprint is in cooldown window",
            )

    def confirm_candidate(
        self,
        *,
        candidate_id: UUID,
        user_id: UUID,
        confirmed_at: datetime,
        place_override: Optional[dict[str, Any]],
    ) -> tuple[int, dict[str, Any]]:
        candidate = self._get_owned_candidate(candidate_id=candidate_id, user_id=user_id)
        if candidate.status == "confirmed":
            return status.HTTP_200_OK, {"candidate": self._candidate_payload(candidate)}
        if candidate.status in {"expired", "rejected"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Cannot confirm candidate in current state",
            )

        place_id: Optional[UUID] = None
        override = place_override or {}
        override_place_id = override.get("trip_place_id")

        if override_place_id:
            place = self._get_owned_trip_place(
                place_id=override_place_id,
                trip_id=candidate.trip_id,
                user_id=user_id,
            )
            place_id = place.id
        else:
            name = override.get("name") or candidate.suggested_name or "Inferred Place"
            latitude = override.get("latitude")
            longitude = override.get("longitude")
            if latitude is None:
                latitude = candidate.suggested_latitude
            if longitude is None:
                longitude = candidate.suggested_longitude
            if latitude is None or longitude is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Candidate confirmation requires a place location",
                )

            source = "auto"
            if any(override.get(field) is not None for field in ("name", "latitude", "longitude")):
                source = "edited_auto"

            place = TripPlace(
                trip_id=candidate.trip_id,
                user_id=user_id,
                name=name,
                place_type="inferred",
                location=f"SRID=4326;POINT({longitude} {latitude})",
                lat=latitude,
                lng=longitude,
                order_in_trip=self._next_place_order(trip_id=candidate.trip_id),
                source=source,
                confidence=candidate.confidence,
                candidate_id=candidate.id,
                locked_fields={},
            )
            self.db.add(place)
            self.db.flush()
            place_id = place.id

        confirmed_at_utc = self._to_utc(confirmed_at)
        candidate.status = "confirmed"
        candidate.confirmed_trip_place_id = place_id
        candidate.rejected_reason = None
        candidate.snoozed_until = None
        candidate.cooldown_until = None
        candidate.updated_at = confirmed_at_utc
        self._mark_candidate_inbox_acted(candidate=candidate, acted_at=confirmed_at_utc)

        self.db.flush()
        return status.HTTP_200_OK, {"candidate": self._candidate_payload(candidate)}

    def reject_candidate(
        self,
        *,
        candidate_id: UUID,
        user_id: UUID,
        rejected_at: datetime,
        reason: Optional[str],
    ) -> tuple[int, dict[str, Any]]:
        candidate = self._get_owned_candidate(candidate_id=candidate_id, user_id=user_id)
        if candidate.status == "confirmed":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Cannot reject an already confirmed candidate",
            )

        rejected_at_utc = self._to_utc(rejected_at)
        candidate.status = "rejected"
        candidate.rejected_reason = reason
        candidate.snoozed_until = None
        candidate.cooldown_until = rejected_at_utc + timedelta(hours=REJECT_COOLDOWN_HOURS)
        candidate.updated_at = rejected_at_utc
        self._mark_candidate_inbox_acted(candidate=candidate, acted_at=rejected_at_utc)

        self.db.flush()
        return status.HTTP_200_OK, {"candidate": self._candidate_payload(candidate)}

    def snooze_candidate(
        self,
        *,
        candidate_id: UUID,
        user_id: UUID,
        snoozed_until: datetime,
    ) -> tuple[int, dict[str, Any]]:
        candidate = self._get_owned_candidate(candidate_id=candidate_id, user_id=user_id)
        if candidate.status in {"confirmed", "expired"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Cannot snooze candidate in current state",
            )
        snooze_utc = self._to_utc(snoozed_until)
        if snooze_utc <= self._utcnow():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="snoozed_until must be in the future",
            )
        acted_at = self._utcnow()
        candidate.status = "snoozed"
        candidate.snoozed_until = snooze_utc
        candidate.updated_at = acted_at
        self._mark_candidate_inbox_acted(candidate=candidate, acted_at=acted_at)

        self.db.flush()
        return status.HTTP_200_OK, {"candidate": self._candidate_payload(candidate)}

    def list_moments(self, *, trip_id: UUID, user_id: UUID) -> dict[str, Any]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        moments = (
            self.db.query(TripMoment)
            .filter(
                TripMoment.trip_id == trip_id,
                TripMoment.user_id == user_id,
            )
            .order_by(desc(TripMoment.captured_at))
            .all()
        )
        return {
            "moments": [self._moment_payload(moment) for moment in moments],
            "total": len(moments),
        }

    def create_moment(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        captured_at: datetime,
        note: Optional[str],
        location: Optional[dict[str, float]],
        media_refs: list[dict[str, Any]],
        linked_trip_place_id: Optional[UUID],
        extra_payload: dict[str, Any],
    ) -> tuple[int, dict[str, Any]]:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        if linked_trip_place_id:
            self._get_owned_trip_place(place_id=linked_trip_place_id, trip_id=trip_id, user_id=user_id)

        latitude = location["latitude"] if location else None
        longitude = location["longitude"] if location else None
        moment = TripMoment(
            trip_id=trip_id,
            user_id=user_id,
            source="manual",
            captured_at=self._to_utc(captured_at),
            latitude=latitude,
            longitude=longitude,
            note=note,
            media_refs=media_refs or [],
            extra_payload=extra_payload or {},
            linked_trip_place_id=linked_trip_place_id,
            locked_fields={},
        )
        self.db.add(moment)
        self.db.flush()

        return status.HTTP_201_CREATED, self._moment_payload(moment)

    def update_moment(
        self,
        *,
        moment_id: UUID,
        user_id: UUID,
        update_data: dict[str, Any],
    ) -> tuple[int, dict[str, Any]]:
        moment = (
            self.db.query(TripMoment)
            .filter(
                TripMoment.id == moment_id,
                TripMoment.user_id == user_id,
            )
            .first()
        )
        if not moment:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Moment not found")

        self._get_owned_trip(trip_id=moment.trip_id, user_id=user_id)
        changed_fields: list[str] = []

        if "linked_trip_place_id" in update_data:
            linked_place_id = update_data["linked_trip_place_id"]
            if linked_place_id:
                self._get_owned_trip_place(
                    place_id=linked_place_id,
                    trip_id=moment.trip_id,
                    user_id=user_id,
                )
            moment.linked_trip_place_id = linked_place_id
            changed_fields.append("linked_trip_place_id")

        if "captured_at" in update_data and update_data["captured_at"] is not None:
            moment.captured_at = self._to_utc(update_data["captured_at"])
            changed_fields.append("captured_at")

        if "note" in update_data:
            moment.note = update_data["note"]
            changed_fields.append("note")

        if "location" in update_data:
            location = update_data["location"]
            if location is None:
                moment.latitude = None
                moment.longitude = None
            else:
                moment.latitude = location["latitude"]
                moment.longitude = location["longitude"]
            changed_fields.append("location")

        if "media_refs" in update_data and update_data["media_refs"] is not None:
            moment.media_refs = update_data["media_refs"]
            changed_fields.append("media_refs")

        if "extra_payload" in update_data and update_data["extra_payload"] is not None:
            moment.extra_payload = update_data["extra_payload"]
            changed_fields.append("extra_payload")

        if changed_fields:
            locks = dict(moment.locked_fields or {})
            for field in changed_fields:
                locks[field] = True
            moment.locked_fields = locks
            if moment.source == "auto":
                moment.source = "edited_auto"

        self.db.flush()
        return status.HTTP_200_OK, self._moment_payload(moment)

    def commit_auto_finalize(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        committed_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        trip = self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        active_session_exists = (
            self.db.query(TripTrackingSession.id)
            .filter(
                TripTrackingSession.trip_id == trip_id,
                TripTrackingSession.user_id == user_id,
                TripTrackingSession.state.in_(["active", "paused"]),
            )
            .first()
            is not None
        )
        if active_session_exists:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Trip cannot be finalized while tracking session is active",
            )

        if trip.status != "completed":
            trip.status = "completed"
            if trip.tracking_ended_at is None:
                trip.tracking_ended_at = self._to_utc(committed_at)

        self.db.flush()
        return status.HTTP_200_OK, {
            "trip_id": trip.id,
            "status": trip.status,
            "tracking_enabled": trip.tracking_enabled,
            "tracking_started_at": trip.tracking_started_at,
            "tracking_ended_at": trip.tracking_ended_at,
        }

    def register_device_token(
        self,
        *,
        user_id: UUID,
        platform: str,
        push_token: str,
        device_id: Optional[str],
        app_version: Optional[str],
        locale: Optional[str],
        seen_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        seen_at_utc = self._to_utc(seen_at)
        upsert = (
            pg_insert(UserDeviceToken)
            .values(
                user_id=user_id,
                platform=platform,
                push_token=push_token,
                device_id=device_id,
                app_version=app_version,
                locale=locale,
                is_active=True,
                last_seen_at=seen_at_utc,
                failure_count=0,
            )
            .on_conflict_do_update(
                index_elements=[UserDeviceToken.push_token],
                set_={
                    "user_id": user_id,
                    "platform": platform,
                    "device_id": device_id,
                    "app_version": app_version,
                    "locale": locale,
                    "is_active": True,
                    "last_seen_at": seen_at_utc,
                    "failure_count": 0,
                    "updated_at": func.now(),
                },
            )
            .returning(UserDeviceToken.id)
        )
        token_id = self.db.execute(upsert).scalar_one()
        token_row = self.db.query(UserDeviceToken).filter(UserDeviceToken.id == token_id).first()
        if token_row is None:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Device token upsert failed")
        return status.HTTP_200_OK, self._device_token_payload(token_row)

    def deactivate_device_token(
        self,
        *,
        user_id: UUID,
        push_token: str,
        deactivated_at: datetime,
    ) -> tuple[int, dict[str, Any]]:
        token_row = (
            self.db.query(UserDeviceToken)
            .filter(
                UserDeviceToken.user_id == user_id,
                UserDeviceToken.push_token == push_token,
            )
            .first()
        )
        if token_row is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device token not found")

        token_row.is_active = False
        token_row.last_seen_at = self._to_utc(deactivated_at)
        self.db.flush()
        return status.HTTP_200_OK, self._device_token_payload(token_row)
