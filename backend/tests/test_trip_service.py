"""
Tests for trip service layer.

This module validates the business logic of:
- Trip creation with free tier limits
- Trip listing with pagination
- Trip updates with ownership checks
- Trip deletion with ownership checks
- Date validation

Focus Areas:
- Free tier limit enforcement (3 trips)
- Ownership validation
- Date validation (end >= start)
- Pagination correctness

All tests use transactional database sessions.
"""

import pytest
from uuid import uuid4
from datetime import date

from app.models.user import User
from app.models.trip import Trip
from app.services.trip_service import TripService
from app.schemas.trip import TripCreate, TripUpdate
from fastapi import HTTPException


@pytest.fixture
def premium_user(db):
    """
    Create premium test user.

    Parameters:
    ----------
    db : Session
        Test database session.

    Returns:
    -------
    User
        Premium user instance.
    """
    unique_id = str(uuid4())[:8]

    user = User(
        id=uuid4(),
        email=f"premium_{unique_id}@example.com",
        username=f"premium_{unique_id}",
        hashed_password="hashed",
        is_premium=True,  # Premium status
        is_verified=True
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@pytest.fixture
def sample_trip(db, test_user):
    """
    Create a sample trip for testing.

    Parameters:
    ----------
    db : Session
        Test database session.

    test_user : User
        Owner of the trip.

    Returns:
    -------
    Trip
        Trip instance.
    """
    trip = Trip(
        user_id=test_user.id,
        title="Test Trip",
        description="Test Description",
        visibility="private",
        start_date=date(2025, 1, 1),
        end_date=date(2025, 1, 10)
    )

    db.add(trip)
    db.commit()
    db.refresh(trip)

    return trip


def test_get_trip_by_id(db, sample_trip):
    """
    Test fetching trip by ID.

    Verifies that:
    - Trip can be fetched by ID
    - Returns None for non-existent ID
    """
    service = TripService(db)

    # Fetch existing trip
    trip = service.get_trip_by_id(sample_trip.id)
    assert trip is not None
    assert trip.id == sample_trip.id
    assert trip.title == "Test Trip"

    # Fetch non-existent trip
    non_existent = service.get_trip_by_id(uuid4())
    assert non_existent is None


def test_create_trip_success(db, test_user):
    """
    Test creating a trip as free user (first trip).

    Verifies that:
    - Trip is created successfully
    - user_id is set correctly
    - Default values are applied
    """
    service = TripService(db)

    trip_data = TripCreate(
        title="My First Trip",
        description="A wonderful journey",
        start_date=date(2025, 2, 1),
        end_date=date(2025, 2, 15),
        visibility="private"
    )

    trip = service.create_trip(test_user.id, trip_data)

    assert trip.id is not None
    assert trip.user_id == test_user.id
    assert trip.title == "My First Trip"
    assert trip.description == "A wonderful journey"
    assert trip.views_count == 0
    assert trip.saves_count == 0
    assert trip.created_at is not None


def test_create_trip_free_tier_limit(db, test_user):
    """
    Test free tier limit enforcement (3 trips max).

    Verifies that:
    - Free user can create 3 trips
    - 4th trip creation raises 403 error
    - Error message mentions upgrade
    """
    service = TripService(db)

    # Create 3 trips
    for i in range(3):
        trip_data = TripCreate(title=f"Trip {i+1}")
        service.create_trip(test_user.id, trip_data)

    # Verify count
    count = service.get_user_trip_count(test_user.id)
    assert count == 3

    # Attempt to create 4th trip
    trip_data = TripCreate(title="Trip 4")

    with pytest.raises(HTTPException) as exc_info:
        service.create_trip(test_user.id, trip_data)

    assert exc_info.value.status_code == 403
    assert "Free tier limit reached" in exc_info.value.detail
    assert "Upgrade to Premium" in exc_info.value.detail


def test_create_trip_premium_unlimited(db, premium_user):
    """
    Test premium users can create unlimited trips.

    Verifies that:
    - Premium user can create 5+ trips
    - No limit is enforced
    """
    service = TripService(db)

    # Create 5 trips
    for i in range(5):
        trip_data = TripCreate(title=f"Premium Trip {i+1}")
        trip = service.create_trip(premium_user.id, trip_data)
        assert trip.id is not None

    # Verify count
    count = service.get_user_trip_count(premium_user.id)
    assert count == 5


def test_list_user_trips_pagination(db, premium_user):
    """
    Test trip listing with pagination.

    Verifies that:
    - Pagination works correctly
    - Total count is accurate
    - Total pages calculated correctly
    """
    service = TripService(db)

    # Create 25 trips (using premium user to avoid free tier limit)
    for i in range(25):
        trip_data = TripCreate(title=f"Trip {i+1}")
        service.create_trip(premium_user.id, trip_data)

    # Fetch page 1 (page_size=10)
    result = service.list_user_trips(premium_user.id, page=1, page_size=10)

    assert len(result.trips) == 10
    assert result.total == 25
    assert result.page == 1
    assert result.page_size == 10
    assert result.total_pages == 3

    # Fetch page 3 (should have 5 trips)
    result = service.list_user_trips(premium_user.id, page=3, page_size=10)

    assert len(result.trips) == 5
    assert result.total == 25
    assert result.page == 3


def test_list_user_trips_empty(db, test_user):
    """
    Test listing trips for user with no trips.

    Verifies that:
    - Empty list is returned
    - Total count is 0
    """
    service = TripService(db)

    result = service.list_user_trips(test_user.id)

    assert len(result.trips) == 0
    assert result.total == 0
    assert result.total_pages == 0


def test_update_trip_success(db, sample_trip, test_user):
    """
    Test updating trip fields.

    Verifies that:
    - Title and description can be updated
    - Changes persist in database
    """
    service = TripService(db)

    update_data = TripUpdate(
        title="Updated Title",
        description="Updated Description"
    )

    updated_trip = service.update_trip(sample_trip.id, test_user.id, update_data)

    assert updated_trip.title == "Updated Title"
    assert updated_trip.description == "Updated Description"
    assert updated_trip.id == sample_trip.id


def test_update_trip_ownership_check(db, sample_trip, premium_user):
    """
    Test ownership check prevents unauthorized updates.

    Verifies that:
    - Different user cannot update trip
    - 403 error is raised
    """
    service = TripService(db)

    update_data = TripUpdate(title="Hacked Title")

    with pytest.raises(HTTPException) as exc_info:
        service.update_trip(sample_trip.id, premium_user.id, update_data)

    assert exc_info.value.status_code == 403
    assert "permission" in exc_info.value.detail.lower()


def test_update_trip_invalid_dates_end_before_start(db, sample_trip, test_user):
    """
    Test date validation on update.

    Verifies that:
    - Updating end_date to before start_date fails
    - 400 error is raised
    """
    service = TripService(db)

    # sample_trip has start=2025-01-01, end=2025-01-10
    # Try to update end_date to before start_date
    update_data = TripUpdate(end_date=date(2024, 12, 31))

    with pytest.raises(HTTPException) as exc_info:
        service.update_trip(sample_trip.id, test_user.id, update_data)

    assert exc_info.value.status_code == 400
    assert "end_date must be after or equal to start_date" in exc_info.value.detail


def test_update_trip_valid_dates(db, sample_trip, test_user):
    """
    Test valid date updates.

    Verifies that:
    - Updating end_date to valid date succeeds
    """
    service = TripService(db)

    # sample_trip has start=2025-01-01, end=2025-01-10
    # Update end_date to later date
    update_data = TripUpdate(end_date=date(2025, 1, 15))

    updated_trip = service.update_trip(sample_trip.id, test_user.id, update_data)

    assert updated_trip.end_date == date(2025, 1, 15)


def test_delete_trip_success(db, sample_trip, test_user):
    """
    Test deleting a trip.

    Verifies that:
    - Trip is deleted from database
    - Subsequent fetch returns None
    """
    service = TripService(db)

    # Delete trip
    service.delete_trip(sample_trip.id, test_user.id)

    # Verify trip no longer exists
    trip = service.get_trip_by_id(sample_trip.id)
    assert trip is None


def test_delete_trip_ownership_check(db, sample_trip, premium_user):
    """
    Test ownership check prevents unauthorized deletion.

    Verifies that:
    - Different user cannot delete trip
    - 403 error is raised
    """
    service = TripService(db)

    with pytest.raises(HTTPException) as exc_info:
        service.delete_trip(sample_trip.id, premium_user.id)

    assert exc_info.value.status_code == 403
    assert "permission" in exc_info.value.detail.lower()


def test_get_user_trip_count(db, test_user):
    """
    Test trip count calculation.

    Verifies that:
    - Count is accurate after create
    - Count decreases after delete
    """
    service = TripService(db)

    # Initial count should be 0
    count = service.get_user_trip_count(test_user.id)
    assert count == 0

    # Create 3 trips
    for i in range(3):
        trip_data = TripCreate(title=f"Trip {i+1}")
        service.create_trip(test_user.id, trip_data)

    count = service.get_user_trip_count(test_user.id)
    assert count == 3

    # Delete one trip
    trips = db.query(Trip).filter(Trip.user_id == test_user.id).all()
    service.delete_trip(trips[0].id, test_user.id)

    count = service.get_user_trip_count(test_user.id)
    assert count == 2


def test_date_validation_both_dates():
    """
    Test Pydantic schema validation for dates.

    Verifies that:
    - Creating trip with end < start raises validation error
    """
    with pytest.raises(ValueError) as exc_info:
        TripCreate(
            title="Invalid Trip",
            start_date=date(2025, 1, 10),
            end_date=date(2025, 1, 1)  # Before start
        )

    assert "end_date must be after or equal to start_date" in str(exc_info.value)


def test_visibility_validation():
    """
    Test visibility enum validation.

    Verifies that:
    - Invalid visibility value raises error
    - Valid values succeed
    """
    # Invalid visibility
    with pytest.raises(ValueError) as exc_info:
        TripCreate(title="Test", visibility="invalid")

    assert "Visibility must be one of" in str(exc_info.value)

    # Valid visibility values
    for visibility in ["private", "unlisted", "public"]:
        trip = TripCreate(title="Test", visibility=visibility)
        assert trip.visibility == visibility
