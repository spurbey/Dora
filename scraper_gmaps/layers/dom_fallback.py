"""
dom_fallback.py — Layer 6b: CSS/XPath extraction when proto decode fails

Only activated when proto_decoder returns 0 reviews.
More brittle than network capture but covers edge cases.
"""
import re, hashlib
from typing import List, Optional
from loguru import logger
from playwright.async_api import Page

from .models import Review


# Selectors — update when Google changes class names
DOM_SELECTORS = {
    "review_cards":   "div[data-review-id]",
    "author":         "div.d4r55, span.X43Kjb, button[aria-label*='photo']",
    "rating":         "span[aria-label*='star'], span[role='img'][aria-label*='star']",
    "text":           "span.wiI7pd, div.Jtu6Td span",
    "date":           "span.rsqaWe, span[class*='dehysf']",
    "owner_response": "div.CDe7pd span, div[class*='owner'] span",
    "photos":         "button[aria-label*='photo'] img",
}


class DomFallback:
    def __init__(self, page: Page, place_id: str):
        self.page = page
        self.place_id = place_id

    async def extract_reviews(self) -> List[Review]:
        """Extract all visible review cards from the DOM."""
        cards = await self.page.query_selector_all(DOM_SELECTORS["review_cards"])
        if not cards:
            logger.warning("[dom] No review cards found in DOM")
            return []

        reviews = []
        for card in cards:
            try:
                r = await self._extract_card(card)
                if r:
                    reviews.append(r)
            except Exception as e:
                logger.debug(f"[dom] Card extraction error: {e}")

        logger.info(f"[dom] Extracted {len(reviews)} reviews from DOM")
        return reviews

    async def _extract_card(self, card) -> Optional[Review]:
        review_id = await card.get_attribute("data-review-id") or ""

        author = await self._text(card, DOM_SELECTORS["author"])
        date_str = await self._text(card, DOM_SELECTORS["date"])
        text = await self._text(card, DOM_SELECTORS["text"])
        rating = await self._extract_rating(card)
        owner_resp = await self._text(card, DOM_SELECTORS["owner_response"])

        photos = await card.query_selector_all(DOM_SELECTORS["photos"])
        photo_count = len(photos)

        if not review_id:
            # Synthesize a stable ID from content
            raw = f"{author}|{text}|{date_str}"
            review_id = hashlib.md5(raw.encode()).hexdigest()[:12]

        return Review(
            review_id=review_id,
            place_id=self.place_id,
            author_name=author or "Unknown",
            author_id=None,
            rating=rating,
            text=text,
            language=None,
            review_date=date_str,
            review_date_iso=None,
            owner_response=owner_resp or None,
            has_photos=photo_count > 0,
            photo_count=photo_count,
            source="dom",
        )

    async def _extract_rating(self, card) -> Optional[int]:
        """Parse 'Rated 4 out of 5' or similar aria-label."""
        try:
            el = await card.query_selector(DOM_SELECTORS["rating"])
            if not el:
                return None
            label = await el.get_attribute("aria-label") or ""
            nums = re.findall(r"\d+", label)
            if nums:
                return int(nums[0])
        except Exception:
            pass
        return None

    async def _text(self, card, selector: str) -> str:
        """Get inner text from first matching child element."""
        try:
            el = await card.query_selector(selector)
            if el:
                return (await el.inner_text()).strip()
        except Exception:
            pass
        return ""