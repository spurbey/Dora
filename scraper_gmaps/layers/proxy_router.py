"""
proxy_router.py — Layer 1: Proxy rotation

Manages a pool of proxy URLs. Rotates on block signals.
Residential proxies strongly recommended for Google Maps.
"""
import os
from typing import Optional
from loguru import logger


class ProxyRouter:
    def __init__(self):
        raw = os.getenv("PROXY_POOL", os.getenv("PROXY_URL", ""))
        self._pool = [p.strip() for p in raw.split(",") if p.strip()]
        self._index = 0
        self._blocked: set = set()

        if not self._pool:
            logger.warning(
                "[proxy] No proxies configured. Running without proxy — "
                "expect blocks quickly on Google Maps."
            )

    @property
    def current(self) -> Optional[str]:
        available = [p for p in self._pool if p not in self._blocked]
        if not available:
            logger.error("[proxy] All proxies exhausted / blocked")
            return None
        return available[self._index % len(available)]

    def rotate(self, mark_blocked: bool = False) -> Optional[str]:
        """Move to next proxy. Optionally mark current as blocked."""
        if mark_blocked and self.current:
            self._blocked.add(self.current)
            logger.warning(f"[proxy] Marked blocked: {self._masked(self.current)}")
        self._index += 1
        logger.info(f"[proxy] Rotated to: {self._masked(self.current)}")
        return self.current

    def playwright_proxy_kwargs(self) -> dict:
        """Returns proxy dict for Playwright browser launch."""
        p = self.current
        if not p:
            return {}
        # Playwright expects: {"server": "http://host:port", "username": ..., "password": ...}
        try:
            from urllib.parse import urlparse
            parsed = urlparse(p)
            result = {"server": f"{parsed.scheme}://{parsed.hostname}:{parsed.port}"}
            if parsed.username:
                result["username"] = parsed.username
            if parsed.password:
                result["password"] = parsed.password
            return {"proxy": result}
        except Exception as e:
            logger.error(f"[proxy] Failed to parse proxy URL: {e}")
            return {}

    @staticmethod
    def _masked(url: Optional[str]) -> str:
        if not url:
            return "none"
        # Hide password in logs
        try:
            from urllib.parse import urlparse
            p = urlparse(url)
            return f"{p.scheme}://{p.hostname}:{p.port}"
        except Exception:
            return "***"