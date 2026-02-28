"""
Durable export worker for Phase 6B.

Runs as a separate process from the FastAPI API server.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
import json
import os
import time
from typing import Optional
from uuid import uuid4

import httpx
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.export_job import ExportJob
from app.services.export_renderer import (
    AbstractRemotionRenderer,
    RenderManifest,
    create_renderer_from_env,
)


STAGE_ORDER = [
    "snapshotting",
    "asset_fetch",
    "rendering",
    "encoding",
    "uploading",
    "finalizing",
]
RETRY_BACKOFF_SECONDS = [30, 120, 480]

# Export artifacts are stored under this private Supabase Storage bucket.
EXPORTS_BUCKET = "exports"

# 500 KB hard cap on snapshot payload (defence-in-depth; enforced at creation too).
SNAPSHOT_MAX_BYTES = 500 * 1024


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def backoff_seconds(retry_count: int) -> int:
    index = max(0, min(retry_count - 1, len(RETRY_BACKOFF_SECONDS) - 1))
    return RETRY_BACKOFF_SECONDS[index]


# ─── Stage helpers ──────────────────────────────────────────────────────────


def _validate_snapshot_size(snapshot: dict) -> None:
    """Raise RuntimeError when snapshot exceeds 500 KB (defence-in-depth)."""
    serialized = json.dumps(snapshot, separators=(",", ":"), sort_keys=True)
    size_bytes = len(serialized.encode("utf-8"))
    if size_bytes > SNAPSHOT_MAX_BYTES:
        raise RuntimeError(f"snapshot_too_large:{size_bytes}")


def _extract_media_urls(snapshot: dict) -> list[str]:
    """Walk the snapshot and return all HTTP(S) URL strings under media-like keys."""
    urls: list[str] = []

    def _walk(node: object) -> None:
        if isinstance(node, dict):
            for key, val in node.items():
                if (
                    key in ("url", "photo_url", "video_url")
                    and isinstance(val, str)
                    and val.startswith("http")
                ):
                    urls.append(val)
                else:
                    _walk(val)
        elif isinstance(node, list):
            for item in node:
                _walk(item)

    _walk(snapshot)
    return urls


async def _stage_asset_fetch(
    snapshot: dict,
    _transport: Optional[httpx.AsyncTransport] = None,
) -> None:
    """HEAD all media URLs found in the snapshot.

    Raises RuntimeError('asset_all_404') only when *every* found URL returns
    HTTP 404.  Partial availability is acceptable — the render proceeds and
    missing photos are replaced with the solid-colour fallback in Classic.jsx.
    Network errors and timeouts are treated as "reachable" to avoid
    false-positive failures on transient connectivity issues.
    """
    urls = _extract_media_urls(snapshot)
    if not urls:
        return  # no media in this trip — still renderable

    reachable = 0
    client_kwargs: dict = {"timeout": httpx.Timeout(8.0)}
    if _transport is not None:
        client_kwargs["transport"] = _transport

    async with httpx.AsyncClient(**client_kwargs) as client:
        for url in urls:
            try:
                r = await client.head(url, follow_redirects=True)
                if r.status_code != 404:
                    reachable += 1
            except Exception:
                # Network error or timeout — count as reachable to avoid
                # incorrectly flagging valid-but-slow storage endpoints.
                reachable += 1

    if reachable == 0:
        raise RuntimeError("asset_all_404")


async def _stage_uploading(
    db: Session,
    job: ExportJob,
    _transport: Optional[httpx.AsyncTransport] = None,
) -> None:
    """Upload the rendered MP4 artifact to Supabase Storage.

    Skips gracefully when:
    - SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY are absent (local dev).
    - The local render artifact does not exist on disk (test environments
      using MockRemotionRenderer, which never writes a real file).

    On success, replaces job.output_url with the canonical Supabase object URL
    so that the /download-url endpoint can later issue a signed redirect.

    The optional _transport parameter is for test injection only.
    """
    supabase_url = os.getenv("SUPABASE_URL", "").rstrip("/")
    service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")

    if not supabase_url or not service_role_key:
        # Supabase not configured — local dev without credentials.
        return

    current_url = job.output_url or ""
    if not current_url.startswith("file://"):
        # Already a remote URL (previous retry uploaded successfully) or empty.
        return

    local_path = current_url[len("file://"):]
    if not os.path.isfile(local_path):
        # Artifact not on disk — MockRemotionRenderer in test, or file cleaned up.
        return

    storage_path = f"{job.user_id}/{job.id}.mp4"
    upload_url = f"{supabase_url}/storage/v1/object/{EXPORTS_BUCKET}/{storage_path}"

    with open(local_path, "rb") as fh:
        data = fh.read()

    client_kwargs: dict = {"timeout": httpx.Timeout(120.0)}
    if _transport is not None:
        client_kwargs["transport"] = _transport

    async with httpx.AsyncClient(**client_kwargs) as client:
        response = await client.post(
            upload_url,
            content=data,
            headers={
                "Authorization": f"Bearer {service_role_key}",
                "Content-Type": "video/mp4",
                "x-upsert": "false",
            },
        )

    if response.status_code not in (200, 201):
        raise RuntimeError(
            f"upload_failed:{response.status_code}:{response.text[:200]}"
        )

    job.output_url = (
        f"{supabase_url}/storage/v1/object/{EXPORTS_BUCKET}/{storage_path}"
    )
    db.commit()


# ─── Recovery and claim ─────────────────────────────────────────────────────


def recover_orphaned_jobs(db: Session, stale_after_seconds: int = 300) -> int:
    """Reset stale in-flight jobs so a restarted worker can re-claim them."""
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
            # Preserve user intent: canceled jobs must not re-queue.
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
    """Atomically claim one queued export job using FOR UPDATE SKIP LOCKED."""
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


# ─── Cancel / retry helpers ─────────────────────────────────────────────────


async def _cancel_job(db: Session, job: ExportJob, renderer: AbstractRemotionRenderer) -> None:
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


# ─── Main job runner ─────────────────────────────────────────────────────────


async def run_job_once(db: Session, job: ExportJob, renderer: AbstractRemotionRenderer) -> ExportJob:
    """Execute a single job through all 6 stages."""
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

            if stage == "snapshotting":
                _validate_snapshot_size(job.snapshot_json)

            elif stage == "asset_fetch":
                await _stage_asset_fetch(job.snapshot_json)

            elif stage == "rendering":
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

                    # Race: cancel arrived but renderer already completed — accept artifact.
                    if job.status == "cancel_requested":
                        if render_status.status == "completed":
                            output_path = render_status.output_path or f"/tmp/{render_id}.mp4"
                            job.output_url = job.output_url or f"file://{output_path}"
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
                        db.commit()
                        break
                    if render_status.status in {"failed", "canceled"}:
                        raise RuntimeError(render_status.error or "renderer_failed")

                    await asyncio.sleep(0.05)

            elif stage == "encoding":
                # No-op for local renderer: Remotion produces H.264 MP4 inline.
                pass

            elif stage == "uploading":
                await _stage_uploading(db, job)

            # finalizing: no inline work; job marked completed after the loop.

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

    except Exception as exc:
        _mark_retry_or_fail(
            db=db,
            job=job,
            error_code="render_crash",
            error_message=str(exc),
        )
        db.refresh(job)
        return job


# ─── Managed runner (one renderer per asyncio loop) ─────────────────────────


async def _run_job_once_managed(db: Session, job: ExportJob) -> ExportJob:
    """
    Create a renderer scoped to this event loop, run the job, and guarantee cleanup.

    Each asyncio.run() call spins a fresh event loop.  Constructing the renderer
    here ensures the httpx.AsyncClient is bound to the correct loop and is
    explicitly closed before the loop exits — avoiding transport-reuse errors
    on subsequent asyncio.run() calls.
    """
    renderer = create_renderer_from_env()
    try:
        return await run_job_once(db=db, job=job, renderer=renderer)
    finally:
        await renderer.aclose()


# ─── Worker entrypoint ────────────────────────────────────────────────────────


def run_worker_forever() -> None:
    """Worker process entrypoint for `python -m app.workers.export_worker`."""
    poll_seconds = float(os.getenv("EXPORT_WORKER_POLL_SECONDS", "2"))
    stale_seconds = int(os.getenv("EXPORT_WORKER_STALE_SECONDS", "300"))
    worker_session_id = str(uuid4())

    while True:
        with SessionLocal() as db:
            recover_orphaned_jobs(db=db, stale_after_seconds=stale_seconds)

        with SessionLocal() as db:
            claimed = claim_next_job(db=db, worker_session_id=worker_session_id)
            if not claimed:
                time.sleep(poll_seconds)
                continue

            asyncio.run(_run_job_once_managed(db=db, job=claimed))


if __name__ == "__main__":
    run_worker_forever()
