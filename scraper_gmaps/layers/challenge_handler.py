"""
challenge_handler.py — Layer 3: Detect and handle Google interrupts

Three challenge types on Google Maps:
  1. Consent / cookie dialog (EU/UK)
  2. reCAPTCHA v3 — silent, score-based (hard to detect directly)
  3. HTTP 429 / "unusual traffic" page

Strategy: detect → pause → optionally solve → rotate session if unsolvable.
"""
import asyncio, os
from enum import Enum
from typing import Optional, Callable
from loguru import logger
from playwright.async_api import Page


class ChallengeType(Enum):
    NONE = "none"
    CONSENT = "consent"
    CAPTCHA = "captcha"
    RATE_LIMITED = "rate_limited"
    UNKNOWN_BLOCK = "unknown_block"


CHALLENGE_SIGNALS = {
    ChallengeType.CONSENT: [
        'button[aria-label*="Accept"]',
        'button[id*="accept"]',
        'form[action*="consent.google"]',
    ],
    ChallengeType.CAPTCHA: [
        'iframe[src*="recaptcha"]',
        'div.g-recaptcha',
        '#captcha-form',
    ],
    ChallengeType.RATE_LIMITED: [
        # Google's unusual traffic page
    ],
}

BLOCK_URL_PATTERNS = [
    "sorry/index",
    "recaptcha",
    "unusual_traffic",
]


class ChallengeHandler:
    def __init__(self, page: Page, on_session_rotate: Optional[Callable] = None):
        self.page = page
        self.on_session_rotate = on_session_rotate
        self._capsolver_key = os.getenv("CAPSOLVER_API_KEY", "")

    async def check(self) -> ChallengeType:
        """Inspect current page state and return challenge type."""
        url = self.page.url

        # URL-based detection (fastest)
        for pattern in BLOCK_URL_PATTERNS:
            if pattern in url:
                logger.warning(f"[challenge] Detected block via URL pattern: {pattern}")
                return ChallengeType.RATE_LIMITED

        # DOM-based detection
        for challenge_type, selectors in CHALLENGE_SIGNALS.items():
            for sel in selectors:
                try:
                    el = await self.page.query_selector(sel)
                    if el:
                        logger.warning(f"[challenge] Detected {challenge_type.value} via selector: {sel}")
                        return challenge_type
                except Exception:
                    pass

        return ChallengeType.NONE

    async def handle(self) -> bool:
        """
        Detect and attempt to resolve any challenge.
        Returns True if resolved (safe to continue), False if session should rotate.
        """
        challenge = await self.check()

        if challenge == ChallengeType.NONE:
            return True

        if challenge == ChallengeType.CONSENT:
            return await self._handle_consent()

        if challenge == ChallengeType.CAPTCHA:
            return await self._handle_captcha()

        if challenge == ChallengeType.RATE_LIMITED:
            logger.error("[challenge] Rate limited — triggering session rotation")
            if self.on_session_rotate:
                await self.on_session_rotate()
            return False

        logger.error(f"[challenge] Unknown block: {challenge.value}")
        return False

    async def _handle_consent(self) -> bool:
        """Click through consent dialogs."""
        accept_selectors = [
            'button[aria-label*="Accept all"]',
            'button[aria-label*="Accept"]',
            'button[id*="accept"]',
            '#L2AGLb',  # Google's consent button ID
        ]
        for sel in accept_selectors:
            try:
                btn = await self.page.query_selector(sel)
                if btn:
                    await btn.click()
                    await asyncio.sleep(1.5)
                    logger.info("[challenge] Consent dialog dismissed")
                    return True
            except Exception:
                pass
        logger.warning("[challenge] Consent dialog found but couldn't dismiss it")
        return False

    async def _handle_captcha(self) -> bool:
        """
        Attempt CAPTCHA resolution.
        With CapSolver: routes to their API.
        Without: pauses for 60s (manual intervention) then checks if cleared.
        """
        if self._capsolver_key:
            return await self._solve_with_capsolver()

        logger.warning(
            "[challenge] CAPTCHA detected. No solver configured. "
            "Waiting 60s for manual resolution..."
        )
        await asyncio.sleep(60)

        # Check if it's gone
        challenge = await self.check()
        if challenge == ChallengeType.NONE:
            logger.info("[challenge] CAPTCHA cleared (manual)")
            return True

        logger.error("[challenge] CAPTCHA not resolved — rotating session")
        if self.on_session_rotate:
            await self.on_session_rotate()
        return False

    async def _solve_with_capsolver(self) -> bool:
        """
        CapSolver integration stub.
        Full implementation requires capsolver-python package.
        """
        try:
            import httpx
            # Get site key from page
            frame = self.page.frames[0] if self.page.frames else None
            site_key = "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-"  # default reCAPTCHA v3 key

            payload = {
                "clientKey": self._capsolver_key,
                "task": {
                    "type": "ReCaptchaV3TaskProxyless",
                    "websiteURL": self.page.url,
                    "websiteKey": site_key,
                    "pageAction": "maps",
                    "minScore": 0.7,
                },
            }
            async with httpx.AsyncClient() as client:
                r = await client.post(
                    "https://api.capsolver.com/createTask",
                    json=payload, timeout=10
                )
                data = r.json()
                task_id = data.get("taskId")
                if not task_id:
                    return False

                # Poll for result
                for _ in range(30):
                    await asyncio.sleep(3)
                    poll = await client.post(
                        "https://api.capsolver.com/getTaskResult",
                        json={"clientKey": self._capsolver_key, "taskId": task_id},
                        timeout=10,
                    )
                    result = poll.json()
                    if result.get("status") == "ready":
                        token = result["solution"]["gRecaptchaResponse"]
                        # Inject token into page
                        await self.page.evaluate(
                            f'document.getElementById("g-recaptcha-response").value = "{token}";'
                        )
                        logger.info("[challenge] CapSolver resolved CAPTCHA")
                        return True

        except Exception as e:
            logger.error(f"[challenge] CapSolver failed: {e}")
        return False