"""
review_parser.py — Layer 7: Normalise and enrich extracted reviews

Responsibilities:
- Parse relative dates ("2 months ago") → approximate ISO dates
- Detect language
- Deduplicate within a batch
- Merge proto + DOM results intelligently
"""
import re, hashlib
from datetime import datetime, timedelta
from typing import List, Optional
from loguru import logger

from .models import Review


# Relative date patterns (English — extend for other locales)
RELATIVE_DATE_PATTERNS = [
    (r"(\d+)\s+year",   "years"),
    (r"(\d+)\s+month",  "months"),
    (r"(\d+)\s+week",   "weeks"),
    (r"(\d+)\s+day",    "days"),
    (r"a\s+year",       "1_year"),
    (r"a\s+month",      "1_month"),
    (r"a\s+week",       "1_week"),
    (r"yesterday",      "1_day"),
]


class ReviewParser:
    def __init__(self):
        self._seen_ids: set = set()

    def normalise_batch(self, reviews: List[Review]) -> List[Review]:
        """Normalise a list of reviews: parse dates, detect lang, dedupe."""
        normalised = []
        for r in reviews:
            r = self._parse_date(r)
            r = self._detect_language(r)
            if r.review_id not in self._seen_ids:
                self._seen_ids.add(r.review_id)
                normalised.append(r)
        logger.debug(f"[parser] {len(normalised)}/{len(reviews)} unique after normalise")
        return normalised

    def merge(self, proto_reviews: List[Review], dom_reviews: List[Review]) -> List[Review]:
        """
        Merge proto and DOM results.
        Proto wins on data quality; DOM fills gaps if proto missed some.
        """
        proto_ids = {r.review_id for r in proto_reviews}
        dom_only = [r for r in dom_reviews if r.review_id not in proto_ids]

        if dom_only:
            logger.info(f"[parser] DOM fallback added {len(dom_only)} reviews not in proto")

        merged = proto_reviews + dom_only
        return self.normalise_batch(merged)

    def _parse_date(self, review: Review) -> Review:
        """Convert relative date string to approximate ISO date."""
        if review.review_date_iso:
            return review  # already parsed

        raw = (review.review_date or "").lower().strip()
        if not raw:
            return review

        now = datetime.utcnow()
        approx: Optional[datetime] = None

        for pattern, kind in RELATIVE_DATE_PATTERNS:
            m = re.search(pattern, raw)
            if m:
                if "_" in kind:
                    n, unit = kind.split("_")
                    n = int(n)
                else:
                    n = int(m.group(1)) if m.lastindex else 1
                    unit = kind

                if unit == "years":
                    approx = now - timedelta(days=365 * n)
                elif unit == "months":
                    approx = now - timedelta(days=30 * n)
                elif unit == "weeks":
                    approx = now - timedelta(weeks=n)
                elif unit == "days":
                    approx = now - timedelta(days=n)
                break

        if approx:
            review.review_date_iso = approx.strftime("%Y-%m-%d")
        return review

    def _detect_language(self, review: Review) -> Review:
        """Best-effort language detection on review text."""
        if review.language or not review.text:
            return review
        try:
            from langdetect import detect
            review.language = detect(review.text)
        except Exception:
            review.language = "unknown"
        return review