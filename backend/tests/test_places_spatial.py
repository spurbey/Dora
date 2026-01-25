"""
Tests for spatial place queries and trip bounds.

Validates:
- Nearby places endpoint
- PlaceService distance calculation
- Trip bounds endpoint
"""

from uuid import uuid4

import pytest
from fastapi import HTTPException

from app.dependencies import get_current_user
from app.models.trip import Trip
from app.schemas.place import PlaceCreate
from app.services.place_service import PlaceService


def override_current_user(user):
    def _override():
        return user
    return _override


def create_trip(db, user_id, visibility="private", title="Trip"):
    trip = Trip(
        user_id=user_id,
        title=title,
        visibility=visibility,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def create_place(service, trip_id, user_id, name, lat, lng, order_in_trip=None):
    place_data = PlaceCreate(
        trip_id=trip_id,
        name=name,
        lat=lat,
        lng=lng,
        order_in_trip=order_in_trip,
    )
    return service.create_place(user_id, place_data)


@pytest.fixture
def auth_as(fastapi_app):
    def _set(user):
        fastapi_app.dependency_overrides[get_current_user] = (
            override_current_user(user)
        )
    yield _set
    fastapi_app.dependency_overrides.clear()


def test_nearby_places_success(client, db, test_user, auth_as):
    auth_as(test_user)
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, title="Paris Trip")

    create_place(service, trip.id, test_user.id, "Eiffel Tower", 48.8584, 2.2945)
    create_place(service, trip.id, test_user.id, "Louvre Museum", 48.8606, 2.3376)
    create_place(service, trip.id, test_user.id, "Arc de Triomphe", 48.8738, 2.2950)

    response = client.get("/api/v1/places/nearby?lat=48.8584&lng=2.2945&radius=3")
    assert response.status_code == 200

    data = response.json()
    assert data["total"] == 2
    names = [place["name"] for place in data["places"]]
    assert names == ["Eiffel Tower", "Arc de Triomphe"]


def test_nearby_places_with_large_radius(client, db, test_user, auth_as):
    auth_as(test_user)
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, title="Paris Trip")

    create_place(service, trip.id, test_user.id, "Eiffel Tower", 48.8584, 2.2945)
    create_place(service, trip.id, test_user.id, "Louvre Museum", 48.8606, 2.3376)
    create_place(service, trip.id, test_user.id, "Arc de Triomphe", 48.8738, 2.2950)

    response = client.get("/api/v1/places/nearby?lat=48.8584&lng=2.2945&radius=10")
    assert response.status_code == 200
    assert response.json()["total"] == 3


def test_nearby_places_empty_result(client, test_user, auth_as):
    auth_as(test_user)

    response = client.get("/api/v1/places/nearby?lat=0&lng=0&radius=5")
    assert response.status_code == 200
    assert response.json()["total"] == 0
    assert response.json()["places"] == []


def test_nearby_places_filters_by_user(client, db, test_user, premium_user, auth_as):
    service = PlaceService(db)
    trip_user = create_trip(db, test_user.id, title="User Trip")
    trip_premium = create_trip(db, premium_user.id, title="Premium Trip")

    create_place(service, trip_user.id, test_user.id, "User Place", 48.8584, 2.2945)
    create_place(service, trip_premium.id, premium_user.id, "Premium Place", 48.8584, 2.2945)

    auth_as(test_user)
    response = client.get("/api/v1/places/nearby?lat=48.8584&lng=2.2945&radius=5")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1
    assert data["places"][0]["name"] == "User Place"


def test_calculate_distance_success(db, test_user):
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, title="Paris Trip")

    eiffel = create_place(service, trip.id, test_user.id, "Eiffel Tower", 48.8584, 2.2945)
    louvre = create_place(service, trip.id, test_user.id, "Louvre Museum", 48.8606, 2.3376)

    distance_km = service.calculate_distance(eiffel.id, louvre.id)
    assert distance_km == pytest.approx(3.1, abs=0.7)


def test_calculate_distance_place_not_found(db, test_user):
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, title="Paris Trip")

    eiffel = create_place(service, trip.id, test_user.id, "Eiffel Tower", 48.8584, 2.2945)

    with pytest.raises(HTTPException) as exc_info:
        service.calculate_distance(eiffel.id, uuid4())

    assert exc_info.value.status_code == 404
    assert "One or both places not found" in exc_info.value.detail


def test_trip_bounds_with_places(client, db, test_user, auth_as):
    auth_as(test_user)
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, title="Bounds Trip")

    create_place(service, trip.id, test_user.id, "Place A", 10.0, 10.0)
    create_place(service, trip.id, test_user.id, "Place B", 20.0, 30.0)
    create_place(service, trip.id, test_user.id, "Place C", 15.0, 5.0)

    response = client.get(f"/api/v1/trips/{trip.id}/bounds")
    assert response.status_code == 200
    data = response.json()
    assert data["min_lat"] == 10.0
    assert data["min_lng"] == 5.0
    assert data["max_lat"] == 20.0
    assert data["max_lng"] == 30.0
    assert data["center_lat"] == 15.0
    assert data["center_lng"] == 17.5


def test_trip_bounds_no_places(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id, title="Empty Trip")

    response = client.get(f"/api/v1/trips/{trip.id}/bounds")
    assert response.status_code == 200
    assert response.json() is None


def test_trip_bounds_trip_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.get(f"/api/v1/trips/{uuid4()}/bounds")
    assert response.status_code == 404
    assert response.json()["detail"] == "Trip not found"


def test_trip_bounds_access_control(client, db, test_user, premium_user, auth_as):
    service = PlaceService(db)
    trip = create_trip(db, test_user.id, visibility="private", title="Private Trip")
    create_place(service, trip.id, test_user.id, "Hidden Place", 10.0, 10.0)

    auth_as(premium_user)
    response = client.get(f"/api/v1/trips/{trip.id}/bounds")
    assert response.status_code == 403
