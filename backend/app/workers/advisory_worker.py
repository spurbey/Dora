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
    """Segment route into cities, derive keywords. Parse NL intent for on_demand jobs."""
    logger.info("[ADVISORY_STAGE] route_segmentation job_id=%s", job.id)
    # TODO: Fetch trip places/routes from DB, reverse-geocode to cities
    # TODO: For on_demand jobs, call LLM to parse query_text → parsed_filters
    # TODO: Generate scrape_plan (seeds, keywords, extraction instructions)
    job.scrape_plan = job.scrape_plan or {}
    job.scrape_plan["status"] = "stub_segmentation_done"
    db.commit()


async def _stage_reddit_scrape(db: Session, job: AdvisoryJob) -> None:
    """Deep crawl Reddit + LLM extraction."""
    logger.info("[ADVISORY_STAGE] reddit_scrape job_id=%s", job.id)
    _heartbeat(db, job)
    # TODO: Call scraper_reddit logic with keywords from scrape_plan
    result = job.result_summary or {}
    result["reddit"] = {"status": "stub", "insights": []}
    job.result_summary = result
    db.commit()


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
    # TODO: Merge reddit + tripadvisor + gmaps results, dedupe, generate dedupe_keys
    result = job.result_summary or {}
    result["merged_insights"] = []
    job.result_summary = result
    db.commit()


async def _stage_scoring(db: Session, job: AdvisoryJob) -> None:
    """Assign confidence scores, filter below threshold."""
    logger.info("[ADVISORY_STAGE] scoring job_id=%s", job.id)
    # TODO: Score insights by source count, recency, corroboration
    result = job.result_summary or {}
    result["scored_insights"] = []
    job.result_summary = result
    db.commit()


async def _stage_delivery(db: Session, job: AdvisoryJob) -> None:
    """Write TripAdvisory rows. Push only if above confidence threshold and within hourly limit."""
    logger.info("[ADVISORY_STAGE] delivery job_id=%s", job.id)
    # TODO: Create TripAdvisory rows from scored_insights
    # TODO: Check push throttle: SELECT COUNT(*) FROM trip_advisories
    #       WHERE trip_id=X AND status='delivered' AND delivered_at >= now()-1hr
    # TODO: Send push notification for high-confidence advisories
    db.commit()


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
