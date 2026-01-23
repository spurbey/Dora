"""
User service layer for business logic.

Handles:
    - User profile retrieval
    - User profile updates
    - User statistics calculation
    - Username uniqueness validation
"""

from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException, status
from typing import Optional
from uuid import UUID

from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.schemas.user import UserUpdate, UserStats


class UserService:
    """
    Service layer for user operations.
    
    Attributes:
        db: Database session
        
    Methods:
        get_user_by_id: Get user by UUID
        get_user_by_username: Get user by username
        get_user_by_email: Get user by email
        update_user: Update user profile
        get_user_stats: Calculate user statistics
        check_username_available: Check if username is available
    """
    
    def __init__(self, db: Session):
        """
        Initialize user service.
        
        Args:
            db: SQLAlchemy database session
        """
        self.db = db
    
    def get_user_by_id(self, user_id: UUID) -> Optional[User]:
        """
        Get user by ID.
        
        Args:
            user_id: User UUID
            
        Returns:
            User object or None if not found
        """
        return self.db.query(User).filter(User.id == user_id).first()
    
    def get_user_by_username(self, username: str) -> Optional[User]:
        """
        Get user by username.
        
        Args:
            username: Username to search
            
        Returns:
            User object or None if not found
        """
        return self.db.query(User).filter(User.username == username).first()
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """
        Get user by email.
        
        Args:
            email: Email to search
            
        Returns:
            User object or None if not found
        """
        return self.db.query(User).filter(User.email == email).first()
    
    def check_username_available(self, username: str, current_user_id: UUID) -> bool:
        """
        Check if username is available.
        
        Args:
            username: Username to check
            current_user_id: ID of current user (to allow keeping same username)
            
        Returns:
            bool: True if available, False if taken
            
        Business Logic:
            - Username must be unique across all users
            - Current user can keep their existing username
        """
        existing_user = self.get_user_by_username(username)
        
        # Username is available if:
        # 1. No user has it, OR
        # 2. Current user already has it
        if existing_user is None:
            return True
        
        return existing_user.id == current_user_id
    
    def update_user(
        self,
        user_id: UUID,
        user_update: UserUpdate
    ) -> User:
        """
        Update user profile.
        
        Args:
            user_id: User ID to update
            user_update: Update data
            
        Returns:
            Updated User object
            
        Raises:
            HTTPException 404: User not found
            HTTPException 400: Username already taken
            
        Business Logic:
            - Only update fields that are provided (partial update)
            - Validate username uniqueness before updating
            - Cannot change email (must use Supabase Auth)
        """
        user = self.get_user_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Check username availability if changing username
        if user_update.username is not None:
            if not self.check_username_available(user_update.username, user_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Username already taken"
                )
        
        # Update only provided fields
        update_data = user_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)
        
        self.db.commit()
        self.db.refresh(user)
        
        return user
    
    def get_user_stats(self, user_id: UUID) -> UserStats:
        """
        Calculate user statistics.
        
        Args:
            user_id: User ID
            
        Returns:
            UserStats object with calculated statistics
            
        Statistics Calculated:
            - trip_count: Total trips created
            - place_count: Total places across all trips
            - public_trip_count: Number of public trips
            - total_views: Sum of views across all trips
            - total_saves: Sum of saves across all trips
            - photos_uploaded: Count of photos in JSONB arrays
            
        Performance:
            - Uses SQLAlchemy aggregation functions
            - Single query per statistic (could be optimized with joins)
        """
        # Count trips
        trip_count = self.db.query(func.count(Trip.id)).filter(
            Trip.user_id == user_id
        ).scalar() or 0
        
        # Count places
        place_count = self.db.query(func.count(TripPlace.id)).filter(
            TripPlace.user_id == user_id
        ).scalar() or 0
        
        # Count public trips
        public_trip_count = self.db.query(func.count(Trip.id)).filter(
            Trip.user_id == user_id,
            Trip.visibility == "public"
        ).scalar() or 0
        
        # Sum views across all trips
        total_views = self.db.query(func.sum(Trip.views_count)).filter(
            Trip.user_id == user_id
        ).scalar() or 0
        
        # Sum saves across all trips
        total_saves = self.db.query(func.sum(Trip.saves_count)).filter(
            Trip.user_id == user_id
        ).scalar() or 0
        
        # Count photos (sum of JSONB array lengths)
        photos_uploaded = self.db.query(
            func.coalesce(
                func.sum(func.jsonb_array_length(TripPlace.photos)),
                0
            )
        ).filter(
            TripPlace.user_id == user_id
        ).scalar() or 0
        
        return UserStats(
            trip_count=trip_count,
            place_count=place_count,
            public_trip_count=public_trip_count,
            total_views=total_views,
            total_saves=total_saves,
            photos_uploaded=photos_uploaded
        )