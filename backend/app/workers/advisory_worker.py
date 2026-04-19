"""
Advisory pipeline worker.

Runs as a separate process alongside export_worker and live_tracking_worker.
Entry: python -m app.workers.advisory_worker
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
import logging
import os
import time
from typing import Optional
from uuid import uuid4

from sqlalchemy import or_
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from app.config import settings
from app.database import SessionLocal
from app.models.advisory_job import AdvisoryJob
from app.models.trip_advisory import TripAdvisory
from app.models.trip import Trip
from app.models.place import TripPlace
from app.services.trip_brain_service import TripBrainService, TargetContext


STAGE_ORDER = [
    "route_segmentation",
    "reddit_scrape",
    "tripadvisor_scrape",
    "gmaps_scrape",
    "llm_extraction",
    "scoring",
    "delivery",
]
RETRY_BACKOFF_SECONDS = [30, 120, 480]

logger = logging.getLogger(__name__)


# ─── Helpers ─────────────────────────────────────────────────────────────────


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def backoff_seconds(retry_count: int) -> int:
    index = max(0, min(retry_count - 1, len(RETRY_BACKOFF_SECONDS) - 1))
    return RETRY_BACKOFF_SECONDS[index]


class TerminalJobError(Exception):
    """Non-retryable error. Job goes to 'blocked' status."""
    def __init__(self, error_code: str, error_message: str) -> None:
        super().__init__(error_message)
        self.error_code = error_code
        self.error_message = error_message


# ─── Job claiming ────────────────────────────────────────────────────────────


def claim_next_job(db: Session, worker_session_id: str) -> Optional[AdvisoryJob]:
    now = utcnow()
    job = (
        db.query(AdvisoryJob)
        .filter(AdvisoryJob.status == "queued")
        .filter(or_(
            AdvisoryJob.next_attempt_at.is_(None),
            AdvisoryJob.next_attempt_at <= now,
        ))
        .order_by(AdvisoryJob.created_at.asc())
        .with_for_update(skip_locked=True)
        .first()
    )
    if not job:
        return None

    job.status = "processing"
    job.stage = STAGE_ORDER[0]
    job.progress = 0.0
    job.started_at = job.started_at or now
    job.worker_session_id = worker_session_id
    job.error_code = None
    job.error_message = None
    db.commit()
    logger.info(
        "[ADVISORY_WORKER] claimed job_id=%s trip_id=%s type=%s",
        job.id, job.trip_id, job.job_type,
    )
    return job


def recover_orphaned_jobs(db: Session, stale_after_seconds: int = 900) -> int:
    cutoff = utcnow() - timedelta(seconds=stale_after_seconds)
    stale = (
        db.query(AdvisoryJob)
        .filter(AdvisoryJob.status.in_(["processing", "cancel_requested"]))
        .filter(AdvisoryJob.updated_at < cutoff)
        .all()
    )
    if not stale:
        return 0

    now = utcnow()
    count = 0
    for job in stale:
        if job.status == "cancel_requested":
            job.status = "canceled"
            job.error_code = "canceled_by_user"
            job.error_message = "Canceled during stale recovery"
        elif job.retry_count < job.max_retries:
            job.status = "queued"
            job.next_attempt_at = now
            job.error_code = "worker_recovered"
            job.error_message = "Recovered after worker restart"
        else:
            job.status = "failed"
            job.error_code = "worker_timeout"
            job.error_message = "Failed during stale recovery — retry limit reached"

        job.stage = None
        job.progress = 0.0
        job.completed_at = now if job.status in ("canceled", "failed") else None
        job.worker_session_id = None
        count += 1

    db.commit()
    logger.info("[ADVISORY_WORKER] recovered %d stale job(s)", count)
    return count


# ─── Retry / terminal handling ───────────────────────────────────────────────


def _mark_retry_or_fail(db: Session, job: AdvisoryJob, error_code: str, error_message: str) -> None:
    db.refresh(job)
    if job.status == "cancel_requested":
        _set_canceled(job)
        db.commit()
        return

    now = utcnow()
    next_retry = job.retry_count + 1

    logger.error(
        "[ADVISORY_FAIL] job_id=%s error=%s retry=%s/%s msg=%s",
        job.id, error_code, next_retry, job.max_retries, error_message,
    )

    job.retry_count = next_retry
    job.error_code = error_code
    job.error_message = error_message
    job.stage = None

    if next_retry <= job.max_retries:
        delay = backoff_seconds(next_retry)
        job.status = "queued"
        job.progress = 0.0
        job.next_attempt_at = now + timedelta(seconds=delay)
        job.worker_session_id = None
        job.completed_at = None
    else:
        job.status = "failed"
        job.progress = 0.0
        job.completed_at = now
        job.worker_session_id = None
        job.next_attempt_at = None

    db.commit()


def _mark_terminal_blocked(db: Session, job: AdvisoryJob, error_code: str, error_message: str) -> None:
    now = utcnow()
    job.status = "blocked"
    job.stage = None
    job.progress = 0.0
    job.error_code = error_code
    job.error_message = error_message
    job.completed_at = now
    job.worker_session_id = None
    job.next_attempt_at = None
    db.commit()
    logger.error("[ADVISORY_BLOCKED] job_id=%s error=%s", job.id, error_code)


def _set_canceled(job: AdvisoryJob) -> None:
    job.status = "canceled"
    job.stage = None
    job.progress = 0.0
    job.error_code = "canceled_by_user"
    job.error_message = "Canceled by user request"
    job.completed_at = utcnow()
    job.worker_session_id = None
    job.next_attempt_at = None


def _heartbeat(db: Session, job: AdvisoryJob) -> None:
    """Update updated_at to prevent false stale recovery during long stages."""
    job.updated_at = utcnow()
    db.commit()


# ─── Cycle-job helpers (location_trigger) ────────────────────────────────────


def _is_cycle_job(job: AdvisoryJob) -> bool:
    """True when this job was fired by the advisory_cycle_worker."""
    return job.job_type == "location_trigger"


def _target_from_plan(job: AdvisoryJob) -> Optional[TargetContext]:
    """Reconstruct the TargetContext wired into scrape_plan by the cycle worker.

    advisory_service.create_advisory_job wraps the trigger_payload as either:
        - scrape_plan = {"trigger_payload": {...}}            (new job)
        - scrape_plan keeps existing + coalesced_triggers[]   (coalesced job)

    We accept either shape, preferring a direct "target" key (for future
    compatibility) and falling back to trigger_payload / last coalesced.
    """
    plan = job.scrape_plan or {}
    raw: Optional[dict] = None
    if isinstance(plan.get("target"), dict):
        raw = plan["target"]
    elif isinstance(plan.get("trigger_payload"), dict):
        raw = plan["trigger_payload"]
    else:
        coalesced = plan.get("coalesced_triggers") or []
        if coalesced and isinstance(coalesced[-1], dict):
            raw = coalesced[-1]
    if not raw:
        return None
    try:
        return TargetContext(
            locality_key=raw.get("locality_key") or "",
            locality=raw.get("locality"),
            region=raw.get("region"),
            country=raw.get("country"),
            center_lat=float(raw.get("center_lat") or 0.0),
            center_lng=float(raw.get("center_lng") or 0.0),
            mode=raw.get("mode") or "route",
            sample_idx=raw.get("sample_idx"),
            trip_metadata=dict(raw.get("trip_metadata") or {}),
            user_metadata=dict(raw.get("user_metadata") or {}),
            recent_categories=dict(raw.get("recent_categories") or {}),
            baseline_findings=dict(raw.get("baseline_findings") or {}),
        )
    except (TypeError, ValueError):
        return None


# ─── Stage handlers (stubs — wired in Step 8-9) ─────────────────────────────


async def _stage_route_segmentation(db: Session, job: AdvisoryJob) -> None:
    """Segment route into cities/destinations OR resolve a cycle target.

    For pre_trip / on_demand jobs the pipeline scans TripPlaces as before.
    For location_trigger jobs we bypass that and pull the target the cycle
    worker wrote into scrape_plan.target — composing a Reddit query from
    locality + activity_focus + dietary_restrictions, minus the categories
    already over-represented in recent_categories.
    """
    logger.info("[ADVISORY_STAGE] route_segmentation job_id=%s", job.id)
    from app.services.scrapers.reddit_scraper import (
        derive_search_query,
        extract_keywords,
    )

    trip = db.query(Trip).filter(Trip.id == job.trip_id).first()
    if not trip:
        raise TerminalJobError("trip_not_found", f"Trip {job.trip_id} not found")

    plan = job.scrape_plan or {}

    # Cycle job: narrow the scrape plan to the target locality only.
    if _is_cycle_job(job):
        target = _target_from_plan(job)
        if target is None or not target.locality:
            raise TerminalJobError(
                "invalid_cycle_target",
                "location_trigger job missing scrape_plan.target",
            )
        trip_meta = target.trip_metadata or {}
        user_meta = target.user_metadata or {}
        recent = target.recent_categories or {}

        activity_focus = list(trip_meta.get("activity_focus") or [])
        dietary = list(user_meta.get("dietary_restrictions") or [])
        # Avoid re-querying categories the user has seen too often.
        exclude = [cat for cat, count in recent.items() if count and int(count) >= 2]

        question_parts = [
            f"travel tips for {target.locality}",
            " ".join(activity_focus[:3]) if activity_focus else "",
            " ".join(dietary[:2]) if dietary else "",
        ]
        question = " ".join(p for p in question_parts if p).strip()
        keywords = extract_keywords(question, [target.locality])
        keywords = [k for k in keywords if k not in exclude]

        plan.update(
            {
                "cities": [target.locality],
                "question": question,
                "keywords": keywords,
                "search_query": derive_search_query(keywords),
                "subreddits": ["IndiaTravel", "solotravel", "travel"],
                "max_pages": 4,           # lighter per-cycle fetch
                "max_depth": 1,
                "exclude_categories": exclude,
            }
        )
        job.scrape_plan = plan
        flag_modified(job, "scrape_plan")
        db.commit()
        return

    # Pre-trip / on-demand path — unchanged behaviour based on pinned places.
    places = (
        db.query(TripPlace)
        .filter(TripPlace.trip_id == job.trip_id)
        .order_by(TripPlace.order_in_trip.asc())
        .all()
    )
    city_names = []
    for p in places:
        name = p.name or ""
        if name and name not in city_names:
            city_names.append(name)
    if not city_names:
        city_names = [trip.title or "travel destination"]

    if job.job_type == "on_demand" and job.query_text:
        question = job.query_text
    else:
        question = f"travel tips for {', '.join(city_names[:5])}"

    subs = ["IndiaTravel", "solotravel", "travel"]
    keywords = extract_keywords(question, city_names)

    plan.update(
        {
            "cities": city_names,
            "question": question,
            "keywords": keywords,
            "search_query": derive_search_query(keywords),
            "subreddits": subs,
            "max_pages": 8,
            "max_depth": 2,
        }
    )
    job.scrape_plan = plan
    flag_modified(job, "scrape_plan")
    db.commit()


async def _stage_reddit_scrape(db: Session, job: AdvisoryJob) -> None:
    """Deep crawl Reddit + LLM extraction."""
    logger.info("[ADVISORY_STAGE] reddit_scrape job_id=%s", job.id)

    if not settings.OPENROUTER_API_KEY:
        logger.warning("[ADVISORY_STAGE] reddit_scrape skipped — no OPENROUTER_API_KEY")
        result = job.result_summary or {}
        result["reddit"] = {"status": "skipped_no_config", "insights": []}
        job.result_summary = result
        db.commit()
        return

    _heartbeat(db, job)

    plan = job.scrape_plan or {}
    question = plan.get("question", "travel tips")
    subs = plan.get("subreddits", ["IndiaTravel", "travel"])
    keywords = plan.get("keywords", [])
    max_pages = plan.get("max_pages", 8)
    max_depth = plan.get("max_depth", 2)

    from app.services.scrapers.reddit_scraper import scrape_reddit
    scrape_result = await scrape_reddit(
        question=question,
        subs=subs,
        extra_keywords=keywords,
        max_pages=max_pages,
        max_depth=max_depth,
        openrouter_api_key=settings.OPENROUTER_API_KEY,
        openrouter_model=settings.OPENROUTER_MODEL,
    )

    _heartbeat(db, job)

    result = job.result_summary or {}
    result["reddit"] = {
        "status": "done",
        "pages_visited": scrape_result.get("pages_visited", 0),
        "insights": scrape_result.get("insights", []),
    }
    job.result_summary = result
    flag_modified(job, "result_summary")
    db.commit()
    logger.info(
        "[ADVISORY_STAGE] reddit_scrape done. insights=%d",
        len(scrape_result.get("insights", [])),
    )


async def _stage_tripadvisor_scrape(db: Session, job: AdvisoryJob) -> None:
    """Scrape TripAdvisor — skip if not configured."""
    logger.info("[ADVISORY_STAGE] tripadvisor_scrape job_id=%s (stub — skipping)", job.id)
    result = job.result_summary or {}
    result["tripadvisor"] = {"status": "skipped", "insights": []}
    job.result_summary = result
    flag_modified(job, "result_summary")
    db.commit()


async def _stage_gmaps_scrape(db: Session, job: AdvisoryJob) -> None:
    """GMaps POI search + targeted review fetches.

    Only runs for location_trigger (cycle) jobs with a resolved target.
    Enforces BRIGHTDATA_MAX_CALLS_PER_TRIP atomically via the brain. On
    missing config or cap breach we skip cleanly — Reddit-only advisories
    still fire downstream.
    """
    result = job.result_summary or {}

    if not settings.BRIGHTDATA_WS_ENDPOINT:
        logger.info(
            "[ADVISORY_STAGE] gmaps_scrape job_id=%s skipped (no BRIGHTDATA_WS_ENDPOINT)",
            job.id,
        )
        result["gmaps"] = {"status": "skipped_no_config", "pois": []}
        job.result_summary = result
        flag_modified(job, "result_summary")
        db.commit()
        return

    if not _is_cycle_job(job):
        logger.info(
            "[ADVISORY_STAGE] gmaps_scrape job_id=%s skipped (non-cycle job)",
            job.id,
        )
        result["gmaps"] = {"status": "skipped_non_cycle", "pois": []}
        job.result_summary = result
        flag_modified(job, "result_summary")
        db.commit()
        return

    target = _target_from_plan(job)
    if target is None or not target.locality:
        result["gmaps"] = {"status": "skipped_no_target", "pois": []}
        job.result_summary = result
        flag_modified(job, "result_summary")
        db.commit()
        return

    brain_svc = TripBrainService(db)
    trip_meta = target.trip_metadata or {}
    activity_focus = list(trip_meta.get("activity_focus") or [])
    intent = " ".join(activity_focus[:2]) if activity_focus else "things to do"
    query = f"{intent} in {target.locality}"

    # Budget: account for 1 search call + up to 4 review fetches.
    new_count = brain_svc.try_increment_brightdata(job.trip_id, n=5)
    if new_count is None:
        logger.warning(
            "[ADVISORY_STAGE] gmaps_scrape job_id=%s skipped (brightdata cap reached)",
            job.id,
        )
        result["gmaps"] = {"status": "skipped_cap", "pois": []}
        job.result_summary = result
        flag_modified(job, "result_summary")
        db.commit()
        return

    _heartbeat(db, job)
    from app.services.scrapers.gmaps_scraper import (
        scrape_gmaps_reviews,
        scrape_gmaps_search,
    )
    pois = await scrape_gmaps_search(query, location=None, max_pois=20)

    # Weather snapshot for the target centroid at advisory time.
    from app.services.weather_service import get_forecast
    forecast = await get_forecast(target.center_lat, target.center_lng)
    weather_snapshot = forecast.to_dict() if forecast else None

    # Fetch top-few reviews for the highest-rated POIs only (cost cap).
    reviews_limit = settings.BRIGHTDATA_MAX_REVIEWS_PER_CYCLE
    per_poi = settings.BRIGHTDATA_REVIEWS_PER_POI
    sorted_pois = sorted(
        pois, key=lambda p: p.rating or 0.0, reverse=True
    )
    review_targets = [
        p for p in sorted_pois if p.url.startswith("http")
    ][: max(1, reviews_limit // max(per_poi, 1))]

    reviews_by_poi: dict[str, list[dict]] = {}
    review_calls_used = 0
    for p in review_targets:
        if review_calls_used + per_poi > reviews_limit:
            break
        try:
            revs = await scrape_gmaps_reviews(p.name, limit=per_poi)
        except Exception as exc:  # noqa: BLE001
            logger.warning("gmaps review fetch failed for %s: %s", p.name, exc)
            revs = []
        review_calls_used += len(revs) if revs else per_poi
        reviews_by_poi[p.place_id] = [r.to_dict() for r in revs]

    result["gmaps"] = {
        "status": "done",
        "pois": [p.to_dict() for p in pois],
        "reviews_by_poi": reviews_by_poi,
        "query": query,
    }
    result["weather_snapshot"] = weather_snapshot
    job.result_summary = result
    flag_modified(job, "result_summary")
    db.commit()
    logger.info(
        "[ADVISORY_STAGE] gmaps_scrape done job_id=%s pois=%d reviews_on=%d",
        job.id,
        len(pois),
        len(reviews_by_poi),
    )


async def _stage_llm_extraction(db: Session, job: AdvisoryJob) -> None:
    """Merge and dedupe insights across all sources."""
    logger.info("[ADVISORY_STAGE] llm_extraction job_id=%s", job.id)
    import hashlib

    result = job.result_summary or {}
    all_insights: list[dict] = []

    for source_key in ("reddit", "tripadvisor", "gmaps"):
        source_data = result.get(source_key, {})
        for item in source_data.get("insights", []):
            item["_source"] = source_key
            all_insights.append(item)

    # Dedupe by (place_name, category, first 100 chars of insight)
    seen_keys: dict[str, dict] = {}
    for item in all_insights:
        place = (item.get("place_name") or "").strip().lower()
        cat = item.get("category", "general_tip")
        body = (item.get("insight") or "")[:100].strip().lower()
        raw = f"{place}|{cat}|{body}"
        dedupe_key = hashlib.sha256(raw.encode()).hexdigest()

        if dedupe_key in seen_keys:
            # Corroboration: increment source count
            seen_keys[dedupe_key]["_source_count"] = seen_keys[dedupe_key].get("_source_count", 1) + 1
            existing_signal = seen_keys[dedupe_key].get("context_signal") or ""
            seen_keys[dedupe_key]["context_signal"] = (
                f"{existing_signal}; also on {item.get('_source', '?')}"
            ).lstrip("; ")
        else:
            item["_dedupe_key"] = dedupe_key
            item["_source_count"] = 1
            seen_keys[dedupe_key] = item

    merged = list(seen_keys.values())
    result["merged_insights"] = merged
    job.result_summary = result
    flag_modified(job, "result_summary")
    db.commit()
    logger.info("[ADVISORY_STAGE] llm_extraction merged %d → %d unique", len(all_insights), len(merged))


async def _stage_scoring(db: Session, job: AdvisoryJob) -> None:
    """Score candidates for delivery.

    Cycle jobs (location_trigger) use the advisory_ranker: hard-filter by
    dedupe/weather/Reddit warnings → soft score → LLM final pick. Those
    picks are persisted as `ranker_picks` in result_summary.

    Pre-trip / on-demand jobs keep the simpler heuristic on Reddit-only
    insights, producing `scored_insights` for legacy delivery behaviour.
    """
    logger.info("[ADVISORY_STAGE] scoring job_id=%s", job.id)
    result = job.result_summary or {}

    if _is_cycle_job(job):
        target = _target_from_plan(job)
        if target is None:
            # Fallback: treat as failed terminal (mark_cycle_outcome wires this).
            result["ranker_picks"] = []
            job.result_summary = result
            flag_modified(job, "result_summary")
            db.commit()
            return

        gmaps_block = result.get("gmaps") or {}
        pois = gmaps_block.get("pois") or []
        reviews_by_poi = gmaps_block.get("reviews_by_poi") or {}
        weather = result.get("weather_snapshot")
        reddit_block = result.get("reddit") or {}
        reddit_insights = reddit_block.get("insights") or []

        # Pull the brain so we know what's already been advised this trip.
        from app.models.trip_advisory_state import TripAdvisoryState
        brain = (
            db.query(TripAdvisoryState)
            .filter(TripAdvisoryState.trip_id == job.trip_id)
            .one_or_none()
        )
        advised_pois = set(brain.advised_poi_place_ids or []) if brain else set()

        from app.services.advisory_ranker import rank_and_pick
        picks = await rank_and_pick(
            pois=pois,
            locality=target.locality or "",
            advised_poi_place_ids=advised_pois,
            reddit_insights=reddit_insights,
            weather=weather,
            user_metadata=target.user_metadata or {},
            trip_metadata=target.trip_metadata or {},
            recent_categories=target.recent_categories or {},
            reviews_by_poi=reviews_by_poi,
        )

        result["ranker_picks"] = [
            {
                "place_id": p.place_id,
                "name": p.name,
                "category": p.category,
                "title": p.title,
                "body": p.body,
                "reason": p.reason,
                "lat": p.lat,
                "lng": p.lng,
                "url": p.url,
                "confidence": p.confidence,
                "source": p.source,
            }
            for p in picks
        ]
        job.result_summary = result
        flag_modified(job, "result_summary")
        db.commit()
        logger.info(
            "[ADVISORY_STAGE] scoring (cycle) done. picks=%d", len(picks)
        )
        return

    # Legacy path for pre_trip / on_demand.
    merged = result.get("merged_insights", [])
    scored = []
    for item in merged:
        source_count = item.get("_source_count", 1)
        has_signal = bool(item.get("context_signal"))
        has_place = bool(item.get("place_name"))

        score = 0.4
        score += min((source_count - 1) * 0.15, 0.3)
        if has_signal:
            score += 0.1
        if has_place:
            score += 0.1
        score = min(score, 1.0)
        item["_confidence_score"] = round(score, 2)
        scored.append(item)

    scored = [s for s in scored if s["_confidence_score"] >= 0.3]
    scored.sort(key=lambda x: x["_confidence_score"], reverse=True)

    result["scored_insights"] = scored
    job.result_summary = result
    flag_modified(job, "result_summary")
    db.commit()
    logger.info("[ADVISORY_STAGE] scoring done. %d insights above threshold", len(scored))


async def _stage_delivery(db: Session, job: AdvisoryJob) -> None:
    """Write TripAdvisory rows.

    Cycle jobs persist one row per ranker pick, each with poi_place_id and
    the weather snapshot captured during gmaps_scrape. Push dispatch goes
    via send_advisory_notification under the Redis-backed per-user
    throttle. Pre-trip / on-demand jobs keep their legacy behaviour.
    """
    logger.info("[ADVISORY_STAGE] delivery job_id=%s", job.id)
    import hashlib
    from sqlalchemy import func as sa_func

    result = job.result_summary or {}
    now = utcnow()
    created_count = 0
    pushed_count = 0
    delivered_categories: list[str] = []
    delivered_advisory_ids: list = []
    delivered_poi_place_ids: list[str] = []

    if _is_cycle_job(job):
        picks = result.get("ranker_picks") or []
        weather_snapshot = result.get("weather_snapshot")
        target = _target_from_plan(job)
        locality_name = target.locality if target else None

        for p in picks:
            body = p.get("body") or ""
            title = p.get("title") or (p.get("name") or "")
            raw = f"{p.get('place_id', '')}|{p.get('category','general_tip')}|{body[:100]}"
            dedupe_key = hashlib.sha256(raw.encode()).hexdigest()

            existing = (
                db.query(TripAdvisory.id)
                .filter(
                    TripAdvisory.trip_id == job.trip_id,
                    TripAdvisory.dedupe_key == dedupe_key,
                )
                .first()
            )
            if existing:
                continue

            confidence = float(p.get("confidence") or 0.5)
            should_push = confidence >= settings.ADVISORY_MIN_CONFIDENCE_PUSH
            # Push throttle is enforced inside send_advisory_notification
            # (Redis INCR) once that service lands in Step 8. For now we
            # mark delivered and let the push service decide; the status
            # flip matches plan semantics.
            advisory = TripAdvisory(
                trip_id=job.trip_id,
                user_id=job.user_id,
                advisory_job_id=job.id,
                category=p.get("category") or "general_tip",
                source=p.get("source") or "combined",
                place_name=p.get("name"),
                place_lat=p.get("lat"),
                place_lng=p.get("lng"),
                title=title[:255] if title else (p.get("name") or locality_name or "Tip"),
                body=body,
                context_signal=p.get("reason"),
                best_for=None,
                confidence_score=confidence,
                source_urls=[p.get("url")] if p.get("url") else None,
                source_count=1,
                dedupe_key=dedupe_key,
                poi_place_id=p.get("place_id"),
                weather_snapshot=weather_snapshot,
                status="delivered" if should_push else "pending",
                observed_at=now,
                delivered_at=now if should_push else None,
            )
            db.add(advisory)
            db.flush()
            created_count += 1
            delivered_advisory_ids.append(advisory.id)
            if advisory.category:
                delivered_categories.append(advisory.category)
            if p.get("place_id"):
                delivered_poi_place_ids.append(p["place_id"])
            if should_push:
                pushed_count += 1
                # Fire push via advisory push path; redis throttle enforced inside.
                try:
                    from app.services.push_service import PushNotificationService
                    push_result = await PushNotificationService(
                        db
                    ).send_advisory_notification(advisory)
                    if push_result.status == "throttled":
                        # Revert delivered → pending if we couldn't actually push.
                        advisory.status = "pending"
                        advisory.delivered_at = None
                        pushed_count -= 1
                except Exception as exc:  # noqa: BLE001
                    logger.warning(
                        "[ADVISORY_STAGE] push failed advisory_id=%s: %s",
                        advisory.id,
                        exc,
                    )

        db.commit()
        logger.info(
            "[ADVISORY_STAGE] delivery (cycle) done. created=%d push_eligible=%d",
            created_count,
            pushed_count,
        )
        # Stash delivery metadata for the terminus hook.
        job.scrape_plan = {
            **(job.scrape_plan or {}),
            "_delivery": {
                "advisory_ids": [str(aid) for aid in delivered_advisory_ids],
                "poi_place_ids": delivered_poi_place_ids,
                "categories": delivered_categories,
                "count": created_count,
            },
        }
        flag_modified(job, "scrape_plan")
        db.commit()
        return

    # Legacy path — pre_trip / on_demand.
    scored = result.get("scored_insights", [])
    one_hour_ago = now - timedelta(hours=1)
    push_count_this_hour = (
        db.query(sa_func.count(TripAdvisory.id))
        .filter(
            TripAdvisory.trip_id == job.trip_id,
            TripAdvisory.status == "delivered",
            TripAdvisory.delivered_at >= one_hour_ago,
        )
        .scalar()
    ) or 0

    for item in scored:
        dedupe_key = item.get("_dedupe_key", "")
        if not dedupe_key:
            continue
        existing = (
            db.query(TripAdvisory.id)
            .filter(
                TripAdvisory.trip_id == job.trip_id,
                TripAdvisory.dedupe_key == dedupe_key,
            )
            .first()
        )
        if existing:
            continue
        confidence = item.get("_confidence_score", 0.5)
        should_push = (
            confidence >= settings.ADVISORY_MIN_CONFIDENCE_PUSH
            and (push_count_this_hour + pushed_count) < settings.ADVISORY_MAX_PER_HOUR
        )
        source_urls = []
        src_url = item.get("_source_url")
        if src_url:
            source_urls.append(src_url)
        advisory = TripAdvisory(
            trip_id=job.trip_id,
            user_id=job.user_id,
            advisory_job_id=job.id,
            category=item.get("category", "general_tip"),
            source=item.get("_source", "reddit"),
            place_name=item.get("place_name"),
            title=item.get("category", "tip").replace("_", " ").title(),
            body=item.get("insight", ""),
            context_signal=item.get("context_signal"),
            best_for=item.get("best_for"),
            confidence_score=confidence,
            source_urls=source_urls or None,
            source_count=item.get("_source_count", 1),
            dedupe_key=dedupe_key,
            status="delivered" if should_push else "pending",
            observed_at=now,
            delivered_at=now if should_push else None,
        )
        db.add(advisory)
        created_count += 1
        if should_push:
            pushed_count += 1
    db.commit()
    logger.info(
        "[ADVISORY_STAGE] delivery done. created=%d pushed=%d (throttle: %d/%d this hour)",
        created_count,
        pushed_count,
        push_count_this_hour + pushed_count,
        settings.ADVISORY_MAX_PER_HOUR,
    )


STAGE_HANDLERS = {
    "route_segmentation": _stage_route_segmentation,
    "reddit_scrape": _stage_reddit_scrape,
    "tripadvisor_scrape": _stage_tripadvisor_scrape,
    "gmaps_scrape": _stage_gmaps_scrape,
    "llm_extraction": _stage_llm_extraction,
    "scoring": _stage_scoring,
    "delivery": _stage_delivery,
}


# ─── Job execution ───────────────────────────────────────────────────────────


async def _mark_cycle_terminus(
    db: Session, job: AdvisoryJob, outcome: str
) -> None:
    """Notify the brain of a cycle-job terminus.

    Outcome values map to TripBrainService.mark_cycle_outcome:
        delivered | no_pick | failed
    For non-cycle jobs this is a no-op. Errors in the brain update are
    logged and swallowed — they must not cascade into the worker loop.
    """
    if not _is_cycle_job(job):
        return

    target = _target_from_plan(job)
    delivery = (job.scrape_plan or {}).get("_delivery") or {}

    try:
        brain_svc = TripBrainService(db)
        await brain_svc.mark_cycle_outcome(
            job.trip_id,
            outcome,
            target=target,
            advisory_ids=None,
            poi_place_ids=delivery.get("poi_place_ids") or [],
            categories_delivered=delivery.get("categories") or [],
        )
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "[ADVISORY_WORKER] mark_cycle_outcome(%s) failed job_id=%s: %s",
            outcome,
            job.id,
            exc,
        )


def _cycle_outcome_for_completed(job: AdvisoryJob) -> str:
    """'delivered' if any advisories were created, else 'no_pick'."""
    delivery = (job.scrape_plan or {}).get("_delivery") or {}
    count = int(delivery.get("count") or 0)
    return "delivered" if count > 0 else "no_pick"


async def run_job_once(db: Session, job: AdvisoryJob) -> None:
    try:
        for i, stage_name in enumerate(STAGE_ORDER):
            db.refresh(job)
            if job.status == "cancel_requested":
                _set_canceled(job)
                db.commit()
                logger.info("[ADVISORY_WORKER] canceled job_id=%s at stage=%s", job.id, stage_name)
                await _mark_cycle_terminus(db, job, "failed")
                return

            job.stage = stage_name
            job.progress = i / len(STAGE_ORDER)
            db.commit()

            handler = STAGE_HANDLERS[stage_name]
            await handler(db, job)

        # All stages complete
        job.status = "completed"
        job.stage = STAGE_ORDER[-1]
        job.progress = 1.0
        job.completed_at = utcnow()
        job.worker_session_id = None
        job.error_code = None
        job.error_message = None
        db.commit()
        logger.info("[ADVISORY_WORKER] completed job_id=%s trip_id=%s", job.id, job.trip_id)
        await _mark_cycle_terminus(db, job, _cycle_outcome_for_completed(job))

    except TerminalJobError as exc:
        _mark_terminal_blocked(db, job, exc.error_code, exc.error_message)
        await _mark_cycle_terminus(db, job, "failed")
    except Exception as exc:
        db.refresh(job)
        if job.status == "cancel_requested":
            _set_canceled(job)
            db.commit()
            await _mark_cycle_terminus(db, job, "failed")
        else:
            _mark_retry_or_fail(db, job, "advisory_crash", str(exc)[:500])
            # Only mark terminus if we've exhausted retries (state == 'failed').
            db.refresh(job)
            if job.status == "failed":
                await _mark_cycle_terminus(db, job, "failed")


# ─── Worker entrypoint ───────────────────────────────────────────────────────


def run_worker_forever() -> None:
    poll_seconds = settings.ADVISORY_WORKER_POLL_SECONDS
    stale_seconds = settings.ADVISORY_WORKER_STALE_SECONDS
    worker_session_id = str(uuid4())
    consecutive_db_failures = 0

    logger.info(
        "[ADVISORY_WORKER] starting session=%s poll=%.1fs stale=%ds",
        worker_session_id, poll_seconds, stale_seconds,
    )

    while True:
        try:
            with SessionLocal() as db:
                recover_orphaned_jobs(db=db, stale_after_seconds=stale_seconds)

            with SessionLocal() as db:
                claimed = claim_next_job(db=db, worker_session_id=worker_session_id)
                if not claimed:
                    consecutive_db_failures = 0
                    time.sleep(poll_seconds)
                    continue

                consecutive_db_failures = 0
                asyncio.run(run_job_once(db=db, job=claimed))

        except Exception as exc:
            consecutive_db_failures += 1
            backoff = min(60, 5 * (2 ** (consecutive_db_failures - 1)))
            logger.error(
                "[ADVISORY_WORKER] loop error #%d (retry in %ds): %s",
                consecutive_db_failures, backoff, exc,
            )
            time.sleep(backoff)


if __name__ == "__main__":
    run_worker_forever()
