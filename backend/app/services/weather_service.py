"""
Weather service — Open-Meteo forecast for advisory pipeline.

Free, no-auth, decent accuracy. We fetch the hourly forecast surrounding a
target arrival time, normalize to a small WeatherForecast dataclass, and
cache by (lat_bucket, lng_bucket, hour_epoch) for 3h.

get_forecast(lat, lng, when) returns None on any failure — caller proceeds
without weather context (rule-filter falls through).
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Optional

import httpx

from app.services.advisory_cache import advisory_cache

logger = logging.getLogger(__name__)


OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"
_TIMEOUT_SECONDS = 4.0


# Open-Meteo WMO weather codes → coarse label.
# https://open-meteo.com/en/docs (WMO Weather interpretation codes)
_WEATHER_LABELS = {
    0: "clear",
    1: "mostly_clear",
    2: "partly_cloudy",
    3: "overcast",
    45: "fog",
    48: "fog",
    51: "drizzle",
    53: "drizzle",
    55: "drizzle",
    61: "rain_light",
    63: "rain",
    65: "rain_heavy",
    71: "snow_light",
    73: "snow",
    75: "snow_heavy",
    80: "showers",
    81: "showers",
    82: "showers_heavy",
    95: "thunderstorm",
    96: "thunderstorm_hail",
    99: "thunderstorm_hail",
}


@dataclass
class WeatherForecast:
    temp_c: Optional[float]
    precipitation_probability: Optional[int]   # 0..100
    weather_code: Optional[int]
    weather_label: Optional[str]
    is_daylight: Optional[bool]
    sunrise_ts: Optional[float]
    sunset_ts: Optional[float]

    def to_dict(self) -> dict:
        return asdict(self)


def _hour_bucket(when: datetime) -> int:
    """Epoch seconds truncated to the hour — cache key partition."""
    aware = when if when.tzinfo else when.replace(tzinfo=timezone.utc)
    hour = aware.replace(minute=0, second=0, microsecond=0)
    return int(hour.timestamp())


def _pick_hour_index(times: list[str], target_iso: str) -> int:
    """Return the index of the hourly slot closest to target_iso."""
    if not times:
        return 0
    # Open-Meteo returns ISO strings like "2026-04-15T12:00". Lexical compare
    # works for slicing when dates share tz (we asked for timezone=auto so
    # they all do).
    best = 0
    for i, t in enumerate(times):
        if t <= target_iso:
            best = i
        else:
            break
    return best


async def get_forecast(
    lat: float, lng: float, when: Optional[datetime] = None
) -> Optional[WeatherForecast]:
    """Return weather forecast for (lat, lng) at `when` (defaults to now)."""
    if when is None:
        when = datetime.now(timezone.utc)

    hour_key = _hour_bucket(when)
    cached = await advisory_cache.get_weather(lat, lng, hour_key)
    if cached:
        try:
            return WeatherForecast(**cached)
        except TypeError:
            logger.warning("weather cache malformed at (%s, %s)", lat, lng)

    params = {
        "latitude": f"{lat:.4f}",
        "longitude": f"{lng:.4f}",
        "hourly": "temperature_2m,precipitation_probability,weather_code,is_day",
        "daily": "sunrise,sunset",
        "timezone": "auto",
        "forecast_days": 2,
    }

    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT_SECONDS) as client:
            resp = await client.get(OPEN_METEO_URL, params=params)
    except (httpx.HTTPError, OSError) as exc:
        logger.warning("weather http error at (%s, %s): %s", lat, lng, exc)
        return None

    if resp.status_code != 200:
        logger.warning(
            "weather non-200 at (%s, %s): %s", lat, lng, resp.status_code
        )
        return None

    payload = resp.json()
    hourly = payload.get("hourly") or {}
    times = hourly.get("time") or []
    temps = hourly.get("temperature_2m") or []
    probs = hourly.get("precipitation_probability") or []
    codes = hourly.get("weather_code") or []
    is_day = hourly.get("is_day") or []

    target_iso = when.astimezone().replace(minute=0, second=0).strftime(
        "%Y-%m-%dT%H:00"
    )
    idx = _pick_hour_index(times, target_iso)

    def _at(lst: list, i: int):
        return lst[i] if 0 <= i < len(lst) else None

    code = _at(codes, idx)
    daily = payload.get("daily") or {}
    sunrise_list = daily.get("sunrise") or []
    sunset_list = daily.get("sunset") or []

    def _iso_to_ts(iso_str: Optional[str]) -> Optional[float]:
        if not iso_str:
            return None
        try:
            return datetime.fromisoformat(iso_str).timestamp()
        except (ValueError, TypeError):
            return None

    forecast = WeatherForecast(
        temp_c=_at(temps, idx),
        precipitation_probability=_at(probs, idx),
        weather_code=code,
        weather_label=_WEATHER_LABELS.get(code) if code is not None else None,
        is_daylight=bool(_at(is_day, idx)) if _at(is_day, idx) is not None else None,
        sunrise_ts=_iso_to_ts(sunrise_list[0] if sunrise_list else None),
        sunset_ts=_iso_to_ts(sunset_list[0] if sunset_list else None),
    )
    await advisory_cache.set_weather(lat, lng, hour_key, forecast.to_dict())
    return forecast
