"""
Advisory Redis cache — Upstash REST wrapper.

Thin async wrapper around Upstash Redis REST API. All methods tolerate Redis
unavailability: on network/HTTP error they return `None` and log a warning,
never raise into the caller. The advisory pipeline is designed to degrade
gracefully (slower, but still correct) when Redis is down.

Keyspace (see plan: cosmic-knitting-rabbit.md §Redis Keyspace):
    brain:{trip_id}                   JSON — 24h hot cache of trip_advisory_state
    brain:{trip_id}:mode              STRING — route|radius, read by hot ingest
    brain:{trip_id}:centroid          JSON — 2h rolling centroid (radius mode)
    brain:{trip_id}:centroid:points   LIST — rolling GPS points for centroid
    geocode:{lat_b}:{lng_b}           JSON — 7d reverse-geocode cache
    weather:{lat_b}:{lng_b}:{hour}    JSON — 3h Open-Meteo forecast cache
    user:{user_id}:push_throttle      INT — 1h INCR counter for push throttle
    reddit:seed:{corridor_hash}       JSON — 72h Reddit seed corridor cache

Upstash REST takes commands as JSON arrays, e.g. ["SET","k","v","EX","60"].
https://docs.upstash.com/redis/features/restapi
"""

from __future__ import annotations

import json
import logging
import time
from typing import Any, Optional

import httpx

from app.config import settings

logger = logging.getLogger(__name__)


def _bucket(coord: float, precision: float = 0.01) -> str:
    """Round a lat/lng to precision buckets for cache key stability."""
    return f"{coord // precision * precision:.4f}"


class AdvisoryCache:
    """Upstash REST Redis client with graceful-degradation semantics."""

    _TIMEOUT_SECONDS = 3.0

    def __init__(
        self,
        url: Optional[str] = None,
        token: Optional[str] = None,
    ) -> None:
        self._url = (url or settings.UPSTASH_REDIS_URL or "").rstrip("/")
        self._token = token or settings.UPSTASH_REDIS_TOKEN or ""
        self._enabled = bool(self._url and self._token)

    # ------------------------------------------------------------------
    # low-level command dispatch
    # ------------------------------------------------------------------
    async def _cmd(self, *args: Any) -> Any:
        """Run an Upstash REST command; return parsed result or None on error.

        Caller must treat None as "cache miss or Redis unavailable".
        """
        if not self._enabled:
            return None

        body = [str(a) for a in args]
        headers = {"Authorization": f"Bearer {self._token}"}

        try:
            async with httpx.AsyncClient(timeout=self._TIMEOUT_SECONDS) as client:
                resp = await client.post(self._url, json=body, headers=headers)
                if resp.status_code != 200:
                    logger.warning(
                        "advisory_cache upstash non-200: %s %s",
                        resp.status_code,
                        resp.text[:200],
                    )
                    return None
                payload = resp.json()
                # Upstash wraps results in {"result": ...} or {"error": "..."}
                if "error" in payload:
                    logger.warning(
                        "advisory_cache upstash error: %s", payload["error"]
                    )
                    return None
                return payload.get("result")
        except (httpx.HTTPError, json.JSONDecodeError, OSError) as exc:
            logger.warning("advisory_cache upstash exception: %s", exc)
            return None

    # ------------------------------------------------------------------
    # typed helpers
    # ------------------------------------------------------------------
    async def _get_json(self, key: str) -> Optional[dict]:
        raw = await self._cmd("GET", key)
        if not raw:
            return None
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            logger.warning("advisory_cache bad JSON at key %s", key)
            return None

    async def _set_json(
        self, key: str, value: dict, ttl_seconds: Optional[int] = None
    ) -> None:
        payload = json.dumps(value, separators=(",", ":"), default=str)
        if ttl_seconds is not None:
            await self._cmd("SET", key, payload, "EX", int(ttl_seconds))
        else:
            await self._cmd("SET", key, payload)

    # ------------------------------------------------------------------
    # brain cache
    # ------------------------------------------------------------------
    async def get_brain(self, trip_id: str) -> Optional[dict]:
        return await self._get_json(f"brain:{trip_id}")

    async def set_brain(self, trip_id: str, data: dict) -> None:
        await self._set_json(
            f"brain:{trip_id}",
            data,
            ttl_seconds=settings.ADVISORY_BRAIN_CACHE_TTL_SECONDS,
        )

    async def invalidate_brain(self, trip_id: str) -> None:
        await self._cmd("DEL", f"brain:{trip_id}")

    # ------------------------------------------------------------------
    # mode cache (read by hot GPS ingest path)
    # ------------------------------------------------------------------
    async def get_mode(self, trip_id: str) -> Optional[str]:
        raw = await self._cmd("GET", f"brain:{trip_id}:mode")
        return raw if raw in ("route", "radius") else None

    async def set_mode(self, trip_id: str, mode: str) -> None:
        if mode not in ("route", "radius"):
            return
        await self._cmd(
            "SET",
            f"brain:{trip_id}:mode",
            mode,
            "EX",
            int(settings.ADVISORY_MODE_CACHE_TTL_SECONDS),
        )

    # ------------------------------------------------------------------
    # centroid (radius mode)
    # ------------------------------------------------------------------
    async def push_centroid_point(
        self, trip_id: str, lat: float, lng: float, now_ts: Optional[float] = None
    ) -> None:
        """Append a GPS point to the rolling 2h centroid buffer.

        Stored as a LIST of "{ts}:{lat}:{lng}" strings. TTL refreshed on
        every push; per-entry trimming handled by get_centroid at read
        time (cheaper than LREM-per-push).
        """
        ts = now_ts if now_ts is not None else time.time()
        entry = f"{ts:.0f}:{lat:.6f}:{lng:.6f}"
        key = f"brain:{trip_id}:centroid:points"
        await self._cmd("LPUSH", key, entry)
        # Cap list at 500 points to bound memory growth
        await self._cmd("LTRIM", key, "0", "499")
        # TTL matches centroid window
        await self._cmd(
            "EXPIRE",
            key,
            int(settings.ADVISORY_CENTROID_WINDOW_SECONDS),
        )

    async def get_centroid_points(
        self, trip_id: str, window_seconds: Optional[int] = None
    ) -> list[tuple[float, float, float]]:
        """Return list of (ts, lat, lng) for points within the window."""
        if window_seconds is None:
            window_seconds = settings.ADVISORY_CENTROID_WINDOW_SECONDS
        raw = await self._cmd("LRANGE", f"brain:{trip_id}:centroid:points", "0", "-1")
        if not raw:
            return []
        cutoff = time.time() - window_seconds
        out: list[tuple[float, float, float]] = []
        for entry in raw:
            try:
                ts_s, lat_s, lng_s = entry.split(":")
                ts = float(ts_s)
                if ts >= cutoff:
                    out.append((ts, float(lat_s), float(lng_s)))
            except (ValueError, AttributeError):
                continue
        return out

    # ------------------------------------------------------------------
    # push throttle
    # ------------------------------------------------------------------
    async def incr_push_throttle(self, user_id: str) -> Optional[int]:
        """Increment per-user hourly push counter; return new count or None."""
        key = f"user:{user_id}:push_throttle"
        count = await self._cmd("INCR", key)
        if count == 1:
            # First increment in window — set expiry.
            await self._cmd("EXPIRE", key, 3600)
        try:
            return int(count) if count is not None else None
        except (TypeError, ValueError):
            return None

    # ------------------------------------------------------------------
    # geocode cache
    # ------------------------------------------------------------------
    def geocode_key(self, lat: float, lng: float) -> str:
        return f"geocode:{_bucket(lat)}:{_bucket(lng)}"

    async def get_geocode(self, lat: float, lng: float) -> Optional[dict]:
        return await self._get_json(self.geocode_key(lat, lng))

    async def set_geocode(self, lat: float, lng: float, value: dict) -> None:
        await self._set_json(
            self.geocode_key(lat, lng),
            value,
            ttl_seconds=settings.ADVISORY_GEOCODE_CACHE_TTL_SECONDS,
        )

    # ------------------------------------------------------------------
    # weather cache
    # ------------------------------------------------------------------
    def weather_key(self, lat: float, lng: float, hour_epoch: int) -> str:
        return f"weather:{_bucket(lat)}:{_bucket(lng)}:{hour_epoch}"

    async def get_weather(
        self, lat: float, lng: float, hour_epoch: int
    ) -> Optional[dict]:
        return await self._get_json(self.weather_key(lat, lng, hour_epoch))

    async def set_weather(
        self, lat: float, lng: float, hour_epoch: int, value: dict
    ) -> None:
        await self._set_json(
            self.weather_key(lat, lng, hour_epoch),
            value,
            ttl_seconds=settings.ADVISORY_WEATHER_CACHE_TTL_SECONDS,
        )

    # ------------------------------------------------------------------
    # reddit seed cache (shared across trips with same corridor hash)
    # ------------------------------------------------------------------
    async def get_reddit_seed(self, corridor_hash: str) -> Optional[dict]:
        return await self._get_json(f"reddit:seed:{corridor_hash}")

    async def set_reddit_seed(self, corridor_hash: str, value: dict) -> None:
        await self._set_json(
            f"reddit:seed:{corridor_hash}",
            value,
            ttl_seconds=settings.ADVISORY_REDDIT_SEED_CACHE_TTL_SECONDS,
        )


# Module-level singleton for convenience.
advisory_cache = AdvisoryCache()
