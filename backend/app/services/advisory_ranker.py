"""
Advisory Ranker — hard rule filter → soft scoring → LLM final pick.

Turns a raw pool of GMaps POIs plus Reddit findings and brain context into
the top 3 advisory picks with LLM-generated title/body copy.

Staged for clarity and deterministic testing:

    1. hard_filter(pois, ctx)
          Remove POIs that violate absolute rules: already advised (dedupe),
          flagged by Reddit as "avoid"/"scam_alert", weather-incompatible,
          or outside reasonable distance from the locality centroid.

    2. soft_score(pois, ctx, reviews_by_poi)
          Assign a heuristic 0..1 score based on dietary match, budget fit,
          time-of-day affinity (cafe morning / bar night), activity_focus,
          review rating quality, and category diversity vs recent_categories.

    3. llm_pick(top_k, ctx)
          OpenRouter call with structured JSON output to select the final
          3 and author a title + body for each. Falls back to the top-3 by
          soft score with templated copy if the LLM is unreachable.

Cost note: one OpenRouter call per cycle, short prompt. Tracks well inside
the free tier quota described in the plan.
"""

from __future__ import annotations

import json
import logging
import math
import re
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Iterable, Optional

import httpx
from pydantic import BaseModel, Field, ValidationError

from app.config import settings

logger = logging.getLogger(__name__)

OPENROUTER_CHAT_URL = "https://openrouter.ai/api/v1/chat/completions"
_LLM_TIMEOUT_SECONDS = 15.0

# -- tuning constants -------------------------------------------------------

# Weather rule: if precipitation probability >= this, prefer indoor POIs.
_RAINY_THRESHOLD_PCT = 55

# Category hints for indoor/outdoor split — kept deliberately small and
# case-insensitive substring match on category.
_OUTDOOR_HINTS = ("park", "garden", "beach", "hike", "trail", "viewpoint", "lake", "river")
_INDOOR_HINTS = (
    "cafe",
    "restaurant",
    "museum",
    "gallery",
    "mall",
    "bar",
    "bookstore",
    "bakery",
)

# Time-of-day affinity: hour -> preferred category buckets.
_MORNING_CATS = ("cafe", "bakery", "breakfast", "park")
_AFTERNOON_CATS = ("museum", "gallery", "attraction", "market", "shopping")
_EVENING_CATS = ("restaurant", "bar", "pub", "viewpoint", "theater")

# Reddit insight categories treated as "warnings" — any hit blocks the POI.
_WARNING_CATEGORIES = {"avoid", "scam_alert", "safety_warning"}


# ---------------------------------------------------------------------------
# Result types
# ---------------------------------------------------------------------------


@dataclass
class RankedPOI:
    """A POI that survived the hard filter, with soft score attached."""
    place_id: str
    name: str
    category: Optional[str]
    rating: Optional[float]
    review_count: Optional[int]
    url: str
    lat: Optional[float]
    lng: Optional[float]
    price_level: Optional[str]
    soft_score: float
    reasons: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "place_id": self.place_id,
            "name": self.name,
            "category": self.category,
            "rating": self.rating,
            "review_count": self.review_count,
            "url": self.url,
            "lat": self.lat,
            "lng": self.lng,
            "price_level": self.price_level,
            "soft_score": self.soft_score,
            "reasons": self.reasons,
        }


@dataclass
class AdvisoryPick:
    """Final pick returned to the delivery stage."""
    place_id: str
    name: str
    category: Optional[str]
    title: str
    body: str
    reason: str
    lat: Optional[float]
    lng: Optional[float]
    url: str
    confidence: float           # 0..1, carried to TripAdvisory.confidence_score
    source: str = "combined"     # "combined" when Reddit + GMaps agree; else "google_maps"


# ---------------------------------------------------------------------------
# LLM response schema (structured output)
# ---------------------------------------------------------------------------


class LLMPick(BaseModel):
    place_id: str = Field(description="Identifier of the chosen POI from input list")
    title: str = Field(description="Short advisory title, <= 60 chars")
    body: str = Field(description="1-3 sentence actionable recommendation, <= 240 chars")
    reason: str = Field(description="Why this POI fits the user now")


class LLMPickResponse(BaseModel):
    picked: list[LLMPick]


# ---------------------------------------------------------------------------
# Hard filter
# ---------------------------------------------------------------------------


def _category_hits_any(category: Optional[str], hints: Iterable[str]) -> bool:
    if not category:
        return False
    c = category.lower()
    return any(h in c for h in hints)


def _weather_blocks(category: Optional[str], weather: Optional[dict]) -> bool:
    if not weather:
        return False
    precip = weather.get("precipitation_probability")
    if precip is None:
        return False
    if precip < _RAINY_THRESHOLD_PCT:
        return False
    # Rain likely: block outdoor categories.
    return _category_hits_any(category, _OUTDOOR_HINTS)


def _reddit_warns_against(name: str, reddit_insights: list[dict]) -> Optional[str]:
    """Return the warning text if any Reddit insight flags this place, else None."""
    if not name or not reddit_insights:
        return None
    name_l = name.lower()
    for ins in reddit_insights:
        cat = (ins.get("category") or "").lower()
        if cat not in _WARNING_CATEGORIES:
            continue
        place = (ins.get("place_name") or "").lower()
        if not place:
            continue
        # Substring match either direction — reviews name businesses loosely.
        if place in name_l or name_l in place:
            return ins.get("insight") or ins.get("body") or cat
    return None


def hard_filter(
    pois: list[dict],
    *,
    advised_poi_place_ids: Iterable[str],
    reddit_insights: list[dict],
    weather: Optional[dict],
) -> list[dict]:
    """Remove POIs that violate absolute rules. Returns a subset of `pois`.

    `pois` is a list of POI dicts (POISearchResult.to_dict() shape).
    """
    advised = set(advised_poi_place_ids or ())
    out: list[dict] = []
    for p in pois:
        pid = p.get("place_id") or ""
        name = p.get("name") or ""
        category = p.get("category")
        if not name:
            continue
        if pid and pid in advised:
            continue
        if _weather_blocks(category, weather):
            continue
        warn = _reddit_warns_against(name, reddit_insights)
        if warn:
            logger.info("ranker blocked %s (reddit warning: %s)", name, warn[:80])
            continue
        out.append(p)
    return out


# ---------------------------------------------------------------------------
# Soft scoring
# ---------------------------------------------------------------------------


def _time_of_day_bonus(category: Optional[str], now: datetime) -> float:
    hour = now.hour
    if 5 <= hour < 11:
        buckets = _MORNING_CATS
    elif 11 <= hour < 17:
        buckets = _AFTERNOON_CATS
    else:
        buckets = _EVENING_CATS
    return 0.1 if _category_hits_any(category, buckets) else 0.0


def _rating_bonus(rating: Optional[float], review_count: Optional[int]) -> float:
    if rating is None:
        return 0.0
    # Cap at 1.0 (rating/5) scaled to 0.25 weight; confidence uplift from
    # review count gently tops out.
    base = max(0.0, min(rating, 5.0)) / 5.0 * 0.25
    if not review_count:
        return base
    conf = min(1.0, math.log10(max(review_count, 1) + 1) / 3.0)  # 0..1 rough
    return base + 0.05 * conf


def _dietary_match(
    category: Optional[str], dietary: list[str]
) -> float:
    """Naive category-name match to dietary restrictions (strong negative on conflict)."""
    if not category or not dietary:
        return 0.0
    c = category.lower()
    bonus = 0.0
    for tag in dietary:
        t = (tag or "").lower()
        if not t:
            continue
        if t in c:
            bonus += 0.1
        # Conflict heuristics (cheap, not a substitute for LLM check).
        if t == "vegetarian" and "steakhouse" in c:
            return -0.4
        if t == "halal" and ("pork" in c or "bbq" in c):
            return -0.25
    return bonus


def _activity_focus_bonus(category: Optional[str], focus: list[str]) -> float:
    if not category or not focus:
        return 0.0
    c = category.lower()
    hit = 0
    for f in focus:
        if (f or "").lower() in c:
            hit += 1
    return min(0.15, 0.075 * hit)


def _diversity_penalty(
    category: Optional[str], recent_categories: dict[str, int]
) -> float:
    if not category or not recent_categories:
        return 0.0
    c = category.lower()
    worst = 0
    for seen_cat, count in recent_categories.items():
        if not seen_cat:
            continue
        if seen_cat.lower() in c or c in seen_cat.lower():
            if count > worst:
                worst = count
    # Every repeat beyond the first shaves off a bit.
    return -min(0.3, 0.1 * max(0, worst - 1))


def soft_score(
    pois: list[dict],
    *,
    user_metadata: dict,
    trip_metadata: dict,
    recent_categories: dict,
    now: Optional[datetime] = None,
) -> list[RankedPOI]:
    """Return POIs sorted by descending soft score."""
    now = now or datetime.now(timezone.utc)
    dietary = list(user_metadata.get("dietary_restrictions") or [])
    focus = list(trip_metadata.get("activity_focus") or [])

    ranked: list[RankedPOI] = []
    for p in pois:
        reasons: list[str] = []
        score = 0.0

        r_bonus = _rating_bonus(p.get("rating"), p.get("review_count"))
        if r_bonus:
            reasons.append(f"rating_bonus={r_bonus:.2f}")
            score += r_bonus

        t_bonus = _time_of_day_bonus(p.get("category"), now)
        if t_bonus:
            reasons.append(f"time_of_day_bonus={t_bonus:.2f}")
            score += t_bonus

        d_bonus = _dietary_match(p.get("category"), dietary)
        if d_bonus:
            reasons.append(f"dietary={d_bonus:+.2f}")
            score += d_bonus

        a_bonus = _activity_focus_bonus(p.get("category"), focus)
        if a_bonus:
            reasons.append(f"activity_focus={a_bonus:+.2f}")
            score += a_bonus

        div_pen = _diversity_penalty(p.get("category"), recent_categories)
        if div_pen:
            reasons.append(f"diversity={div_pen:+.2f}")
            score += div_pen

        # Clamp to [0, 1] for stable downstream reasoning.
        score = max(0.0, min(1.0, score))

        ranked.append(
            RankedPOI(
                place_id=p.get("place_id") or "",
                name=p.get("name") or "",
                category=p.get("category"),
                rating=p.get("rating"),
                review_count=p.get("review_count"),
                url=p.get("url") or "",
                lat=p.get("lat"),
                lng=p.get("lng"),
                price_level=p.get("price_level"),
                soft_score=score,
                reasons=reasons,
            )
        )

    ranked.sort(key=lambda r: r.soft_score, reverse=True)
    return ranked


# ---------------------------------------------------------------------------
# LLM final pick (with deterministic fallback)
# ---------------------------------------------------------------------------


def _fallback_copy(ranked: list[RankedPOI], locality: str) -> list[AdvisoryPick]:
    """Templated copy when the LLM is unreachable. Used only as a safety net."""
    out: list[AdvisoryPick] = []
    for r in ranked[:3]:
        category = (r.category or "place").lower()
        rating_txt = f" ({r.rating:.1f}★)" if r.rating else ""
        title = f"{r.name}{rating_txt}"[:60]
        body = (
            f"Popular {category} in {locality} — "
            f"{r.review_count or 'many'} reviews, {r.rating or 'well'} rated."
        )[:240]
        out.append(
            AdvisoryPick(
                place_id=r.place_id,
                name=r.name,
                category=r.category,
                title=title,
                body=body,
                reason="heuristic_fallback",
                lat=r.lat,
                lng=r.lng,
                url=r.url,
                confidence=round(0.55 + 0.2 * r.soft_score, 2),
                source="google_maps",
            )
        )
    return out


def _llm_prompt(
    ranked: list[RankedPOI],
    context: dict,
    locality: str,
    reviews_by_poi: dict[str, list[dict]],
) -> list[dict]:
    """Build the OpenRouter chat messages."""
    poi_lines = []
    for r in ranked[:8]:
        reviews = reviews_by_poi.get(r.place_id, [])[:3]
        review_blurbs = " | ".join((rev.get("text") or "")[:120] for rev in reviews)
        poi_lines.append(
            f"- place_id={r.place_id} | {r.name} | cat={r.category or '-'} | "
            f"rating={r.rating or '-'} ({r.review_count or 0} reviews) | "
            f"soft_score={r.soft_score:.2f} | reviews: {review_blurbs or '(none)'}"
        )
    system = (
        "You are a concise travel concierge. Given a list of POI candidates in "
        "a single locality and the traveler's context, pick the top 3 that best "
        "fit NOW (time, weather, preferences, recent category balance). Respond "
        "as JSON matching the schema exactly. Keep titles <= 60 chars and bodies "
        "<= 240 chars. Do NOT invent place_id values; use only ids from the list."
    )
    user = (
        f"Locality: {locality}\n"
        f"Trip metadata: {json.dumps(context.get('trip_metadata') or {}, default=str)}\n"
        f"User metadata: {json.dumps(context.get('user_metadata') or {}, default=str)}\n"
        f"Weather: {json.dumps(context.get('weather') or {}, default=str)}\n"
        f"Recent categories already delivered this trip: "
        f"{json.dumps(context.get('recent_categories') or {}, default=str)}\n"
        f"POI candidates:\n" + "\n".join(poi_lines)
    )
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


async def _call_openrouter(messages: list[dict]) -> Optional[LLMPickResponse]:
    if not settings.OPENROUTER_API_KEY:
        logger.info("OPENROUTER_API_KEY not set — ranker skipping LLM call")
        return None
    payload = {
        "model": settings.OPENROUTER_MODEL,
        "messages": messages,
        "temperature": 0.2,
        "response_format": {
            "type": "json_schema",
            "json_schema": {
                "name": "llm_pick_response",
                "strict": True,
                "schema": LLMPickResponse.model_json_schema(),
            },
        },
    }
    headers = {
        "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }
    try:
        async with httpx.AsyncClient(timeout=_LLM_TIMEOUT_SECONDS) as client:
            resp = await client.post(
                OPENROUTER_CHAT_URL, json=payload, headers=headers
            )
    except (httpx.HTTPError, OSError) as exc:
        logger.warning("ranker openrouter http error: %s", exc)
        return None
    if resp.status_code != 200:
        logger.warning(
            "ranker openrouter non-200: %s %s", resp.status_code, resp.text[:200]
        )
        return None
    try:
        body = resp.json()
        content = body["choices"][0]["message"]["content"]
        parsed = json.loads(content) if isinstance(content, str) else content
        return LLMPickResponse.model_validate(parsed)
    except (KeyError, ValueError, ValidationError, TypeError) as exc:
        logger.warning("ranker openrouter parse error: %s", exc)
        return None


async def llm_pick(
    ranked: list[RankedPOI],
    *,
    locality: str,
    context: dict,
    reviews_by_poi: Optional[dict[str, list[dict]]] = None,
) -> list[AdvisoryPick]:
    """Top-3 final picks with LLM-authored copy; fallback to templated."""
    if not ranked:
        return []
    reviews_by_poi = reviews_by_poi or {}

    messages = _llm_prompt(ranked, context, locality, reviews_by_poi)
    response = await _call_openrouter(messages)
    if response is None or not response.picked:
        return _fallback_copy(ranked, locality)

    lookup: dict[str, RankedPOI] = {r.place_id: r for r in ranked}
    picks: list[AdvisoryPick] = []
    reviews_flag = {pid: bool(reviews_by_poi.get(pid)) for pid in lookup}

    for item in response.picked[:3]:
        r = lookup.get(item.place_id)
        if r is None:
            continue
        picks.append(
            AdvisoryPick(
                place_id=r.place_id,
                name=r.name,
                category=r.category,
                title=(item.title or r.name)[:60],
                body=(item.body or "")[:240],
                reason=item.reason or "llm_pick",
                lat=r.lat,
                lng=r.lng,
                url=r.url,
                confidence=round(0.65 + 0.25 * r.soft_score, 2),
                source="combined" if reviews_flag.get(r.place_id) else "google_maps",
            )
        )

    if not picks:
        # LLM returned items that didn't map to any known place_id.
        return _fallback_copy(ranked, locality)

    return picks


# ---------------------------------------------------------------------------
# Top-level entry
# ---------------------------------------------------------------------------


async def rank_and_pick(
    *,
    pois: list[dict],
    locality: str,
    advised_poi_place_ids: Iterable[str],
    reddit_insights: list[dict],
    weather: Optional[dict],
    user_metadata: dict,
    trip_metadata: dict,
    recent_categories: dict,
    reviews_by_poi: Optional[dict[str, list[dict]]] = None,
    now: Optional[datetime] = None,
) -> list[AdvisoryPick]:
    """End-to-end: hard filter → soft score → LLM pick."""
    survivors = hard_filter(
        pois,
        advised_poi_place_ids=advised_poi_place_ids,
        reddit_insights=reddit_insights,
        weather=weather,
    )
    if not survivors:
        return []

    ranked = soft_score(
        survivors,
        user_metadata=user_metadata,
        trip_metadata=trip_metadata,
        recent_categories=recent_categories,
        now=now,
    )
    return await llm_pick(
        ranked,
        locality=locality,
        context={
            "trip_metadata": trip_metadata,
            "user_metadata": user_metadata,
            "weather": weather,
            "recent_categories": recent_categories,
        },
        reviews_by_poi=reviews_by_poi,
    )
