"""
Live-tracking worker for Phase 3 async processing.

Implements:
- stay/candidate scoring from ingested points
- auto moment generation
- notification handoff marking
- inactivity/end-date auto-end lifecycle updates

The worker is intentionally retry-safe:
- candidate duplicates are suppressed by fingerprint checks and DB uniqueness
- moment duplicates are suppressed by candidate-linked lookups
- notification handoff is marked in candidate payload to avoid repeat dispatch
"""

from __future__ import annotations

import hashlib
import json
import logging
import time
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID, uuid4

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.config import settings
from app.database import SessionLocal
from app.models.trip import Trip
from app.models.trip_auto_entity_tombstone import TripAutoEntityTombstone
from app.models.trip_checkin_candidate import TripCheckinCandidate
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_moment import TripMoment
from app.models.trip_tracking_session import TripTrackingSession
from app.services.live_tracking_service import LiveTrackingService
from app.utils.geo import haversine_distance

logger = logging.getLogger(__name__)


RETRY_BACKOFF_SECONDS = (5, 20, 60)


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _to_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


@dataclass(frozen=True)
class _Point:
    recorded_at: datetime
    latitude: float
    longitude: float
    accuracy_m: Optional[float]


@dataclass(frozen=True)
class _StayCluster:
    started_at: datetime
    ended_at: datetime
    centroid_latitude: float
    centroid_longitude: float
    point_count: int
    average_accuracy_m: Optional[float]

    @property
    def dwell_minutes(self) -> float:
        return max(0.0, (self.ended_at - self.started_at).total_seconds() / 60.0)


@dataclass
class SessionInferenceResult:
    session_id: UUID
    scanned_points: int = 0
    filtered_points: int = 0
    clusters_found: int = 0
    candidates_created: int = 0
    moments_created: int = 0
    duplicate_candidates: int = 0
    cooldown_suppressed: int = 0
    tombstone_suppressed: int = 0
    notification_candidate_ids: list[UUID] = None

    def __post_init__(self) -> None:
        if self.notification_candidate_ids is None:
            self.notification_candidate_ids = []


@dataclass
class NotificationHandoffResult:
    dispatched_count: int
    candidate_ids: list[UUID]


@dataclass
class AutoEndPassResult:
    scanned_sessions: int
    auto_ended_sessions: int
    ended_session_ids: list[UUID]
    ended_trip_ids: list[UUID]


def build_candidate_fingerprint(
    *,
    trip_id: UUID,
    session_id: UUID,
    latitude: float,
    longitude: float,
    started_at: datetime,
    ended_at: datetime,
) -> str:
    """
    Build deterministic fingerprint for deduping inferred stays.

    Coarsens spatial coordinates and timestamp seconds to preserve stability
    across retries while still distinguishing separate stays.
    """
    payload = {
        "trip_id": str(trip_id),
        "session_id": str(session_id),
        "lat": round(latitude, 4),
        "lng": round(longitude, 4),
        "start": _to_utc(started_at).replace(second=0, microsecond=0).isoformat(),
        "end": _to_utc(ended_at).replace(second=0, microsecond=0).isoformat(),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(encoded.encode("utf-8")).hexdigest()[:32]


def _cluster_confidence(cluster: _StayCluster) -> float:
    dwell_score = min(1.0, cluster.dwell_minutes / 30.0)
    density_score = min(1.0, cluster.point_count / 15.0)
    if cluster.average_accuracy_m is None:
        accuracy_score = 0.8
    else:
        accuracy_score = 1.0 if cluster.average_accuracy_m <= 20 else max(0.2, 1.0 - (cluster.average_accuracy_m - 20) / 80.0)

    confidence = 0.45 * dwell_score + 0.35 * density_score + 0.20 * accuracy_score
    return round(max(0.0, min(1.0, confidence)), 3)


def _to_points(rows: list[TripLocationPoint]) -> list[_Point]:
    points: list[_Point] = []
    max_accuracy = float(settings.TRACKING_POINT_MAX_ACCURACY_M)
    for row in rows:
        if row.accuracy_m is not None and row.accuracy_m > max_accuracy:
            continue
        points.append(
            _Point(
                recorded_at=_to_utc(row.recorded_at),
                latitude=row.latitude,
                longitude=row.longitude,
                accuracy_m=row.accuracy_m,
            )
        )
    return points


def _dedupe_points(points: list[_Point]) -> list[_Point]:
    if not points:
        return []

    deduped: list[_Point] = [points[0]]
    max_seconds = int(settings.TRACKING_POINT_DEDUP_WINDOW_SECONDS)
    max_distance = float(settings.TRACKING_POINT_DEDUP_DISTANCE_M)

    for point in points[1:]:
        prev = deduped[-1]
        delta_seconds = (point.recorded_at - prev.recorded_at).total_seconds()
        if delta_seconds < 0:
            # Keep monotonic order assumptions intact; treat out-of-order points as unique.
            deduped.append(point)
            continue

        if delta_seconds <= max_seconds:
            distance = haversine_distance(prev.latitude, prev.longitude, point.latitude, point.longitude)
            if distance <= max_distance:
                continue
        deduped.append(point)

    return deduped


def _build_stay_clusters(points: list[_Point]) -> list[_StayCluster]:
    if not points:
        return []

    stay_radius = float(settings.TRACKING_STAY_RADIUS_M)
    min_duration_minutes = int(settings.TRACKING_STAY_MIN_DURATION_MINUTES)
    min_duration_seconds = min_duration_minutes * 60

    clusters: list[_StayCluster] = []

    current_points: list[_Point] = []
    sum_lat = 0.0
    sum_lng = 0.0

    def flush_cluster() -> None:
        nonlocal current_points, sum_lat, sum_lng
        if len(current_points) < 2:
            current_points = []
            sum_lat = 0.0
            sum_lng = 0.0
            return

        started = current_points[0].recorded_at
        ended = current_points[-1].recorded_at
        duration_seconds = (ended - started).total_seconds()
        if duration_seconds < min_duration_seconds:
            current_points = []
            sum_lat = 0.0
            sum_lng = 0.0
            return

        count = len(current_points)
        centroid_lat = sum_lat / count
        centroid_lng = sum_lng / count
        accuracies = [p.accuracy_m for p in current_points if p.accuracy_m is not None]
        avg_accuracy = (sum(accuracies) / len(accuracies)) if accuracies else None
        clusters.append(
            _StayCluster(
                started_at=started,
                ended_at=ended,
                centroid_latitude=centroid_lat,
                centroid_longitude=centroid_lng,
                point_count=count,
                average_accuracy_m=avg_accuracy,
            )
        )

        current_points = []
        sum_lat = 0.0
        sum_lng = 0.0

    for point in points:
        if not current_points:
            current_points.append(point)
            sum_lat = point.latitude
            sum_lng = point.longitude
            continue

        current_count = len(current_points)
        centroid_lat = sum_lat / current_count
        centroid_lng = sum_lng / current_count
        distance = haversine_distance(centroid_lat, centroid_lng, point.latitude, point.longitude)

        if distance <= stay_radius:
            current_points.append(point)
            sum_lat += point.latitude
            sum_lng += point.longitude
        else:
            flush_cluster()
            current_points = [point]
            sum_lat = point.latitude
            sum_lng = point.longitude

    flush_cluster()
    return clusters


def _is_tombstoned(
    db: Session,
    *,
    trip_id: UUID,
    user_id: UUID,
    fingerprint: str,
    now: datetime,
) -> bool:
    row = (
        db.query(TripAutoEntityTombstone.id)
        .filter(
            TripAutoEntityTombstone.trip_id == trip_id,
            TripAutoEntityTombstone.user_id == user_id,
            TripAutoEntityTombstone.entity_type == "place",
            TripAutoEntityTombstone.entity_fingerprint == fingerprint,
            TripAutoEntityTombstone.cooldown_expires_at > now,
        )
        .first()
    )
    return row is not None


def _ensure_auto_moment(
    db: Session,
    *,
    candidate: TripCheckinCandidate,
    cluster: _StayCluster,
) -> bool:
    existing = (
        db.query(TripMoment.id)
        .filter(TripMoment.candidate_id == candidate.id)
        .first()
    )
    if existing:
        return False

    db.add(
        TripMoment(
            trip_id=candidate.trip_id,
            user_id=candidate.user_id,
            candidate_id=candidate.id,
            source="auto",
            confidence=candidate.confidence,
            captured_at=_to_utc(candidate.ended_at or cluster.ended_at),
            latitude=candidate.suggested_latitude,
            longitude=candidate.suggested_longitude,
            note=f"Auto moment near {candidate.suggested_name or 'inferred place'}",
            media_refs=[],
            extra_payload={
                "inference_version": "v1",
                "cluster": {
                    "point_count": cluster.point_count,
                    "duration_minutes": round(cluster.dwell_minutes, 2),
                },
            },
            locked_fields={},
        )
    )
    return True


def process_session_inference(
    db: Session,
    *,
    session_id: UUID,
    now: Optional[datetime] = None,
) -> SessionInferenceResult:
    as_of = _to_utc(now or utcnow())
    session = db.query(TripTrackingSession).filter(TripTrackingSession.id == session_id).first()
    if not session:
        raise ValueError(f"Tracking session not found: {session_id}")

    rows = (
        db.query(TripLocationPoint)
        .filter(TripLocationPoint.session_id == session_id)
        .order_by(TripLocationPoint.recorded_at.asc())
        .all()
    )

    result = SessionInferenceResult(session_id=session_id, scanned_points=len(rows))
    if not rows:
        return result

    points = _dedupe_points(_to_points(rows))
    result.filtered_points = len(points)
    if len(points) < 2:
        return result

    clusters = _build_stay_clusters(points)
    result.clusters_found = len(clusters)
    if not clusters:
        return result

    service = LiveTrackingService(db)

    for cluster in clusters:
        fingerprint = build_candidate_fingerprint(
            trip_id=session.trip_id,
            session_id=session.id,
            latitude=cluster.centroid_latitude,
            longitude=cluster.centroid_longitude,
            started_at=cluster.started_at,
            ended_at=cluster.ended_at,
        )

        if _is_tombstoned(
            db,
            trip_id=session.trip_id,
            user_id=session.user_id,
            fingerprint=fingerprint,
            now=as_of,
        ):
            result.tombstone_suppressed += 1
            continue

        existing_candidate = (
            db.query(TripCheckinCandidate)
            .filter(
                TripCheckinCandidate.trip_id == session.trip_id,
                TripCheckinCandidate.user_id == session.user_id,
                TripCheckinCandidate.fingerprint == fingerprint,
                TripCheckinCandidate.status.in_(["pending", "snoozed"]),
            )
            .first()
        )
        if existing_candidate:
            result.duplicate_candidates += 1
            if _ensure_auto_moment(db, candidate=existing_candidate, cluster=cluster):
                result.moments_created += 1
            if existing_candidate.confidence >= float(settings.TRACKING_NOTIFICATION_CONFIDENCE_THRESHOLD):
                result.notification_candidate_ids.append(existing_candidate.id)
            continue

        try:
            service.assert_candidate_fingerprint_available(
                trip_id=session.trip_id,
                user_id=session.user_id,
                fingerprint=fingerprint,
                at_time=as_of,
            )
        except HTTPException:
            result.cooldown_suppressed += 1
            continue

        confidence = _cluster_confidence(cluster)
        candidate = TripCheckinCandidate(
            trip_id=session.trip_id,
            user_id=session.user_id,
            session_id=session.id,
            fingerprint=fingerprint,
            status="pending",
            confidence=confidence,
            suggested_name="Inferred stop",
            suggested_latitude=round(cluster.centroid_latitude, 6),
            suggested_longitude=round(cluster.centroid_longitude, 6),
            started_at=cluster.started_at,
            ended_at=cluster.ended_at,
            payload={
                "inference_version": "v1",
                "cluster": {
                    "point_count": cluster.point_count,
                    "duration_minutes": round(cluster.dwell_minutes, 2),
                    "average_accuracy_m": cluster.average_accuracy_m,
                },
                "notification_handoff_at": None,
            },
        )
        try:
            with db.begin_nested():
                db.add(candidate)
                db.flush()
        except IntegrityError:
            # Concurrent worker inserted the same active fingerprint first.
            result.duplicate_candidates += 1
            existing_candidate = (
                db.query(TripCheckinCandidate)
                .filter(
                    TripCheckinCandidate.trip_id == session.trip_id,
                    TripCheckinCandidate.user_id == session.user_id,
                    TripCheckinCandidate.fingerprint == fingerprint,
                    TripCheckinCandidate.status.in_(["pending", "snoozed"]),
                )
                .first()
            )
            if existing_candidate and _ensure_auto_moment(db, candidate=existing_candidate, cluster=cluster):
                result.moments_created += 1
            continue

        result.candidates_created += 1
        if _ensure_auto_moment(db, candidate=candidate, cluster=cluster):
            result.moments_created += 1
        if candidate.confidence >= float(settings.TRACKING_NOTIFICATION_CONFIDENCE_THRESHOLD):
            result.notification_candidate_ids.append(candidate.id)

    return result


def handoff_candidate_notifications(
    db: Session,
    *,
    trip_id: Optional[UUID] = None,
    limit: int = 100,
    now: Optional[datetime] = None,
) -> NotificationHandoffResult:
    as_of = _to_utc(now or utcnow())

    query = db.query(TripCheckinCandidate).filter(
        TripCheckinCandidate.status == "pending",
        TripCheckinCandidate.confidence >= float(settings.TRACKING_NOTIFICATION_CONFIDENCE_THRESHOLD),
    )
    if trip_id is not None:
        query = query.filter(TripCheckinCandidate.trip_id == trip_id)

    candidates = (
        query.order_by(TripCheckinCandidate.created_at.asc())
        .limit(limit)
        .all()
    )

    dispatched: list[UUID] = []
    for candidate in candidates:
        payload = dict(candidate.payload or {})
        if payload.get("notification_handoff_at"):
            continue

        payload["notification_handoff_at"] = as_of.isoformat()
        payload["notification_handoff_id"] = str(uuid4())
        candidate.payload = payload
        dispatched.append(candidate.id)

    return NotificationHandoffResult(
        dispatched_count=len(dispatched),
        candidate_ids=dispatched,
    )


def run_auto_end_pass(
    db: Session,
    *,
    now: Optional[datetime] = None,
) -> AutoEndPassResult:
    as_of = _to_utc(now or utcnow())
    inactivity_cutoff = as_of - timedelta(hours=int(settings.TRACKING_AUTO_END_INACTIVITY_HOURS))

    sessions = (
        db.query(TripTrackingSession)
        .filter(TripTrackingSession.state.in_(["active", "paused"]))
        .all()
    )

    ended_session_ids: list[UUID] = []
    ended_trip_ids: list[UUID] = []
    for session in sessions:
        trip = db.query(Trip).filter(Trip.id == session.trip_id).first()
        if not trip:
            continue

        reason: Optional[str] = None
        if trip.end_date and as_of.date() > trip.end_date:
            reason = "end_date_reached"
        else:
            reference = session.last_point_at or session.resumed_at or session.started_at
            if reference is not None and _to_utc(reference) <= inactivity_cutoff:
                reason = "inactivity_threshold"

        if not reason:
            continue

        session.state = "ended"
        if session.ended_at is None:
            session.ended_at = as_of

        trip.status = "review_pending"
        if trip.tracking_ended_at is None:
            trip.tracking_ended_at = as_of
        trip.auto_end_reason = reason

        ended_session_ids.append(session.id)
        ended_trip_ids.append(trip.id)

    return AutoEndPassResult(
        scanned_sessions=len(sessions),
        auto_ended_sessions=len(ended_session_ids),
        ended_session_ids=ended_session_ids,
        ended_trip_ids=ended_trip_ids,
    )


def _claim_sessions_for_inference(db: Session, *, batch_size: int) -> list[TripTrackingSession]:
    """
    Claim candidate inference work units.

    Uses row-locking with SKIP LOCKED so multiple worker processes can run
    without double-processing the same session in the same loop.
    """
    return (
        db.query(TripTrackingSession)
        .filter(TripTrackingSession.last_point_at.is_not(None))
        .filter(TripTrackingSession.state.in_(["active", "paused", "ended"]))
        .order_by(TripTrackingSession.last_point_at.asc())
        .with_for_update(skip_locked=True)
        .limit(batch_size)
        .all()
    )


def run_worker_cycle(db: Session) -> dict[str, int]:
    batch_size = int(settings.TRACKING_WORKER_BATCH_SIZE)

    sessions = _claim_sessions_for_inference(db, batch_size=batch_size)
    candidates_created = 0
    moments_created = 0

    for session in sessions:
        result = process_session_inference(db, session_id=session.id)
        candidates_created += result.candidates_created
        moments_created += result.moments_created

    handoff = handoff_candidate_notifications(db, limit=batch_size * 2)
    auto_end = run_auto_end_pass(db)

    summary = {
        "sessions_scanned": len(sessions),
        "candidates_created": candidates_created,
        "moments_created": moments_created,
        "notifications_handed_off": handoff.dispatched_count,
        "auto_ended_sessions": auto_end.auto_ended_sessions,
    }
    return summary


def run_worker_forever() -> None:
    poll_seconds = max(1.0, float(settings.TRACKING_WORKER_POLL_SECONDS))
    logger.info("[LIVE_TRACKING_WORKER] starting poll_seconds=%s", poll_seconds)

    error_streak = 0
    while True:
        db = SessionLocal()
        try:
            summary = run_worker_cycle(db)
            db.commit()
            error_streak = 0

            if any(summary.values()):
                logger.info("[LIVE_TRACKING_WORKER] summary=%s", summary)

            time.sleep(poll_seconds)
        except Exception as exc:
            db.rollback()
            error_streak += 1
            backoff = RETRY_BACKOFF_SECONDS[min(error_streak - 1, len(RETRY_BACKOFF_SECONDS) - 1)]
            logger.exception(
                "[LIVE_TRACKING_WORKER] cycle_error streak=%s backoff=%ss error=%s",
                error_streak,
                backoff,
                exc,
            )
            time.sleep(backoff)
        finally:
            db.close()


if __name__ == "__main__":
    run_worker_forever()
