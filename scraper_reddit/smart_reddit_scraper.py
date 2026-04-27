"""
Smart Reddit Scraper — goal-directed deep crawl + LLM extraction.

Given a natural-language user question (e.g. "how is Mathura for solo female
travelers?") and a small list of seed subreddits, this will:

  1. Build seed search URLs on old.reddit.com
  2. Use Crawl4AI's BestFirstCrawlingStrategy to follow links scored by
     keywords derived from the question — surfacing the most relevant
     posts without manually listing URLs
  3. Restrict the crawler to stay inside old.reddit.com and only post
     pages (no user profiles, wikis, etc.)
  4. Run LLM extraction against EACH fetched page with the user's
     question as the guiding instruction
  5. Aggregate structured insights across all visited pages

Run:
  python smart_reddit_scraper.py --q "how is Mathura for solo female travelers" \
      --subs IndiaTravel,solotravel,TwoXIndia \
      --max-pages 15 --max-depth 2
"""

import argparse
import asyncio
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Literal, Optional
from urllib.parse import quote_plus

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

try:
    from dotenv import load_dotenv
    for p in [
        Path(__file__).parent / ".env",
        Path(__file__).parent.parent / ".env",
    ]:
        if p.exists():
            load_dotenv(p)
            break
except ImportError:
    pass

from pydantic import BaseModel, Field

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "openrouter/openai/gpt-oss-120b:free")
LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://openrouter.ai/api/v1")

DEBUG_DIR = Path(__file__).parent / "debug"
DEBUG_DIR.mkdir(exist_ok=True)

STOPWORDS = {
    "a", "an", "the", "is", "are", "was", "were", "for", "to", "of", "in",
    "on", "with", "about", "and", "or", "but", "how", "what", "when", "where",
    "why", "which", "who", "i", "me", "my", "mine", "we", "our", "you",
    "your", "it", "its", "this", "that", "these", "those", "be", "been",
    "being", "have", "has", "had", "do", "does", "did", "not", "no",
    "any", "some", "will", "would", "should", "could", "can", "may",
    "as", "at", "by", "from", "up", "down",
}


# ---------- Pydantic schema ----------

class TravelInsight(BaseModel):
    category: Literal[
        "safety_warning",
        "scam_alert",
        "food_tip",
        "photo_spot",
        "transport_tip",
        "accommodation",
        "cultural_etiquette",
        "must_do",
        "avoid",
        "general_tip",
    ] = Field(description="Type of insight")
    place_name: Optional[str] = Field(
        default=None,
        description="Specific place/business/area mentioned; null if the tip applies to the whole city",
    )
    insight: str = Field(description="Actionable 1-3 sentence takeaway")
    context_signal: Optional[str] = Field(
        default=None,
        description="Signal of strength: e.g. 'top comment', 'mentioned by 3 users', 'contested by replies'",
    )
    best_for: Optional[str] = Field(
        default=None,
        description="Who this is most relevant for; null if universal",
    )


def _json_schema(cls) -> dict:
    if hasattr(cls, "model_json_schema"):
        return cls.model_json_schema()
    return cls.schema()


# ---------- Helpers ----------

def extract_keywords(question: str, extra: list[str] | None = None) -> list[str]:
    """Pull content words out of a natural-language question for URL scoring."""
    words = re.findall(r"[A-Za-z][A-Za-z\-]{2,}", question.lower())
    kw = [w for w in words if w not in STOPWORDS]
    # De-dupe preserving order
    seen = set()
    out = []
    for w in kw + [e.lower() for e in (extra or [])]:
        if w not in seen:
            seen.add(w)
            out.append(w)
    return out


def seed_urls(
    subs: list[str], search_query: str, time_filter: str = "year"
) -> list[str]:
    """Build old.reddit.com in-subreddit search URLs for each seed sub."""
    q = quote_plus(search_query)
    urls = []
    for sub in subs:
        sub = sub.strip().lstrip("r/").lstrip("/")
        urls.append(
            f"https://old.reddit.com/r/{sub}/search?"
            f"q={q}&restrict_sr=on&sort=relevance&t={time_filter}"
        )
    return urls


def derive_search_query(keywords: list[str], max_terms: int = 4) -> str:
    """Reddit search works best with a few strong keywords, not a full sentence."""
    return " ".join(keywords[:max_terms])


# ---------- Main ----------

async def run(
    question: str,
    subs: list[str],
    extra_keywords: list[str],
    max_pages: int,
    max_depth: int,
    time_filter: str,
) -> dict:
    from crawl4ai import (
        AsyncWebCrawler,
        BrowserConfig,
        CacheMode,
        CrawlerRunConfig,
        LLMConfig,
    )
    from crawl4ai.extraction_strategy import LLMExtractionStrategy
    from crawl4ai.deep_crawling import BestFirstCrawlingStrategy
    from crawl4ai.deep_crawling.scorers import KeywordRelevanceScorer
    from crawl4ai.deep_crawling.filters import (
        DomainFilter,
        URLPatternFilter,
        FilterChain,
    )

    if not OPENROUTER_API_KEY:
        raise RuntimeError("OPENROUTER_API_KEY missing from env/.env")

    keywords = extract_keywords(question, extra_keywords)
    search_query = derive_search_query(keywords)
    seeds = seed_urls(subs, search_query, time_filter)

    print(f"[*] Provider : {LLM_PROVIDER}")
    print(f"[*] Question : {question}")
    print(f"[*] Keywords : {keywords}")
    print(f"[*] Search q : {search_query}")
    print(f"[*] Subs     : {subs}")
    print(f"[*] Seeds    : {len(seeds)} URL(s)")
    for s in seeds:
        print(f"      - {s}")
    print(f"[*] Budget   : max_pages={max_pages} max_depth={max_depth}")

    # --- Scorer: rank discovered URLs by keyword match in URL/anchor ---
    scorer = KeywordRelevanceScorer(keywords=keywords, weight=1.0)

    # --- Filters: stay on old.reddit.com, only follow actual post pages ---
    # URLPatternFilter with use_glob=True matches only post/comment URLs.
    # This blocks sidebar navigation (r/AskReddit, r/popular, etc.).
    filter_chain = FilterChain([
        DomainFilter(allowed_domains=["old.reddit.com"]),
        URLPatternFilter(patterns=["*/comments/*"], use_glob=True),
    ])

    # --- Deep crawl strategy: BestFirst = visit highest-scoring link first ---
    deep_strategy = BestFirstCrawlingStrategy(
        max_depth=max_depth,
        max_pages=max_pages,
        include_external=False,
        url_scorer=scorer,
        filter_chain=filter_chain,
    )

    # --- LLM extraction, applied to every fetched page ---
    instruction = f"""
You are reading a Reddit page (post + comments, OR a search result listing).
The end user's question is:

    "{question}"

For EVERY distinct, actionable piece of advice you find on this page that
helps answer the question, produce one TravelInsight JSON object.

Rules:
- Only include specific, actionable tips — not vague vibes
- Include warnings / scams as safety_warning or scam_alert
- When a specific place, restaurant, or area is named, put it in place_name
- If multiple commenters agree, note in context_signal (e.g. "3 users agreed")
- If a tip is contested, note the disagreement in context_signal
- Skip jokes, memes, and off-topic tangents
- If the page has NO useful content for the question, return an empty array

Return ONLY a JSON array of TravelInsight objects matching the schema.
""".strip()

    llm_cfg = LLMConfig(
        provider=LLM_PROVIDER,
        api_token=OPENROUTER_API_KEY,
        base_url=LLM_BASE_URL,
    )

    extractor = LLMExtractionStrategy(
        llm_config=llm_cfg,
        schema=_json_schema(TravelInsight),
        extraction_type="schema",
        instruction=instruction,
        force_json_response=True,
        apply_chunking=True,
        chunk_token_threshold=10000,
        overlap_rate=0.05,
        input_format="markdown",
        verbose=True,
    )

    browser_cfg = BrowserConfig(headless=True, verbose=False)
    run_cfg = CrawlerRunConfig(
        extraction_strategy=extractor,
        deep_crawl_strategy=deep_strategy,
        cache_mode=CacheMode.BYPASS,
        word_count_threshold=20,
        stream=False,
        verbose=False,
    )

    all_pages = []
    total_insights = []

    async with AsyncWebCrawler(config=browser_cfg) as crawler:
        # arun on a seed triggers the deep crawl using the strategy in config
        for seed in seeds:
            print(f"\n[>] Deep crawl from seed: {seed}")
            results = await crawler.arun(url=seed, config=run_cfg)

            # Deep crawl returns a list of CrawlResult (one per discovered page)
            if hasattr(results, "__iter__") and not hasattr(results, "url"):
                page_results = list(results)
            else:
                page_results = [results]

            for r in page_results:
                page_info = {
                    "url": r.url,
                    "success": r.success,
                    "depth": (r.metadata or {}).get("depth") if hasattr(r, "metadata") else None,
                    "score": (r.metadata or {}).get("score") if hasattr(r, "metadata") else None,
                    "insights": [],
                    "error": None,
                }

                if not r.success:
                    page_info["error"] = getattr(r, "error_message", "unknown")
                    all_pages.append(page_info)
                    continue

                raw = r.extracted_content or "[]"
                page_info["raw_extracted"] = raw[:4000]  # keep for debug
                try:
                    parsed = json.loads(raw)
                    if isinstance(parsed, dict):
                        parsed = [parsed]
                    clean = [
                        p for p in parsed
                        if isinstance(p, dict)
                        and not p.get("error")
                        and (p.get("insight") or p.get("category"))
                    ]
                    page_info["insights"] = clean
                    page_info["extracted_count"] = len(parsed) if isinstance(parsed, list) else 1
                    total_insights.extend(
                        {**item, "_source_url": r.url} for item in clean
                    )
                except json.JSONDecodeError:
                    page_info["error"] = "json parse failed"

                # Save raw markdown of first few pages for debug
                page_info["markdown_chars"] = len(r.markdown or "")

                all_pages.append(page_info)
                print(
                    f"    [<] {len(page_info['insights'])} insight(s) from "
                    f"{r.url[:90]}"
                )

    return {
        "question": question,
        "keywords": keywords,
        "pages_visited": len(all_pages),
        "pages": all_pages,
        "insights": total_insights,
    }


# ---------- CLI ----------

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--q", "--question", dest="question", required=True)
    p.add_argument(
        "--subs",
        default="IndiaTravel,solotravel,travel",
        help="Comma-separated subreddit names (no r/)",
    )
    p.add_argument(
        "--keywords",
        default="",
        help="Extra keywords for URL scoring, comma-separated (optional)",
    )
    p.add_argument("--max-pages", type=int, default=12)
    p.add_argument("--max-depth", type=int, default=2)
    p.add_argument(
        "--time",
        default="year",
        choices=["all", "year", "month", "week", "day"],
    )
    return p.parse_args()


async def main():
    args = parse_args()
    subs = [s.strip() for s in args.subs.split(",") if s.strip()]
    extra = [k.strip() for k in args.keywords.split(",") if k.strip()]

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = DEBUG_DIR / f"smart_{ts}"
    out_dir.mkdir(exist_ok=True)

    result = await run(
        question=args.question,
        subs=subs,
        extra_keywords=extra,
        max_pages=args.max_pages,
        max_depth=args.max_depth,
        time_filter=args.time,
    )

    (out_dir / "result.json").write_text(
        json.dumps(result, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print()
    print("=" * 70)
    print(f"Pages visited : {result['pages_visited']}")
    print(f"Insights      : {len(result['insights'])}")
    print(f"Saved         : {out_dir / 'result.json'}")
    print("=" * 70)

    for i, it in enumerate(result["insights"][:20], 1):
        cat = it.get("category", "?")
        place = it.get("place_name") or "-"
        text = (it.get("insight") or "")[:150]
        sig = it.get("context_signal") or "-"
        print(f"\n[{i}] {cat}  |  {place}")
        print(f"    {text}")
        print(f"    signal: {sig}")


if __name__ == "__main__":
    asyncio.run(main())
