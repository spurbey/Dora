"""
Tests for search API endpoints (Session 16).

Tests:
- Successful search with ranking
- Authentication required
- Invalid parameters validation
- Empty results handling
- Debug mode
- Signal logging
"""

import pytest
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from uuid import uuid4

from app.main import app
from app.models import User, Trip, TripPlace, SearchEvent
from app.dependencies import get_current_user
from app.api.v1 import search as search_api


def override_current_user(user):
    """Create override function for current user dependency."""
    def _override():
        return user
    return _override


@pytest.fixture
def test_user(db: Session):
    """Create a test user."""
    user = User(
        email="search_test@example.com",
        username="search_test_user",
        hashed_password="hashed",
        is_verified=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def client_with_auth(client, test_user):
    """Create test client with auth dependency override."""
    app.dependency_overrides[get_current_user] = override_current_user(test_user)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture
def test_trip(db: Session, test_user):
    """Create a test trip."""
    trip = Trip(
        user_id=test_user.id,
        title="Search Test Trip",
        visibility="public"
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def test_places(db: Session, test_user, test_trip):
    """Create test places for search."""
    now = datetime.now(timezone.utc)

    places = [
        TripPlace(
            trip_id=test_trip.id,
            user_id=test_user.id,
            name="Coffee Lab Paris",
            place_type="cafe",
            lat=48.8584,
            lng=2.2945,
            location=f"SRID=4326;POINT(2.2945 48.8584)",
            created_at=now - timedelta(days=3)
        ),
        TripPlace(
            trip_id=test_trip.id,
            user_id=test_user.id,
            name="The Great Coffee Shop",
            place_type="cafe",
            lat=48.8600,
            lng=2.3000,
            location=f"SRID=4326;POINT(2.3000 48.8600)",
            created_at=now - timedelta(days=30)
        ),
        TripPlace(
            trip_id=test_trip.id,
            user_id=test_user.id,
            name="Random Restaurant",
            place_type="restaurant",
            lat=48.8700,
            lng=2.3200,
            location=f"SRID=4326;POINT(2.3200 48.8700)",
            created_at=now - timedelta(days=100)
        )
    ]

    for place in places:
        db.add(place)

    db.commit()

    # Refresh to get IDs
    for place in places:
        db.refresh(place)

    return places


class TestSearchEndpoint:
    """Test search API endpoint."""

    def test_successful_search(self, db: Session, client_with_auth, test_places):
        """Search should return ranked results."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "radius_km": 5.0,
                "limit": 10
            }
        )

        assert response.status_code == 200

        data = response.json()
        assert "results" in data
        assert "count" in data
        assert "query" in data
        assert data["query"] == "coffee"

        # Should have results (at least the coffee places)
        assert len(data["results"]) >= 2

        # All results should have scores
        for result in data["results"]:
            assert "score" in result
            assert 0 <= result["score"] <= 1

        # Results should be sorted by score (descending)
        scores = [r["score"] for r in data["results"]]
        assert scores == sorted(scores, reverse=True)

    def test_authentication_required(self, db: Session):
        """Search without auth should return 401 or 422."""
        # Create a client without auth override
        from fastapi.testclient import TestClient
        unauthenticated_client = TestClient(app)

        response = unauthenticated_client.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        # FastAPI may return 422 (validation) or 401 (auth) depending on order
        assert response.status_code in [401, 422]

    def test_invalid_coordinates(self, db: Session, client_with_auth):
        """Invalid coordinates should return 422 validation error."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 999,  # Invalid
                "lng": 2.2945
            }
        )

        assert response.status_code == 422

    def test_empty_query(self, db: Session, client_with_auth):
        """Empty query should return 400."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "   ",  # Whitespace only
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        assert response.status_code == 400
        assert "empty" in response.json()["detail"].lower()

    def test_empty_results(self, db: Session, client_with_auth):
        """Search with no matches should return empty list."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "xyzabc123nonexistent",
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        assert response.status_code == 200

        data = response.json()
        assert data["count"] == 0
        assert data["results"] == []

    def test_debug_mode(self, db: Session, client_with_auth, test_places):
        """Debug mode should include score breakdown."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "debug": True
            }
        )

        assert response.status_code == 200

        data = response.json()
        assert len(data["results"]) > 0

        # First result should have debug info
        first_result = data["results"][0]
        assert "_debug" in first_result

        debug = first_result["_debug"]
        assert "source_score" in debug
        assert "text_score" in debug
        assert "popularity_score" in debug
        assert "freshness_score" in debug
        assert "final_score" in debug
        assert "breakdown" in debug

    def test_radius_parameter(self, db: Session, client_with_auth, test_places):
        """Radius parameter should filter results."""
        # Small radius - should find fewer places
        small_radius = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "radius_km": 0.5
            }
        )

        # Large radius - should find more places
        large_radius = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "radius_km": 10.0
            }
        )

        assert small_radius.status_code == 200
        assert large_radius.status_code == 200

        small_count = small_radius.json()["count"]
        large_count = large_radius.json()["count"]

        # Larger radius should find at least as many results
        assert large_count >= small_count

    def test_limit_parameter(self, db: Session, client_with_auth, test_places):
        """Limit parameter should cap results."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "limit": 1
            }
        )

        assert response.status_code == 200

        data = response.json()
        assert data["count"] <= 1

    def test_ranking_order(self, db: Session, client_with_auth, test_places):
        """Results should be ranked properly."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945,
                "radius_km": 10.0
            }
        )

        assert response.status_code == 200

        data = response.json()
        results = data["results"]

        if len(results) >= 2:
            # First result should have higher or equal score
            assert results[0]["score"] >= results[1]["score"]

            # Verify all are local (for this test data)
            for result in results:
                if "coffee" in result["name"].lower():
                    assert result["source"] == "local"
                    assert result["has_user_content"] is True


class TestSignalLogging:
    """Test that search events are logged."""

    @pytest.fixture(autouse=True)
    def _override_log_search_event(self, db: Session, monkeypatch):
        """Override log_search_event to use the test session."""
        def _log_search_event(**kwargs):
            event = SearchEvent(
                user_id=kwargs.get("user_id"),
                query=kwargs.get("query"),
                lat=kwargs.get("lat"),
                lng=kwargs.get("lng"),
                radius_km=kwargs.get("radius_km"),
                results_count=kwargs.get("results_count")
            )
            db.add(event)
            db.commit()

        monkeypatch.setattr(search_api, "log_search_event", _log_search_event)
        yield

    def test_search_event_logged(self, db: Session, client_with_auth, test_user):
        """Successful search should log search_event."""
        # Count events before
        events_before = db.query(SearchEvent).filter(
            SearchEvent.user_id == test_user.id
        ).count()

        # Perform search
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "test query",
                "lat": 48.8584,
                "lng": 2.2945,
                "radius_km": 5.0
            }
        )

        assert response.status_code == 200

        # Give background task time to complete
        import time
        time.sleep(0.5)

        # Count events after
        events_after = db.query(SearchEvent).filter(
            SearchEvent.user_id == test_user.id
        ).count()

        # Should have one more event
        assert events_after == events_before + 1

        # Verify event data
        latest_event = db.query(SearchEvent).filter(
            SearchEvent.user_id == test_user.id
        ).order_by(SearchEvent.created_at.desc()).first()

        assert latest_event is not None
        assert latest_event.query == "test query"
        assert latest_event.lat == 48.8584
        assert latest_event.lng == 2.2945
        assert latest_event.radius_km == 5.0
        assert latest_event.results_count >= 0

    def test_failed_search_still_logs(self, db: Session, client_with_auth, test_user):
        """Even failed searches should log (for analytics)."""
        # Search with no results
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "nonexistent12345",
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        assert response.status_code == 200
        assert response.json()["count"] == 0

        # Give background task time
        import time
        time.sleep(0.5)

        # Should still have logged the event
        latest_event = db.query(SearchEvent).filter(
            SearchEvent.user_id == test_user.id
        ).order_by(SearchEvent.created_at.desc()).first()

        assert latest_event is not None
        assert latest_event.query == "nonexistent12345"
        assert latest_event.results_count == 0


class TestResultFormat:
    """Test result format compliance."""

    def test_result_has_required_fields(self, db: Session, client_with_auth, test_places):
        """All results should have required fields."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "coffee",
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        assert response.status_code == 200

        data = response.json()
        if len(data["results"]) > 0:
            result = data["results"][0]

            # Required fields
            assert "name" in result
            assert "lat" in result
            assert "lng" in result
            assert "source" in result
            assert "distance_m" in result
            assert "has_user_content" in result
            assert "score" in result

            # Type checks
            assert isinstance(result["name"], str)
            assert isinstance(result["lat"], (int, float))
            assert isinstance(result["lng"], (int, float))
            assert isinstance(result["source"], str)
            assert isinstance(result["distance_m"], (int, float))
            assert isinstance(result["has_user_content"], bool)
            assert isinstance(result["score"], (int, float))
            assert 0 <= result["score"] <= 1

    def test_response_format(self, db: Session, client_with_auth):
        """Response should have correct format."""
        response = client_with_auth.get(
            "/api/v1/search/places",
            params={
                "query": "test",
                "lat": 48.8584,
                "lng": 2.2945
            }
        )

        assert response.status_code == 200

        data = response.json()

        # Required top-level fields
        assert "results" in data
        assert "count" in data
        assert "query" in data

        # Type checks
        assert isinstance(data["results"], list)
        assert isinstance(data["count"], int)
        assert isinstance(data["query"], str)

        # Count should match results length
        assert data["count"] == len(data["results"])
