"""
scroll_engine.py — Layer 6a: Paginate the virtualized reviews pane

Google Maps uses a virtualized scroll container for reviews.
Naive window.scrollBy won't work — must scroll the inner container.
Detects: end of reviews, throttling, infinite loop (no new cards).
"""
import asyncio, os, random
from typing import Optional
from loguru import logger
from playwright.async_api import Page


# The reviews pane is a scrollable div, not the window
SCROLL_CONTAINER_SELECTORS = [
    "div.m6QErb[aria-label]",          # primary reviews container
    "div[data-review-id]",             # fallback: first review card's parent
    "div.section-scrollbox",           # older Maps layout
]

REVIEW_CARD_SELECTOR = "div[data-review-id]"


class ScrollEngine:
    def __init__(self, page: Page, max_reviews: int = 500):
        self.page = page
        self.max_reviews = max_reviews
        self._delay_min = float(os.getenv("SCROLL_DELAY_MIN", "1.5"))
        self._delay_max = float(os.getenv("SCROLL_DELAY_MAX", "3.5"))
        self._container_sel: Optional[str] = None

    async def find_container(self) -> bool:
        """Locate the scrollable reviews container."""
        for sel in SCROLL_CONTAINER_SELECTORS:
            try:
                el = await self.page.query_selector(sel)
                if el:
                    self._container_sel = sel
                    logger.debug(f"[scroll] Container found: {sel}")
                    return True
            except Exception:
                pass
        logger.warning("[scroll] Could not find scroll container — will scroll window")
        return False

    async def scroll_to_load_all(self, target_count: Optional[int] = None) -> int:
        """
        Scroll reviews pane until all reviews load or max_reviews reached.
        Returns count of review cards visible at end.
        """
        await self.find_container()
        limit = min(target_count or self.max_reviews, self.max_reviews)
        prev_count = 0
        stale_cycles = 0
        max_stale = 5  # give up after 5 scroll cycles with no new cards

        logger.info(f"[scroll] Starting scroll, target={limit}")

        while True:
            current_count = await self._count_visible_reviews()

            if current_count >= limit:
                logger.info(f"[scroll] Reached limit: {current_count} reviews")
                break

            if current_count == prev_count:
                stale_cycles += 1
                if stale_cycles >= max_stale:
                    logger.info(
                        f"[scroll] No new reviews after {max_stale} cycles "
                        f"(total: {current_count}). Assuming end."
                    )
                    break
            else:
                stale_cycles = 0

            prev_count = current_count
            await self._do_scroll()
            await self._human_delay()

        final = await self._count_visible_reviews()
        logger.info(f"[scroll] Done. {final} review cards visible.")
        return final

    async def _do_scroll(self):
        """Scroll the reviews container by a randomized amount."""
        scroll_px = random.randint(600, 1200)

        if self._container_sel:
            try:
                await self.page.evaluate(
                    f"""
                    const el = document.querySelector('{self._container_sel}');
                    if (el) el.scrollBy(0, {scroll_px});
                    """
                )
                return
            except Exception as e:
                logger.debug(f"[scroll] Container scroll failed: {e}")

        # Fallback: scroll window
        await self.page.evaluate(f"window.scrollBy(0, {scroll_px})")

    async def _count_visible_reviews(self) -> int:
        try:
            cards = await self.page.query_selector_all(REVIEW_CARD_SELECTOR)
            return len(cards)
        except Exception:
            return 0

    async def _human_delay(self):
        """Random delay to mimic human reading pace."""
        delay = random.uniform(self._delay_min, self._delay_max)
        await asyncio.sleep(delay)