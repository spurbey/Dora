"""
Search service with multi-source retrieval and deduplication.

Session 14: Normalization + cache key
Session 15: Multi-source retrieval + deduplication
Session 16: Ranking + API endpoints
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, timezone
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
        limit: int = 10,
        debug: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Search for places from multiple sources with ranking.

        Strategy:
            1. Normalize inputs
            2. Search local database
            3. If results < limit, query Foursquare
            4. Merge results
            5. Deduplicate (local priority)
            6. Rank by relevance score (Session 16)
            7. Return top results

        Args:
            query: Search text
            lat: Search center latitude
            lng: Search center longitude
            radius_km: Search radius in kilometers
            limit: Maximum results to return
            debug: Include score breakdown in results

        Returns:
            List of unified results (deduplicated, ranked by score).
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
            limit=limit * 2  # Get extra for ranking
        )

        # 4. Query Foursquare to fill gaps
        foursquare_results = []
        if len(local_results) < limit * 2:
            try:
                foursquare_results = await self.foursquare_provider.search(
                    clean_query,
                    norm_lat,
                    norm_lng,
                    norm_radius,
                    limit=limit * 2  # Get extra for deduplication + ranking
                )
            except Exception as e:
                # Graceful degradation: continue with local results only
                print(f"Foursquare search failed: {e}")

        # 5. Merge results
        all_results = local_results + foursquare_results

        # 6. Deduplicate (local priority)
        unique_results = self._deduplicate_results(all_results)

        # 7. Rank by relevance score (Session 16)
        ranked_results = self._rank_results(unique_results, clean_query, debug)

        # 8. Limit final results
        return ranked_results[:limit]

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

    def _rank_results(
        self,
        results: List[Dict[str, Any]],
        query: str,
        debug: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Rank results by relevance score.

        Ranking Formula:
            score = (
                source_weight * 0.4 +
                text_relevance * 0.3 +
                popularity * 0.2 +
                freshness * 0.1
            )

        Args:
            results: List of deduplicated results
            query: Original search query (for text relevance)
            debug: Include score breakdown

        Returns:
            Results sorted by score (highest first)
        """
        if not results:
            return []

        # Calculate score for each result
        for result in results:
            score_info = self._calculate_result_score(result, query)
            result["score"] = score_info["final_score"]

            # Add debug info if requested
            if debug:
                result["_debug"] = self._add_debug_info(score_info)

        # Sort by score descending
        ranked = sorted(results, key=lambda r: r["score"], reverse=True)

        return ranked

    def _calculate_result_score(
        self,
        result: Dict[str, Any],
        query: str
    ) -> Dict[str, float]:
        """
        Calculate weighted relevance score for a result.

        Args:
            result: Result dict from provider
            query: Search query

        Returns:
            Dict with component scores and final weighted score
        """
        # Component weights (must sum to 1.0)
        WEIGHTS = {
            "source": 0.4,
            "text": 0.3,
            "popularity": 0.2,
            "freshness": 0.1
        }

        # Calculate component scores (0-1 scale)
        source_score = self._calculate_source_score(result)
        text_score = self._calculate_text_score(result, query)
        popularity_score = self._calculate_popularity_score(result)
        freshness_score = self._calculate_freshness_score(result)

        # Calculate weighted contributions
        source_contrib = source_score * WEIGHTS["source"]
        text_contrib = text_score * WEIGHTS["text"]
        popularity_contrib = popularity_score * WEIGHTS["popularity"]
        freshness_contrib = freshness_score * WEIGHTS["freshness"]

        # Final score
        final_score = (
            source_contrib +
            text_contrib +
            popularity_contrib +
            freshness_contrib
        )

        return {
            "source_score": source_score,
            "source_contribution": source_contrib,
            "text_score": text_score,
            "text_contribution": text_contrib,
            "popularity_score": popularity_score,
            "popularity_contribution": popularity_contrib,
            "freshness_score": freshness_score,
            "freshness_contribution": freshness_contrib,
            "final_score": final_score
        }

    def _calculate_source_score(self, result: Dict[str, Any]) -> float:
        """
        Calculate source weight score.

        Local user data > External API data.

        Args:
            result: Result dict

        Returns:
            Score 0-1 (1.0 for local, 0.6 for external)
        """
        source = result.get("source", "").lower()

        if source == "local":
            return 1.0
        elif source == "foursquare":
            return 0.6
        elif source == "mapbox":
            return 0.6
        else:
            return 0.5  # Unknown source

    def _calculate_text_score(
        self,
        result: Dict[str, Any],
        query: str
    ) -> float:
        """
        Calculate text relevance score.

        For local results: use text_relevance from PostgreSQL ts_rank_cd
        For external results: fuzzy match on name

        Args:
            result: Result dict
            query: Search query

        Returns:
            Score 0-1
        """
        # Local results have pre-calculated text_relevance from ts_rank_cd
        if "text_relevance" in result and result["text_relevance"] is not None:
            # ts_rank_cd returns values typically 0-1, but can be higher
            # Normalize to 0-1 range
            return min(result["text_relevance"], 1.0)

        # External results: fuzzy match on name
        name = result.get("name", "").lower()
        query_lower = query.lower()

        # Exact name match
        if name == query_lower:
            return 1.0

        # Word-level matching
        query_words = query_lower.split()
        name_words = name.split()

        # Single-word exact match (e.g., "coffee" in "coffee bean")
        if len(query_words) == 1 and query_words[0] in name_words:
            return 1.0

        # All query words present (partial word match)
        if all(word in name_words for word in query_words):
            return 0.7

        # Any query word present
        if any(word in name_words for word in query_words):
            return 0.5

        # Substring match (query appears in name but not as full words)
        if query_lower in name:
            return 0.4

        # Fuzzy match
        similarity = fuzz.ratio(query_lower, name)
        if similarity >= 80:
            return 0.3
        elif similarity >= 60:
            return 0.3

        return 0.2  # Weak match

    def _calculate_popularity_score(self, result: Dict[str, Any]) -> float:
        """
        Calculate popularity score.

        For local: based on save count
        For external: based on rating if available

        Args:
            result: Result dict

        Returns:
            Score 0-1
        """
        # Local results have save count as popularity
        if result.get("source") == "local":
            save_count = result.get("popularity", 0) or 0
            # Normalize: assume 100 saves = max popularity
            return min(save_count / 100.0, 1.0)

        # External results may have rating
        rating = result.get("rating")
        if rating is not None:
            # Rating typically 0-10 scale
            return min(rating / 10.0, 1.0)

        # No popularity data
        return 0.1  # Neutral default

    def _calculate_freshness_score(self, result: Dict[str, Any]) -> float:
        """
        Calculate freshness score.

        For local: based on created_at
        For external: neutral default (no creation date)

        Args:
            result: Result dict

        Returns:
            Score 0-1
        """
        # External results don't have creation dates
        if result.get("source") != "local":
            return 0.5  # Neutral

        # Local results have created_at
        created_at = result.get("created_at")
        if not created_at:
            return 0.5  # Neutral if missing

        # Calculate age in days
        if isinstance(created_at, str):
            try:
                created_at = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
            except Exception:
                return 0.5

        now = datetime.now(timezone.utc)
        age_days = (now - created_at).days

        # Score based on age
        if age_days < 7:
            return 1.0  # Very fresh
        elif age_days < 30:
            return 0.8  # Fresh
        elif age_days < 90:
            return 0.5  # Moderate
        else:
            return 0.3  # Older

    def _add_debug_info(self, score_info: Dict[str, float]) -> Dict[str, Any]:
        """
        Format score breakdown for debug mode.

        Args:
            score_info: Score components from _calculate_result_score

        Returns:
            Debug info dict with human-readable breakdown
        """
        breakdown = (
            f"{score_info['source_contribution']:.2f} + "
            f"{score_info['text_contribution']:.2f} + "
            f"{score_info['popularity_contribution']:.2f} + "
            f"{score_info['freshness_contribution']:.2f} = "
            f"{score_info['final_score']:.2f}"
        )

        return {
            "source_score": round(score_info["source_score"], 2),
            "source_contribution": round(score_info["source_contribution"], 2),
            "text_score": round(score_info["text_score"], 2),
            "text_contribution": round(score_info["text_contribution"], 2),
            "popularity_score": round(score_info["popularity_score"], 2),
            "popularity_contribution": round(score_info["popularity_contribution"], 2),
            "freshness_score": round(score_info["freshness_score"], 2),
            "freshness_contribution": round(score_info["freshness_contribution"], 2),
            "final_score": round(score_info["final_score"], 2),
            "breakdown": breakdown
        }


# Signal logging helper functions (called from background tasks)

def log_search_event(
    db: Session,
    user_id: str,
    query: str,
    lat: float,
    lng: float,
    radius_km: float,
    results_count: int
) -> None:
    """
    Log a search event to the database (background task).

    Args:
        db: Database session (new session for background task)
        user_id: User who performed search
        query: Search query text
        lat: Search center latitude
        lng: Search center longitude
        radius_km: Search radius
        results_count: Number of results returned

    Returns:
        None (logs errors but doesn't raise)
    """
    from app.models import SearchEvent

    try:
        event = SearchEvent(
            user_id=user_id,
            query=query,
            lat=lat,
            lng=lng,
            radius_km=radius_km,
            results_count=results_count
        )
        db.add(event)
        db.commit()
    except Exception as e:
        print(f"Failed to log search event: {e}")
        db.rollback()
    finally:
        db.close()


def log_place_view(
    db: Session,
    user_id: str,
    place_id: str,
    source: str
) -> None:
    """
    Log a place view to the database (background task).

    Args:
        db: Database session (new session for background task)
        user_id: User who viewed the place
        place_id: Place ID that was viewed
        source: Source of the result ("local" or "foursquare")

    Returns:
        None (logs errors but doesn't raise)
    """
    from app.models import PlaceView

    try:
        view = PlaceView(
            user_id=user_id,
            place_id=place_id,
            source=source
        )
        db.add(view)
        db.commit()
    except Exception as e:
        print(f"Failed to log place view: {e}")
        db.rollback()
    finally:
        db.close()


def log_place_save(
    db: Session,
    user_id: str,
    place_id: str
) -> None:
    """
    Log a place save to the database (background task).

    Args:
        db: Database session (new session for background task)
        user_id: User who saved the place
        place_id: Place ID that was saved

    Returns:
        None (logs errors but doesn't raise)
    """
    from app.models import PlaceSave

    try:
        save = PlaceSave(
            user_id=user_id,
            place_id=place_id
        )
        db.add(save)
        db.commit()
    except Exception as e:
        print(f"Failed to log place save: {e}")
        db.rollback()
    finally:
        db.close()
