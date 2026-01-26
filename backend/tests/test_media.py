"""
Tests for media management and place integration.
"""

from io import BytesIO
from uuid import uuid4, UUID
import os

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

            contents = await file.read()
            await file.seek(0)
            file_size = len(contents)

            max_bytes = max_size_mb * 1024 * 1024
            if is_premium:
                max_bytes *= 10

            if file_size > max_bytes:
                tier = "Premium" if is_premium else "Free"
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"{tier} tier file size limit: {max_bytes / 1024 / 1024:.0f}MB. Your file: {file_size / 1024 / 1024:.1f}MB"
                )

            if file_size == 0:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Uploaded file is empty"
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

        def build_thumbnail_url(self, base_url, width=200, height=200):
            separator = "&" if "?" in base_url else "?"
            return f"{base_url}{separator}width={width}&height={height}"

        def get_signed_url(self, bucket, file_path, expires_in=3600):
            return (
                f"https://example.supabase.co/storage/v1/object/sign/"
                f"{bucket}/{file_path}?token=mock&expires_in={expires_in}"
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


def test_upload_photo(client, db, test_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id), "caption": "Great view"}

    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 201
    payload = response.json()
    assert payload["trip_place_id"] == str(place.id)
    assert payload["user_id"] == str(test_user.id)

    updated_place = db.query(TripPlace).filter(TripPlace.id == place.id).first()
    assert str(payload["id"]) in [str(item) for item in updated_place.photos]


def test_upload_invalid_file_type(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.txt", b"hello", "text/plain")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 400
    assert "invalid file type" in response.json()["detail"].lower()


def test_upload_file_too_large(client, db, test_user, auth_as):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    large_bytes = os.urandom(15 * 1024 * 1024)
    files = {"file": ("large.jpg", large_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    assert response.status_code == 400
    assert "file size limit" in response.json()["detail"].lower()


def test_delete_media(client, db, test_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    media_id = response.json()["id"]

    delete_response = client.delete(f"/api/v1/media/{media_id}")
    assert delete_response.status_code == 204

    media_uuid = UUID(media_id)
    remaining = db.query(MediaFile).filter(MediaFile.id == media_uuid).first()
    assert remaining is None

    updated_place = db.query(TripPlace).filter(TripPlace.id == place.id).first()
    assert str(media_id) not in [str(item) for item in updated_place.photos]


def test_delete_media_not_owner(client, db, test_user, other_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    media_id = response.json()["id"]

    auth_as(other_user)
    delete_response = client.delete(f"/api/v1/media/{media_id}")
    assert delete_response.status_code == 403


def test_place_includes_photos(client, db, test_user, auth_as, sample_image_bytes):
    auth_as(test_user)
    trip = create_trip(db, test_user.id)
    place = create_place(db, trip.id, test_user.id)

    files = {"file": ("test.jpg", sample_image_bytes, "image/jpeg")}
    data = {"trip_place_id": str(place.id)}
    response = client.post("/api/v1/media/upload", files=files, data=data)
    media_id = response.json()["id"]

    place_response = client.get(f"/api/v1/places/{place.id}")
    assert place_response.status_code == 200
    data = place_response.json()
    assert data["photos"]
    assert data["photos"][0]["id"] == str(media_id)
    assert "object/sign" in data["photos"][0]["file_url"]
