"""
Base search provider abstraction.

All search providers (local DB, Foursquare, Mapbox, etc.) must inherit
from BaseSearchProvider and implement the search() method.

This enables:
- Consistent interface across all sources
- Easy addition of new providers
- Clean SearchService orchestration
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Any


class BaseSearchProvider(ABC):
    """
    Abstract base class for all search providers.

    All providers must implement search() method that returns results
    in the unified schema format.

    Unified Result Schema:
        {
            "id": str | None,              # "local:uuid" or "foursquare:fsq_id"
            "name": str,                   # Place name
            "lat": float,                  # Latitude
            "lng": float,                  # Longitude
            "address": str | None,         # Full address (if available)
            "source": str,                 # "local" | "foursquare" | "mapbox"
            "distance_m": float,           # Distance from search center (meters)
            "rating": float | None,        # 0-10 scale (if available)
            "popularity": int | None,      # Save count (local) or rating (external)
            "has_user_content": bool       # True if source="local"
        }
    """

    @abstractmethod
    async def search(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Search for places near coordinates.

        Args:
            query: Normalized search text (cleaned by SearchService)
            lat: Normalized latitude
            lng: Normalized longitude
            radius_km: Normalized radius in kilometers
            limit: Maximum number of results to return

        Returns:
            List of results in unified schema format.
            Empty list if no results or error.
            Never raises exceptions (graceful degradation).

        Implementation Requirements:
            - Map provider results to unified schema
            - Handle errors gracefully (log and return empty list)
            - Respect limit parameter
            - Calculate distance_m if not provided by source
            - Set has_user_content appropriately
        """
        pass
