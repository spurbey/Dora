from datetime import datetime, timezone
from types import SimpleNamespace
from uuid import UUID, uuid4

from app.services.place_service import PlaceService


class _NoMediaQueryDb:
    def query(self, *_args, **_kwargs):
        raise AssertionError(
            "Media query should not run when place photos contain no valid UUIDs"
        )


def _make_place(photos):
    now = datetime.now(timezone.utc)
    return SimpleNamespace(
        id=uuid4(),
        trip_id=uuid4(),
        user_id=uuid4(),
        name="Example place",
        place_type=None,
        lat=12.34,
        lng=56.78,
        user_notes=None,
        user_rating=None,
        visit_date=None,
        photos=photos,
        videos=[],
        external_data=None,
        order_in_trip=0,
        created_at=now,
        updated_at=now,
    )


def test_extract_photo_media_ids_filters_invalid_values():
    valid_a = str(uuid4())
    valid_b = str(uuid4()).upper()

    result = PlaceService._extract_photo_media_ids(
        [
            valid_a,
            {"id": valid_b},
            {"id": "local-temp-media-id"},
            "not-a-uuid",
            {"url": "https://example.com/no-id"},
            valid_a,  # duplicate
        ]
    )

    assert result == [str(UUID(valid_a)), str(UUID(valid_b))]


def test_build_place_response_ignores_non_uuid_photo_references():
    service = PlaceService(_NoMediaQueryDb())
    place = _make_place(
        photos=[
            "temp-local-id",
            {"id": "not-a-uuid"},
            {"url": "https://example.com/no-id"},
        ]
    )

    response = service.build_place_response(place)

    assert response.photos == []

