"""Tests for the clarify_intent stage helpers.

Focus on the pure-state pieces: confidence read/update math and the
maybe_clarify decision tree under various flag/confidence combos.
The LLM call itself is mocked.
"""
from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from typing import Any
from unittest.mock import patch

import pytest
from sqlalchemy import text

from app.models.advisory_job import AdvisoryJob
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.advisory_clarify import (
    CONFIDENCE_HIGH,
    CONFIDENCE_LOW,
    lookup_confidence,
    maybe_clarify,
    update_confidence,
)


def _make_brain(db, user, trip, *, locality_confidence=None) -> TripAdvisoryState:
    db.execute(
        text(
            """
            INSERT INTO trip_advisory_state (
                trip_id, user_id, lifecycle_state, mode, trip_class,
                cadence_seconds, locality_confidence, phase
            )
            VALUES (
                :tid, :uid, 'active', 'route', 'short_road',
                1800, CAST(:lc AS jsonb), 'planning'
            )
            ON CONFLICT (trip_id) DO UPDATE
            SET locality_confidence = CAST(:lc AS jsonb)
            """
        ),
        {
            "tid": str(trip.id),
            "uid": str(user.id),
            "lc": (
                __import__("json").dumps(locality_confidence or {})
            ),
        },
    )
    db.commit()
    return (
        db.query(TripAdvisoryState)
        .filter(TripAdvisoryState.trip_id == trip.id)
        .one()
    )


def _make_trip(db, user):
    """Create a minimal trip row for the brain FK."""
    from app.models.trip import Trip
    trip = Trip(
        title="Clarify test trip",
        user_id=user.id,
        v2_backend_enabled=True,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _make_job(db, user, trip, *, query_text=None, scrape_plan=None) -> AdvisoryJob:
    import hashlib, uuid
    rh = hashlib.sha256(f"{trip.id}:{uuid.uuid4()}".encode()).hexdigest()
    job = AdvisoryJob(
        user_id=user.id,
        trip_id=trip.id,
        job_type="on_demand",
        status="queued",
        query_text=query_text,
        scrape_plan=scrape_plan or {},
        request_hash=rh,
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    return job


# ---------------------------------------------------------------------------
# lookup_confidence
# ---------------------------------------------------------------------------


def test_lookup_confidence_no_locality_returns_zero(db, test_user):
    trip = _make_trip(db, test_user)
    brain = _make_brain(db, test_user, trip, locality_confidence={})
    assert lookup_confidence(brain, None, ["food_tip"]) == 0.0
    assert lookup_confidence(brain, "", ["food_tip"]) == 0.0


def test_lookup_confidence_returns_max_across_intents(db, test_user):
    trip = _make_trip(db, test_user)
    brain = _make_brain(
        db, test_user, trip,
        locality_confidence={
            "in:MH:Pune": {
                "food_tip": 0.85,
                "must_do": 0.40,
                "_signals": {"delivered": 5},
            },
        },
    )
    # Picks the higher of the two intents
    assert lookup_confidence(brain, "in:MH:Pune", ["food_tip", "must_do"]) == 0.85
    assert lookup_confidence(brain, "in:MH:Pune", ["must_do"]) == 0.40
    # Unknown locality → 0
    assert lookup_confidence(brain, "in:KA:Bangalore", ["food_tip"]) == 0.0
    # Empty intents → max across non-_ keys
    assert lookup_confidence(brain, "in:MH:Pune", []) == 0.85


# ---------------------------------------------------------------------------
# update_confidence
# ---------------------------------------------------------------------------


def test_update_confidence_first_delivery_creates_entry(db, test_user):
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip, locality_confidence={})

    update_confidence(
        db,
        trip.id,
        "in:MH:Pune",
        delivered_categories=["food_tip"],
        insights_count_per_category={"food_tip": 1},
    )

    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    pune = brain.locality_confidence["in:MH:Pune"]
    assert pune["food_tip"] >= 0.10
    assert pune["food_tip"] <= 0.20
    assert pune["_signals"]["delivered"] == 1


def test_update_confidence_caps_at_one(db, test_user):
    trip = _make_trip(db, test_user)
    _make_brain(
        db, test_user, trip,
        locality_confidence={"in:MH:Pune": {"food_tip": 0.90}},
    )

    update_confidence(
        db,
        trip.id,
        "in:MH:Pune",
        delivered_categories=["food_tip"],
        insights_count_per_category={"food_tip": 5},
    )

    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert brain.locality_confidence["in:MH:Pune"]["food_tip"] <= 1.0


def test_update_confidence_no_op_on_empty_categories(db, test_user):
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip, locality_confidence={"x": {"y": 0.5}})

    update_confidence(db, trip.id, "in:MH:Pune", delivered_categories=[])

    db.expire_all()
    brain = db.query(TripAdvisoryState).filter_by(trip_id=trip.id).one()
    assert brain.locality_confidence == {"x": {"y": 0.5}}


# ---------------------------------------------------------------------------
# maybe_clarify decision tree
# ---------------------------------------------------------------------------


def test_maybe_clarify_disabled_passes_through(db, test_user, monkeypatch):
    """Feature flag off → always returns True without LLM call."""
    monkeypatch.setattr("app.config.settings.ADVISORY_CLARIFY_ENABLED", False)
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip, locality_confidence={})
    job = _make_job(db, test_user, trip, query_text="anything")

    with patch("app.services.advisory_clarify.chat_json") as mock_llm:
        result = asyncio.run(maybe_clarify(db, job))
    assert result is True
    mock_llm.assert_not_called()


def test_maybe_clarify_skips_non_on_demand(db, test_user, monkeypatch):
    monkeypatch.setattr("app.config.settings.ADVISORY_CLARIFY_ENABLED", True)
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip, locality_confidence={})
    job = _make_job(db, test_user, trip)
    job.job_type = "location_trigger"
    db.commit()

    with patch("app.services.advisory_clarify.chat_json") as mock_llm:
        result = asyncio.run(maybe_clarify(db, job))
    assert result is True
    mock_llm.assert_not_called()


def test_maybe_clarify_high_confidence_skips_ask(db, test_user, monkeypatch):
    monkeypatch.setattr("app.config.settings.ADVISORY_CLARIFY_ENABLED", True)
    trip = _make_trip(db, test_user)
    _make_brain(
        db, test_user, trip,
        locality_confidence={
            "in:MH:Pune": {"food_tip": CONFIDENCE_HIGH + 0.05},
        },
    )
    job = _make_job(
        db, test_user, trip,
        query_text="vegetarian food",
        scrape_plan={
            "target": {"locality_key": "in:MH:Pune"},
            "focus_categories": ["food_tip"],
        },
    )

    with patch("app.services.advisory_clarify.chat_json") as mock_llm:
        result = asyncio.run(maybe_clarify(db, job))
    assert result is True
    mock_llm.assert_not_called()


def test_maybe_clarify_already_clarified_passes_through(db, test_user, monkeypatch):
    """Once user has answered (scrape_plan.clarified=True), subsequent calls no-op."""
    monkeypatch.setattr("app.config.settings.ADVISORY_CLARIFY_ENABLED", True)
    trip = _make_trip(db, test_user)
    _make_brain(db, test_user, trip)
    job = _make_job(
        db, test_user, trip,
        query_text="food",
        scrape_plan={"clarified": True, "target": {"locality_key": "in:MH:Pune"}},
    )

    with patch("app.services.advisory_clarify.chat_json") as mock_llm:
        result = asyncio.run(maybe_clarify(db, job))
    assert result is True
    mock_llm.assert_not_called()
