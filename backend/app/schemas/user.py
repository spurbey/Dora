"""
Pydantic schemas for user operations.

Schemas for user profile requests and responses.
"""

from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import datetime
from uuid import UUID


class UserBase(BaseModel):
    """
    Base user schema with common fields.
    
    Attributes:
        email: User email address
        username: Unique username (3-50 chars)
        full_name: Optional full name
        bio: Optional bio/description
    """
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)
    full_name: Optional[str] = Field(None, max_length=255)
    bio: Optional[str] = Field(None, max_length=500)


class UserUpdate(BaseModel):
    """
    User profile update schema.
    
    All fields are optional for partial updates.
    
    Attributes:
        username: New username (must be unique)
        full_name: New full name
        bio: New bio
        avatar_url: New avatar URL
        
    Business Rules:
        - Username must be unique across all users
        - Username can only contain alphanumeric and underscore
        - Email cannot be changed (must use Supabase Auth)
    """
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    full_name: Optional[str] = Field(None, max_length=255)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None
    
    @validator('username')
    def username_alphanumeric(cls, v):
        """
        Validate username contains only alphanumeric and underscore.
        
        Args:
            v: Username value
            
        Returns:
            str: Validated username
            
        Raises:
            ValueError: If username contains invalid characters
        """
        if v is not None:
            if not v.replace('_', '').isalnum():
                raise ValueError('Username must contain only letters, numbers, and underscores')
        return v


class UserResponse(BaseModel):
    """
    User profile response schema.
    
    Attributes:
        id: User UUID
        email: User email
        username: Unique username
        full_name: Full name
        avatar_url: Profile picture URL
        bio: User bio
        is_premium: Premium subscription status
        is_verified: Email verification status
        subscription_ends_at: Premium subscription end date
        created_at: Account creation timestamp
        last_login: Last login timestamp
        
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
    subscription_ends_at: Optional[datetime] = None
    created_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class UserStats(BaseModel):
    """
    Detailed user statistics.
    
    Attributes:
        trip_count: Total trips created
        place_count: Total places across all trips
        public_trip_count: Number of public trips
        total_views: Total views across all trips
        total_saves: Total saves across all trips
        photos_uploaded: Number of photos uploaded
        
    Used by /users/me/stats endpoint for dashboard display.
    """
    trip_count: int = 0
    place_count: int = 0
    public_trip_count: int = 0
    total_views: int = 0
    total_saves: int = 0
    photos_uploaded: int = 0


class UserProfileResponse(BaseModel):
    """
    Complete user profile with stats.
    
    Attributes:
        user: User profile data
        stats: User statistics
        
    Used for dashboard/profile pages.
    """
    user: UserResponse
    stats: UserStats