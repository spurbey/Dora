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


# CSS selectors — ordered by reliability, first match wins
SEL = {
    "place_name": [
        'h1.DUwDvf',
        'h1[class*="fontHeadline"]',
        'h1',
    ],
    "reviews_tab": [
        'button[aria-label*="reviews" i]',
        'button[aria-label*="Reviews" i]',
        'button.hh2c6:nth-child(2)',
        'button[jsaction*="reviews"]',
        '[role="tab"]:has-text("reviews")',
        '[role="tab"]:has-text("Reviews")',
    ],
    "reviews_container": [
        'div[data-review-id]',
        'div[jsaction*="review"]',
        'div.jftiEf',
        'div[class*="review"]',
    ],
    "sort_button": [
        'button[aria-label*="Sort" i]',
        'button[data-value="sort"]',
        'button[jsaction*="sort"]',
    ],
    "sort_newest": [
        'li[data-index="1"]',
        '[data-value="newestFirst"]',
        'li:has-text("Newest")',
        'li:has-text("newest")',
    ],
    "review_card": [
        'div[data-review-id]',
        'div.jftiEf',
    ],
    "total_reviews": [
        'button[jsaction*="reviews"] span',
        'span[aria-label*="reviews" i]',
        'div.F7nice span',
        'span.UY7F9',
    ],
    "dismiss_popup": [
        'button[aria-label="Close"]',
        'button[aria-label="close"]',
        'button[jsaction*="close"]',
        'button.VfPpkd-icon-LgbsSe',
        '[data-ved] button:has-text("Cancel")',
        'button:has-text("Cancel")',
    ],
}


class Navigator:
    def __init__(self, page: Page, timeout: int = 15_000):
        self.page = page
        self.timeout = timeout
        self.state = NavState.INIT

    async def goto_place(self, url: str) -> bool:
        logger.info(f"[nav] goto_place: {url}")
        try:
            await self.page.goto(url, wait_until="domcontentloaded", timeout=30_000)
            await self._dismiss_popups()
            name_el = await self._try_selectors(SEL["place_name"], timeout=15_000)
            if not name_el:
                logger.error("[nav] Place name not found")
                self.state = NavState.ERROR
                return False
            self.state = NavState.PLACE_CARD
            logger.debug("[nav] -> PLACE_CARD")
            return True
        except PWTimeout:
            logger.error("[nav] Timed out waiting for place card")
            self.state = NavState.ERROR
            return False

    async def open_reviews_tab(self) -> bool:
        logger.debug(f"[nav] open_reviews_tab (state={self.state})")
        await self._dismiss_popups()

        tab = await self._try_selectors(SEL["reviews_tab"], timeout=10_000)
        if tab:
            try:
                await tab.scroll_into_view_if_needed()
                await tab.click()
                logger.debug("[nav] Reviews tab clicked")
                await asyncio.sleep(2.0)
            except Exception as e:
                logger.warning(f"[nav] Tab click failed: {e}")
        else:
            logger.warning("[nav] Reviews tab not found — trying URL approach")
            await self._try_reviews_url_approach()

        container = await self._try_selectors(SEL["reviews_container"], timeout=12_000)
        if container:
            self.state = NavState.REVIEWS_TAB
            logger.debug("[nav] -> REVIEWS_TAB")
            return True

        logger.error("[nav] Reviews container not found")
        self.state = NavState.ERROR
        return False

    async def sort_by_newest(self) -> bool:
        try:
            sort_btn = await self._try_selectors(SEL["sort_button"], timeout=5_000)
            if not sort_btn:
                logger.warning("[nav] Sort button not found — using default sort")
                self.state = NavState.SORTED
                return False
            await sort_btn.click()
            await asyncio.sleep(0.8)
            newest = await self._try_selectors(SEL["sort_newest"], timeout=5_000)
            if newest:
                await newest.click()
                await asyncio.sleep(1.5)
            self.state = NavState.SORTED
            logger.debug("[nav] -> SORTED (newest first)")
            return True
        except PWTimeout:
            logger.warning("[nav] Sort timed out — using default sort")
            self.state = NavState.SORTED
            return False

    async def get_total_review_count(self) -> Optional[int]:
        for sel in SEL["total_reviews"]:
            try:
                el = await self.page.query_selector(sel)
                if not el:
                    continue
                text = await el.inner_text()
                nums = re.findall(r"[\d,]+", text)
                if nums:
                    count = int(nums[0].replace(",", ""))
                    if count > 0:
                        return count
            except Exception:
                pass
        return None

    async def get_place_name(self) -> Optional[str]:
        for sel in SEL["place_name"]:
            try:
                el = await self.page.query_selector(sel)
                if el:
                    text = (await el.inner_text()).strip()
                    if text:
                        return text
            except Exception:
                pass
        return None

    async def _try_selectors(self, selectors: list, timeout: int = 5_000):
        """Try a list of selectors, return the first element found."""
        for sel in selectors:
            try:
                el = await self.page.query_selector(sel)
                if el:
                    logger.debug(f"[nav] Found (instant): {sel}")
                    return el
            except Exception:
                pass

        per_selector_timeout = max(1000, timeout // len(selectors))
        for sel in selectors:
            try:
                el = await self.page.wait_for_selector(sel, timeout=per_selector_timeout)
                if el:
                    logger.debug(f"[nav] Found (waited): {sel}")
                    return el
            except PWTimeout:
                pass
            except Exception as e:
                logger.debug(f"[nav] Selector error {sel}: {e}")
        return None

    async def _dismiss_popups(self):
        """Dismiss any overlays/modals that block interaction."""
        await asyncio.sleep(0.5)
        for sel in SEL["dismiss_popup"]:
            try:
                el = await self.page.query_selector(sel)
                if el and await el.is_visible():
                    await el.click()
                    logger.debug(f"[nav] Dismissed popup via: {sel}")
                    await asyncio.sleep(0.5)
                    return
            except Exception:
                pass

    async def _try_reviews_url_approach(self):
        """Fallback: append /reviews to the current URL."""
        try:
            current = self.page.url
            if "/reviews" not in current:
                reviews_url = re.sub(r'(/place/[^/]+/[^/]+).*', r'\1/reviews', current)
                if reviews_url != current:
                    await self.page.goto(reviews_url, wait_until="domcontentloaded", timeout=15_000)
                    await asyncio.sleep(1.5)
                    logger.debug(f"[nav] Tried reviews URL: {reviews_url}")
        except Exception as e:
            logger.debug(f"[nav] Reviews URL approach failed: {e}")