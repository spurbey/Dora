import asyncio
from datetime import datetime, timezone
from uuid import uuid4

from app.models.trip import Trip
from app.models.trip_metadata import TripMetadata
from app.models.trip_tracking_session import TripTrackingSession
from app.schemas.route import RouteCreate
from app.schemas.trip_metadata import TripMetadataUpdate
from app.api.v1.routes import create_route
from app.api.v1.metadata import update_trip_metadata
from app.services.live_tracking_service import LiveTrackingService


def test_create_route_triggers_route_changed_reseed(db, test_user):
    trip = Trip(user_id=test_user.id, title="Route Hook Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    called = {"count": 0}

    def _fake_reseed(_db, _trip_id):
        called["count"] += 1

    # Patch module helper used by endpoint.
    import app.api.v1.routes as routes_api
    original = routes_api._best_effort_route_reseed
    routes_api._best_effort_route_reseed = _fake_reseed
    try:
        route = asyncio.run(
            create_route(
                trip_id=trip.id,
                route_data=RouteCreate(
                    route_geojson={
                        "type": "LineString",
                        "coordinates": [[77.5946, 12.9716], [77.6, 13.0]],
                    },
                    transport_mode="car",
                    route_category="ground",
                    order_in_trip=0,
                ),
                current_user=test_user,
                db=db,
            )
        )
    finally:
        routes_api._best_effort_route_reseed = original

    assert route.id is not None
    assert called["count"] == 1


def test_update_trip_metadata_triggers_metadata_changed_reseed(
    db, test_user
):
    trip = Trip(user_id=test_user.id, title="Metadata Hook Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    metadata = TripMetadata(trip_id=trip.id, traveler_type=["solo"])
    db.add(metadata)
    db.commit()

    called = {"count": 0}

    def _fake_reseed(_db, _trip_id):
        called["count"] += 1

    import app.api.v1.metadata as metadata_api
    original = metadata_api._best_effort_metadata_reseed
    metadata_api._best_effort_metadata_reseed = _fake_reseed
    try:
        metadata = asyncio.run(
            update_trip_metadata(
                trip_id=trip.id,
                metadata_data=TripMetadataUpdate(budget_category="budget"),
                current_user=test_user,
                db=db,
            )
        )
    finally:
        metadata_api._best_effort_metadata_reseed = original

    assert metadata.budget_category == "budget"
    assert called["count"] == 1


def test_commit_auto_finalize_triggers_brain_complete(db, test_user, monkeypatch):
    trip = Trip(
        user_id=test_user.id,
        title="Finalize Hook Trip",
        visibility="private",
        status="review_pending",
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)

    captured = {"trip_id": None, "count": 0}

    def _fake_complete(self, trip_id):
        captured["count"] += 1
        captured["trip_id"] = str(trip_id)
        return None

    monkeypatch.setattr(
        "app.services.trip_brain_service.TripBrainService.complete",
        _fake_complete,
    )

    status_code, payload = LiveTrackingService(db).commit_auto_finalize(
        trip_id=trip.id,
        user_id=test_user.id,
        committed_at=datetime.now(timezone.utc),
    )

    assert status_code == 200
    assert payload["status"] == "completed"
    assert captured["count"] == 1
    assert captured["trip_id"] == str(trip.id)


def test_ingest_points_pushes_centroid_only_for_radius_mode(db, test_user, monkeypatch):
    trip = Trip(user_id=test_user.id, title="Centroid Hook Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    session = TripTrackingSession(
        trip_id=trip.id,
        user_id=test_user.id,
        client_session_id="client-session-1",
        state="active",
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    calls = {"get_mode": 0, "push": 0}

    async def fake_get_mode(_trip_id):
        calls["get_mode"] += 1
        return "radius"

    async def fake_push(_trip_id, _lat, _lng):
        calls["push"] += 1

    class _ImmediateLoop:
        def create_task(self, coro):
            import asyncio
            return asyncio.run(coro)

    monkeypatch.setattr(
        "app.services.live_tracking_service.advisory_cache.get_mode",
        fake_get_mode,
    )
    monkeypatch.setattr(
        "app.services.live_tracking_service.advisory_cache.push_centroid_point",
        fake_push,
    )
    monkeypatch.setattr(
        "app.services.live_tracking_service.asyncio.get_running_loop",
        lambda: _ImmediateLoop(),
    )

    service = LiveTrackingService(db)
    status_code, payload = service.ingest_points_batch(
        trip_id=trip.id,
        user_id=test_user.id,
        session_id=session.id,
        client_batch_id=uuid4(),
        points=[
            {
                "point_id": uuid4(),
                "recorded_at": datetime.now(timezone.utc),
                "latitude": 18.5204,
                "longitude": 73.8567,
                "accuracy_m": 10.0,
            }
        ],
    )

    assert status_code == 202
    assert payload["accepted_points"] == 1
    assert calls["get_mode"] == 1
    assert calls["push"] == 1
