"""
Tests for place service layer.

This module validates the business logic of:
- Place CRUD operations
- PostGIS Geography conversion
- Geospatial queries (nearby places)
- Trip ownership validation
- Order management

Focus Areas:
- Geography conversion (lat/lng to PostGIS POINT)
- Geospatial queries (ST_DWithin, ST_Distance)
- Ownership validation
- Order in trip management

All tests use transactional database sessions.
"""

import pytest
from uuid import uuid4
from datetime import date

from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.services.place_service import PlaceService
from app.schemas.place import PlaceCreate, PlaceUpdate
from fastapi import HTTPException


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
        title="Test Trip to Paris",
        description="Exploring the City of Light",
        visibility="private"
    )

    db.add(trip)
    db.commit()
    db.refresh(trip)

    return trip


@pytest.fixture
def sample_place(db, test_user, sample_trip):
    """
    Create a sample place for testing.

    Parameters:
    ----------
    db : Session
        Test database session.

    test_user : User
        Owner of the place.

    sample_trip : Trip
        Parent trip.

    Returns:
    -------
    TripPlace
        Place instance.
    """
    # Eiffel Tower coordinates
    location_wkt = "SRID=4326;POINT(2.2945 48.8584)"

    place = TripPlace(
        trip_id=sample_trip.id,
        user_id=test_user.id,
        name="Eiffel Tower",
        place_type="attraction",
        location=location_wkt,
        lat=48.8584,
        lng=2.2945,
        user_notes="Must visit!",
        user_rating=5,
        order_in_trip=0
    )

    db.add(place)
    db.commit()
    db.refresh(place)

    return place


def test_get_place_by_id(db, sample_place):
    """
    Test fetching place by ID.

    Verifies that:
    - Place can be fetched by ID
    - Returns None for non-existent ID
    """
    service = PlaceService(db)

    # Fetch existing place
    place = service.get_place_by_id(sample_place.id)
    assert place is not None
    assert place.id == sample_place.id
    assert place.name == "Eiffel Tower"
    assert place.lat == 48.8584
    assert place.lng == 2.2945

    # Fetch non-existent place
    non_existent = service.get_place_by_id(uuid4())
    assert non_existent is None


def test_create_place_success(db, test_user, sample_trip):
    """
    Test creating a place with Geography conversion.

    Verifies that:
    - Place is created successfully
    - lat/lng converted to PostGIS Geography POINT
    - user_id is set correctly
    - order_in_trip auto-set to 0 (first place)
    """
    service = PlaceService(db)

    # Louvre Museum coordinates
    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Louvre Museum",
        place_type="museum",
        lat=48.8606,
        lng=2.3376,
        user_notes="See the Mona Lisa",
        user_rating=5
    )

    place = service.create_place(test_user.id, place_data)

    assert place.id is not None
    assert place.trip_id == sample_trip.id
    assert place.user_id == test_user.id
    assert place.name == "Louvre Museum"
    assert place.lat == 48.8606
    assert place.lng == 2.3376
    assert place.location is not None  # Geography column set
    assert place.order_in_trip == 0  # Auto-set
    assert place.created_at is not None


def test_create_place_with_explicit_order(db, test_user, sample_trip, sample_place):
    """
    Test creating a place with explicit order.

    Verifies that:
    - order_in_trip can be explicitly set
    - Does not auto-increment
    """
    service = PlaceService(db)

    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Arc de Triomphe",
        place_type="monument",
        lat=48.8738,
        lng=2.2950,
        order_in_trip=5  # Explicit order
    )

    place = service.create_place(test_user.id, place_data)

    assert place.order_in_trip == 5


def test_create_place_auto_order(db, test_user, sample_trip, sample_place):
    """
    Test auto-order assignment for new places.

    Verifies that:
    - New place gets max(order_in_trip) + 1
    - Works with existing places
    """
    service = PlaceService(db)

    # sample_place has order_in_trip=0
    # New place should get order_in_trip=1

    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Notre-Dame",
        place_type="church",
        lat=48.8530,
        lng=2.3499
    )

    place = service.create_place(test_user.id, place_data)

    assert place.order_in_trip == 1  # max(0) + 1


def test_create_place_trip_not_found(db, test_user):
    """
    Test creating place for non-existent trip.

    Verifies that:
    - Raises 404 if trip doesn't exist
    """
    service = PlaceService(db)

    place_data = PlaceCreate(
        trip_id=uuid4(),  # Non-existent trip
        name="Test Place",
        lat=48.8584,
        lng=2.2945
    )

    with pytest.raises(HTTPException) as exc_info:
        service.create_place(test_user.id, place_data)

    assert exc_info.value.status_code == 404
    assert "Trip not found" in exc_info.value.detail


def test_create_place_not_owner(db, test_user, premium_user, sample_trip):
    """
    Test creating place in someone else's trip.

    Verifies that:
    - Raises 403 if user doesn't own trip
    """
    service = PlaceService(db)

    # sample_trip is owned by test_user
    # Try to add place as premium_user

    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Unauthorized Place",
        lat=48.8584,
        lng=2.2945
    )

    with pytest.raises(HTTPException) as exc_info:
        service.create_place(premium_user.id, place_data)

    assert exc_info.value.status_code == 403
    assert "permission" in exc_info.value.detail.lower()


def test_list_trip_places(db, test_user, sample_trip, sample_place):
    """
    Test listing places for a trip.

    Verifies that:
    - Returns places ordered by order_in_trip
    - Includes total count
    """
    service = PlaceService(db)

    # Add another place
    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Louvre Museum",
        lat=48.8606,
        lng=2.3376,
        order_in_trip=1
    )
    service.create_place(test_user.id, place_data)

    # List places
    result = service.list_trip_places(sample_trip.id, test_user.id)

    assert len(result.places) == 2
    assert result.total == 2
    assert result.trip_id == sample_trip.id
    # Verify order
    assert result.places[0].name == "Eiffel Tower"  # order=0
    assert result.places[1].name == "Louvre Museum"  # order=1


def test_list_trip_places_empty(db, test_user, sample_trip):
    """
    Test listing places for trip with no places.

    Verifies that:
    - Returns empty list
    - total = 0
    """
    service = PlaceService(db)

    result = service.list_trip_places(sample_trip.id, test_user.id)

    assert len(result.places) == 0
    assert result.total == 0


def test_update_place_success(db, test_user, sample_place):
    """
    Test updating place fields.

    Verifies that:
    - Fields can be updated
    - Changes persist in database
    """
    service = PlaceService(db)

    update_data = PlaceUpdate(
        name="Eiffel Tower - Updated",
        user_notes="Visited at night, beautiful!",
        user_rating=5
    )

    updated_place = service.update_place(sample_place.id, test_user.id, update_data)

    assert updated_place.name == "Eiffel Tower - Updated"
    assert updated_place.user_notes == "Visited at night, beautiful!"
    assert updated_place.id == sample_place.id


def test_update_place_coordinates(db, test_user, sample_place):
    """
    Test updating place coordinates.

    Verifies that:
    - lat/lng can be updated
    - Geography column is recalculated
    """
    service = PlaceService(db)

    # Move to slightly different location
    update_data = PlaceUpdate(
        lat=48.8600,
        lng=2.2950
    )

    updated_place = service.update_place(sample_place.id, test_user.id, update_data)

    assert updated_place.lat == 48.8600
    assert updated_place.lng == 2.2950
    assert updated_place.location is not None  # Geography recalculated


def test_update_place_not_owner(db, premium_user, sample_place):
    """
    Test updating someone else's place.

    Verifies that:
    - Raises 403 if user doesn't own trip
    """
    service = PlaceService(db)

    update_data = PlaceUpdate(name="Hacked Name")

    with pytest.raises(HTTPException) as exc_info:
        service.update_place(sample_place.id, premium_user.id, update_data)

    assert exc_info.value.status_code == 403


def test_delete_place_success(db, test_user, sample_place):
    """
    Test deleting a place.

    Verifies that:
    - Place is deleted from database
    - Subsequent fetch returns None
    """
    service = PlaceService(db)

    # Delete place
    service.delete_place(sample_place.id, test_user.id)

    # Verify place no longer exists
    place = service.get_place_by_id(sample_place.id)
    assert place is None


def test_delete_place_not_owner(db, premium_user, sample_place):
    """
    Test deleting someone else's place.

    Verifies that:
    - Raises 403 if user doesn't own trip
    """
    service = PlaceService(db)

    with pytest.raises(HTTPException) as exc_info:
        service.delete_place(sample_place.id, premium_user.id)

    assert exc_info.value.status_code == 403


def test_get_places_near_location(db, test_user, sample_trip):
    """
    Test PostGIS geospatial query for nearby places.

    Verifies that:
    - ST_DWithin works correctly
    - Returns places within radius
    - Orders by distance
    """
    service = PlaceService(db)

    # Create places at known locations in Paris
    places_data = [
        # Eiffel Tower
        PlaceCreate(trip_id=sample_trip.id, name="Eiffel Tower", lat=48.8584, lng=2.2945),
        # Louvre (about 3.5km from Eiffel Tower)
        PlaceCreate(trip_id=sample_trip.id, name="Louvre Museum", lat=48.8606, lng=2.3376),
        # Arc de Triomphe (about 2km from Eiffel Tower)
        PlaceCreate(trip_id=sample_trip.id, name="Arc de Triomphe", lat=48.8738, lng=2.2950),
    ]

    for place_data in places_data:
        service.create_place(test_user.id, place_data)

    # Search near Eiffel Tower with 3km radius
    # Should find: Eiffel Tower (0km), Arc de Triomphe (~2km)
    # Should NOT find: Louvre (~3.5km)
    nearby = service.get_places_near_location(
        lat=48.8584,
        lng=2.2945,
        radius_km=3.0,
        user_id=test_user.id
    )

    assert len(nearby) == 2
    # Verify ordered by distance (closest first)
    assert nearby[0].name == "Eiffel Tower"
    assert nearby[1].name == "Arc de Triomphe"


def test_get_places_near_location_different_user(db, test_user, premium_user, sample_trip):
    """
    Test nearby query filters by user_id.

    Verifies that:
    - Only returns places owned by specified user
    - Does not return other users' places
    """
    service = PlaceService(db)

    # Create test_user's place
    place_data = PlaceCreate(
        trip_id=sample_trip.id,
        name="Test User Place",
        lat=48.8584,
        lng=2.2945
    )
    service.create_place(test_user.id, place_data)

    # Search as test_user
    nearby = service.get_places_near_location(
        lat=48.8584,
        lng=2.2945,
        radius_km=5.0,
        user_id=test_user.id
    )

    assert len(nearby) == 1
    assert nearby[0].name == "Test User Place"

    # Search as premium_user (no places)
    nearby_premium = service.get_places_near_location(
        lat=48.8584,
        lng=2.2945,
        radius_km=5.0,
        user_id=premium_user.id
    )

    assert len(nearby_premium) == 0


def test_coordinate_validation():
    """
    Test Pydantic schema validation for coordinates.

    Verifies that:
    - lat must be -90 to 90
    - lng must be -180 to 180
    """
    from pydantic import ValidationError

    # Valid coordinates
    valid = PlaceCreate(
        trip_id=uuid4(),
        name="Valid Place",
        lat=48.8584,
        lng=2.2945
    )
    assert valid.lat == 48.8584
    assert valid.lng == 2.2945

    # Invalid lat (out of range)
    with pytest.raises(ValidationError):
        PlaceCreate(
            trip_id=uuid4(),
            name="Invalid Lat",
            lat=91.0,  # > 90
            lng=2.2945
        )

    # Invalid lng (out of range)
    with pytest.raises(ValidationError):
        PlaceCreate(
            trip_id=uuid4(),
            name="Invalid Lng",
            lat=48.8584,
            lng=181.0  # > 180
        )


def test_rating_validation():
    """
    Test rating validation.

    Verifies that:
    - user_rating must be 1-5 if provided
    - None is allowed
    """
    from pydantic import ValidationError

    # Valid ratings
    for rating in [1, 2, 3, 4, 5]:
        place = PlaceCreate(
            trip_id=uuid4(),
            name="Test",
            lat=48.8584,
            lng=2.2945,
            user_rating=rating
        )
        assert place.user_rating == rating

    # Invalid rating (Pydantic V2 raises ValidationError)
    with pytest.raises(ValidationError) as exc_info:
        PlaceCreate(
            trip_id=uuid4(),
            name="Test",
            lat=48.8584,
            lng=2.2945,
            user_rating=6  # > 5
        )
    # Check that error is about rating constraint
    assert "user_rating" in str(exc_info.value)
