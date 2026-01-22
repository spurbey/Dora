"""
Authentication endpoints.

Endpoints:
    - GET /auth/me: Get current user info with stats
    
Note:
    Login/signup handled by Supabase Auth directly.
    These endpoints are for authenticated users only.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.schemas.auth import MeResponse, UserResponse


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.get("/me", response_model=MeResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get current authenticated user with statistics.
    
    **Authentication:** Required
    
    **Permissions:** Any authenticated user
    
    **Returns:**
    - user: User profile data
    - trip_count: Number of trips created
    - place_count: Total places across all trips
    
    **Response Example:**
```json
    {
        "user": {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "email": "user@example.com",
            "username": "traveler123",
            "is_premium": false,
            "created_at": "2024-01-15T10:30:00Z"
        },
        "trip_count": 2,
        "place_count": 15
    }
```
    
    **Errors:**
    - 401: Not authenticated or invalid token
    
    **Business Logic:**
    - Stats calculated in real-time from database
    - Used by frontend to display user dashboard
    - Premium status determines feature availability
    """
    
    # Count user's trips
    trip_count = db.query(func.count(Trip.id)).filter(
        Trip.user_id == current_user.id
    ).scalar()
    
    # Count user's places
    place_count = db.query(func.count(TripPlace.id)).filter(
        TripPlace.user_id == current_user.id
    ).scalar()
    
    return MeResponse(
        user=UserResponse.from_orm(current_user),
        trip_count=trip_count or 0,
        place_count=place_count or 0
    )