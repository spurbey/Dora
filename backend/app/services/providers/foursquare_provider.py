"""
Foursquare Places API search provider.

Queries Foursquare Places API with retry logic and error handling.
Falls back gracefully on failure (returns empty list).

API Docs: https://location.foursquare.com/developer/reference/places-search
"""

import httpx
from typing import List, Dict, Any
import asyncio

from app.services.providers.base import BaseSearchProvider
from app.config import settings
from app.utils.geo import haversine_distance


class FoursquareSearchProvider(BaseSearchProvider):
    """
    Search Foursquare Places API.

    Features:
    - Async HTTP with httpx
    - Timeout handling (2 seconds)
    - Retry logic for 5xx errors
    - Graceful error handling
    - Maps to unified schema

    API Limits (Free Tier):
    - 100,000 calls/month
    - ~3 calls/second
    """

    BASE_URL = "https://places-api.foursquare.com/places/search"
    API_VERSION = "2025-06-17"
    TIMEOUT = 2.0  # seconds
    MAX_RETRIES = 1  # Total 2 attempts (initial + 1 retry)

    def __init__(self):
        """Initialize Foursquare provider with API key from config."""
        self.api_key = settings.FOURSQUARE_API_KEY

    async def search(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Query Foursquare Places API.

        Args:
            query: Search text
            lat: Search center latitude
            lng: Search center longitude
            radius_km: Search radius in kilometers
            limit: Maximum results to return

        Returns:
            List of results in unified schema format.
            Empty list on error or no results.
        """
        try:
            # Convert radius to meters
            radius_meters = int(radius_km * 1000)

            # Build request parameters
            # Note: Do not include fields in the request; the Places API rejects
            # unsupported fields with 400 (e.g., fsq_id/geocodes).
            params = {
                "query": query,
                "ll": f"{lat},{lng}",
                "radius": radius_meters,
                "limit": limit
            }

            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Accept": "application/json",
                "X-Places-Api-Version": self.API_VERSION
            }

            # Make request with retry logic
            response_data = await self._make_request_with_retry(
                params, headers
            )

            if not response_data:
                return []

            # Parse response
            results = response_data.get("results", [])

            # Map to unified schema
            unified_results = []
            for result in results:
                mapped = self._map_to_unified_schema(result, lat, lng)
                if mapped:
                    unified_results.append(mapped)

            return unified_results

        except Exception as e:
            print(f"FoursquareSearchProvider error: {e}")
            return []

    async def _make_request_with_retry(
        self,
        params: Dict[str, Any],
        headers: Dict[str, str]
    ) -> Dict[str, Any] | None:
        """
        Make HTTP request with retry logic.

        Retries on:
        - 500, 502, 503 (server errors)
        - Timeout

        Does NOT retry on:
        - 400 (bad request)
        - 401 (invalid API key)
        - 429 (rate limit)

        Args:
            params: Query parameters
            headers: Request headers

        Returns:
            Response JSON dict or None on failure
        """
        async with httpx.AsyncClient(timeout=self.TIMEOUT) as client:
            for attempt in range(self.MAX_RETRIES + 1):
                try:
                    response = await client.get(
                        self.BASE_URL,
                        params=params,
                        headers=headers
                    )

                    # Success
                    if response.status_code == 200:
                        return response.json()

                    # Client errors - don't retry
                    if response.status_code in [400, 401, 429]:
                        print(f"Foursquare API error {response.status_code}: {response.text}")
                        return None

                    # Server errors - retry
                    if response.status_code in [500, 502, 503]:
                        if attempt < self.MAX_RETRIES:
                            print(f"Foursquare server error {response.status_code}, retrying...")
                            await asyncio.sleep(1)  # Wait before retry
                            continue
                        else:
                            print(f"Foursquare server error {response.status_code}, max retries exceeded")
                            return None

                    # Other errors - don't retry
                    print(f"Foursquare unexpected status {response.status_code}")
                    return None

                except httpx.TimeoutException:
                    if attempt < self.MAX_RETRIES:
                        print("Foursquare timeout, retrying...")
                        await asyncio.sleep(1)
                        continue
                    else:
                        print("Foursquare timeout, max retries exceeded")
                        return None

                except Exception as e:
                    print(f"Foursquare request error: {e}")
                    return None

        return None

    def _map_to_unified_schema(
        self,
        result: Dict[str, Any],
        search_lat: float,
        search_lng: float
    ) -> Dict[str, Any] | None:
        """
        Map Foursquare result to unified schema.

        Args:
            result: Foursquare result dict
            search_lat: Search center latitude (for distance calculation)
            search_lng: Search center longitude

        Returns:
            Unified result dict or None if invalid
        """
        try:
            # Extract required fields
            fsq_id = result.get("fsq_id") or result.get("fsq_place_id")
            name = result.get("name")
            geocodes = result.get("geocodes", {}).get("main", {})
            lat = (
                geocodes.get("latitude")
                or result.get("latitude")
                or result.get("location", {}).get("latitude")
            )
            lng = (
                geocodes.get("longitude")
                or result.get("longitude")
                or result.get("location", {}).get("longitude")
            )

            # Validate required fields
            if not all([fsq_id, name, lat, lng]):
                return None

            # Extract optional fields
            location = result.get("location", {})
            address_parts = []
            if location.get("address"):
                address_parts.append(location["address"])
            if location.get("locality"):
                address_parts.append(location["locality"])
            if location.get("postcode"):
                address_parts.append(location["postcode"])

            address = ", ".join(address_parts) if address_parts else None

            # Distance (from API or calculate)
            distance_m = result.get("distance")
            if distance_m is None:
                distance_m = haversine_distance(search_lat, search_lng, lat, lng)

            # Rating - Not available in Places Pro tier
            # (Would require Places Premium to access)
            rating = None

            # Build unified result
            return {
                "id": f"foursquare:{fsq_id}",
                "name": name,
                "lat": float(lat),
                "lng": float(lng),
                "address": address,
                "source": "foursquare",
                "distance_m": float(distance_m),
                "rating": rating,
                "popularity": None,  # External source, no save count
                "has_user_content": False
            }

        except Exception as e:
            print(f"Error mapping Foursquare result: {e}")
            return None
