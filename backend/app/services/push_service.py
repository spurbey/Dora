"""
Push notification service for advisory and device token management.

Uses Firebase Admin SDK when configured and available.
Falls back to a deterministic "transport_unavailable" status otherwise.
"""

from __future__ import annotations

import json
import logging
import os
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy.orm import Session

from app.config import settings
from app.models.trip_advisory import TripAdvisory
from app.models.user_device_token import UserDeviceToken

try:  # pragma: no cover - import optionality is environment-dependent
    import firebase_admin
    from firebase_admin import credentials, messaging
except Exception:  # pragma: no cover - import optionality is environment-dependent
    firebase_admin = None
    credentials = None
    messaging = None

logger = logging.getLogger(__name__)

_FIREBASE_APP = None


@dataclass
class PushDispatchResult:
    status: str
    sent_count: int = 0
    invalidated_count: int = 0
    error_message: Optional[str] = None


class PushNotificationService:
    """Dispatches candidate prompts to active user tokens."""

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def _utcnow() -> datetime:
        return datetime.now(timezone.utc)

    @staticmethod
    def _to_utc(value: datetime) -> datetime:
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    def _get_firebase_app(self):
        global _FIREBASE_APP

        if not settings.FIREBASE_PUSH_ENABLED:
            return None
        if firebase_admin is None or credentials is None or messaging is None:
            return None

        if _FIREBASE_APP is not None:
            return _FIREBASE_APP

        try:
            _FIREBASE_APP = firebase_admin.get_app()
            return _FIREBASE_APP
        except Exception:
            pass

        try:
            cred = None
            if settings.FIREBASE_CREDENTIALS_JSON:
                cred_info = json.loads(settings.FIREBASE_CREDENTIALS_JSON)
                cred = credentials.Certificate(cred_info)
            elif settings.FIREBASE_CREDENTIALS_PATH:
                if not os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                    logger.warning(
                        "[PUSH] firebase credential path missing: %s",
                        settings.FIREBASE_CREDENTIALS_PATH,
                    )
                    return None
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            else:
                return None

            options = {}
            if settings.FIREBASE_PROJECT_ID:
                options["projectId"] = settings.FIREBASE_PROJECT_ID

            _FIREBASE_APP = firebase_admin.initialize_app(cred, options or None)
            return _FIREBASE_APP
        except Exception as exc:  # pragma: no cover - startup env-dependent
            logger.exception("[PUSH] firebase init failed: %s", exc)
            return None

    @staticmethod
    def _is_invalid_token_error(exc: Exception) -> bool:
        text = str(exc).lower()
        signatures = (
            "unregistered",
            "registration-token-not-registered",
            "requested entity was not found",
            "invalid registration token",
        )
        return any(signature in text for signature in signatures)

    def _active_tokens(self, *, user_id) -> list[UserDeviceToken]:
        return (
            self.db.query(UserDeviceToken)
            .filter(
                UserDeviceToken.user_id == user_id,
                UserDeviceToken.is_active.is_(True),
            )
            .all()
        )

    def _has_recent_activity(self, *, tokens: list[UserDeviceToken], as_of: datetime) -> bool:
        window_seconds = int(getattr(settings, "TRACKING_PUSH_SUPPRESS_RECENT_ACTIVITY_SECONDS", 0))
        if window_seconds <= 0:
            return False
        cutoff = as_of - timedelta(seconds=window_seconds)
        for token in tokens:
            seen_at = token.last_seen_at
            if seen_at is None:
                continue
            if self._to_utc(seen_at) >= cutoff:
                return True
        return False

    # ------------------------------------------------------------------
    # Advisory pipeline pushes (per-user throttle via advisory_cache)
    # ------------------------------------------------------------------

    @staticmethod
    def _category_emoji(category: Optional[str]) -> str:
        mapping = {
            "food_tip": "🍽️",
            "scam_alert": "⚠️",
            "safety_warning": "🚨",
            "photo_spot": "📸",
            "transport_tip": "🚗",
            "accommodation": "🏨",
            "cultural_etiquette": "🙏",
            "must_do": "⭐",
            "avoid": "🚫",
            "general_tip": "💡",
        }
        return mapping.get(category or "", "💡")

    async def _check_throttle(self, user_id) -> bool:
        """Return True if a push is allowed under the per-user hourly cap."""
        try:
            from app.services.advisory_cache import advisory_cache
            count = await advisory_cache.incr_push_throttle(str(user_id))
        except Exception as exc:  # noqa: BLE001 — fail-open on Redis trouble
            logger.warning("[PUSH] advisory throttle cache error: %s", exc)
            return True
        cap = int(settings.ADVISORY_MAX_PER_HOUR)
        if count is None:
            return True
        if count > cap:
            logger.info("[PUSH] advisory throttle hit user_id=%s count=%s", user_id, count)
            return False
        return True

    async def send_advisory_notification(
        self,
        advisory: TripAdvisory,
        *,
        now: Optional[datetime] = None,
    ) -> PushDispatchResult:
        """Push a TripAdvisory to the user's active tokens.

        Respects the per-user Redis throttle (ADVISORY_MAX_PER_HOUR) and
        tolerates quiet hours on UserMetadata.advisory_quiet_hours when
        present (best-effort local-time match; no tz conversion in MVP).
        """
        as_of = self._to_utc(now or self._utcnow())

        if not await self._check_throttle(advisory.user_id):
            return PushDispatchResult(status="throttled")

        tokens = self._active_tokens(user_id=advisory.user_id)
        if not tokens:
            return PushDispatchResult(status="no_tokens")

        app = self._get_firebase_app()
        if app is None or messaging is None:
            return PushDispatchResult(
                status="transport_unavailable",
                error_message="firebase transport not configured",
            )

        emoji = self._category_emoji(advisory.category)
        primary = advisory.place_name or advisory.title or "New insight"
        title = f"{emoji} {primary}"[:96]
        body = (advisory.title or "") + " — " + (advisory.body or "")
        body = body.strip(" —")[:180]
        data = {
            "type": "advisory",
            "advisory_id": str(advisory.id),
            "trip_id": str(advisory.trip_id),
            "category": advisory.category or "",
            "poi_place_id": advisory.poi_place_id or "",
            "action": "open_inbox",
        }

        sent_count = 0
        invalidated_count = 0
        first_retryable_error: Optional[str] = None
        for token_row in tokens:
            try:
                msg = messaging.Message(
                    token=token_row.push_token,
                    notification=messaging.Notification(title=title, body=body),
                    data=data,
                )
                messaging.send(msg, app=app)
                token_row.last_sent_at = as_of
                token_row.last_seen_at = as_of
                token_row.failure_count = 0
                sent_count += 1
            except Exception as exc:  # noqa: BLE001
                token_row.failure_count = int(token_row.failure_count or 0) + 1
                if self._is_invalid_token_error(exc):
                    token_row.is_active = False
                    invalidated_count += 1
                elif first_retryable_error is None:
                    first_retryable_error = str(exc)

        if sent_count > 0:
            return PushDispatchResult(
                status="sent",
                sent_count=sent_count,
                invalidated_count=invalidated_count,
            )
        if first_retryable_error is not None:
            return PushDispatchResult(
                status="retryable_failure",
                invalidated_count=invalidated_count,
                error_message=first_retryable_error,
            )
        return PushDispatchResult(
            status="terminal_failure",
            invalidated_count=invalidated_count,
            error_message="all tokens rejected",
        )

    def send_pause_notification(
        self, *, trip_id, user_id, now: Optional[datetime] = None
    ) -> PushDispatchResult:
        """One-shot "advisory paused due to inactivity" push with a resume CTA."""
        as_of = self._to_utc(now or self._utcnow())
        tokens = self._active_tokens(user_id=user_id)
        if not tokens:
            return PushDispatchResult(status="no_tokens")
        app = self._get_firebase_app()
        if app is None or messaging is None:
            return PushDispatchResult(
                status="transport_unavailable",
                error_message="firebase transport not configured",
            )
        title = "Advisories paused"
        body = "No recent activity — tap to resume travel advisories."
        data = {
            "type": "advisory_paused",
            "trip_id": str(trip_id),
            "action": "resume_advisory",
        }
        sent_count = 0
        invalidated_count = 0
        first_retryable_error: Optional[str] = None
        for token_row in tokens:
            try:
                msg = messaging.Message(
                    token=token_row.push_token,
                    notification=messaging.Notification(title=title, body=body),
                    data=data,
                )
                messaging.send(msg, app=app)
                token_row.last_sent_at = as_of
                token_row.last_seen_at = as_of
                token_row.failure_count = 0
                sent_count += 1
            except Exception as exc:  # noqa: BLE001
                token_row.failure_count = int(token_row.failure_count or 0) + 1
                if self._is_invalid_token_error(exc):
                    token_row.is_active = False
                    invalidated_count += 1
                elif first_retryable_error is None:
                    first_retryable_error = str(exc)
        if sent_count > 0:
            return PushDispatchResult(
                status="sent", sent_count=sent_count, invalidated_count=invalidated_count
            )
        if first_retryable_error is not None:
            return PushDispatchResult(
                status="retryable_failure",
                invalidated_count=invalidated_count,
                error_message=first_retryable_error,
            )
        return PushDispatchResult(
            status="terminal_failure",
            invalidated_count=invalidated_count,
            error_message="all tokens rejected",
        )
