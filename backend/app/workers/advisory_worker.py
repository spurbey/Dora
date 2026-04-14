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

from app.config import settings
from app.database import SessionLocal
from app.models.advisory_job import AdvisoryJob
from app.models.trip_advisory import TripAdvisory
from app.models.trip import Trip
from app.models.place import TripPlace


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


# ─── Stage handlers (stubs — wired in Step 8-9) ─────────────────────────────


async def _stage_route_segmentation(db: Session, job: AdvisoryJob) -> None:
    """Segment route into cities/destinations. Build scrape plan from trip data."""
    logger.info("[ADVISORY_STAGE] route_segmentation job_id=%s", job.id)

    trip = db.query(Trip).filter(Trip.id == job.trip_id).first()
    if not trip:
        raise TerminalJobError("trip_not_found", f"Trip {job.trip_id} not found")

    # Gather destination names from trip places
    places = (
        db.query(TripPlace)
        .filter(TripPlace.trip_id == job.trip_id)
        .order_by(TripPlace.order_index.asc())
        .all()
    )
    city_names = []
    for p in places:
        name = getattr(p, "city", None) or getattr(p, "name", None) or ""
        if name and name not in city_names:
            city_names.append(name)

    # Fallback: use trip name/description if no places
    if not city_names:
        city_names = [trip.name or "travel destination"]

    # Build the question from context
    if job.job_type == "on_demand" and job.query_text:
        question = job.query_text
    else:
        question = f"travel tips for {', '.join(city_names[:5])}"

    # Default subreddits
    subs = ["IndiaTravel", "solotravel", "travel"]

    from app.services.scrapers.reddit_scraper import extract_keywords, derive_search_query
    keywords = extract_keywords(question, city_names)

    plan = job.scrape_plan or {}
    plan.update({
        "cities": city_names,
        "question": question,
        "keywords": keywords,
        "search_query": derive_search_query(keywords),
        "subreddits": subs,
        "max_pages": 8,
        "max_depth": 2,
    })
    job.scrape_plan = plan
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
    db.commit()


async def _stage_gmaps_scrape(db: Session, job: AdvisoryJob) -> None:
    """Scrape Google Maps — skip if Bright Data not configured."""
    if not settings.BRIGHTDATA_WS_ENDPOINT:
        logger.info("[ADVISORY_STAGE] gmaps_scrape job_id=%s (skipped — no BRIGHTDATA_WS_ENDPOINT)", job.id)
        result = job.result_summary or {}
        result["gmaps"] = {"status": "skipped_no_config", "insights": []}
        job.result_summary = result
        db.commit()
        return
    logger.info("[ADVISORY_STAGE] gmaps_scrape job_id=%s (stub)", job.id)
    _heartbeat(db, job)
    result = job.result_summary or {}
    result["gmaps"] = {"status": "stub", "insights": []}
    job.result_summary = result
    db.commit()


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
    db.commit()
    logger.info("[ADVISORY_STAGE] llm_extraction merged %d → %d unique", len(all_insights), len(merged))


async def _stage_scoring(db: Session, job: AdvisoryJob) -> None:
    """Assign confidence scores based on source count and context signals."""
    logger.info("[ADVISORY_STAGE] scoring job_id=%s", job.id)

    result = job.result_summary or {}
    merged = result.get("merged_insights", [])

    scored = []
    for item in merged:
        source_count = item.get("_source_count", 1)
        has_signal = bool(item.get("context_signal"))
        has_place = bool(item.get("place_name"))

        # Simple scoring: base 0.4, +0.15 per extra source, +0.1 for signal, +0.1 for named place
        score = 0.4
        score += min((source_count - 1) * 0.15, 0.3)
        if has_signal:
            score += 0.1
        if has_place:
            score += 0.1
        score = min(score, 1.0)

        item["_confidence_score"] = round(score, 2)
        scored.append(item)

    # Filter out very low confidence
    scored = [s for s in scored if s["_confidence_score"] >= 0.3]
    scored.sort(key=lambda x: x["_confidence_score"], reverse=True)

    result["scored_insights"] = scored
    job.result_summary = result
    db.commit()
    logger.info("[ADVISORY_STAGE] scoring done. %d insights above threshold", len(scored))


async def _stage_delivery(db: Session, job: AdvisoryJob) -> None:
    """Write TripAdvisory rows. Push high-confidence ones within hourly throttle."""
    logger.info("[ADVISORY_STAGE] delivery job_id=%s", job.id)
    from sqlalchemy import func as sa_func

    result = job.result_summary or {}
    scored = result.get("scored_insights", [])
    now = utcnow()

    # Check push throttle
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

    created_count = 0
    pushed_count = 0

    for item in scored:
        dedupe_key = item.get("_dedupe_key", "")
        if not dedupe_key:
            continue

        # Skip if advisory with this dedupe_key already exists for this trip
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
        created_count, pushed_count,
        push_count_this_hour + pushed_count, settings.ADVISORY_MAX_PER_HOUR,
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


async def run_job_once(db: Session, job: AdvisoryJob) -> None:
    try:
        for i, stage_name in enumerate(STAGE_ORDER):
            db.refresh(job)
            if job.status == "cancel_requested":
                _set_canceled(job)
                db.commit()
                logger.info("[ADVISORY_WORKER] canceled job_id=%s at stage=%s", job.id, stage_name)
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

    except TerminalJobError as exc:
        _mark_terminal_blocked(db, job, exc.error_code, exc.error_message)
    except Exception as exc:
        db.refresh(job)
        if job.status == "cancel_requested":
            _set_canceled(job)
            db.commit()
        else:
            _mark_retry_or_fail(db, job, "advisory_crash", str(exc)[:500])


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
