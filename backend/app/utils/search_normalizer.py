"""
Search input normalization for consistent cache keys and queries.
"""

import re
from typing import Tuple
from decimal import Decimal, ROUND_HALF_UP


_WHITESPACE_RE = re.compile(r"\s+")
# Allow unicode letters (café), numbers, space, -, '
_ALLOWED_CHARS_RE = re.compile(r"[^\w\s\-\']+", re.UNICODE)


def normalize_query(query: str) -> str:
    """
    Normalize search query.

    Args:
        query: Raw search query string.

    Returns:
        Normalized query string.
    """

    if not query:
        return ""

    # Lowercase
    q = query.lower()

    # Remove unwanted characters (but keep unicode)
    q = _ALLOWED_CHARS_RE.sub("", q)

    # Normalize whitespace
    q = _WHITESPACE_RE.sub(" ", q)

    # Trim
    return q.strip()


def normalize_coords(lat: float, lng: float) -> Tuple[float, float]:
    """
    Normalize coordinates with ROUND_HALF_UP.

    Args:
        lat: Latitude value.
        lng: Longitude value.

    Returns:
        Tuple of (normalized_lat, normalized_lng).
    """

    try:
        lat_f = float(lat)
        lng_f = float(lng)
    except (TypeError, ValueError):
        raise ValueError("Invalid coordinates")

    # Clamp
    lat_f = max(min(lat_f, 90.0), -90.0)
    lng_f = max(min(lng_f, 180.0), -180.0)

    # Decimal rounding (avoid banker's rounding)
    lat_d = Decimal(str(lat_f)).quantize(
        Decimal("0.0001"),
        rounding=ROUND_HALF_UP
    )

    lng_d = Decimal(str(lng_f)).quantize(
        Decimal("0.0001"),
        rounding=ROUND_HALF_UP
    )

    return float(lat_d), float(lng_d)


def normalize_radius(radius_km: float, max_radius: float = 50.0) -> float:
    """
    Normalize radius.

    Args:
        radius_km: Requested radius in kilometers.
        max_radius: Maximum allowed radius in kilometers.

    Returns:
        Normalized radius in kilometers.
    """

    try:
        r = float(radius_km)
    except (TypeError, ValueError):
        return 5.0

    # Default if negative/zero
    if r <= 0:
        return 5.0

    # Clamp
    r = min(r, max_radius)

    # Round to 1 decimal
    return round(r, 1)
