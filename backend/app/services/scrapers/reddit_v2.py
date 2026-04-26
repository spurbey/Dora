"""
Reddit scraper v2 — orchestrator over `reddit_json` + LLM stages.

Pipeline (each stage is independently testable):

    1. plan_search       (LLM)   pick subreddits + queries from context
    2. search_subreddit  (HTTP)  one call per (sub, query) → SearchHit[]
    3. fetch_post        (HTTP)  one call per chosen permalink → RedditPost
    4. extract_insights  (LLM)   one call per fetched post → TravelInsight[]

Routes through BrightData residential proxy (see app.services.scrapers.reddit_json).
Direct EC2 → Reddit returns 403 (datacenter IP class blocked). The proxy was
empirically the only path that returns real content; tested 2026-04-26.

Earlier iterations of this file used Playwright + Crawl4AI. Both were dropped:
the JSON endpoints are simpler, faster, cheaper to feed to the LLM, and
return cleaner structured data (title/body/comments tree) than scraped HTML.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from typing import Optional

from app.services.llm import chat_json
from app.services.scrapers.reddit_json import (
    RedditComment,
    RedditPost,
    SearchHit,
    fetch_post,
    search_subreddit,
)

logger = logging.getLogger(__name__)


# Defaults — overridable per call.
_DEFAULT_MAX_POSTS_PER_QUERY = 3
_DEFAULT_MAX_POSTS_TOTAL = 10
_DEFAULT_MIN_HIT_SCORE = 1
_DEFAULT_MIN_HIT_COMMENTS = 2
# Drop low-signal comments before sending to the extractor LLM. Saves tokens.
_EXTRACTOR_MIN_COMMENT_SCORE = 2
_EXTRACTOR_MIN_COMMENT_LEN = 40
_EXTRACTOR_MAX_COMMENTS = 30
_EXTRACTOR_MAX_REPLY_DEPTH = 1


# ---------------------------------------------------------------------------
# Data shapes (planner + extractor IO)
# ---------------------------------------------------------------------------


@dataclass
class ScrapeContext:
    """Everything the planner + extractor need to decide what to scrape."""

    locality: str                              # e.g. "Pune"
    intent_categories: list[str] = field(default_factory=list)
    trip_metadata: dict = field(default_factory=dict)
    user_metadata: dict = field(default_factory=dict)
    conversation_tail: list[dict] = field(default_factory=list)
    user_query: Optional[str] = None           # raw on_demand query if any


@dataclass
class SearchPlan:
    subreddits: list[str]
    queries: list[str]
    focus_categories: list[str]


@dataclass
class TravelInsight:
    category: str
    insight: str
    place_name: Optional[str] = None
    context_signal: Optional[str] = None
    best_for: Optional[str] = None
    source_url: str = ""

    def to_dict(self) -> dict:
        return {
            "category": self.category,
            "insight": self.insight,
            "place_name": self.place_name,
            "context_signal": self.context_signal,
            "best_for": self.best_for,
            "_source_url": self.source_url,
        }


@dataclass
class ScrapeResult:
    insights: list[TravelInsight]
    posts_visited: int
    posts_extracted: int
    llm_calls: int
    plan: Optional[SearchPlan] = None

    def to_dict(self) -> dict:
        return {
            "insights": [i.to_dict() for i in self.insights],
            "posts_visited": self.posts_visited,
            "posts_extracted": self.posts_extracted,
            "llm_calls": self.llm_calls,
            "plan": (
                {
                    "subreddits": self.plan.subreddits,
                    "queries": self.plan.queries,
                    "focus_categories": self.plan.focus_categories,
                }
                if self.plan
                else None
            ),
        }


# ---------------------------------------------------------------------------
# Stage 1: plan_search
# ---------------------------------------------------------------------------


_PLANNER_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "subreddits": {
            "type": "array",
            "minItems": 1,
            "maxItems": 5,
            "items": {"type": "string", "minLength": 2, "maxLength": 50},
        },
        "queries": {
            "type": "array",
            "minItems": 1,
            "maxItems": 4,
            "items": {"type": "string", "minLength": 3, "maxLength": 120},
        },
        "focus_categories": {
            "type": "array",
            "minItems": 1,
            "items": {
                "type": "string",
                "enum": [
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
                ],
            },
        },
    },
    "required": ["subreddits", "queries", "focus_categories"],
}


_PLANNER_FALLBACK_SUBREDDITS = ["IndiaTravel", "india", "travel"]


def _planner_messages(ctx: ScrapeContext) -> list[dict]:
    convo_tail = "\n".join(
        f"{m.get('role','?')}: {(m.get('content') or '')[:200]}"
        for m in (ctx.conversation_tail or [])[-6:]
    )
    convo_block = f"\nRecent conversation:\n{convo_tail}\n" if convo_tail else ""

    activity = ctx.trip_metadata.get("activity_focus") or []
    style = ctx.trip_metadata.get("travel_style") or []
    budget = ctx.trip_metadata.get("budget_category") or "any"
    diet = ctx.user_metadata.get("dietary_restrictions") or []
    dislikes = ctx.user_metadata.get("dislikes") or []
    intent = ", ".join(ctx.intent_categories) if ctx.intent_categories else "general travel tips"

    user_q_block = (
        f"\nUser asked: \"{ctx.user_query}\"\n" if ctx.user_query else ""
    )

    system = (
        "You are a Reddit search planner for a travel advisory pipeline. "
        "Given a traveler's destination and preferences, decide which "
        "subreddits and search queries will surface the most useful, "
        "actionable insights. Return strict JSON matching the schema. "
        "Subreddits: bare names without 'r/' prefix. Queries: each 3-8 "
        "words, optimized for old.reddit.com search relevance. Pick 2-5 "
        "subreddits and 2-4 queries. Skip generic subs like r/AskReddit. "
        "Prefer travel-specific, region-specific, or activity-specific subs. "
        "Focus categories must be from the allowed list."
    )

    user = (
        f"Destination: {ctx.locality}\n"
        f"Travel intent (categories of interest): {intent}\n"
        f"Activity focus: {', '.join(activity) if activity else 'unspecified'}\n"
        f"Travel style: {', '.join(style) if style else 'unspecified'}\n"
        f"Budget: {budget}\n"
        f"Dietary: {', '.join(diet) if diet else 'none'}\n"
        f"Dislikes: {', '.join(dislikes) if dislikes else 'none'}"
        f"{user_q_block}{convo_block}"
    )
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


async def plan_search(ctx: ScrapeContext, model: Optional[str] = None) -> SearchPlan:
    """Ask the LLM what to search. Falls back to a deterministic plan on LLM
    unavailability so the pipeline never stalls here."""
    try:
        out = await chat_json(
            messages=_planner_messages(ctx),
            schema=_PLANNER_SCHEMA,
            model=model,
            timeout_seconds=20.0,
            label="reddit_planner",
        )
    except Exception as exc:  # noqa: BLE001 — never raise from planner
        logger.warning("[reddit_v2] planner threw: %s", exc)
        out = None

    if out is None:
        logger.info(
            "[reddit_v2] planner LLM unavailable — using deterministic fallback plan"
        )
        return SearchPlan(
            subreddits=list(_PLANNER_FALLBACK_SUBREDDITS),
            queries=[
                f"{ctx.locality} travel tips",
                f"best things to do {ctx.locality}",
            ],
            focus_categories=ctx.intent_categories or ["general_tip", "must_do"],
        )

    subs = [s.strip().lstrip("r/").lstrip("/") for s in out.get("subreddits", []) if s]
    queries = [q.strip() for q in out.get("queries", []) if q and q.strip()]
    focus = list(out.get("focus_categories") or [])
    if not subs:
        subs = list(_PLANNER_FALLBACK_SUBREDDITS)
    if not queries:
        queries = [f"{ctx.locality} travel tips"]
    plan = SearchPlan(subreddits=subs, queries=queries, focus_categories=focus)
    logger.info(
        "[reddit_v2] plan: subs=%s queries=%s focus=%s",
        plan.subreddits, plan.queries, plan.focus_categories,
    )
    return plan


# ---------------------------------------------------------------------------
# Stage 4: extract_insights — per-post LLM call
# ---------------------------------------------------------------------------


_EXTRACTOR_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "insights": {
            "type": "array",
            "maxItems": 8,
            "items": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "category": {
                        "type": "string",
                        "enum": [
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
                        ],
                    },
                    "place_name": {"type": ["string", "null"], "maxLength": 120},
                    "insight": {"type": "string", "minLength": 20, "maxLength": 320},
                    "context_signal": {"type": ["string", "null"], "maxLength": 120},
                    "best_for": {"type": ["string", "null"], "maxLength": 120},
                },
                "required": ["category", "insight"],
            },
        }
    },
    "required": ["insights"],
}


def _flatten_comments(
    comments: list[RedditComment],
    *,
    depth: int = 0,
    max_depth: int = _EXTRACTOR_MAX_REPLY_DEPTH,
) -> list[RedditComment]:
    """DFS-flatten the comment tree, keeping replies up to max_depth.

    Returns flat list ordered by traversal so context (parent-then-replies)
    is preserved for the LLM.
    """
    out: list[RedditComment] = []
    for c in comments:
        out.append(c)
        if depth < max_depth and c.replies:
            out.extend(
                _flatten_comments(
                    c.replies, depth=depth + 1, max_depth=max_depth
                )
            )
    return out


def _filter_comments_for_llm(
    comments: list[RedditComment],
) -> list[RedditComment]:
    """Drop low-signal comments to save LLM tokens.

    Rules:
    - body length >= _EXTRACTOR_MIN_COMMENT_LEN OR is OP (OP often
      clarifies in short replies, worth keeping)
    - score >= _EXTRACTOR_MIN_COMMENT_SCORE OR is OP
    - cap at _EXTRACTOR_MAX_COMMENTS, sorted by score desc, OP first
    """
    flat = _flatten_comments(comments)
    kept: list[RedditComment] = []
    for c in flat:
        if c.is_op:
            kept.append(c)
            continue
        if len(c.body) < _EXTRACTOR_MIN_COMMENT_LEN:
            continue
        if c.score < _EXTRACTOR_MIN_COMMENT_SCORE:
            continue
        kept.append(c)
    # OP comments first, then by score desc.
    kept.sort(key=lambda c: (0 if c.is_op else 1, -c.score))
    return kept[:_EXTRACTOR_MAX_COMMENTS]


def _extractor_messages(
    post: RedditPost, ctx: ScrapeContext
) -> list[dict]:
    """Build the LLM prompt. Comments come in as a structured list with
    score + is_op tags so the model can weight them naturally."""
    intent = ", ".join(ctx.intent_categories) if ctx.intent_categories else "general travel"
    diet = ctx.user_metadata.get("dietary_restrictions") or []
    activity = ctx.trip_metadata.get("activity_focus") or []
    budget = ctx.trip_metadata.get("budget_category") or "any"

    filtered = _filter_comments_for_llm(post.comments)

    # Render comments as a compact JSON-ish list inline in the prompt.
    comment_lines: list[str] = []
    for c in filtered:
        op_tag = " (OP)" if c.is_op else ""
        author_tag = c.author or "anon"
        comment_lines.append(
            f"- [{author_tag}{op_tag}, score={c.score}] {c.body}"
        )
    comments_block = "\n".join(comment_lines) if comment_lines else "(no qualifying comments)"

    system = (
        "You are extracting structured travel insights from a Reddit thread "
        "(post + selected comments) for a traveler. ONLY emit insights that are: "
        "(a) actionable — someone could DO or AVOID the thing, "
        "(b) specific — a place, behavior, dish, route — not vibes, "
        "(c) relevant to the destination + intent below. "
        "Skip jokes, off-topic chatter, generic platitudes, and insights about "
        "other destinations. If a tip mentions a specific place, fill place_name. "
        "If multiple commenters reinforce the same tip, note that in "
        "context_signal (e.g. 'mentioned by 3 commenters'; 'OP confirmed in "
        "replies'). If the entire thread has nothing useful for this traveler, "
        "return an empty insights array. Strict JSON per schema."
    )

    user = (
        f"Destination: {ctx.locality}\n"
        f"Traveler intent: {intent}\n"
        f"Activity focus: {', '.join(activity) if activity else '-'}\n"
        f"Dietary: {', '.join(diet) if diet else '-'}\n"
        f"Budget: {budget}\n"
        f"\nReddit post: {post.title}\n"
        f"Source: https://www.reddit.com{post.permalink}\n"
        f"OP body: {post.body[:1500] if post.body else '(no selftext)'}\n"
        f"\nComments ({len(filtered)} of {len(post.comments)} top-level shown):\n"
        f"{comments_block}"
    )
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


async def extract_insights(
    post: RedditPost,
    ctx: ScrapeContext,
    *,
    model: Optional[str] = None,
) -> list[TravelInsight]:
    """Run the per-post LLM extractor. Returns [] on any failure."""
    if not post.title and not post.body and not post.comments:
        return []
    try:
        out = await chat_json(
            messages=_extractor_messages(post, ctx),
            schema=_EXTRACTOR_SCHEMA,
            model=model,
            timeout_seconds=30.0,
            label="reddit_extractor",
            max_tokens=1500,
        )
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "[reddit_v2] extractor threw on %s: %s", post.permalink[:60], exc
        )
        return []
    if out is None:
        return []
    raw = out.get("insights") or []
    insights: list[TravelInsight] = []
    src_url = f"https://www.reddit.com{post.permalink}"
    for item in raw:
        if not isinstance(item, dict):
            continue
        cat = item.get("category")
        ins = (item.get("insight") or "").strip()
        if not cat or not ins:
            continue
        insights.append(
            TravelInsight(
                category=cat,
                insight=ins,
                place_name=(item.get("place_name") or None),
                context_signal=(item.get("context_signal") or None),
                best_for=(item.get("best_for") or None),
                source_url=src_url,
            )
        )
    return insights


# ---------------------------------------------------------------------------
# Orchestrator
# ---------------------------------------------------------------------------


def _qualifies_hit(hit: SearchHit) -> bool:
    return (
        hit.score >= _DEFAULT_MIN_HIT_SCORE
        and hit.num_comments >= _DEFAULT_MIN_HIT_COMMENTS
    )


async def scrape_reddit_v2(
    ctx: ScrapeContext,
    *,
    max_posts_per_query: int = _DEFAULT_MAX_POSTS_PER_QUERY,
    max_posts_total: int = _DEFAULT_MAX_POSTS_TOTAL,
    planner_model: Optional[str] = None,
    extractor_model: Optional[str] = None,
) -> ScrapeResult:
    """Run the 4-stage pipeline. Never raises — degrades gracefully.

    Stages:
      1. LLM picks subreddits + queries
      2. Search each (sub, query) via reddit_json (BrightData proxy)
      3. Fetch each chosen post via reddit_json
      4. LLM extracts TravelInsight[] per post
    """
    llm_calls = 0
    posts_visited = 0
    posts_extracted = 0
    insights: list[TravelInsight] = []

    # Stage 1: plan
    plan = await plan_search(ctx, model=planner_model)
    llm_calls += 1

    # Stage 2: search → SearchHit list
    seen_perms: set[str] = set()
    hits: list[SearchHit] = []
    for sub in plan.subreddits:
        for q in plan.queries:
            if len(hits) >= max_posts_total:
                break
            sub_hits = await search_subreddit(sub, q, limit=max_posts_per_query * 2)
            qualifying = [h for h in sub_hits if _qualifies_hit(h)]
            for h in qualifying[:max_posts_per_query]:
                if h.permalink in seen_perms:
                    continue
                seen_perms.add(h.permalink)
                hits.append(h)
                if len(hits) >= max_posts_total:
                    break
        if len(hits) >= max_posts_total:
            break

    if not hits:
        logger.info("[reddit_v2] plan produced 0 qualifying hits")
        return ScrapeResult(
            insights=[], posts_visited=0, posts_extracted=0,
            llm_calls=llm_calls, plan=plan,
        )

    # Stages 3 + 4: fetch each post, extract insights
    for hit in hits:
        posts_visited += 1
        post = await fetch_post(hit.permalink)
        if post is None:
            continue
        post_insights = await extract_insights(post, ctx, model=extractor_model)
        llm_calls += 1
        if post_insights:
            posts_extracted += 1
            insights.extend(post_insights)

    logger.info(
        "[reddit_v2] done. posts_visited=%d posts_extracted=%d insights=%d llm_calls=%d",
        posts_visited, posts_extracted, len(insights), llm_calls,
    )
    return ScrapeResult(
        insights=insights,
        posts_visited=posts_visited,
        posts_extracted=posts_extracted,
        llm_calls=llm_calls,
        plan=plan,
    )
