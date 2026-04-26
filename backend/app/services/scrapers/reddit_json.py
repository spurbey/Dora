"""
Reddit JSON fetcher via BrightData residential proxy.

Why this module exists:
    Reddit blocks every datacenter ASN we tried (EC2 direct + Webshare DC
    proxy both returned 403/blocked HTML). Their `whoa there, pardner!`
    page even tells you to use the official API, but we want richer
    response shapes than the raw v1 endpoints. The undocumented `.json`
    suffix on public Reddit URLs returns the same data Reddit's mobile
    apps consume — pre-parsed posts, comments, scores, replies — and
    routing it through BrightData residential bypasses the IP-class block.

Two public functions:
    search_subreddit(subreddit, query, limit) -> list[SearchHit]
    fetch_post(permalink) -> RedditPost | None

Both fail-soft: any HTTP / JSON error returns []/None and logs. Caller
takes a deterministic fallback path (typically: skip this source).

Inspired by the YARS package (datavorous/yars) but reimplemented inline
to avoid pulling in a 1MB user-agent list and dependency tree we don't
need. Same two endpoints (`.../search.json`, `.../{permalink}.json`),
same JSON shape.
"""

from __future__ import annotations

import logging
import os
import random
from dataclasses import dataclass, field
from typing import Optional

import httpx

from app.config import settings

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Result shapes
# ---------------------------------------------------------------------------


@dataclass
class SearchHit:
    title: str
    permalink: str            # leading-slash form: /r/.../comments/.../slug/
    description: str          # post selftext preview, may be empty
    score: int = 0
    num_comments: int = 0


@dataclass
class RedditComment:
    author: Optional[str]
    body: str
    score: int
    is_op: bool = False
    replies: list["RedditComment"] = field(default_factory=list)


@dataclass
class RedditPost:
    permalink: str
    title: str
    body: str                 # OP selftext
    op_author: Optional[str]
    score: int
    num_comments: int
    comments: list[RedditComment]


# ---------------------------------------------------------------------------
# HTTP setup — proxy + cert
# ---------------------------------------------------------------------------


# Five real Chrome / Firefox UA strings. We rotate per request so the proxy
# pool sees a normal mix of clients, not "same UA from 1000 different IPs".
_UA_POOL = [
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
]


def _cfg(name: str, default: str = "") -> str:
    """Prefer env (handles hot-pushed test runs into a container that was
    built before these settings fields existed); fall back to settings."""
    val = os.environ.get(name)
    if val is None:
        val = getattr(settings, name, default)
    return (val or "").strip() if isinstance(val, str) else str(val or default)


def _proxy_url() -> Optional[str]:
    """Build the proxy URL from env / settings, or None if not configured."""
    user = _cfg("BRIGHTDATA_PROXY_USER")
    pwd = _cfg("BRIGHTDATA_PROXY_PASS")
    host = _cfg("BRIGHTDATA_PROXY_HOST", "brd.superproxy.io")
    port = _cfg("BRIGHTDATA_PROXY_PORT", "33335")
    if not (user and pwd and host and port):
        return None
    return f"http://{user}:{pwd}@{host}:{port}"


def _verify_arg() -> object:
    """Return the value to pass as `verify=` to httpx.

    Prefer the bundled CA cert path. If it's missing on disk (which would
    only happen during local dev outside Docker), fall back to True so
    httpx uses the system bundle — that won't authenticate the BrightData
    proxy's MITM but keeps local tests runnable.
    """
    ca_path = _cfg("BRIGHTDATA_PROXY_CA_PATH", "/app/certs/brightdata_ca.crt")
    if ca_path and os.path.isfile(ca_path):
        return ca_path
    logger.warning(
        "BrightData CA cert not found at %s — TLS verification falls back "
        "to system bundle. This will fail when actually proxying through "
        "BrightData; set BRIGHTDATA_PROXY_CA_PATH or mount the cert.",
        ca_path,
    )
    return True


def _client(timeout: float = 12.0) -> httpx.AsyncClient:
    """Build a per-request AsyncClient. We don't share clients to keep
    each request independent — Reddit's edge has been observed to flag
    long-lived sessions even from residential IPs."""
    headers = {
        "User-Agent": random.choice(_UA_POOL),
        "Accept": "application/json,text/javascript,*/*;q=0.01",
        "Accept-Language": "en-US,en;q=0.9",
    }
    proxy = _proxy_url()
    return httpx.AsyncClient(
        timeout=timeout,
        headers=headers,
        proxy=proxy,
        verify=_verify_arg(),
        follow_redirects=True,
    )


# ---------------------------------------------------------------------------
# Public: search_subreddit
# ---------------------------------------------------------------------------


async def search_subreddit(
    subreddit: str,
    query: str,
    *,
    limit: int = 10,
    sort: str = "relevance",
    time_filter: str = "year",
) -> list[SearchHit]:
    """Search inside one subreddit. Returns up to `limit` hits.

    Endpoint: https://www.reddit.com/r/{sub}/search.json?q=...&restrict_sr=on
    Returns empty list on any failure.
    """
    sub = subreddit.strip().lstrip("r/").lstrip("/")
    if not sub or not query.strip():
        return []

    url = f"https://www.reddit.com/r/{sub}/search.json"
    params = {
        "q": query,
        "limit": limit,
        "sort": sort,
        "type": "link",
        "restrict_sr": "on",
        "t": time_filter,
    }

    try:
        async with _client() as cl:
            resp = await cl.get(url, params=params)
    except (httpx.HTTPError, OSError) as exc:
        logger.warning(
            "[reddit_json] search %s/%r http error: %s", sub, query, exc
        )
        return []

    if resp.status_code != 200:
        logger.warning(
            "[reddit_json] search %s/%r non-200: %s",
            sub, query, resp.status_code,
        )
        return []

    try:
        data = resp.json()
        children = data.get("data", {}).get("children", []) or []
    except (ValueError, AttributeError) as exc:
        logger.warning(
            "[reddit_json] search %s/%r parse error: %s", sub, query, exc
        )
        return []

    hits: list[SearchHit] = []
    for item in children:
        d = item.get("data") or {}
        permalink = d.get("permalink") or ""
        title = d.get("title") or ""
        if not (permalink and title):
            continue
        hits.append(
            SearchHit(
                title=title,
                permalink=permalink,
                description=(d.get("selftext") or "")[:300],
                score=int(d.get("score") or 0),
                num_comments=int(d.get("num_comments") or 0),
            )
        )
    logger.info(
        "[reddit_json] search %s/%r ok hits=%d",
        sub, query, len(hits),
    )
    return hits


# ---------------------------------------------------------------------------
# Public: fetch_post
# ---------------------------------------------------------------------------


async def fetch_post(permalink: str) -> Optional[RedditPost]:
    """Fetch a post + its comment tree. Returns None on any failure.

    permalink is leading-slash form, e.g. "/r/Pune/comments/abc/title/".
    Reddit returns a 2-element JSON array: [post_listing, comments_listing].
    """
    pl = (permalink or "").strip()
    if not pl.startswith("/"):
        return None

    url = f"https://www.reddit.com{pl.rstrip('/')}.json"

    try:
        async with _client(timeout=20.0) as cl:
            resp = await cl.get(url)
    except (httpx.HTTPError, OSError) as exc:
        logger.warning(
            "[reddit_json] post %s %s: %r",
            pl[:60], type(exc).__name__, exc,
        )
        return None

    if resp.status_code != 200:
        logger.warning(
            "[reddit_json] post %s non-200: %s", pl[:60], resp.status_code
        )
        return None

    try:
        data = resp.json()
    except ValueError as exc:
        logger.warning("[reddit_json] post %s parse error: %s", pl[:60], exc)
        return None

    if not isinstance(data, list) or len(data) < 2:
        logger.info("[reddit_json] post %s unexpected shape", pl[:60])
        return None

    try:
        post_node = data[0]["data"]["children"][0]["data"]
    except (KeyError, IndexError, TypeError):
        logger.info("[reddit_json] post %s missing post node", pl[:60])
        return None

    op_author = post_node.get("author")
    title = post_node.get("title") or ""
    body = post_node.get("selftext") or ""
    score = int(post_node.get("score") or 0)
    num_comments = int(post_node.get("num_comments") or 0)

    raw_comments = []
    try:
        raw_comments = data[1]["data"]["children"]
    except (KeyError, IndexError, TypeError):
        pass

    comments = _parse_comments(raw_comments, op_author=op_author, depth=0)

    logger.info(
        "[reddit_json] post %s ok body=%d comments=%d (top-level)",
        pl[:60], len(body), len(comments),
    )
    return RedditPost(
        permalink=pl,
        title=title,
        body=body,
        op_author=op_author,
        score=score,
        num_comments=num_comments,
        comments=comments,
    )


def _parse_comments(
    raw: list,
    *,
    op_author: Optional[str],
    depth: int,
    max_depth: int = 2,
) -> list[RedditComment]:
    """Recursively parse the comment tree. Caps depth to keep payload sane.

    We pull author + body + score + first ~level of replies. Beyond
    `max_depth` the tree gets pruned — for advisory extraction the OP
    plus first 1-2 reply layers carry almost all the signal.
    """
    out: list[RedditComment] = []
    if depth > max_depth:
        return out
    for node in raw or []:
        if not isinstance(node, dict):
            continue
        if node.get("kind") != "t1":
            # 'more' nodes (collapsed reply chains) — skip; they need a
            # separate `morechildren` API call to expand and we don't
            # need that fidelity.
            continue
        d = node.get("data") or {}
        body = (d.get("body") or "").strip()
        if not body or body in ("[deleted]", "[removed]"):
            continue
        author = d.get("author")
        replies_node = d.get("replies")
        replies = []
        if isinstance(replies_node, dict):
            try:
                replies = _parse_comments(
                    replies_node.get("data", {}).get("children", []),
                    op_author=op_author,
                    depth=depth + 1,
                    max_depth=max_depth,
                )
            except Exception:  # noqa: BLE001
                replies = []
        out.append(
            RedditComment(
                author=author,
                body=body,
                score=int(d.get("score") or 0),
                is_op=bool(op_author and author == op_author),
                replies=replies,
            )
        )
    return out
