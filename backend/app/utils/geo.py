"""
Geospatial utility functions.

Functions for calculating distances and geographic operations
when database PostGIS functions aren't available (e.g., external API results).
"""

import math
from typing import Tuple


# Earth's radius in meters (mean radius)
EARTH_RADIUS_METERS = 6371000


def haversine_distance(
    lat1: float,
    lng1: float,
    lat2: float,
    lng2: float
) -> float:
    """
    Calculate great-circle distance between two points on Earth.

    Uses the Haversine formula for accurate distance calculation
    on a sphere. Good for distances up to ~10,000 km.

    Args:
        lat1: Starting point latitude (decimal degrees)
        lng1: Starting point longitude (decimal degrees)
        lat2: Ending point latitude (decimal degrees)
        lng2: Ending point longitude (decimal degrees)

    Returns:
        Distance in meters (float)

    Example:
        >>> # Paris to Eiffel Tower (~2km)
        >>> haversine_distance(48.8566, 2.3522, 48.8584, 2.2945)
        4237.0  # meters

        >>> # Same point
        >>> haversine_distance(48.8584, 2.2945, 48.8584, 2.2945)
        0.0
    """
    # Convert degrees to radians
    lat1_rad = math.radians(lat1)
    lng1_rad = math.radians(lng1)
    lat2_rad = math.radians(lat2)
    lng2_rad = math.radians(lng2)

    # Differences
    dlat = lat2_rad - lat1_rad
    dlng = lng2_rad - lng1_rad

    # Haversine formula
    a = (
        math.sin(dlat / 2) ** 2 +
        math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlng / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Distance in meters
    distance = EARTH_RADIUS_METERS * c

    return distance


def normalize_name_for_matching(name: str) -> str:
    """
    Normalize place name for deduplication matching.

    Removes accents, converts to lowercase, strips whitespace.
    Used for fuzzy matching to detect duplicate places from different sources.

    Args:
        name: Place name to normalize

    Returns:
        Normalized name string

    Example:
        >>> normalize_name_for_matching("Café de Flore")
        "cafe de flore"

        >>> normalize_name_for_matching("  O'Brien's PUB  ")
        "o'brien's pub"
    """
    import unicodedata

    # Normalize unicode (NFKD = compatibility decomposition)
    normalized = unicodedata.normalize('NFKD', name)

    # Remove combining characters (accents)
    without_accents = ''.join(
        char for char in normalized
        if not unicodedata.combining(char)
    )

    # Lowercase and strip whitespace
    result = without_accents.lower().strip()

    # Collapse multiple spaces to single space
    result = ' '.join(result.split())

    return result
