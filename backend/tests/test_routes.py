"""
Tests for Phase A2: Route System.

Tests all 10 endpoints + cascade behavior + validation.
Covers routes, waypoints, route_metadata, and Mapbox integration.
"""

from uuid import uuid4
import pytest
from fastapi import status
from unittest.mock import AsyncMock, patch

from app.dependencies import get_current_user
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.route_metadata import RouteMetadata
from app.models.user import User


def override_current_user(user):
    def _override():
        return user
    return _override


@pytest.fixture
def test_user(db):
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
    trip = Trip(user_id=test_user.id, title="Test Trip", visibility="private")
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def public_trip(db, test_user):
    trip = Trip(user_id=test_user.id, title="Public Trip", visibility="public")
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def test_place1(db, test_user, test_trip):
    place = TripPlace(
        trip_id=test_trip.id,
        user_id=test_user.id,
        name="Place 1",
        location="SRID=4326;POINT(77.5946 12.9716)",
        lat=12.9716,
        lng=77.5946,
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


@pytest.fixture
def test_place2(db, test_user, test_trip):
    place = TripPlace(
        trip_id=test_trip.id,
        user_id=test_user.id,
        name="Place 2",
        location="SRID=4326;POINT(77.6000 13.0000)",
        lat=13.0000,
        lng=77.6000,
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


@pytest.fixture
def auth_as(fastapi_app):
    def _set(user):
        fastapi_app.dependency_overrides[get_current_user] = override_current_user(user)
    return _set


# ============================================================================
# ROUTE TESTS
# ============================================================================

def test_create_route(client, test_user, test_trip, test_place1, test_place2, auth_as):
    """Test creating a route with GeoJSON."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/routes",
        json={
            "route_geojson": {
                "type": "LineString",
                "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]
            },
            "transport_mode": "car",
            "route_category": "ground",
            "start_place_id": str(test_place1.id),
            "end_place_id": str(test_place2.id),
            "name": "Scenic Route",
            "description": "Beautiful drive",
            "order_in_trip": 1
        }
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["trip_id"] == str(test_trip.id)
    assert data["transport_mode"] == "car"
    assert data["route_category"] == "ground"
    assert data["route_geojson"]["type"] == "LineString"
    assert data["name"] == "Scenic Route"
    assert data["order_in_trip"] == 1


def test_create_route_invalid_geojson(client, test_user, test_trip, auth_as):
    """Test creating route with invalid GeoJSON."""
    auth_as(test_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/routes",
        json={
            "route_geojson": {"type": "Point", "coordinates": [77.5946, 12.9716]},  # Wrong type
            "transport_mode": "car",
            "route_category": "ground",
            "order_in_trip": 1
        }
    )

    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_route_not_owner(client, other_user, test_trip, auth_as):
    """Test creating route when not trip owner."""
    auth_as(other_user)

    response = client.post(
        f"/api/v1/trips/{test_trip.id}/routes",
        json={
            "route_geojson": {"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
            "transport_mode": "car",
            "route_category": "ground",
            "order_in_trip": 1
        }
    )

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_list_trip_routes(client, db, test_user, test_trip, auth_as):
    """Test listing routes for a trip."""
    auth_as(test_user)

    # Create routes
    route1 = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    route2 = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.6000, 13.0000], [77.6100, 13.0100]]},
        transport_mode="bike",
        route_category="ground",
        order_in_trip=2
    )
    db.add_all([route1, route2])
    db.commit()

    response = client.get(f"/api/v1/trips/{test_trip.id}/routes")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["total"] == 2
    assert len(data["routes"]) == 2
    assert data["routes"][0]["order_in_trip"] == 1


def test_get_route(client, db, test_user, test_trip, auth_as):
    """Test getting route details."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="train",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    response = client.get(f"/api/v1/routes/{route.id}")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == str(route.id)
    assert data["transport_mode"] == "train"


def test_update_route(client, db, test_user, test_trip, auth_as):
    """Test updating a route."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    response = client.patch(
        f"/api/v1/routes/{route.id}",
        json={"name": "Updated Route", "order_in_trip": 5}
    )

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["name"] == "Updated Route"
    assert data["order_in_trip"] == 5


def test_delete_route(client, db, test_user, test_trip, auth_as):
    """Test deleting a route."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()
    route_id = route.id

    response = client.delete(f"/api/v1/routes/{route_id}")

    assert response.status_code == status.HTTP_204_NO_CONTENT

    # Verify deleted
    route = db.query(Route).filter(Route.id == route_id).first()
    assert route is None


def test_delete_trip_cascades_routes(db, test_user, test_trip):
    """Test that deleting trip cascades to routes."""
    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()
    route_id = route.id

    # Delete trip
    db.delete(test_trip)
    db.commit()

    # Verify route deleted
    route = db.query(Route).filter(Route.id == route_id).first()
    assert route is None


# ============================================================================
# WAYPOINT TESTS
# ============================================================================

def test_add_waypoint(client, db, test_user, test_trip, auth_as):
    """Test adding a waypoint to a route."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    response = client.post(
        f"/api/v1/routes/{route.id}/waypoints",
        json={
            "lat": 12.98,
            "lng": 77.60,
            "name": "Scenic Viewpoint",
            "waypoint_type": "photo",
            "notes": "Great photo spot",
            "order_in_route": 1
        }
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["route_id"] == str(route.id)
    assert data["name"] == "Scenic Viewpoint"
    assert data["waypoint_type"] == "photo"
    assert data["lat"] == 12.98
    assert data["lng"] == 77.60


def test_list_waypoints(client, db, test_user, test_trip, auth_as):
    """Test listing waypoints for a route."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    waypoint1 = Waypoint(
        route_id=route.id,
        trip_id=test_trip.id,
        user_id=test_user.id,
        lat=12.98,
        lng=77.60,
        name="Waypoint 1",
        waypoint_type="stop",
        order_in_route=1
    )
    waypoint2 = Waypoint(
        route_id=route.id,
        trip_id=test_trip.id,
        user_id=test_user.id,
        lat=12.99,
        lng=77.61,
        name="Waypoint 2",
        waypoint_type="note",
        order_in_route=2
    )
    db.add_all([waypoint1, waypoint2])
    db.commit()

    response = client.get(f"/api/v1/routes/{route.id}/waypoints")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["total"] == 2
    assert len(data["waypoints"]) == 2
    assert data["waypoints"][0]["order_in_route"] == 1


def test_update_waypoint(client, db, test_user, test_trip, auth_as):
    """Test updating a waypoint."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    waypoint = Waypoint(
        route_id=route.id,
        trip_id=test_trip.id,
        user_id=test_user.id,
        lat=12.98,
        lng=77.60,
        name="Old Name",
        waypoint_type="stop",
        order_in_route=1
    )
    db.add(waypoint)
    db.commit()

    response = client.patch(
        f"/api/v1/waypoints/{waypoint.id}",
        json={"name": "New Name", "notes": "Updated notes"}
    )

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["name"] == "New Name"
    assert data["notes"] == "Updated notes"


def test_delete_waypoint(client, db, test_user, test_trip, auth_as):
    """Test deleting a waypoint."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    waypoint = Waypoint(
        route_id=route.id,
        trip_id=test_trip.id,
        user_id=test_user.id,
        lat=12.98,
        lng=77.60,
        name="Waypoint",
        waypoint_type="stop",
        order_in_route=1
    )
    db.add(waypoint)
    db.commit()
    waypoint_id = waypoint.id

    response = client.delete(f"/api/v1/waypoints/{waypoint_id}")

    assert response.status_code == status.HTTP_204_NO_CONTENT

    # Verify deleted
    waypoint = db.query(Waypoint).filter(Waypoint.id == waypoint_id).first()
    assert waypoint is None


def test_delete_route_cascades_waypoints(db, test_user, test_trip):
    """Test that deleting route cascades to waypoints."""
    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    waypoint = Waypoint(
        route_id=route.id,
        trip_id=test_trip.id,
        user_id=test_user.id,
        lat=12.98,
        lng=77.60,
        name="Waypoint",
        waypoint_type="stop",
        order_in_route=1
    )
    db.add(waypoint)
    db.commit()
    waypoint_id = waypoint.id

    # Delete route
    db.delete(route)
    db.commit()

    # Verify waypoint deleted
    waypoint = db.query(Waypoint).filter(Waypoint.id == waypoint_id).first()
    assert waypoint is None


# ============================================================================
# ROUTE METADATA TESTS
# ============================================================================

def test_create_route_metadata(client, db, test_user, test_trip, auth_as):
    """Test creating route metadata."""
    auth_as(test_user)

    route = Route(
        trip_id=test_trip.id,
        user_id=test_user.id,
        route_geojson={"type": "LineString", "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]},
        transport_mode="car",
        route_category="ground",
        order_in_trip=1
    )
    db.add(route)
    db.commit()

    response = client.post(
        f"/api/v1/routes/{route.id}/metadata",
        json={
            "route_quality": "scenic",
            "road_condition": "excellent",
            "scenic_rating": 5,
            "safety_rating": 4,
            "solo_safe": True,
            "fuel_cost": 50.00,
            "toll_cost": 10.00,
            "highlights": ["waterfall", "viewpoint"],
            "is_public": True
        }
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["route_id"] == str(route.id)
    assert data["route_quality"] == "scenic"
    assert data["scenic_rating"] == 5
    assert data["highlights"] == ["waterfall", "viewpoint"]


# ============================================================================
# MAPBOX INTEGRATION TESTS
# ============================================================================

@patch('app.services.route_service.httpx.AsyncClient')
def test_generate_route_mapbox(mock_httpx, client, test_user, auth_as):
    """Test route generation using Mapbox API (mocked)."""
    auth_as(test_user)

    # Mock Mapbox API response
    mock_response = AsyncMock()
    mock_response.json.return_value = {
        "routes": [{
            "geometry": {
                "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]]
            },
            "distance": 10500,  # meters
            "duration": 1800    # seconds
        }]
    }
    mock_response.raise_for_status = AsyncMock()

    mock_client = AsyncMock()
    mock_client.get = AsyncMock(return_value=mock_response)
    mock_client.__aenter__.return_value = mock_client
    mock_client.__aexit__.return_value = AsyncMock()
    mock_httpx.return_value = mock_client

    response = client.post(
        "/api/v1/routes/generate",
        json={
            "coordinates": [[77.5946, 12.9716], [77.6000, 13.0000]],
            "mode": "driving"
        }
    )

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "route_geojson" in data
    assert data["route_geojson"]["type"] == "LineString"
    assert data["distance_km"] == 10.5
    assert data["duration_mins"] == 30
