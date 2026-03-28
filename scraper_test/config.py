"""
Data models and configuration for scraper pipeline.
"""

import os
from dataclasses import dataclass, field
from typing import Optional
from datetime import datetime
from enum import Enum
from pathlib import Path


class SignalSource(Enum):
    GOOGLE_PLACES = "google_places"
    REDDIT = "reddit"
    TRIPADVISOR = "tripadvisor"
    WIKIPEDIA = "wikipedia"


class SignalCategory(Enum):
    RESTAURANT = "restaurant"
    CAFE = "cafe"
    BAR = "bar"
    STREET_FOOD = "street_food"
    HOTEL = "hotel"
    HOSTEL = "hostel"
    RESORT = "resort"
    AIRBNB = "airbnb"
    ATTRACTION = "attraction"
    LANDMARK = "landmark"
    MUSEUM = "museum"
    PARK = "park"
    SHOPPING = "shopping"
    MARKET = "market"
    MALL = "mall"
    TRANSPORT = "transport"
    STATION = "station"
    AIRPORT = "airport"
    NATURE = "nature"
    BEACH = "beach"
    MOUNTAIN = "mountain"
    WARNING = "warning"
    HAZARD = "hazard"
    SCAM_ALERT = "scam_alert"
    TRAVEL_INFO = "travel_info"
    ACTIVITIES = "activities"
    UTILITY = "utility"


class SentimentType(Enum):
    POSITIVE = "positive"
    NEGATIVE = "negative"
    MIXED = "mixed"
    NEUTRAL = "neutral"


class SignalTiming(Enum):
    BEFORE_TRIP = "before_trip"
    DURING_TRIP = "during_trip"
    ON_ROUTE = "on_route"
    DAY_1 = "day_1"
    DAY_2 = "day_2"
    DAY_3 = "day_3"
    DAY_4 = "day_4"
    DAY_5 = "day_5"
    DAY_6 = "day_6"
    DAY_7 = "day_7"
    AT_DESTINATION = "at_destination"


@dataclass
class TripMetadata:
    """User's trip metadata - input to the system."""
    trip_id: str
    name: str
    source: str
    destination: str
    start_date: str
    end_date: str
    waypoints: list[str] = field(default_factory=list)
    interests: list[str] = field(default_factory=list)
    transport_mode: str = "car"


@dataclass
class SearchQuery:
    """Query to be sent to scrapers."""
    query: str
    category: str
    priority: int = 5
    when: Optional[str] = None
    sources: list[SignalSource] = field(default_factory=list)


@dataclass
class ScrapedSignal:
    """Raw signal from scraper before LLM processing."""
    source: SignalSource
    original_id: str
    url: str
    title: str
    content: str
    rating: Optional[float] = None
    review_count: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address: Optional[str] = None
    photos: list[str] = field(default_factory=list)
    timestamp: Optional[datetime] = None
    trip_id: str = ""


@dataclass
class ProcessedSignal:
    """Final signal after LLM processing."""
    source: SignalSource
    original_id: str
    url: str
    title: str
    content: str
    rating: Optional[float]
    category: SignalCategory
    sentiment: SentimentType
    sentiment_score: float
    should_show: bool
    priority: int
    reason: str
    tags: list[str] = field(default_factory=list)
    when_to_show: Optional[SignalTiming] = None
    trip_id: str = ""
    created_at: datetime = field(default_factory=datetime.utcnow)


class Config:
    """Runtime configuration loaded from environment variables."""

    def __init__(self):
        self.OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
        self.OPENROUTER_API_KEY: str = os.getenv("OPENROUTER_API_KEY", "")
        self.LLM_API_KEY: str = os.getenv(
            "LLM_API_KEY",
            self.OPENROUTER_API_KEY or self.OPENAI_API_KEY
        )
        self.LLM_PROVIDER: str = os.getenv(
            "LLM_PROVIDER",
            "openrouter/nvidia/nemotron-3-super-120b-a12b:free",
        )
        self.LLM_BASE_URL: str = os.getenv(
            "LLM_BASE_URL",
            "https://openrouter.ai/api/v1",
        )

        self.CRAWL4AI_HEADLESS: bool = os.getenv(
            "CRAWL4AI_HEADLESS", "true"
        ).lower() in ("1", "true", "yes")
        self.CRAWL4AI_STEALTH: bool = os.getenv(
            "CRAWL4AI_STEALTH", "true"
        ).lower() in ("1", "true", "yes")
        self.CRAWL4AI_VERBOSE: bool = os.getenv(
            "CRAWL4AI_VERBOSE", "false"
        ).lower() in ("1", "true", "yes")

        proxy_env = os.getenv("PROXY_LIST", "")
        self.PROXY_LIST: list[str] = [
            item.strip() for item in proxy_env.split(",") if item.strip()
        ]
        self.PROXY_ENABLED: bool = bool(self.PROXY_LIST) and os.getenv(
            "PROXY_ENABLED", "false"
        ).lower() in ("1", "true", "yes")

        default_crawl_dir = Path(__file__).resolve().parent / ".crawl4ai_runtime"
        self.CRAWL4AI_BASE_DIRECTORY: str = os.getenv(
            "CRAWL4_AI_BASE_DIRECTORY",
            str(default_crawl_dir),
        )

        default_chat_model = self.LLM_PROVIDER.replace("openrouter/", "")
        # Retained for existing llm_processor usage.
        self.LLM_EXTRACTION_MODEL: str = os.getenv(
            "LLM_EXTRACTION_MODEL", default_chat_model
        )
        self.LLM_CLASSIFICATION_MODEL: str = os.getenv(
            "LLM_CLASSIFICATION_MODEL", default_chat_model
        )
        self.LLM_SENTIMENT_MODEL: str = os.getenv(
            "LLM_SENTIMENT_MODEL", default_chat_model
        )
        self.LLM_RANKING_MODEL: str = os.getenv(
            "LLM_RANKING_MODEL", default_chat_model
        )


config = Config()
