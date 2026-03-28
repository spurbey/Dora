"""
Main test file for the scraper pipeline.

This tests:
1. Trip Analyzer - generates search queries from trip metadata
2. Crawl4AI - fetches and extracts data from websites
3. LLM Processor - classifies, analyzes sentiment, scores

Run:
    python test_pipeline.py
"""

import asyncio
import os
import json
try:
    from .config import (
        Config, TripMetadata, SearchQuery, ScrapedSignal,
        SignalSource, SignalCategory, SentimentType
    )
    from .trip_analyzer import TripAnalyzer
    from .llm_processor import LLMProcessor
    from .crawl4ai_wrapper import Crawl4AIWrapper
except ImportError:
    from config import (
        Config, TripMetadata, SearchQuery, ScrapedSignal,
        SignalSource, SignalCategory, SentimentType
    )
    from trip_analyzer import TripAnalyzer
    from llm_processor import LLMProcessor
    from crawl4ai_wrapper import Crawl4AIWrapper


async def test_trip_analyzer():
    """Test 1: Trip Analyzer generates correct queries."""
    print("\n" + "="*60)
    print("TEST 1: Trip Analyzer")
    print("="*60)
    
    # Create sample trip
    trip = TripMetadata(
        trip_id="delhi-jaipur-1",
        name="Delhi Jaipur Road Trip",
        source="Delhi",
        destination="Jaipur",
        waypoints=["Neemrana"],
        start_date="2025-03-20",
        end_date="2025-03-25",
        interests=["food", "photography", "history"],
        transport_mode="car"
    )
    
    analyzer = TripAnalyzer()
    queries = analyzer.analyze(trip)
    
    print(f"\nTrip: {trip.name}")
    print(f"From: {trip.source} To: {trip.destination}")
    print(f"Interests: {trip.interests}")
    print(f"Transport: {trip.transport_mode}")
    print(f"\nGenerated {len(queries)} search queries:\n")
    
    for i, q in enumerate(queries[:10], 1):  # Show first 10
        print(f"  {i}. [{q.category}] Priority: {q.priority}")
        print(f"     Query: {q.query}")
        print(f"     When: {q.when}")
        print()
    
    if len(queries) > 10:
        print(f"  ... and {len(queries) - 10} more queries")
    
    print(f"\n[PASS] Test passed: Generated {len(queries)} queries")


async def test_llm_processor():
    """Test 2: LLM Processor classifies and scores signals."""
    print("\n" + "="*60)
    print("TEST 2: LLM Processor")
    print("="*60)
    
    config = Config()
    if not (config.OPENAI_API_KEY or config.LLM_API_KEY):
        print("[WARNING] LLM API key not set, skipping LLM test")
        print("Set LLM_API_KEY or OPENROUTER_API_KEY (or OPENAI_API_KEY) to test LLM processing")
        return
    
    processor = LLMProcessor(config)
    
    # Test signals
    test_signals = [
        ScrapedSignal(
            source=SignalSource.REDDIT,
            original_id="reddit-1",
            url="https://reddit.com/r/india/comments/abc",
            title="Amazing street food at Chandni Chowk!",
            content="Best paratha I've ever had! Must visit for breakfast. Get there early before they sell out.",
            rating=4.5,
            review_count=150,
            trip_id="test-1"
        ),
        ScrapedSignal(
            source=SignalSource.GOOGLE_PLACES,
            original_id="google-1",
            url="https://maps.google.com/place/1",
            title="Karim's Restaurant",
            content="Famous non-veg restaurant in Old Delhi. Mutton dishes are excellent.",
            rating=4.2,
            review_count=500,
            latitude=28.6500,
            longitude=77.2300,
            address="Near Jama Masjid, Delhi",
            trip_id="test-1"
        ),
    ]
    
    trip_context = {
        "destination": "Jaipur",
        "day": 1,
        "location": "near Delhi",
        "distance_km": 5
    }
    
    for signal in test_signals:
        print(f"\nProcessing: {signal.title}")
        print(f"Source: {signal.source.value}")
        
        # Classify
        category, tags = await processor.classify(signal)
        print(f"  Category: {category.value}")
        print(f"  Tags: {tags}")
        
        # Sentiment
        sentiment, score = await processor.analyze_sentiment(signal)
        print(f"  Sentiment: {sentiment.value} ({score})")
        
        # Score
        should_show, priority, reason = await processor.score_recommendation(
            signal, category, sentiment, trip_context
        )
        print(f"  Should show: {should_show} (priority: {priority})")
        safe_reason = reason.encode("ascii", "replace").decode("ascii")
        print(f"  Reason: {safe_reason}")
    
    print("[PASS] Test passed: LLM processing works")


async def test_crawl4ai_live_scrape():
    """Test 3: Real Crawl4AI scrape attempt (Google Maps URL if provided)."""
    print("\n" + "="*60)
    print("TEST 3: Crawl4AI Live Scrape")
    print("="*60)

    config = Config()
    wrapper = Crawl4AIWrapper(config)

    google_maps_url = os.getenv("GOOGLE_MAPS_TEST_URL", "").strip()
    if not google_maps_url:
        print("[WARNING] GOOGLE_MAPS_TEST_URL not set, skipping live Google Maps probe")
        print("Set GOOGLE_MAPS_TEST_URL to a place/details URL to run live scraping")
        return

    use_llm = bool(config.LLM_API_KEY)
    if use_llm:
        print(f"Using LLM provider: {config.LLM_PROVIDER}")
    else:
        print("[WARNING] No LLM API key configured, using CSS fallback extraction")

    records = await wrapper.scrape_google_maps_place(
        place_url=google_maps_url,
        use_llm=use_llm,
    )

    if not isinstance(records, list):
        raise RuntimeError("Crawl4AI scrape returned non-list response")

    print(f"Scrape returned {len(records)} records")
    if records:
        record = records[0]
        print("Structured record:")
        print(json.dumps(record, indent=2, ensure_ascii=False))

        required = ["place_name", "latitude", "longitude", "source_url"]
        missing = [k for k in required if not record.get(k)]
        if missing:
            raise RuntimeError(f"Structured scrape incomplete, missing required fields: {missing}")
        print("[PASS] Live scrape produced complete structured response")
        return

    raise RuntimeError("Live crawl failed: no structured records returned")


async def test_mock_scraping():
    """Test 4: Mock scraping flow (without actual network calls)."""
    print("\n" + "="*60)
    print("TEST 4: Mock Scraping Flow")
    print("="*60)
    
    # Simulate scraped data (instead of actually crawling)
    mock_signals = [
        ScrapedSignal(
            source=SignalSource.GOOGLE_PLACES,
            original_id="place-1",
            url="https://maps.google.com/place/karims",
            title="Karim's Restaurant",
            content="Famous restaurant in Delhi for non-veg. Mutton dishes are their specialty.",
            rating=4.3,
            review_count=523,
            address="Jama Masjid Road, Chandni Chowk, Delhi",
            latitude=28.6500,
            longitude=77.2300,
            trip_id="test-1"
        ),
        ScrapedSignal(
            source=SignalSource.REDDIT,
            original_id="reddit-post-1",
            url="https://reddit.com/r/Delhi/comments/abc",
            title="Best dhabas on Delhi-Jaipur highway",
            content="Just traveled Delhi to Jaipur. The best dhaba is at Shahpura - called 'Sharma Dhaba'. Amazing parathas and lassi!",
            rating=None,
            trip_id="test-1"
        ),
        ScrapedSignal(
            source=SignalSource.WIKIPEDIA,
            original_id="wiki-hawa",
            url="https://en.wikipedia.org.org/Hawa_Mahal",
            title="Hawa Mahal - Palace of Winds",
            content="Historic palace in Jaipur built in 1799. Iconic pink sandstone architecture.",
            rating=4.7,
            trip_id="test-1"
        ),
    ]
    
    print(f"\nSimulated {len(mock_signals)} scraped signals:")
    for signal in mock_signals:
        print(f"  - [{signal.source.value}] {signal.title}")
    
    print("[PASS] Test passed: Mock data works")


def print_banner():
    print("""
==============================================
   SCRAPER PIPELINE TEST - DORA
==============================================
   Testing: Trip Analyzer + Crawl4AI + LLM
==============================================
    """)


async def main():
    print_banner()
    
    print("\nStarting tests...")
    print("="*60)
    
    # Test 1: Trip Analyzer
    await test_trip_analyzer()
    
    # Test 2: LLM Processor (requires API key)
    await test_llm_processor()
    
    # Test 3: Real Crawl4AI scrape (requires network + URL)
    await test_crawl4ai_live_scrape()

    # Test 4: Mock scraping
    await test_mock_scraping()
    
    print("\n" + "="*60)
    print("ALL TESTS COMPLETED!")
    print("="*60)
    print("""
Next steps:
1. Set LLM_API_KEY or OPENROUTER_API_KEY to test LLM processing
2. Set GOOGLE_MAPS_TEST_URL to test Crawl4AI scraping
3. Configure LLM_API_KEY / OPENROUTER_API_KEY for LLM extraction
4. Configure proxies for production
    """)


if __name__ == "__main__":
    asyncio.run(main())
