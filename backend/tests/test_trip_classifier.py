"""Tests for trip_classifier — pure rule-table classification."""

from datetime import date

from app.services.trip_classifier import (
    CADENCE_BY_CLASS,
    TripShape,
    cadence_for,
    classify,
    mode_for,
    shape_from_trip,
)


def _shape(has_route: bool, distance_km: float, duration_days: float) -> TripShape:
    return TripShape(
        has_route=has_route,
        total_distance_km=distance_km,
        trip_duration_days=duration_days,
    )


# ---------------------------------------------------------------------------
# classify() rule-table branches
# ---------------------------------------------------------------------------


def test_classify_no_route_is_intra_city():
    assert classify(_shape(has_route=False, distance_km=0.0, duration_days=1)) == "intra_city"


def test_classify_tiny_route_is_intra_city():
    # distance < 50km threshold
    assert classify(_shape(has_route=True, distance_km=20.0, duration_days=1)) == "intra_city"


def test_classify_long_road_over_300km():
    assert classify(_shape(has_route=True, distance_km=500.0, duration_days=2)) == "long_road"


def test_classify_multi_day_leisure():
    # duration >3d and distance <=300
    assert (
        classify(_shape(has_route=True, distance_km=200.0, duration_days=5))
        == "multi_day_leisure"
    )


def test_classify_day_trip():
    # duration <=1d, distance <=150km
    assert classify(_shape(has_route=True, distance_km=120.0, duration_days=1)) == "day_trip"


def test_classify_short_road():
    # 50 < distance <=300, duration outside day_trip/multi_day_leisure bands
    assert classify(_shape(has_route=True, distance_km=200.0, duration_days=2)) == "short_road"


# ---------------------------------------------------------------------------
# cadence_for / mode_for / shape_from_trip
# ---------------------------------------------------------------------------


def test_cadence_for_known_and_unknown():
    assert cadence_for("long_road") == CADENCE_BY_CLASS["long_road"]
    # Unknown falls back to unclassified value.
    assert cadence_for("made_up_class") == CADENCE_BY_CLASS["unclassified"]


def test_mode_for_radius_only_for_intra_city():
    assert mode_for("intra_city") == "radius"
    for cls in ("long_road", "short_road", "day_trip", "multi_day_leisure", "unclassified"):
        assert mode_for(cls) == "route"


def test_shape_from_trip_sums_distances_and_counts_days():
    shape = shape_from_trip(
        trip_start_date=date(2026, 4, 15),
        trip_end_date=date(2026, 4, 17),
        routes=[{"distance_km": 120.5}, {"distance_km": 60.0}, {"distance_km": None}],
    )
    assert shape.has_route is True
    assert shape.total_distance_km == 180.5
    # 3-day trip (15, 16, 17).
    assert shape.trip_duration_days == 3.0


def test_shape_from_trip_without_dates():
    shape = shape_from_trip(None, None, routes=[])
    assert shape.has_route is False
    assert shape.total_distance_km == 0.0
    assert shape.trip_duration_days == 0.0


def test_shape_from_trip_tolerates_bad_distance():
    shape = shape_from_trip(
        trip_start_date=date(2026, 4, 15),
        trip_end_date=date(2026, 4, 15),
        routes=[{"distance_km": "nope"}, {"distance_km": 10.0}],
    )
    assert shape.total_distance_km == 10.0
    assert shape.has_route is True
    assert shape.trip_duration_days == 1.0
