"""
Crawl4AI Wrapper - Handles fetching and extraction.

This wrapper provides:
- Proxy rotation
- Session management
- Stealth mode
- LLM extraction
- CSS/XPath extraction
"""

import json
import asyncio
from typing import Optional, Any
import os
import re
from datetime import datetime, timezone
from urllib.parse import parse_qs, urlparse, unquote, quote_plus
from html import unescape

try:
    from .config import Config
except ImportError:
    from config import Config


class Crawl4AIWrapper:
    """
    Wrapper around Crawl4AI for robust web scraping.
    
    Features:
    - Proxy rotation (if configured)
    - Session management
    - Stealth mode (bypass bot detection)
    - LLM extraction (for complex pages)
    - CSS/XPath extraction (for simple pages)
    """
    
    def __init__(self, config: Config = None):
        self.config = config or Config()
        os.environ.setdefault(
            "CRAWL4_AI_BASE_DIRECTORY",
            self.config.CRAWL4AI_BASE_DIRECTORY,
        )

    def _build_browser_config(self):
        from crawl4ai import BrowserConfig

        proxy_url = (
            self.config.PROXY_LIST[0]
            if self.config.PROXY_ENABLED and self.config.PROXY_LIST
            else None
        )
        return BrowserConfig(
            headless=self.config.CRAWL4AI_HEADLESS,
            proxy=proxy_url,
            verbose=self.config.CRAWL4AI_VERBOSE,
        )
    
    async def crawl_with_llm_extraction(
        self,
        url: str,
        schema: dict,
        instruction: str,
        provider: Optional[str] = None,
        wait_for: Optional[str] = None
    ) -> list[dict]:
        """
        Crawl URL and extract data using LLM.
        
        Args:
            url: Target URL
            schema: JSON schema for extraction
            instruction: Instructions for LLM
            provider: LLM provider (e.g., "openai/gpt-4o-mini")
            wait_for: CSS selector to wait for
            
        Returns:
            List of extracted data as dicts
        """
        try:
            from crawl4ai import (
                AsyncWebCrawler,
                CrawlerRunConfig,
                CacheMode,
                LLMConfig,
            )
            from crawl4ai.extraction_strategy import LLMExtractionStrategy
            
            browser_config = self._build_browser_config()

            model_provider = provider or self.config.LLM_PROVIDER
            if not self.config.LLM_API_KEY:
                raise ValueError(
                    "Missing LLM_API_KEY/OPENROUTER_API_KEY/OPENAI_API_KEY for LLM extraction"
                )

            llm_config = LLMConfig(
                provider=model_provider,
                api_token=self.config.LLM_API_KEY,
                base_url=self.config.LLM_BASE_URL,
            )
            
            extraction_strategy = LLMExtractionStrategy(
                llm_config=llm_config,
                schema=schema,
                instruction=instruction,
                force_json_response=True,
            )
            
            run_config = CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                cache_mode=CacheMode.BYPASS,
                wait_for=wait_for,
                verbose=self.config.CRAWL4AI_VERBOSE,
            )
            
            async with AsyncWebCrawler(config=browser_config) as crawler:
                result = await crawler.arun(
                    url=url,
                    config=run_config,
                )
                
                if result and result.extracted_content:
                    parsed = json.loads(result.extracted_content)
                    if isinstance(parsed, dict):
                        return [parsed]
                    if isinstance(parsed, list):
                        return parsed
                    return []
                
                return []
                
        except ImportError:
            print("ERROR: crawl4ai not installed. Run: pip install crawl4ai")
            return []
        except Exception as e:
            print(f"ERROR crawling {url}: {e}")
            return []
    
    async def crawl_with_css_extraction(
        self,
        url: str,
        css_schema: dict,
        wait_for: Optional[str] = None,
        js_code: Optional[list[str] | str] = None,
        delay_before_return_html: Optional[float] = None,
        page_timeout: Optional[int] = None,
    ) -> list[dict]:
        """
        Crawl URL and extract data using CSS selectors (no LLM needed).
        
        Faster and cheaper than LLM extraction.
        
        Args:
            url: Target URL
            css_schema: CSS selector schema
            wait_for: CSS selector to wait for
            
        Returns:
            List of extracted data as dicts
        """
        try:
            from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode
            from crawl4ai.extraction_strategy import JsonCssExtractionStrategy
            
            browser_config = self._build_browser_config()
            
            extraction_strategy = JsonCssExtractionStrategy(
                schema=css_schema
            )
            
            run_config = CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                cache_mode=CacheMode.BYPASS,
                wait_for=wait_for,
                js_code=js_code,
                delay_before_return_html=delay_before_return_html,
                page_timeout=page_timeout or 120000,
                verbose=self.config.CRAWL4AI_VERBOSE,
            )
            
            async with AsyncWebCrawler(config=browser_config) as crawler:
                result = await crawler.arun(
                    url=url,
                    config=run_config,
                )
                
                if result and result.extracted_content:
                    parsed = json.loads(result.extracted_content)
                    if isinstance(parsed, dict):
                        return [parsed]
                    if isinstance(parsed, list):
                        return parsed
                    return []
                
                return []
                
        except ImportError:
            print("ERROR: crawl4ai not installed. Run: pip install crawl4ai")
            return []
        except Exception as e:
            print(f"ERROR crawling {url}: {e}")
            return []
    
    async def simple_crawl(self, url: str) -> Optional[str]:
        """
        Simple crawl - just get HTML.
        
        Args:
            url: Target URL
            
        Returns:
            HTML content or None
        """
        try:
            from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode
            
            browser_config = self._build_browser_config()
            run_config = CrawlerRunConfig(
                cache_mode=CacheMode.BYPASS,
                verbose=self.config.CRAWL4AI_VERBOSE,
            )
            
            async with AsyncWebCrawler(config=browser_config) as crawler:
                result = await crawler.arun(url=url, config=run_config)
                return result.html if result else None
                
        except Exception as e:
            print(f"ERROR simple crawling {url}: {e}")
            return None

    async def scrape_google_maps_place(
        self,
        place_url: str,
        use_llm: bool = True,
    ) -> list[dict]:
        """
        Attempt extraction from a Google Maps place/details URL.

        Note:
        - This confirms crawler capability; production-hardening (pagination, anti-bot retries,
          source-specific parsing) should be layered later.
        """
        wait_for = "body"
        structured: list[dict] = []
        if use_llm:
            structured = await self.crawl_with_llm_extraction(
                url=place_url,
                schema=GOOGLE_PLACES_SCHEMA,
                instruction=GOOGLE_PLACES_EXTRACTION_INSTRUCTION,
                provider=self.config.LLM_PROVIDER,
                wait_for=wait_for,
            )
        else:
            structured = await self.crawl_with_css_extraction(
                url=place_url,
                css_schema=GOOGLE_PLACES_CSS_SCHEMA,
                wait_for=wait_for,
            )

        html = await self.simple_crawl(place_url)
        merged = self._normalize_google_place_record(
            source_url=place_url,
            structured_records=structured,
            raw_html=html,
        )
        return [merged]

    def _normalize_google_place_record(
        self,
        source_url: str,
        structured_records: list[dict],
        raw_html: Optional[str],
    ) -> dict:
        """
        Normalize Google place extraction into stable schema.

        This gives us a deterministic response contract even when Google DOM varies.
        """
        now_iso = datetime.now(timezone.utc).isoformat()
        record: dict[str, Any] = {
            "source": "google_maps",
            "source_url": source_url,
            "place_name": None,
            "rating": None,
            "review_count": None,
            "reviews": [],
            "category": None,
            "address": None,
            "latitude": None,
            "longitude": None,
            "phone": None,
            "website": None,
            "hours": [],
            "photos": [],
            "place_token": None,
            "raw_query": None,
            "extracted_at": now_iso,
            "completeness_score": 0.0,
            "is_complete": False,
        }

        if structured_records and isinstance(structured_records[0], dict):
            incoming = structured_records[0]
            synonyms = {
                "place_name": ["place_name", "name", "title"],
                "rating": ["rating", "stars"],
                "review_count": ["review_count", "reviews_count", "total_reviews"],
                "reviews": ["reviews", "review_snippets"],
                "category": ["category", "types", "type"],
                "address": ["address", "formatted_address"],
                "latitude": ["latitude", "lat"],
                "longitude": ["longitude", "lng", "lon"],
                "phone": ["phone", "phone_number"],
                "website": ["website", "url"],
                "hours": ["hours", "opening_hours"],
                "photos": ["photos", "images"],
            }
            for target, candidates in synonyms.items():
                for key in candidates:
                    value = incoming.get(key)
                    if value not in (None, "", [], {}):
                        record[target] = value
                        break

        if raw_html:
            html_hints = self._extract_google_maps_shell_hints(raw_html)
            for key, value in html_hints.items():
                if record.get(key) in (None, "", [], {}) and value not in (None, "", [], {}):
                    record[key] = value

        if not record["place_name"]:
            parsed = urlparse(source_url)
            path_parts = [p for p in parsed.path.split("/") if p]
            if "place" in path_parts:
                idx = path_parts.index("place")
                if idx + 1 < len(path_parts):
                    record["place_name"] = unquote(path_parts[idx + 1]).replace("+", " ")

        required = ["place_name", "latitude", "longitude", "source_url"]
        present = 0
        for key in required:
            value = record.get(key)
            if value not in (None, "", [], {}):
                present += 1
        record["completeness_score"] = round(present / len(required), 3)
        record["is_complete"] = (present == len(required))
        return record

    async def scrape_google_maps_place_with_reviews(
        self,
        place_url: str,
        review_limit: int = 7,
        use_llm: bool = True,
    ) -> dict:
        """
        Scrape a Google Maps place and request up to `review_limit` review snippets.
        """
        review_limit = max(1, min(review_limit, 12))
        structured: list[dict] = []
        if use_llm:
            instruction = (
                "Extract place details from this Google Maps page. "
                f"Return up to {review_limit} review snippets if visible on page. "
                "If any field is unknown, return null or empty array. "
                "Do not invent values."
            )
            structured = await self.crawl_with_llm_extraction(
                url=place_url,
                schema=GOOGLE_PLACES_WITH_REVIEWS_SCHEMA,
                instruction=instruction,
                provider=self.config.LLM_PROVIDER,
                wait_for="body",
            )
        else:
            structured = await self.crawl_with_css_extraction(
                url=place_url,
                css_schema=GOOGLE_PLACES_CSS_SCHEMA,
                wait_for="body",
            )
        html = await self.simple_crawl(place_url)
        return self._normalize_google_place_record(
            source_url=place_url,
            structured_records=structured,
            raw_html=html,
        )

    async def scrape_google_maps_dynamic_reviews(
        self,
        place_url: str,
        review_limit: int = 7,
    ) -> list[dict]:
        """
        Dynamic JS path: open reviews panel and extract review cards.
        """
        review_limit = max(1, min(review_limit, 12))
        rows = await self.crawl_with_css_extraction(
            url=place_url,
            css_schema=GOOGLE_DYNAMIC_REVIEW_SCHEMA,
            wait_for="body",
            js_code=[
                GOOGLE_JS_OPEN_REVIEWS_PANEL,
                GOOGLE_JS_SCROLL_REVIEWS_PANEL,
            ],
            delay_before_return_html=6.0,
            page_timeout=180000,
        )

        out: list[dict] = []
        seen: set[str] = set()
        for row in rows:
            if not isinstance(row, dict):
                continue
            text = (row.get("text") or "").strip()
            if len(text) < 35:
                continue
            key = re.sub(r"\s+", " ", text).lower()
            if key in seen:
                continue
            seen.add(key)
            out.append({
                "author": (row.get("author") or "").strip() or None,
                "rating": (row.get("rating") or "").strip() or None,
                "relative_time": (row.get("relative_time") or "").strip() or None,
                "text": re.sub(r"\s+", " ", text),
            })
            if len(out) >= review_limit:
                break
        return out

    async def crawl_search_review_snippets(
        self,
        query: str,
        limit: int = 7,
    ) -> list[str]:
        """
        Crawl low-volume web search snippets via Crawl4AI only.
        """
        limit = max(1, min(limit, 12))
        url = f"https://duckduckgo.com/html/?q={quote_plus(query)}"
        records = await self.crawl_with_css_extraction(
            url=url,
            css_schema=DUCKDUCKGO_SNIPPET_SCHEMA,
            wait_for="body",
        )
        snippets: list[str] = []
        seen: set[str] = set()
        for row in records:
            if not isinstance(row, dict):
                continue
            text = (row.get("snippet") or "").strip()
            if len(text) < 35:
                continue
            key = text.lower()
            if key in seen:
                continue
            seen.add(key)
            snippets.append(text)
            if len(snippets) >= limit:
                break
        return snippets

    def _extract_google_maps_shell_hints(self, html: str) -> dict:
        """
        Parse non-DOM stable hints from Google Maps shell/preload markup.
        """
        hints: dict[str, Any] = {}

        # Preview preload link carries query + pb payload with coords/place token.
        preview_match = re.search(r'href="(/maps/preview/place\?[^"]+)"', html)
        if preview_match:
            href = unescape(preview_match.group(1))
            full_url = f"https://www.google.com{href}"
            parsed = urlparse(full_url)
            qs = parse_qs(parsed.query)

            query = qs.get("q", [None])[0]
            if query:
                hints["raw_query"] = query.replace("+", " ")
                if not hints.get("place_name"):
                    hints["place_name"] = hints["raw_query"]

            pb = qs.get("pb", [None])[0]
            if pb:
                token = re.search(r"!1s([^!]+)", pb)
                if token:
                    hints["place_token"] = token.group(1)

                title = re.search(r"!2s([^!]+)", pb)
                if title:
                    hints["place_name"] = unquote(title.group(1)).replace("+", " ")

                lat_m = re.search(r"!3d(-?\d+(?:\.\d+)?)", pb)
                lng_m = re.search(r"!4d(-?\d+(?:\.\d+)?)", pb)
                if lat_m and lng_m:
                    hints["latitude"] = float(lat_m.group(1))
                    hints["longitude"] = float(lng_m.group(1))

        # Static map meta image usually includes center lat/lng.
        static_center = re.search(
            r"staticmap\?center=(-?\d+(?:\.\d+)?)%2C(-?\d+(?:\.\d+)?)",
            html,
            flags=re.IGNORECASE,
        )
        if static_center:
            hints.setdefault("latitude", float(static_center.group(1)))
            hints.setdefault("longitude", float(static_center.group(2)))

        return hints


# Example schemas for different sources

GOOGLE_PLACES_SCHEMA = {
    "name": "place_data",
    "type": "object",
    "properties": {
        "place_name": {"type": "string"},
        "rating": {"type": "number"},
        "review_count": {"type": "integer"},
        "price_level": {"type": "string"},
        "category": {"type": "string"},
        "address": {"type": "string"},
        "latitude": {"type": "number"},
        "longitude": {"type": "number"},
        "phone": {"type": "string"},
        "website": {"type": "string"},
        "hours": {"type": "array"},
        "reviews": {"type": "array"},
        "photos": {"type": "array"},
    }
}

GOOGLE_PLACES_EXTRACTION_INSTRUCTION = """
Extract all place information from this Google Maps page.
Be thorough - extract name, rating, reviews, photos, hours, contact info, location.
Return as JSON array with all places found.
"""

REDDIT_POST_SCHEMA = {
    "name": "reddit_post",
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "content": {"type": "string"},
        "subreddit": {"type": "string"},
        "upvotes": {"type": "integer"},
        "comments_count": {"type": "integer"},
        "url": {"type": "string"},
        "flair": {"type": "string"},
        "posted_time": {"type": "string"},
    }
}

REDDIT_EXTRACTION_INSTRUCTION = """
Extract Reddit posts from this page.
Get: title, content, subreddit, upvotes, comments count, URL, flair, time.
Return as JSON array.
"""

GOOGLE_PLACES_CSS_SCHEMA = {
    "name": "google_places_fallback",
    "baseSelector": "body",
    "fields": [
        {"name": "title", "selector": "h1", "type": "text"},
        {"name": "rating_text", "selector": "span[aria-label*='stars']", "type": "text"},
        {"name": "address_text", "selector": "button[data-item-id='address']", "type": "text"},
        {"name": "phone_text", "selector": "button[data-item-id^='phone']", "type": "text"},
    ],
}

GOOGLE_PLACES_WITH_REVIEWS_SCHEMA = {
    "name": "google_place_with_reviews",
    "type": "object",
    "properties": {
        "place_name": {"type": "string"},
        "rating": {"type": "number"},
        "review_count": {"type": "integer"},
        "category": {"type": "string"},
        "address": {"type": "string"},
        "latitude": {"type": "number"},
        "longitude": {"type": "number"},
        "phone": {"type": "string"},
        "website": {"type": "string"},
        "hours": {"type": "array"},
        "photos": {"type": "array"},
        "reviews": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "text": {"type": "string"},
                    "rating": {"type": "number"},
                    "relative_time": {"type": "string"},
                },
            },
        },
    },
}

DUCKDUCKGO_SNIPPET_SCHEMA = {
    "name": "search_snippets",
    "baseSelector": "div.result",
    "fields": [
        {"name": "title", "selector": "a.result__a", "type": "text"},
        {"name": "snippet", "selector": "a.result__snippet", "type": "text"},
    ],
}

GOOGLE_DYNAMIC_REVIEW_SCHEMA = {
    "name": "google_dynamic_reviews",
    "baseSelector": "div.jftiEf, div[data-review-id], div.MyEned, div[role='article']",
    "fields": [
        {"name": "author", "selector": "div.d4r55, span.d4r55, .TSUbDb", "type": "text"},
        {"name": "rating", "selector": "span.kvMYJc, span[aria-label*='stars']", "type": "attribute", "attribute": "aria-label"},
        {"name": "relative_time", "selector": "span.rsqaWe, .xRkPPb", "type": "text"},
        {"name": "text", "selector": "span.wiI7pd, div.MyEned span, div.MyEned", "type": "text"},
    ],
}

GOOGLE_JS_OPEN_REVIEWS_PANEL = """
(() => {
  const norm = (v) => (v || '').replace(/\\s+/g, ' ').trim().toLowerCase();
  const clickable = Array.from(document.querySelectorAll('button,[role="button"],a,div[role="button"],span[role="button"]'));
  const patterns = [/^reviews$/, /more reviews/, /all reviews/, /^review summary$/, /review summary/];
  const deny = [/write a review/, /about this data/, /sign in/];
  const clicked = [];
  for (const el of clickable) {
    const label = norm(el.getAttribute('aria-label') || el.textContent);
    if (!label) continue;
    if (deny.some((r) => r.test(label))) continue;
    if (patterns.some((r) => r.test(label))) {
      try { el.click(); clicked.push(label); break; } catch (e) {}
    }
  }
  if (!clicked.length) {
    const star = Array.from(document.querySelectorAll('span[aria-label*="stars"], span[aria-label*="Stars"]'))[0];
    if (star) {
      const parent = star.closest('button,[role="button"],a,div[role="button"]');
      if (parent) {
        try { parent.click(); clicked.push('star_parent'); } catch (e) {}
      }
    }
  }
  return { clicked };
})()
"""

GOOGLE_JS_SCROLL_REVIEWS_PANEL = """
(() => {
  const findScrollers = () => {
    const els = Array.from(document.querySelectorAll('div'));
    return els.filter((el) => {
      const sh = el.scrollHeight || 0;
      const ch = el.clientHeight || 0;
      if (sh < ch + 200) return false;
      const aria = (el.getAttribute('aria-label') || '').toLowerCase();
      const cls = (el.className || '').toString().toLowerCase();
      return aria.includes('review') || cls.includes('m6qerb') || cls.includes('dS8AEf');
    }).sort((a, b) => (b.scrollHeight - a.scrollHeight));
  };

  const scrollers = findScrollers();
  let scrolls = 0;
  if (scrollers.length) {
    const target = scrollers[0];
    for (let i = 0; i < 22; i++) {
      target.scrollTop = target.scrollHeight;
      scrolls += 1;
    }
  } else {
    for (let i = 0; i < 10; i++) {
      window.scrollTo(0, document.body.scrollHeight);
      scrolls += 1;
    }
  }

  const expandable = Array.from(document.querySelectorAll('button,[role="button"],span[role="button"]'));
  let expanded = 0;
  for (const el of expandable) {
    const label = ((el.getAttribute('aria-label') || el.textContent || '').trim().toLowerCase());
    if (label === 'more' || label === 'more reviews') {
      try { el.click(); expanded += 1; } catch (e) {}
    }
  }
  return { scrolls, expanded, scrollerCount: scrollers.length };
})()
"""


# Test
if __name__ == "__main__":
    async def test():
        wrapper = Crawl4AIWrapper()
        
        # Test simple crawl
        print("Testing simple crawl...")
        html = await wrapper.simple_crawl("https://www.example.com")
        if html:
            print(f"Got HTML: {html[:200]}...")
        
        print("\nDone!")
    
    asyncio.run(test())
