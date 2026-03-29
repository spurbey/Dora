"""
session_policy.py — Layer 8: Session lifecycle and rotation

Manages when to rotate proxy + browser context.
Tracks: places scraped per session, block signals, age.
"""
import os, asyncio
from loguru import logger
from typing import Optional

from .proxy_router import ProxyRouter
from .fingerprint_manager import FingerprintManager


class SessionPolicy:
    def __init__(self, proxy_router: ProxyRouter, fp_manager: FingerprintManager):
        self._proxy = proxy_router
        self._fp = fp_manager
        self._rotate_after = int(os.getenv("SESSION_ROTATE_AFTER", "50"))
        self._places_this_session = 0
        self._context = None  # Playwright BrowserContext
        self._browser = None

    def should_rotate(self) -> bool:
        return self._places_this_session >= self._rotate_after

    def record_place_done(self):
        self._places_this_session += 1

    async def rotate(self, browser, mark_proxy_blocked: bool = False):
        """
        Create a fresh browser context with new proxy + fingerprint.
        Call this on block detection or after SESSION_ROTATE_AFTER places.
        """
        logger.info(
            f"[session] Rotating after {self._places_this_session} places "
            f"(blocked={mark_proxy_blocked})"
        )
        # Close old context
        if self._context:
            try:
                await self._context.close()
            except Exception:
                pass

        # Rotate proxy
        self._proxy.rotate(mark_blocked=mark_proxy_blocked)

        # New fingerprint
        fp = self._fp.lock()

        # Build new context
        ctx_kwargs = self._fp.playwright_context_kwargs()
        ctx_kwargs.update(self._proxy.playwright_proxy_kwargs())

        self._context = await browser.new_context(**ctx_kwargs)
        self._places_this_session = 0

        # Apply stealth patches
        await self._apply_stealth(self._context)

        logger.info(f"[session] New context ready. Proxy: {self._proxy._masked(self._proxy.current)}")
        return self._context

    async def get_context(self, browser):
        """Get current context, creating one if needed."""
        if not self._context:
            return await self.rotate(browser)
        return self._context

    async def _apply_stealth(self, context):
        """
        Inject stealth JS to mask automation signals.
        playwright-stealth is the main tool; we add a few extra patches.
        """
        try:
            from playwright_stealth import stealth_async
            page = await context.new_page()
            await stealth_async(page)
            await page.close()
        except ImportError:
            logger.warning("[session] playwright-stealth not installed — bot detection risk higher")

        # Patch navigator.webdriver
        await context.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
            Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
            Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
            window.chrome = { runtime: {} };
        """)