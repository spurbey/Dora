"""
network_sniffer.py — Layer 4: Intercept XHR/fetch for review payloads

Google Maps sends review data as binary protobuf over XHR.
We capture raw response bytes here; proto_decoder.py handles parsing.

Key insight: filter by URL patterns that match review endpoints,
not by content-type (Maps returns application/json even for proto).
"""
import asyncio
from typing import List, Callable, Optional
from dataclasses import dataclass, field
from loguru import logger
from playwright.async_api import Page, Request, Response


# URL substrings that indicate a review-data endpoint
REVIEW_URL_PATTERNS = [
    "maps/api/js/reviews",
    "listugcposts",
    "GetFeatureFeedItems",
    "maps/preview/review",
    "/maps/rpc/",
    "reviewSort",
    "localreviews",
]


@dataclass
class CapturedResponse:
    url: str
    status: int
    body: bytes
    headers: dict


class NetworkSniffer:
    """
    Attaches Playwright route/response listeners to capture raw review payloads.
    Call start() before navigation, stop() when done.
    """

    def __init__(self, page: Page):
        self.page = page
        self._captured: List[CapturedResponse] = []
        self._on_capture: Optional[Callable] = None
        self._active = False

    def on_capture(self, callback: Callable[[CapturedResponse], None]):
        """Register a callback fired each time a review response is captured."""
        self._on_capture = callback

    async def start(self):
        """Attach response listener to the page."""
        self.page.on("response", self._handle_response)
        self._active = True
        logger.debug("[sniffer] Started network capture")

    async def stop(self):
        """Remove listener."""
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
        """Filter and capture review-related responses."""
        url = response.url
        if not self._is_review_url(url):
            return

        try:
            status = response.status
            if status not in (200, 206):
                logger.debug(f"[sniffer] Skipping non-200 response {status} from {url[:80]}")
                return

            body = await response.body()
            if not body:
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
            # Response body may be unavailable for redirects etc.
            logger.debug(f"[sniffer] Could not read response body from {url[:60]}: {e}")

    @staticmethod
    def _is_review_url(url: str) -> bool:
        return any(pattern in url for pattern in REVIEW_URL_PATTERNS)