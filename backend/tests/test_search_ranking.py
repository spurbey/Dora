"""
Tests for search ranking algorithm (Session 16).

Tests:
- Source weight prioritization
- Text relevance scoring
- Popularity influence
- Freshness scoring
- Combined score calculation
- Debug info generation
"""

import pytest
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session

from app.services.search_service import SearchService


class TestSourceScoring:
    """Test source weight scoring component."""

    def test_local_source_scores_highest(self, db: Session):
        """Local sources should score 1.0."""
        service = SearchService(db)

        result = {"source": "local", "name": "Test"}
        score = service._calculate_source_score(result)

        assert score == 1.0

    def test_foursquare_source_scores_lower(self, db: Session):
        """Foursquare sources should score 0.6."""
        service = SearchService(db)

        result = {"source": "foursquare", "name": "Test"}
        score = service._calculate_source_score(result)

        assert score == 0.6

    def test_unknown_source_gets_default(self, db: Session):
        """Unknown sources should get default 0.5."""
        service = SearchService(db)

        result = {"source": "unknown", "name": "Test"}
        score = service._calculate_source_score(result)

        assert score == 0.5


class TestTextRelevanceScoring:
    """Test text relevance scoring component."""

    def test_local_with_text_relevance(self, db: Session):
        """Local results with text_relevance should use it."""
        service = SearchService(db)

        result = {"name": "Coffee Shop", "text_relevance": 0.85}
        score = service._calculate_text_score(result, "coffee")

        assert score == 0.85

    def test_external_exact_match(self, db: Session):
        """External results with exact match should score 1.0."""
        service = SearchService(db)

        result = {"name": "Coffee Bean"}
        score = service._calculate_text_score(result, "coffee")

        assert score == 1.0

    def test_external_word_match(self, db: Session):
        """External results with word match should score 0.7."""
        service = SearchService(db)

        result = {"name": "The Great Coffee Place"}
        score = service._calculate_text_score(result, "coffee place")

        assert score == 0.7

    def test_external_weak_match(self, db: Session):
        """External results with weak similarity should score lower."""
        service = SearchService(db)

        result = {"name": "Restaurant"}
        score = service._calculate_text_score(result, "coffee")

        assert score <= 0.3


class TestPopularityScoring:
    """Test popularity scoring component."""

    def test_local_with_high_saves(self, db: Session):
        """Local with 100 saves should score 1.0."""
        service = SearchService(db)

        result = {"source": "local", "popularity": 100}
        score = service._calculate_popularity_score(result)

        assert score == 1.0

    def test_local_with_medium_saves(self, db: Session):
        """Local with 50 saves should score 0.5."""
        service = SearchService(db)

        result = {"source": "local", "popularity": 50}
        score = service._calculate_popularity_score(result)

        assert score == 0.5

    def test_local_with_no_saves(self, db: Session):
        """Local with 0 saves should score 0.0."""
        service = SearchService(db)

        result = {"source": "local", "popularity": 0}
        score = service._calculate_popularity_score(result)

        assert score == 0.0

    def test_external_with_rating(self, db: Session):
        """External with rating 8/10 should score 0.8."""
        service = SearchService(db)

        result = {"source": "foursquare", "rating": 8.0}
        score = service._calculate_popularity_score(result)

        assert score == 0.8

    def test_external_without_rating(self, db: Session):
        """External without rating should get default 0.1."""
        service = SearchService(db)

        result = {"source": "foursquare", "rating": None}
        score = service._calculate_popularity_score(result)

        assert score == 0.1


class TestFreshnessScoring:
    """Test freshness scoring component."""

    def test_very_fresh_local(self, db: Session):
        """Places < 7 days old should score 1.0."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)
        three_days_ago = now - timedelta(days=3)

        result = {"source": "local", "created_at": three_days_ago}
        score = service._calculate_freshness_score(result)

        assert score == 1.0

    def test_fresh_local(self, db: Session):
        """Places < 30 days old should score 0.8."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)
        twenty_days_ago = now - timedelta(days=20)

        result = {"source": "local", "created_at": twenty_days_ago}
        score = service._calculate_freshness_score(result)

        assert score == 0.8

    def test_moderate_age_local(self, db: Session):
        """Places < 90 days old should score 0.5."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)
        sixty_days_ago = now - timedelta(days=60)

        result = {"source": "local", "created_at": sixty_days_ago}
        score = service._calculate_freshness_score(result)

        assert score == 0.5

    def test_old_local(self, db: Session):
        """Places > 90 days old should score 0.3."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)
        hundred_days_ago = now - timedelta(days=100)

        result = {"source": "local", "created_at": hundred_days_ago}
        score = service._calculate_freshness_score(result)

        assert score == 0.3

    def test_external_gets_neutral(self, db: Session):
        """External results should get neutral 0.5."""
        service = SearchService(db)

        result = {"source": "foursquare"}
        score = service._calculate_freshness_score(result)

        assert score == 0.5


class TestCombinedScoring:
    """Test combined weighted score calculation."""

    def test_perfect_score(self, db: Session):
        """Perfect result should score 1.0."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)
        result = {
            "source": "local",  # 1.0 * 0.4 = 0.4
            "name": "Coffee Lab",
            "text_relevance": 1.0,  # 1.0 * 0.3 = 0.3
            "popularity": 100,  # 1.0 * 0.2 = 0.2
            "created_at": now  # 1.0 * 0.1 = 0.1
        }

        score_info = service._calculate_result_score(result, "coffee")

        assert score_info["source_score"] == 1.0
        assert score_info["text_score"] == 1.0
        assert score_info["popularity_score"] == 1.0
        assert score_info["freshness_score"] == 1.0
        # Use pytest.approx for floating point comparison
        assert score_info["final_score"] == pytest.approx(1.0, abs=0.01)

    def test_local_beats_external_same_quality(self, db: Session):
        """Local should rank higher than external with same quality."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)

        # Local result
        local_result = {
            "source": "local",
            "name": "Coffee Shop",
            "text_relevance": 0.8,
            "popularity": 50,
            "created_at": now - timedelta(days=30)
        }

        # External result with similar quality
        external_result = {
            "source": "foursquare",
            "name": "Coffee Shop",
            "rating": 8.0,
            "text_relevance": None
        }

        local_score = service._calculate_result_score(local_result, "coffee")
        external_score = service._calculate_result_score(external_result, "coffee")

        # Local should score higher due to source weight
        assert local_score["final_score"] > external_score["final_score"]

    def test_high_popularity_boosts_score(self, db: Session):
        """High popularity should significantly boost score."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)

        # Low popularity
        low_pop = {
            "source": "local",
            "name": "Place A",
            "text_relevance": 0.5,
            "popularity": 5,
            "created_at": now - timedelta(days=100)
        }

        # High popularity
        high_pop = {
            "source": "local",
            "name": "Place B",
            "text_relevance": 0.5,
            "popularity": 80,
            "created_at": now - timedelta(days=100)
        }

        low_score = service._calculate_result_score(low_pop, "test")
        high_score = service._calculate_result_score(high_pop, "test")

        # High popularity should score higher
        assert high_score["final_score"] > low_score["final_score"]
        assert high_score["popularity_contribution"] > low_score["popularity_contribution"]


class TestRankingOrchestration:
    """Test full ranking flow."""

    def test_rank_results_sorts_by_score(self, db: Session):
        """Results should be sorted by score descending."""
        service = SearchService(db)

        now = datetime.now(timezone.utc)

        results = [
            {
                "name": "Low Score",
                "source": "foursquare",
                "rating": 3.0,
                "lat": 48.8,
                "lng": 2.3
            },
            {
                "name": "High Score",
                "source": "local",
                "text_relevance": 1.0,
                "popularity": 100,
                "created_at": now,
                "lat": 48.8,
                "lng": 2.3
            },
            {
                "name": "Medium Score",
                "source": "local",
                "text_relevance": 0.5,
                "popularity": 20,
                "created_at": now - timedelta(days=60),
                "lat": 48.8,
                "lng": 2.3
            }
        ]

        ranked = service._rank_results(results, "test", debug=False)

        # Should be ordered by score
        assert ranked[0]["name"] == "High Score"
        assert ranked[1]["name"] == "Medium Score"
        assert ranked[2]["name"] == "Low Score"

        # All should have scores
        assert all("score" in r for r in ranked)

    def test_rank_results_adds_debug_info(self, db: Session):
        """Debug mode should add score breakdown."""
        service = SearchService(db)

        results = [
            {
                "name": "Test Place",
                "source": "local",
                "text_relevance": 0.8,
                "popularity": 50,
                "created_at": datetime.now(timezone.utc),
                "lat": 48.8,
                "lng": 2.3
            }
        ]

        ranked = service._rank_results(results, "test", debug=True)

        # Should have debug info
        assert "_debug" in ranked[0]
        assert "breakdown" in ranked[0]["_debug"]
        assert "final_score" in ranked[0]["_debug"]
        assert "source_contribution" in ranked[0]["_debug"]

    def test_rank_empty_results(self, db: Session):
        """Ranking empty list should return empty list."""
        service = SearchService(db)

        ranked = service._rank_results([], "test", debug=False)

        assert ranked == []


class TestDebugInfo:
    """Test debug info generation."""

    def test_debug_info_format(self, db: Session):
        """Debug info should have correct format."""
        service = SearchService(db)

        score_info = {
            "source_score": 1.0,
            "source_contribution": 0.4,
            "text_score": 0.8,
            "text_contribution": 0.24,
            "popularity_score": 0.5,
            "popularity_contribution": 0.1,
            "freshness_score": 1.0,
            "freshness_contribution": 0.1,
            "final_score": 0.84
        }

        debug = service._add_debug_info(score_info)

        assert debug["source_score"] == 1.0
        assert debug["source_contribution"] == 0.4
        assert debug["text_score"] == 0.8
        assert debug["text_contribution"] == 0.24
        assert debug["popularity_score"] == 0.5
        assert debug["popularity_contribution"] == 0.1
        assert debug["freshness_score"] == 1.0
        assert debug["freshness_contribution"] == 0.1
        assert debug["final_score"] == 0.84
        assert "breakdown" in debug
        assert "=" in debug["breakdown"]
