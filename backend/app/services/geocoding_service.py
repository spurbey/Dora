"""
Geocoding service — Mapbox reverse geocoding for the advisory pipeline.

reverse_geocode() takes a lat/lng and returns a normalized GeocodeResult
(locality, region, country, locality_key, center). Results cached in Redis
for 7 days via AdvisoryCache. Network/rate-limit errors return None and are
logged — the caller decides how to retry.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, asdict
from typing import Optional

import httpx

from app.config import settings
from app.services.advisory_cache import advisory_cache

logger = logging.getLogger(__name__)


MAPBOX_REVERSE_URL = "https://api.mapbox.com/geocoding/v5/mapbox.places/{lng},{lat}.json"
_TIMEOUT_SECONDS = 4.0


@dataclass
class GeocodeResult:
    locality: Optional[str]
    region: Optional[str]
    country: Optional[str]
    locality_key: str            # "{country}:{region}:{locality}" — stable slug
    center_lat: float
    center_lng: float
    raw: Optional[dict] = None   # original Mapbox feature for debugging

    def to_dict(self) -> dict:
        d = asdict(self)
        # Keep raw out of caches to bound size.
        d.pop("raw", None)
        return d


def _slug(value: Optional[str]) -> str:
    if not value:
        return ""
    return value.replace(":", "_").strip()


def _build_locality_key(
    country: Optional[str],
    region: Optional[str],
    locality: Optional[str],
) -> str:
    return f"{_slug(country)}:{_slug(region)}:{_slug(locality)}"


def _extract_from_features(features: list[dict]) -> tuple[Optional[str], Optional[str], Optional[str]]:
    """Pick locality / region / country from Mapbox feature hierarchy.

    Mapbox places the most-specific match first. The `place_type` field
    identifies the level of each feature and context entries have `id`
    prefixes like "place.xxx", "region.xxx", "country.xxx".
    """
    locality: Optional[str] = None
    region: Optional[str] = None
    country: Optional[str] = None

    for feat in features:
        ptypes = set(feat.get("place_type") or [])
        name = feat.get("text") or feat.get("place_name")
        if "locality" in ptypes or "place" in ptypes or "neighborhood" in ptypes:
            if not locality:
                locality = name
        elif "region" in ptypes:
            if not region:
                region = name
        elif "country" in ptypes:
            if not country:
                country = feat.get("properties", {}).get("short_code") or name
        # Also walk context for missing pieces.
        for ctx in feat.get("context") or []:
            cid = (ctx.get("id") or "").split(".")[0]
            cname = ctx.get("text")
            if cid in ("place", "locality", "neighborhood") and not locality:
                locality = cname
            elif cid == "region" and not region:
                region = cname
            elif cid == "country" and not country:
                country = ctx.get("short_code") or cname

    return locality, region, country


async def reverse_geocode(lat: float, lng: float) -> Optional[GeocodeResult]:
    """Reverse-geocode a GPS point. Cache-backed, fail-soft."""
    # Cache hit?
    cached = await advisory_cache.get_geocode(lat, lng)
    if cached:
        try:
            return GeocodeResult(**cached)
        except TypeError:
            logger.warning("geocode cache malformed at (%s, %s)", lat, lng)

    token = settings.MAPBOX_API_KEY
    if not token:
        logger.warning("MAPBOX_API_KEY not set — reverse geocode disabled")
        return None

    url = MAPBOX_REVERSE_URL.format(lng=lng, lat=lat)
    params = {
        "access_token": token,
        "types": "place,locality,region,country,neighborhood",
        "limit": 1,
    }

    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT_SECONDS) as client:
            resp = await client.get(url, params=params)
    except (httpx.HTTPError, OSError) as exc:
        logger.warning("reverse_geocode http error at (%s, %s): %s", lat, lng, exc)
        return None

    if resp.status_code != 200:
        logger.warning(
            "reverse_geocode non-200 at (%s, %s): %s", lat, lng, resp.status_code
        )
        return None

    payload = resp.json()
    features = payload.get("features") or []
    if not features:
        return None

    locality, region, country = _extract_from_features(features)
    top = features[0]
    center = top.get("center") or [lng, lat]  # [lng, lat] per GeoJSON

    result = GeocodeResult(
        locality=locality,
        region=region,
        country=country,
        locality_key=_build_locality_key(country, region, locality),
        center_lat=center[1],
        center_lng=center[0],
    )
    await advisory_cache.set_geocode(lat, lng, result.to_dict())
    return result
