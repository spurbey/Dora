"""
Search API endpoints.

Session 16: Public search interface with ranking and signal logging.
"""

from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models import User
from app.schemas.search import SearchQuery, SearchResponse, SearchResult
from app.services.search_service import SearchService, log_search_event


router = APIRouter(prefix="/search", tags=["search"])


@router.get("/places", response_model=SearchResponse)
async def search_places(
    query: Annotated[str, Query(min_length=1, max_length=100, description="Search text")],
    lat: Annotated[float, Query(ge=-90, le=90, description="Search center latitude")],
    lng: Annotated[float, Query(ge=-180, le=180, description="Search center longitude")],
    radius_km: Annotated[float, Query(ge=0.1, le=50.0, description="Search radius in km")] = 5.0,
    limit: Annotated[int, Query(ge=1, le=50, description="Max results")] = 10,
    debug: Annotated[bool, Query(description="Include score breakdown")] = False,
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Search for places from multiple sources.

    **Authentication:** Required

    **Strategy:**
    - Searches local database first (user-contributed places)
    - Falls back to Foursquare API if needed
    - Deduplicates results (local priority)
    - Ranks by relevance score
    - Logs search event for learning

    **Query Parameters:**
    - `query`: Search text (e.g., "coffee shop")
    - `lat`: Search center latitude
    - `lng`: Search center longitude
    - `radius_km`: Search radius in kilometers (default: 5.0)
    - `limit`: Maximum results to return (default: 10)
    - `debug`: Include score breakdown in results (default: false)

    **Response:**
    - `results`: List of ranked results with scores
    - `count`: Number of results returned
    - `query`: Original search query (echoed back)

    **Errors:**
    - 400: Invalid parameters (bad coordinates, empty query)
    - 401: Not authenticated
    - 500: Internal server error
    """
    try:
        # Validate query not empty
        if not query or not query.strip():
            raise HTTPException(status_code=400, detail="Query cannot be empty")

        # Initialize search service
        search_service = SearchService(db)

        # Execute search
        results = await search_service.search_places(
            query=query.strip(),
            lat=lat,
            lng=lng,
            radius_km=radius_km,
            limit=limit,
            debug=debug
        )

        # Log search event in background (non-blocking)
        background_tasks.add_task(
            log_search_event,
            db=next(get_db()),  # New session for background task
            user_id=str(current_user.id),
            query=query.strip(),
            lat=lat,
            lng=lng,
            radius_km=radius_km,
            results_count=len(results)
        )

        # Convert to response schema
        search_results = [SearchResult(**result) for result in results]

        return SearchResponse(
            results=search_results,
            count=len(search_results),
            query=query.strip()
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Search error: {e}")
        raise HTTPException(
            status_code=500,
            detail="An error occurred while searching"
        )
