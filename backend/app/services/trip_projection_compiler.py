"""
Trip projection compiler service.

Builds editor-consumable storyline artifacts from raw tracking events
and tracking points without mutating source rows.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime, timezone
import math
from typing import Any, Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import asc
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.orm import Session

from app.models.place import TripPlace
from app.models.trip import Trip
from app.models.trip_compiled_projection_item import TripCompiledProjectionItem
from app.models.trip_compiled_projection_override import TripCompiledProjectionOverride
from app.models.trip_compiled_projection_state import TripCompiledProjectionState
from app.models.trip_compiled_route_segment import TripCompiledRouteSegment
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_tracking_event import TripTrackingEvent
from app.models.trip_tracking_event_media import TripTrackingEventMedia
from app.schemas.compiled_projection import (
    CompiledProjectionResponse,
    CompiledProjectionStats,
    CompiledRouteSegment,
    CompiledTimelineDayGroup,
    CompiledTimelineEntry,
)
from app.utils.geo import haversine_distance


@dataclass(frozen=True)
class _Point:
    recorded_at: datetime
    latitude: float
    longitude: float


class TripProjectionCompilerService:
    """Compiler and projection retrieval service."""

    COMPILER_VERSION = 1
    PLACE_BIND_RADIUS_M = 50.0
    SEGMENT_BREAK_SECONDS = 15 * 60
    SEGMENT_MAX_JUMP_M = 2500.0
    MAX_SIMPLIFIED_POINTS = 250

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def _to_utc(value: datetime) -> datetime:
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)

    @staticmethod
    def _parse_uuid(value: Any) -> Optional[UUID]:
        if value is None:
            return None
        if isinstance(value, UUID):
            return value
        raw = str(value).strip()
        if not raw:
            return None
        try:
            return UUID(raw)
        except (ValueError, TypeError, AttributeError):
            return None

    @staticmethod
    def _coerce_float(value: Any) -> Optional[float]:
        if value is None:
            return None
        if isinstance(value, (int, float)):
            return float(value)
        try:
            return float(str(value))
        except (TypeError, ValueError):
            return None

    def _get_owned_trip(self, *, trip_id: UUID, user_id: UUID) -> Trip:
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
        if trip.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not own this trip")
        return trip

    def _ensure_state(self, *, trip_id: UUID, user_id: UUID) -> TripCompiledProjectionState:
        state = self.db.query(TripCompiledProjectionState).filter(
            TripCompiledProjectionState.trip_id == trip_id
        ).first()
        if state is None:
            state = TripCompiledProjectionState(
                trip_id=trip_id,
                user_id=user_id,
                compiler_version=self.COMPILER_VERSION,
                dirty=True,
                stale=False,
            )
            self.db.add(state)
            self.db.flush()
            return state

        if state.user_id != user_id:
            state.user_id = user_id
        if state.compiler_version != self.COMPILER_VERSION:
            state.compiler_version = self.COMPILER_VERSION
            state.dirty = True
        return state

    def mark_dirty(self, *, trip_id: UUID, user_id: UUID, reason: Optional[str] = None) -> None:
        """Mark compiled projection for a trip as dirty."""
        insert_stmt = pg_insert(TripCompiledProjectionState).values(
            trip_id=trip_id,
            user_id=user_id,
            compiler_version=self.COMPILER_VERSION,
            dirty=True,
            stale=False,
            last_error=reason,
        )
        update_stmt = insert_stmt.on_conflict_do_update(
            index_elements=[TripCompiledProjectionState.trip_id],
            set_={
                "user_id": user_id,
                "compiler_version": self.COMPILER_VERSION,
                "dirty": True,
                "stale": False,
                "last_error": reason,
                "updated_at": datetime.now(timezone.utc),
            },
        )
        try:
            with self.db.begin_nested():
                self.db.execute(update_stmt)
        except ProgrammingError as exc:
            # Backward-compatible fallback for test DBs/environments where
            # projection migration has not yet been applied.
            message = str(exc).lower()
            if "trip_compiled_projection_state" in message and "does not exist" in message:
                return
            raise

    def save_manual_rebind(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        source_kind: str,
        source_id: Optional[UUID],
        action: str,
        trip_place_id: Optional[UUID],
    ) -> None:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)

        normalized_source_kind = source_kind.strip().lower()
        if normalized_source_kind not in {"tracking_event", "tracking_event_media"}:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="source_kind must be tracking_event|tracking_event_media",
            )
        if source_id is None:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="source id is required for rebind",
            )
        if normalized_source_kind == "tracking_event":
            source_row = self.db.query(TripTrackingEvent).filter(
                TripTrackingEvent.id == source_id,
                TripTrackingEvent.trip_id == trip_id,
                TripTrackingEvent.user_id == user_id,
            ).first()
            if source_row is None:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking event not found")
        else:
            source_row = self.db.query(TripTrackingEventMedia).filter(
                TripTrackingEventMedia.id == source_id,
                TripTrackingEventMedia.trip_id == trip_id,
                TripTrackingEventMedia.user_id == user_id,
            ).first()
            if source_row is None:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking media not found")

        normalized_action = action.strip().lower()
        if normalized_action not in {"bind", "unbind"}:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="action must be bind|unbind")

        if normalized_action == "bind":
            if trip_place_id is None:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="trip_place_id is required for bind action",
                )
            place = self.db.query(TripPlace).filter(
                TripPlace.id == trip_place_id,
                TripPlace.trip_id == trip_id,
                TripPlace.user_id == user_id,
            ).first()
            if place is None:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip place not found")
        else:
            trip_place_id = None

        insert_stmt = pg_insert(TripCompiledProjectionOverride).values(
            trip_id=trip_id,
            user_id=user_id,
            source_kind=normalized_source_kind,
            source_id=source_id,
            action=normalized_action,
            trip_place_id=trip_place_id,
        )
        update_stmt = insert_stmt.on_conflict_do_update(
            index_elements=[
                TripCompiledProjectionOverride.trip_id,
                TripCompiledProjectionOverride.source_kind,
                TripCompiledProjectionOverride.source_id,
            ],
            set_={
                "user_id": user_id,
                "action": normalized_action,
                "trip_place_id": trip_place_id,
                "updated_at": datetime.now(timezone.utc),
            },
        )
        self.db.execute(update_stmt)
        self.mark_dirty(
            trip_id=trip_id,
            user_id=user_id,
            reason=f"manual_rebind:{normalized_action}",
        )

    def get_compiled_projection(self, *, trip_id: UUID, user_id: UUID) -> CompiledProjectionResponse:
        self._get_owned_trip(trip_id=trip_id, user_id=user_id)
        state = self._ensure_state(trip_id=trip_id, user_id=user_id)

        if state.dirty or state.last_compiled_at is None:
            try:
                self._compile_trip(trip_id=trip_id, user_id=user_id, state=state)
                self.db.commit()
            except Exception as exc:  # pragma: no cover - guarded by tests via stale fallback
                self.db.rollback()
                self._record_compile_failure(trip_id=trip_id, user_id=user_id, error_text=str(exc))
                fallback = self._build_projection_response(
                    trip_id=trip_id,
                    user_id=user_id,
                    force_stale=True,
                )
                if fallback.timeline_entries or fallback.route_segments:
                    return fallback
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Compiled projection is temporarily unavailable",
                ) from exc

        return self._build_projection_response(trip_id=trip_id, user_id=user_id)

    def _record_compile_failure(self, *, trip_id: UUID, user_id: UUID, error_text: str) -> None:
        state = self._ensure_state(trip_id=trip_id, user_id=user_id)
        state.stale = True
        state.last_error = (error_text or "")[:2000]
        state.updated_at = datetime.now(timezone.utc)
        self.db.commit()

    def _compile_trip(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        state: TripCompiledProjectionState,
    ) -> None:
        events = self.db.query(TripTrackingEvent).filter(
            TripTrackingEvent.trip_id == trip_id,
            TripTrackingEvent.user_id == user_id,
            TripTrackingEvent.event_type.in_(("note", "warn", "tag")),
        ).order_by(
            asc(TripTrackingEvent.captured_at),
            asc(TripTrackingEvent.id),
        ).all()
        media_rows = self.db.query(TripTrackingEventMedia).filter(
            TripTrackingEventMedia.trip_id == trip_id,
            TripTrackingEventMedia.user_id == user_id,
            TripTrackingEventMedia.media_type.in_(("photo", "media")),
        ).order_by(
            asc(TripTrackingEventMedia.captured_at),
            asc(TripTrackingEventMedia.id),
        ).all()

        places = self.db.query(TripPlace).filter(
            TripPlace.trip_id == trip_id,
            TripPlace.user_id == user_id,
        ).all()
        place_by_id = {place.id: place for place in places}

        overrides = self.db.query(TripCompiledProjectionOverride).filter(
            TripCompiledProjectionOverride.trip_id == trip_id,
            TripCompiledProjectionOverride.user_id == user_id,
        ).all()
        event_override_by_source = {
            override.source_id: override
            for override in overrides
            if override.source_kind == "tracking_event"
        }
        media_override_by_source = {
            override.source_id: override
            for override in overrides
            if override.source_kind == "tracking_event_media"
        }

        point_rows = self.db.query(TripLocationPoint).filter(
            TripLocationPoint.trip_id == trip_id,
            TripLocationPoint.user_id == user_id,
        ).order_by(
            asc(TripLocationPoint.session_id),
            asc(TripLocationPoint.recorded_at),
            asc(TripLocationPoint.id),
        ).all()

        item_rows: list[TripCompiledProjectionItem] = []
        for event in events:
            payload = dict(event.payload or {})
            bind = self._resolve_binding(
                event=event,
                payload=payload,
                place_by_id=place_by_id,
                places=places,
                override=event_override_by_source.get(event.id),
            )
            title = (event.note or "").strip() or self._default_title_for_event(event.event_type)
            subtitle = self._build_subtitle(event=event, bind=bind)
            event_payload = dict(payload)
            if event.client_event_id:
                event_payload.setdefault("client_event_id", str(event.client_event_id))
            if event.latitude is not None and event.longitude is not None:
                event_payload.setdefault(
                    "location",
                    {"latitude": event.latitude, "longitude": event.longitude},
                )

            item_rows.append(
                TripCompiledProjectionItem(
                    trip_id=trip_id,
                    user_id=user_id,
                    entry_id=f"tracking_event:{event.id}",
                    source_kind="tracking_event",
                    source_id=event.id,
                    event_type=event.event_type,
                    captured_at=self._to_utc(event.captured_at),
                    day_key=self._to_utc(event.captured_at).date(),
                    bucket_type=bind["bucket_type"],
                    place_id=bind["place_id"],
                    place_name=bind["place_name"],
                    bind_source=bind["bind_source"],
                    bind_confidence=bind["bind_confidence"],
                    reason_code=bind["reason_code"],
                    title=title[:255],
                    subtitle=subtitle,
                    payload=event_payload,
                    order_index=0,
                    compiler_version=self.COMPILER_VERSION,
                )
            )

        for media in media_rows:
            bind = self._resolve_media_binding(
                media=media,
                place_by_id=place_by_id,
                override=media_override_by_source.get(media.id),
            )
            media_payload = dict(media.payload or {})
            media_payload.setdefault("upload_ref", media.upload_ref)
            if media.mime_type:
                media_payload.setdefault("mime_type", media.mime_type)
            if media.file_size_bytes is not None:
                media_payload.setdefault("file_size_bytes", media.file_size_bytes)
            if media.client_media_id:
                media_payload.setdefault("client_media_id", str(media.client_media_id))
            if media.client_event_id:
                media_payload.setdefault("client_event_id", str(media.client_event_id))
            if media.anchor_latitude is not None and media.anchor_longitude is not None:
                media_payload.setdefault(
                    "location",
                    {
                        "latitude": media.anchor_latitude,
                        "longitude": media.anchor_longitude,
                    },
                )
            title = "Photo" if media.media_type == "photo" else "Media"
            subtitle = self._build_compiled_subtitle(
                captured_at=media.captured_at,
                bind=bind,
            )
            item_rows.append(
                TripCompiledProjectionItem(
                    trip_id=trip_id,
                    user_id=user_id,
                    entry_id=f"tracking_event_media:{media.id}",
                    source_kind="tracking_event_media",
                    source_id=media.id,
                    event_type=media.media_type,
                    captured_at=self._to_utc(media.captured_at),
                    day_key=self._to_utc(media.captured_at).date(),
                    bucket_type=bind["bucket_type"],
                    place_id=bind["place_id"],
                    place_name=bind["place_name"],
                    bind_source=bind["bind_source"],
                    bind_confidence=bind["bind_confidence"],
                    reason_code=bind["reason_code"],
                    title=title,
                    subtitle=subtitle,
                    payload=media_payload,
                    order_index=0,
                    compiler_version=self.COMPILER_VERSION,
                )
            )

        item_rows.sort(
            key=lambda row: (row.captured_at, row.entry_id, str(row.source_id)),
        )
        for index, row in enumerate(item_rows):
            row.order_index = index

        route_rows = self._compile_route_segments(
            trip_id=trip_id,
            user_id=user_id,
            point_rows=point_rows,
        )

        self.db.query(TripCompiledProjectionItem).filter(
            TripCompiledProjectionItem.trip_id == trip_id
        ).delete(synchronize_session=False)
        self.db.query(TripCompiledRouteSegment).filter(
            TripCompiledRouteSegment.trip_id == trip_id
        ).delete(synchronize_session=False)

        if item_rows:
            self.db.bulk_save_objects(item_rows)
        if route_rows:
            self.db.bulk_save_objects(route_rows)

        state.compiler_version = self.COMPILER_VERSION
        state.dirty = False
        state.stale = False
        state.raw_event_count = len(events) + len(media_rows)
        state.compiled_event_count = len(item_rows)
        state.raw_point_count = len(point_rows)
        state.compiled_route_segment_count = len(route_rows)
        state.last_compiled_at = datetime.now(timezone.utc)
        state.last_error = None
        state.updated_at = datetime.now(timezone.utc)
        self.db.flush()

    def _compile_route_segments(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        point_rows: list[TripLocationPoint],
    ) -> list[TripCompiledRouteSegment]:
        per_session: dict[UUID, list[_Point]] = defaultdict(list)
        for row in point_rows:
            if row.session_id is None:
                continue
            if row.latitude is None or row.longitude is None:
                continue
            if not (-90 <= row.latitude <= 90 and -180 <= row.longitude <= 180):
                continue
            per_session[row.session_id].append(
                _Point(
                    recorded_at=self._to_utc(row.recorded_at),
                    latitude=float(row.latitude),
                    longitude=float(row.longitude),
                )
            )

        segments: list[TripCompiledRouteSegment] = []
        for session_id, points in per_session.items():
            points.sort(key=lambda p: p.recorded_at)
            split = self._split_point_segments(points)
            for seg_index, segment_points in enumerate(split):
                if len(segment_points) < 2:
                    continue
                coordinates = [(point.latitude, point.longitude) for point in segment_points]
                simplified = self._simplify_coordinates(coordinates, max_points=self.MAX_SIMPLIFIED_POINTS)
                distance_m = self._distance_for_coordinates(coordinates)
                geometry = {
                    "type": "LineString",
                    "coordinates": [[lng, lat] for lat, lng in simplified],
                }
                segments.append(
                    TripCompiledRouteSegment(
                        trip_id=trip_id,
                        user_id=user_id,
                        segment_key=f"{session_id}:{seg_index}",
                        session_id=session_id,
                        started_at=segment_points[0].recorded_at,
                        ended_at=segment_points[-1].recorded_at,
                        distance_m=distance_m,
                        raw_point_count=len(coordinates),
                        simplified_point_count=len(simplified),
                        geometry=geometry,
                        compiler_version=self.COMPILER_VERSION,
                    )
                )

        segments.sort(key=lambda row: (row.started_at, str(row.session_id), row.segment_key))
        return segments

    def _split_point_segments(self, points: list[_Point]) -> list[list[_Point]]:
        if not points:
            return []
        segments: list[list[_Point]] = []
        current: list[_Point] = [points[0]]
        previous = points[0]

        for point in points[1:]:
            delta_seconds = (point.recorded_at - previous.recorded_at).total_seconds()
            jump_m = haversine_distance(
                previous.latitude,
                previous.longitude,
                point.latitude,
                point.longitude,
            )
            if delta_seconds > self.SEGMENT_BREAK_SECONDS or jump_m > self.SEGMENT_MAX_JUMP_M:
                if len(current) >= 2:
                    segments.append(current)
                current = [point]
            else:
                current.append(point)
            previous = point

        if len(current) >= 2:
            segments.append(current)
        return segments

    @staticmethod
    def _simplify_coordinates(
        coordinates: list[tuple[float, float]],
        *,
        max_points: int,
    ) -> list[tuple[float, float]]:
        if len(coordinates) <= max_points:
            return coordinates
        if max_points <= 2:
            return [coordinates[0], coordinates[-1]]

        stride = math.ceil((len(coordinates) - 1) / (max_points - 1))
        simplified = [coordinates[0]]
        for idx in range(stride, len(coordinates) - 1, stride):
            simplified.append(coordinates[idx])
        simplified.append(coordinates[-1])
        return simplified

    @staticmethod
    def _distance_for_coordinates(coordinates: list[tuple[float, float]]) -> float:
        if len(coordinates) < 2:
            return 0.0
        distance = 0.0
        previous = coordinates[0]
        for current in coordinates[1:]:
            distance += haversine_distance(previous[0], previous[1], current[0], current[1])
            previous = current
        return round(distance, 3)

    def _resolve_binding(
        self,
        *,
        event: TripTrackingEvent,
        payload: dict[str, Any],
        place_by_id: dict[UUID, TripPlace],
        places: list[TripPlace],
        override: Optional[TripCompiledProjectionOverride],
    ) -> dict[str, Any]:
        if override is not None:
            if override.action == "bind" and override.trip_place_id in place_by_id:
                place = place_by_id[override.trip_place_id]
                return {
                    "bucket_type": "place",
                    "place_id": place.id,
                    "place_name": place.name,
                    "bind_source": "manual",
                    "bind_confidence": 1.0,
                    "reason_code": "manual_bind",
                }
            return {
                "bucket_type": "on_route",
                "place_id": None,
                "place_name": None,
                "bind_source": "manual",
                "bind_confidence": None,
                "reason_code": "manual_unbind",
            }

        payload_place_id = self._parse_uuid(payload.get("resolved_place_id"))
        payload_reason = payload.get("resolver_reason_code") or payload.get("reason_code")
        payload_confidence = self._coerce_float(payload.get("bind_confidence"))
        if payload_place_id is not None and payload_place_id in place_by_id:
            place = place_by_id[payload_place_id]
            return {
                "bucket_type": "place",
                "place_id": place.id,
                "place_name": place.name,
                "bind_source": "auto",
                "bind_confidence": payload_confidence,
                "reason_code": str(payload_reason or "resolver_payload"),
            }

        if event.latitude is not None and event.longitude is not None and places:
            nearest, distance_m = self._nearest_place(
                latitude=float(event.latitude),
                longitude=float(event.longitude),
                places=places,
            )
            if nearest is not None and distance_m <= self.PLACE_BIND_RADIUS_M:
                confidence = max(0.0, min(1.0, 1.0 - (distance_m / self.PLACE_BIND_RADIUS_M)))
                return {
                    "bucket_type": "place",
                    "place_id": nearest.id,
                    "place_name": nearest.name,
                    "bind_source": "auto",
                    "bind_confidence": round(confidence, 3),
                    "reason_code": "trip_place_radius_match",
                }

        return {
            "bucket_type": "on_route",
            "place_id": None,
            "place_name": None,
            "bind_source": "none",
            "bind_confidence": None,
            "reason_code": "no_candidate",
        }

    def _resolve_media_binding(
        self,
        *,
        media: TripTrackingEventMedia,
        place_by_id: dict[UUID, TripPlace],
        override: Optional[TripCompiledProjectionOverride],
    ) -> dict[str, Any]:
        if override is not None:
            if override.action == "bind" and override.trip_place_id in place_by_id:
                place = place_by_id[override.trip_place_id]
                return {
                    "bucket_type": "place",
                    "place_id": place.id,
                    "place_name": place.name,
                    "bind_source": "manual",
                    "bind_confidence": 1.0,
                    "reason_code": "manual_bind",
                }
            return {
                "bucket_type": "on_route",
                "place_id": None,
                "place_name": None,
                "bind_source": "manual",
                "bind_confidence": None,
                "reason_code": "manual_unbind",
            }

        if media.bind_mode == "place" and media.trip_place_id in place_by_id:
            place = place_by_id[media.trip_place_id]
            return {
                "bucket_type": "place",
                "place_id": place.id,
                "place_name": place.name,
                "bind_source": "auto",
                "bind_confidence": 1.0,
                "reason_code": "media_place_bind",
            }

        return {
            "bucket_type": "on_route",
            "place_id": None,
            "place_name": None,
            "bind_source": "auto",
            "bind_confidence": 1.0,
            "reason_code": "media_route_geotag",
        }

    @staticmethod
    def _default_title_for_event(event_type: str) -> str:
        if event_type == "warn":
            return "Warning"
        if event_type == "tag":
            return "Checkpoint"
        return "Note"

    @staticmethod
    def _build_subtitle(*, event: TripTrackingEvent, bind: dict[str, Any]) -> str:
        captured = event.captured_at
        local = captured if captured.tzinfo else captured.replace(tzinfo=timezone.utc)
        hh = local.strftime("%H:%M")
        if bind["bucket_type"] == "place" and bind.get("place_name"):
            return f"{hh} · Near {bind['place_name']}"
        return f"{hh} · On Route"

    @staticmethod
    def _nearest_place(
        *,
        latitude: float,
        longitude: float,
        places: list[TripPlace],
    ) -> tuple[Optional[TripPlace], float]:
        nearest: Optional[TripPlace] = None
        nearest_distance = float("inf")
        for place in places:
            if place.lat is None or place.lng is None:
                continue
            distance = haversine_distance(latitude, longitude, float(place.lat), float(place.lng))
            if distance < nearest_distance:
                nearest_distance = distance
                nearest = place
        return nearest, nearest_distance

    def _build_projection_response(
        self,
        *,
        trip_id: UUID,
        user_id: UUID,
        force_stale: bool = False,
    ) -> CompiledProjectionResponse:
        state = self._ensure_state(trip_id=trip_id, user_id=user_id)
        items = self.db.query(TripCompiledProjectionItem).filter(
            TripCompiledProjectionItem.trip_id == trip_id,
            TripCompiledProjectionItem.user_id == user_id,
            TripCompiledProjectionItem.compiler_version == state.compiler_version,
        ).order_by(
            asc(TripCompiledProjectionItem.day_key),
            asc(TripCompiledProjectionItem.order_index),
            asc(TripCompiledProjectionItem.captured_at),
            asc(TripCompiledProjectionItem.id),
        ).all()
        segments = self.db.query(TripCompiledRouteSegment).filter(
            TripCompiledRouteSegment.trip_id == trip_id,
            TripCompiledRouteSegment.user_id == user_id,
            TripCompiledRouteSegment.compiler_version == state.compiler_version,
        ).order_by(
            asc(TripCompiledRouteSegment.started_at),
            asc(TripCompiledRouteSegment.segment_key),
        ).all()

        timeline_entries = [
            CompiledTimelineEntry(
                entry_id=item.entry_id,
                source_kind=item.source_kind,
                source_id=item.source_id,
                event_type=item.event_type,
                captured_at=item.captured_at,
                bucket_type=item.bucket_type,
                place_id=item.place_id,
                place_name=item.place_name,
                bind_source=item.bind_source,
                bind_confidence=item.bind_confidence,
                reason_code=item.reason_code,
                title=item.title,
                subtitle=item.subtitle,
                payload=dict(item.payload or {}),
            )
            for item in items
        ]

        groups_by_day: dict[date, dict[str, list[CompiledTimelineEntry]]] = {}
        for entry in timeline_entries:
            day = entry.captured_at.date()
            day_group = groups_by_day.setdefault(day, {"place": [], "on_route": []})
            day_group[entry.bucket_type].append(entry)

        timeline_groups = [
            CompiledTimelineDayGroup(
                day=day,
                place_entries=groups_by_day[day]["place"],
                on_route_entries=groups_by_day[day]["on_route"],
            )
            for day in sorted(groups_by_day.keys())
        ]

        route_segments = [
            CompiledRouteSegment(
                segment_id=segment.segment_key,
                session_id=segment.session_id,
                started_at=segment.started_at,
                ended_at=segment.ended_at,
                distance_m=segment.distance_m,
                raw_point_count=segment.raw_point_count,
                simplified_point_count=segment.simplified_point_count,
                geometry=dict(segment.geometry or {}),
            )
            for segment in segments
        ]

        actual_raw_event_count = self.db.query(TripTrackingEvent).filter(
            TripTrackingEvent.trip_id == trip_id,
            TripTrackingEvent.user_id == user_id,
            TripTrackingEvent.event_type.in_(("note", "warn", "tag")),
        ).count()
        actual_compiled_event_count = len(items)
        actual_compiled_route_segment_count = len(segments)

        raw_event_count_delta = actual_raw_event_count - state.raw_event_count
        compiled_event_count_delta = actual_compiled_event_count - state.compiled_event_count
        compiled_route_segment_count_delta = (
            actual_compiled_route_segment_count - state.compiled_route_segment_count
        )
        raw_vs_compiled_event_delta = actual_raw_event_count - actual_compiled_event_count

        drift_reasons: list[str] = []
        if raw_event_count_delta != 0:
            drift_reasons.append("raw_event_state_mismatch")
        if compiled_event_count_delta != 0:
            drift_reasons.append("compiled_event_state_mismatch")
        if compiled_route_segment_count_delta != 0:
            drift_reasons.append("compiled_route_segment_state_mismatch")
        if raw_vs_compiled_event_delta != 0:
            drift_reasons.append("raw_vs_compiled_event_mismatch")

        return CompiledProjectionResponse(
            trip_id=trip_id,
            compiler_version=state.compiler_version,
            stale=force_stale or state.stale,
            compiled_at=state.last_compiled_at,
            timeline_entries=timeline_entries,
            timeline_groups=timeline_groups,
            route_segments=route_segments,
            stats=CompiledProjectionStats(
                raw_event_count=state.raw_event_count,
                compiled_event_count=state.compiled_event_count,
                raw_point_count=state.raw_point_count,
                compiled_route_segment_count=state.compiled_route_segment_count,
                has_drift=bool(drift_reasons),
                raw_event_count_delta=raw_event_count_delta,
                compiled_event_count_delta=compiled_event_count_delta,
                compiled_route_segment_count_delta=compiled_route_segment_count_delta,
                raw_vs_compiled_event_delta=raw_vs_compiled_event_delta,
                drift_reasons=drift_reasons,
            ),
        )
