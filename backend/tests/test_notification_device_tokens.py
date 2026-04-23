"""
Tests for notification device token registration/deactivation endpoints.
"""

from datetime import datetime, timezone

from app.models.user_device_token import UserDeviceToken


def _headers(key: str = "idem-1") -> dict[str, str]:
    return {"Idempotency-Key": key}


def test_register_device_token_creates_row(client, db, test_user, auth_as):
    auth_as(test_user)

    response = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers(),
        json={
            "client_event_id": "evt-1",
            "platform": "android",
            "push_token": "push-token-123",
            "seen_at": "2026-04-23T00:00:00Z",
            "locale": "en-US",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["idempotency_replayed"] is False
    assert payload["token"]["user_id"] == str(test_user.id)
    assert payload["token"]["platform"] == "android"
    assert payload["token"]["is_active"] is True

    row = (
        db.query(UserDeviceToken)
        .filter(UserDeviceToken.push_token == "push-token-123")
        .one_or_none()
    )
    assert row is not None
    assert row.user_id == test_user.id
    assert row.is_active is True


def test_register_device_token_reassigns_existing_owner(client, db, test_user, other_user, auth_as):
    existing = UserDeviceToken(
        user_id=other_user.id,
        platform="android",
        push_token="push-token-transfer",
        is_active=False,
        last_seen_at=datetime(2026, 4, 20, tzinfo=timezone.utc),
        failure_count=2,
    )
    db.add(existing)
    db.commit()

    auth_as(test_user)
    response = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers("idem-2"),
        json={
            "client_event_id": "evt-2",
            "platform": "android",
            "push_token": "push-token-transfer",
            "seen_at": "2026-04-23T01:00:00Z",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["token"]["user_id"] == str(test_user.id)
    assert payload["token"]["is_active"] is True
    assert payload["token"]["failure_count"] == 0

    row = (
        db.query(UserDeviceToken)
        .filter(UserDeviceToken.push_token == "push-token-transfer")
        .one()
    )
    assert row.user_id == test_user.id
    assert row.is_active is True
    assert row.failure_count == 0


def test_deactivate_device_token_marks_row_inactive(client, db, test_user, auth_as):
    row = UserDeviceToken(
        user_id=test_user.id,
        platform="android",
        push_token="push-token-deactivate",
        is_active=True,
        last_seen_at=datetime(2026, 4, 23, tzinfo=timezone.utc),
        failure_count=0,
    )
    db.add(row)
    db.commit()

    auth_as(test_user)
    response = client.post(
        "/api/v1/notifications/device-tokens/deactivate",
        headers=_headers("idem-3"),
        json={
            "client_event_id": "evt-3",
            "push_token": "push-token-deactivate",
            "deactivated_at": "2026-04-23T02:00:00Z",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["idempotency_replayed"] is False
    assert payload["token"]["is_active"] is False

    db.refresh(row)
    assert row.is_active is False


def test_deactivate_device_token_is_noop_when_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.post(
        "/api/v1/notifications/device-tokens/deactivate",
        headers=_headers("idem-4"),
        json={
            "client_event_id": "evt-4",
            "push_token": "missing-token",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["idempotency_replayed"] is False
    assert payload["token"] is None


def test_register_device_token_requires_idempotency_key(client, test_user, auth_as):
    auth_as(test_user)
    response = client.post(
        "/api/v1/notifications/device-tokens/register",
        json={
            "client_event_id": "evt-5",
            "platform": "android",
            "push_token": "push-token-no-header",
        },
    )

    assert response.status_code == 400
    payload = response.json()
    assert payload["detail"]["error_code"] == "invalid_payload"


def test_register_device_token_replays_with_same_idempotency_key(client, db, test_user, auth_as):
    auth_as(test_user)
    payload = {
        "client_event_id": "evt-replay-1",
        "platform": "android",
        "push_token": "push-token-replay",
        "seen_at": "2026-04-23T03:00:00Z",
    }

    first = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers("idem-replay"),
        json=payload,
    )
    second = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers("idem-replay"),
        json=payload,
    )

    assert first.status_code == 200
    assert first.json()["idempotency_replayed"] is False
    assert second.status_code == 200
    assert second.json()["idempotency_replayed"] is True

    rows = (
        db.query(UserDeviceToken)
        .filter(UserDeviceToken.push_token == "push-token-replay")
        .all()
    )
    assert len(rows) == 1


def test_register_device_token_idempotency_conflict(client, test_user, auth_as):
    auth_as(test_user)
    first = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers("idem-conflict"),
        json={
            "client_event_id": "evt-conflict-1",
            "platform": "android",
            "push_token": "push-token-conflict",
            "seen_at": "2026-04-23T04:00:00Z",
        },
    )
    second = client.post(
        "/api/v1/notifications/device-tokens/register",
        headers=_headers("idem-conflict"),
        json={
            "client_event_id": "evt-conflict-2",
            "platform": "android",
            "push_token": "push-token-conflict",
            "seen_at": "2026-04-23T04:05:00Z",
        },
    )

    assert first.status_code == 200
    assert second.status_code == 409
    detail = second.json()["detail"]
    assert detail["error_code"] == "idempotency_conflict"
