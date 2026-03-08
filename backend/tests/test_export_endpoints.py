"""
Tests for export control-plane API endpoints.
"""

from datetime import datetime, timezone
from uuid import UUID, uuid4

import pytest

from app.models.export_job import ExportJob
from app.models.media import MediaFile
from app.models.place import TripPlace
from app.models.route import Route
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


def _create_place(db, user_id, trip_id, *, order_in_trip=0):
    place = TripPlace(
        trip_id=trip_id,
        user_id=user_id,
        name="Eiffel Tower",
        place_type="attraction",
        location="SRID=4326;POINT(2.2945 48.8584)",
        lat=48.8584,
        lng=2.2945,
        order_in_trip=order_in_trip,
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


def _create_media(
    db,
    user_id,
    place_id,
    *,
    file_url="https://cdn.example.com/trip/photo-1.jpg",
    file_type="photo",
    mime_type="image/jpeg",
    thumbnail_url="https://cdn.example.com/trip/photo-1-thumb.jpg",
):
    media = MediaFile(
        user_id=user_id,
        trip_place_id=place_id,
        file_url=file_url,
        file_type=file_type,
        file_size_bytes=123456,
        mime_type=mime_type,
        width=1080,
        height=1920,
        thumbnail_url=thumbnail_url,
    )
    db.add(media)
    db.commit()
    db.refresh(media)
    return media


def _create_route(db, user_id, trip_id, *, start_place_id, end_place_id, order_in_trip=1):
    route = Route(
        trip_id=trip_id,
        user_id=user_id,
        route_geojson={
            "type": "LineString",
            "coordinates": [
                [2.2945, 48.8584],
                [2.3333, 48.8600],
            ],
        },
        start_place_id=start_place_id,
        end_place_id=end_place_id,
        transport_mode="foot",
        route_category="ground",
        order_in_trip=order_in_trip,
        name="Walk",
    )
    db.add(route)
    db.commit()
    db.refresh(route)
    return route


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


def test_create_export_snapshot_contains_trip_content(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    place = _create_place(db, test_user.id, trip.id, order_in_trip=0)
    _create_media(db, test_user.id, place.id)
    _create_route(
        db,
        test_user.id,
        trip.id,
        start_place_id=place.id,
        end_place_id=place.id,
        order_in_trip=1,
    )

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
    job_id = UUID(response.json()["job_id"])
    job = db.query(ExportJob).filter(ExportJob.id == job_id).first()
    assert job is not None

    snapshot = job.snapshot_json
    assert len(snapshot["places"]) == 1
    assert len(snapshot["media"]) == 1
    assert len(snapshot["routes"]) == 1
    assert snapshot["places"][0]["media"][0]["url"] == "https://cdn.example.com/trip/photo-1.jpg"
    assert any(item["component_type"] == "place" for item in snapshot["timeline"])
    assert any(item["component_type"] == "route" for item in snapshot["timeline"])


def test_create_export_snapshot_caps_places_media_and_routes(
    client, db, test_user, auth_as, monkeypatch
):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    place_one = _create_place(db, test_user.id, trip.id, order_in_trip=0)
    place_two = _create_place(db, test_user.id, trip.id, order_in_trip=1)

    _create_media(
        db,
        test_user.id,
        place_one.id,
        file_url="https://cdn.example.com/trip/p1-photo-1.jpg",
    )
    _create_media(
        db,
        test_user.id,
        place_one.id,
        file_url="https://cdn.example.com/trip/p1-photo-2.jpg",
    )
    _create_media(
        db,
        test_user.id,
        place_two.id,
        file_url="https://cdn.example.com/trip/p2-photo-1.jpg",
    )

    first_route = _create_route(
        db,
        test_user.id,
        trip.id,
        start_place_id=place_one.id,
        end_place_id=place_one.id,
        order_in_trip=1,
    )
    _create_route(
        db,
        test_user.id,
        trip.id,
        start_place_id=place_one.id,
        end_place_id=place_one.id,
        order_in_trip=2,
    )

    monkeypatch.setenv("EXPORT_SNAPSHOT_MAX_PLACES", "1")
    monkeypatch.setenv("EXPORT_SNAPSHOT_MAX_MEDIA_PER_PLACE", "1")
    monkeypatch.setenv("EXPORT_SNAPSHOT_MAX_ROUTES", "1")

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
    job_id = UUID(response.json()["job_id"])
    job = db.query(ExportJob).filter(ExportJob.id == job_id).first()
    assert job is not None

    snapshot = job.snapshot_json
    assert len(snapshot["places"]) == 1
    assert snapshot["places"][0]["id"] == str(place_one.id)
    assert len(snapshot["places"][0]["media"]) == 1
    assert len(snapshot["media"]) == 1
    assert len(snapshot["routes"]) == 1
    assert snapshot["routes"][0]["id"] == str(first_route.id)
    assert [item["id"] for item in snapshot["timeline"] if item["component_type"] == "place"] == [
        str(place_one.id)
    ]


def test_create_export_snapshot_prioritizes_photo_media(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    place = _create_place(db, test_user.id, trip.id, order_in_trip=0)

    _create_media(
        db,
        test_user.id,
        place.id,
        file_url="https://cdn.example.com/trip/video-1.mp4",
        file_type="video",
        mime_type="video/mp4",
        thumbnail_url="https://cdn.example.com/trip/video-1-thumb.jpg",
    )
    _create_media(
        db,
        test_user.id,
        place.id,
        file_url="https://cdn.example.com/trip/photo-priority.jpg",
        file_type="photo",
        mime_type="image/jpeg",
    )

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
    job_id = UUID(response.json()["job_id"])
    job = db.query(ExportJob).filter(ExportJob.id == job_id).first()
    assert job is not None

    place_media = job.snapshot_json["places"][0]["media"]
    assert place_media[0]["file_type"] == "photo"
    assert place_media[0]["url"] == "https://cdn.example.com/trip/photo-priority.jpg"


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


def test_create_export_global_cap_counts_processing_jobs(client, db, test_user, auth_as, monkeypatch):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)

    monkeypatch.setenv("EXPORT_GLOBAL_QUEUE_CAP", "1")
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


def test_get_download_url_includes_future_expiry(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = _create_trip(db, test_user.id)
    job = _create_export_job(db, test_user.id, trip.id, status="completed")
    job.output_url = "https://storage.example.com/private/output.mp4"
    db.commit()

    response = client.get(f"/api/v1/exports/{job.id}/download-url")
    assert response.status_code == 200
    body = response.json()
    expires_at = datetime.fromisoformat(body["expires_at"].replace("Z", "+00:00"))
    remaining = (expires_at - datetime.now(timezone.utc)).total_seconds()

    assert body["ttl_seconds"] == export_service_module.DOWNLOAD_TTL_SECONDS
    assert body["download_url"] == "https://storage.example.com/private/output.mp4"
    assert export_service_module.DOWNLOAD_TTL_SECONDS - 20 <= remaining <= export_service_module.DOWNLOAD_TTL_SECONDS + 5
