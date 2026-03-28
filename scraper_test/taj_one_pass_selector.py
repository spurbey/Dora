"""
One-pass Taj Mahal nearby entity selector using Google Maps pages.

Goal:
- Pull a small nearby candidate set
- Extract up to 5-7 review snippets per entity
- Rank for "gen-z + less crowded"

Usage (PowerShell):
  $env:OPENROUTER_API_KEY="..."
  $env:LLM_API_KEY=$env:OPENROUTER_API_KEY
  python scraper_test/taj_one_pass_selector.py
"""

import asyncio
import copy
import json
import random
import os
import re
from typing import Any
from urllib.parse import quote_plus

try:
    from .config import Config
    from .crawl4ai_wrapper import Crawl4AIWrapper
except ImportError:
    from config import Config
    from crawl4ai_wrapper import Crawl4AIWrapper


TAJ_NEARBY_CANDIDATES = [
    "Mehtab Bagh Agra",
    "Taj Nature Walk Agra",
    "Itmad-ud-Daulah's Tomb Agra",
    "Agra Fort Agra",
    "Sadar Bazaar Agra",
    "Jama Masjid Agra",
    "Kinari Bazaar Agra",
]

LOW_CROWD_TERMS = [
    "less crowded", "not crowded", "quiet", "peaceful", "calm", "serene",
    "hidden gem", "uncrowded", "offbeat",
]
HIGH_CROWD_TERMS = [
    "very crowded", "crowded", "packed", "long queue", "rush", "too many people",
    "overcrowded", "jam-packed",
]
GENZ_TERMS = [
    "vibe", "aesthetic", "instagram", "reel", "photo", "photogenic",
    "chill", "hangout", "trendy", "young crowd",
]
IGNORE_SNIPPET_TERMS = [
    "lowest rates guaranteed",
    "booking.com",
    "no reservation costs",
    "top 10 hotels",
    "book at over",
]
REVIEW_CUE_TERMS = [
    "review",
    "recommended",
    "peaceful",
    "quiet",
    "crowded",
    "worth",
    "beautiful",
    "serene",
    "experience",
    "walk",
]


def _to_place_url(candidate: str) -> str:
    return f"https://www.google.com/maps/search/?api=1&query={quote_plus(candidate)}"


def _safe_review_texts(record: dict[str, Any]) -> list[str]:
    reviews = record.get("reviews") or []
    out: list[str] = []
    for item in reviews:
        if isinstance(item, dict):
            text = (item.get("text") or "").strip()
        else:
            text = str(item).strip()
        if text:
            out.append(text)
    return out


def _filter_review_snippets(snippets: list[str], limit: int) -> list[str]:
    out: list[str] = []
    seen: set[str] = set()
    for text in snippets:
        cleaned = re.sub(r"\s+", " ", text).strip()
        lower = cleaned.lower()
        if len(cleaned) < 40:
            continue
        if any(term in lower for term in IGNORE_SNIPPET_TERMS):
            continue
        if not any(term in lower for term in REVIEW_CUE_TERMS):
            continue
        if lower in seen:
            continue
        seen.add(lower)
        out.append(cleaned)
        if len(out) >= limit:
            break
    return out


def _score_candidate(record: dict[str, Any]) -> tuple[float, dict[str, int]]:
    reviews = _safe_review_texts(record)
    joined = " ".join(reviews).lower()
    signals = {
        "low_crowd_hits": sum(1 for t in LOW_CROWD_TERMS if t in joined),
        "high_crowd_hits": sum(1 for t in HIGH_CROWD_TERMS if t in joined),
        "genz_hits": sum(1 for t in GENZ_TERMS if t in joined),
    }

    rating = float(record.get("rating") or 0.0)
    review_density_bonus = min(len(reviews), 7) * 0.25

    score = 0.0
    score += signals["low_crowd_hits"] * 2.0
    score -= signals["high_crowd_hits"] * 2.0
    score += signals["genz_hits"] * 1.2
    score += rating * 0.35
    score += review_density_bonus

    if not reviews:
        score -= 2.0

    return round(score, 3), signals


def _wrapper_for_proxy(base_config: Config, proxy_url: str | None) -> Crawl4AIWrapper:
    cfg = copy.deepcopy(base_config)
    if proxy_url:
        cfg.PROXY_ENABLED = True
        cfg.PROXY_LIST = [proxy_url]
    else:
        cfg.PROXY_ENABLED = False
        cfg.PROXY_LIST = []
    return Crawl4AIWrapper(cfg)


async def run_one_pass():
    config = Config()
    use_llm = bool(config.LLM_API_KEY)
    review_limit = int(os.getenv("REVIEW_LIMIT", "7"))
    review_limit = max(1, min(review_limit, 12))
    max_candidates = int(os.getenv("MAX_CANDIDATES", "5"))
    max_candidates = max(1, min(max_candidates, len(TAJ_NEARBY_CANDIDATES)))
    delay_min = float(os.getenv("REQUEST_DELAY_MIN_SEC", "2.0"))
    delay_max = float(os.getenv("REQUEST_DELAY_MAX_SEC", "4.0"))

    candidates = TAJ_NEARBY_CANDIDATES[:max_candidates]
    proxies = config.PROXY_LIST if config.PROXY_ENABLED and config.PROXY_LIST else []
    wrappers: dict[str, Crawl4AIWrapper] = {}
    wrappers["__default__"] = _wrapper_for_proxy(config, None)

    print("=== One-pass selector (Taj nearby) ===")
    print(f"LLM enabled: {use_llm}")
    print(f"Proxy rotation enabled: {bool(proxies)} (pool={len(proxies)})")
    print(f"Candidates: {len(candidates)} | Review limit/entity: {review_limit}")
    print()

    results: list[dict[str, Any]] = []
    for idx, candidate in enumerate(candidates):
        proxy = proxies[idx % len(proxies)] if proxies else None
        key = proxy or "__default__"
        if key not in wrappers:
            wrappers[key] = _wrapper_for_proxy(config, proxy)
        wrapper = wrappers[key]

        place_url = _to_place_url(candidate)
        print(f"[{idx + 1}/{len(candidates)}] {candidate}")
        if proxy:
            print(f"  proxy: {proxy}")

        try:
            record = await wrapper.scrape_google_maps_place_with_reviews(
                place_url=place_url,
                review_limit=review_limit,
                use_llm=use_llm,
            )
            reviews_used = _safe_review_texts(record)[:review_limit]
            review_source = "google_maps_dynamic"
            if len(reviews_used) < review_limit:
                try:
                    dyn_rows = await wrapper.scrape_google_maps_dynamic_reviews(
                        place_url=place_url,
                        review_limit=review_limit,
                    )
                    dyn_texts = [r.get("text", "").strip() for r in dyn_rows if r.get("text")]
                    dyn_texts = _filter_review_snippets(dyn_texts, review_limit)
                    if dyn_texts:
                        reviews_used = dyn_texts
                except Exception as dyn_exc:
                    print(f"  dynamic review extraction failed: {dyn_exc}")

            scoring_record = dict(record)
            scoring_record["reviews"] = reviews_used
            score, signals = _score_candidate(scoring_record)
            result = {
                "candidate": candidate,
                "source_url": place_url,
                "fit_score": score,
                "signals": signals,
                "place_name": record.get("place_name"),
                "rating": record.get("rating"),
                "review_count": record.get("review_count"),
                "reviews_used": reviews_used,
                "review_source": review_source,
                "is_complete": record.get("is_complete"),
                "completeness_score": record.get("completeness_score"),
            }
            results.append(result)
            print(
                f"  score={score} | complete={result['is_complete']} | "
                f"reviews={len(result['reviews_used'])}"
            )
        except Exception as exc:
            print(f"  ERROR: {exc}")

        await asyncio.sleep(random.uniform(delay_min, delay_max))

    ranked = sorted(results, key=lambda x: x["fit_score"], reverse=True)
    print("\n=== Ranked (best fit first) ===")
    for i, row in enumerate(ranked, 1):
        print(
            f"{i}. {row['candidate']} | score={row['fit_score']} | "
            f"reviews={len(row['reviews_used'])} | rating={row['rating']}"
        )

    if ranked:
        print("\n=== Top recommendation ===")
        print(json.dumps(ranked[0], indent=2, ensure_ascii=False))
    else:
        print("\nNo candidates produced usable output.")


if __name__ == "__main__":
    asyncio.run(run_one_pass())
