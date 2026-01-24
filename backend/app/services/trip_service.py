"""
Trip service layer for business logic.

Handles:
    - Trip CRUD operations
    - Free tier limit enforcement (3 trips for non-premium users)
    - Ownership validation
    - Pagination
"""

from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from fastapi import HTTPException, status
from typing import Optional
from uuid import UUID

from app.models.trip import Trip
from app.models.user import User
from app.schemas.trip import TripCreate, TripUpdate, TripListResponse, TripResponse


class TripService:
    """
    Service layer for trip operations.

    Attributes:
        db: Database session

    Methods:
        get_trip_by_id: Get trip by UUID
        get_user_trip_count: Count user's trips
        create_trip: Create new trip (with free tier limit check)
        list_user_trips: List user's trips with pagination
        update_trip: Update existing trip (with ownership check)
        delete_trip: Delete trip (with ownership check)
        _check_free_tier_limit: Internal free tier limit check
        _check_trip_ownership: Internal ownership validation
    """

    def __init__(self, db: Session):
        """
        Initialize trip service.

        Args:
            db: SQLAlchemy database session
        """
        self.db = db

    def get_trip_by_id(self, trip_id: UUID) -> Optional[Trip]:
        """
        Get trip by ID.

        Args:
            trip_id: Trip UUID

        Returns:
            Trip object or None if not found

        Usage:
            Used by detail, update, and delete endpoints to fetch trip.
            Caller is responsible for access control checks.
        """
        return self.db.query(Trip).filter(Trip.id == trip_id).first()

    def get_user_trip_count(self, user_id: UUID) -> int:
        """
        Count user's total trips.

        Args:
            user_id: User UUID

        Returns:
            int: Total trip count

        Usage:
            - Used by free tier limit check
            - Used by user stats endpoint

        Performance:
            - Uses COUNT aggregation (fast)
            - No need to fetch trip rows
        """
        return self.db.query(func.count(Trip.id)).filter(
            Trip.user_id == user_id
        ).scalar() or 0

    def _check_free_tier_limit(self, user_id: UUID) -> None:
        """
        Check if user can create new trip (free tier limit).

        Args:
            user_id: User UUID

        Raises:
            HTTPException 403: If user has reached free tier limit

        Business Logic:
            - Free users: max 3 trips
            - Premium users: unlimited trips
            - Check is_premium flag on User model

        Implementation:
            1. Fetch user from database
            2. If user not found, raise 404 (shouldn't happen if auth works)
            3. If user is premium, return immediately (no limit)
            4. If user is free, count existing trips
            5. If count >= 3, raise 403 with upgrade message
        """
        user = self.db.query(User).filter(User.id == user_id).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Premium users have unlimited trips
        if user.is_premium:
            return

        # Free users: max 3 trips
        trip_count = self.get_user_trip_count(user_id)

        if trip_count >= 3:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Free tier limit reached. You can create up to 3 trips. Upgrade to Premium for unlimited trips."
            )

    def _check_trip_ownership(self, trip: Trip, user_id: UUID) -> None:
        """
        Verify user owns the trip.

        Args:
            trip: Trip object
            user_id: User ID to check

        Raises:
            HTTPException 403: If user does not own trip

        Security:
            - Prevents users from modifying/deleting others' trips
            - Must be called before any update/delete operation
        """
        if trip.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this trip"
            )

    def create_trip(self, user_id: UUID, trip_data: TripCreate) -> Trip:
        """
        Create new trip.

        Args:
            user_id: Owner user ID
            trip_data: Trip creation data

        Returns:
            Created Trip object

        Raises:
            HTTPException 403: If free tier limit reached

        Business Logic:
            1. Check free tier limit (raise if exceeded)
            2. Create trip with user_id
            3. Set default values (views_count=0, saves_count=0)
            4. Commit to database
            5. Return created trip

        Side Effects:
            - Inserts row into trips table
            - Auto-generates UUID primary key
            - Auto-sets created_at, updated_at timestamps
        """
        # Check free tier limit
        self._check_free_tier_limit(user_id)

        # Create trip instance
        trip = Trip(
            user_id=user_id,
            **trip_data.model_dump()
        )

        self.db.add(trip)
        self.db.commit()
        self.db.refresh(trip)

        return trip

    def list_user_trips(
        self,
        user_id: UUID,
        page: int = 1,
        page_size: int = 20,
        visibility_filter: Optional[str] = None
    ) -> TripListResponse:
        """
        List user's trips with pagination.

        Args:
            user_id: User UUID
            page: Page number (1-indexed)
            page_size: Number of items per page (max 100)
            visibility_filter: Optional filter by visibility

        Returns:
            TripListResponse with trips and pagination metadata

        Business Logic:
            - Only returns trips owned by user
            - Results ordered by created_at DESC (newest first)
            - Page size capped at 100 to prevent abuse
            - Total count calculated for pagination UI

        Query Pattern:
            1. Build base query: filter by user_id
            2. Apply optional visibility filter
            3. Get total count (before pagination)
            4. Apply pagination: offset + limit
            5. Return trips + metadata
        """
        # Cap page_size at 100
        page_size = min(page_size, 100)

        # Build base query
        query = self.db.query(Trip).filter(Trip.user_id == user_id)

        # Apply visibility filter if provided
        if visibility_filter:
            query = query.filter(Trip.visibility == visibility_filter)

        # Get total count
        total = query.count()

        # Calculate total pages
        total_pages = (total + page_size - 1) // page_size if total > 0 else 0

        # Apply pagination
        offset = (page - 1) * page_size
        trips = query.order_by(desc(Trip.created_at)).offset(offset).limit(page_size).all()

        return TripListResponse(
            trips=[TripResponse.model_validate(trip) for trip in trips],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )

    def update_trip(
        self,
        trip_id: UUID,
        user_id: UUID,
        trip_data: TripUpdate
    ) -> Trip:
        """
        Update existing trip.

        Args:
            trip_id: Trip UUID
            user_id: User ID (for ownership check)
            trip_data: Update data

        Returns:
            Updated Trip object

        Raises:
            HTTPException 404: Trip not found
            HTTPException 403: User does not own trip
            HTTPException 400: Invalid date combination

        Business Logic:
            1. Fetch trip by ID
            2. Check ownership
            3. Validate dates if updating
            4. Apply partial update (only provided fields)
            5. Commit to database

        Date Validation:
            - If updating only end_date, validate against existing start_date
            - If updating only start_date, validate against existing end_date
            - If updating both, schema validator handles it
        """
        # Fetch trip
        trip = self.get_trip_by_id(trip_id)
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        # Check ownership
        self._check_trip_ownership(trip, user_id)

        # Get update data (only fields provided)
        update_data = trip_data.model_dump(exclude_unset=True)

        # Validate dates if updating
        if 'end_date' in update_data and update_data['end_date'] is not None:
            # Check against current start_date if not also being updated
            start = update_data.get('start_date', trip.start_date)
            end = update_data['end_date']

            if start is not None and end < start:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="end_date must be after or equal to start_date"
                )

        if 'start_date' in update_data and update_data['start_date'] is not None:
            # Check against current end_date if not also being updated
            start = update_data['start_date']
            end = update_data.get('end_date', trip.end_date)

            if end is not None and end < start:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="end_date must be after or equal to start_date"
                )

        # Apply updates
        for field, value in update_data.items():
            setattr(trip, field, value)

        self.db.commit()
        self.db.refresh(trip)

        return trip

    def delete_trip(self, trip_id: UUID, user_id: UUID) -> None:
        """
        Delete trip.

        Args:
            trip_id: Trip UUID
            user_id: User ID (for ownership check)

        Raises:
            HTTPException 404: Trip not found
            HTTPException 403: User does not own trip

        Business Logic:
            1. Fetch trip by ID
            2. Check ownership
            3. Delete from database

        Side Effects:
            - Deletes trip row from database
            - Cascades to related records (places, routes) via FK constraints

        Note:
            - Database cascade rules handle related records
            - No need to manually delete places/routes
        """
        # Fetch trip
        trip = self.get_trip_by_id(trip_id)
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        # Check ownership
        self._check_trip_ownership(trip, user_id)

        # Delete
        self.db.delete(trip)
        self.db.commit()
