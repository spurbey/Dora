"""
Route sampler — produce N equal-distance samples along a trip's polyline.

A "trip polyline" is the ordered concatenation of all legs (each leg is a
separate Route row with its own route_geojson). This service:

  1. concatenates legs in order_in_trip order,
  2. computes cumulative arc distance (great-circle) along the combined path,
  3. emits N samples at equal-distance fractions in [0, 1],
  4. returns sha256(concatenated coords) as polyline_signature for change
     detection.

We interpolate in pure Python rather than per-sample PostGIS round-trips —
the 22-point fanout is cheap in-process and keeps the sampler callable from
non-DB contexts (e.g. unit tests).
"""

from __future__ import annotations

import hashlib
import json
import math
from dataclasses import dataclass
from typing import Iterable, Optional


@dataclass
class Sample:
    idx: int
    fraction: float   # 0..1 along polyline
    lat: float
    lng: float


# ---------------------------------------------------------------------------
# GeoJSON parsing
# ---------------------------------------------------------------------------

def _coords_from_linestring(geojson: dict) -> list[tuple[float, float]]:
    """Extract [(lng, lat), ...] from a GeoJSON LineString (or feature wrapping one).

    Returns empty list if shape isn't a LineString or is malformed.
    """
    if not isinstance(geojson, dict):
        return []

    # Accept either {type:"LineString", coordinates:[...]} or a Feature wrapping it.
    geom = geojson
    if geojson.get("type") == "Feature":
        geom = geojson.get("geometry") or {}
    if geom.get("type") != "LineString":
        return []

    raw = geom.get("coordinates") or []
    out: list[tuple[float, float]] = []
    for pt in raw:
        if isinstance(pt, (list, tuple)) and len(pt) >= 2:
            try:
                out.append((float(pt[0]), float(pt[1])))
            except (TypeError, ValueError):
                continue
    return out


# ---------------------------------------------------------------------------
# Great-circle distance / interpolation
# ---------------------------------------------------------------------------

_EARTH_RADIUS_M = 6_371_000.0


def _haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    p1 = math.radians(lat1)
    p2 = math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    c = 2 * math.asin(math.sqrt(a))
    return _EARTH_RADIUS_M * c


def _interp_along_segment(
    lat1: float, lng1: float, lat2: float, lng2: float, t: float
) -> tuple[float, float]:
    """Linear interpolation in lat/lng. Accurate enough for per-km scale
    sampling used by the advisory pipeline; avoids full spherical slerp."""
    return (lat1 + (lat2 - lat1) * t, lng1 + (lng2 - lng1) * t)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def concatenate_legs(legs: Iterable[dict]) -> list[tuple[float, float]]:
    """Concatenate per-leg GeoJSON LineStrings into a single polyline.

    Input: iterable of leg geojson dicts ORDERED by order_in_trip (caller
    responsibility). Duplicate adjacent points at leg boundaries are dropped.
    """
    combined: list[tuple[float, float]] = []
    for leg in legs:
        coords = _coords_from_linestring(leg)
        if not coords:
            continue
        if combined and combined[-1] == coords[0]:
            combined.extend(coords[1:])
        else:
            combined.extend(coords)
    return combined


def polyline_signature(coords: list[tuple[float, float]]) -> str:
    """sha256 of the coordinate list — stable across orderings of same shape.

    Used by the brain to detect "route changed" without comparing full geojson.
    """
    canon = json.dumps(
        [(round(lng, 6), round(lat, 6)) for lng, lat in coords], separators=(",", ":")
    )
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()


def sample_polyline(
    coords: list[tuple[float, float]],
    count: int = 22,
) -> list[Sample]:
    """Emit `count` samples at equal-distance fractions along `coords`.

    `coords` is [(lng, lat), ...]. Returns Sample(idx, fraction, lat, lng).
    Edge cases:
      - 0 or 1 coord → returns empty
      - count <= 0 → returns empty
      - count == 1 → single sample at fraction=0
    """
    if count <= 0 or len(coords) < 2:
        return []

    # Per-segment arc lengths.
    seg_lens: list[float] = []
    for i in range(len(coords) - 1):
        lng1, lat1 = coords[i]
        lng2, lat2 = coords[i + 1]
        seg_lens.append(_haversine_m(lat1, lng1, lat2, lng2))
    total_len = sum(seg_lens)
    if total_len <= 0:
        # All points coincident — degenerate.
        return []

    samples: list[Sample] = []
    if count == 1:
        lng, lat = coords[0]
        samples.append(Sample(idx=0, fraction=0.0, lat=lat, lng=lng))
        return samples

    for i in range(count):
        fraction = i / (count - 1)
        target = fraction * total_len
        # Walk segments until cumulative length covers target.
        acc = 0.0
        seg_idx = 0
        while seg_idx < len(seg_lens) and acc + seg_lens[seg_idx] < target:
            acc += seg_lens[seg_idx]
            seg_idx += 1
        if seg_idx >= len(seg_lens):
            # Past the end (floating point slack) — pin to last point.
            lng, lat = coords[-1]
            samples.append(Sample(idx=i, fraction=fraction, lat=lat, lng=lng))
            continue
        remaining = target - acc
        seg_len = seg_lens[seg_idx] or 1.0
        t = remaining / seg_len
        lng1, lat1 = coords[seg_idx]
        lng2, lat2 = coords[seg_idx + 1]
        lat_s, lng_s = _interp_along_segment(lat1, lng1, lat2, lng2, t)
        samples.append(Sample(idx=i, fraction=fraction, lat=lat_s, lng=lng_s))

    return samples


def project_gps_to_fraction(
    coords: list[tuple[float, float]], gps_lat: float, gps_lng: float
) -> Optional[float]:
    """Return the 0..1 fraction on the polyline closest to the GPS point.

    Uses O(n) scan + great-circle distance. Returns None for a malformed
    polyline or a GPS point with no valid projection.
    """
    if len(coords) < 2:
        return None

    total_len = 0.0
    seg_lens: list[float] = []
    for i in range(len(coords) - 1):
        lng1, lat1 = coords[i]
        lng2, lat2 = coords[i + 1]
        seg_lens.append(_haversine_m(lat1, lng1, lat2, lng2))
        total_len += seg_lens[-1]
    if total_len <= 0:
        return None

    best_dist = float("inf")
    best_cum = 0.0
    cum = 0.0

    for i in range(len(coords) - 1):
        lng1, lat1 = coords[i]
        lng2, lat2 = coords[i + 1]
        seg_len = seg_lens[i]
        if seg_len <= 0:
            continue
        # Closest-point-to-segment, linearized in lat/lng for cheap math.
        dx = lng2 - lng1
        dy = lat2 - lat1
        if dx == 0 and dy == 0:
            t = 0.0
        else:
            t = ((gps_lng - lng1) * dx + (gps_lat - lat1) * dy) / (dx * dx + dy * dy)
            t = max(0.0, min(1.0, t))
        px = lng1 + dx * t
        py = lat1 + dy * t
        d = _haversine_m(gps_lat, gps_lng, py, px)
        if d < best_dist:
            best_dist = d
            best_cum = cum + seg_len * t
        cum += seg_len

    return best_cum / total_len if total_len > 0 else None
