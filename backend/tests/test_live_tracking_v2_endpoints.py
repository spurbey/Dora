"""
Tests for strict V2 ingest and projection endpoints.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from app.models.trip import Trip
from app.models.trip_commit_manifest import TripCommitManifest
from app.models.trip_event_raw import TripEventRaw
from app.models.trip_media_raw import TripMediaRaw
from app.models.trip_route_raw_point import TripRouteRawPoint
from app.models.trip_session_raw import TripSessionRaw
from app.services.live_tracking_v2_service import LiveTrackingV2Service


def _iso_now(offset_seconds: int = 0) -> str:
    return (datetime.now(timezone.utc) + timedelta(seconds=offset_seconds)).isoformat()


def _idem(prefix: str) -> str:
    return f"{prefix}:{uuid4().hex}"


def _json_hash(value: object) -> str:
    return hashlib.sha256(
        json.dumps(value, sort_keys=True, separators=(",", ":"), default=str).encode("utf-8")
    ).hexdigest()


def create_v2_trip(db, user_id, title="V2 Trip"):
    trip = Trip(
        id=uuid4(),
        user_id=user_id,
        title=title,
        visibility="private",
        status="planned",
        tracking_enabled=True,
        v2_backend_enabled=True,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def _build_snapshot_payload(*, client_session_id: str, media_id: str = "media-1") -> dict[str, object]:
    captured = datetime(2026, 4, 12, 10, 0, tzinfo=timezone.utc)
    created = captured - timedelta(seconds=5)
    return {
        "session_id": client_session_id,
        "seal_version": 1,
        "control_state": "sealed",
        "stop_server_pending": 0,
        "started_at": (captured - timedelta(minutes=10)).isoformat(),
        "ended_at": captured.isoformat(),
        "device_id": "device-1",
        "stop_client_event_id": "stop-event-1",
        "events": [
            {
                "event_id": "event-1",
                "session_id": client_session_id,
                "captured_at": captured.isoformat(),
                "event_type": "note",
                "latitude": 27.7172,
                "longitude": 85.3240,
                "payload_json": {"note": "Reached the ridge"},
                "resolver_state": "place_bound",
                "decision_source": "user_manual_place",
                "manual_lock": 1,
                "place_bind_kind": "trip_place_local",
                "place_bind_id": "tp-1",
                "place_bind_name": "View Point",
                "geotag_final_reason": None,
                "captured_while_paused": 0,
                "candidate_set_version": 1,
                "resolved_at": captured.isoformat(),
                "event_seq": 1,
                "created_at": created.isoformat(),
                "updated_at": captured.isoformat(),
            }
        ],
        "media": [
            {
                "media_id": media_id,
                "session_id": client_session_id,
                "event_id": "event-1",
                "captured_at": captured.isoformat(),
                "media_type": "photo",
                "local_uri": "/tmp/photo.jpg",
                "mime_type": "image/jpeg",
                "bytes_size": 2048,
                "duration_ms": None,
                "width_px": 1080,
                "height_px": 1920,
                "upload_state": "local_only",
                "upload_ref": None,
                "created_at": created.isoformat(),
                "updated_at": captured.isoformat(),
            }
        ],
        "route_points": [
            {
                "point_id": "point-1",
                "session_id": client_session_id,
                "captured_at": (captured - timedelta(minutes=1)).isoformat(),
                "latitude": 27.7170,
                "longitude": 85.3238,
                "accuracy_m": 5.0,
                "speed_mps": 1.0,
                "bearing_deg": 45.0,
                "altitude_m": 1300.0,
                "source": "device_gps",
                "point_seq": 1,
            },
            {
                "point_id": "point-2",
                "session_id": client_session_id,
                "captured_at": captured.isoformat(),
                "latitude": 27.7172,
                "longitude": 85.3240,
                "accuracy_m": 4.0,
                "speed_mps": 0.2,
                "bearing_deg": 60.0,
                "altitude_m": 1302.0,
                "source": "device_gps",
                "point_seq": 2,
            },
        ],
    }


def test_v2_endpoints_require_idempotency_key(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Missing Key")

    response = client.post(
        f"/api/v2/trips/{trip.id}/sessions:start",
        json={
            "client_session_id": "session-1",
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android"},
        },
    )

    assert response.status_code == 400
    assert response.json()["detail"]["error_code"] == "invalid_payload"


def test_v2_finalize_commit_writes_raw_rows_and_projection_reads(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Finalize Success")
    client_session_id = "client-session-1"

    start = client.post(
        f"/api/v2/trips/{trip.id}/sessions:start",
        json={
            "client_session_id": client_session_id,
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android", "device_id": "pixel-8"},
        },
        headers={"Idempotency-Key": _idem("start")},
    )
    assert start.status_code == 200

    stop = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}:stop",
        json={
            "seal_version": 1,
            "stop_client_event_id": "stop-event-1",
            "stopped_at": _iso_now(1),
            "reason": "done",
        },
        headers={"Idempotency-Key": _idem("stop")},
    )
    assert stop.status_code == 200
    assert stop.json()["status"] == "sealed"

    media_manifest = [
        {
            "client_media_id": "media-1",
            "mime_type": "image/jpeg",
            "size_bytes": 2048,
            "media_content_hash": "mediahash-1",
        }
    ]
    finalize_start = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:start",
        json={
            "client_job_id": "commit:client-session-1:1",
            "schema_version": 1,
            "session_summary": {
                "snapshot_hash": "snapshot-1",
                "event_count": 1,
                "media_count": 1,
                "point_count": 2,
                "payload_bytes": 2048,
                "started_at": _iso_now(-600),
                "ended_at": _iso_now(),
            },
            "media_manifest": media_manifest,
            "media_manifest_digest": _json_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("fstart")},
    )
    assert finalize_start.status_code == 200
    start_body = finalize_start.json()
    token = start_body["session_commit_token"]
    storage_ref = start_body["upload_targets"][0]["storage_ref"]

    media_complete = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:media-complete",
        json={
            "session_commit_token": token,
            "uploaded_media": [
                {
                    "client_media_id": "media-1",
                    "storage_ref": storage_ref,
                }
            ],
        },
        headers={"Idempotency-Key": _idem("fmedia")},
    )
    assert media_complete.status_code == 200
    assert media_complete.json()["manifest_phase"] == "media_verified"

    payload = _build_snapshot_payload(client_session_id=client_session_id)
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    payload_chunk = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:payload-chunk",
        json={
            "session_commit_token": token,
            "chunk_index": 0,
            "total_chunks": 1,
            "chunk_content_hash": _json_hash(payload_json),
            "chunk_json": payload_json,
        },
        headers={"Idempotency-Key": _idem("fchunk")},
    )
    assert payload_chunk.status_code == 200
    assert payload_chunk.json()["manifest_phase"] == "chunks_complete"

    commit = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:commit",
        json={
            "session_commit_token": token,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "fcommit:token"},
    )
    assert commit.status_code == 200
    commit_body = commit.json()
    assert commit_body["manifest_status"] == "committed"
    assert commit_body["manifest_phase"] == "finalized"
    assert commit_body["accepted_event_count"] == 1
    assert commit_body["accepted_media_count"] == 1
    assert commit_body["accepted_point_count"] == 2

    assert db.query(TripSessionRaw).filter(TripSessionRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripEventRaw).filter(TripEventRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripMediaRaw).filter(TripMediaRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripRouteRawPoint).filter(TripRouteRawPoint.trip_server_id == trip.id).count() == 2

    timeline = client.get(f"/api/v2/trips/{trip.id}/timeline", params={"limit": 10})
    assert timeline.status_code == 200
    timeline_body = timeline.json()
    assert len(timeline_body["entries"]) == 1
    assert timeline_body["entries"][0]["title"] == "View Point"
    assert timeline_body["entries"][0]["bucket_type"] == "place"

    route = client.get(f"/api/v2/trips/{trip.id}/route", params={"limit_segments": 10})
    assert route.status_code == 200
    route_body = route.json()
    assert len(route_body["segments"]) == 1
    assert route_body["segments"][0]["raw_point_count"] == 2


def test_v2_finalize_commit_retries_projection_without_duplicate_raw_rows(client, db, test_user, auth_as, monkeypatch):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Projection Retry")
    client_session_id = "retry-session"

    client.post(
        f"/api/v2/trips/{trip.id}/sessions:start",
        json={
            "client_session_id": client_session_id,
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android", "device_id": "pixel-8"},
        },
        headers={"Idempotency-Key": _idem("start")},
    )
    client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}:stop",
        json={
            "seal_version": 1,
            "stop_client_event_id": "stop-event-1",
            "stopped_at": _iso_now(1),
            "reason": "done",
        },
        headers={"Idempotency-Key": _idem("stop")},
    )

    finalize_start = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:start",
        json={
            "client_job_id": "commit:retry-session:1",
            "schema_version": 1,
            "session_summary": {
                "snapshot_hash": "snapshot-2",
                "event_count": 1,
                "media_count": 1,
                "point_count": 2,
                "payload_bytes": 2048,
                "started_at": _iso_now(-600),
                "ended_at": _iso_now(),
            },
            "media_manifest": [
                {
                    "client_media_id": "media-1",
                    "mime_type": "image/jpeg",
                    "size_bytes": 2048,
                    "media_content_hash": "mediahash-1",
                }
            ],
            "media_manifest_digest": _json_hash(
                [
                    {
                        "client_media_id": "media-1",
                        "mime_type": "image/jpeg",
                        "size_bytes": 2048,
                        "media_content_hash": "mediahash-1",
                    }
                ]
            ),
        },
        headers={"Idempotency-Key": _idem("fstart")},
    )
    token = finalize_start.json()["session_commit_token"]
    storage_ref = finalize_start.json()["upload_targets"][0]["storage_ref"]

    client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:media-complete",
        json={
            "session_commit_token": token,
            "uploaded_media": [{"client_media_id": "media-1", "storage_ref": storage_ref}],
        },
        headers={"Idempotency-Key": _idem("fmedia")},
    )

    payload = _build_snapshot_payload(client_session_id=client_session_id)
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:payload-chunk",
        json={
            "session_commit_token": token,
            "chunk_index": 0,
            "total_chunks": 1,
            "chunk_content_hash": _json_hash(payload_json),
            "chunk_json": payload_json,
        },
        headers={"Idempotency-Key": _idem("fchunk")},
    )

    original_compile = LiveTrackingV2Service._compile_trip_projection
    state = {"calls": 0}

    def flaky_compile(self, *, trip_id, user_id):
        state["calls"] += 1
        if state["calls"] == 1:
            raise TimeoutError("projection compile exceeded the 10s timeout")
        return original_compile(self, trip_id=trip_id, user_id=user_id)

    monkeypatch.setattr(LiveTrackingV2Service, "_compile_trip_projection", flaky_compile)

    first = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:commit",
        json={
            "session_commit_token": token,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "fcommit:retry"},
    )
    assert first.status_code == 503
    assert first.json()["detail"]["error_code"] == "projection_retryable"
    assert db.query(TripEventRaw).filter(TripEventRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripMediaRaw).filter(TripMediaRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripRouteRawPoint).filter(TripRouteRawPoint.trip_server_id == trip.id).count() == 2

    second = client.post(
        f"/api/v2/trips/{trip.id}/sessions/{client_session_id}/finalize:commit",
        json={
            "session_commit_token": token,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "fcommit:retry"},
    )
    assert second.status_code == 200
    assert second.json()["manifest_status"] == "committed"
    assert db.query(TripEventRaw).filter(TripEventRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripMediaRaw).filter(TripMediaRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripRouteRawPoint).filter(TripRouteRawPoint.trip_server_id == trip.id).count() == 2

    manifest = db.query(TripCommitManifest).filter(TripCommitManifest.trip_server_id == trip.id).one()
    assert manifest.status == "committed"
    assert manifest.phase == "finalized"
