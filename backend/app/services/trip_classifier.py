"""
Trip classifier — deterministic rule table that maps trip shape + duration
onto an advisory cadence.

Pure functions. No DB or network access. Brain calls classify() at seed
time (and again on reseed when route/metadata change), stores the result on
trip_advisory_state.trip_class and .cadence_seconds.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from typing import Iterable, Optional

from app.config import settings


# Cadence for each class, in seconds. Keep this table in sync with the plan
# (cosmic-knitting-rabbit.md §Trip Classification Rule Table).
CADENCE_BY_CLASS = {
    "long_road": 3600,          # 1h
    "short_road": 1800,         # 30m
    "multi_day_leisure": 7200,  # 2h
    "day_trip": 2700,           # 45m
    "intra_city": 5400,         # 90m
    "unclassified": 3600,       # fallback
}

VALID_CLASSES = frozenset(CADENCE_BY_CLASS.keys())


@dataclass
class TripShape:
    """Lightweight input to classify() — computed by the brain seed step.

    Using a dataclass instead of passing raw SQLAlchemy rows keeps the
    classifier testable without DB fixtures.
    """
    has_route: bool
    total_distance_km: float
    trip_duration_days: float


def _duration_days(start: Optional[date], end: Optional[date]) -> float:
    if not start or not end:
        return 0.0
    delta = (end - start).days
    # Same-day trips are 1 day, not 0.
    return float(max(1, delta + 1))


def shape_from_trip(
    trip_start_date: Optional[date],
    trip_end_date: Optional[date],
    routes: Iterable[dict],
) -> TripShape:
    """Derive TripShape from a trip's dates and its ordered leg summaries.

    `routes` is an iterable of dicts with key 'distance_km' (float | None).
    """
    total_km = 0.0
    any_route = False
    for r in routes:
        d = r.get("distance_km") if isinstance(r, dict) else getattr(r, "distance_km", None)
        if d is None:
            continue
        try:
            total_km += float(d)
            any_route = True
        except (TypeError, ValueError):
            continue

    return TripShape(
        has_route=any_route and total_km > 0,
        total_distance_km=total_km,
        trip_duration_days=_duration_days(trip_start_date, trip_end_date),
    )


def classify(shape: TripShape) -> str:
    """Return a trip_class string per the rule table in the plan.

    Rules (first match wins):
      - intra_city:        no route OR distance < INTRA_CITY threshold
      - long_road:         route && distance > LONG_ROAD threshold
      - multi_day_leisure: duration > 3d && distance <= 300km
      - day_trip:          duration <= 1d && distance <= 150km
      - short_road:        route && 50 < distance <= 300
      - unclassified:      fallback
    """
    intra = settings.ADVISORY_INTRA_CITY_DISTANCE_THRESHOLD_KM  # 50
    long_road = settings.ADVISORY_LONG_ROAD_DISTANCE_THRESHOLD_KM  # 300

    if not shape.has_route or shape.total_distance_km < intra:
        return "intra_city"

    if shape.total_distance_km > long_road:
        return "long_road"

    if shape.trip_duration_days > 3 and shape.total_distance_km <= 300:
        return "multi_day_leisure"

    if shape.trip_duration_days <= 1 and shape.total_distance_km <= 150:
        return "day_trip"

    if intra < shape.total_distance_km <= long_road:
        return "short_road"

    return "unclassified"


def cadence_for(trip_class: str) -> int:
    """Return cadence in seconds for a trip_class; falls back to unclassified."""
    return CADENCE_BY_CLASS.get(trip_class, CADENCE_BY_CLASS["unclassified"])


def mode_for(trip_class: str) -> str:
    """Return advisory mode ('route' or 'radius') for a classified trip."""
    return "radius" if trip_class == "intra_city" else "route"
