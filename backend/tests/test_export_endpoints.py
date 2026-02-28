"""
Tests for export control-plane API endpoints.
"""

from datetime import datetime, timezone
from uuid import UUID, uuid4

import pytest

from app.models.export_job import ExportJob
from app.models.trip import Trip


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


def test_get_export_status_enforces_ownership(client, db, test_user, other_user, auth_as):
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/exports/{job.id}")
    assert response.status_code == 403


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
