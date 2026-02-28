"""
Durable export worker skeleton for Phase 6A.

Runs as a separate process from FastAPI API server.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
import os
import time
from typing import Optional
from uuid import uuid4

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.export_job import ExportJob
from app.services.export_renderer import MockRemotionRenderer, RenderManifest


STAGE_ORDER = [
    "snapshotting",
    "asset_fetch",
    "rendering",
    "encoding",
    "uploading",
    "finalizing",
]
RETRY_BACKOFF_SECONDS = [30, 120, 480]


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def backoff_seconds(retry_count: int) -> int:
    index = max(0, min(retry_count - 1, len(RETRY_BACKOFF_SECONDS) - 1))
    return RETRY_BACKOFF_SECONDS[index]


def recover_orphaned_jobs(db: Session, stale_after_seconds: int = 300) -> int:
    """
    Reset stale in-flight jobs so a restarted worker can re-claim them.
    """
    cutoff = utcnow() - timedelta(seconds=stale_after_seconds)
    stale_jobs = (
        db.query(ExportJob)
        .filter(ExportJob.status.in_(["processing", "cancel_requested"]))
        .filter(ExportJob.updated_at < cutoff)
        .all()
    )
    if not stale_jobs:
        return 0

    now = utcnow()
    recovered_count = 0
    for job in stale_jobs:
        if job.status == "cancel_requested":
            # Preserve user intent on recovery: canceled jobs must not re-queue.
            job.status = "canceled"
            job.stage = None
            job.progress = 0.0
            job.completed_at = now
            job.worker_session_id = None
            job.renderer_job_id = None
            job.next_attempt_at = None
            job.error_code = "canceled_by_user"
            job.error_message = "Canceled during stale recovery after worker restart"
            recovered_count += 1
            continue

        if job.retry_count < job.max_retries:
            job.status = "queued"
            job.stage = None
            job.progress = 0.0
            job.completed_at = None
            job.worker_session_id = None
            job.renderer_job_id = None
            job.next_attempt_at = now
            job.error_code = "worker_recovered"
            job.error_message = "Recovered after worker restart"
            recovered_count += 1
            continue

        job.status = "failed"
        job.stage = None
        job.progress = 0.0
        job.completed_at = now
        job.worker_session_id = None
        job.renderer_job_id = None
        job.next_attempt_at = None
        job.error_code = "worker_timeout"
        job.error_message = "Marked failed during stale recovery after retry limit reached"
        recovered_count += 1

    db.commit()
    return recovered_count


def claim_next_job(db: Session, worker_session_id: str) -> Optional[ExportJob]:
    """
    Atomically claim one queued export job using FOR UPDATE SKIP LOCKED.
    """
    now = utcnow()
    job = (
        db.query(ExportJob)
        .filter(ExportJob.status == "queued")
        .filter(or_(ExportJob.next_attempt_at.is_(None), ExportJob.next_attempt_at <= now))
        .order_by(ExportJob.created_at.asc())
        .with_for_update(skip_locked=True)
        .first()
    )
    if not job:
        return None

    job.status = "processing"
    job.stage = "snapshotting"
    job.progress = 0.0
    job.started_at = job.started_at or now
    job.worker_session_id = worker_session_id
    # Ensure retries do not accidentally carry a stale renderer ID.
    job.renderer_job_id = None
    job.error_code = None
    job.error_message = None
    db.commit()
    db.refresh(job)
    return job


async def _cancel_job(db: Session, job: ExportJob, renderer: MockRemotionRenderer) -> None:
    if job.renderer_job_id:
        await renderer.cancel(job.renderer_job_id)
    job.status = "canceled"
    job.stage = None
    job.progress = 0.0
    job.completed_at = utcnow()
    job.worker_session_id = None
    job.renderer_job_id = None
    job.next_attempt_at = None
    job.error_code = "canceled_by_user"
    job.error_message = "Export canceled by user request"
    db.commit()


def _mark_retry_or_fail(db: Session, job: ExportJob, error_code: str, error_message: str) -> None:
    now = utcnow()
    next_retry = job.retry_count + 1
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
        job.renderer_job_id = None
        job.completed_at = None
        db.commit()
        return

    job.status = "failed"
    job.progress = 0.0
    job.completed_at = now
    job.worker_session_id = None
    job.renderer_job_id = None
    job.next_attempt_at = None
    db.commit()


async def run_job_once(db: Session, job: ExportJob, renderer: MockRemotionRenderer) -> ExportJob:
    """
    Execute a single job through 6A mock stages.
    """
    started_at = utcnow()
    stage_count = float(len(STAGE_ORDER))

    try:
        for index, stage in enumerate(STAGE_ORDER, start=1):
            db.refresh(job)
            if job.status == "cancel_requested":
                # If output already exists, render completion won the race; finalize.
                if job.output_url:
                    job.status = "processing"
                    job.error_code = None
                    job.error_message = None
                    db.commit()
                    db.refresh(job)
                else:
                    await _cancel_job(db, job, renderer)
                    db.refresh(job)
                    return job

            if job.status != "processing":
                db.refresh(job)
                return job

            job.stage = stage
            job.progress = round((index - 1) / stage_count, 3)
            db.commit()

            if stage == "rendering":
                manifest = RenderManifest(
                    job_id=job.id,
                    template=job.template,
                    aspect_ratio=job.aspect_ratio,
                    quality=job.quality,
                    duration_sec=job.duration_sec,
                    fps=job.fps,
                    snapshot=job.snapshot_json,
                )
                render_id = await renderer.render(manifest)
                job.renderer_job_id = render_id
                db.commit()

                while True:
                    db.refresh(job)
                    render_status = await renderer.get_status(render_id)

                    # Race handling: if cancel was requested but render already
                    # completed, accept the artifact and finalize as completed.
                    if job.status == "cancel_requested":
                        if render_status.status == "completed":
                            output_path = render_status.output_path or f"/tmp/{render_id}.mp4"
                            job.output_url = job.output_url or f"file://{output_path}"
                            # Cancel request arrived too late; continue and finalize completion.
                            job.status = "processing"
                            job.error_code = None
                            job.error_message = None
                            db.commit()
                            break
                        await _cancel_job(db, job, renderer)
                        db.refresh(job)
                        return job

                    job.progress = max(job.progress, min(0.95, 0.2 + render_status.progress * 0.6))
                    db.commit()

                    if render_status.status == "completed":
                        output_path = render_status.output_path or f"/tmp/{render_id}.mp4"
                        job.output_url = job.output_url or f"file://{output_path}"
                        break
                    if render_status.status in {"failed", "canceled"}:
                        raise RuntimeError(render_status.error or "renderer_failed")

                    await asyncio.sleep(0.05)
            else:
                await asyncio.sleep(0.05)

        duration_ms = int((utcnow() - started_at).total_seconds() * 1000)
        job.status = "completed"
        job.stage = "finalizing"
        job.progress = 1.0
        job.completed_at = utcnow()
        job.render_duration_ms = duration_ms
        job.next_attempt_at = None
        job.worker_session_id = None
        job.error_code = None
        job.error_message = None
        db.commit()
        db.refresh(job)
        return job

    except Exception as exc:  # pragma: no cover - explicit branch tested by behavior
        _mark_retry_or_fail(
            db=db,
            job=job,
            error_code="render_crash",
            error_message=str(exc),
        )
        db.refresh(job)
        return job


def run_worker_forever() -> None:
    """
    Worker process entrypoint for `python -m app.workers.export_worker`.
    """
    poll_seconds = float(os.getenv("EXPORT_WORKER_POLL_SECONDS", "2"))
    stale_seconds = int(os.getenv("EXPORT_WORKER_STALE_SECONDS", "300"))
    worker_session_id = str(uuid4())
    renderer = MockRemotionRenderer()

    while True:
        with SessionLocal() as db:
            recover_orphaned_jobs(db=db, stale_after_seconds=stale_seconds)

        with SessionLocal() as db:
            claimed = claim_next_job(db=db, worker_session_id=worker_session_id)
            if not claimed:
                time.sleep(poll_seconds)
                continue

            asyncio.run(run_job_once(db=db, job=claimed, renderer=renderer))


if __name__ == "__main__":
    run_worker_forever()
