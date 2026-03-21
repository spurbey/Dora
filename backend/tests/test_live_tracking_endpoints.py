"""
Tests for live-tracking Phase 2 endpoints and service invariants.
"""

from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest
from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError

from app.models.trip import Trip
from app.models.trip_checkin_candidate import TripCheckinCandidate
from app.models.trip_tracking_session import TripTrackingSession
from app.services.live_tracking_service import LiveTrackingService


def _iso_now(offset_seconds: int = 0) -> str:
    return (datetime.now(timezone.utc) + timedelta(seconds=offset_seconds)).isoformat()


def create_trip(db, user_id, title="Tracking Trip", status="planned"):
    trip = Trip(
        id=uuid4(),
        user_id=user_id,
        title=title,
        visibility="private",
        status=status,
        tracking_enabled=False,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def create_session(db, trip_id, user_id, state="active"):
    session = TripTrackingSession(
        id=uuid4(),
        trip_id=trip_id,
        user_id=user_id,
        client_session_id=f"client-{uuid4()}",
        state=state,
        started_at=datetime.now(timezone.utc),
        device_context={},
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def create_candidate(
    db,
    trip_id,
    user_id,
    *,
    session_id=None,
    status="pending",
    fingerprint=None,
    suggested_name="Cafe",
    suggested_latitude=27.7172,
    suggested_longitude=85.3240,
    snoozed_until=None,
    cooldown_until=None,
):
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip_id,
        user_id=user_id,
        session_id=session_id,
        fingerprint=fingerprint or f"fp-{uuid4()}",
        status=status,
        confidence=0.9,
        suggested_name=suggested_name,
        suggested_latitude=suggested_latitude,
        suggested_longitude=suggested_longitude,
        snoozed_until=snoozed_until,
        cooldown_until=cooldown_until,
        payload={},
    )
    db.add(candidate)
    db.commit()
    db.refresh(candidate)
    return candidate


def _idem() -> str:
    return str(uuid4())


def test_tracking_start_idempotency_and_conflict(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Start Idempotent")

    body = {
        "client_session_id": "ios-session-1",
        "started_at": _iso_now(),
        "timezone": "Asia/Kathmandu",
        "device_context": {"platform": "ios"},
    }
    key = _idem()

    first = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json=body,
        headers={"X-Idempotency-Key": key},
    )
    assert first.status_code == 200
    first_data = first.json()
    assert first_data["state"] == "active"
    assert first.headers["Idempotency-Replayed"] == "false"

    replay = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json=body,
        headers={"X-Idempotency-Key": key},
    )
    assert replay.status_code == 200
    assert replay.json()["session_id"] == first_data["session_id"]
    assert replay.headers["Idempotency-Replayed"] == "true"

    conflict = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json={**body, "client_session_id": "ios-session-2"},
        headers={"X-Idempotency-Key": key},
    )
    assert conflict.status_code == 409
    assert conflict.json()["detail"]["error_code"] == "idempotency_conflict"


def test_idempotency_key_cannot_be_reused_across_different_trip_resources(client, db, test_user, auth_as):
    auth_as(test_user)
    trip_a = create_trip(db, test_user.id, title="Trip A")
    trip_b = create_trip(db, test_user.id, title="Trip B")

    body = {
        "client_session_id": "shared-key-session",
        "started_at": _iso_now(),
        "timezone": "UTC",
        "device_context": {"platform": "android"},
    }
    key = _idem()

    first = client.post(
        f"/api/v1/trips/{trip_a.id}/tracking/start",
        json=body,
        headers={"X-Idempotency-Key": key},
    )
    assert first.status_code == 200
    assert first.headers["Idempotency-Replayed"] == "false"

    second = client.post(
        f"/api/v1/trips/{trip_b.id}/tracking/start",
        json=body,
        headers={"X-Idempotency-Key": key},
    )
    assert second.status_code == 409
    assert second.json()["detail"]["error_code"] == "idempotency_conflict"


def test_tracking_start_rejects_non_planned_trip_status(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Review Pending", status="review_pending")

    response = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json={
            "client_session_id": "restart-attempt",
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "ios"},
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert response.status_code == 409
    assert response.json()["detail"] == "Tracking can only be started from planned trip status"


def test_tracking_pause_resume_stop_transitions(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Transitions")

    start = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json={
            "client_session_id": "android-1",
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android"},
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    session_id = start.json()["session_id"]

    paused = client.post(
        f"/api/v1/trips/{trip.id}/tracking/pause",
        json={
            "client_event_id": str(uuid4()),
            "session_id": session_id,
            "paused_at": _iso_now(1),
            "reason": "break",
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert paused.status_code == 200
    assert paused.json()["state"] == "paused"

    resumed = client.post(
        f"/api/v1/trips/{trip.id}/tracking/resume",
        json={
            "client_event_id": str(uuid4()),
            "session_id": session_id,
            "resumed_at": _iso_now(2),
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert resumed.status_code == 200
    assert resumed.json()["state"] == "active"

    stopped = client.post(
        f"/api/v1/trips/{trip.id}/tracking/stop",
        json={
            "client_event_id": str(uuid4()),
            "session_id": session_id,
            "stopped_at": _iso_now(3),
            "reason": "done",
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert stopped.status_code == 200
    assert stopped.json()["state"] == "ended"
    assert stopped.json()["trip_status"] == "review_pending"


def test_points_batch_dedup_and_replay(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Batch Dedup")

    start = client.post(
        f"/api/v1/trips/{trip.id}/tracking/start",
        json={
            "client_session_id": "batch-session",
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {},
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    session_id = start.json()["session_id"]

    points = [
        {
            "point_id": str(uuid4()),
            "recorded_at": _iso_now(1),
            "latitude": 27.7172,
            "longitude": 85.3240,
            "accuracy_m": 5.0,
        },
        {
            "point_id": str(uuid4()),
            "recorded_at": _iso_now(2),
            "latitude": 27.7180,
            "longitude": 85.3250,
            "accuracy_m": 6.0,
        },
        {
            "point_id": str(uuid4()),
            "recorded_at": _iso_now(3),
            "latitude": 27.7190,
            "longitude": 85.3260,
            "accuracy_m": 7.0,
        },
    ]
    payload = {
        "session_id": session_id,
        "client_batch_id": str(uuid4()),
        "sent_at": _iso_now(4),
        "points": points,
    }
    key = _idem()

    first = client.post(
        f"/api/v1/trips/{trip.id}/tracking/points:batch",
        json=payload,
        headers={"X-Idempotency-Key": key},
    )
    assert first.status_code == 202
    assert first.json()["accepted_points"] == 3
    assert first.json()["duplicate_points"] == 0
    assert first.json()["idempotency_replayed"] is False

    replay = client.post(
        f"/api/v1/trips/{trip.id}/tracking/points:batch",
        json=payload,
        headers={"X-Idempotency-Key": key},
    )
    assert replay.status_code == 202
    assert replay.json()["accepted_points"] == 3
    assert replay.json()["duplicate_points"] == 0
    assert replay.json()["idempotency_replayed"] is True

    second_key = client.post(
        f"/api/v1/trips/{trip.id}/tracking/points:batch",
        json=payload,
        headers={"X-Idempotency-Key": _idem()},
    )
    assert second_key.status_code == 202
    assert second_key.json()["accepted_points"] == 0
    assert second_key.json()["duplicate_points"] == 3


def test_pending_checkins_filters_snoozed_until(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Pending Checkins")
    session = create_session(db, trip.id, test_user.id)

    create_candidate(db, trip.id, test_user.id, session_id=session.id, status="pending")
    create_candidate(
        db,
        trip.id,
        test_user.id,
        session_id=session.id,
        status="snoozed",
        snoozed_until=datetime.now(timezone.utc) - timedelta(minutes=1),
    )
    create_candidate(
        db,
        trip.id,
        test_user.id,
        session_id=session.id,
        status="snoozed",
        snoozed_until=datetime.now(timezone.utc) + timedelta(hours=1),
    )

    response = client.get(f"/api/v1/trips/{trip.id}/checkins/pending")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 2
    statuses = {item["status"] for item in data["candidates"]}
    assert statuses == {"pending", "snoozed"}


def test_candidate_actions_reject_snooze_confirm(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Candidate Actions")
    session = create_session(db, trip.id, test_user.id)

    to_reject = create_candidate(db, trip.id, test_user.id, session_id=session.id)
    reject = client.post(
        f"/api/v1/checkins/{to_reject.id}/reject",
        json={
            "client_event_id": str(uuid4()),
            "rejected_at": _iso_now(),
            "reason": "not now",
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert reject.status_code == 200
    assert reject.json()["candidate"]["status"] == "rejected"
    assert reject.json()["candidate"]["cooldown_until"] is not None

    to_snooze = create_candidate(db, trip.id, test_user.id, session_id=session.id)
    snooze = client.post(
        f"/api/v1/checkins/{to_snooze.id}/snooze",
        json={
            "client_event_id": str(uuid4()),
            "snoozed_until": _iso_now(1800),
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert snooze.status_code == 200
    assert snooze.json()["candidate"]["status"] == "snoozed"

    to_confirm = create_candidate(
        db,
        trip.id,
        test_user.id,
        session_id=session.id,
        suggested_name="Boudha",
        suggested_latitude=27.7215,
        suggested_longitude=85.3616,
    )
    confirm = client.post(
        f"/api/v1/checkins/{to_confirm.id}/confirm",
        json={
            "client_event_id": str(uuid4()),
            "confirmed_at": _iso_now(),
            "place_override": {
                "name": "Boudha Stupa",
                "latitude": 27.7216,
                "longitude": 85.3617,
            },
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert confirm.status_code == 200
    payload = confirm.json()["candidate"]
    assert payload["status"] == "confirmed"
    assert payload["confirmed_trip_place_id"] is not None


def test_moment_create_update_list(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Moments")

    create = client.post(
        f"/api/v1/trips/{trip.id}/moments",
        json={
            "client_event_id": str(uuid4()),
            "captured_at": _iso_now(),
            "note": "Sunrise",
            "location": {"latitude": 27.70, "longitude": 85.33},
            "media_refs": [],
            "extra_payload": {"weather": "clear"},
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert create.status_code == 201
    moment_id = create.json()["id"]

    update = client.patch(
        f"/api/v1/moments/{moment_id}",
        json={
            "client_event_id": str(uuid4()),
            "note": "Golden sunrise",
            "location": {"latitude": 27.701, "longitude": 85.331},
        },
        headers={"X-Idempotency-Key": _idem()},
    )
    assert update.status_code == 200
    assert update.json()["note"] == "Golden sunrise"

    listing = client.get(f"/api/v1/trips/{trip.id}/moments")
    assert listing.status_code == 200
    assert listing.json()["total"] == 1
    assert listing.json()["moments"][0]["id"] == moment_id


def test_manual_only_finalize_planned_to_completed(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Manual Finalize", status="planned")
    key = _idem()
    request_payload = {
        "client_event_id": str(uuid4()),
        "committed_at": _iso_now(),
    }

    first = client.post(
        f"/api/v1/trips/{trip.id}/auto-finalize/commit",
        json=request_payload,
        headers={"X-Idempotency-Key": key},
    )
    assert first.status_code == 200
    assert first.json()["status"] == "completed"
    assert first.json()["idempotency_replayed"] is False

    replay = client.post(
        f"/api/v1/trips/{trip.id}/auto-finalize/commit",
        json=request_payload,
        headers={"X-Idempotency-Key": key},
    )
    assert replay.status_code == 200
    assert replay.json()["status"] == "completed"
    assert replay.json()["idempotency_replayed"] is True


def test_candidate_cooldown_helper_enforced(db, test_user):
    trip = create_trip(db, test_user.id, title="Cooldown", status="planned")
    create_candidate(
        db,
        trip.id,
        test_user.id,
        status="rejected",
        fingerprint="same-fp",
        cooldown_until=datetime.now(timezone.utc) + timedelta(hours=2),
    )
    service = LiveTrackingService(db)

    with pytest.raises(HTTPException) as exc:
        service.assert_candidate_fingerprint_available(
            trip_id=trip.id,
            user_id=test_user.id,
            fingerprint="same-fp",
        )

    assert exc.value.status_code == 409


class _FakeConstraintDiag:
    def __init__(self, constraint_name: str):
        self.constraint_name = constraint_name


class _FakeIntegrityOrig(Exception):
    def __init__(self, constraint_name: str):
        super().__init__(constraint_name)
        self.diag = _FakeConstraintDiag(constraint_name)


def test_run_idempotent_mutation_maps_business_integrity_race_to_conflict(db, test_user):
    service = LiveTrackingService(db)
    trip = create_trip(db, test_user.id, title="Integrity Race")

    def _operation():
        raise IntegrityError(
            "insert into trip_tracking_sessions",
            {"trip_id": str(trip.id)},
            _FakeIntegrityOrig("uq_tracking_session_active_trip_user"),
        )

    with pytest.raises(HTTPException) as exc:
        service.run_idempotent_mutation(
            user_id=test_user.id,
            endpoint_signature="POST:/trips/{trip_id}/tracking/start",
            idempotency_key=_idem(),
            request_payload={"trip_id": str(trip.id), "client_session_id": "abc"},
            operation=_operation,
        )

    assert exc.value.status_code == 409
    assert exc.value.detail == "Tracking session already active for trip"
