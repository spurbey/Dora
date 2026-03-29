"""
navigator.py — Layer 2: State machine for Google Maps navigation

States: SEARCH → PLACE_CARD → REVIEWS_TAB → SORTED → READY
Each transition has explicit wait conditions and error exits.
"""
import asyncio, re
from enum import Enum, auto
from typing import Optional
from loguru import logger
from playwright.async_api import Page, TimeoutError as PWTimeout


class NavState(Enum):
    INIT = auto()
    PLACE_CARD = auto()
    REVIEWS_TAB = auto()
    SORTED = auto()
    READY = auto()
    ERROR = auto()


# CSS selectors — these are the most brittle part; update when Maps changes
SEL = {
    "place_name":        'h1.DUwDvf, h1[class*="fontHeadline"]',
    "reviews_tab":       'button[aria-label*="review"], button[jsaction*="reviews"]',
    "reviews_container": 'div[data-review-id], div[jsaction*="review"]',
    "sort_button":       'button[data-value="sort"], button[aria-label*="Sort"]',
    "sort_newest":       'li[data-index="1"], [data-value="newestFirst"]',
    "review_card":       'div[data-review-id]',
    "total_reviews":     'span[aria-label*="reviews"], button[jsaction*="reviews"] span',
}


class Navigator:
    def __init__(self, page: Page, timeout: int = 15_000):
        self.page = page
        self.timeout = timeout
        self.state = NavState.INIT

    async def goto_place(self, url: str) -> bool:
        """Navigate to a Google Maps place URL and wait for the card."""
        logger.info(f"[nav] goto_place: {url}")
        try:
            await self.page.goto(url, wait_until="domcontentloaded", timeout=30_000)
            await self._wait_for(SEL["place_name"])
            self.state = NavState.PLACE_CARD
            logger.debug("[nav] → PLACE_CARD")
            return True
        except PWTimeout:
            logger.error("[nav] Timed out waiting for place card")
            self.state = NavState.ERROR
            return False

    async def open_reviews_tab(self) -> bool:
        """Click the reviews tab and wait for review cards to appear."""
        if self.state != NavState.PLACE_CARD:
            logger.warning(f"[nav] open_reviews_tab called in state {self.state}")
        try:
            tab = await self.page.wait_for_selector(SEL["reviews_tab"], timeout=self.timeout)
            if tab:
                await tab.click()
                await asyncio.sleep(1.5)  # animation settle
            await self._wait_for(SEL["reviews_container"])
            self.state = NavState.REVIEWS_TAB
            logger.debug("[nav] → REVIEWS_TAB")
            return True
        except PWTimeout:
            logger.error("[nav] Reviews tab not found or reviews container didn't load")
            self.state = NavState.ERROR
            return False

    async def sort_by_newest(self) -> bool:
        """Sort reviews by newest. Returns False if sort UI not found (non-fatal)."""
        try:
            sort_btn = await self.page.wait_for_selector(SEL["sort_button"], timeout=5_000)
            if not sort_btn:
                return False
            await sort_btn.click()
            await asyncio.sleep(0.8)
            newest = await self.page.wait_for_selector(SEL["sort_newest"], timeout=5_000)
            if newest:
                await newest.click()
                await asyncio.sleep(1.5)
            self.state = NavState.SORTED
            logger.debug("[nav] → SORTED (newest first)")
            return True
        except PWTimeout:
            logger.warning("[nav] Sort button not found — using default sort")
            self.state = NavState.SORTED
            return False

    async def get_total_review_count(self) -> Optional[int]:
        """Extract the total review count shown in the UI."""
        try:
            el = await self.page.query_selector(SEL["total_reviews"])
            if not el:
                return None
            text = await el.inner_text()
            nums = re.findall(r"[\d,]+", text)
            if nums:
                return int(nums[0].replace(",", ""))
        except Exception as e:
            logger.debug(f"[nav] Could not read total reviews: {e}")
        return None

    async def get_place_name(self) -> Optional[str]:
        try:
            el = await self.page.query_selector(SEL["place_name"])
            return await el.inner_text() if el else None
        except Exception:
            return None

    async def _wait_for(self, selector: str) -> None:
        await self.page.wait_for_selector(selector, timeout=self.timeout)