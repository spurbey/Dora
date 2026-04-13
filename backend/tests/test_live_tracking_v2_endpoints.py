"""
Tests for strict V2 publish ingest and projection endpoints.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timedelta, timezone
from uuid import uuid4

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


def _sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _canonical_hash(value: object) -> str:
    return _sha256_text(json.dumps(value, sort_keys=True, separators=(",", ":"), default=str))


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


def _build_publish_payload(*, client_session_id: str, media_id: str = "media-1") -> dict[str, object]:
    captured = datetime(2026, 4, 12, 10, 0, tzinfo=timezone.utc)
    created = captured - timedelta(seconds=5)
    return {
        "sessions": [
            {
                "session_id": client_session_id,
                "seal_version": 1,
                "control_state": "sealed",
                "stop_server_pending": 0,
                "started_at": (captured - timedelta(minutes=10)).isoformat(),
                "ended_at": captured.isoformat(),
                "device_id": "device-1",
                "stop_client_event_id": "stop-event-1",
                "timezone": "UTC",
                "reason": "done",
            }
        ],
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
                "mime_type": "image/jpeg",
                "bytes_size": 2048,
                "duration_ms": None,
                "width_px": 1080,
                "height_px": 1920,
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


def _bootstrap_publish(
    *,
    client,
    trip_id,
    client_session_id: str,
    client_job_id: str,
    media_manifest: list[dict[str, object]],
    publish_summary: dict[str, object],
):
    start = client.post(
        f"/api/v2/trips/{trip_id}/sessions:start",
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
        f"/api/v2/trips/{trip_id}/sessions/{client_session_id}:stop",
        json={
            "seal_version": 1,
            "stop_client_event_id": "stop-event-1",
            "stopped_at": _iso_now(1),
            "reason": "done",
        },
        headers={"Idempotency-Key": _idem("stop")},
    )
    assert stop.status_code == 200

    publish_start = client.post(
        f"/api/v2/trips/{trip_id}/publish:start",
        json={
            "client_job_id": client_job_id,
            "schema_version": 1,
            "publish_summary": publish_summary,
            "media_manifest": media_manifest,
            "media_manifest_digest": _canonical_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("pstart")},
    )
    assert publish_start.status_code == 200
    body = publish_start.json()
    token = body["publish_token"]

    upload_targets_by_media_id = {
        item["client_media_id"]: item["storage_ref"]
        for item in body.get("upload_targets", [])
    }
    uploaded_media = [
        {
            "client_media_id": item["client_media_id"],
            "storage_ref": upload_targets_by_media_id[item["client_media_id"]],
        }
        for item in media_manifest
    ]
    media_complete = client.post(
        f"/api/v2/trips/{trip_id}/publish:media-complete",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "uploaded_media": uploaded_media,
        },
        headers={"Idempotency-Key": _idem("pmedia")},
    )
    assert media_complete.status_code == 200
    return token


def _upload_payload_chunks(
    *,
    client,
    trip_id,
    publish_token: str,
    client_job_id: str,
    payload_json: str,
    chunk_size_chars: int = 120 * 1024,
):
    total_chunks = max(1, (len(payload_json) + chunk_size_chars - 1) // chunk_size_chars)
    for chunk_index in range(total_chunks):
        chunk_json = payload_json[
            chunk_index * chunk_size_chars : (chunk_index + 1) * chunk_size_chars
        ]
        response = client.post(
            f"/api/v2/trips/{trip_id}/publish:payload-chunk",
            json={
                "publish_token": publish_token,
                "client_job_id": client_job_id,
                "schema_version": 1,
                "chunk_index": chunk_index,
                "total_chunks": total_chunks,
                "chunk_content_hash": _sha256_text(chunk_json),
                "chunk_json": chunk_json,
            },
            headers={"Idempotency-Key": _idem(f"pchunk:{chunk_index}")},
        )
        assert response.status_code == 200


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


def test_v2_publish_start_rejects_when_session_is_active(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Active Session Blocks Publish")
    client_session_id = "active-session"

    start = client.post(
        f"/api/v2/trips/{trip.id}/sessions:start",
        json={
            "client_session_id": client_session_id,
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android"},
        },
        headers={"Idempotency-Key": _idem("start")},
    )
    assert start.status_code == 200

    media_manifest = [
        {
            "client_media_id": "media-1",
            "mime_type": "image/jpeg",
            "size_bytes": 1024,
            "media_content_hash": "mediahash-1",
        }
    ]
    publish_start = client.post(
        f"/api/v2/trips/{trip.id}/publish:start",
        json={
            "client_job_id": "publish:active:1",
            "schema_version": 1,
            "publish_summary": {
                "snapshot_hash": "snapshot-active",
                "session_count": 1,
                "event_count": 0,
                "media_count": 0,
                "point_count": 0,
                "payload_bytes": 0,
            },
            "media_manifest": media_manifest,
            "media_manifest_digest": _canonical_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("pstart")},
    )
    assert publish_start.status_code == 409
    assert publish_start.json()["detail"]["error_code"] == "active_session_present"


def test_v2_publish_token_scope_mismatch_returns_403(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Token Scope Mismatch")
    client_session_id = "scope-session"
    client_job_id = "publish:scope:1"

    client.post(
        f"/api/v2/trips/{trip.id}/sessions:start",
        json={
            "client_session_id": client_session_id,
            "started_at": _iso_now(),
            "timezone": "UTC",
            "device_context": {"platform": "android"},
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

    media_manifest = [
        {
            "client_media_id": "media-1",
            "mime_type": "image/jpeg",
            "size_bytes": 1024,
            "media_content_hash": "mediahash-1",
        }
    ]
    start = client.post(
        f"/api/v2/trips/{trip.id}/publish:start",
        json={
            "client_job_id": client_job_id,
            "schema_version": 1,
            "publish_summary": {
                "snapshot_hash": "snapshot-scope",
                "session_count": 1,
                "event_count": 0,
                "media_count": 0,
                "point_count": 0,
                "payload_bytes": 0,
            },
            "media_manifest": media_manifest,
            "media_manifest_digest": _canonical_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("pstart")},
    )
    assert start.status_code == 200
    token = start.json()["publish_token"]

    mismatch = client.post(
        f"/api/v2/trips/{trip.id}/publish:media-complete",
        json={
            "publish_token": token,
            "client_job_id": "publish:scope:wrong",
            "schema_version": 1,
            "uploaded_media": [],
        },
        headers={"Idempotency-Key": _idem("pmedia")},
    )
    assert mismatch.status_code == 403
    assert mismatch.json()["detail"]["error_code"] == "token_scope_mismatch"


def test_v2_publish_commit_writes_raw_rows_and_projection_reads(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Publish Success")
    client_session_id = "client-session-1"
    client_job_id = "publish:trip-1:1"

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
    publish_start = client.post(
        f"/api/v2/trips/{trip.id}/publish:start",
        json={
            "client_job_id": client_job_id,
            "schema_version": 1,
            "publish_summary": {
                "snapshot_hash": "snapshot-1",
                "session_count": 1,
                "event_count": 1,
                "media_count": 1,
                "point_count": 2,
                "payload_bytes": 2048,
                "started_at": _iso_now(-600),
                "ended_at": _iso_now(),
            },
            "media_manifest": media_manifest,
            "media_manifest_digest": _canonical_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("pstart")},
    )
    assert publish_start.status_code == 200
    start_body = publish_start.json()
    token = start_body["publish_token"]
    storage_ref = start_body["upload_targets"][0]["storage_ref"]

    media_complete = client.post(
        f"/api/v2/trips/{trip.id}/publish:media-complete",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "uploaded_media": [
                {
                    "client_media_id": "media-1",
                    "storage_ref": storage_ref,
                }
            ],
        },
        headers={"Idempotency-Key": _idem("pmedia")},
    )
    assert media_complete.status_code == 200
    assert media_complete.json()["manifest_phase"] == "media_verified"

    payload = _build_publish_payload(client_session_id=client_session_id)
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    payload_chunk = client.post(
        f"/api/v2/trips/{trip.id}/publish:payload-chunk",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "chunk_index": 0,
            "total_chunks": 1,
            "chunk_content_hash": _sha256_text(payload_json),
            "chunk_json": payload_json,
        },
        headers={"Idempotency-Key": _idem("pchunk")},
    )
    assert payload_chunk.status_code == 200
    assert payload_chunk.json()["manifest_phase"] == "chunks_complete"

    commit = client.post(
        f"/api/v2/trips/{trip.id}/publish:commit",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "pcommit:token"},
    )
    assert commit.status_code == 200
    commit_body = commit.json()
    assert commit_body["manifest_status"] == "committed"
    assert commit_body["manifest_phase"] == "finalized"
    assert commit_body["accepted_session_count"] == 1
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


def test_v2_publish_commit_retries_projection_without_duplicate_raw_rows(client, db, test_user, auth_as, monkeypatch):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Projection Retry")
    client_session_id = "retry-session"
    client_job_id = "publish:retry:1"

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

    media_manifest = [
        {
            "client_media_id": "media-1",
            "mime_type": "image/jpeg",
            "size_bytes": 2048,
            "media_content_hash": "mediahash-1",
        }
    ]
    publish_start = client.post(
        f"/api/v2/trips/{trip.id}/publish:start",
        json={
            "client_job_id": client_job_id,
            "schema_version": 1,
            "publish_summary": {
                "snapshot_hash": "snapshot-2",
                "session_count": 1,
                "event_count": 1,
                "media_count": 1,
                "point_count": 2,
                "payload_bytes": 2048,
                "started_at": _iso_now(-600),
                "ended_at": _iso_now(),
            },
            "media_manifest": media_manifest,
            "media_manifest_digest": _canonical_hash(media_manifest),
        },
        headers={"Idempotency-Key": _idem("pstart")},
    )
    token = publish_start.json()["publish_token"]
    storage_ref = publish_start.json()["upload_targets"][0]["storage_ref"]

    client.post(
        f"/api/v2/trips/{trip.id}/publish:media-complete",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "uploaded_media": [{"client_media_id": "media-1", "storage_ref": storage_ref}],
        },
        headers={"Idempotency-Key": _idem("pmedia")},
    )

    payload = _build_publish_payload(client_session_id=client_session_id)
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    client.post(
        f"/api/v2/trips/{trip.id}/publish:payload-chunk",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "chunk_index": 0,
            "total_chunks": 1,
            "chunk_content_hash": _sha256_text(payload_json),
            "chunk_json": payload_json,
        },
        headers={"Idempotency-Key": _idem("pchunk")},
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
        f"/api/v2/trips/{trip.id}/publish:commit",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "pcommit:retry"},
    )
    assert first.status_code == 503
    assert first.json()["detail"]["error_code"] == "projection_retryable"
    assert db.query(TripEventRaw).filter(TripEventRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripMediaRaw).filter(TripMediaRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripRouteRawPoint).filter(TripRouteRawPoint.trip_server_id == trip.id).count() == 2

    second = client.post(
        f"/api/v2/trips/{trip.id}/publish:commit",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": "pcommit:retry"},
    )
    assert second.status_code == 200
    assert second.json()["manifest_status"] == "committed"
    assert db.query(TripEventRaw).filter(TripEventRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripMediaRaw).filter(TripMediaRaw.trip_server_id == trip.id).count() == 1
    assert db.query(TripRouteRawPoint).filter(TripRouteRawPoint.trip_server_id == trip.id).count() == 2

    manifest = db.query(TripCommitManifest).filter(TripCommitManifest.trip_server_id == trip.id).one()
    assert manifest.status == "committed"
    assert manifest.phase == "finalized"


def test_v2_timeline_cursor_pagination_is_stable(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Timeline Cursor Pagination")
    client_session_id = "cursor-session"
    client_job_id = "publish:cursor:1"

    payload = _build_publish_payload(client_session_id=client_session_id)
    base_captured = datetime(2026, 4, 12, 10, 0, tzinfo=timezone.utc)
    payload["events"] = [
        {
            **payload["events"][0],
            "event_id": "event-1",
            "event_seq": 1,
            "captured_at": (base_captured + timedelta(seconds=0)).isoformat(),
            "created_at": (base_captured - timedelta(seconds=5)).isoformat(),
            "updated_at": (base_captured + timedelta(seconds=0)).isoformat(),
        },
        {
            **payload["events"][0],
            "event_id": "event-2",
            "event_seq": 2,
            "captured_at": (base_captured + timedelta(seconds=10)).isoformat(),
            "created_at": (base_captured + timedelta(seconds=4)).isoformat(),
            "updated_at": (base_captured + timedelta(seconds=10)).isoformat(),
            "payload_json": {"note": "Second"},
            "place_bind_name": "Second Place",
        },
        {
            **payload["events"][0],
            "event_id": "event-3",
            "event_seq": 3,
            "captured_at": (base_captured + timedelta(seconds=20)).isoformat(),
            "created_at": (base_captured + timedelta(seconds=14)).isoformat(),
            "updated_at": (base_captured + timedelta(seconds=20)).isoformat(),
            "payload_json": {"note": "Third"},
            "place_bind_name": "Third Place",
        },
    ]
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))

    media_manifest = [
        {
            "client_media_id": "media-1",
            "mime_type": "image/jpeg",
            "size_bytes": 2048,
            "media_content_hash": "mediahash-1",
        }
    ]
    publish_summary = {
        "snapshot_hash": "snapshot-cursor",
        "session_count": 1,
        "event_count": len(payload["events"]),
        "media_count": len(payload["media"]),
        "point_count": len(payload["route_points"]),
        "payload_bytes": len(payload_json.encode("utf-8")),
        "started_at": _iso_now(-600),
        "ended_at": _iso_now(),
    }
    token = _bootstrap_publish(
        client=client,
        trip_id=trip.id,
        client_session_id=client_session_id,
        client_job_id=client_job_id,
        media_manifest=media_manifest,
        publish_summary=publish_summary,
    )

    _upload_payload_chunks(
        client=client,
        trip_id=trip.id,
        publish_token=token,
        client_job_id=client_job_id,
        payload_json=payload_json,
    )

    commit = client.post(
        f"/api/v2/trips/{trip.id}/publish:commit",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": _idem("pcommit")},
    )
    assert commit.status_code == 200

    first_page = client.get(f"/api/v2/trips/{trip.id}/timeline", params={"limit": 2})
    assert first_page.status_code == 200
    first_body = first_page.json()
    assert len(first_body["entries"]) == 2
    assert first_body["has_more"] is True
    assert first_body["next_cursor"]

    second_page = client.get(
        f"/api/v2/trips/{trip.id}/timeline",
        params={"limit": 2, "cursor": first_body["next_cursor"]},
    )
    assert second_page.status_code == 200
    second_body = second_page.json()
    assert len(second_body["entries"]) == 1
    assert second_body["has_more"] is False
    assert second_body["next_cursor"] is None

    all_entries = first_body["entries"] + second_body["entries"]
    captured_and_ids = [(entry["captured_at"], entry["entry_id"]) for entry in all_entries]
    assert captured_and_ids == sorted(captured_and_ids)


def test_v2_route_response_is_bounded_to_max_points(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Route Bound")
    client_session_id = "route-bound-session"
    client_job_id = "publish:route-bound:1"

    base = datetime(2026, 4, 12, 10, 0, tzinfo=timezone.utc)
    route_points: list[dict[str, object]] = []
    for idx in range(6001):
        route_points.append(
            {
                "point_id": f"pt-{idx+1}",
                "session_id": client_session_id,
                "captured_at": (base + timedelta(seconds=idx)).isoformat(),
                "latitude": 27.7172 + (idx * 0.000001),
                "longitude": 85.3240 + (idx * 0.000001),
                "accuracy_m": 5.0,
                "speed_mps": 1.0,
                "bearing_deg": 45.0,
                "altitude_m": 1300.0,
                "source": "device_gps",
                "point_seq": idx + 1,
            }
        )

    payload = {
        "sessions": [
            {
                "session_id": client_session_id,
                "seal_version": 1,
                "control_state": "sealed",
                "stop_server_pending": 0,
                "started_at": (base - timedelta(minutes=10)).isoformat(),
                "ended_at": (base + timedelta(seconds=6001)).isoformat(),
                "device_id": "device-1",
                "stop_client_event_id": "stop-event-1",
                "timezone": "UTC",
                "reason": "done",
            }
        ],
        "events": [],
        "media": [],
        "route_points": route_points,
    }
    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    publish_summary = {
        "snapshot_hash": "snapshot-route-bound",
        "session_count": 1,
        "event_count": 0,
        "media_count": 0,
        "point_count": len(route_points),
        "payload_bytes": len(payload_json.encode("utf-8")),
        "started_at": (base - timedelta(minutes=10)).isoformat(),
        "ended_at": (base + timedelta(seconds=6001)).isoformat(),
    }

    token = _bootstrap_publish(
        client=client,
        trip_id=trip.id,
        client_session_id=client_session_id,
        client_job_id=client_job_id,
        media_manifest=[],
        publish_summary=publish_summary,
    )

    _upload_payload_chunks(
        client=client,
        trip_id=trip.id,
        publish_token=token,
        client_job_id=client_job_id,
        payload_json=payload_json,
    )

    commit = client.post(
        f"/api/v2/trips/{trip.id}/publish:commit",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
        },
        headers={"Idempotency-Key": _idem("pcommit")},
    )
    assert commit.status_code == 200

    route = client.get(f"/api/v2/trips/{trip.id}/route", params={"limit_segments": 1})
    assert route.status_code == 200
    route_body = route.json()
    assert len(route_body["segments"]) == 1
    segment = route_body["segments"][0]
    assert segment["raw_point_count"] == 6001
    assert segment["point_count"] <= 5000
    assert segment["is_simplified"] is True


def test_v2_publish_payload_chunk_rejects_index_out_of_range(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_v2_trip(db, test_user.id, title="Chunk Index Guard")
    client_session_id = "chunk-index-session"
    client_job_id = "publish:chunk-index:1"

    token = _bootstrap_publish(
        client=client,
        trip_id=trip.id,
        client_session_id=client_session_id,
        client_job_id=client_job_id,
        media_manifest=[],
        publish_summary={
            "snapshot_hash": "snapshot-chunk-index",
            "session_count": 1,
            "event_count": 0,
            "media_count": 0,
            "point_count": 0,
            "payload_bytes": 2,
            "started_at": _iso_now(-60),
            "ended_at": _iso_now(),
        },
    )

    invalid_chunk = client.post(
        f"/api/v2/trips/{trip.id}/publish:payload-chunk",
        json={
            "publish_token": token,
            "client_job_id": client_job_id,
            "schema_version": 1,
            "chunk_index": 1,
            "total_chunks": 1,
            "chunk_content_hash": _sha256_text("{}"),
            "chunk_json": "{}",
        },
        headers={"Idempotency-Key": _idem("pchunk")},
    )
    assert invalid_chunk.status_code == 422
    assert invalid_chunk.json()["detail"]["error_code"] == "invalid_payload"
