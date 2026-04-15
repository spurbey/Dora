"""Tests for route_sampler — polyline concat + sampling + GPS projection."""

import math

from app.services.route_sampler import (
    Sample,
    concatenate_legs,
    polyline_signature,
    project_gps_to_fraction,
    sample_polyline,
)


def _line(coords):
    return {"type": "LineString", "coordinates": coords}


# ---------------------------------------------------------------------------
# concatenate_legs
# ---------------------------------------------------------------------------


def test_concatenate_single_leg():
    combined = concatenate_legs([_line([[0, 0], [1, 1], [2, 2]])])
    assert combined == [(0, 0), (1, 1), (2, 2)]


def test_concatenate_drops_duplicate_boundary_point():
    combined = concatenate_legs(
        [
            _line([[0, 0], [1, 1]]),
            _line([[1, 1], [2, 2]]),  # dup at boundary
        ]
    )
    assert combined == [(0, 0), (1, 1), (2, 2)]


def test_concatenate_handles_feature_wrapper():
    feat = {"type": "Feature", "geometry": _line([[5, 5], [6, 6]])}
    assert concatenate_legs([feat]) == [(5, 5), (6, 6)]


def test_concatenate_skips_malformed():
    combined = concatenate_legs([{"type": "Point", "coordinates": [0, 0]}, _line([[1, 1], [2, 2]])])
    assert combined == [(1, 1), (2, 2)]


# ---------------------------------------------------------------------------
# sample_polyline
# ---------------------------------------------------------------------------


def test_sample_returns_empty_for_degenerate_input():
    assert sample_polyline([], count=22) == []
    assert sample_polyline([(0, 0)], count=22) == []
    assert sample_polyline([(0, 0), (0, 0)], count=22) == []  # all coincident
    assert sample_polyline([(0, 0), (1, 1)], count=0) == []


def test_sample_endpoint_alignment():
    coords = [(0.0, 0.0), (1.0, 0.0), (2.0, 0.0)]
    samples = sample_polyline(coords, count=3)
    assert len(samples) == 3
    # First sample pins to start, last pins to end.
    assert samples[0].fraction == 0.0
    assert samples[-1].fraction == 1.0
    assert math.isclose(samples[0].lat, 0.0, abs_tol=1e-6)
    assert math.isclose(samples[0].lng, 0.0, abs_tol=1e-6)
    # Last sample should be very close to the final coord.
    assert math.isclose(samples[-1].lat, 0.0, abs_tol=1e-3)
    assert math.isclose(samples[-1].lng, 2.0, abs_tol=1e-3)


def test_sample_count_22():
    # Simple 100km-equivalent polyline along equator.
    coords = [(float(i) * 0.01, 0.0) for i in range(11)]
    samples = sample_polyline(coords, count=22)
    assert len(samples) == 22
    # Fractions must be monotonically increasing.
    fractions = [s.fraction for s in samples]
    assert fractions == sorted(fractions)
    assert fractions[0] == 0.0
    assert math.isclose(fractions[-1], 1.0, abs_tol=1e-6)


def test_sample_single_returns_origin():
    samples = sample_polyline([(0, 0), (1, 1)], count=1)
    assert samples == [Sample(idx=0, fraction=0.0, lat=0.0, lng=0.0)]


# ---------------------------------------------------------------------------
# polyline_signature
# ---------------------------------------------------------------------------


def test_signature_stable_for_same_input():
    coords = [(0.0, 0.0), (1.0, 1.0), (2.0, 2.0)]
    assert polyline_signature(coords) == polyline_signature(coords)


def test_signature_changes_with_coords():
    a = polyline_signature([(0.0, 0.0), (1.0, 1.0)])
    b = polyline_signature([(0.0, 0.0), (1.0, 1.0001)])
    assert a != b


# ---------------------------------------------------------------------------
# project_gps_to_fraction
# ---------------------------------------------------------------------------


def test_project_gps_on_line():
    coords = [(0.0, 0.0), (1.0, 0.0), (2.0, 0.0)]
    # GPS at the midpoint should project to fraction ≈ 0.5
    frac = project_gps_to_fraction(coords, gps_lat=0.0, gps_lng=1.0)
    assert frac is not None
    assert math.isclose(frac, 0.5, abs_tol=1e-3)


def test_project_gps_past_end_clamps():
    coords = [(0.0, 0.0), (1.0, 0.0)]
    frac = project_gps_to_fraction(coords, gps_lat=0.0, gps_lng=5.0)
    assert frac is not None
    assert math.isclose(frac, 1.0, abs_tol=1e-6)


def test_project_returns_none_for_bad_polyline():
    assert project_gps_to_fraction([], 0.0, 0.0) is None
    assert project_gps_to_fraction([(0, 0)], 0.0, 0.0) is None
    assert project_gps_to_fraction([(0, 0), (0, 0)], 0.0, 0.0) is None
