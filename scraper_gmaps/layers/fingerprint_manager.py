"""
fingerprint_manager.py — Layer 1: Identity & Stealth

Builds a consistent browser fingerprint so Google sees a plausible
human, not a bot. Consistency matters more than randomness:
same UA + same TLS JA3 + same locale + same timezone every session.
"""
import os, random
from dataclasses import dataclass
from typing import Optional
from loguru import logger


# Curated set of plausible desktop fingerprints.
# Each tuple: (user_agent, platform, viewport_w, viewport_h, timezone, locale)
FINGERPRINT_POOL = [
    (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "Win32", 1920, 1080, "America/New_York", "en-US",
    ),
    (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "MacIntel", 1440, 900, "America/Los_Angeles", "en-US",
    ),
    (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "Win32", 1366, 768, "America/Chicago", "en-US",
    ),
    (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "MacIntel", 1680, 1050, "Europe/London", "en-GB",
    ),
]


@dataclass
class Fingerprint:
    user_agent: str
    platform: str
    viewport_width: int
    viewport_height: int
    timezone: str
    locale: str


class FingerprintManager:
    """
    Picks and locks a fingerprint for the lifetime of a session.
    Always call lock() at session start; never change mid-session.
    """

    def __init__(self, seed: Optional[int] = None):
        self._rng = random.Random(seed)
        self._active: Optional[Fingerprint] = None

    def lock(self) -> Fingerprint:
        """Pick a fingerprint and lock it for this session."""
        ua, platform, w, h, tz, locale = self._rng.choice(FINGERPRINT_POOL)

        # Allow .env overrides so proxy locale matches
        tz = os.getenv("TIMEZONE", tz)
        locale = os.getenv("LOCALE", locale)

        self._active = Fingerprint(
            user_agent=ua,
            platform=platform,
            viewport_width=w,
            viewport_height=h,
            timezone=tz,
            locale=locale,
        )
        logger.debug(f"[fingerprint] locked: {ua[:60]}... tz={tz}")
        return self._active

    @property
    def active(self) -> Fingerprint:
        if not self._active:
            raise RuntimeError("Call lock() before accessing active fingerprint")
        return self._active

    def playwright_context_kwargs(self) -> dict:
        """Returns kwargs to pass directly to browser.new_context()."""
        fp = self.active
        return {
            "user_agent": fp.user_agent,
            "viewport": {"width": fp.viewport_width, "height": fp.viewport_height},
            "locale": fp.locale,
            "timezone_id": fp.timezone,
            "extra_http_headers": {
                "Accept-Language": f"{fp.locale},{fp.locale.split('-')[0]};q=0.9,en;q=0.8",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "sec-ch-ua": '"Chromium";v="124", "Google Chrome";v="124"',
                "sec-ch-ua-mobile": "?0",
                "sec-ch-ua-platform": f'"{fp.platform}"',
            },
        }