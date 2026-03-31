"""
Tests for compiled projection endpoints and compiler baseline behavior.
"""

from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.trip_compiled_projection_item import TripCompiledProjectionItem
from app.models.trip_compiled_projection_override import TripCompiledProjectionOverride
from app.models.trip_compiled_projection_state import TripCompiledProjectionState
from app.models.trip_compiled_route_segment import TripCompiledRouteSegment
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_tracking_event import TripTrackingEvent
from app.models.trip_tracking_session import TripTrackingSession


def _iso(value: datetime) -> str:
    return value.astimezone(timezone.utc).isoformat()


def _create_trip(db, *, user_id):
    trip = Trip(
        id=uuid4(),
        user_id=user_id,
        title=f"Trip {uuid4()}",
        visibility="private",
        status="planned",
        tracking_enabled=True,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _create_session(db, *, trip_id, user_id, started_at):
    session = TripTrackingSession(
        id=uuid4(),
        trip_id=trip_id,
        user_id=user_id,
        client_session_id=str(uuid4()),
        state="active",
        started_at=started_at,
        device_context={},
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


@pytest.fixture(autouse=True)
def ensure_compiled_projection_tables(db):
    TripCompiledProjectionState.__table__.create(bind=db.bind, checkfirst=True)
    TripCompiledProjectionItem.__table__.create(bind=db.bind, checkfirst=True)
    TripCompiledRouteSegment.__table__.create(bind=db.bind, checkfirst=True)
    TripCompiledProjectionOverride.__table__.create(bind=db.bind, checkfirst=True)


def test_compiled_projection_returns_on_route_entries_and_route_segments(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, user_id=test_user.id)
    now = datetime.now(timezone.utc)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        started_at=now - timedelta(minutes=10),
    )

    event = TripTrackingEvent(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        client_event_id=uuid4(),
        event_type="note",
        captured_at=now - timedelta(minutes=5),
        latitude=27.7000,
        longitude=85.3000,
        note="Coffee break",
        payload={},
    )
    db.add(event)

    p1 = TripLocationPoint(
        id=uuid4(),
        session_id=session.id,
        trip_id=trip.id,
        user_id=test_user.id,
        client_batch_id=uuid4(),
        point_id=uuid4(),
        recorded_at=now - timedelta(minutes=8),
        latitude=27.7000,
        longitude=85.3000,
        accuracy_m=5.0,
    )
    p2 = TripLocationPoint(
        id=uuid4(),
        session_id=session.id,
        trip_id=trip.id,
        user_id=test_user.id,
        client_batch_id=uuid4(),
        point_id=uuid4(),
        recorded_at=now - timedelta(minutes=7),
        latitude=27.7007,
        longitude=85.3009,
        accuracy_m=6.0,
    )
    db.add_all([p1, p2])
    db.commit()

    first = client.get(f"/api/v1/trips/{trip.id}/compiled/projection")
    assert first.status_code == 200
    payload = first.json()
    assert payload["trip_id"] == str(trip.id)
    assert payload["stale"] is False
    assert payload["stats"]["raw_event_count"] == 1
    assert payload["stats"]["compiled_event_count"] == 1
    assert payload["stats"]["compiled_route_segment_count"] >= 1
    assert payload["timeline_entries"][0]["bucket_type"] == "on_route"

    second = client.get(f"/api/v1/trips/{trip.id}/compiled/projection")
    assert second.status_code == 200
    payload2 = second.json()
    assert payload2["timeline_entries"][0]["entry_id"] == payload["timeline_entries"][0]["entry_id"]
    assert len(payload2["timeline_entries"]) == 1


def test_compiled_projection_manual_rebind_persists_across_recompile(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, user_id=test_user.id)
    now = datetime.now(timezone.utc)
    session = _create_session(
        db,
        trip_id=trip.id,
        user_id=test_user.id,
        started_at=now - timedelta(minutes=10),
    )

    place = TripPlace(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Cafe House",
        place_type="cafe",
        location="SRID=4326;POINT(85.3240 27.7172)",
        lat=27.7172,
        lng=85.3240,
        order_in_trip=0,
    )
    db.add(place)

    event = TripTrackingEvent(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        client_event_id=uuid4(),
        event_type="tag",
        captured_at=now - timedelta(minutes=5),
        latitude=27.9000,
        longitude=85.1000,
        note="Checkpoint",
        payload={},
    )
    db.add(event)
    db.commit()

    before = client.get(f"/api/v1/trips/{trip.id}/compiled/projection")
    assert before.status_code == 200
    before_payload = before.json()
    assert before_payload["timeline_entries"][0]["bucket_type"] == "on_route"

    rebind = client.post(
        f"/api/v1/trips/{trip.id}/compiled/rebind",
        json={
            "source_event_id": str(event.id),
            "action": "bind",
            "trip_place_id": str(place.id),
        },
    )
    assert rebind.status_code == 200
    rebound = rebind.json()
    assert rebound["timeline_entries"][0]["bucket_type"] == "place"
    assert rebound["timeline_entries"][0]["place_id"] == str(place.id)
    assert rebound["timeline_entries"][0]["bind_source"] == "manual"

    # Force another compile pass by ingesting one more event.
    event2 = TripTrackingEvent(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        client_event_id=uuid4(),
        event_type="note",
        captured_at=now - timedelta(minutes=2),
        latitude=27.7169,
        longitude=85.3238,
        note="Second event",
        payload={},
    )
    db.add(event2)
    state = db.query(TripCompiledProjectionState).filter(
        TripCompiledProjectionState.trip_id == trip.id
    ).first()
    assert state is not None
    state.dirty = True
    db.commit()

    after = client.get(f"/api/v1/trips/{trip.id}/compiled/projection")
    assert after.status_code == 200
    after_payload = after.json()
    rebound_entry = next(
        entry for entry in after_payload["timeline_entries"] if entry["source_id"] == str(event.id)
    )
    assert rebound_entry["bucket_type"] == "place"
    assert rebound_entry["place_id"] == str(place.id)
    assert rebound_entry["bind_source"] == "manual"


def test_events_batch_marks_projection_dirty_and_projection_compiles(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, user_id=test_user.id)
    now = datetime.now(timezone.utc)

    response = client.post(
        f"/api/v1/trips/{trip.id}/tracking/events:batch",
        json={
            "events": [
                {
                    "client_event_id": str(uuid4()),
                    "event_type": "note",
                    "captured_at": _iso(now),
                    "note": "Quick note",
                    "location": {"latitude": 27.7, "longitude": 85.3},
                    "payload": {},
                }
            ]
        },
        headers={"X-Idempotency-Key": str(uuid4())},
    )
    assert response.status_code == 202
    assert response.json()["accepted_count"] == 1

    state = db.query(TripCompiledProjectionState).filter(
        TripCompiledProjectionState.trip_id == trip.id
    ).first()
    assert state is not None
    assert state.dirty is True

    compiled = client.get(f"/api/v1/trips/{trip.id}/compiled/projection")
    assert compiled.status_code == 200
    payload = compiled.json()
    assert payload["stats"]["raw_event_count"] == 1
    assert len(payload["timeline_entries"]) == 1

    db.refresh(state)
    assert state.dirty is False

