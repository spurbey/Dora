"""
Tests for search utility functions.

Tests:
    - Query normalization
    - Coordinate normalization
    - Radius clamping
    - Cache key generation
"""

import pytest
from app.utils.search_normalizer import normalize_query, normalize_coords, normalize_radius
from app.utils.cache_keys import make_search_key


class TestSearchNormalizer:
    """Test search input normalization."""
    
    def test_normalize_query_basic(self):
        """Test basic query normalization."""
        assert normalize_query("Coffee Shop") == "coffee shop"
        assert normalize_query("  Coffee  ") == "coffee"
        assert normalize_query("EIFFEL TOWER") == "eiffel tower"
    
    def test_normalize_query_special_chars(self):
        """Test special character handling."""
        assert normalize_query("café") == "café"  # Keep accents
        assert normalize_query("coffee!!") == "coffee"
        assert normalize_query("shop???") == "shop"
        assert normalize_query("o'brien's") == "o'brien's"  # Keep apostrophes
        assert normalize_query("co-op") == "co-op"  # Keep hyphens
    
    def test_normalize_query_whitespace(self):
        """Test whitespace normalization."""
        assert normalize_query("coffee    shop") == "coffee shop"
        assert normalize_query("\n\tcoffee\t\n") == "coffee"
    
    def test_normalize_query_empty(self):
        """Test empty/None handling."""
        assert normalize_query("") == ""
        assert normalize_query("   ") == ""
    
    def test_normalize_coords_rounding(self):
        """Test coordinate rounding to 4 decimals."""
        lat, lng = normalize_coords(48.858370123456, 2.294481987654)
        assert lat == 48.8584
        assert lng == 2.2945
    
    def test_normalize_coords_already_rounded(self):
        """Test coordinates already at 4 decimals."""
        lat, lng = normalize_coords(48.8584, 2.2945)
        assert lat == 48.8584
        assert lng == 2.2945
    
    def test_normalize_coords_precision(self):
        """Test rounding preserves 4 decimal precision."""
        lat, lng = normalize_coords(48.12345, 2.56789)
        assert lat == 48.1235  # Rounds up
        assert lng == 2.5679   # Rounds up
    
    def test_normalize_radius_valid(self):
        """Test valid radius values."""
        assert normalize_radius(5.0) == 5.0
        assert normalize_radius(10.5) == 10.5
        assert normalize_radius(0.5) == 0.5
    
    def test_normalize_radius_max_clamp(self):
        """Test radius clamping to maximum."""
        assert normalize_radius(100) == 50.0  # Max 50km
        assert normalize_radius(500) == 50.0
    
    def test_normalize_radius_negative(self):
        """Test negative radius handling."""
        assert normalize_radius(-5) == 5.0  # Default to 5km
        assert normalize_radius(-100) == 5.0


class TestCacheKeys:
    """Test cache key generation."""
    
    def test_make_search_key_deterministic(self):
        """Test same inputs produce same key."""
        key1 = make_search_key("coffee", 48.8584, 2.2945, 5.0)
        key2 = make_search_key("coffee", 48.8584, 2.2945, 5.0)
        assert key1 == key2
    
    def test_make_search_key_different_inputs(self):
        """Test different inputs produce different keys."""
        key1 = make_search_key("coffee", 48.8584, 2.2945, 5.0)
        key2 = make_search_key("tea", 48.8584, 2.2945, 5.0)
        assert key1 != key2
    
    def test_make_search_key_format(self):
        """Test key format is human-readable."""
        key = make_search_key("coffee", 48.8584, 2.2945, 5.0)
        assert "coffee" in key
        assert "48.8584" in key
        assert "2.2945" in key
        assert "5.0" in key or "5" in key
    
    def test_make_search_key_with_filters(self):
        """Test key generation with filters."""
        key1 = make_search_key("coffee", 48.8584, 2.2945, 5.0, filters=None)
        key2 = make_search_key("coffee", 48.8584, 2.2945, 5.0, filters={"type": "cafe"})
        assert key1 != key2  # Filters should change key