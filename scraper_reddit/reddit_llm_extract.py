"""
Reddit LLM Extraction Test (Crawl4AI + OpenRouter)

Goal: Given an old.reddit.com URL (post or search), scrape it via Crawl4AI
and use an LLM (free open-source via OpenRouter) to extract structured
travel insights via natural-language instruction.

This is the first proof that:
  - Crawl4AI can fetch old.reddit.com without anti-bot friction
  - LLM extraction turns unstructured Reddit text into typed JSON facts
  - OpenRouter's free tier can do this reliably

Run:
  python reddit_llm_extract.py
  python reddit_llm_extract.py --url "https://old.reddit.com/r/IndiaTravel/comments/XXX"
  python reddit_llm_extract.py --query "Mathura tips" --subreddit "IndiaTravel"

Requires env: OPENROUTER_API_KEY (read from env or ../.env / .env)
"""

import argparse
import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Literal, Optional

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Load .env from a few likely locations
try:
    from dotenv import load_dotenv
    for p in [
        Path(__file__).parent / ".env",
        Path(__file__).parent.parent / ".env",
        Path(__file__).parent.parent / "scraper_test" / ".env",
    ]:
        if p.exists():
            load_dotenv(p)
            print(f"[env] loaded {p}")
            break
except ImportError:
    pass

from pydantic import BaseModel, Field


def _json_schema(model_cls) -> dict:
    """Pydantic v1/v2 compatibility helper."""
    if hasattr(model_cls, "model_json_schema"):
        return model_cls.model_json_schema()
    return model_cls.schema()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
# Default to a free, strong, open-source model known for good JSON following.
# Override via env: LLM_PROVIDER="openrouter/<model>"
LLM_PROVIDER = os.getenv(
    "LLM_PROVIDER",
    "openrouter/meta-llama/llama-3.3-70b-instruct:free",
)
LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://openrouter.ai/api/v1")

DEBUG_DIR = Path(__file__).parent / "debug"
DEBUG_DIR.mkdir(exist_ok=True)


# ---------- Pydantic schema for structured extraction ----------

class TravelInsight(BaseModel):
    """A single actionable travel insight extracted from Reddit content."""

    category: Literal[
        "safety_warning",
        "food_tip",
        "photo_spot",
        "transport_tip",
        "accommodation",
        "cultural_etiquette",
        "scam_alert",
        "must_do",
        "avoid",
        "general_tip",
    ] = Field(description="Category of the insight")

    place_name: Optional[str] = Field(
        default=None,
        description=(
            "Specific place/business mentioned (e.g. 'Brijwasi Restaurant'). "
            "Null if the tip is about the city/area in general."
        ),
    )

    insight: str = Field(
        description="The actual tip/warning in 1-3 sentences. Be specific and actionable."
    )

    context_signal: Optional[str] = Field(
        default=None,
        description=(
            "Signal of strength (e.g. 'mentioned 3 times', 'top comment 200 upvotes', "
            "'contradicted by another user'). Null if no signal available."
        ),
    )

    best_for: Optional[str] = Field(
        default=None,
        description="Who this applies to most (e.g. 'solo female travelers', 'families', 'photographers'). Null if universal.",
    )


# ---------- URL helpers ----------

def build_search_url(query: str, subreddit: str, time_filter: str = "year") -> str:
    """Build an old.reddit.com search URL."""
    from urllib.parse import quote_plus
    q = quote_plus(query)
    # restrict_sr=on → search within subreddit only
    return (
        f"https://old.reddit.com/r/{subreddit}/search?"
        f"q={q}&restrict_sr=on&sort=relevance&t={time_filter}"
    )


# ---------- Main extraction ----------

async def run_extraction(
    url: str,
    focus_topic: str,
    user_context: str,
) -> tuple[List[dict], str]:
    """
    Fetch URL via Crawl4AI, run LLM extraction with natural-language instruction,
    return (insights, raw_markdown).
    """
    from crawl4ai import (
        AsyncWebCrawler,
        BrowserConfig,
        CacheMode,
        CrawlerRunConfig,
        LLMConfig,
    )
    from crawl4ai.extraction_strategy import LLMExtractionStrategy

    if not OPENROUTER_API_KEY:
        raise RuntimeError(
            "OPENROUTER_API_KEY not set. Export it or add to .env."
        )

    print(f"[*] Provider : {LLM_PROVIDER}")
    print(f"[*] URL      : {url}")
    print(f"[*] Topic    : {focus_topic}")

    llm_config = LLMConfig(
        provider=LLM_PROVIDER,
        api_token=OPENROUTER_API_KEY,
        base_url=LLM_BASE_URL,
    )

    instruction = f"""
You are extracting travel insights from a Reddit page about "{focus_topic}".
The reader is: {user_context}

For EVERY distinct actionable piece of advice you find in the page
(across the post body and the comments), produce one TravelInsight object.

Guidelines:
- Focus on SPECIFIC, ACTIONABLE tips — not generic statements like "it's nice"
- Pull out warnings (scams, unsafe areas, overcharging) as safety_warning or scam_alert
- Name specific places/restaurants/areas whenever mentioned
- If multiple users corroborate a tip, note that in context_signal
- If a tip is contested/contradicted, note that in context_signal
- Skip off-topic comments, jokes, personal anecdotes unrelated to travel
- If the same advice appears multiple times, produce ONE insight and note the corroboration
- Prefer insights grounded in the comments (community consensus) over the post alone

Return a JSON array of TravelInsight objects, following the schema strictly.
""".strip()

    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config,
        schema=_json_schema(TravelInsight),
        extraction_type="schema",
        instruction=instruction,
        force_json_response=True,
        apply_chunking=True,
        chunk_token_threshold=12000,
        overlap_rate=0.05,
        input_format="markdown",
        verbose=True,
    )

    browser_config = BrowserConfig(
        headless=True,
        verbose=False,
        # old.reddit.com does not anti-bot, so default config is fine
    )

    run_config = CrawlerRunConfig(
        extraction_strategy=extraction_strategy,
        cache_mode=CacheMode.BYPASS,
        word_count_threshold=5,
        verbose=False,
    )

    async with AsyncWebCrawler(config=browser_config) as crawler:
        result = await crawler.arun(url=url, config=run_config)

        if not result.success:
            raise RuntimeError(f"Crawl failed: {result.error_message}")

        raw_md = result.markdown or ""
        extracted_raw = result.extracted_content or "[]"

        try:
            parsed = json.loads(extracted_raw)
            if isinstance(parsed, dict):
                parsed = [parsed]
        except json.JSONDecodeError as e:
            print(f"[!] JSON parse failed: {e}")
            print(f"[!] Raw first 500 chars: {extracted_raw[:500]}")
            parsed = []

        return parsed, raw_md


# ---------- CLI ----------

def parse_args():
    p = argparse.ArgumentParser(description="Reddit LLM extraction test")
    p.add_argument(
        "--url",
        help="Full old.reddit.com URL (post or search). If omitted, --query + --subreddit used.",
    )
    p.add_argument("--query", default="Mathura travel tips", help="Search query")
    p.add_argument("--subreddit", default="IndiaTravel", help="Subreddit name (no r/)")
    p.add_argument(
        "--focus",
        default="Mathura (Uttar Pradesh, India) for a short visit",
        help="Topic focus passed to LLM",
    )
    p.add_argument(
        "--user",
        default="a couple on a 3-day Delhi-Agra road trip, interested in food, photography, and culture",
        help="User context passed to LLM",
    )
    p.add_argument(
        "--time",
        default="year",
        choices=["all", "year", "month", "week", "day"],
        help="Reddit time filter for search",
    )
    return p.parse_args()


async def main():
    args = parse_args()

    url = args.url or build_search_url(args.query, args.subreddit, args.time)

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = DEBUG_DIR / ts
    out_dir.mkdir(exist_ok=True)

    print("=" * 70)
    print("Reddit LLM Extraction Test")
    print("=" * 70)

    insights, raw_md = await run_extraction(
        url=url,
        focus_topic=args.focus,
        user_context=args.user,
    )

    # Save artifacts
    (out_dir / "raw.md").write_text(raw_md, encoding="utf-8")
    (out_dir / "insights.json").write_text(
        json.dumps(insights, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    (out_dir / "meta.json").write_text(
        json.dumps(
            {
                "url": url,
                "focus": args.focus,
                "user": args.user,
                "provider": LLM_PROVIDER,
                "count": len(insights),
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    # Summary
    print()
    print("=" * 70)
    print(f"RESULT: {len(insights)} insight(s) extracted")
    print(f"Saved:  {out_dir}")
    print("=" * 70)

    for i, item in enumerate(insights, 1):
        cat = item.get("category", "?")
        place = item.get("place_name") or "-"
        insight = (item.get("insight") or "")[:140]
        signal = item.get("context_signal") or "-"
        best_for = item.get("best_for") or "-"
        print(f"\n[{i}] {cat}  |  place: {place}")
        print(f"    insight : {insight}")
        print(f"    signal  : {signal}")
        print(f"    best_for: {best_for}")


if __name__ == "__main__":
    asyncio.run(main())
