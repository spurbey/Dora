"""
User profile endpoints.

Endpoints:
    - GET /users/me: Get current user profile
    - PATCH /users/me: Update current user profile
    - GET /users/me/stats: Get detailed user statistics
    - DELETE /users/me: Permanently delete current user account
"""

from uuid import UUID

import httpx
from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.config import settings
from app.schemas.user import UserResponse, UserUpdate, UserStats, UserProfileResponse
from app.services.user_service import UserService


router = APIRouter(prefix="/users", tags=["Users"])


async def _delete_supabase_auth_user(user_id: UUID) -> None:
    """
    Delete the Supabase Auth identity for a user via Admin API.

    Treats HTTP 404 as already-deleted and therefore successful.
    """
    endpoint = f"{settings.SUPABASE_URL}/auth/v1/admin/users/{user_id}"
    headers = {
        "apikey": settings.SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}",
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.delete(
                endpoint,
                headers=headers,
                params={"should_soft_delete": "false"},
            )
    except httpx.RequestError:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to reach auth provider during account deletion",
        )

    if response.status_code in (200, 204, 404):
        return

    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="Auth provider rejected account deletion request",
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Get current user profile.
    
    **Authentication:** Required
    
    **Permissions:** Any authenticated user
    
    **Returns:**
    User profile data
    
    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "email": "user@example.com",
        "username": "traveler123",
        "full_name": "John Doe",
        "avatar_url": "https://example.com/avatar.jpg",
        "bio": "Love to travel!",
        "is_premium": false,
        "is_verified": true,
        "created_at": "2024-01-15T10:30:00Z"
    }
```
    
    **Errors:**
    - 401: Not authenticated
    
    **Business Logic:**
    - Returns current user's profile data
    - Used by frontend profile page
    """
    return UserResponse.model_validate(current_user)


@router.patch("/me", response_model=UserResponse)
async def update_current_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update current user profile.
    
    **Authentication:** Required
    
    **Permissions:** Any authenticated user (can only update own profile)
    
    **Request Body:**
    All fields are optional (partial update):
    - username: New username (3-50 chars, alphanumeric + underscore)
    - full_name: New full name
    - bio: New bio (max 500 chars)
    - avatar_url: New avatar URL
    
    **Returns:**
    Updated user profile
    
    **Response Example:**
```json
    {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "username": "new_username",
        "full_name": "Updated Name",
        "bio": "Updated bio",
        ...
    }
```
    
    **Errors:**
    - 400: Username already taken or invalid format
    - 401: Not authenticated
    
    **Business Logic:**
    - Only updates provided fields (partial update)
    - Username must be unique across all users
    - Username can only contain letters, numbers, underscore
    - Email cannot be changed (use Supabase Auth)
    """
    service = UserService(db)
    updated_user = service.update_user(current_user.id, user_update)
    return UserResponse.model_validate(updated_user)


@router.get("/me/stats", response_model=UserStats)
async def get_current_user_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get detailed user statistics.
    
    **Authentication:** Required
    
    **Permissions:** Any authenticated user
    
    **Returns:**
    Detailed statistics about user's content and engagement
    
    **Response Example:**
```json
    {
        "trip_count": 5,
        "place_count": 47,
        "public_trip_count": 2,
        "total_views": 1234,
        "total_saves": 56,
        "photos_uploaded": 89
    }
```
    
    **Errors:**
    - 401: Not authenticated
    
    **Business Logic:**
    - Calculates statistics in real-time from database
    - Used by dashboard to display user activity
    - Premium users get additional stats (future)
    
    **Performance:**
    - Uses SQLAlchemy aggregation functions
    - Queries optimized with indexes
    - Consider caching for high-traffic users
    """
    service = UserService(db)
    stats = service.get_user_stats(current_user.id)
    return stats


@router.get("/me/profile", response_model=UserProfileResponse)
async def get_current_user_complete_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get complete user profile with statistics.
    
    **Authentication:** Required
    
    **Permissions:** Any authenticated user
    
    **Returns:**
    User profile + statistics in single response
    
    **Response Example:**
```json
    {
        "user": {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "email": "user@example.com",
            "username": "traveler123",
            ...
        },
        "stats": {
            "trip_count": 5,
            "place_count": 47,
            ...
        }
    }
```
    
    **Errors:**
    - 401: Not authenticated
    
    **Business Logic:**
    - Combines /me and /me/stats into single response
    - Reduces frontend API calls for profile page
    - More efficient than two separate requests
    """
    service = UserService(db)
    stats = service.get_user_stats(current_user.id)
    
    return UserProfileResponse(
        user=UserResponse.model_validate(current_user),
        stats=stats
    )


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_current_user_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Permanently delete current user account and owned data.

    Deletion sequence:
    1. Remove auth identity from Supabase Auth.
    2. Remove backend user row (DB cascades remove related rows).
    """
    await _delete_supabase_auth_user(current_user.id)

    service = UserService(db)
    service.delete_user_account(current_user.id)

    return Response(status_code=status.HTTP_204_NO_CONTENT)
