import asyncio
from datetime import datetime, timedelta, timezone
from uuid import uuid4

from app.models.trip import Trip
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.trip_brain_service import TargetDecision
from app.workers.advisory_cycle_worker import (
    claim_due_trips,
    flush_pending_reseeds,
    process_trip,
)


def _create_trip_and_brain(db, user):
    trip = Trip(user_id=user.id, title="Advisory Cycle Test Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    brain = TripAdvisoryState(
        trip_id=trip.id,
        user_id=user.id,
        lifecycle_state="active",
        mode="route",
        cadence_seconds=3600,
        next_eligible_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db.add(brain)
    db.commit()
    return trip, brain


def test_claim_due_trips_applies_processing_lease(db, test_user):
    trip, _ = _create_trip_and_brain(db, test_user)

    claimed = claim_due_trips(db, batch_size=50, lease_seconds=120)
    assert str(trip.id) in claimed

    # Re-claim in the same tick should not return the same trip.
    claimed_again = claim_due_trips(db, batch_size=50, lease_seconds=120)
    assert str(trip.id) not in claimed_again


def test_process_trip_marks_no_target_outcome(db, test_user, monkeypatch):
    trip, _ = _create_trip_and_brain(db, test_user)

    async def fake_pick_next_target(self, _trip_id):
        return TargetDecision(outcome="no_target", target=None)

    captured = {}

    async def fake_mark_cycle_outcome(self, trip_id, outcome, **_kwargs):
        captured["trip_id"] = str(trip_id)
        captured["outcome"] = outcome

    monkeypatch.setattr(
        "app.services.trip_brain_service.TripBrainService.pick_next_target",
        fake_pick_next_target,
    )
    monkeypatch.setattr(
        "app.services.trip_brain_service.TripBrainService.mark_cycle_outcome",
        fake_mark_cycle_outcome,
    )

    asyncio.run(process_trip(db, str(trip.id)))

    assert captured["trip_id"] == str(trip.id)
    assert captured["outcome"] == "no_target"


def test_flush_pending_reseeds_invokes_reseed(db, test_user, monkeypatch):
    trip, brain = _create_trip_and_brain(db, test_user)
    brain.pending_reseed_reasons = ["route_changed", "metadata_changed"]
    brain.last_seed_at = datetime.now(timezone.utc) - timedelta(minutes=10)
    db.commit()

    calls = []

    async def fake_reseed(self, trip_id, reasons):
        calls.append((str(trip_id), tuple(reasons)))
        return None

    monkeypatch.setattr(
        "app.services.trip_brain_service.TripBrainService.reseed",
        fake_reseed,
    )

    flushed = asyncio.run(flush_pending_reseeds(db, limit=25))

    assert flushed == 1
    assert calls
    assert calls[0][0] == str(trip.id)
    assert "route_changed" in calls[0][1]
