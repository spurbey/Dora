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

from fastapi import HTTPException, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy import and_, desc, func, or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.api_idempotency_record import ApiIdempotencyRecord
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.trip_checkin_candidate import TripCheckinCandidate
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_moment import TripMoment
from app.models.trip_tracking_session import TripTrackingSession
from app.models.user_device_token import UserDeviceToken


IDEMPOTENCY_TTL_HOURS = 72
REJECT_COOLDOWN_HOURS = 24


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
    def _json_hash(payload: dict[str, Any]) -> str:
        normalized = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str)
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()

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

            if constraint_name in {"uq_tracking_point_session_point", "uq_checkin_candidate_active_fingerprint"}:
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

        if trip.status != "planned":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Tracking can only be started from planned trip status",
            )

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

        trip.status = "tracking_active"
        trip.tracking_enabled = True
        if trip.tracking_started_at is None:
            trip.tracking_started_at = started_at_utc
        if timezone_name:
            trip.timezone = timezone_name

        self.db.flush()
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
        trip.status = "tracking_paused"

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
        trip.status = "tracking_active"

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
        trip.status = "review_pending"
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
            if latest_recorded is None or recorded_at > latest_recorded:
                latest_recorded = recorded_at

        session.last_point_at = latest_recorded
        self.db.flush()

        return status.HTTP_202_ACCEPTED, {
            "trip_id": trip_id,
            "session_id": session_id,
            "client_batch_id": client_batch_id,
            "accepted_points": accepted,
            "duplicate_points": duplicates,
            "ingest_job_id": uuid.uuid4(),
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

        candidate.status = "confirmed"
        candidate.confirmed_trip_place_id = place_id
        candidate.rejected_reason = None
        candidate.snoozed_until = None
        candidate.cooldown_until = None
        candidate.updated_at = self._to_utc(confirmed_at)

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
        candidate.status = "snoozed"
        candidate.snoozed_until = snooze_utc
        candidate.updated_at = self._utcnow()

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
        if trip.status not in {"planned", "review_pending", "completed"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Trip cannot be finalized from current status",
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
        token_row = (
            self.db.query(UserDeviceToken)
            .filter(
                UserDeviceToken.user_id == user_id,
                UserDeviceToken.push_token == push_token,
            )
            .first()
        )
        seen_at_utc = self._to_utc(seen_at)

        if token_row is None:
            token_row = UserDeviceToken(
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
            self.db.add(token_row)
        else:
            token_row.platform = platform
            token_row.device_id = device_id
            token_row.app_version = app_version
            token_row.locale = locale
            token_row.is_active = True
            token_row.last_seen_at = seen_at_utc
            token_row.failure_count = 0

        self.db.flush()
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
