"""
Search service foundation.

Session 14: Normalization + cache key only.
No retrieval yet.
"""

from typing import List, Dict, Any
from sqlalchemy.orm import Session

from app.utils.search_normalizer import (
    normalize_query,
    normalize_coords,
    normalize_radius
)
from app.utils.cache_keys import make_search_key


class SearchService:
    """
    Multi-source search service.

    Session 14:
        - Normalize inputs
        - Generate cache key
        - Return empty list
    """

    def __init__(self, db: Session):
        self.db = db

    async def search_places(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float = 5.0
    ) -> List[Dict[str, Any]]:
        """
        Search places (Session 14 stub).

        Later:
            - Retrieval
            - Ranking
            - Caching
        """

        # 1. Normalize inputs
        clean_query = normalize_query(query)
        norm_lat, norm_lng = normalize_coords(lat, lng)
        norm_radius = normalize_radius(radius_km)

        # 2. Generate cache key (not used yet)
        _ = make_search_key(
            clean_query,
            norm_lat,
            norm_lng,
            norm_radius
        )

        # 3. Session 14: No retrieval yet
        return []
