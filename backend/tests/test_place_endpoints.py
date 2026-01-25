"""
Tests for place API endpoints.

Validates:
- Authentication and authorization
- CRUD operations for places
- Order management
- Visibility-based access control
"""

from uuid import uuid4

import pytest
from fastapi import HTTPException, status

from app.dependencies import get_current_user
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.user import User


def override_current_user(user):
    def _override():
        return user
    return _override


def create_trip(db, user_id, title="Trip", visibility="private"):
    trip = Trip(
        user_id=user_id,
        title=title,
        visibility=visibility,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def create_place(
    db,
    trip_id,
    user_id,
    name="Place",
    lat=12.9716,
    lng=77.5946,
    order_in_trip=None,
):
    place = TripPlace(
        trip_id=trip_id,
        user_id=user_id,
        name=name,
        lat=lat,
        lng=lng,
        location=f"SRID=4326;POINT({lng} {lat})",
        order_in_trip=order_in_trip,
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


@pytest.fixture
def other_user(db):
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
def auth_as(fastapi_app):
    def _set(user):
        fastapi_app.dependency_overrides[get_current_user] = (
            override_current_user(user)
        )
    yield _set
    fastapi_app.dependency_overrides.clear()


@pytest.fixture
def unauthorized(fastapi_app):
    def _override():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )
    fastapi_app.dependency_overrides[get_current_user] = _override
    yield
    fastapi_app.dependency_overrides.clear()


def test_create_place_success(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)

    payload = {
        "trip_id": str(trip.id),
        "name": "Eiffel Tower",
        "lat": 48.8584,
        "lng": 2.2945,
        "place_type": "attraction",
        "user_notes": "Must visit at night",
        "user_rating": 5,
        "visit_date": "2025-06-15",
    }

    response = client.post("/api/v1/places", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["trip_id"] == str(trip.id)
    assert data["user_id"] == str(test_user.id)
    assert data["order_in_trip"] == 0
    assert data["lat"] == 48.8584
    assert data["lng"] == 2.2945


def test_create_place_unauthorized(client, unauthorized):
    response = client.post("/api/v1/places", json={})
    assert response.status_code == 401


def test_create_place_trip_not_found(client, test_user, auth_as):
    auth_as(test_user)
    payload = {
        "trip_id": str(uuid4()),
        "name": "Nowhere",
        "lat": 10.0,
        "lng": 10.0,
    }
    response = client.post("/api/v1/places", json=payload)
    assert response.status_code == 404
    assert response.json()["detail"] == "Trip not found"


def test_create_place_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, other_user.id)
    auth_as(test_user)

    payload = {
        "trip_id": str(trip.id),
        "name": "Private Place",
        "lat": 10.0,
        "lng": 10.0,
    }
    response = client.post("/api/v1/places", json=payload)
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_create_place_invalid_rating(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)

    payload = {
        "trip_id": str(trip.id),
        "name": "Bad Rating",
        "lat": 10.0,
        "lng": 10.0,
        "user_rating": 7,
    }
    response = client.post("/api/v1/places", json=payload)
    assert response.status_code == 422


def test_list_places_empty(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)

    response = client.get(f"/api/v1/places?trip_id={trip.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["places"] == []
    assert data["total"] == 0
    assert data["trip_id"] == str(trip.id)


def test_list_places_ordered(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)

    create_place(db, trip.id, test_user.id, name="Second", order_in_trip=1)
    create_place(db, trip.id, test_user.id, name="First", order_in_trip=0)

    response = client.get(f"/api/v1/places?trip_id={trip.id}")
    assert response.status_code == 200
    names = [place["name"] for place in response.json()["places"]]
    assert names == ["First", "Second"]


def test_list_places_private_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="private")
    create_place(db, trip.id, test_user.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/places?trip_id={trip.id}")
    assert response.status_code == 403


def test_list_places_public_non_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="public")
    create_place(db, trip.id, test_user.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/places?trip_id={trip.id}")
    assert response.status_code == 200
    assert response.json()["total"] == 1


def test_list_places_unauthorized(client, unauthorized):
    response = client.get(f"/api/v1/places?trip_id={uuid4()}")
    assert response.status_code == 401


def test_get_place_owner(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id, name="Owner Place")

    response = client.get(f"/api/v1/places/{place.id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Owner Place"


def test_get_place_public_non_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="public")
    place = create_place(db, trip.id, test_user.id, name="Public Place")

    auth_as(other_user)
    response = client.get(f"/api/v1/places/{place.id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Public Place"


def test_get_place_private_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="private")
    place = create_place(db, trip.id, test_user.id, name="Private Place")

    auth_as(other_user)
    response = client.get(f"/api/v1/places/{place.id}")
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_get_place_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.get(f"/api/v1/places/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found"


def test_get_place_unauthorized(client, unauthorized):
    response = client.get(f"/api/v1/places/{uuid4()}")
    assert response.status_code == 401


def test_update_place_success(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id, name="Old Name")

    payload = {"name": "New Name", "user_notes": "Updated"}
    response = client.patch(f"/api/v1/places/{place.id}", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "New Name"
    assert data["user_notes"] == "Updated"


def test_update_place_coordinates(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id, lat=10.0, lng=10.0)

    payload = {"lat": 11.0, "lng": 12.0}
    response = client.patch(f"/api/v1/places/{place.id}", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["lat"] == 11.0
    assert data["lng"] == 12.0


def test_update_place_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    auth_as(other_user)
    response = client.patch(f"/api/v1/places/{place.id}", json={"name": "Hack"})
    assert response.status_code == 403


def test_update_place_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.patch(f"/api/v1/places/{uuid4()}", json={"name": "Nope"})
    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found"


def test_update_place_invalid_rating(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    response = client.patch(f"/api/v1/places/{place.id}", json={"user_rating": 9})
    assert response.status_code == 422


def test_update_place_unauthorized(client, unauthorized):
    response = client.patch(f"/api/v1/places/{uuid4()}", json={"name": "No Auth"})
    assert response.status_code == 401


def test_delete_place_success(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    response = client.delete(f"/api/v1/places/{place.id}")
    assert response.status_code == 204
    remaining = db.query(TripPlace).filter(TripPlace.id == place.id).first()
    assert remaining is None


def test_delete_place_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    auth_as(other_user)
    response = client.delete(f"/api/v1/places/{place.id}")
    assert response.status_code == 403


def test_delete_place_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.delete(f"/api/v1/places/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found"


def test_delete_place_unauthorized(client, unauthorized):
    response = client.delete(f"/api/v1/places/{uuid4()}")
    assert response.status_code == 401
