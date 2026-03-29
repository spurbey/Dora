"""
network_sniffer.py — Layer 4: Intercept XHR/fetch for review payloads

Google Maps sends review data as binary protobuf over XHR.
We capture raw response bytes here; proto_decoder.py handles parsing.

IMPORTANT: Filter carefully.
  - /maps/api/js/reviews  → JavaScript widget FILE, not data. Skip it.
  - /maps/rpc/             → Actual RPC data calls. Capture these.
  - listugcposts           → Review feed. Capture.
  - GetFeatureFeedItems    → Review feed. Capture.
"""
from typing import List, Callable, Optional
from dataclasses import dataclass, field
from loguru import logger
from playwright.async_api import Page, Response


# Must contain one of these to be captured
REVIEW_URL_ALLOWLIST = [
    "listugcposts",
    "GetFeatureFeedItems",
    "maps/preview/review",
    "/maps/rpc/",
    "reviewSort",
    "localreviews",
    "GetPlaceDetails",
    "maps/api/js/PlacesService",
]

# Skip these even if they match the allowlist
REVIEW_URL_BLOCKLIST = [
    "/maps/api/js/reviews",   # JS widget file, not data
    ".js?",                   # any JS file
    "maps/api/js?",           # Maps JS loader
]

# Minimum bytes — skip tiny responses that can't contain reviews
MIN_BODY_SIZE = 500


@dataclass
class CapturedResponse:
    url: str
    status: int
    body: bytes
    headers: dict


class NetworkSniffer:
    def __init__(self, page: Page):
        self.page = page
        self._captured: List[CapturedResponse] = []
        self._on_capture: Optional[Callable] = None
        self._active = False

    def on_capture(self, callback: Callable[[CapturedResponse], None]):
        self._on_capture = callback

    async def start(self):
        self.page.on("response", self._handle_response)
        self._active = True
        logger.debug("[sniffer] Started network capture")

    async def stop(self):
        try:
            self.page.remove_listener("response", self._handle_response)
        except Exception:
            pass
        self._active = False
        logger.debug(f"[sniffer] Stopped. Captured {len(self._captured)} review responses.")

    def get_captured(self) -> List[CapturedResponse]:
        return list(self._captured)

    def clear(self):
        self._captured.clear()

    async def _handle_response(self, response: Response):
        url = response.url
        if not self._is_review_url(url):
            return
        try:
            status = response.status
            if status not in (200, 206):
                return
            body = await response.body()
            if not body or len(body) < MIN_BODY_SIZE:
                logger.debug(f"[sniffer] Skipping small/empty body ({len(body) if body else 0}B): {url[:80]}")
                return
            headers = dict(response.headers)
            cap = CapturedResponse(url=url, status=status, body=body, headers=headers)
            self._captured.append(cap)
            logger.debug(f"[sniffer] Captured {len(body)}B from {url[:80]}")
            if self._on_capture:
                try:
                    self._on_capture(cap)
                except Exception as e:
                    logger.error(f"[sniffer] on_capture callback error: {e}")
        except Exception as e:
            logger.debug(f"[sniffer] Could not read body from {url[:60]}: {e}")

    @staticmethod
    def _is_review_url(url: str) -> bool:
        # Block list takes priority
        for blocked in REVIEW_URL_BLOCKLIST:
            if blocked in url:
                return False
        # Must match allowlist
        return any(pattern in url for pattern in REVIEW_URL_ALLOWLIST)