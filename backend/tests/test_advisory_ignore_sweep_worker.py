from datetime import datetime, timedelta, timezone

from app.models.advisory_user_action import AdvisoryUserAction
from app.models.trip import Trip
from app.models.trip_advisory import TripAdvisory
from app.workers.advisory_ignore_sweep_worker import expire_stale_delivered


def test_expire_stale_delivered_skips_rows_with_user_action(db, test_user):
    trip = Trip(user_id=test_user.id, title="Ignore Sweep Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)

    old_ts = datetime.now(timezone.utc) - timedelta(hours=2)

    stale = TripAdvisory(
        trip_id=trip.id,
        user_id=test_user.id,
        category="general_tip",
        source="reddit",
        title="Stale",
        body="No action",
        confidence_score=0.6,
        dedupe_key=f"dedupe:{trip.id}:stale",
        status="delivered",
        delivered_at=old_ts,
    )
    acted = TripAdvisory(
        trip_id=trip.id,
        user_id=test_user.id,
        category="general_tip",
        source="reddit",
        title="Acted",
        body="Has action",
        confidence_score=0.8,
        dedupe_key=f"dedupe:{trip.id}:acted",
        status="delivered",
        delivered_at=old_ts,
    )
    db.add_all([stale, acted])
    db.commit()
    db.refresh(stale)
    db.refresh(acted)

    action = AdvisoryUserAction(
        user_id=test_user.id,
        trip_id=trip.id,
        advisory_id=acted.id,
        action="liked",
        trip_metadata_snapshot={},
    )
    db.add(action)
    db.commit()

    expired = expire_stale_delivered(db)
    expired_ids = {row[0] for row in expired}

    assert str(stale.id) in expired_ids
    assert str(acted.id) not in expired_ids
