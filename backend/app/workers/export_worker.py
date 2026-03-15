"""
Durable export worker for Phase 6B.

Runs as a separate process from the FastAPI API server.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
import json
import logging
import os
import time
from typing import Optional
from uuid import uuid4

import httpx
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.config import settings
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

logger = logging.getLogger(__name__)


def _env_float(name: str, default: float) -> float:
    value = os.getenv(name)
    if value is None or value == "":
        return default
    try:
        return float(value)
    except ValueError:
        logger.warning("[EXPORT_FAIL] invalid %s=%s; using default=%s", name, value, default)
        return default


def _env_int(name: str, default: int) -> int:
    value = os.getenv(name)
    if value is None or value == "":
        return default
    try:
        return int(value)
    except ValueError:
        logger.warning("[EXPORT_FAIL] invalid %s=%s; using default=%s", name, value, default)
        return default


def _bootstrap_runtime_env_defaults() -> None:
    """
    Seed process env from Settings for worker/runtime-only reads.

    Export worker code still reads some values via os.getenv() and renderer
    adapter selection is env-based by contract. This bridge keeps behavior
    deterministic when launching the worker without manual `set` commands.
    """
    defaults = {
        "RENDER_BACKEND": settings.RENDER_BACKEND,
        "RENDERER_URL": settings.RENDERER_URL,
        "SUPABASE_URL": settings.SUPABASE_URL,
        "SUPABASE_SERVICE_ROLE_KEY": settings.SUPABASE_SERVICE_ROLE_KEY,
        "EXPORT_WORKER_POLL_SECONDS": str(settings.EXPORT_WORKER_POLL_SECONDS),
        "EXPORT_WORKER_STALE_SECONDS": str(settings.EXPORT_WORKER_STALE_SECONDS),
    }
    if settings.EXPORT_RENDER_POLL_SECONDS > 0:
        defaults["EXPORT_RENDER_POLL_SECONDS"] = str(settings.EXPORT_RENDER_POLL_SECONDS)

    for key, value in defaults.items():
        if value:
            os.environ.setdefault(key, str(value))


class TerminalJobError(Exception):
    """Raised by stage handlers for non-retryable terminal conditions.

    The worker catches this before the generic RuntimeError handler and
    calls _mark_terminal_blocked() instead of _mark_retry_or_fail(), setting
    status='blocked' with the structured error_code from the PRD taxonomy.
    """

    def __init__(self, error_code: str, error_message: str) -> None:
        super().__init__(error_message)
        self.error_code = error_code
        self.error_message = error_message


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def backoff_seconds(retry_count: int) -> int:
    index = max(0, min(retry_count - 1, len(RETRY_BACKOFF_SECONDS) - 1))
    return RETRY_BACKOFF_SECONDS[index]


def _render_poll_seconds() -> float:
    """
    Resolve render poll interval with sane backend-specific defaults.

    Local mode keeps the fast loop from 6B, while Lambda mode defaults to a
    slower cadence to avoid excessive cloud polling and request cost.
    """
    configured = os.getenv("EXPORT_RENDER_POLL_SECONDS")
    if configured:
        try:
            seconds = float(configured)
            if seconds > 0:
                return seconds
        except ValueError:
            logger.warning(
                "[EXPORT_FAIL] invalid EXPORT_RENDER_POLL_SECONDS=%s; using backend default",
                configured,
            )
    elif settings.EXPORT_RENDER_POLL_SECONDS > 0:
        return settings.EXPORT_RENDER_POLL_SECONDS

    backend = (os.getenv("RENDER_BACKEND") or settings.RENDER_BACKEND or "mock").strip().lower()
    return 3.0 if backend == "lambda" else 0.05


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

    Raises TerminalJobError('asset_all_404') only when *every* found URL returns
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
        raise TerminalJobError(
            "asset_all_404",
            "All media assets returned HTTP 404; nothing to render.",
        )


def _resolve_artifact_url(path_value: Optional[str], default_path: str) -> str:
    """Normalize renderer artifact path to persisted URL format."""
    resolved = path_value or default_path
    if resolved.startswith(("s3://", "http://", "https://", "file://")):
        return resolved
    return f"file://{resolved}"


def _resolve_output_url(output_path: Optional[str], render_id: str) -> str:
    return _resolve_artifact_url(output_path, default_path=f"/tmp/{render_id}.mp4")


def _resolve_thumbnail_url(thumbnail_path: Optional[str], render_id: str) -> str:
    return _resolve_artifact_url(thumbnail_path, default_path=f"/tmp/{render_id}.jpg")


async def _stage_uploading(
    db: Session,
    job: ExportJob,
    _transport: Optional[httpx.AsyncTransport] = None,
) -> None:
    """Persist completed video and thumbnail artifacts.

    6D contract:
    - Worker expects renderer to provide both output and thumbnail artifacts.
    - Local mode stores file:// paths and uploads them to Supabase when configured.
    - Lambda mode already writes to S3; worker preserves s3:// paths as-is.
    """
    output_url = job.output_url or ""
    thumbnail_url = job.thumbnail_url or ""
    if not output_url:
        raise RuntimeError("upload_missing_output_url")
    if not thumbnail_url:
        raise RuntimeError("upload_missing_thumbnail_url")

    supabase_url = (os.getenv("SUPABASE_URL") or settings.SUPABASE_URL or "").rstrip("/")
    service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or settings.SUPABASE_SERVICE_ROLE_KEY or ""

    if not supabase_url or not service_role_key:
        # Local dev without credentials: keep renderer-provided paths.
        return

    output_is_file = output_url.startswith("file://")
    thumb_is_file = thumbnail_url.startswith("file://")

    if not output_is_file and not thumb_is_file:
        logger.info(
            "[EXPORT_UPLOAD] skip job_id=%s reason=remote_artifacts output_url=%s thumbnail_url=%s",
            job.id,
            output_url,
            thumbnail_url,
        )
        return

    async def _upload_local_file(
        *,
        local_path: str,
        storage_path: str,
        content_type: str,
    ) -> str:
        if not os.path.isfile(local_path):
            raise RuntimeError(f"upload_artifact_missing:{local_path}")

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
                    "Content-Type": content_type,
                    "x-upsert": "false",
                },
            )
        if response.status_code not in (200, 201):
            raise RuntimeError(f"upload_failed:{response.status_code}:{response.text[:200]}")
        return f"{supabase_url}/storage/v1/object/{EXPORTS_BUCKET}/{storage_path}"

    if output_is_file:
        output_local_path = output_url[len("file://"):]
        logger.info(
            "[EXPORT_UPLOAD] uploading_video job_id=%s source=%s",
            job.id,
            output_url,
        )
        job.output_url = await _upload_local_file(
            local_path=output_local_path,
            storage_path=f"private/{job.user_id}/{job.id}/output.mp4",
            content_type="video/mp4",
        )
        # Persist video upload immediately so retries don't re-upload it.
        db.commit()
        db.refresh(job)

    if thumb_is_file:
        thumbnail_local_path = thumbnail_url[len("file://"):]
        logger.info(
            "[EXPORT_UPLOAD] uploading_thumbnail job_id=%s source=%s",
            job.id,
            thumbnail_url,
        )
        job.thumbnail_url = await _upload_local_file(
            local_path=thumbnail_local_path,
            storage_path=f"private/{job.user_id}/{job.id}/thumbnail.jpg",
            content_type="image/jpeg",
        )
        # Persist thumbnail upload immediately so partial success is retry-safe.
        db.commit()
        db.refresh(job)
    logger.info(
        "[EXPORT_UPLOAD] uploaded job_id=%s output_url=%s thumbnail_url=%s",
        job.id,
        job.output_url,
        job.thumbnail_url,
    )


# --- Recovery and claim ─────────────────────────────────────────────────────


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
    logger.info(
        "[EXPORT_JOB] claimed job_id=%s worker_session=%s retry=%s",
        job.id,
        worker_session_id,
        job.retry_count,
    )
    return job


# ─── Cancel / retry helpers ─────────────────────────────────────────────────


def _set_canceled_state(job: ExportJob, *, error_message: str) -> None:
    job.status = "canceled"
    job.stage = None
    job.progress = 0.0
    job.completed_at = utcnow()
    job.worker_session_id = None
    job.renderer_job_id = None
    job.next_attempt_at = None
    job.error_code = "canceled_by_user"
    job.error_message = error_message


async def _cancel_job(db: Session, job: ExportJob, renderer: AbstractRemotionRenderer) -> None:
    if job.renderer_job_id:
        await renderer.cancel(job.renderer_job_id)
    _set_canceled_state(job, error_message="Export canceled by user request")
    db.commit()


def _mark_retry_or_fail(db: Session, job: ExportJob, error_code: str, error_message: str) -> None:
    db.refresh(job)
    if job.status == "cancel_requested":
        _set_canceled_state(job, error_message="Export canceled by user request")
        db.commit()
        return

    now = utcnow()
    next_retry = job.retry_count + 1
    will_retry = next_retry <= job.max_retries
    logger.error(
        "[EXPORT_FAIL] job_id=%s error_code=%s retry_count=%s will_retry=%s message=%s",
        job.id,
        error_code,
        next_retry,
        will_retry,
        error_message,
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


def _mark_terminal_blocked(
    db: Session, job: ExportJob, error_code: str, error_message: str
) -> None:
    """Set job to the terminal 'blocked' status (non-retryable, per PRD §5 taxonomy)."""
    logger.error(
        "[EXPORT_FAIL] job_id=%s error_code=%s retry_count=%s will_retry=false message=%s",
        job.id,
        error_code,
        job.retry_count,
        error_message,
    )
    job.status = "blocked"
    job.stage = None
    job.progress = 0.0
    job.completed_at = utcnow()
    job.worker_session_id = None
    job.renderer_job_id = None
    job.next_attempt_at = None
    job.error_code = error_code
    job.error_message = error_message
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
                if job.output_url and job.thumbnail_url:
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
            logger.info("[EXPORT_RENDER] stage=%s job_id=%s", stage, job.id)

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
                render_poll_seconds = _render_poll_seconds()

                while True:
                    db.refresh(job)
                    render_status = await renderer.get_status(render_id)

                    # Race: cancel arrived but renderer already completed — accept artifact.
                    if job.status == "cancel_requested":
                        if render_status.status == "completed":
                            if not render_status.output_path:
                                raise RuntimeError("renderer_missing_output_artifact")
                            if not render_status.thumbnail_path:
                                raise RuntimeError("renderer_missing_thumbnail_artifact")
                            job.output_url = job.output_url or _resolve_output_url(
                                render_status.output_path,
                                render_id=render_id,
                            )
                            job.thumbnail_url = job.thumbnail_url or _resolve_thumbnail_url(
                                render_status.thumbnail_path,
                                render_id=render_id,
                            )
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
                        if not render_status.output_path:
                            raise RuntimeError("renderer_missing_output_artifact")
                        if not render_status.thumbnail_path:
                            raise RuntimeError("renderer_missing_thumbnail_artifact")
                        job.output_url = job.output_url or _resolve_output_url(
                            render_status.output_path,
                            render_id=render_id,
                        )
                        job.thumbnail_url = job.thumbnail_url or _resolve_thumbnail_url(
                            render_status.thumbnail_path,
                            render_id=render_id,
                        )
                        db.commit()
                        break
                    if render_status.status in {"failed", "canceled"}:
                        db.refresh(job)
                        if job.status == "cancel_requested":
                            await _cancel_job(db, job, renderer)
                            db.refresh(job)
                            return job
                        raise RuntimeError(render_status.error or "renderer_failed")

                    await asyncio.sleep(render_poll_seconds)

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
        logger.info("[EXPORT_COST] job_id=%s render_ms=%s", job.id, duration_ms)
        db.refresh(job)
        return job

    except TerminalJobError as exc:
        _mark_terminal_blocked(
            db=db,
            job=job,
            error_code=exc.error_code,
            error_message=exc.error_message,
        )
        db.refresh(job)
        return job

    except Exception as exc:
        db.refresh(job)
        if job.status == "cancel_requested":
            await _cancel_job(db, job, renderer)
            db.refresh(job)
            return job
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
    _bootstrap_runtime_env_defaults()
    poll_seconds = _env_float("EXPORT_WORKER_POLL_SECONDS", settings.EXPORT_WORKER_POLL_SECONDS)
    stale_seconds = _env_int("EXPORT_WORKER_STALE_SECONDS", settings.EXPORT_WORKER_STALE_SECONDS)
    worker_session_id = str(uuid4())
    consecutive_db_failures = 0

    logger.info(
        "[EXPORT_WORKER] starting session=%s poll=%.1fs stale=%ds",
        worker_session_id,
        poll_seconds,
        stale_seconds,
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
                asyncio.run(_run_job_once_managed(db=db, job=claimed))

        except Exception as exc:
            consecutive_db_failures += 1
            # Exponential backoff: 5s, 10s, 20s, 40s … capped at 60s
            backoff = min(60, 5 * (2 ** (consecutive_db_failures - 1)))
            logger.error(
                "[EXPORT_WORKER] loop error #%d (retry in %ds): %s",
                consecutive_db_failures,
                backoff,
                exc,
            )
            time.sleep(backoff)


if __name__ == "__main__":
    run_worker_forever()


