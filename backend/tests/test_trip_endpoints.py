"""
Tests for trip API endpoints.

Validates:
- Authentication and authorization
- CRUD operations for trips
- Pagination and filtering
- Visibility access control
- Views count behavior
"""

from datetime import date, datetime, timedelta, timezone
from uuid import uuid4

import pytest
from fastapi import HTTPException, status

from app.dependencies import get_current_user
from app.models.trip import Trip
from app.models.user import User


def override_current_user(user):
    def _override():
        return user
    return _override


def create_trip(
    db,
    user_id,
    title="Test Trip",
    description=None,
    start_date=None,
    end_date=None,
    cover_photo_url=None,
    visibility="private",
    views_count=0,
    saves_count=0,
    created_at=None,
    updated_at=None,
):
    trip = Trip(
        user_id=user_id,
        title=title,
        description=description,
        start_date=start_date,
        end_date=end_date,
        cover_photo_url=cover_photo_url,
        visibility=visibility,
        views_count=views_count,
        saves_count=saves_count,
        created_at=created_at,
        updated_at=updated_at,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


@pytest.fixture
def premium_user(db):
    unique_id = str(uuid4())[:8]
    user = User(
        id=uuid4(),
        email=f"premium_{unique_id}@example.com",
        username=f"premium_{unique_id}",
        hashed_password="hashed",
        is_premium=True,
        is_verified=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def other_user(db):
    unique_id = str(uuid4())[:8]
    user = User(
        id=uuid4(),
        email=f"other_{unique_id}@example.com",
        username=f"other_{unique_id}",
        hashed_password="hashed",
        is_premium=False,
        is_verified=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def auth_as(fastapi_app):
    def _set(user):
        fastapi_app.dependency_overrides[get_current_user] = (
            override_current_user(user)
        )
    yield _set
    fastapi_app.dependency_overrides.clear()


@pytest.fixture
def unauthorized(fastapi_app):
    def _override():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )
    fastapi_app.dependency_overrides[get_current_user] = _override
    yield
    fastapi_app.dependency_overrides.clear()


def test_create_trip_success(client, db, test_user, auth_as):
    auth_as(test_user)

    payload = {
        "title": "My First Trip",
        "description": "A wonderful journey",
        "start_date": "2025-02-01",
        "end_date": "2025-02-15",
        "visibility": "private",
    }

    response = client.post("/api/v1/trips", json=payload)
    assert response.status_code == 201

    data = response.json()
    assert data["user_id"] == str(test_user.id)
    assert data["title"] == "My First Trip"
    assert data["views_count"] == 0
    assert data["saves_count"] == 0
    assert data["created_at"] is not None
    assert data["updated_at"] is not None


def test_create_trip_with_all_fields(client, test_user, auth_as):
    auth_as(test_user)

    payload = {
        "title": "Full Trip",
        "description": "All fields set",
        "start_date": "2025-03-01",
        "end_date": "2025-03-10",
        "cover_photo_url": "https://example.com/photo.jpg",
        "visibility": "public",
    }

    response = client.post("/api/v1/trips", json=payload)
    assert response.status_code == 201

    data = response.json()
    assert data["description"] == "All fields set"
    assert data["start_date"] == "2025-03-01"
    assert data["end_date"] == "2025-03-10"
    assert data["cover_photo_url"] == "https://example.com/photo.jpg"
    assert data["visibility"] == "public"


def test_create_trip_premium_user(client, premium_user, auth_as):
    auth_as(premium_user)

    payload = {"title": "Premium Trip"}
    response = client.post("/api/v1/trips", json=payload)

    assert response.status_code == 201
    assert response.json()["user_id"] == str(premium_user.id)


def test_create_trip_unauthorized(client, unauthorized):
    response = client.post("/api/v1/trips", json={"title": "No Auth"})
    assert response.status_code == 401


def test_create_trip_free_tier_limit(client, db, test_user, auth_as):
    auth_as(test_user)

    for i in range(3):
        create_trip(db, test_user.id, title=f"Trip {i + 1}")

    response = client.post("/api/v1/trips", json={"title": "Trip 4"})
    assert response.status_code == 403
    assert "Free tier limit" in response.json()["detail"]
    assert "Upgrade to Premium" in response.json()["detail"]


def test_create_trip_invalid_dates(client, test_user, auth_as):
    auth_as(test_user)

    payload = {
        "title": "Invalid Dates",
        "start_date": "2025-01-10",
        "end_date": "2025-01-01",
    }

    response = client.post("/api/v1/trips", json=payload)
    assert response.status_code == 422


def test_create_trip_invalid_visibility(client, test_user, auth_as):
    auth_as(test_user)

    payload = {"title": "Bad Visibility", "visibility": "invalid"}

    response = client.post("/api/v1/trips", json=payload)
    assert response.status_code == 422


def test_list_trips_empty(client, test_user, auth_as):
    auth_as(test_user)

    response = client.get("/api/v1/trips")
    assert response.status_code == 200

    data = response.json()
    assert data["trips"] == []
    assert data["total"] == 0
    assert data["total_pages"] == 0


def test_list_trips_pagination(client, db, test_user, auth_as):
    auth_as(test_user)

    for i in range(25):
        create_trip(db, test_user.id, title=f"Trip {i + 1}")

    response = client.get("/api/v1/trips?page=1&page_size=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["trips"]) == 10
    assert data["total"] == 25
    assert data["page"] == 1
    assert data["page_size"] == 10
    assert data["total_pages"] == 3

    response = client.get("/api/v1/trips?page=3&page_size=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["trips"]) == 5
    assert data["total"] == 25
    assert data["page"] == 3


def test_list_trips_visibility_filter(client, db, test_user, auth_as):
    auth_as(test_user)

    create_trip(db, test_user.id, title="Private 1", visibility="private")
    create_trip(db, test_user.id, title="Private 2", visibility="private")
    create_trip(db, test_user.id, title="Public 1", visibility="public")
    create_trip(db, test_user.id, title="Public 2", visibility="public")
    create_trip(db, test_user.id, title="Public 3", visibility="public")
    create_trip(db, test_user.id, title="Unlisted 1", visibility="unlisted")

    response = client.get("/api/v1/trips?visibility=public")
    assert response.status_code == 200
    data = response.json()
    assert len(data["trips"]) == 3
    assert all(trip["visibility"] == "public" for trip in data["trips"])


def test_list_trips_ordered_by_newest(client, db, test_user, auth_as):
    auth_as(test_user)

    base_time = datetime(2025, 1, 1, tzinfo=timezone.utc)
    create_trip(db, test_user.id, title="Oldest", created_at=base_time)
    create_trip(db, test_user.id, title="Middle", created_at=base_time + timedelta(days=1))
    create_trip(db, test_user.id, title="Newest", created_at=base_time + timedelta(days=2))

    response = client.get("/api/v1/trips")
    assert response.status_code == 200
    titles = [trip["title"] for trip in response.json()["trips"]]
    assert titles[:3] == ["Newest", "Middle", "Oldest"]


def test_list_trips_unauthorized(client, unauthorized):
    response = client.get("/api/v1/trips")
    assert response.status_code == 401


def test_get_trip_owner(client, db, test_user, auth_as):
    auth_as(test_user)

    trip = create_trip(db, test_user.id, title="Owner Trip", views_count=0)

    response = client.get(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == str(trip.id)
    assert data["views_count"] == 0


def test_get_trip_public(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, title="Public Trip", visibility="public")

    auth_as(other_user)
    response = client.get(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["views_count"] == 1


def test_get_trip_unlisted(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, title="Unlisted Trip", visibility="unlisted")

    auth_as(other_user)
    response = client.get(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["views_count"] == 1


def test_get_trip_not_found(client, test_user, auth_as):
    auth_as(test_user)

    response = client.get(f"/api/v1/trips/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Trip not found"


def test_get_trip_private_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, title="Private Trip", visibility="private")

    auth_as(other_user)
    response = client.get(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_get_trip_unauthorized(client, unauthorized):
    response = client.get(f"/api/v1/trips/{uuid4()}")
    assert response.status_code == 401


def test_update_trip_success(client, db, test_user, auth_as):
    auth_as(test_user)

    previous_updated_at = datetime(2025, 1, 1, tzinfo=timezone.utc)
    trip = create_trip(
        db,
        test_user.id,
        title="Old Title",
        description="Old",
        created_at=previous_updated_at,
        updated_at=previous_updated_at,
    )

    payload = {"title": "New Title", "description": "New"}
    response = client.patch(f"/api/v1/trips/{trip.id}", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["title"] == "New Title"
    assert data["description"] == "New"
    assert data["updated_at"] != previous_updated_at.isoformat()


def test_update_trip_partial(client, db, test_user, auth_as):
    auth_as(test_user)

    trip = create_trip(db, test_user.id, title="Trip", visibility="private")

    payload = {"visibility": "public"}
    response = client.patch(f"/api/v1/trips/{trip.id}", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["visibility"] == "public"
    assert data["title"] == "Trip"


def test_update_trip_dates(client, db, test_user, auth_as):
    auth_as(test_user)

    trip = create_trip(
        db,
        test_user.id,
        title="Trip",
        start_date=date(2025, 1, 1),
        end_date=date(2025, 1, 10),
    )

    payload = {"start_date": "2025-01-05", "end_date": "2025-01-15"}
    response = client.patch(f"/api/v1/trips/{trip.id}", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["start_date"] == "2025-01-05"
    assert data["end_date"] == "2025-01-15"


def test_update_trip_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, title="Trip")

    auth_as(other_user)
    response = client.patch(f"/api/v1/trips/{trip.id}", json={"title": "Hack"})
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_update_trip_not_found(client, test_user, auth_as):
    auth_as(test_user)

    response = client.patch(f"/api/v1/trips/{uuid4()}", json={"title": "Nope"})
    assert response.status_code == 404
    assert response.json()["detail"] == "Trip not found"


def test_update_trip_invalid_dates(client, db, test_user, auth_as):
    auth_as(test_user)

    trip = create_trip(
        db,
        test_user.id,
        title="Trip",
        start_date=date(2025, 1, 10),
        end_date=date(2025, 1, 20),
    )

    payload = {"end_date": "2025-01-01"}
    response = client.patch(f"/api/v1/trips/{trip.id}", json=payload)
    assert response.status_code == 400
    assert "end_date must be after or equal to start_date" in response.json()["detail"]


def test_update_trip_unauthorized(client, unauthorized):
    response = client.patch(f"/api/v1/trips/{uuid4()}", json={"title": "No Auth"})
    assert response.status_code == 401


def test_delete_trip_success(client, db, test_user, auth_as):
    auth_as(test_user)

    trip = create_trip(db, test_user.id, title="Trip")
    response = client.delete(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 204

    remaining = db.query(Trip).filter(Trip.id == trip.id).first()
    assert remaining is None


def test_delete_trip_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, title="Trip")

    auth_as(other_user)
    response = client.delete(f"/api/v1/trips/{trip.id}")
    assert response.status_code == 403


def test_delete_trip_not_found(client, test_user, auth_as):
    auth_as(test_user)

    response = client.delete(f"/api/v1/trips/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Trip not found"


def test_delete_trip_unauthorized(client, unauthorized):
    response = client.delete(f"/api/v1/trips/{uuid4()}")
    assert response.status_code == 401
