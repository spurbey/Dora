from __future__ import annotations

import base64
import json
from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from app.config import settings
from app.models.story import Story
from app.services import story_service


@pytest.fixture(autouse=True)
def mock_story_storage(monkeypatch):
    class FakeStorageService:
        async def upload_file(
            self,
            file,
            bucket,
            user_id,
            is_premium=False,
            allowed_types=None,
            max_size_mb=10,
            contents=None,
            object_key=None,
            cache_control_seconds=None,
        ):
            path = object_key or f"{user_id}/mock.bin"
            return f"https://example.supabase.co/storage/v1/object/public/{bucket}/{path}"

        def get_thumbnail_url(self, bucket, file_path, width=200, height=200):
            return (
                f"https://example.supabase.co/storage/v1/object/public/{bucket}/{file_path}"
                f"?width={width}&height={height}"
            )

        def delete_file(self, bucket, file_path):
            return None

    monkeypatch.setattr(story_service, "StorageService", FakeStorageService)


def _create_story(
    db,
    *,
    author_id,
    center_lat=27.7172,
    center_lng=85.3240,
    status_="published",
    minutes_ago=5,
):
    now = datetime.now(timezone.utc)
    row = Story(
        id=uuid4(),
        client_story_id=str(uuid4()),
        author_user_id=author_id,
        media_type="photo",
        media_url="https://example.supabase.co/storage/v1/object/public/stories/u/1.jpg",
        thumbnail_url="https://example.supabase.co/storage/v1/object/public/stories/u/1.jpg?width=360&height=640",
        center_lat=center_lat,
        center_lng=center_lng,
        status=status_,
        published_at=now - timedelta(minutes=minutes_ago),
        expires_at=now + timedelta(hours=1),
        created_at=now - timedelta(minutes=minutes_ago),
        updated_at=now - timedelta(minutes=minutes_ago),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def _decode_feed_cursor(raw: str) -> dict:
    padded = raw + ("=" * (-len(raw) % 4))
    decoded = base64.urlsafe_b64decode(padded.encode("utf-8")).decode("utf-8")
    payload = json.loads(decoded)
    assert isinstance(payload, dict)
    return payload


def test_publish_story_success_and_idempotent(client, test_user, auth_as):
    auth_as(test_user)
    payload = {
        "client_story_id": "local-story-001",
        "media_type": "photo",
        "center_lat": "27.7172",
        "center_lng": "85.3240",
    }
    file_bytes = b"\xff\xd8\xff\xdbmockjpeg"
    files = {"file": ("story.jpg", file_bytes, "image/jpeg")}

    first = client.post("/api/v1/stories/publish", data=payload, files=files)
    assert first.status_code == 201
    first_body = first.json()
    assert first_body["status"] == "published"
    assert first_body["media_type"] == "photo"

    second = client.post("/api/v1/stories/publish", data=payload, files=files)
    assert second.status_code == 201
    second_body = second.json()
    assert second_body["id"] == first_body["id"]
    assert second_body["client_story_id"] == "local-story-001"


def test_feed_orders_own_first_and_respects_radius(client, db, test_user, other_user, auth_as):
    own = _create_story(db, author_id=test_user.id, center_lat=40.0, center_lng=40.0, minutes_ago=10)
    near = _create_story(db, author_id=other_user.id, center_lat=27.72, center_lng=85.32, minutes_ago=2)
    far = _create_story(db, author_id=other_user.id, center_lat=10.0, center_lng=10.0, minutes_ago=1)

    auth_as(test_user)
    resp = client.get("/api/v1/stories/feed", params={"lat": 27.7172, "lng": 85.3240, "radius_km": "5"})
    assert resp.status_code == 200
    body = resp.json()
    ids = [item["id"] for item in body["stories"]]

    assert str(own.id) == ids[0]
    assert str(near.id) in ids
    assert str(far.id) not in ids


def test_mute_author_excludes_feed(client, db, test_user, other_user, auth_as):
    _create_story(db, author_id=other_user.id, center_lat=27.72, center_lng=85.32)
    auth_as(test_user)

    mute = client.post(f"/api/v1/stories/authors/{other_user.id}/mute")
    assert mute.status_code == 200
    assert mute.json()["muted"] is True

    feed = client.get("/api/v1/stories/feed", params={"radius_km": "all"})
    assert feed.status_code == 200
    assert feed.json()["stories"] == []


def test_delete_story_marks_deleted(client, db, test_user, auth_as):
    row = _create_story(db, author_id=test_user.id)
    auth_as(test_user)
    resp = client.delete(f"/api/v1/stories/{row.id}")
    assert resp.status_code == 200
    assert resp.json()["status"] == "deleted"


def test_moderation_hide_requires_allow_list(client, db, test_user, other_user, auth_as, monkeypatch):
    row = _create_story(db, author_id=other_user.id)
    monkeypatch.setattr(settings, "STORIES_MODERATOR_USER_IDS", str(test_user.id))

    auth_as(other_user)
    denied = client.post(f"/api/v1/stories/{row.id}/moderation-hide")
    assert denied.status_code == 403

    auth_as(test_user)
    allowed = client.post(f"/api/v1/stories/{row.id}/moderation-hide")
    assert allowed.status_code == 200
    assert allowed.json()["status"] == "moderation_hidden"


def test_story_view_is_idempotent_per_viewer(client, db, test_user, other_user, auth_as):
    row = _create_story(db, author_id=other_user.id)

    auth_as(test_user)
    first = client.post(f"/api/v1/stories/{row.id}/view")
    assert first.status_code == 200
    second = client.post(f"/api/v1/stories/{row.id}/view")
    assert second.status_code == 200

    db.refresh(row)
    assert int(row.view_count or 0) == 1
    assert first.json()["view_count"] == 1
    assert second.json()["view_count"] == 1


def test_story_view_counts_are_per_viewer_and_owner_noop(
    client,
    db,
    test_user,
    other_user,
    premium_user,
    auth_as,
):
    row = _create_story(db, author_id=other_user.id)

    auth_as(test_user)
    first = client.post(f"/api/v1/stories/{row.id}/view")
    assert first.status_code == 200

    auth_as(premium_user)
    second = client.post(f"/api/v1/stories/{row.id}/view")
    assert second.status_code == 200

    auth_as(other_user)
    owner = client.post(f"/api/v1/stories/{row.id}/view")
    assert owner.status_code == 200

    db.refresh(row)
    assert int(row.view_count or 0) == 2
    assert first.json()["view_count"] == 1
    assert second.json()["view_count"] == 2
    assert owner.json()["view_count"] == 2


def test_feed_emits_opaque_keyset_cursor(client, db, test_user, other_user, auth_as):
    for minutes_ago in (1, 2, 3, 4):
        _create_story(
            db,
            author_id=other_user.id,
            center_lat=27.72,
            center_lng=85.32,
            minutes_ago=minutes_ago,
        )

    auth_as(test_user)
    resp = client.get("/api/v1/stories/feed", params={"radius_km": "all", "limit": 2})
    assert resp.status_code == 200
    cursor = resp.json()["next_cursor"]
    assert cursor
    assert not cursor.isdigit()

    decoded = _decode_feed_cursor(cursor)
    assert decoded["v"] == 1
    assert decoded["tier"] in (0, 1)
    assert "published_at" in decoded
    assert "id" in decoded


def test_feed_keyset_pagination_has_no_duplicates_or_gaps(
    client,
    db,
    test_user,
    other_user,
    auth_as,
):
    _create_story(db, author_id=test_user.id, center_lat=40.0, center_lng=40.0, minutes_ago=30)
    _create_story(db, author_id=test_user.id, center_lat=40.0, center_lng=40.0, minutes_ago=15)
    for minutes_ago in (1, 2, 3, 4, 5):
        _create_story(
            db,
            author_id=other_user.id,
            center_lat=27.72,
            center_lng=85.32,
            minutes_ago=minutes_ago,
        )

    auth_as(test_user)
    full = client.get("/api/v1/stories/feed", params={"radius_km": "all", "limit": 50})
    assert full.status_code == 200
    expected_ids = [item["id"] for item in full.json()["stories"]]

    seen: list[str] = []
    cursor = None
    while True:
        params = {"radius_km": "all", "limit": 2}
        if cursor:
            params["cursor"] = cursor
        page = client.get("/api/v1/stories/feed", params=params)
        assert page.status_code == 200
        body = page.json()
        page_ids = [item["id"] for item in body["stories"]]
        assert not (set(page_ids) & set(seen))
        seen.extend(page_ids)
        cursor = body["next_cursor"]
        if not cursor:
            break

    assert seen == expected_ids


def test_feed_legacy_numeric_cursor_returns_400(client, db, test_user, other_user, auth_as):
    _create_story(db, author_id=other_user.id, center_lat=27.72, center_lng=85.32, minutes_ago=1)

    auth_as(test_user)
    resp = client.get("/api/v1/stories/feed", params={"radius_km": "all", "cursor": "10"})
    assert resp.status_code == 400
    assert resp.json()["detail"] == "Invalid cursor"


def test_feed_insert_between_pages_preserves_cursor_continuity(
    client,
    db,
    test_user,
    other_user,
    auth_as,
):
    for minutes_ago in (1, 2, 3, 4, 5, 6):
        _create_story(
            db,
            author_id=other_user.id,
            center_lat=27.72,
            center_lng=85.32,
            minutes_ago=minutes_ago,
        )

    auth_as(test_user)
    baseline = client.get("/api/v1/stories/feed", params={"radius_km": "all", "limit": 50})
    assert baseline.status_code == 200
    baseline_ids = [item["id"] for item in baseline.json()["stories"]]

    first = client.get("/api/v1/stories/feed", params={"radius_km": "all", "limit": 3})
    assert first.status_code == 200
    first_body = first.json()
    first_ids = [item["id"] for item in first_body["stories"]]
    cursor = first_body["next_cursor"]
    assert cursor

    inserted = _create_story(
        db,
        author_id=other_user.id,
        center_lat=27.72,
        center_lng=85.32,
        minutes_ago=0,
    )

    second = client.get(
        "/api/v1/stories/feed",
        params={"radius_km": "all", "limit": 3, "cursor": cursor},
    )
    assert second.status_code == 200
    second_ids = [item["id"] for item in second.json()["stories"]]

    expected_remaining = baseline_ids[len(first_ids):]
    assert second_ids == expected_remaining[: len(second_ids)]
    assert str(inserted.id) not in second_ids
