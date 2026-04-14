"""
Reddit scraper for advisory pipeline.

Extracted from scraper_reddit/smart_reddit_scraper.py.
Uses Crawl4AI deep crawl + LLM extraction via OpenRouter.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Literal, Optional
from urllib.parse import quote_plus

from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

STOPWORDS = {
    "a", "an", "the", "is", "are", "was", "were", "for", "to", "of", "in",
    "on", "with", "about", "and", "or", "but", "how", "what", "when", "where",
    "why", "which", "who", "i", "me", "my", "mine", "we", "our", "you",
    "your", "it", "its", "this", "that", "these", "those", "be", "been",
    "being", "have", "has", "had", "do", "does", "did", "not", "no",
    "any", "some", "will", "would", "should", "could", "can", "may",
    "as", "at", "by", "from", "up", "down",
}


class TravelInsight(BaseModel):
    """Schema for LLM extraction — matches advisory pipeline categories."""
    category: Literal[
        "safety_warning", "scam_alert", "food_tip", "photo_spot",
        "transport_tip", "accommodation", "cultural_etiquette",
        "must_do", "avoid", "general_tip",
    ] = Field(description="Type of insight")
    place_name: Optional[str] = Field(
        default=None,
        description="Specific place/business/area; null if tip applies to whole city",
    )
    insight: str = Field(description="Actionable 1-3 sentence takeaway")
    context_signal: Optional[str] = Field(
        default=None,
        description="Strength signal: 'top comment', 'mentioned by 3 users', etc.",
    )
    best_for: Optional[str] = Field(
        default=None,
        description="Who this is most relevant for; null if universal",
    )


def _json_schema(cls) -> dict:
    if hasattr(cls, "model_json_schema"):
        return cls.model_json_schema()
    return cls.schema()


def extract_keywords(question: str, extra: list[str] | None = None) -> list[str]:
    words = re.findall(r"[A-Za-z][A-Za-z\-]{2,}", question.lower())
    kw = [w for w in words if w not in STOPWORDS]
    seen: set[str] = set()
    out: list[str] = []
    for w in kw + [e.lower() for e in (extra or [])]:
        if w not in seen:
            seen.add(w)
            out.append(w)
    return out


def derive_search_query(keywords: list[str], max_terms: int = 4) -> str:
    return " ".join(keywords[:max_terms])


def seed_urls(subs: list[str], search_query: str, time_filter: str = "year") -> list[str]:
    q = quote_plus(search_query)
    urls = []
    for sub in subs:
        sub = sub.strip().lstrip("r/").lstrip("/")
        urls.append(
            f"https://old.reddit.com/r/{sub}/search?"
            f"q={q}&restrict_sr=on&sort=relevance&t={time_filter}"
        )
    return urls


async def scrape_reddit(
    question: str,
    subs: list[str],
    extra_keywords: list[str] | None = None,
    max_pages: int = 8,
    max_depth: int = 2,
    time_filter: str = "year",
    openrouter_api_key: str = "",
    openrouter_model: str = "openrouter/openai/gpt-oss-120b:free",
) -> dict:
    """
    Deep-crawl Reddit for travel insights using Crawl4AI + LLM extraction.

    Returns dict with keys: question, keywords, pages_visited, insights (list[dict]).
    """
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

    if not openrouter_api_key:
        raise RuntimeError("OPENROUTER_API_KEY required for Reddit scraping")

    keywords = extract_keywords(question, extra_keywords)
    search_query = derive_search_query(keywords)
    seeds = seed_urls(subs, search_query, time_filter)

    logger.info(
        "[REDDIT_SCRAPE] question=%r keywords=%s subs=%s seeds=%d max_pages=%d",
        question, keywords, subs, len(seeds), max_pages,
    )

    scorer = KeywordRelevanceScorer(keywords=keywords, weight=1.0)

    filter_chain = FilterChain([
        DomainFilter(allowed_domains=["old.reddit.com"]),
        URLPatternFilter(patterns=["*/comments/*"], use_glob=True),
    ])

    deep_strategy = BestFirstCrawlingStrategy(
        max_depth=max_depth,
        max_pages=max_pages,
        include_external=False,
        url_scorer=scorer,
        filter_chain=filter_chain,
    )

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
        provider=openrouter_model,
        api_token=openrouter_api_key,
        base_url="https://openrouter.ai/api/v1",
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
        verbose=False,
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

    total_insights: list[dict] = []
    pages_visited = 0

    async with AsyncWebCrawler(config=browser_cfg) as crawler:
        for seed in seeds:
            logger.info("[REDDIT_SCRAPE] crawling seed: %s", seed[:100])
            results = await crawler.arun(url=seed, config=run_cfg)

            if hasattr(results, "__iter__") and not hasattr(results, "url"):
                page_results = list(results)
            else:
                page_results = [results]

            for r in page_results:
                pages_visited += 1
                if not r.success:
                    continue

                raw = r.extracted_content or "[]"
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
                    for item in clean:
                        item["_source_url"] = r.url
                    total_insights.extend(clean)
                    if clean:
                        logger.info(
                            "[REDDIT_SCRAPE] %d insight(s) from %s",
                            len(clean), r.url[:80],
                        )
                except json.JSONDecodeError:
                    logger.warning("[REDDIT_SCRAPE] JSON parse failed for %s", r.url[:80])

    logger.info(
        "[REDDIT_SCRAPE] done. pages=%d insights=%d",
        pages_visited, len(total_insights),
    )

    return {
        "question": question,
        "keywords": keywords,
        "pages_visited": pages_visited,
        "insights": total_insights,
    }
