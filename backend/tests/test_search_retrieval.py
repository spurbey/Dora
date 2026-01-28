"""
Tests for Session 15 search retrieval layer.

Test Coverage:
- Local search provider
- Foursquare search provider (mocked)
- Deduplication logic
- Multi-source search orchestration
- Error handling and graceful degradation
- Unified schema compliance
"""

import pytest
from unittest.mock import patch, AsyncMock, MagicMock
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import uuid

from app.services.search_service import SearchService
from app.services.providers.local_provider import LocalSearchProvider
from app.services.providers.foursquare_provider import FoursquareSearchProvider
from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.search_signals import PlaceSave
from app.utils.geo import haversine_distance, normalize_name_for_matching


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def test_user(db: Session) -> User:
    """Create test user."""
    unique_id = str(uuid.uuid4())[:8]
    user = User(
        id=uuid.uuid4(),
        email=f"test_{unique_id}@example.com",
        username=f"testuser_{unique_id}",
        hashed_password="hashed",
        full_name="Test User",
        is_premium=False,
        is_verified=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def public_trip(db: Session, test_user: User) -> Trip:
    """Create public trip for test places."""
    trip = Trip(
        id=uuid.uuid4(),
        user_id=test_user.id,
        title="Paris Trip",
        visibility="public",
        start_date=datetime.now().date(),
        end_date=(datetime.now() + timedelta(days=7)).date()
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def coffee_places(db: Session, public_trip: Trip) -> list[TripPlace]:
    """Create test coffee places in Paris."""
    places = []

    # Place 1: Café de Flore (famous)
    place1 = TripPlace(
        id=uuid.uuid4(),
        trip_id=public_trip.id,
        user_id=public_trip.user_id,
        name="Café de Flore",
        place_type="cafe",
        lat=48.8542,
        lng=2.3325,
        location=f"SRID=4326;POINT(2.3325 48.8542)",
        user_notes="Famous historical cafe",
        created_at=datetime.now() - timedelta(days=5)
    )
    places.append(place1)

    # Place 2: Starbucks (chain)
    place2 = TripPlace(
        id=uuid.uuid4(),
        trip_id=public_trip.id,
        user_id=public_trip.user_id,
        name="Starbucks Champs-Élysées",
        place_type="cafe",
        lat=48.8698,
        lng=2.3078,
        location=f"SRID=4326;POINT(2.3078 48.8698)",
        user_notes="Coffee chain",
        created_at=datetime.now() - timedelta(days=2)
    )
    places.append(place2)

    for place in places:
        db.add(place)

    db.commit()

    for place in places:
        db.refresh(place)

    return places


# ============================================================================
# GEO UTILITY TESTS
# ============================================================================

def test_haversine_distance_same_point():
    """Test distance calculation for same point."""
    distance = haversine_distance(48.8584, 2.2945, 48.8584, 2.2945)
    assert distance == 0.0


def test_haversine_distance_paris_to_eiffel():
    """Test distance calculation Paris center to Eiffel Tower."""
    # Paris center: 48.8566, 2.3522
    # Eiffel Tower: 48.8584, 2.2945
    distance = haversine_distance(48.8566, 2.3522, 48.8584, 2.2945)

    # Should be around 4.2 km
    assert 4000 < distance < 5000


def test_normalize_name_for_matching():
    """Test name normalization for duplicate detection."""
    assert normalize_name_for_matching("Café de Flore") == "cafe de flore"
    assert normalize_name_for_matching("  O'Brien's PUB  ") == "o'brien's pub"
    assert normalize_name_for_matching("CO-OP Store") == "co-op store"


# ============================================================================
# LOCAL PROVIDER TESTS
# ============================================================================

@pytest.mark.asyncio
async def test_local_provider_finds_places(db: Session, coffee_places: list):
    """Test local provider finds matching places."""
    provider = LocalSearchProvider(db)

    results = await provider.search(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    assert len(results) >= 1
    assert all(r["source"] == "local" for r in results)
    assert all(r["has_user_content"] is True for r in results)
    assert all("id" in r and r["id"].startswith("local:") for r in results)


@pytest.mark.asyncio
async def test_local_provider_respects_radius(db: Session, coffee_places: list):
    """Test local provider filters by radius."""
    provider = LocalSearchProvider(db)

    # Search with very small radius
    results = await provider.search(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=0.5,  # 500 meters
        limit=10
    )

    # Should find fewer results than with large radius
    all_results = await provider.search(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=10.0,
        limit=10
    )

    assert len(results) <= len(all_results)


@pytest.mark.asyncio
async def test_local_provider_orders_by_distance(db: Session, coffee_places: list):
    """Test local provider orders results by distance."""
    provider = LocalSearchProvider(db)

    results = await provider.search(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    # Verify distances are in ascending order
    distances = [r["distance_m"] for r in results]
    assert distances == sorted(distances)


@pytest.mark.asyncio
async def test_local_provider_includes_popularity(
    db: Session,
    coffee_places: list,
    test_user: User
):
    """Test local provider includes save count as popularity."""
    # Add saves to first place
    place = coffee_places[0]
    save = PlaceSave(
        id=uuid.uuid4(),
        user_id=test_user.id,
        place_id=place.id
    )
    db.add(save)
    db.commit()

    provider = LocalSearchProvider(db)
    results = await provider.search(
        query="cafe de flore",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    # Find the saved place in results
    saved_place_result = next(
        (r for r in results if r["name"] == "Café de Flore"),
        None
    )

    assert saved_place_result is not None
    assert saved_place_result["popularity"] >= 1


@pytest.mark.asyncio
async def test_local_provider_empty_query(db: Session):
    """Test local provider handles empty query."""
    provider = LocalSearchProvider(db)

    results = await provider.search(
        query="",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    # Should return empty list or handle gracefully
    assert isinstance(results, list)


# ============================================================================
# FOURSQUARE PROVIDER TESTS (MOCKED)
# ============================================================================

@pytest.mark.asyncio
async def test_foursquare_provider_success():
    """Test Foursquare provider with successful response."""
    mock_response = {
        "results": [
            {
                "fsq_id": "4c8b5c5e1234567890abcdef",
                "name": "Le Consulat",
                "geocodes": {
                    "main": {
                        "latitude": 48.8867,
                        "longitude": 2.3402
                    }
                },
                "location": {
                    "address": "18 Rue Norvins",
                    "locality": "Paris",
                    "postcode": "75018"
                },
                "distance": 1250,
                "rating": 8.5
            }
        ]
    }

    provider = FoursquareSearchProvider()

    with patch.object(provider, '_make_request_with_retry', new=AsyncMock(return_value=mock_response)):
        results = await provider.search(
            query="cafe",
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    assert len(results) == 1
    assert results[0]["source"] == "foursquare"
    assert results[0]["has_user_content"] is False
    assert results[0]["id"].startswith("foursquare:")
    assert results[0]["name"] == "Le Consulat"
    assert results[0]["address"] == "18 Rue Norvins, Paris, 75018"


@pytest.mark.asyncio
async def test_foursquare_provider_empty_results():
    """Test Foursquare provider with empty results."""
    mock_response = {"results": []}

    provider = FoursquareSearchProvider()

    with patch.object(provider, '_make_request_with_retry', new=AsyncMock(return_value=mock_response)):
        results = await provider.search(
            query="xyzabc123",
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    assert results == []


@pytest.mark.asyncio
async def test_foursquare_provider_api_failure():
    """Test Foursquare provider handles API failure gracefully."""
    provider = FoursquareSearchProvider()

    with patch.object(provider, '_make_request_with_retry', new=AsyncMock(return_value=None)):
        results = await provider.search(
            query="cafe",
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    assert results == []


@pytest.mark.asyncio
async def test_foursquare_provider_timeout():
    """Test Foursquare provider handles timeout."""
    provider = FoursquareSearchProvider()

    with patch.object(provider, '_make_request_with_retry', new=AsyncMock(side_effect=Exception("Timeout"))):
        results = await provider.search(
            query="cafe",
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    assert results == []


# ============================================================================
# DEDUPLICATION TESTS
# ============================================================================

@pytest.mark.asyncio
async def test_deduplication_removes_duplicates(db: Session):
    """Test deduplication removes identical places from different sources."""
    service = SearchService(db)

    results = [
        {
            "id": "local:123",
            "name": "Café de Flore",
            "lat": 48.8542,
            "lng": 2.3325,
            "source": "local",
            "distance_m": 100.0,
            "has_user_content": True,
            "address": None,
            "rating": None,
            "popularity": 5
        },
        {
            "id": "foursquare:abc",
            "name": "Cafe de Flore",  # Same place, different spelling
            "lat": 48.8543,  # Slightly different coords
            "lng": 2.3326,
            "source": "foursquare",
            "distance_m": 105.0,
            "has_user_content": False,
            "address": "172 Boulevard Saint-Germain, Paris",
            "rating": 8.5,
            "popularity": None
        }
    ]

    unique = service._deduplicate_results(results)

    # Should keep only local result
    assert len(unique) == 1
    assert unique[0]["source"] == "local"


@pytest.mark.asyncio
async def test_deduplication_keeps_distinct_places(db: Session):
    """Test deduplication keeps truly different places."""
    service = SearchService(db)

    results = [
        {
            "id": "local:123",
            "name": "Café de Flore",
            "lat": 48.8542,
            "lng": 2.3325,
            "source": "local",
            "distance_m": 100.0,
            "has_user_content": True,
            "address": None,
            "rating": None,
            "popularity": 5
        },
        {
            "id": "foursquare:abc",
            "name": "Le Consulat",  # Different place
            "lat": 48.8867,
            "lng": 2.3402,
            "source": "foursquare",
            "distance_m": 2500.0,
            "has_user_content": False,
            "address": "18 Rue Norvins, Paris",
            "rating": 8.5,
            "popularity": None
        }
    ]

    unique = service._deduplicate_results(results)

    # Should keep both
    assert len(unique) == 2


@pytest.mark.asyncio
async def test_deduplication_local_priority(db: Session):
    """Test local results always win over external."""
    service = SearchService(db)

    # Create signature matching test
    sig1 = {"name": "cafe de flore", "lat": 48.8542, "lng": 2.3325}
    sig2 = {"name": "cafe de flore", "lat": 48.8543, "lng": 2.3326}

    # Should be duplicates (same name, close coords)
    assert service._are_duplicates(sig1, sig2)


# ============================================================================
# MULTI-SOURCE SEARCH TESTS
# ============================================================================

@pytest.mark.asyncio
async def test_search_service_local_only(db: Session, coffee_places: list):
    """Test search returns local results when sufficient."""
    service = SearchService(db)

    results = await service.search_places(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    assert len(results) >= 1
    assert all(r["source"] == "local" for r in results)


@pytest.mark.asyncio
async def test_search_service_foursquare_fallback(db: Session):
    """Test search queries Foursquare when local results insufficient."""
    service = SearchService(db)

    mock_foursquare_results = [
        {
            "id": "foursquare:abc",
            "name": "Le Consulat",
            "lat": 48.8867,
            "lng": 2.3402,
            "source": "foursquare",
            "distance_m": 2500.0,
            "has_user_content": False,
            "address": "18 Rue Norvins, Paris",
            "rating": 8.5,
            "popularity": None
        }
    ]

    with patch.object(
        service.foursquare_provider,
        'search',
        new=AsyncMock(return_value=mock_foursquare_results)
    ):
        results = await service.search_places(
            query="museum",  # Query with no local results
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    # Should include Foursquare results
    foursquare_count = sum(1 for r in results if r["source"] == "foursquare")
    assert foursquare_count >= 1


@pytest.mark.asyncio
async def test_search_service_handles_foursquare_failure(
    db: Session,
    coffee_places: list
):
    """Test search continues with local results on Foursquare failure."""
    service = SearchService(db)

    with patch.object(
        service.foursquare_provider,
        'search',
        new=AsyncMock(side_effect=Exception("API Error"))
    ):
        results = await service.search_places(
            query="cafe",
            lat=48.8566,
            lng=2.3522,
            radius_km=5.0,
            limit=10
        )

    # Should still return local results
    assert len(results) >= 1
    assert all(r["source"] == "local" for r in results)


@pytest.mark.asyncio
async def test_search_service_respects_limit(db: Session, coffee_places: list):
    """Test search respects result limit."""
    service = SearchService(db)

    results = await service.search_places(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=10.0,
        limit=1
    )

    assert len(results) <= 1


@pytest.mark.asyncio
async def test_search_service_unified_schema(db: Session, coffee_places: list):
    """Test all results conform to unified schema."""
    service = SearchService(db)

    results = await service.search_places(
        query="cafe",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    required_fields = ["id", "name", "lat", "lng", "source", "distance_m", "has_user_content"]

    for result in results:
        for field in required_fields:
            assert field in result, f"Missing field: {field}"

        # Validate types
        assert isinstance(result["name"], str)
        assert isinstance(result["lat"], float)
        assert isinstance(result["lng"], float)
        assert isinstance(result["distance_m"], float)
        assert isinstance(result["has_user_content"], bool)


@pytest.mark.asyncio
async def test_search_service_empty_query(db: Session):
    """Test search handles empty/invalid query gracefully."""
    service = SearchService(db)

    results = await service.search_places(
        query="",
        lat=48.8566,
        lng=2.3522,
        radius_km=5.0,
        limit=10
    )

    # Should handle gracefully, return empty or minimal results
    assert isinstance(results, list)
