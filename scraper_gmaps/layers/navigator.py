"""
navigator.py - Layer 2: State machine and page acquisition for Google Maps.

Primary rule:
1) Acquire the correct place page variant.
2) Only then open reviews and extract.
"""
import asyncio
import re
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


class PageState(Enum):
    FULL_PLACE = "full_place"
    LIMITED_PLACE = "limited_place"
    CONSENT = "consent"
    BLOCKED = "blocked"
    SEARCH_RESULTS = "search_results"
    NO_REVIEWS_AVAILABLE = "no_reviews_available"
    UNKNOWN = "unknown"


SEL = {
    "place_name": [
        "h1.DUwDvf",
        'h1[class*="fontHeadline"]',
        "h1",
    ],
    "top_tabs": [
        'button[role="tab"]',
    ],
    "search_box": [
        "input#searchboxinput",
        'input[aria-label*="Search Google Maps" i]',
        'input[placeholder*="Search Google Maps" i]',
    ],
    "search_results": [
        "div.Nv2PK",
        'a.hfpxzc[href*="/maps/place/"]',
        'div[role="article"] a[href*="/maps/place/"]',
    ],
    "reviews_tab": [
        '[role="tab"][aria-label*="review" i]',
        'button[role="tab"][aria-label*="review" i]',
        'button[jsaction*="reviews"]',
        '[role="tab"]:has-text("reviews")',
        '[role="tab"]:has-text("Reviews")',
        'button:has-text("reviews")',
        'button:has-text("Reviews")',
    ],
    "reviews_entry_fallback": [
        'button[aria-label*="review" i]',
        'button[aria-label*="stars" i][aria-label*="review" i]',
        'button[jsaction*="pane.rating"]',
    ],
    "reviews_container": [
        "div[data-review-id]",
        "div.jftiEf",
        'div[role="feed"]',
        "div.m6QErb.DxyBCb.kA9KIf.dS8AEf",
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
    # Keep scoped to upper place header panel. Do not use generic UY7F9 globally.
    "total_reviews": [
        'button[jsaction*="reviews"]',
        'button[jsaction*="reviews"] span',
        'span[aria-label*="reviews" i]',
        "div.F7nice",
    ],
    "consent_signals": [
        'button[aria-label*="Accept" i]',
        'button[id*="accept" i]',
        'form[action*="consent.google"]',
    ],
    "dismiss_popup": [
        'button[aria-label*="close" i]',
        'button[jsaction*="close"]',
        'button:has-text("Cancel")',
        'button:has-text("Not now")',
    ],
}


class Navigator:
    _RE_REVIEW_COUNT = re.compile(r"(\d[\d,]*)\s*\+?\s*reviews?\b", re.I)
    _RE_BLOCKED_REVIEW_BUTTON = re.compile(
        r"\b(write|add|rate|post)\s+(a\s+)?review\b", re.I
    )
    _BLOCK_URL_PATTERNS = ("sorry/index", "recaptcha", "unusual_traffic")
    _LIMITED_VIEW_MARKERS = (
        "you're seeing a limited view of google maps",
        "limited view of google maps",
    )

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

    async def open_maps_home(self) -> bool:
        try:
            await self.page.goto(
                "https://www.google.com/maps?hl=en&gl=in",
                wait_until="domcontentloaded",
                timeout=30_000,
            )
            await asyncio.sleep(1.5)
            await self._dismiss_popups()
            return True
        except Exception as e:
            logger.error(f"[nav] open_maps_home failed: {e}")
            return False

    async def search_place(self, query: str) -> bool:
        box = await self._try_selectors(SEL["search_box"], timeout=10_000)
        if not box:
            logger.error("[nav] Search input not found")
            return False
        try:
            await box.click()
            await box.fill("")
            await asyncio.sleep(0.2)
            await box.type(query, delay=40)
            await asyncio.sleep(0.4)
            await self.page.keyboard.press("Enter")
            await asyncio.sleep(2.0)
            return True
        except Exception as e:
            logger.error(f"[nav] search_place failed: {e}")
            return False

    async def open_place_from_results(self, query_hint: str) -> bool:
        query_hint_norm = self._normalize(query_hint)
        candidates = []
        for sel in SEL["search_results"]:
            try:
                nodes = await self.page.query_selector_all(sel)
                candidates.extend(nodes)
            except Exception:
                pass

        if not candidates:
            logger.warning("[nav] No search result candidates found")
            return False

        best_node = None
        fallback_node = None
        for node in candidates[:20]:
            try:
                if not await node.is_visible():
                    continue
                label = await self._element_label(node)
                if not label:
                    continue
                if not fallback_node:
                    fallback_node = node
                if query_hint_norm and query_hint_norm in self._normalize(label):
                    best_node = node
                    break
            except Exception:
                continue

        target = best_node or fallback_node
        if not target:
            logger.warning("[nav] No clickable search result selected")
            return False

        try:
            await target.scroll_into_view_if_needed()
            await target.click()
            await asyncio.sleep(2.0)
            name_el = await self._try_selectors(SEL["place_name"], timeout=10_000)
            if not name_el:
                logger.warning("[nav] Clicked a result but place name did not appear")
                return False
            return True
        except Exception as e:
            logger.warning(f"[nav] open_place_from_results click failed: {e}")
            return False

    async def recover_full_place_via_search(self, query: str, place_hint: str = "") -> bool:
        logger.info(f"[nav] Recovering via search flow (query={query!r})")
        if not await self.open_maps_home():
            return False
        if not await self.search_place(query):
            return False
        if not await self.open_place_from_results(place_hint or query):
            return False
        await self._dismiss_popups()
        state = await self.classify_page_state()
        logger.info(f"[nav] Post-recovery page state: {state.value}")
        return state in (PageState.FULL_PLACE, PageState.NO_REVIEWS_AVAILABLE)

    async def classify_page_state(self) -> PageState:
        url = self.page.url or ""
        if any(token in url for token in self._BLOCK_URL_PATTERNS):
            return PageState.BLOCKED

        if await self._has_any_selector(SEL["consent_signals"]):
            return PageState.CONSENT

        if await self.is_limited_view():
            return PageState.LIMITED_PLACE

        place_name = await self.get_place_name()
        if place_name:
            if await self.has_reviews_entrypoint():
                return PageState.FULL_PLACE
            return PageState.NO_REVIEWS_AVAILABLE

        if await self._has_any_selector(SEL["search_results"]):
            return PageState.SEARCH_RESULTS

        return PageState.UNKNOWN

    async def is_full_place_page(self) -> bool:
        state = await self.classify_page_state()
        return state == PageState.FULL_PLACE

    async def is_limited_view(self) -> bool:
        try:
            html = (await self.page.content()).lower()
        except Exception:
            return False
        return any(marker in html for marker in self._LIMITED_VIEW_MARKERS)

    async def has_reviews_entrypoint(self) -> bool:
        if await self._find_reviews_tab_strict():
            return True
        if await self._find_reviews_entry_fallback():
            return True
        return False

    async def open_reviews_tab(self) -> bool:
        logger.debug(f"[nav] open_reviews_tab (state={self.state})")
        await self._dismiss_popups()

        tab = await self._find_reviews_tab_strict()
        if not tab:
            tab = await self._find_reviews_entry_fallback()
        if not tab:
            await asyncio.sleep(1.0)
            tab = await self._find_reviews_tab_strict() or await self._find_reviews_entry_fallback()

        if not tab:
            logger.error("[nav] Reviews entrypoint not found")
            self.state = NavState.ERROR
            return False

        try:
            await tab.scroll_into_view_if_needed()
            await tab.click()
            logger.debug("[nav] Reviews entry clicked")
            await asyncio.sleep(1.5)
        except Exception as e:
            logger.error(f"[nav] Reviews click failed: {e}")
            self.state = NavState.ERROR
            return False

        container = await self._try_selectors(SEL["reviews_container"], timeout=12_000)
        if container:
            self.state = NavState.REVIEWS_TAB
            logger.debug("[nav] -> REVIEWS_TAB")
            return True

        logger.error("[nav] Reviews container not found after click")
        self.state = NavState.ERROR
        return False

    async def sort_by_newest(self) -> bool:
        try:
            sort_btn = await self._try_selectors(SEL["sort_button"], timeout=5_000)
            if not sort_btn:
                logger.warning("[nav] Sort button not found - using default sort")
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
            logger.warning("[nav] Sort timed out - using default sort")
            self.state = NavState.SORTED
            return False

    async def get_total_review_count(self) -> Optional[int]:
        """
        Parse explicit "<N> reviews" near the top place header.
        Avoid unrelated nested listing counts farther down the panel.
        """
        tab = await self._find_reviews_tab_strict()
        if tab:
            label = await self._element_label(tab)
            count = self._extract_review_count(label)
            if count:
                return count

        for sel in SEL["total_reviews"]:
            try:
                els = await self.page.query_selector_all(sel)
            except Exception:
                els = []
            for el in els[:10]:
                try:
                    box = await el.bounding_box()
                    if box and box.get("y", 0) > 430:
                        continue
                    label = await self._element_label(el)
                    count = self._extract_review_count(label)
                    if count:
                        return count
                except Exception:
                    continue
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
        for sel in selectors:
            try:
                el = await self.page.query_selector(sel)
                if el:
                    logger.debug(f"[nav] Found (instant): {sel}")
                    return el
            except Exception:
                pass

        per_selector_timeout = max(1000, timeout // max(1, len(selectors)))
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

    async def _has_any_selector(self, selectors: list) -> bool:
        for sel in selectors:
            try:
                el = await self.page.query_selector(sel)
                if el:
                    return True
            except Exception:
                pass
        return False

    async def _dismiss_popups(self):
        await asyncio.sleep(0.5)
        dismissed = 0

        modal_roots = []
        for root_sel in ('[role="dialog"]', '[aria-modal="true"]'):
            try:
                roots = await self.page.query_selector_all(root_sel)
                modal_roots.extend(roots)
            except Exception:
                pass

        for root in modal_roots:
            for btn_sel in SEL["dismiss_popup"]:
                try:
                    btn = await root.query_selector(btn_sel)
                    if btn and await btn.is_visible():
                        await btn.click()
                        dismissed += 1
                        logger.debug(f"[nav] Dismissed modal popup via: {btn_sel}")
                        await asyncio.sleep(0.3)
                        break
                except Exception:
                    pass

        if dismissed:
            logger.debug(f"[nav] Dismissed {dismissed} modal popup(s)")

    async def _find_reviews_tab_strict(self):
        for sel in SEL["reviews_tab"]:
            try:
                nodes = await self.page.query_selector_all(sel)
            except Exception:
                nodes = []

            for node in nodes:
                try:
                    if not await node.is_visible():
                        continue
                    role = (await node.get_attribute("role") or "").lower()
                    label = await self._element_label(node)
                    if not self._is_reviews_tab_label(label, role):
                        continue
                    logger.debug(f"[nav] Reviews tab candidate matched: {label!r}")
                    return node
                except Exception:
                    continue

        return None

    async def _find_reviews_entry_fallback(self):
        for sel in SEL["reviews_entry_fallback"]:
            try:
                nodes = await self.page.query_selector_all(sel)
            except Exception:
                nodes = []
            for node in nodes:
                try:
                    if not await node.is_visible():
                        continue
                    label = await self._element_label(node)
                    if not label:
                        continue
                    low = label.lower()
                    if self._RE_BLOCKED_REVIEW_BUTTON.search(low):
                        continue
                    if "review" in low and "write a review" not in low:
                        logger.debug(f"[nav] Reviews fallback candidate matched: {label!r}")
                        return node
                except Exception:
                    continue
        return None

    async def _element_label(self, element) -> str:
        parts = []
        try:
            txt = (await element.inner_text() or "").strip()
            if txt:
                parts.append(txt)
        except Exception:
            pass
        for attr in ("aria-label", "title", "data-value"):
            try:
                val = await element.get_attribute(attr)
                if val:
                    parts.append(val.strip())
            except Exception:
                pass
        return " ".join(parts).strip()

    def _extract_review_count(self, text: str) -> Optional[int]:
        if not text:
            return None
        normalized = self._normalize(text)
        m = self._RE_REVIEW_COUNT.search(normalized)
        if not m:
            return None
        count = int(m.group(1).replace(",", ""))
        return count if count > 0 else None

    def _is_reviews_tab_label(self, raw_label: str, role: str) -> bool:
        label = self._normalize(raw_label)
        if not label:
            return False

        if self._RE_BLOCKED_REVIEW_BUTTON.search(label):
            return False

        if "review" not in label:
            return False

        has_count = bool(self._RE_REVIEW_COUNT.search(label))
        has_explicit_reviews_tab = (
            label == "reviews"
            or label.startswith("reviews ")
            or " all reviews" in label
            or "google reviews" in label
        )
        if has_count or has_explicit_reviews_tab:
            return True

        return role == "tab" and "review" in label

    @staticmethod
    def _normalize(text: str) -> str:
        return " ".join((text or "").replace("\xa0", " ").split()).lower()
