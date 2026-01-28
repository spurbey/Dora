"""
Local database search provider.

Searches user-contributed places using:
- PostgreSQL full-text search (search_vector + GIN index)
- PostGIS geospatial queries (ST_DWithin, ST_Distance)

Returns results with popularity from place_saves count.
"""

from typing import List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func, select, and_, or_
from geoalchemy2.functions import ST_DWithin, ST_Distance, ST_SetSRID, ST_MakePoint

from app.services.providers.base import BaseSearchProvider
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.search_signals import PlaceSave


class LocalSearchProvider(BaseSearchProvider):
    """
    Search local database for user-contributed places.

    Combines full-text search with geospatial filtering.
    Only returns public/unlisted places (respects privacy).

    Attributes:
        db: SQLAlchemy database session
    """

    def __init__(self, db: Session):
        """
        Initialize local provider with database session.

        Args:
            db: SQLAlchemy session for database queries
        """
        self.db = db

    async def search(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Search local database for places.

        Strategy:
            1. Use search_vector for full-text matching
            2. Use ST_DWithin for radius filtering
            3. Join trips table for visibility check
            4. Calculate distance with ST_Distance
            5. Count saves from place_saves table
            6. Order by distance (closest first)

        Args:
            query: Normalized search text
            lat: Search center latitude
            lng: Search center longitude
            radius_km: Search radius in kilometers
            limit: Maximum results to return

        Returns:
            List of results in unified schema format.
            Empty list if no matches or error.
        """
        try:
            # Convert radius to meters for PostGIS
            radius_meters = radius_km * 1000

            # Create search point (SRID 4326 = WGS84)
            search_point = func.ST_SetSRID(
                func.ST_MakePoint(lng, lat),
                4326
            )

            # Build query
            # Using plainto_tsquery for user-friendly text search
            # (handles multi-word queries without operators)
            query_obj = (
                select(
                    TripPlace.id,
                    TripPlace.name,
                    TripPlace.lat,
                    TripPlace.lng,
                    TripPlace.created_at,
                    func.ST_Distance(
                        TripPlace.location,
                        search_point
                    ).label('distance_m'),
                    func.ts_rank_cd(
                        TripPlace.search_vector,
                        func.plainto_tsquery('english', query)
                    ).label('text_relevance'),
                    func.count(PlaceSave.id).label('save_count')
                )
                .join(Trip, TripPlace.trip_id == Trip.id)
                .outerjoin(PlaceSave, PlaceSave.place_id == TripPlace.id)
                .where(
                    and_(
                        # Full-text search match
                        TripPlace.search_vector.op('@@')(
                            func.plainto_tsquery('english', query)
                        ),
                        # Geospatial radius filter
                        func.ST_DWithin(
                            TripPlace.location,
                            search_point,
                            radius_meters
                        ),
                        # Privacy: only public/unlisted
                        Trip.visibility.in_(['public', 'unlisted'])
                    )
                )
                .group_by(
                    TripPlace.id,
                    TripPlace.name,
                    TripPlace.lat,
                    TripPlace.lng,
                    TripPlace.created_at,
                    TripPlace.location,
                    TripPlace.search_vector
                )
                .order_by(func.ST_Distance(TripPlace.location, search_point))
                .limit(limit)
            )

            # Execute query
            results = self.db.execute(query_obj).all()

            # Map to unified schema
            unified_results = []
            for row in results:
                unified_results.append({
                    "id": f"local:{row.id}",
                    "name": row.name,
                    "lat": row.lat,
                    "lng": row.lng,
                    "address": None,  # Not stored in TripPlace
                    "source": "local",
                    "distance_m": float(row.distance_m),
                    "rating": None,  # Not in TripPlace model
                    "popularity": row.save_count,
                    "has_user_content": True,
                    "text_relevance": float(row.text_relevance),  # For ranking
                    "created_at": row.created_at  # For freshness
                })

            return unified_results

        except Exception as e:
            # Log error but don't crash
            print(f"LocalSearchProvider error: {e}")
            return []
