"""
Tests for export control-plane API endpoints.
"""

from datetime import datetime, timezone
from uuid import UUID, uuid4

import pytest

from app.models.export_job import ExportJob
from app.models.trip import Trip
import app.services.export_service as export_service_module


@pytest.fixture(autouse=True)
def ensure_export_jobs_table(db):
    ExportJob.__table__.create(bind=db.bind, checkfirst=True)


def _create_trip(db, user_id):
    trip = Trip(
        user_id=user_id,
        title="Export Trip",
        visibility="private",
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _create_export_job(
    db,
    user_id,
    trip_id,
    status="queued",
):
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
        snapshot_hash=f"hash-{uuid4().hex}",
        created_at=datetime.now(timezone.utc),
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    return job


def test_create_export_job_success(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    response = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "720p",
            "fps": 30,
        },
    )

    assert response.status_code == 202
    body = response.json()
    assert body["status"] == "queued"
    assert body["progress"] == 0.0
    assert body["stage"] is None
    assert body["job_id"] is not None

    persisted = db.query(ExportJob).filter(ExportJob.id == UUID(body["job_id"])).first()
    assert persisted is not None
    assert persisted.user_id == test_user.id


def test_create_export_duplicate_returns_409(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    first = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "720p",
            "fps": 30,
        },
    )
    assert first.status_code == 202

    duplicate = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "720p",
            "fps": 30,
        },
    )
    assert duplicate.status_code == 409
    body = duplicate.json()
    assert body["detail"]["error"] == "duplicate_job"
    assert body["detail"]["existing_job_id"] == first.json()["job_id"]


def test_create_export_rejects_when_user_active_limit_reached(client, db, test_user, auth_as, monkeypatch):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    monkeypatch.setenv("EXPORT_MAX_CONCURRENT_PER_USER", "2")
    _create_export_job(db, test_user.id, trip.id, status="queued")
    _create_export_job(db, test_user.id, trip.id, status="processing")

    response = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "720p",
            "fps": 30,
        },
    )
    assert response.status_code == 429


def test_create_export_rejects_when_global_queue_cap_reached(client, db, test_user, auth_as, monkeypatch):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    monkeypatch.setenv("EXPORT_GLOBAL_QUEUE_CAP", "1")
    _create_export_job(db, test_user.id, trip.id, status="queued")

    response = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "720p",
            "fps": 30,
        },
    )
    assert response.status_code == 503


def test_create_export_rejects_1080p_for_free_tier(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    response = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 15,
            "quality": "1080p",
            "fps": 30,
        },
    )
    assert response.status_code == 403


def test_create_export_rejects_duration_above_free_tier_limit(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    response = client.post(
        f"/api/v1/trips/{trip.id}/export",
        json={
            "template": "classic",
            "aspect_ratio": "9:16",
            "duration_sec": 16,
            "quality": "720p",
            "fps": 30,
        },
    )
    assert response.status_code == 403


def test_get_export_status_enforces_ownership(client, db, test_user, other_user, auth_as):
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/exports/{job.id}")
    assert response.status_code == 403


def test_get_export_status_includes_render_duration_ms(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="completed")
    job.render_duration_ms = 12345
    db.commit()

    response = client.get(f"/api/v1/exports/{job.id}")
    assert response.status_code == 200
    assert response.json()["render_duration_ms"] == 12345


def test_cancel_queued_export_returns_200(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="queued")

    response = client.post(f"/api/v1/exports/{job.id}/cancel")
    assert response.status_code == 200
    assert response.json()["status"] == "canceled"

    db.refresh(job)
    assert job.status == "canceled"


def test_cancel_processing_export_returns_202(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="processing")

    response = client.post(f"/api/v1/exports/{job.id}/cancel")
    assert response.status_code == 202
    assert response.json()["status"] == "cancel_requested"

    db.refresh(job)
    assert job.status == "cancel_requested"


def test_get_download_url_requires_completed(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="processing")

    response = client.get(f"/api/v1/exports/{job.id}/download-url")
    assert response.status_code == 409


def test_get_share_url_for_completed_job(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="completed")
    job.output_url = "https://storage.example.com/private/output.mp4"
    db.commit()

    response = client.get(f"/api/v1/exports/{job.id}/share")
    assert response.status_code == 200
    body = response.json()
    assert body["share_url"].startswith("https://api.dora.app/api/v1/shares/")
    assert body["ttl_seconds"] == 604800


def test_get_download_url_for_s3_output_generates_presigned_url(
    client, db, test_user, auth_as, monkeypatch
):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="completed")
    job.output_url = "s3://dora-exports-dev/private/user/job/output.mp4"
    db.commit()

    class _FakeS3Client:
        def generate_presigned_url(self, operation_name, Params, ExpiresIn):
            assert operation_name == "get_object"
            assert Params["Bucket"] == "dora-exports-dev"
            assert Params["Key"] == "private/user/job/output.mp4"
            assert ExpiresIn == export_service_module.DOWNLOAD_TTL_SECONDS
            return "https://signed.example.com/download.mp4"

    monkeypatch.setattr(export_service_module.boto3, "client", lambda *args, **kwargs: _FakeS3Client())

    response = client.get(f"/api/v1/exports/{job.id}/download-url")
    assert response.status_code == 200
    body = response.json()
    assert body["download_url"] == "https://signed.example.com/download.mp4"
    assert body["ttl_seconds"] == export_service_module.DOWNLOAD_TTL_SECONDS
