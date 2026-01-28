"""
Search service with multi-source retrieval and deduplication.

Session 14: Normalization + cache key
Session 15: Multi-source retrieval + deduplication
Session 16: Ranking + API endpoints
"""

from typing import List, Dict, Any
from sqlalchemy.orm import Session
from rapidfuzz import fuzz

from app.utils.search_normalizer import (
    normalize_query,
    normalize_coords,
    normalize_radius
)
from app.utils.cache_keys import make_search_key
from app.utils.geo import haversine_distance, normalize_name_for_matching
from app.services.providers import LocalSearchProvider, FoursquareSearchProvider


class SearchService:
    """
    Multi-source search orchestrator.

    Combines:
    - Local database (user-contributed places)
    - External APIs (Foursquare)

    Features:
    - Local-first strategy (prioritize user data)
    - Intelligent deduplication (same place from multiple sources)
    - Graceful degradation (continue on partial failure)
    """

    def __init__(self, db: Session):
        """
        Initialize search service with providers.

        Args:
            db: SQLAlchemy database session
        """
        self.db = db
        self.local_provider = LocalSearchProvider(db)
        self.foursquare_provider = FoursquareSearchProvider()

    async def search_places(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float = 5.0,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Search for places from multiple sources.

        Strategy:
            1. Normalize inputs
            2. Search local database
            3. If results < limit, query Foursquare
            4. Merge results
            5. Deduplicate (local priority)
            6. Return up to limit results

        Args:
            query: Search text
            lat: Search center latitude
            lng: Search center longitude
            radius_km: Search radius in kilometers
            limit: Maximum results to return

        Returns:
            List of unified results (deduplicated, unranked).
            Ranking applied in Session 16.
        """
        # 1. Normalize inputs
        clean_query = normalize_query(query)
        norm_lat, norm_lng = normalize_coords(lat, lng)
        norm_radius = normalize_radius(radius_km)

        # 2. Generate cache key (logged but not used yet)
        cache_key = make_search_key(
            clean_query,
            norm_lat,
            norm_lng,
            norm_radius
        )

        # 3. Search local database first
        local_results = await self.local_provider.search(
            clean_query,
            norm_lat,
            norm_lng,
            norm_radius,
            limit=limit
        )

        # 4. If local results fill the limit, return early
        if len(local_results) >= limit:
            return local_results[:limit]

        # 5. Query Foursquare for additional results
        remaining_limit = limit - len(local_results)
        foursquare_results = []

        try:
            foursquare_results = await self.foursquare_provider.search(
                clean_query,
                norm_lat,
                norm_lng,
                norm_radius,
                limit=remaining_limit * 2  # Get extra for deduplication
            )
        except Exception as e:
            # Graceful degradation: continue with local results only
            print(f"Foursquare search failed: {e}")

        # 6. Merge results
        all_results = local_results + foursquare_results

        # 7. Deduplicate (local priority)
        unique_results = self._deduplicate_results(all_results)

        # 8. Limit final results
        return unique_results[:limit]

    def _deduplicate_results(
        self,
        results: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Remove duplicate places from merged results.

        Deduplication Rules:
        - Two results are duplicates if:
          1. Name similarity ≥ 90% (rapidfuzz)
          2. Distance ≤ 50 meters (haversine)
        - Local results ALWAYS win over external
        - For same-source duplicates, keep first

        Args:
            results: List of results from all sources

        Returns:
            Deduplicated list with local results prioritized
        """
        if not results:
            return []

        # Separate local and external results
        local_results = [r for r in results if r["source"] == "local"]
        external_results = [r for r in results if r["source"] != "local"]

        # Track unique results
        unique_results = []
        seen_signatures = []

        # Add all local results first (they always win)
        for result in local_results:
            unique_results.append(result)
            seen_signatures.append(self._get_result_signature(result))

        # Check external results for duplicates
        for ext_result in external_results:
            ext_sig = self._get_result_signature(ext_result)

            # Check against all seen results
            is_duplicate = False
            for seen_sig in seen_signatures:
                if self._are_duplicates(ext_sig, seen_sig):
                    is_duplicate = True
                    break

            # Keep if not duplicate
            if not is_duplicate:
                unique_results.append(ext_result)
                seen_signatures.append(ext_sig)

        return unique_results

    def _get_result_signature(
        self,
        result: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Extract signature for duplicate detection.

        Args:
            result: Unified result dict

        Returns:
            Dict with normalized name and coordinates
        """
        return {
            "name": normalize_name_for_matching(result["name"]),
            "lat": result["lat"],
            "lng": result["lng"]
        }

    def _are_duplicates(
        self,
        sig1: Dict[str, Any],
        sig2: Dict[str, Any]
    ) -> bool:
        """
        Check if two result signatures are duplicates.

        Criteria:
        - Name similarity ≥ 90%
        - Distance ≤ 50 meters

        Args:
            sig1: First result signature
            sig2: Second result signature

        Returns:
            True if duplicates, False otherwise
        """
        # Name similarity check
        name_similarity = fuzz.ratio(sig1["name"], sig2["name"])
        if name_similarity < 90:
            return False

        # Distance check
        distance = haversine_distance(
            sig1["lat"], sig1["lng"],
            sig2["lat"], sig2["lng"]
        )

        return distance <= 50  # 50 meters threshold
