"""
Pydantic schemas for authentication.

Schemas for auth-related requests and responses.
"""

from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from uuid import UUID


class Token(BaseModel):
    """
    JWT token response.
    
    Attributes:
        access_token: JWT token string
        token_type: Always "bearer"
        expires_at: Token expiration timestamp
    """
    access_token: str
    token_type: str = "bearer"
    expires_at: Optional[datetime] = None


class UserResponse(BaseModel):
    """
    User data in API responses.
    
    Attributes:
        id: User UUID
        email: User email
        username: Unique username
        full_name: Optional full name
        avatar_url: Optional profile picture URL
        bio: Optional bio
        is_premium: Premium subscription status
        is_verified: Email verification status
        created_at: Account creation timestamp
        
    Config:
        from_attributes: Enable ORM mode for SQLAlchemy models
    """
    id: UUID
    email: str
    username: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    is_premium: bool
    is_verified: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class MeResponse(BaseModel):
    """
    Current user info with additional stats.
    
    Attributes:
        user: User data
        trip_count: Number of trips created
        place_count: Total places across all trips
        
    Used by /auth/me endpoint.
    """
    user: UserResponse
    trip_count: int = 0
    place_count: int = 0