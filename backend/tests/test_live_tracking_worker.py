"""
Tests for live-tracking Phase 3 worker flows.
"""

from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from app.models.trip import Trip
from app.models.trip_auto_entity_tombstone import TripAutoEntityTombstone
from app.models.trip_checkin_candidate import TripCheckinCandidate
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_moment import TripMoment
from app.models.trip_tracking_notification import TripTrackingNotification
from app.models.trip_tracking_notification_event import TripTrackingNotificationEvent
from app.models.trip_tracking_session import TripTrackingSession
from app.models.user_device_token import UserDeviceToken
from app.workers.live_tracking_worker import (
    _adaptive_limit,
    _claim_sessions_for_inference,
    _emit_operational_alerts,
    build_candidate_fingerprint,
    dispatch_candidate_notifications,
    handoff_candidate_notifications,
    process_session_inference,
    run_auto_end_pass,
    run_worker_cycle,
)


def _create_trip(db, *, user_id, status="tracking_active", end_date=None):
    trip = Trip(
        id=uuid4(),
        user_id=user_id,
        title=f"Trip {uuid4()}",
        visibility="private",
        status=status,
        tracking_enabled=True,
        tracking_started_at=datetime.now(timezone.utc) - timedelta(hours=1),
        end_date=end_date,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture(autouse=True)
def ensure_user_device_tokens_table(db):
    UserDeviceToken.__table__.create(bind=db.bind, checkfirst=True)
    TripTrackingNotification.__table__.create(bind=db.bind, checkfirst=True)
    TripTrackingNotificationEvent.__table__.create(bind=db.bind, checkfirst=True)


def _create_session(db, *, trip_id, user_id, state="active", started_at=None, last_point_at=None):
    started = started_at or (datetime.now(timezone.utc) - timedelta(hours=1))
    session = TripTrackingSession(
        id=uuid4(),
        trip_id=trip_id,
        user_id=user_id,
        client_session_id=f"session-{uuid4()}",
        state=state,
        started_at=started,
        last_point_at=last_point_at,
        device_context={},
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def _add_point(db, *, session_id, trip_id, user_id, recorded_at, lat, lng, accuracy=5.0):
    point = TripLocationPoint(
        id=uuid4(),
        session_id=session_id,
        trip_id=trip_id,
        user_id=user_id,
        client_batch_id=uuid4(),
        point_id=uuid4(),
        recorded_at=recorded_at,
        latitude=lat,
        longitude=lng,
        accuracy_m=accuracy,
    )
    db.add(point)


def _seed_cluster_points(db, *, trip, session, base_time):
    _add_point(
        db,
        session_id=session.id,
        trip_id=trip.id,
        user_id=trip.user_id,
        recorded_at=base_time,
        lat=27.717200,
        lng=85.324000,
    )
    _add_point(
        db,
        session_id=session.id,
        trip_id=trip.id,
        user_id=trip.user_id,
        recorded_at=base_time + timedelta(minutes=4),
        lat=27.717250,
        lng=85.324020,
    )
    _add_point(
        db,
        session_id=session.id,
        trip_id=trip.id,
        user_id=trip.user_id,
        recorded_at=base_time + timedelta(minutes=8),
        lat=27.717280,
        lng=85.324040,
    )
    _add_point(
        db,
        session_id=session.id,
        trip_id=trip.id,
        user_id=trip.user_id,
        recorded_at=base_time + timedelta(minutes=12),
        lat=27.717260,
        lng=85.324010,
    )
    session.last_point_at = base_time + timedelta(minutes=12)
    db.commit()
    db.refresh(session)


def test_process_session_inference_is_retry_safe_for_candidates_and_moments(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    base = datetime.now(timezone.utc) - timedelta(minutes=20)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=base,
        last_point_at=base + timedelta(minutes=12),
    )
    _seed_cluster_points(db, trip=trip, session=session, base_time=base)

    first = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    db.flush()

    assert first.candidates_created == 1
    assert first.moments_created == 1

    second = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    db.flush()

    assert second.candidates_created == 0
    assert second.moments_created == 0
    assert second.scanned_points == 0

    candidate_count = (
        db.query(TripCheckinCandidate)
        .filter(TripCheckinCandidate.session_id == session.id)
        .count()
    )
    moment_count = (
        db.query(TripMoment)
        .join(TripCheckinCandidate, TripMoment.candidate_id == TripCheckinCandidate.id)
        .filter(TripCheckinCandidate.session_id == session.id)
        .count()
    )
    assert candidate_count == 1
    assert moment_count == 1


def test_process_session_inference_advances_cursor_and_skips_without_new_points(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    base = datetime.now(timezone.utc) - timedelta(minutes=25)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=base,
        last_point_at=base + timedelta(minutes=12),
    )
    _seed_cluster_points(db, trip=trip, session=session, base_time=base)

    first = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    db.flush()
    db.refresh(session)
    assert first.candidates_created == 1
    assert session.inference_cursor_at is not None
    assert session.inference_updated_at is not None

    second = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=21))
    db.flush()
    assert second.scanned_points == 0
    assert second.candidates_created == 0
    assert second.moments_created == 0


def test_claim_sessions_prioritizes_fresh_work_and_skips_fully_processed(db, test_user):
    now = datetime.now(timezone.utc)
    trip = _create_trip(db, user_id=test_user.id)

    stale = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="ended",
        started_at=now - timedelta(hours=2),
        last_point_at=now - timedelta(minutes=30),
    )
    fresh = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=1),
        last_point_at=now - timedelta(minutes=5),
    )
    done = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="paused",
        started_at=now - timedelta(hours=1),
        last_point_at=now - timedelta(minutes=1),
    )
    done.inference_cursor_at = done.last_point_at
    db.flush()

    claimed = _claim_sessions_for_inference(db, batch_size=10)
    claimed_ids = [row.id for row in claimed]

    assert done.id not in claimed_ids
    assert claimed_ids[0] == fresh.id
    assert stale.id in claimed_ids


def test_claim_sessions_includes_late_point_marker_without_max_timestamp_advance(db, test_user):
    now = datetime.now(timezone.utc)
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=1),
        last_point_at=now - timedelta(minutes=5),
    )
    session.inference_cursor_at = session.last_point_at
    session.oldest_uninferred_point_at = now - timedelta(minutes=20)
    db.flush()

    claimed = _claim_sessions_for_inference(db, batch_size=10)
    claimed_ids = [row.id for row in claimed]
    assert session.id in claimed_ids


def test_process_session_inference_reprocesses_when_late_marker_present(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    base = datetime.now(timezone.utc) - timedelta(minutes=30)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=base,
        last_point_at=base + timedelta(minutes=12),
    )
    _seed_cluster_points(db, trip=trip, session=session, base_time=base)
    process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    db.flush()
    db.refresh(session)

    # Inject a late point that does not advance max timestamp.
    _add_point(
        db,
        session_id=session.id,
        trip_id=trip.id,
        user_id=test_user.id,
        recorded_at=base + timedelta(minutes=6),
        lat=27.71726,
        lng=85.32403,
    )
    session.oldest_uninferred_point_at = base + timedelta(minutes=6)
    db.flush()

    rerun = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=25))
    db.flush()
    db.refresh(session)

    assert rerun.scanned_points > 0
    assert session.oldest_uninferred_point_at is None


def test_process_session_inference_respects_candidate_cooldown(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    base = datetime.now(timezone.utc) - timedelta(minutes=30)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        started_at=base,
        last_point_at=base + timedelta(minutes=12),
    )
    _seed_cluster_points(db, trip=trip, session=session, base_time=base)

    process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    candidate = (
        db.query(TripCheckinCandidate)
        .filter(TripCheckinCandidate.session_id == session.id)
        .first()
    )
    assert candidate is not None

    now = base + timedelta(minutes=25)
    candidate.status = "rejected"
    candidate.cooldown_until = now + timedelta(hours=2)
    # Rewind cursor to force re-evaluation of same inferred window/fingerprint.
    session.inference_cursor_at = base + timedelta(minutes=8)
    session.last_point_at = base + timedelta(minutes=12)
    db.flush()

    rerun = process_session_inference(db, session_id=session.id, now=now)
    db.flush()

    assert rerun.cooldown_suppressed >= 1
    count = (
        db.query(TripCheckinCandidate)
        .filter(TripCheckinCandidate.session_id == session.id)
        .count()
    )
    assert count == 1


def test_process_session_inference_respects_tombstone_suppression(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    base = datetime.now(timezone.utc) - timedelta(minutes=40)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        started_at=base,
        last_point_at=base + timedelta(minutes=12),
    )
    _seed_cluster_points(db, trip=trip, session=session, base_time=base)

    fingerprint = build_candidate_fingerprint(
        trip_id=trip.id,
        session_id=session.id,
        latitude=27.717248,
        longitude=85.3240175,
        started_at=base,
        ended_at=base + timedelta(minutes=12),
    )
    db.add(
        TripAutoEntityTombstone(
            id=uuid4(),
            trip_id=trip.id,
            user_id=test_user.id,
            entity_type="place",
            entity_fingerprint=fingerprint,
            deleted_entity_id=None,
            cooldown_expires_at=base + timedelta(days=2),
            reason="manual_delete",
        )
    )
    db.flush()

    result = process_session_inference(db, session_id=session.id, now=base + timedelta(minutes=20))
    db.flush()

    assert result.tombstone_suppressed >= 1
    candidate_count = (
        db.query(TripCheckinCandidate)
        .filter(TripCheckinCandidate.session_id == session.id)
        .count()
    )
    assert candidate_count == 0


def test_handoff_candidate_notifications_is_idempotent(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Inferred stop",
        payload={},
    )
    db.add(candidate)
    db.flush()

    first = handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    db.flush()
    assert first.dispatched_count == 1
    assert candidate.id in first.candidate_ids
    assert (candidate.payload or {}).get("notification_handoff_at") is not None

    second = handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    assert second.dispatched_count == 0
    inbox_rows = (
        db.query(TripTrackingNotification)
        .filter(
            TripTrackingNotification.candidate_id == candidate.id,
            TripTrackingNotification.channel == "inbox",
        )
        .all()
    )
    assert len(inbox_rows) == 1
    assert inbox_rows[0].delivery_state == "pending"


def test_handoff_candidate_notifications_skips_high_confidence_auto_candidates(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.95,
        suggested_name="High confidence auto-resolve",
        payload={},
    )
    db.add(candidate)
    db.flush()

    result = handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    db.flush()

    assert result.dispatched_count == 0
    assert result.candidate_ids == []
    assert (candidate.payload or {}).get("notification_handoff_at") is None


def test_handoff_candidate_notifications_filters_before_limit(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    now = datetime.now(timezone.utc)

    for _ in range(2):
        db.add(
            TripCheckinCandidate(
                id=uuid4(),
                trip_id=trip.id,
                user_id=test_user.id,
                session_id=session.id,
                fingerprint=f"fp-{uuid4()}",
                status="pending",
                confidence=0.75,
                suggested_name="Already handed off",
                payload={
                    "notification_handoff_at": now.isoformat(),
                    "notification_status": "pending",
                },
            )
        )

    pending_new = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Needs handoff",
        payload={},
    )
    db.add(pending_new)
    db.flush()

    result = handoff_candidate_notifications(
        db,
        trip_id=trip.id,
        limit=2,
        now=now + timedelta(seconds=5),
    )
    db.flush()

    assert result.dispatched_count == 1
    assert result.candidate_ids == [pending_new.id]
    assert (pending_new.payload or {}).get("notification_handoff_at") is not None


class _FakePushDispatchResult:
    def __init__(self, status: str, error_message: str | None = None):
        self.status = status
        self.sent_count = 1 if status == "sent" else 0
        self.invalidated_count = 0
        self.error_message = error_message


class _FakePushService:
    def __init__(self, status: str, error_message: str | None = None):
        self.status = status
        self.error_message = error_message
        self.calls = 0

    def send_candidate_notification(self, *, candidate, now=None):
        self.calls += 1
        return _FakePushDispatchResult(self.status, self.error_message)


def test_dispatch_candidate_notifications_marks_sent(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Inferred stop",
        payload={},
    )
    db.add(candidate)
    db.add(
        UserDeviceToken(
            id=uuid4(),
            user_id=test_user.id,
            platform="android",
            push_token=f"token-{uuid4().hex}-abcdef123456",
            is_active=True,
        )
    )
    db.flush()

    handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    fake_service = _FakePushService(status="sent")

    result = dispatch_candidate_notifications(
        db,
        push_service=fake_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()

    assert result.attempted_count == 1
    assert result.sent_count == 1
    assert fake_service.calls == 1
    payload = dict(candidate.payload or {})
    assert payload.get("notification_status") == "sent"
    assert payload.get("notification_sent_at") is not None


def test_dispatch_candidate_notifications_sets_retryable_backoff(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Inferred stop",
        payload={},
    )
    db.add(candidate)
    db.flush()

    handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    fake_service = _FakePushService(status="retryable_failure", error_message="timeout")

    result = dispatch_candidate_notifications(
        db,
        push_service=fake_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()

    assert result.attempted_count == 1
    assert result.retryable_failures == 1
    payload = dict(candidate.payload or {})
    assert payload.get("notification_status") == "retryable_failure"
    assert payload.get("notification_attempt_count") == 1
    assert payload.get("notification_next_attempt_at") is not None
    assert payload.get("notification_last_error") == "timeout"
    push_row = (
        db.query(TripTrackingNotification)
        .filter(
            TripTrackingNotification.candidate_id == candidate.id,
            TripTrackingNotification.channel == "push",
        )
        .first()
    )
    assert push_row is not None
    assert push_row.delivery_state == "retryable_failure"
    assert push_row.attempt_count == 1
    push_events = (
        db.query(TripTrackingNotificationEvent)
        .filter(TripTrackingNotificationEvent.notification_id == push_row.id)
        .order_by(TripTrackingNotificationEvent.created_at.asc())
        .all()
    )
    assert len(push_events) == 1
    assert push_events[0].event_type == "dispatch"
    assert push_events[0].delivery_state == "retryable_failure"


def test_dispatch_candidate_notifications_records_inbox_when_push_has_no_tokens(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="No token candidate",
        payload={},
    )
    db.add(candidate)
    db.flush()

    handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    fake_service = _FakePushService(status="no_tokens")

    result = dispatch_candidate_notifications(
        db,
        push_service=fake_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()

    assert result.attempted_count == 1
    assert result.skipped_no_tokens == 1

    inbox_row = (
        db.query(TripTrackingNotification)
        .filter(
            TripTrackingNotification.candidate_id == candidate.id,
            TripTrackingNotification.channel == "inbox",
        )
        .first()
    )
    push_row = (
        db.query(TripTrackingNotification)
        .filter(
            TripTrackingNotification.candidate_id == candidate.id,
            TripTrackingNotification.channel == "push",
        )
        .first()
    )
    assert inbox_row is not None
    assert inbox_row.delivery_state == "pending"
    assert push_row is not None
    assert push_row.delivery_state == "no_tokens"
    assert push_row.attempt_count == 1


def test_no_tokens_policy_is_terminal_for_candidate_push(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Terminal no-token",
        payload={},
    )
    db.add(candidate)
    db.flush()

    handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    no_token_service = _FakePushService(status="no_tokens")
    first = dispatch_candidate_notifications(
        db,
        push_service=no_token_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()
    assert first.skipped_no_tokens == 1

    db.add(
        UserDeviceToken(
            id=uuid4(),
            user_id=test_user.id,
            platform="android",
            push_token=f"token-{uuid4().hex}-abcdef123456",
            is_active=True,
        )
    )
    db.flush()

    sent_service = _FakePushService(status="sent")
    second = dispatch_candidate_notifications(
        db,
        push_service=sent_service,
        now=datetime.now(timezone.utc) + timedelta(minutes=5),
    )
    db.flush()

    assert second.attempted_count == 0
    assert second.sent_count == 0
    assert sent_service.calls == 0
    assert (candidate.payload or {}).get("notification_status") == "skipped_no_tokens"


def test_push_notification_events_are_append_only_across_attempts(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    candidate = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Event history",
        payload={},
    )
    db.add(candidate)
    db.flush()

    handoff_candidate_notifications(db, trip_id=trip.id, now=datetime.now(timezone.utc))
    retry_service = _FakePushService(status="retryable_failure", error_message="timeout")
    dispatch_candidate_notifications(
        db,
        push_service=retry_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()

    payload = dict(candidate.payload or {})
    payload["notification_next_attempt_at"] = (datetime.now(timezone.utc) - timedelta(seconds=1)).isoformat()
    candidate.payload = payload
    db.flush()

    sent_service = _FakePushService(status="sent")
    dispatch_candidate_notifications(
        db,
        push_service=sent_service,
        now=datetime.now(timezone.utc),
    )
    db.flush()

    push_row = (
        db.query(TripTrackingNotification)
        .filter(
            TripTrackingNotification.candidate_id == candidate.id,
            TripTrackingNotification.channel == "push",
        )
        .first()
    )
    assert push_row is not None

    events = (
        db.query(TripTrackingNotificationEvent)
        .filter(TripTrackingNotificationEvent.notification_id == push_row.id)
        .order_by(TripTrackingNotificationEvent.created_at.asc())
        .all()
    )
    assert len(events) == 2
    assert [event.delivery_state for event in events] == ["retryable_failure", "sent"]
    assert [event.attempt_count for event in events] == [1, 2]


def test_dispatch_candidate_notifications_filters_due_before_limit(db, test_user):
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(db, trip_id=trip.id, user_id=test_user.id)
    now = datetime.now(timezone.utc)

    not_due_rows: list[TripCheckinCandidate] = []
    for _ in range(3):
        row = TripCheckinCandidate(
            id=uuid4(),
            trip_id=trip.id,
            user_id=test_user.id,
            session_id=session.id,
            fingerprint=f"fp-{uuid4()}",
            status="pending",
            confidence=0.75,
            suggested_name="Retry later",
            payload={
                "notification_handoff_at": (now - timedelta(minutes=5)).isoformat(),
                "notification_status": "retryable_failure",
                "notification_attempt_count": 1,
                "notification_next_attempt_at": (now + timedelta(hours=2)).isoformat(),
            },
        )
        db.add(row)
        not_due_rows.append(row)

    due = TripCheckinCandidate(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        fingerprint=f"fp-{uuid4()}",
        status="pending",
        confidence=0.75,
        suggested_name="Dispatch now",
        payload={
            "notification_handoff_at": (now - timedelta(minutes=1)).isoformat(),
            "notification_status": "retryable_failure",
            "notification_attempt_count": 1,
            "notification_next_attempt_at": (now - timedelta(seconds=1)).isoformat(),
        },
    )
    db.add(due)
    db.flush()

    fake_service = _FakePushService(status="sent")
    result = dispatch_candidate_notifications(
        db,
        push_service=fake_service,
        limit=2,
        now=now,
    )
    db.flush()

    assert result.attempted_count == 1
    assert result.sent_count == 1
    assert fake_service.calls == 1
    assert (due.payload or {}).get("notification_status") == "sent"
    for row in not_due_rows:
        assert (row.payload or {}).get("notification_status") == "retryable_failure"


def test_run_auto_end_pass_closes_stale_inactive_sessions(db, test_user):
    now = datetime.now(timezone.utc)
    trip = _create_trip(db, user_id=test_user.id, status="tracking_active")
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=8),
        last_point_at=now - timedelta(hours=7),
    )

    result = run_auto_end_pass(db, now=now)
    db.flush()

    assert result.auto_ended_sessions == 1
    assert session.id in result.ended_session_ids
    db.refresh(session)
    db.refresh(trip)
    assert session.state == "ended"
    assert trip.status == "review_pending"
    assert trip.auto_end_reason == "inactivity_threshold"

    second = run_auto_end_pass(db, now=now + timedelta(minutes=5))
    assert second.auto_ended_sessions == 0


def test_run_auto_end_pass_respects_trip_end_date(db, test_user):
    now = datetime.now(timezone.utc)
    trip = _create_trip(
        db,
        user_id=test_user.id,
        status="tracking_active",
        end_date=now.date() - timedelta(days=1),
    )
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=2),
        last_point_at=now - timedelta(minutes=30),
    )

    result = run_auto_end_pass(db, now=now)
    db.flush()

    assert result.auto_ended_sessions == 1
    db.refresh(session)
    db.refresh(trip)
    assert session.state == "ended"
    assert trip.auto_end_reason == "end_date_reached"


def test_run_worker_cycle_isolates_single_session_failure(db, test_user, monkeypatch):
    now = datetime.now(timezone.utc)
    trip = _create_trip(db, user_id=test_user.id)
    bad = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="ended",
        started_at=now - timedelta(hours=1),
        last_point_at=now - timedelta(minutes=3),
    )
    _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=1),
        last_point_at=now - timedelta(minutes=1),
    )
    db.flush()

    import app.workers.live_tracking_worker as worker_module

    def _fake_process(db_session, *, session_id, now=None):
        if session_id == bad.id:
            raise RuntimeError("poison session")
        return worker_module.SessionInferenceResult(
            session_id=session_id,
            candidates_created=1,
            moments_created=1,
        )

    monkeypatch.setattr(worker_module, "process_session_inference", _fake_process)

    summary = run_worker_cycle(db)
    db.flush()

    assert summary["sessions_scanned"] == 2
    assert summary["session_errors"] == 1
    assert summary["candidates_created"] == 1
    assert summary["moments_created"] == 1


def test_adaptive_limit_scales_with_backlog():
    assert _adaptive_limit(base_limit=5, backlog_count=2, max_multiplier=4) == 5
    assert _adaptive_limit(base_limit=5, backlog_count=8, max_multiplier=4) == 8
    assert _adaptive_limit(base_limit=5, backlog_count=50, max_multiplier=4) == 20


def test_emit_operational_alerts_logs_threshold_breaches(monkeypatch, caplog):
    import app.workers.live_tracking_worker as worker_module

    monkeypatch.setattr(worker_module.settings, "TRACKING_ALERT_RETRYABLE_BACKLOG_THRESHOLD", 2)
    monkeypatch.setattr(worker_module.settings, "TRACKING_ALERT_DISPATCH_LAG_MINUTES", 1)
    monkeypatch.setattr(worker_module.settings, "TRACKING_ALERT_STUCK_SESSION_THRESHOLD", 1)
    monkeypatch.setattr(worker_module.settings, "TRACKING_ALERT_INFERENCE_BACKLOG_THRESHOLD", 3)

    with caplog.at_level("WARNING"):
        _emit_operational_alerts(
            {
                "notifications_retryable_backlog": 3,
                "dispatch_oldest_due_age_seconds": 120,
                "stuck_active_sessions": 1,
                "inference_backlog": 5,
            }
        )

    joined = "\n".join(record.message for record in caplog.records)
    assert "type=retryable_backlog" in joined
    assert "type=dispatch_lag" in joined
    assert "type=stuck_active_sessions" in joined
    assert "type=inference_backlog" in joined


def test_run_worker_cycle_scales_dispatch_limit_under_backlog(db, test_user, monkeypatch):
    import app.workers.live_tracking_worker as worker_module

    monkeypatch.setattr(worker_module.settings, "TRACKING_WORKER_BATCH_SIZE", 1)
    monkeypatch.setattr(worker_module.settings, "TRACKING_WORKER_MAX_BATCH_MULTIPLIER", 4)

    now = datetime.now(timezone.utc)
    trip = _create_trip(db, user_id=test_user.id)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        state="active",
        started_at=now - timedelta(hours=1),
        last_point_at=now,
    )
    for _ in range(5):
        db.add(
            TripCheckinCandidate(
                id=uuid4(),
                trip_id=trip.id,
                user_id=test_user.id,
                session_id=session.id,
                fingerprint=f"fp-{uuid4()}",
                status="pending",
                confidence=0.75,
                suggested_name="Dispatch backlog",
                payload={
                    "notification_handoff_at": (now - timedelta(minutes=1)).isoformat(),
                    "notification_status": "retryable_failure",
                    "notification_attempt_count": 0,
                    "notification_next_attempt_at": (now - timedelta(seconds=1)).isoformat(),
                },
            )
        )
    db.flush()

    class _NoOpPushService:
        def __init__(self, db_session):
            self.db = db_session

        def send_candidate_notification(self, *, candidate, now=None):
            return _FakePushDispatchResult("retryable_failure", "transport timeout")

    monkeypatch.setattr(worker_module, "PushNotificationService", _NoOpPushService)

    summary = run_worker_cycle(db)
    db.flush()

    assert summary["notification_dispatch_backlog"] >= 5
    assert summary["notification_dispatch_limit"] == 5
    assert summary["notifications_attempted"] == 5
