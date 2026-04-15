"""
Google Maps scraper — BrightData Scraping Browser (CDP) backend.

The BrightData Scraping Browser provides a cloud-hosted Chromium with proxy
rotation and anti-bot defenses built in. We connect via Playwright's
`connect_over_cdp`, which keeps the scraper fully async and avoids managing
a local Chromium profile (unlike the scraper_lean prototype).

Two public entry points are used by the advisory worker:

    async scrape_gmaps_search(query, location=None, max_pois=20)
        → list[POISearchResult]

    async scrape_gmaps_reviews(place_url, limit=4)
        → list[Review]

Both functions return an empty list on any failure; they never raise into
the caller. Errors are logged and the cycle falls through to Reddit-only.

Cost governance (max 4 reviews/POI, 15 reviews/cycle, 50 BrightData calls per
trip) is enforced at the advisory worker layer, not here — this module is
a dumb pipe.
"""

from __future__ import annotations

import asyncio
import contextlib
import logging
import re
import urllib.parse
from dataclasses import dataclass, field
from typing import AsyncIterator, Optional

try:
    from playwright.async_api import (
        Browser,
        BrowserContext,
        Page,
        TimeoutError as PlaywrightTimeoutError,
        async_playwright,
    )
except ImportError:  # pragma: no cover — playwright absent in minimal envs
    async_playwright = None  # type: ignore[assignment]
    Browser = BrowserContext = Page = None  # type: ignore[assignment]

    class PlaywrightTimeoutError(Exception):  # type: ignore[no-redef]
        pass

from app.config import settings

logger = logging.getLogger(__name__)


# Global semaphore — cap concurrent BrightData sessions across the worker.
# BrightData charges per request; parallel browser instances don't speed
# up a single cycle meaningfully for our volume.
_SESSION_SEMAPHORE = asyncio.Semaphore(2)

# Navigation timeouts (ms).
_SEARCH_TIMEOUT_MS = 15_000
_REVIEW_TIMEOUT_MS = 20_000
_NETWORK_IDLE_TIMEOUT_MS = 5_000


# ---------------------------------------------------------------------------
# Result types
# ---------------------------------------------------------------------------


@dataclass
class POISearchResult:
    place_id: str                 # stable id: ftid extracted from URL, else URL itself
    name: str
    category: Optional[str]
    rating: Optional[float]
    review_count: Optional[int]
    lat: Optional[float]
    lng: Optional[float]
    url: str
    price_level: Optional[str] = None   # "$", "$$", "$$$", etc. (when visible on card)

    def to_dict(self) -> dict:
        return {
            "place_id": self.place_id,
            "name": self.name,
            "category": self.category,
            "rating": self.rating,
            "review_count": self.review_count,
            "lat": self.lat,
            "lng": self.lng,
            "url": self.url,
            "price_level": self.price_level,
        }


@dataclass
class Review:
    author: Optional[str]
    rating: Optional[int]
    date: Optional[str]
    text: str
    review_id: Optional[str] = None

    def to_dict(self) -> dict:
        return {
            "author": self.author,
            "rating": self.rating,
            "date": self.date,
            "text": self.text,
            "review_id": self.review_id,
        }


# ---------------------------------------------------------------------------
# URL helpers
# ---------------------------------------------------------------------------


_COORD_RE = re.compile(r"!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)")
_FTID_RE = re.compile(r"!1s([^!]+)")


def _extract_place_id(url: str) -> str:
    """Prefer the GMaps ftid (`!1s...`) from the URL; fall back to the URL itself."""
    m = _FTID_RE.search(url or "")
    if m:
        return m.group(1)
    return url


def _extract_coords(url: str) -> tuple[Optional[float], Optional[float]]:
    m = _COORD_RE.search(url or "")
    if not m:
        return None, None
    try:
        return float(m.group(1)), float(m.group(2))
    except (TypeError, ValueError):
        return None, None


def _search_url(query: str, location: Optional[str] = None) -> str:
    q = query if not location else f"{query} {location}"
    return "https://www.google.com/maps/search/" + urllib.parse.quote(q)


# ---------------------------------------------------------------------------
# Session / browser lifecycle
# ---------------------------------------------------------------------------


def _brightdata_ready() -> bool:
    ep = (settings.BRIGHTDATA_WS_ENDPOINT or "").strip()
    if not ep:
        return False
    if async_playwright is None:
        logger.warning("playwright.async_api unavailable — gmaps_scraper disabled")
        return False
    return True


@contextlib.asynccontextmanager
async def _open_browser() -> AsyncIterator[Browser]:
    """Open a BrightData CDP connection; yield a Browser. Raises on missing config."""
    ep = settings.BRIGHTDATA_WS_ENDPOINT or ""
    async with async_playwright() as pw:  # type: ignore[misc]
        browser = await pw.chromium.connect_over_cdp(ep)
        try:
            yield browser
        finally:
            await browser.close()


async def _new_page(browser: Browser) -> Page:
    ctx = await browser.new_context(
        viewport={"width": 1280, "height": 1800},
        locale="en-US",
    )
    page = await ctx.new_page()
    return page


async def _dismiss_consent(page: Page) -> None:
    """Best-effort cookie/consent dismissal; ignore if not present."""
    for sel in (
        "button[aria-label*='Accept all']",
        "button[aria-label*='Reject all']",
        "#L2AGLb",
        "button:has-text('I agree')",
    ):
        try:
            btn = await page.query_selector(sel)
            if btn:
                await btn.click(timeout=1500)
                await page.wait_for_timeout(500)
                return
        except (PlaywrightTimeoutError, Exception):
            continue


# ---------------------------------------------------------------------------
# Search — list POIs for a query
# ---------------------------------------------------------------------------


async def _extract_search_cards(page: Page, max_pois: int) -> list[POISearchResult]:
    """Parse the left results panel for POI cards."""
    await page.wait_for_selector("a.hfpxzc", timeout=_SEARCH_TIMEOUT_MS)
    anchors = await page.query_selector_all("a.hfpxzc")
    out: list[POISearchResult] = []
    seen: set[str] = set()

    for anchor in anchors[: max_pois * 2]:  # slack for dedupe
        try:
            href = await anchor.get_attribute("href") or ""
            if "/maps/place/" not in href:
                continue
            # Card root — anchor's nearest container.
            card = await anchor.evaluate_handle(
                "el => el.closest('div[jsaction]') || el.parentElement"
            )
            card_el = card.as_element() if card else None
            if not card_el:
                continue

            name_el = await card_el.query_selector(".qBF1Pd")
            name = (await name_el.inner_text()).strip() if name_el else (
                await anchor.get_attribute("aria-label") or ""
            )
            if not name:
                continue
            place_id = _extract_place_id(href)
            if place_id in seen:
                continue
            seen.add(place_id)

            # Rating + review count are rendered together in "4.6 (1,234)" form.
            rating: Optional[float] = None
            review_count: Optional[int] = None
            meta_el = await card_el.query_selector("span.MW4etd")
            if meta_el:
                try:
                    rating = float((await meta_el.inner_text()).strip())
                except (TypeError, ValueError):
                    rating = None
            count_el = await card_el.query_selector("span.UY7F9")
            if count_el:
                try:
                    txt = (await count_el.inner_text()).strip().strip("()").replace(",", "")
                    review_count = int(re.sub(r"[^0-9]", "", txt) or 0) or None
                except (TypeError, ValueError):
                    review_count = None

            # Category is usually the first ".W4Efsd" span descendant.
            category: Optional[str] = None
            cat_el = await card_el.query_selector("div.W4Efsd span")
            if cat_el:
                cat_txt = (await cat_el.inner_text()).strip()
                if cat_txt and "·" not in cat_txt:
                    category = cat_txt

            lat, lng = _extract_coords(href)

            out.append(
                POISearchResult(
                    place_id=place_id,
                    name=name,
                    category=category,
                    rating=rating,
                    review_count=review_count,
                    lat=lat,
                    lng=lng,
                    url=href,
                )
            )
            if len(out) >= max_pois:
                break
        except Exception as exc:  # noqa: BLE001 — swallow per-card parse errors
            logger.debug("gmaps card parse error: %s", exc)
            continue

    return out


async def scrape_gmaps_search(
    query: str, location: Optional[str] = None, max_pois: int = 20
) -> list[POISearchResult]:
    """Return up to `max_pois` POIs for `query` (+ optional `location` suffix)."""
    if not query.strip():
        return []
    if not _brightdata_ready():
        logger.warning("BRIGHTDATA_WS_ENDPOINT missing — scrape_gmaps_search no-op")
        return []

    url = _search_url(query, location)
    async with _SESSION_SEMAPHORE:
        try:
            async with _open_browser() as browser:
                page = await _new_page(browser)
                try:
                    await page.goto(url, timeout=_SEARCH_TIMEOUT_MS)
                    await _dismiss_consent(page)
                    with contextlib.suppress(PlaywrightTimeoutError):
                        await page.wait_for_load_state(
                            "networkidle", timeout=_NETWORK_IDLE_TIMEOUT_MS
                        )
                    return await _extract_search_cards(page, max_pois=max_pois)
                finally:
                    await page.context.close()
        except Exception as exc:  # noqa: BLE001
            logger.warning("scrape_gmaps_search failed for %r: %s", query, exc)
            return []


# ---------------------------------------------------------------------------
# Reviews — up to N reviews for a place
# ---------------------------------------------------------------------------


async def _open_reviews_tab(page: Page) -> bool:
    """Click the Reviews tab on a place page. Returns True if it opened."""
    # Primary selector: aria-label starts with "Reviews for" (place pages).
    candidates = [
        "button[aria-label^='Reviews for']",
        "button[role='tab'][aria-label^='Reviews']",
    ]
    for sel in candidates:
        try:
            btn = await page.query_selector(sel)
            if not btn:
                continue
            await btn.click(timeout=2500)
            await page.wait_for_selector(
                "div[data-review-id]", timeout=_REVIEW_TIMEOUT_MS
            )
            return True
        except (PlaywrightTimeoutError, Exception):
            continue
    # Fallback: maybe we're already on the Reviews tab.
    try:
        await page.wait_for_selector(
            "div[data-review-id]", timeout=4000
        )
        return True
    except PlaywrightTimeoutError:
        return False


async def _extract_visible_reviews(page: Page) -> list[Review]:
    """Read all currently rendered review cards into Review structs.

    Google renders duplicate cards (original + translation) keyed by the
    same data-review-id — we dedupe within this pass.
    """
    cards = await page.query_selector_all("div[data-review-id]")
    seen: set[str] = set()
    out: list[Review] = []
    for card in cards:
        try:
            rid = await card.get_attribute("data-review-id") or ""
            if not rid or rid in seen:
                continue
            seen.add(rid)

            author_el = await card.query_selector(".d4r55")
            author = (await author_el.inner_text()).strip() if author_el else None

            rating: Optional[int] = None
            rating_el = await card.query_selector("span[aria-label*='star']")
            if rating_el:
                aria = await rating_el.get_attribute("aria-label") or ""
                m = re.search(r"(\d+)", aria)
                if m:
                    try:
                        rating = int(m.group(1))
                    except (TypeError, ValueError):
                        rating = None

            date_el = await card.query_selector(".rsqaWe")
            date = (await date_el.inner_text()).strip() if date_el else None

            # Expand "See more" if present before reading text.
            with contextlib.suppress(Exception):
                more = await card.query_selector("button[aria-label='See more']")
                if more:
                    await more.click(timeout=1500)

            text_el = await card.query_selector(".wiI7pd")
            text = (await text_el.inner_text()).strip() if text_el else ""

            out.append(
                Review(
                    author=author,
                    rating=rating,
                    date=date,
                    text=text,
                    review_id=rid,
                )
            )
        except Exception as exc:  # noqa: BLE001
            logger.debug("gmaps review parse error: %s", exc)
            continue
    return out


async def scrape_gmaps_reviews(
    place_url: str, limit: int = 4
) -> list[Review]:
    """Return up to `limit` reviews for the given place URL.

    Only fetches what's visible on first render — no scroll pagination.
    For advisory use, 3-4 reviews is the entire need.
    """
    if not place_url or not place_url.startswith("http"):
        return []
    if not _brightdata_ready():
        logger.warning("BRIGHTDATA_WS_ENDPOINT missing — scrape_gmaps_reviews no-op")
        return []

    effective_limit = max(1, min(int(limit or 1), 20))

    async with _SESSION_SEMAPHORE:
        try:
            async with _open_browser() as browser:
                page = await _new_page(browser)
                try:
                    await page.goto(place_url, timeout=_REVIEW_TIMEOUT_MS)
                    await _dismiss_consent(page)
                    if not await _open_reviews_tab(page):
                        logger.info(
                            "gmaps reviews tab not found for %s", place_url[:80]
                        )
                        return []
                    # Small settle wait so 2x translation cards are rendered.
                    await page.wait_for_timeout(800)
                    reviews = await _extract_visible_reviews(page)
                    return reviews[:effective_limit]
                finally:
                    await page.context.close()
        except Exception as exc:  # noqa: BLE001
            logger.warning("scrape_gmaps_reviews failed for %s: %s", place_url[:80], exc)
            return []
