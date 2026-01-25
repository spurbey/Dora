"""
Pytest-based integration tests for Supabase Storage.

Replaces test_storage.py (async script) with pytest-compatible tests.

Run:
    pytest -v
"""

import pytest
import os
from uuid import uuid4
from io import BytesIO

from PIL import Image
from fastapi import UploadFile, HTTPException
from starlette.datastructures import Headers

from app.services.storage_service import StorageService
from app.config import settings


# --------------------------------------------------
# Fixtures
# --------------------------------------------------


@pytest.fixture(scope="session")
def storage_service():
    """
    Provide a shared StorageService instance.
    """
    return StorageService()


@pytest.fixture
def test_user_id():
    """
    Generate a random test user ID.
    """
    return uuid4()


@pytest.fixture
def sample_image_bytes():
    """
    Create a small in-memory JPEG image.
    """
    img = Image.new("RGB", (100, 100), color="red")

    buffer = BytesIO()
    img.save(buffer, format="JPEG")

    return buffer.getvalue()


@pytest.fixture
def upload_image_file(sample_image_bytes):
    """
    Create UploadFile for a valid image.
    """
    return UploadFile(
        file=BytesIO(sample_image_bytes),
        filename="test.jpg",
        headers=Headers({"content-type": "image/jpeg"}),
    )


# --------------------------------------------------
# Helper
# --------------------------------------------------


def extract_file_path(url: str) -> str:
    """
    Extract storage file path from Supabase public URL.
    """
    parts = url.split("/storage/v1/object/public/photos/")

    if len(parts) != 2:
        raise ValueError(f"Unexpected URL format: {url}")

    return parts[1].split("?")[0]


# --------------------------------------------------
# Main Tests
# --------------------------------------------------


@pytest.mark.asyncio
async def test_upload_and_delete(
    storage_service,
    upload_image_file,
    test_user_id,
):
    """
    Test upload → verify → delete flow.
    """

    url = await storage_service.upload_file(
        file=upload_image_file,
        bucket="photos",
        user_id=test_user_id,
        is_premium=False,
    )

    assert url.startswith(settings.SUPABASE_URL)

    file_path = extract_file_path(url)

    # Verify URL
    verify_url = storage_service.get_public_url("photos", file_path)
    assert verify_url == url

    # Delete
    storage_service.delete_file("photos", file_path)


@pytest.mark.asyncio
async def test_thumbnail_url_generation(
    storage_service,
    upload_image_file,
    test_user_id,
):
    """
    Test thumbnail URL generation.
    """

    url = await storage_service.upload_file(
        file=upload_image_file,
        bucket="photos",
        user_id=test_user_id,
    )

    file_path = extract_file_path(url)

    thumb_url = storage_service.get_thumbnail_url(
        bucket="photos",
        file_path=file_path,
        width=200,
        height=200,
    )

    assert "width=200" in thumb_url
    assert "height=200" in thumb_url

    # Cleanup
    storage_service.delete_file("photos", file_path)


# --------------------------------------------------
# Validation Tests
# --------------------------------------------------


@pytest.mark.asyncio
async def test_invalid_file_type_rejected(
    storage_service,
    test_user_id,
):
    """
    Ensure non-image files are rejected.
    """

    text_bytes = BytesIO(b"This is a text file")

    text_file = UploadFile(
        file=text_bytes,
        filename="test.txt",
        headers=Headers({"content-type": "text/plain"}),
    )

    with pytest.raises(Exception) as exc_info:
        await storage_service.upload_file(
            file=text_file,
            bucket="photos",
            user_id=test_user_id,
        )

    err = exc_info.value
    message = err.detail if isinstance(err, HTTPException) else str(err)

    assert "invalid file type" in message.lower()


@pytest.mark.asyncio
async def test_large_file_rejected_for_free_tier(
    storage_service,
    test_user_id,
):
    """
    Ensure large files are rejected for free users.
    """

    # Create 15MB random payload
    large_bytes = os.urandom(15 * 1024 * 1024)

    large_file = UploadFile(
        file=BytesIO(large_bytes),
        filename="large.jpg",
        headers=Headers({"content-type": "image/jpeg"}),
    )

    with pytest.raises(Exception) as exc_info:
        await storage_service.upload_file(
            file=large_file,
            bucket="photos",
            user_id=test_user_id,
            is_premium=False,
        )

    err = exc_info.value
    message = err.detail if isinstance(err, HTTPException) else str(err)

    assert "file size" in message.lower() or "limit" in message.lower()


@pytest.mark.asyncio
async def test_large_file_allowed_for_premium(
    storage_service,
    test_user_id,
):
    """
    Ensure premium users can upload large files.
    """

    # Create 15MB random payload
    large_bytes = os.urandom(15 * 1024 * 1024)

    large_file = UploadFile(
        file=BytesIO(large_bytes),
        filename="large_premium.jpg",
        headers=Headers({"content-type": "image/jpeg"}),
    )

    url = await storage_service.upload_file(
        file=large_file,
        bucket="photos",
        user_id=test_user_id,
        is_premium=True,
    )

    assert url.startswith(settings.SUPABASE_URL)

    file_path = extract_file_path(url)

    # Cleanup
    storage_service.delete_file("photos", file_path)
