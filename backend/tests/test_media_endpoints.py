"""
Tests for media API endpoints.

Covers:
- Upload media to a place
- Access control for media detail
- Delete media permissions
"""

from datetime import datetime
from io import BytesIO
from uuid import uuid4

import pytest
from fastapi import HTTPException, status
from PIL import Image

from app.dependencies import get_current_user
from app.models.media import MediaFile
from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.user import User
from app.services import media_service


def override_current_user(user):
    def _override():
        return user
    return _override


def create_trip(db, user_id, title="Trip", visibility="private"):
    trip = Trip(
        user_id=user_id,
        title=title,
        visibility=visibility,
    )
    db.add(trip)
    db.commit()
    db.refresh(trip)
    return trip


def create_place(
    db,
    trip_id,
    user_id,
    name="Place",
    lat=12.9716,
    lng=77.5946,
):
    place = TripPlace(
        trip_id=trip_id,
        user_id=user_id,
        name=name,
        lat=lat,
        lng=lng,
        location=f"SRID=4326;POINT({lng} {lat})",
    )
    db.add(place)
    db.commit()
    db.refresh(place)
    return place


def create_media(
    db,
    user_id,
    place_id,
    file_url="https://example.supabase.co/storage/v1/object/public/photos/user/file.jpg",
    thumbnail_url="https://example.supabase.co/storage/v1/object/public/photos/user/file.jpg?width=200&height=200",
    caption="Sample",
    taken_at=None,
):
    media = MediaFile(
        user_id=user_id,
        trip_place_id=place_id,
        file_url=file_url,
        file_type="photo",
        file_size_bytes=1024,
        mime_type="image/jpeg",
        width=100,
        height=100,
        thumbnail_url=thumbnail_url,
        caption=caption,
        taken_at=taken_at,
    )
    db.add(media)
    db.commit()
    db.refresh(media)
    return media


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


@pytest.fixture(autouse=True)
def mock_storage_service(monkeypatch):
    class FakeStorageService:
        async def upload_file(
            self,
            file,
            bucket,
            user_id,
            is_premium=False,
            allowed_types=None,
            max_size_mb=10,
        ):
            if allowed_types is None:
                allowed_types = ["image/jpeg", "image/png", "image/webp"]
            if file.content_type not in allowed_types:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid file type. Allowed types: {', '.join(allowed_types)}",
                )
            return (
                f"https://example.supabase.co/storage/v1/object/public/"
                f"{bucket}/{user_id}/test.jpg"
            )

        def get_thumbnail_url(self, bucket, file_path, width=200, height=200):
            return (
                f"https://example.supabase.co/storage/v1/object/public/"
                f"{bucket}/{file_path}?width={width}&height={height}"
            )

        def delete_file(self, bucket, file_path):
            return None

    monkeypatch.setattr(media_service, "StorageService", FakeStorageService)


@pytest.fixture
def sample_image_bytes():
    img = Image.new("RGB", (100, 100), color="red")
    buffer = BytesIO()
    img.save(buffer, format="JPEG")
    return buffer.getvalue()


def test_upload_media_success(client, db, test_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id), "caption": "Great view"}

    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 201
    payload = response.json()
    assert payload["user_id"] == str(test_user.id)
    assert payload["trip_place_id"] == str(place.id)
    assert payload["file_url"].startswith(
        "https://example.supabase.co/storage/v1/object/public/photos/"
    )
    assert payload["thumbnail_url"] is not None
    assert payload["width"] == 100
    assert payload["height"] == 100
    assert payload["caption"] == "Great view"


def test_upload_media_unauthorized(client, unauthorized, sample_image_bytes):
    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(uuid4())}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 401


def test_upload_media_place_not_found(client, test_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(uuid4())}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found"


def test_upload_media_not_owner(client, db, test_user, other_user, auth_as, sample_image_bytes):
    trip = create_trip(db, other_user.id)
    place = create_place(db, trip.id, other_user.id)
    auth_as(test_user)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_get_media_owner(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)
    media = create_media(db, test_user.id, place.id)

    response = client.get(f"/api/v1/media/{media.id}")
    assert response.status_code == 200
    assert response.json()["id"] == str(media.id)


def test_get_media_public_non_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="public")
    place = create_place(db, trip.id, test_user.id)
    media = create_media(db, test_user.id, place.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/media/{media.id}")
    assert response.status_code == 200


def test_get_media_private_non_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id, visibility="private")
    place = create_place(db, trip.id, test_user.id)
    media = create_media(db, test_user.id, place.id)

    auth_as(other_user)
    response = client.get(f"/api/v1/media/{media.id}")
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_get_media_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.get(f"/api/v1/media/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Media not found"


def test_delete_media_owner(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)
    media = create_media(db, test_user.id, place.id)

    response = client.delete(f"/api/v1/media/{media.id}")
    assert response.status_code == 204
    remaining = db.query(MediaFile).filter(MediaFile.id == media.id).first()
    assert remaining is None


def test_delete_media_not_owner(client, db, test_user, other_user, auth_as):
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)
    media = create_media(db, test_user.id, place.id)

    auth_as(other_user)
    response = client.delete(f"/api/v1/media/{media.id}")
    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()


def test_delete_media_not_found(client, test_user, auth_as):
    auth_as(test_user)
    response = client.delete(f"/api/v1/media/{uuid4()}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Media not found"
