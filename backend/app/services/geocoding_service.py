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
    """Pick city-scope locality / region / country from Mapbox features.

    Strategy: scan all features + their `context` arrays, building a map
    keyed by Mapbox layer type ("place", "locality", "region", "country").
    Then pick `place` (city/town) for the locality slot, falling back to
    `locality` then `neighborhood` only when no `place` exists at all.

    Why: Mapbox sometimes tags landmarks (e.g., "Parliament Of India")
    under the `locality` layer even when the actual city is sitting in
    the context array. Taking the first locality-flavored hit produced
    user-facing advisories about "things to do in Parliament Of India".
    """
    by_layer: dict[str, str] = {}

    for feat in features:
        ptypes = feat.get("place_type") or []
        name = feat.get("text") or feat.get("place_name")
        for ptype in ptypes:
            if name and ptype not in by_layer:
                # Country prefers short_code from properties when available.
                if ptype == "country":
                    short = (feat.get("properties") or {}).get("short_code")
                    by_layer[ptype] = short or name
                else:
                    by_layer[ptype] = name
        for ctx in feat.get("context") or []:
            cid = (ctx.get("id") or "").split(".")[0]
            cname = ctx.get("text")
            if not cid or not cname or cid in by_layer:
                continue
            if cid == "country":
                by_layer[cid] = ctx.get("short_code") or cname
            else:
                by_layer[cid] = cname

    # Strict preference: `place` is the city/town. Fall back to wider /
    # narrower scopes only if `place` is genuinely absent.
    locality = (
        by_layer.get("place")
        or by_layer.get("locality")
        or by_layer.get("neighborhood")
    )
    region = by_layer.get("region")
    country = by_layer.get("country")

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
    # Request city-scope and wider only. We deliberately omit `locality` and
    # `neighborhood` from the types filter because Mapbox occasionally tags
    # landmarks (e.g. "Parliament Of India") under those layers and we don't
    # want the advisory pipeline keying off a building name. If `place` is
    # absent (rare — open country, ocean), we accept the empty result.
    params = {
        "access_token": token,
        "types": "place,region,country",
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
