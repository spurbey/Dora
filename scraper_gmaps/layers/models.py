"""
models.py — canonical data schema shared across all layers
"""
from dataclasses import dataclass, field
from typing import Optional
from datetime import datetime
import hashlib, json


@dataclass
class PlaceInfo:
    place_id: str          # Google's stable place ID
    canonical_url: str
    name: str
    address: Optional[str] = None
    rating: Optional[float] = None
    total_reviews: Optional[int] = None
    crawled_at: datetime = field(default_factory=datetime.utcnow)


@dataclass
class Review:
    # Identity
    review_id: str                  # stable synthetic key
    place_id: str

    # Content
    author_name: str
    author_id: Optional[str]        # Google profile ID when available
    rating: Optional[int]           # 1–5
    text: Optional[str]
    language: Optional[str]

    # Dates
    review_date: Optional[str]      # raw string from Maps ("2 months ago")
    review_date_iso: Optional[str]  # parsed ISO date when possible
    crawl_date: datetime = field(default_factory=datetime.utcnow)

    # Owner response
    owner_response: Optional[str] = None
    owner_response_date: Optional[str] = None

    # Media
    has_photos: bool = False
    photo_count: int = 0

    # Provenance
    source: str = "proto"           # "proto" | "dom"
    payload_hash: Optional[str] = None

    def compute_hash(self) -> str:
        payload = json.dumps({
            "text": self.text,
            "rating": self.rating,
            "owner_response": self.owner_response,
        }, sort_keys=True)
        return hashlib.sha256(payload.encode()).hexdigest()[:16]

    def __post_init__(self):
        if not self.payload_hash:
            self.payload_hash = self.compute_hash()


@dataclass
class RunResult:
    place_id: str
    success: bool
    captured_count: int = 0
    extracted_count: int = 0
    stored_count: int = 0
    errors: list = field(default_factory=list)
    session_rotated: bool = False
    duration_seconds: float = 0.0