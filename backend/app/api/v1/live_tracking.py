"""
Live-tracking Phase 2 API endpoints.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, Header, Query, Response
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.live_tracking import (
    AutoFinalizeCommitRequest,
    AutoFinalizeCommitResponse,
    CheckinActionResponse,
    CheckinConfirmRequest,
    CheckinRejectRequest,
    CheckinSnoozeRequest,
    DeviceTokenActionResponse,
    DeviceTokenDeactivateRequest,
    DeviceTokenRegisterRequest,
    MomentCreateRequest,
    MomentListResponse,
    MomentResponse,
    MomentUpdateRequest,
    PendingCheckinsResponse,
    TrackingPauseRequest,
    TrackingPathResponse,
    TrackingPointsBatchRequest,
    TrackingPointsBatchResponse,
    TrackingEventsBatchRequest,
    TrackingEventsBatchResponse,
    TrackingResumeRequest,
    TrackingSessionResponse,
    TrackingStartRequest,
    TrackingStopRequest,
)
from app.services.live_tracking_service import LiveTrackingService


router = APIRouter(tags=["Live Tracking"])


def _set_replay_header(response: Response, replayed: bool) -> None:
    response.headers["Idempotency-Replayed"] = "true" if replayed else "false"


def _idempotency_payload(body_payload: dict, **path_params: UUID) -> dict:
    """
    Include concrete path params in idempotency hash material.

    Prevents key replay collisions across different resource IDs that share
    the same template endpoint signature.
    """
    payload = dict(body_payload)
    payload["_path_params"] = {key: str(value) for key, value in path_params.items()}
    return payload


@router.post("/trips/{trip_id}/tracking/start", response_model=TrackingSessionResponse)
async def start_tracking(
    trip_id: UUID,
    request: TrackingStartRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/start",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.start_tracking(
            trip_id=trip_id,
            user_id=current_user.id,
            client_session_id=request.client_session_id,
            started_at=request.started_at,
            timezone_name=request.timezone,
            device_context=request.device_context,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post("/trips/{trip_id}/tracking/pause", response_model=TrackingSessionResponse)
async def pause_tracking(
    trip_id: UUID,
    request: TrackingPauseRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/pause",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.pause_tracking(
            trip_id=trip_id,
            user_id=current_user.id,
            session_id=request.session_id,
            paused_at=request.paused_at,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post("/trips/{trip_id}/tracking/resume", response_model=TrackingSessionResponse)
async def resume_tracking(
    trip_id: UUID,
    request: TrackingResumeRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/resume",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.resume_tracking(
            trip_id=trip_id,
            user_id=current_user.id,
            session_id=request.session_id,
            resumed_at=request.resumed_at,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post("/trips/{trip_id}/tracking/stop", response_model=TrackingSessionResponse)
async def stop_tracking(
    trip_id: UUID,
    request: TrackingStopRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/stop",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.stop_tracking(
            trip_id=trip_id,
            user_id=current_user.id,
            session_id=request.session_id,
            stopped_at=request.stopped_at,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post(
    "/trips/{trip_id}/tracking/points:batch",
    response_model=TrackingPointsBatchResponse,
)
async def ingest_points_batch(
    trip_id: UUID,
    request: TrackingPointsBatchRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/points:batch",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.ingest_points_batch(
            trip_id=trip_id,
            user_id=current_user.id,
            session_id=request.session_id,
            client_batch_id=request.client_batch_id,
            points=[point.model_dump() for point in request.points],
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.post(
    "/trips/{trip_id}/tracking/events:batch",
    response_model=TrackingEventsBatchResponse,
)
async def ingest_events_batch(
    trip_id: UUID,
    request: TrackingEventsBatchRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/events:batch",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.ingest_events_batch(
            trip_id=trip_id,
            user_id=current_user.id,
            events=[event.model_dump() for event in request.events],
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.get("/trips/{trip_id}/tracking/path", response_model=TrackingPathResponse)
async def get_tracking_path(
    trip_id: UUID,
    session_id: UUID | None = Query(default=None),
    limit: int = Query(default=5000, ge=1, le=10000),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    return service.get_tracking_path(
        trip_id=trip_id,
        user_id=current_user.id,
        session_id=session_id,
        limit=limit,
    )


@router.get("/trips/{trip_id}/checkins/pending", response_model=PendingCheckinsResponse)
async def list_pending_checkins(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    return service.list_pending_checkins(trip_id=trip_id, user_id=current_user.id)


@router.post("/checkins/{candidate_id}/confirm", response_model=CheckinActionResponse)
async def confirm_checkin_candidate(
    candidate_id: UUID,
    request: CheckinConfirmRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/checkins/{candidate_id}/confirm",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(
            request.model_dump(mode="json"),
            candidate_id=candidate_id,
        ),
        operation=lambda: service.confirm_candidate(
            candidate_id=candidate_id,
            user_id=current_user.id,
            confirmed_at=request.confirmed_at,
            place_override=request.place_override.model_dump() if request.place_override else None,
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.post("/checkins/{candidate_id}/reject", response_model=CheckinActionResponse)
async def reject_checkin_candidate(
    candidate_id: UUID,
    request: CheckinRejectRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/checkins/{candidate_id}/reject",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(
            request.model_dump(mode="json"),
            candidate_id=candidate_id,
        ),
        operation=lambda: service.reject_candidate(
            candidate_id=candidate_id,
            user_id=current_user.id,
            rejected_at=request.rejected_at,
            reason=request.reason,
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.post("/checkins/{candidate_id}/snooze", response_model=CheckinActionResponse)
async def snooze_checkin_candidate(
    candidate_id: UUID,
    request: CheckinSnoozeRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/checkins/{candidate_id}/snooze",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(
            request.model_dump(mode="json"),
            candidate_id=candidate_id,
        ),
        operation=lambda: service.snooze_candidate(
            candidate_id=candidate_id,
            user_id=current_user.id,
            snoozed_until=request.snoozed_until,
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.get("/trips/{trip_id}/moments", response_model=MomentListResponse)
async def list_trip_moments(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    return service.list_moments(trip_id=trip_id, user_id=current_user.id)


@router.post("/trips/{trip_id}/moments", response_model=MomentResponse)
async def create_trip_moment(
    trip_id: UUID,
    request: MomentCreateRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/moments",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.create_moment(
            trip_id=trip_id,
            user_id=current_user.id,
            captured_at=request.captured_at,
            note=request.note,
            location=request.location.model_dump() if request.location else None,
            media_refs=request.media_refs,
            linked_trip_place_id=request.linked_trip_place_id,
            extra_payload=request.extra_payload,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.patch("/moments/{moment_id}", response_model=MomentResponse)
async def update_trip_moment(
    moment_id: UUID,
    request: MomentUpdateRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)

    update_payload = request.model_dump(exclude_unset=True)
    update_payload.pop("client_event_id", None)
    if "location" in update_payload and update_payload["location"] is not None:
        update_payload["location"] = request.location.model_dump()

    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="PATCH:/moments/{moment_id}",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), moment_id=moment_id),
        operation=lambda: service.update_moment(
            moment_id=moment_id,
            user_id=current_user.id,
            update_data=update_payload,
        ),
    )
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return result.body


@router.post(
    "/trips/{trip_id}/auto-finalize/commit",
    response_model=AutoFinalizeCommitResponse,
)
async def commit_auto_finalize(
    trip_id: UUID,
    request: AutoFinalizeCommitRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/auto-finalize/commit",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.commit_auto_finalize(
            trip_id=trip_id,
            user_id=current_user.id,
            committed_at=request.committed_at,
        ),
    )
    payload = dict(result.body)
    payload["idempotency_replayed"] = result.replayed
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.post(
    "/notifications/device-tokens/register",
    response_model=DeviceTokenActionResponse,
)
async def register_device_token(
    request: DeviceTokenRegisterRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/notifications/device-tokens/register",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json")),
        operation=lambda: service.register_device_token(
            user_id=current_user.id,
            platform=request.platform,
            push_token=request.push_token,
            device_id=request.device_id,
            app_version=request.app_version,
            locale=request.locale,
            seen_at=request.seen_at,
        ),
    )
    payload = {
        "token": result.body,
        "idempotency_replayed": result.replayed,
    }
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload


@router.post(
    "/notifications/device-tokens/deactivate",
    response_model=DeviceTokenActionResponse,
)
async def deactivate_device_token(
    request: DeviceTokenDeactivateRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/notifications/device-tokens/deactivate",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json")),
        operation=lambda: service.deactivate_device_token(
            user_id=current_user.id,
            push_token=request.push_token,
            deactivated_at=request.deactivated_at,
        ),
    )
    payload = {
        "token": result.body,
        "idempotency_replayed": result.replayed,
    }
    response.status_code = result.status_code
    _set_replay_header(response, result.replayed)
    return payload
