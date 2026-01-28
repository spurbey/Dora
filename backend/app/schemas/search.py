"""
Search schemas for API validation and response formatting.

Session 16: Intelligence layer schemas
"""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, validator
from pydantic import ConfigDict


class SearchQuery(BaseModel):
    """
    Search query parameters with validation.

    Attributes:
        query: Search text (1-100 chars)
        lat: Search center latitude (-90 to 90)
        lng: Search center longitude (-180 to 180)
        radius_km: Search radius in km (0.1 to 50, default 5.0)
        limit: Max results (1 to 50, default 10)
        debug: Include score breakdown (default False)
    """
    query: str = Field(..., min_length=1, max_length=100, description="Search text")
    lat: float = Field(..., ge=-90, le=90, description="Search center latitude")
    lng: float = Field(..., ge=-180, le=180, description="Search center longitude")
    radius_km: float = Field(5.0, ge=0.1, le=50.0, description="Search radius in kilometers")
    limit: int = Field(10, ge=1, le=50, description="Maximum results to return")
    debug: bool = Field(False, description="Include score breakdown in results")

    @validator('query')
    def query_not_empty(cls, v):
        """Ensure query is not just whitespace."""
        if not v or not v.strip():
            raise ValueError('Query cannot be empty or whitespace only')
        return v.strip()


class SearchResultDebug(BaseModel):
    """
    Debug information for result ranking (optional).

    Attributes:
        source_score: Source weight score (0-1)
        source_contribution: Contribution to final score
        text_score: Text relevance score (0-1)
        text_contribution: Contribution to final score
        popularity_score: Popularity score (0-1)
        popularity_contribution: Contribution to final score
        freshness_score: Freshness score (0-1)
        freshness_contribution: Contribution to final score
        final_score: Total weighted score (0-1)
        breakdown: Human-readable score calculation
    """
    source_score: float
    source_contribution: float
    text_score: float
    text_contribution: float
    popularity_score: float
    popularity_contribution: float
    freshness_score: float
    freshness_contribution: float
    final_score: float
    breakdown: str


class SearchResult(BaseModel):
    """
    Unified search result from any source.

    Attributes:
        id: Result ID ("local:uuid" or "foursquare:fsq_id")
        name: Place name
        lat: Latitude
        lng: Longitude
        address: Full address (if available)
        source: Data source ("local" | "foursquare")
        distance_m: Distance from search center in meters
        rating: Rating 0-10 scale (if available)
        popularity: Save count for local, None for external
        has_user_content: True if source="local"
        score: Ranking score (0-1, higher = more relevant)
        _debug: Score breakdown (only if debug=True)
    """
    id: Optional[str] = None
    name: str
    lat: float
    lng: float
    address: Optional[str] = None
    source: str
    distance_m: float
    rating: Optional[float] = None
    popularity: Optional[int] = None
    has_user_content: bool
    score: float = Field(0.0, ge=0.0, le=1.0, description="Ranking score")
    debug: Optional[SearchResultDebug] = Field(default=None, alias="_debug")

    model_config = ConfigDict(
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "id": "local:123e4567-e89b-12d3-a456-426614174000",
                "name": "Coffee Lab Paris",
                "lat": 48.8584,
                "lng": 2.2945,
                "address": "123 Rue de Rivoli, Paris, 75001",
                "source": "local",
                "distance_m": 150.5,
                "rating": 8.5,
                "popularity": 42,
                "has_user_content": True,
                "score": 0.84
            }
        }
    )


class SearchResponse(BaseModel):
    """
    Search API response wrapper.

    Attributes:
        results: List of ranked search results
        count: Number of results returned
        query: Original search query (echoed back)
    """
    results: List[SearchResult]
    count: int
    query: str

    class Config:
        json_schema_extra = {
            "example": {
                "results": [
                    {
                        "id": "local:123e4567-e89b-12d3-a456-426614174000",
                        "name": "Coffee Lab Paris",
                        "lat": 48.8584,
                        "lng": 2.2945,
                        "address": "123 Rue de Rivoli, Paris, 75001",
                        "source": "local",
                        "distance_m": 150.5,
                        "rating": 8.5,
                        "popularity": 42,
                        "has_user_content": True,
                        "score": 0.84
                    }
                ],
                "count": 1,
                "query": "coffee"
            }
        }
