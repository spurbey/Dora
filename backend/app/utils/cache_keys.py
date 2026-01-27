"""
Generate deterministic cache keys for search results.
"""

import hashlib
import json
from typing import Optional


def make_search_key(
    query: str,
    lat: float,
    lng: float,
    radius_km: float,
    filters: Optional[dict] = None
) -> str:
    """
    Generate deterministic cache key.

    Args:
        query: Normalized query string.
        lat: Normalized latitude.
        lng: Normalized longitude.
        radius_km: Normalized radius in kilometers.
        filters: Optional filter dictionary.

    Returns:
        Deterministic cache key string.
    """

    payload = {
        "q": query,
        "lat": lat,
        "lng": lng,
        "r": radius_km,
        "f": filters or {}
    }

    # Stable JSON
    raw = json.dumps(payload, sort_keys=True)

    # Short hash for uniqueness
    digest = hashlib.sha256(raw.encode()).hexdigest()[:10]

    # Human readable + hash
    return f"search:{query}:{lat}:{lng}:{radius_km}:{digest}"
