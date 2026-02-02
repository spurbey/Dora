"""
Tests for metadata API endpoints.

Validates:
- Trip metadata CRUD operations
- Place metadata CRUD operations
- Authentication and authorization
- Ownership validation
- Enum validation
- Cascade delete behavior
- Public/private access control
"""

from datetime import date
from decimal import Decimal
from uuid import uuid4

import pytest
from fastapi import status

from app.dependencies import get_current_user
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.trip_metadata import TripMetadata
from app.models.place_metadata import PlaceMetadata
from app.models.user import User


def override_current_user(user):
    """Override get_current_user dependency."""
    def _override():
        return user
    return _override


@pytest.fixture
def test_user(db):
    """Create a test user."""
    unique_id = str(uuid4())[:8]
    user = User(
        id=uuid4(),
        email=f"test_{unique_id}@example.com",
        username=f"test_{unique_id}",
        hashed_password="hashed",
        is_premium=False,
        is_verified=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def other_user(db):
    """Create another test user."""
    unique_id = str(uuid4())[:8]
    user = User(
        id=uuid4(),
        email=f"other_{unique_id}@example.com",
        username=f"other_{unique_id}",
        hashed_password="hashed",
        is_premium=False,
        is_verified=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def test_trip(db, test_user):
    """Create a test trip."""
    trip = Trip(
        user_id=test_user.id,
        title="Test Trip",
        description="A test trip",
        visibility="private",
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def public_trip(db, test_user):
    """Create a public test trip."""
    trip = Trip(
        user_id=test_user.id,
        title="Public Trip",
        description="A public trip",
        visibility="public",
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def test_place(db, test_user, test_trip):
    """Create a test place."""
    place = TripPlace(
        trip_id=test_trip.id,
        user_id=test_user.id,
        name="Test Place",
        location="SRID=4326;POINT(77.5946 12.9716)",  # PostGIS format
        lat=12.9716,
        lng=77.5946,
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


@pytest.fixture
def auth_as(fastapi_app):
    """Authenticate as a specific user."""
    def _set(user):
        fastapi_app.dependency_overrides[get_current_user] = override_current_user(user)
    return _set


# ============================================================================
# TRIP METADATA TESTS
# ============================================================================

def test_create_trip_metadata(client, db, test_user, test_trip, auth_as):
    """Test creating trip metadata."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={
            "traveler_type": ["solo", "adventure"],
            "age_group": "gen-z",
            "budget_category": "budget",
            "activity_focus": ["hiking", "photography"],
            "is_discoverable": True,
            "tags": ["monsoon", "western-ghats"]
        }
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["trip_id"] == str(test_trip.id)
    assert data["traveler_type"] == ["solo", "adventure"]
    assert data["age_group"] == "gen-z"
    assert data["budget_category"] == "budget"
    assert data["activity_focus"] == ["hiking", "photography"]
    assert data["is_discoverable"] is True
    assert data["tags"] == ["monsoon", "western-ghats"]
    assert data["quality_score"] == 0.0
    assert "created_at" in data
    assert "updated_at" in data


def test_create_trip_metadata_minimal(client, db, test_user, test_trip, auth_as):
    """Test creating trip metadata with minimal fields."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={}
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["trip_id"] == str(test_trip.id)
    assert data["is_discoverable"] is False
    assert data["quality_score"] == 0.0


def test_create_trip_metadata_trip_not_found(client, test_user, auth_as):
    """Test creating metadata for non-existent trip."""
    auth_as(test_user)

    fake_trip_id = uuid4()
    response = client.post(
        f"/api/v1/trips/{fake_trip_id}/metadata",
        json={}
    )

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Trip not found" in response.json()["detail"]


def test_create_trip_metadata_not_owner(client, db, test_user, other_user, test_trip, auth_as):
    """Test creating metadata when not trip owner."""
    auth_as(other_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={}
    )

    assert response.status_code == status.HTTP_403_FORBIDDEN
    assert "don't own" in response.json()["detail"]


def test_create_trip_metadata_already_exists(client, db, test_user, test_trip, auth_as):
    """Test creating metadata when it already exists."""
    auth_as(test_user)

    # Create first metadata
    metadata = TripMetadata(trip_id=test_trip.id)
    db.add(metadata)
    db.commit()

    # Try to create again
    response = client.post(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={}
    )

    assert response.status_code == status.HTTP_409_CONFLICT
    assert "already exists" in response.json()["detail"]


def test_create_trip_metadata_invalid_enum(client, test_user, test_trip, auth_as):
    """Test creating metadata with invalid enum values."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={"age_group": "invalid"}
    )

    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_get_trip_metadata(client, db, test_user, test_trip, auth_as):
    """Test getting trip metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = TripMetadata(
        trip_id=test_trip.id,
        traveler_type=["solo"],
        is_discoverable=True
    )
    db.add(metadata)
    db.commit()

    # Get metadata
    response = client.get(f"/api/v1/trips/{test_trip.id}/metadata")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["trip_id"] == str(test_trip.id)
    assert data["traveler_type"] == ["solo"]


def test_get_trip_metadata_not_found(client, test_user, test_trip, auth_as):
    """Test getting non-existent metadata."""
    auth_as(test_user)

    response = client.get(f"/api/v1/trips/{test_trip.id}/metadata")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Metadata not found" in response.json()["detail"]


def test_get_trip_metadata_public_access(client, db, test_user, other_user, public_trip, auth_as):
    """Test getting metadata for public trip."""
    # Create metadata
    metadata = TripMetadata(
        trip_id=public_trip.id,
        traveler_type=["family"],
        is_discoverable=True
    )
    db.add(metadata)
    db.commit()

    # Access as other user
    auth_as(other_user)
    response = client.get(f"/api/v1/trips/{public_trip.id}/metadata")

    assert response.status_code == status.HTTP_200_OK


def test_get_trip_metadata_private_access_denied(client, db, test_user, other_user, test_trip, auth_as):
    """Test getting metadata for private trip as non-owner."""
    # Create metadata
    metadata = TripMetadata(trip_id=test_trip.id)
    db.add(metadata)
    db.commit()

    # Access as other user
    auth_as(other_user)
    response = client.get(f"/api/v1/trips/{test_trip.id}/metadata")

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_update_trip_metadata(client, db, test_user, test_trip, auth_as):
    """Test updating trip metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = TripMetadata(
        trip_id=test_trip.id,
        traveler_type=["solo"],
        is_discoverable=False
    )
    db.add(metadata)
    db.commit()

    # Update metadata
    response = client.patch(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={
            "is_discoverable": True,
            "tags": ["beach", "relaxation"]
        }
    )

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["is_discoverable"] is True
    assert data["tags"] == ["beach", "relaxation"]
    assert data["traveler_type"] == ["solo"]  # Unchanged


def test_update_trip_metadata_not_owner(client, db, test_user, other_user, test_trip, auth_as):
    """Test updating metadata when not owner."""
    # Create metadata
    metadata = TripMetadata(trip_id=test_trip.id)
    db.add(metadata)
    db.commit()

    # Try to update as other user
    auth_as(other_user)
    response = client.patch(
        f"/api/v1/trips/{test_trip.id}/metadata",
        json={"is_discoverable": True}
    )

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_delete_trip_metadata(client, db, test_user, test_trip, auth_as):
    """Test deleting trip metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = TripMetadata(trip_id=test_trip.id)
    db.add(metadata)
    db.commit()

    # Delete metadata
    response = client.delete(f"/api/v1/trips/{test_trip.id}/metadata")

    assert response.status_code == status.HTTP_204_NO_CONTENT

    # Verify deleted
    metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == test_trip.id).first()
    assert metadata is None

    # Verify trip still exists
    trip = db.query(Trip).filter(Trip.id == test_trip.id).first()
    assert trip is not None


def test_delete_trip_cascades_metadata(db, test_user, test_trip):
    """Test that deleting trip cascades to metadata."""
    # Create metadata
    metadata = TripMetadata(trip_id=test_trip.id)
    db.add(metadata)
    db.commit()

    # Delete trip
    db.delete(test_trip)
    db.commit()

    # Verify metadata was also deleted
    metadata = db.query(TripMetadata).filter(TripMetadata.trip_id == test_trip.id).first()
    assert metadata is None


# ============================================================================
# PLACE METADATA TESTS
# ============================================================================

def test_create_place_metadata(client, db, test_user, test_place, auth_as):
    """Test creating place metadata."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/places/{test_place.id}/metadata",
        json={
            "component_type": "activity",
            "experience_tags": ["adventurous", "peaceful"],
            "best_for": ["solo-travelers", "photographers"],
            "budget_per_person": 50.0,
            "duration_hours": 3.5,
            "difficulty_rating": 3,
            "physical_demand": "medium",
            "best_time": "sunrise",
            "is_public": True
        }
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["place_id"] == str(test_place.id)
    assert data["component_type"] == "activity"
    assert data["experience_tags"] == ["adventurous", "peaceful"]
    assert data["best_for"] == ["solo-travelers", "photographers"]
    assert float(data["budget_per_person"]) == 50.0
    assert data["duration_hours"] == 3.5
    assert data["difficulty_rating"] == 3
    assert data["physical_demand"] == "medium"
    assert data["best_time"] == "sunrise"
    assert data["is_public"] is True
    assert data["contribution_score"] == 0.0


def test_create_place_metadata_minimal(client, test_user, test_place, auth_as):
    """Test creating place metadata with minimal fields."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/places/{test_place.id}/metadata",
        json={}
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["component_type"] == "place"  # Default
    assert data["is_public"] is False


def test_create_place_metadata_invalid_difficulty(client, test_user, test_place, auth_as):
    """Test creating metadata with invalid difficulty rating."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/places/{test_place.id}/metadata",
        json={"difficulty_rating": 6}  # Invalid (must be 1-5)
    )

    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_place_metadata_negative_budget(client, test_user, test_place, auth_as):
    """Test creating metadata with negative budget."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/places/{test_place.id}/metadata",
        json={"budget_per_person": -10}
    )

    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_get_place_metadata(client, db, test_user, test_place, auth_as):
    """Test getting place metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = PlaceMetadata(
        place_id=test_place.id,
        component_type="food",
        is_public=True
    )
    db.add(metadata)
    db.commit()

    # Get metadata
    response = client.get(f"/api/v1/places/{test_place.id}/metadata")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["place_id"] == str(test_place.id)
    assert data["component_type"] == "food"


def test_update_place_metadata(client, db, test_user, test_place, auth_as):
    """Test updating place metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = PlaceMetadata(
        place_id=test_place.id,
        component_type="place",
        is_public=False
    )
    db.add(metadata)
    db.commit()

    # Update metadata
    response = client.patch(
        f"/api/v1/places/{test_place.id}/metadata",
        json={
            "component_type": "accommodation",
            "is_public": True,
            "best_for": ["families", "couples"]
        }
    )

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["component_type"] == "accommodation"
    assert data["is_public"] is True
    assert data["best_for"] == ["families", "couples"]


def test_delete_place_metadata(client, db, test_user, test_place, auth_as):
    """Test deleting place metadata."""
    auth_as(test_user)

    # Create metadata
    metadata = PlaceMetadata(place_id=test_place.id)
    db.add(metadata)
    db.commit()

    # Delete metadata
    response = client.delete(f"/api/v1/places/{test_place.id}/metadata")

    assert response.status_code == status.HTTP_204_NO_CONTENT

    # Verify deleted
    metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == test_place.id).first()
    assert metadata is None

    # Verify place still exists
    place = db.query(TripPlace).filter(TripPlace.id == test_place.id).first()
    assert place is not None


def test_delete_place_cascades_metadata(db, test_user, test_place):
    """Test that deleting place cascades to metadata."""
    # Create metadata
    metadata = PlaceMetadata(place_id=test_place.id)
    db.add(metadata)
    db.commit()

    # Delete place
    db.delete(test_place)
    db.commit()

    # Verify metadata was also deleted
    metadata = db.query(PlaceMetadata).filter(PlaceMetadata.place_id == test_place.id).first()
    assert metadata is None
