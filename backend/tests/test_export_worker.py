"""
Tests for export worker claim/retry/cancel/recovery behavior.
"""

import asyncio
from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from app.models.export_job import ExportJob
from app.models.trip import Trip
from app.services.export_renderer import MockRemotionRenderer, RenderStatus
import app.workers.export_worker as export_worker_module
from app.workers.export_worker import (
    backoff_seconds,
    claim_next_job,
    recover_orphaned_jobs,
    run_job_once,
)


@pytest.fixture(autouse=True)
def ensure_export_jobs_table(db):
    ExportJob.__table__.create(bind=db.bind, checkfirst=True)


def _create_trip(db, user_id):
    trip = Trip(
        user_id=user_id,
        title="Worker Trip",
        visibility="private",
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _create_job(db, user_id, trip_id, status="queued"):
    job = ExportJob(
        user_id=user_id,
        trip_id=trip_id,
        status=status,
        stage=None,
        progress=0.0,
        template="classic",
        aspect_ratio="9:16",
        duration_sec=15,
        quality="720p",
        fps=30,
        snapshot_json={"trip": {"id": str(trip_id)}, "config": {"template": "classic"}},
        snapshot_hash=f"snapshot-{uuid4().hex}",
        retry_count=0,
        max_retries=3,
        next_attempt_at=None,
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    return job


def test_claim_next_job_sets_processing_and_session(db, test_user):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="queued")
    job.renderer_job_id = "stale-render-id"
    db.commit()

    claimed = claim_next_job(db=db, worker_session_id="worker-abc")
    assert claimed is not None
    assert claimed.status == "processing"
    assert claimed.stage == "snapshotting"
    assert claimed.worker_session_id == "worker-abc"
    assert claimed.renderer_job_id is None


def test_run_job_once_completes_with_mock_renderer(db, test_user):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="queued")
    claimed = claim_next_job(db=db, worker_session_id="worker-1")
    assert claimed is not None

    result = asyncio.run(run_job_once(db=db, job=claimed, renderer=MockRemotionRenderer()))
    assert result.status == "completed"
    assert result.progress == 1.0
    assert result.output_url is not None
    assert result.completed_at is not None


def test_cancel_requested_becomes_canceled(db, test_user):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="processing")
    job.status = "cancel_requested"
    job.renderer_job_id = "render-123"
    db.commit()
    db.refresh(job)

    result = asyncio.run(run_job_once(db=db, job=job, renderer=MockRemotionRenderer()))
    assert result.status == "canceled"
    assert result.error_code == "canceled_by_user"


def test_recover_orphaned_jobs_requeues_processing_jobs_on_restart(db, test_user, monkeypatch):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="processing")
    job.worker_session_id = "worker-old"
    db.commit()
    db.refresh(job)

    # Simulate stale time without mutating updated_at (trigger-managed).
    stale_now = job.updated_at + timedelta(minutes=20)
    monkeypatch.setattr(export_worker_module, "utcnow", lambda: stale_now)

    recovered = recover_orphaned_jobs(db=db, stale_after_seconds=60)
    assert recovered >= 1

    db.refresh(job)
    assert job.status == "queued"
    assert job.worker_session_id is None
    assert job.next_attempt_at is not None


def test_recover_orphaned_jobs_cancels_stale_cancel_requested_jobs(db, test_user, monkeypatch):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="cancel_requested")
    job.worker_session_id = "worker-old"
    job.renderer_job_id = "render-old"
    db.commit()
    db.refresh(job)

    # Simulate stale time without mutating updated_at (trigger-managed).
    stale_now = job.updated_at + timedelta(minutes=20)
    monkeypatch.setattr(export_worker_module, "utcnow", lambda: stale_now)

    recovered = recover_orphaned_jobs(db=db, stale_after_seconds=60)
    assert recovered >= 1

    db.refresh(job)
    assert job.status == "canceled"
    assert job.worker_session_id is None
    assert job.next_attempt_at is None
    assert job.completed_at is not None


def test_retry_backoff_uses_prd_intervals():
    assert backoff_seconds(1) == 30
    assert backoff_seconds(2) == 120
    assert backoff_seconds(3) == 480
    assert backoff_seconds(7) == 480


class _FailingRenderer(MockRemotionRenderer):
    async def get_status(self, render_id: str) -> RenderStatus:
        return RenderStatus(
            render_id=render_id,
            status="failed",
            progress=1.0,
            error="forced_failure",
        )


def test_run_job_once_requeues_on_retryable_failure(db, test_user):
    trip = _create_trip(db, test_user.id)
    _create_job(db, test_user.id, trip.id, status="queued")
    claimed = claim_next_job(db=db, worker_session_id="worker-retry")
    assert claimed is not None

    result = asyncio.run(run_job_once(db=db, job=claimed, renderer=_FailingRenderer()))
    assert result.status == "queued"
    assert result.retry_count == 1
    assert result.next_attempt_at is not None
    assert result.renderer_job_id is None


class _CancelThenCompleteRenderer(MockRemotionRenderer):
    def __init__(self, db, job):
        super().__init__()
        self._db = db
        self._job = job

    async def get_status(self, render_id: str) -> RenderStatus:
        # Simulate race: cancel request arrives but renderer has already completed.
        self._job.status = "cancel_requested"
        self._db.commit()
        return RenderStatus(
            render_id=render_id,
            status="completed",
            progress=1.0,
            output_path=f"/tmp/{render_id}.mp4",
        )


def test_cancel_requested_race_accepts_completed_artifact(db, test_user):
    trip = _create_trip(db, test_user.id)
    _create_job(db, test_user.id, trip.id, status="queued")
    claimed = claim_next_job(db=db, worker_session_id="worker-race")
    assert claimed is not None

    renderer = _CancelThenCompleteRenderer(db, claimed)
    result = asyncio.run(run_job_once(db=db, job=claimed, renderer=renderer))

    assert result.status == "completed"
    assert result.output_url is not None


def test_late_cancel_after_output_is_set_still_finalizes_completed(db, test_user):
    trip = _create_trip(db, test_user.id)
    job = _create_job(db, test_user.id, trip.id, status="processing")
    job.output_url = "file:///tmp/already-rendered.mp4"
    job.status = "cancel_requested"
    db.commit()
    db.refresh(job)

    result = asyncio.run(run_job_once(db=db, job=job, renderer=MockRemotionRenderer()))
    assert result.status == "completed"
