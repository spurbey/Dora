"""
Tests for component endpoints (Phase A3).

Tests unified timeline view combining places and routes.
"""

import pytest
from uuid import uuid4
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.route import Route
from app.models.trip_component import TripComponent


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def trip_with_components(db, test_user):
    """Create a trip with mixed places and routes."""
    trip = Trip(
        id=uuid4(),
        user_id=test_user.id,
        title="Test Trip with Components",
        visibility="private"
    )
    db.add(trip)
    db.flush()

    # Add 3 places
    place1 = TripPlace(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Place 1",
        order_in_trip=0,
        location="SRID=4326;POINT(0 0)",
        lat=0.0,
        lng=0.0
    )
    place2 = TripPlace(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Place 2",
        order_in_trip=2,
        location="SRID=4326;POINT(1 1)",
        lat=1.0,
        lng=1.0
    )
    place3 = TripPlace(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Place 3",
        order_in_trip=4,
        location="SRID=4326;POINT(2 2)",
        lat=2.0,
        lng=2.0
    )

    # Add 2 routes
    route1 = Route(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Route 1",
        order_in_trip=1,
        route_geojson={"type": "LineString", "coordinates": [[0, 0], [1, 1]]},
        transport_mode="car",
        route_category="ground"
    )
    route2 = Route(
        id=uuid4(),
        trip_id=trip.id,
        user_id=test_user.id,
        name="Route 2",
        order_in_trip=3,
        route_geojson={"type": "LineString", "coordinates": [[1, 1], [2, 2]]},
        transport_mode="bike",
        route_category="ground"
    )

    db.add_all([place1, place2, place3, route1, route2])
    db.commit()

    return {
        'trip': trip,
        'places': [place1, place2, place3],
        'routes': [route1, route2]
    }


@pytest.fixture
def public_trip_with_components(db, other_user):
    """Create a public trip owned by another user."""
    trip = Trip(
        id=uuid4(),
        user_id=other_user.id,
        title="Public Trip",
        visibility="public"
    )
    db.add(trip)
    db.flush()

    place = TripPlace(
        id=uuid4(),
        trip_id=trip.id,
        user_id=other_user.id,
        name="Public Place",
        order_in_trip=0,
        location="SRID=4326;POINT(0 0)",
        lat=0.0,
        lng=0.0
    )
    db.add(place)
    db.commit()

    return {'trip': trip, 'places': [place]}


# ============================================================================
# TIMELINE RETRIEVAL TESTS
# ============================================================================

def test_get_components_returns_places_and_routes(client, test_user, auth_as, trip_with_components):
    """View combines both entity types."""
    auth_as(test_user)

    trip = trip_with_components['trip']

    response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )

    assert response.status_code == 200
    data = response.json()

    assert data['total'] == 5  # 3 places + 2 routes
    assert len(data['components']) == 5
    assert data['trip_id'] == str(trip.id)

    # Check component types
    types = [c['component_type'] for c in data['components']]
    assert types.count('place') == 3
    assert types.count('route') == 2


def test_components_ordered_by_order_in_trip(client, test_user, auth_as, trip_with_components):
    """Results sorted correctly via ORDER BY in query."""
    auth_as(test_user)

    trip = trip_with_components['trip']

    response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )

    assert response.status_code == 200
    components = response.json()['components']

    # Verify chronological order: 0, 1, 2, 3, 4
    orders = [c['order_in_trip'] for c in components]
    assert orders == [0, 1, 2, 3, 4]

    # Verify correct interleaving: place, route, place, route, place
    expected_sequence = ['place', 'route', 'place', 'route', 'place']
    actual_sequence = [c['component_type'] for c in components]
    assert actual_sequence == expected_sequence


def test_empty_timeline_returns_empty_list(client, test_user, auth_as, db):
    """Handles trips with no components."""
    auth_as(test_user)

    trip = Trip(
        id=uuid4(),
        user_id=test_user.id,
        title="Empty Trip",
        visibility="private"
    )
    db.add(trip)
    db.commit()

    response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )

    assert response.status_code == 200
    data = response.json()
    assert data['total'] == 0
    assert data['components'] == []


# ============================================================================
# REORDERING TESTS
# ============================================================================

def test_reorder_normalizes_to_sequential(client, test_user, auth_as, trip_with_components, db):
    """[5,2,8] becomes [0,1,2]."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    places = trip_with_components['places']
    routes = trip_with_components['routes']

    # Reorder with non-sequential values: [8, 2, 5]
    reorder_data = {
        'items': [
            {'id': str(places[0].id), 'component_type': 'place', 'new_order': 8},
            {'id': str(routes[0].id), 'component_type': 'route', 'new_order': 2},
            {'id': str(places[1].id), 'component_type': 'place', 'new_order': 5}
        ]
    }

    response = client.patch(
        f"/api/v1/trips/{trip.id}/components/reorder",
        json=reorder_data
    )

    assert response.status_code == 200
    assert response.json()['updated_count'] == 3

    # Verify normalization: should be [0, 1, 2]
    db.refresh(routes[0])
    db.refresh(places[1])
    db.refresh(places[0])

    assert routes[0].order_in_trip == 0  # new_order=2 -> normalized to 0
    assert places[1].order_in_trip == 1  # new_order=5 -> normalized to 1
    assert places[0].order_in_trip == 2  # new_order=8 -> normalized to 2


def test_reorder_multiple_types(client, test_user, auth_as, trip_with_components, db):
    """Can reorder places + routes together."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    places = trip_with_components['places']
    routes = trip_with_components['routes']

    # Mix places and routes in new order
    reorder_data = {
        'items': [
            {'id': str(routes[1].id), 'component_type': 'route', 'new_order': 0},
            {'id': str(places[2].id), 'component_type': 'place', 'new_order': 1},
            {'id': str(routes[0].id), 'component_type': 'route', 'new_order': 2},
            {'id': str(places[0].id), 'component_type': 'place', 'new_order': 3},
            {'id': str(places[1].id), 'component_type': 'place', 'new_order': 4}
        ]
    }

    response = client.patch(
        f"/api/v1/trips/{trip.id}/components/reorder",
        json=reorder_data
    )

    assert response.status_code == 200
    assert response.json()['updated_count'] == 5

    # Verify new order
    db.refresh(routes[1])
    db.refresh(places[2])
    db.refresh(routes[0])

    assert routes[1].order_in_trip == 0
    assert places[2].order_in_trip == 1
    assert routes[0].order_in_trip == 2


def test_reorder_validates_trip_ownership(client, test_user, auth_as, trip_with_components):
    """All components must belong to trip."""
    auth_as(test_user)

    trip = trip_with_components['trip']

    # Try to include a component from a different trip
    fake_id = uuid4()
    reorder_data = {
        'items': [
            {'id': str(fake_id), 'component_type': 'place', 'new_order': 0}
        ]
    }

    response = client.patch(
        f"/api/v1/trips/{trip.id}/components/reorder",
        json=reorder_data
    )

    assert response.status_code == 422
    assert f"Component {fake_id} not found" in response.json()['detail']


def test_reorder_auth_owner_only(client, test_user, auth_as, public_trip_with_components):
    """Non-owners cannot reorder."""
    auth_as(test_user)

    trip = public_trip_with_components['trip']
    place = public_trip_with_components['places'][0]

    reorder_data = {
        'items': [
            {'id': str(place.id), 'component_type': 'place', 'new_order': 0}
        ]
    }

    response = client.patch(
        f"/api/v1/trips/{trip.id}/components/reorder",
        json=reorder_data
    )

    assert response.status_code == 403
    assert "only trip owner" in response.json()['detail'].lower()


# ============================================================================
# COMPONENT DETAILS TESTS
# ============================================================================

def test_get_place_component_details_no_type_param(client, test_user, auth_as, trip_with_components):
    """Auto-detects type from view."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    place = trip_with_components['places'][0]

    response = client.get(
        f"/api/v1/trips/{trip.id}/components/{place.id}"
    )

    assert response.status_code == 200
    data = response.json()

    assert data['id'] == str(place.id)
    assert data['component_type'] == 'place'
    assert data['place_data'] is not None
    assert data['route_data'] is None
    assert data['place_data']['name'] == "Place 1"


def test_get_route_component_details_returns_route_data(client, test_user, auth_as, trip_with_components):
    """Returns full route object."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    route = trip_with_components['routes'][0]

    response = client.get(
        f"/api/v1/trips/{trip.id}/components/{route.id}"
    )

    assert response.status_code == 200
    data = response.json()

    assert data['id'] == str(route.id)
    assert data['component_type'] == 'route'
    assert data['route_data'] is not None
    assert data['place_data'] is None
    assert data['route_data']['name'] == "Route 1"


def test_get_component_invalid_id_returns_404(client, test_user, auth_as, trip_with_components):
    """Handles missing components."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    fake_id = uuid4()

    response = client.get(
        f"/api/v1/trips/{trip.id}/components/{fake_id}"
    )

    assert response.status_code == 404
    assert "Component not found" in response.json()['detail']


# ============================================================================
# EDGE CASES
# ============================================================================

def test_delete_place_removes_from_timeline(client, test_user, auth_as, trip_with_components, db):
    """Cascade works via view."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    place_to_delete = trip_with_components['places'][0]

    # Get initial count
    initial_response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )
    initial_count = initial_response.json()['total']

    # Delete place via places endpoint
    delete_response = client.delete(
        f"/api/v1/places/{place_to_delete.id}"
    )
    assert delete_response.status_code == 204

    # Verify removed from timeline
    after_response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )
    assert after_response.json()['total'] == initial_count - 1


def test_delete_route_removes_from_timeline(client, test_user, auth_as, trip_with_components, db):
    """Cascade works via view."""
    auth_as(test_user)

    trip = trip_with_components['trip']
    route_to_delete = trip_with_components['routes'][0]

    # Get initial count
    initial_response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )
    initial_count = initial_response.json()['total']

    # Delete route
    delete_response = client.delete(
        f"/api/v1/routes/{route_to_delete.id}"
    )
    assert delete_response.status_code == 204

    # Verify removed from timeline
    after_response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )
    assert after_response.json()['total'] == initial_count - 1


# ============================================================================
# AUTH TESTS
# ============================================================================

def test_public_trip_timeline_visible(client, test_user, auth_as, public_trip_with_components):
    """Non-owners can view public trips."""
    auth_as(test_user)

    trip = public_trip_with_components['trip']

    response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )

    assert response.status_code == 200
    assert response.json()['total'] > 0


def test_private_trip_timeline_hidden(client, test_user, auth_as, db, other_user):
    """Non-owners blocked from private trips."""
    auth_as(test_user)

    trip = Trip(
        id=uuid4(),
        user_id=other_user.id,
        title="Private Trip",
        visibility="private"
    )
    db.add(trip)
    db.commit()

    response = client.get(
        f"/api/v1/trips/{trip.id}/components"
    )

    assert response.status_code == 403
    assert "Access denied" in response.json()['detail']


def test_component_detail_respects_visibility(client, test_user, auth_as, public_trip_with_components):
    """Component details respect trip visibility."""
    auth_as(test_user)

    trip = public_trip_with_components['trip']
    place = public_trip_with_components['places'][0]

    response = client.get(
        f"/api/v1/trips/{trip.id}/components/{place.id}"
    )

    assert response.status_code == 200
    assert response.json()['component_type'] == 'place'
