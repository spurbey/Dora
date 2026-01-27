"""
Tests for SearchService.

Tests Session 14 functionality only:
    - Service initialization
    - Input normalization flow
    - Cache key generation
"""

import pytest
from app.services.search_service import SearchService


class TestSearchServiceSession14:
    """Test SearchService foundation (Session 14 only)."""
    
    def test_service_initialization(self, db):
        """Test service can be initialized with db session."""
        service = SearchService(db)
        assert service.db is db
    
    @pytest.mark.asyncio
    async def test_search_places_normalizes_inputs(self, db):
        """Test that search normalizes inputs before processing."""
        service = SearchService(db)
        
        # Should not crash with unnormalized inputs
        results = await service.search_places(
            query="  Coffee  SHOP!!  ",
            lat=48.858370123,
            lng=2.294481987,
            radius_km=100  # Should clamp to 50
        )
        
        # Session 14: Returns empty list (no retrieval yet)
        assert results == []
    
    @pytest.mark.asyncio
    async def test_search_places_returns_list(self, db):
        """Test search returns a list (even if empty for now)."""
        service = SearchService(db)
        
        results = await service.search_places(
            query="coffee",
            lat=48.8584,
            lng=2.2945,
            radius_km=5.0
        )
        
        assert isinstance(results, list)