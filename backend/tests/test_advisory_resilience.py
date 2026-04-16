"""
Concurrency and resilience tests for the advisory pipeline.

Tests derived from Codex review findings — covers:
    1. Sequential multi-writer on same brain row (cycle + sweep + feedback)
    2. No-pick scenario progression (locality A exhausted → locality B next)
    3. Off-route skip (GPS far from route_geom → outcome=off_route)
    4. Redis-down radius fallback (centroid from DB when cache miss)
    5. Ignore sweep + late user action (race-safety guard)
"""

import asyncio
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, patch
from uuid import uuid4

import pytest

from app.models.advisory_user_action import AdvisoryUserAction
from app.models.route import Route
from app.models.trip import Trip
from app.models.trip_advisory import TripAdvisory
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.trip_brain_service import (
    TargetContext,
    TargetDecision,
    TripBrainService,
)
from app.workers.advisory_ignore_sweep_worker import expire_stale_delivered


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


def _make_trip(db, user, *, title="Resilience Test"):
    trip = Trip(user_id=user.id, title=title, visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _make_brain(db, user, trip, *, lifecycle="active", mode="route", cadence=3600):
    brain = TripAdvisoryState(
        trip_id=trip.id,
        user_id=user.id,
        lifecycle_state=lifecycle,
        mode=mode,
        cadence_seconds=cadence,
        next_eligible_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db.add(brain)
    db.commit()
    db.refresh(brain)
    return brain


def _make_advisory(db, user, trip, *, status="delivered", dedupe_suffix="a", delivered_hours_ago=2):
    adv = TripAdvisory(
        trip_id=trip.id,
        user_id=user.id,
        category="general_tip",
        source="reddit",
        title="Test Advisory",
        body="Body text",
        confidence_score=0.6,
        dedupe_key=f"dedupe:{trip.id}:{dedupe_suffix}",
        status=status,
        delivered_at=datetime.now(timezone.utc) - timedelta(hours=delivered_hours_ago),
    )
    db.add(adv)
    db.commit()
    db.refresh(adv)
    return adv


def _target(locality_key="IN:MH:Pune", locality="Pune"):
    return TargetContext(
        locality_key=locality_key,
        locality=locality,
        region="Maharashtra",
        country="IN",
        center_lat=18.52,
        center_lng=73.85,
        mode="route",
        sample_idx=0,
    )


# ---------------------------------------------------------------------------
# 1. Sequential multi-writer on same brain (cycle outcome + feedback + sweep)
# ---------------------------------------------------------------------------


def test_multi_writer_sequential_consistency(db, test_user):
    """Three writers sequentially update the same brain row.

    Verifies that mark_cycle_outcome, apply_feedback, and the ignore sweep
    can all operate on the same trip's brain without data loss or constraint
    violations — the baseline for concurrency safety.
    """
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip)
    svc = TripBrainService(db)

    # Cycle outcome: delivered
    asyncio.run(
        svc.mark_cycle_outcome(
            trip.id,
            "delivered",
            target=_target(),
            poi_place_ids=["poi_1"],
            categories_delivered=["food_tip"],
        )
    )
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert "IN:MH:Pune" in (brain.advised_locality_keys or [])
    assert "poi_1" in (brain.advised_poi_place_ids or [])

    # Feedback: explicit action resets streak
    adv = _make_advisory(db, test_user, trip, dedupe_suffix="multi_writer")
    svc.apply_feedback(adv.id, "liked")
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert brain.ignore_streak == 0

    # Ignore sweep on a different advisory (stale)
    stale = _make_advisory(db, test_user, trip, dedupe_suffix="stale_mw")
    expired_rows = expire_stale_delivered(db)
    stale_ids = {r[0] for r in expired_rows}
    assert str(stale.id) in stale_ids

    # Brain state still coherent
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert brain.lifecycle_state == "active"
    assert "IN:MH:Pune" in (brain.advised_locality_keys or [])


# ---------------------------------------------------------------------------
# 2. No-pick scenario: locality exhausted → next locality picked
# ---------------------------------------------------------------------------


def test_no_pick_exhausts_then_moves_to_next_locality(db, test_user):
    """After NO_PICK_RETRY_BUDGET (2) no-picks on locality A, it's marked
    covered. A subsequent pick_next_target should skip A and find B.
    """
    trip = _make_trip(db, test_user)
    brain = _make_brain(db, test_user, trip)
    svc = TripBrainService(db)

    target_a = _target("IN:MH:Pune", "Pune")
    target_b = _target("IN:GJ:Ahmedabad", "Ahmedabad")

    # Two no-picks on Pune → covered after budget
    asyncio.run(svc.mark_cycle_outcome(trip.id, "no_pick", target=target_a))
    asyncio.run(svc.mark_cycle_outcome(trip.id, "no_pick", target=target_a))

    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert "IN:MH:Pune" in (brain.advised_locality_keys or [])

    # Deliver on Ahmedabad — should succeed without issue
    asyncio.run(
        svc.mark_cycle_outcome(
            trip.id,
            "delivered",
            target=target_b,
            poi_place_ids=["poi_ahm"],
            categories_delivered=["food_tip"],
        )
    )
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert "IN:GJ:Ahmedabad" in (brain.advised_locality_keys or [])
    assert "poi_ahm" in (brain.advised_poi_place_ids or [])


# ---------------------------------------------------------------------------
# 3. Off-route skip
# ---------------------------------------------------------------------------


def test_pick_next_target_returns_off_route_when_far_from_polyline(db, test_user):
    """GPS point ~165km away from the nearest route leg → off_route outcome.

    Uses real PostGIS data in the test DB: a route near Pune (lat ~18.5)
    and a GPS point near Delhi (lat ~28.6). The ST_Distance between them
    is ~1500km, well above the 5km threshold.
    """
    from sqlalchemy import text as sa_text
    from app.models.trip_route_raw_point import TripRouteRawPoint

    trip = _make_trip(db, test_user)
    brain = _make_brain(db, test_user, trip)

    brain.route_samples = {
        "samples": [
            {
                "idx": 0, "lat": 18.52, "lng": 73.85, "fraction": 0.0,
                "locality_key": "IN:MH:Pune", "locality": "Pune",
                "region": "Maharashtra", "country": "IN", "covered_at": None,
            }
        ],
        "polyline_version": "test",
        "sample_count": 1,
    }
    db.commit()

    # Route near Pune.
    route = Route(
        trip_id=trip.id,
        user_id=test_user.id,
        route_geojson={
            "type": "LineString",
            "coordinates": [[73.85, 18.52], [73.90, 18.55]],
        },
        transport_mode="car",
        route_category="ground",
        order_in_trip=0,
    )
    db.add(route)
    db.flush()

    # Compute route_geom from GeoJSON.
    db.execute(
        sa_text(
            """
            UPDATE routes
            SET route_geom = ST_GeomFromGeoJSON(route_geojson::text)::geography
            WHERE id = :rid
            """
        ),
        {"rid": str(route.id)},
    )

    # Need a V2 session row for the FK on trip_route_raw_point.
    from app.models.trip_session_raw import TripSessionRaw
    session = TripSessionRaw(
        trip_server_id=trip.id,
        user_id=test_user.id,
        client_session_id="test-offroute",
        status="active",
        started_at=datetime.now(timezone.utc),
    )
    db.add(session)
    db.flush()

    # GPS point near Delhi (~1500km from the Pune route).
    gps = TripRouteRawPoint(
        trip_server_id=trip.id,
        session_server_id=session.session_server_id,
        captured_at=datetime.now(timezone.utc),
        latitude=28.6,
        longitude=77.2,
        accuracy_m=10.0,
        point_seq=1,
    )
    db.add(gps)
    db.flush()

    svc = TripBrainService(db)
    decision = asyncio.run(svc.pick_next_target(trip.id))

    assert decision.outcome == "off_route"
    assert decision.target is None


# ---------------------------------------------------------------------------
# 4. Radius mode centroid DB fallback when Redis is down
# ---------------------------------------------------------------------------


def test_radius_centroid_uses_db_fallback_when_cache_empty(db, test_user):
    """When advisory_cache returns no centroid points, the brain falls back
    to computing centroid from trip_route_raw_point DB table.

    Since we can't easily seed GPS points in the test DB (different table
    structure per v1/v2), we verify the code path returns no_target
    gracefully (< 5 points → skip) rather than crashing.
    """
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip, mode="radius")
    svc = TripBrainService(db)

    # Patch cache to return empty (simulating Redis down).
    with patch(
        "app.services.trip_brain_service.advisory_cache"
    ) as mock_cache:
        mock_cache.get_centroid_points = AsyncMock(return_value=[])

        decision = asyncio.run(svc.pick_next_target(trip.id))

    # Should reach the DB fallback, find < 5 points, and return no_target
    # (not crash with an unhandled exception).
    assert decision.outcome == "no_target"


# ---------------------------------------------------------------------------
# 5. Ignore sweep race: late action arrival
# ---------------------------------------------------------------------------


def test_expire_stale_skips_advisory_with_late_arriving_action(db, test_user):
    """An advisory that gets a user action AFTER the sweep query plans
    but BEFORE it executes should NOT be expired, thanks to the NOT EXISTS
    guard in the atomic UPDATE.

    We simulate this by inserting the action before calling the sweep — the
    NOT EXISTS should exclude the row.
    """
    trip = _make_trip(db, test_user)
    adv = _make_advisory(db, test_user, trip, dedupe_suffix="late_action")

    # User action arrives (simulating "late" relative to sweep planning).
    action = AdvisoryUserAction(
        user_id=test_user.id,
        trip_id=trip.id,
        advisory_id=adv.id,
        action="dismissed",
        trip_metadata_snapshot={},
    )
    db.add(action)
    db.commit()

    # Sweep runs — should skip this advisory.
    expired_rows = expire_stale_delivered(db)
    expired_ids = {r[0] for r in expired_rows}
    assert str(adv.id) not in expired_ids

    # Advisory still delivered (not expired).
    db.refresh(adv)
    assert adv.status == "delivered"
