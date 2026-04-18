"""
Strict V2 ingest and projection endpoints.
"""

import logging
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Response
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.utils.async_tasks import spawn_best_effort

logger = logging.getLogger(__name__)
from app.schemas.live_tracking_v2 import (
    V2PublishCommitRequest,
    V2PublishCommitResponse,
    V2PublishMediaCompleteRequest,
    V2PublishMediaCompleteResponse,
    V2PublishPayloadChunkRequest,
    V2PublishPayloadChunkResponse,
    V2PublishStartRequest,
    V2PublishStartResponse,
    V2RouteResponse,
    V2SessionResponse,
    V2SessionStartRequest,
    V2SessionStopRequest,
    V2TimelineResponse,
)
from app.services.live_tracking_v2_service import (
    ROUTE_LIMIT_SEGMENTS_DEFAULT,
    LiveTrackingV2Service,
)


router = APIRouter(tags=["Live Tracking V2"])


def _set_replay_header(response: Response, replayed: bool) -> None:
    response.headers["Idempotency-Replayed"] = "true" if replayed else "false"


def _require_idempotency_key(value: str | None) -> str:
    if value is None or not value.strip():
        raise HTTPException(
            status_code=400,
            detail={
                "error_code": "invalid_payload",
                "message": "Idempotency-Key header is required.",
            },
        )
    return value.strip()


@router.post("/trips/{trip_id}/sessions:start", response_model=V2SessionResponse)
async def start_v2_session(
    trip_id: UUID,
    request: V2SessionStartRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    result = service.start_session(
        trip_id=trip_id,
        user_id=current_user.id,
        client_session_id=request.client_session_id,
        started_at=request.started_at,
        timezone_name=request.timezone,
        device_context=request.device_context,
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)

    if not result.replayed:
        async def _enrich(db_session, tid):
            from app.services.trip_brain_service import TripBrainService
            await TripBrainService(db_session).enrich_on_tracking_start(tid)
        spawn_best_effort(_enrich, trip_id, label="advisory_enrich")

    return result.body


@router.post("/trips/{trip_id}/sessions/{client_session_id}:stop", response_model=V2SessionResponse)
async def stop_v2_session(
    trip_id: UUID,
    client_session_id: str,
    request: V2SessionStopRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    result = service.stop_session(
        trip_id=trip_id,
        user_id=current_user.id,
        client_session_id=client_session_id,
        seal_version=request.seal_version,
        stop_client_event_id=request.stop_client_event_id,
        stopped_at=request.stopped_at,
        reason=request.reason,
        echoed_client_session_id=request.client_session_id,
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post(
    "/trips/{trip_id}/publish:start",
    response_model=V2PublishStartResponse,
)
async def publish_start(
    trip_id: UUID,
    request: V2PublishStartRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    status_code, body = service.publish_start(
        trip_id=trip_id,
        user_id=current_user.id,
        client_job_id=request.client_job_id,
        schema_version=request.schema_version,
        publish_summary=request.publish_summary.model_dump(mode="json"),
        media_manifest=[item.model_dump(mode="json") for item in request.media_manifest],
        media_manifest_digest=request.media_manifest_digest,
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = status_code
    return body


@router.post(
    "/trips/{trip_id}/publish:media-complete",
    response_model=V2PublishMediaCompleteResponse,
)
async def publish_media_complete(
    trip_id: UUID,
    request: V2PublishMediaCompleteRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    status_code, body = service.publish_media_complete(
        trip_id=trip_id,
        user_id=current_user.id,
        publish_token=request.publish_token,
        client_job_id=request.client_job_id,
        schema_version=request.schema_version,
        uploaded_media=[item.model_dump(mode="json") for item in request.uploaded_media],
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = status_code
    return body


@router.post(
    "/trips/{trip_id}/publish:payload-chunk",
    response_model=V2PublishPayloadChunkResponse,
)
async def publish_payload_chunk(
    trip_id: UUID,
    request: V2PublishPayloadChunkRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    status_code, body = service.publish_payload_chunk(
        trip_id=trip_id,
        user_id=current_user.id,
        publish_token=request.publish_token,
        client_job_id=request.client_job_id,
        schema_version=request.schema_version,
        chunk_index=request.chunk_index,
        total_chunks=request.total_chunks,
        chunk_content_hash=request.chunk_content_hash,
        chunk_json=request.chunk_json,
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = status_code
    return body


@router.post(
    "/trips/{trip_id}/publish:commit",
    response_model=V2PublishCommitResponse,
)
async def publish_commit(
    trip_id: UUID,
    request: V2PublishCommitRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    status_code, body = service.publish_commit(
        trip_id=trip_id,
        user_id=current_user.id,
        publish_token=request.publish_token,
        client_job_id=request.client_job_id,
        schema_version=request.schema_version,
        idempotency_key=_require_idempotency_key(idempotency_key),
    )
    response.status_code = status_code
    return body


@router.get("/trips/{trip_id}/timeline", response_model=V2TimelineResponse)
async def get_v2_timeline(
    trip_id: UUID,
    cursor: str | None = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    return service.get_timeline(
        trip_id=trip_id,
        user_id=current_user.id,
        cursor=cursor,
        limit=limit,
    )


@router.get("/trips/{trip_id}/route", response_model=V2RouteResponse)
async def get_v2_route(
    trip_id: UUID,
    cursor: str | None = Query(default=None),
    limit_segments: int = Query(default=ROUTE_LIMIT_SEGMENTS_DEFAULT, ge=1, le=20),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingV2Service(db)
    return service.get_route(
        trip_id=trip_id,
        user_id=current_user.id,
        cursor=cursor,
        limit_segments=limit_segments,
    )
