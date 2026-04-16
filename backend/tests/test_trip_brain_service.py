import asyncio
from uuid import uuid4

from app.models.advisory_user_action import AdvisoryUserAction
from app.models.trip import Trip
from app.models.trip_advisory import TripAdvisory
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.trip_brain_service import TargetContext, TripBrainService


def test_ensure_brain_self_heals_missing_row(db, test_user):
    trip = Trip(user_id=test_user.id, title="Brain Self-Heal", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    svc = TripBrainService(db)
    brain = svc.ensure_brain(trip.id, test_user.id)

    assert brain.trip_id == trip.id
    assert brain.user_id == test_user.id


def test_mark_cycle_outcome_no_pick_uses_retry_budget(db, test_user):
    trip = Trip(user_id=test_user.id, title="No Pick Budget", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    svc = TripBrainService(db)
    svc.ensure_brain(trip.id, test_user.id)
    db.commit()

    target = TargetContext(
        locality_key="IN:Maharashtra:Pune",
        locality="Pune",
        region="Maharashtra",
        country="IN",
        center_lat=18.52,
        center_lng=73.85,
        mode="route",
        sample_idx=0,
    )

    asyncio.run(svc.mark_cycle_outcome(trip.id, "no_pick", target=target))
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter(TripAdvisoryState.trip_id == trip.id).one()
    assert target.locality_key not in (brain.advised_locality_keys or [])
    db.commit()

    asyncio.run(svc.mark_cycle_outcome(trip.id, "no_pick", target=target))
    db.expire_all()
    brain = db.query(TripAdvisoryState).filter(TripAdvisoryState.trip_id == trip.id).one()
    assert target.locality_key in (brain.advised_locality_keys or [])


def test_apply_feedback_implicit_ignore_skips_if_action_exists(db, test_user):
    trip = Trip(user_id=test_user.id, title="Ignore Guard", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    svc = TripBrainService(db)
    svc.ensure_brain(trip.id, test_user.id)

    advisory = TripAdvisory(
        trip_id=trip.id,
        user_id=test_user.id,
        category="general_tip",
        source="reddit",
        title="Tip",
        body="Body",
        confidence_score=0.5,
        dedupe_key=f"dedupe:{trip.id}:tip",
        status="delivered",
    )
    db.add(advisory)
    db.commit()
    db.refresh(advisory)

    action = AdvisoryUserAction(
        user_id=test_user.id,
        trip_id=trip.id,
        advisory_id=advisory.id,
        action="liked",
        trip_metadata_snapshot={},
    )
    db.add(action)
    db.commit()

    # Should not increment ignore streak because action exists.
    db.commit()
    svc.apply_feedback(advisory.id, "implicit_ignore")
    brain = db.query(TripAdvisoryState).filter(TripAdvisoryState.trip_id == trip.id).one()
    assert brain.ignore_streak == 0
