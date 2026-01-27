"""
Manual integration test for Session 14.

Run: python tests/test_session14_search.py
"""

import asyncio
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.config import settings
from app.services.search_service import SearchService
from app.utils.search_normalizer import normalize_query, normalize_coords, normalize_radius
from app.utils.cache_keys import make_search_key


def test_normalization():
    """Test normalization utilities."""
    print("\n=== Testing Normalization ===")
    
    # Query normalization
    query = normalize_query("  Coffee  SHOP!!  ")
    print(f"Normalized query: '{query}'")
    assert query == "coffee shop", "Query normalization failed"
    
    # Coordinate normalization
    lat, lng = normalize_coords(48.858370123, 2.294481987)
    print(f"Normalized coords: {lat}, {lng}")
    assert lat == 48.8584, "Lat normalization failed"
    assert lng == 2.2945, "Lng normalization failed"
    
    # Radius normalization
    radius = normalize_radius(100)
    print(f"Normalized radius: {radius}km")
    assert radius == 50.0, "Radius normalization failed"
    
    print("✅ All normalization tests passed")


def test_cache_keys():
    """Test cache key generation."""
    print("\n=== Testing Cache Keys ===")
    
    key1 = make_search_key("coffee", 48.8584, 2.2945, 5.0)
    key2 = make_search_key("coffee", 48.8584, 2.2945, 5.0)
    
    print(f"Key 1: {key1}")
    print(f"Key 2: {key2}")
    
    assert key1 == key2, "Keys not deterministic"
    assert "coffee" in key1, "Key not human-readable"
    
    print("✅ Cache key tests passed")

@pytest.mark.asyncio
async def test_search_service():
    """Test SearchService."""
    print("\n=== Testing SearchService ===")
    
    # Create DB session
    engine = create_engine(settings.SUPABASE_DB_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    try:
        service = SearchService(db)
        
        results = await service.search_places(
            query="coffee",
            lat=48.8584,
            lng=2.2945,
            radius_km=5.0
        )
        
        print(f"Search results: {results}")
        assert isinstance(results, list), "Should return list"
        print("✅ SearchService tests passed")
        
    finally:
        db.close()

@pytest.mark.asyncio
async def test_database():
    """Test database schema."""
    print("\n=== Testing Database Schema ===")
    
    from sqlalchemy import inspect, text
    
    engine = create_engine(settings.SUPABASE_DB_URL)
    inspector = inspect(engine)
    
    # Check search_vector column
    columns = [col['name'] for col in inspector.get_columns('trip_places')]
    assert 'search_vector' in columns, "search_vector column missing"
    print("✅ search_vector column exists")
    
    # Check signal tables
    tables = inspector.get_table_names()
    assert 'search_events' in tables, "search_events table missing"
    assert 'place_views' in tables, "place_views table missing"
    assert 'place_saves' in tables, "place_saves table missing"
    print("✅ Signal tables exist")
    
    # Check trigger
    with engine.connect() as conn:
        result = conn.execute(text(
            "SELECT tgname FROM pg_trigger WHERE tgrelid = 'trip_places'::regclass AND tgname = 'tsvector_update'"
        ))
        trigger = result.scalar()
        assert trigger == 'tsvector_update', "Trigger not found"
        print("✅ Auto-update trigger exists")
    
    print("✅ Database schema tests passed")


async def main():
    """Run all tests."""
    print("=" * 60)
    print("SESSION 14 INTEGRATION TEST")
    print("=" * 60)
    
    test_normalization()
    test_cache_keys()
    await test_search_service()
    await test_database()
    
    print("\n" + "=" * 60)
    print("✅ ALL SESSION 14 TESTS PASSED")
    print("=" * 60)
    print("\nSession 14 complete! Ready for Session 15.")


if __name__ == "__main__":
    asyncio.run(main())
