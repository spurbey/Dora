"""
Advisory pipeline API endpoints.
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.advisory import (
    AdvisoryActionRequest,
    AdvisoryActionResponse,
    AdvisoryInsightListResponse,
    AdvisoryInsightResponse,
    AdvisoryJobListResponse,
    AdvisoryJobResponse,
    AdvisoryQueryRequest,
    AdvisoryStartRequest,
)
from app.config import settings
from app.models.trip import Trip
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.advisory_service import AdvisoryService
from app.services.trip_brain_service import TripBrainService
from fastapi import HTTPException

router = APIRouter(tags=["Advisory"])


def _owned_brain(db: Session, trip_id: UUID, user: User) -> TripAdvisoryState:
    """Fetch the trip brain and verify the caller owns the trip."""
    trip = db.query(Trip).filter(Trip.id == trip_id).one_or_none()
    if trip is None or trip.user_id != user.id:
        raise HTTPException(status_code=404, detail="trip_not_found")
    brain = (
        db.query(TripAdvisoryState)
        .filter(TripAdvisoryState.trip_id == trip_id)
        .one_or_none()
    )
    if brain is None:
        # Self-heal rather than 404 — trip creation hook may have lost the seed.
        brain = TripBrainService(db).ensure_brain(trip_id, trip.user_id)
    return brain


@router.post(
    "/trips/{trip_id}/advisory/start",
    response_model=AdvisoryJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_advisory(
    trip_id: UUID,
    request: AdvisoryStartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a pre_trip or location_trigger advisory job."""
    service = AdvisoryService(db)
    job = service.create_advisory_job(
        user_id=current_user.id,
        trip_id=trip_id,
        job_type=request.job_type.value,
        trigger_payload=request.trigger_payload,
    )
    return AdvisoryJobResponse(
        job_id=job.id,
        status=job.status,
        stage=job.stage,
        progress=job.progress,
        job_type=job.job_type,
        created_at=job.created_at,
        started_at=job.started_at,
        completed_at=job.completed_at,
    )


@router.post(
    "/trips/{trip_id}/advisory/query",
    response_model=AdvisoryJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def query_advisory(
    trip_id: UUID,
    request: AdvisoryQueryRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Submit a natural-language query. Intent parsing happens in the worker, not here."""
    service = AdvisoryService(db)
    job = service.create_advisory_job(
        user_id=current_user.id,
        trip_id=trip_id,
        job_type="on_demand",
        query_text=request.query_text,
    )
    return AdvisoryJobResponse(
        job_id=job.id,
        status=job.status,
        stage=job.stage,
        progress=job.progress,
        job_type=job.job_type,
        created_at=job.created_at,
        started_at=job.started_at,
        completed_at=job.completed_at,
    )


@router.get(
    "/trips/{trip_id}/advisory/jobs",
    response_model=AdvisoryJobListResponse,
)
async def list_advisory_jobs(
    trip_id: UUID,
    status_filter: Optional[str] = Query(None, alias="status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = AdvisoryService(db)
    jobs, total = service.get_advisory_jobs(
        user_id=current_user.id,
        trip_id=trip_id,
        status_filter=status_filter,
        page=page,
        page_size=page_size,
    )
    return AdvisoryJobListResponse(
        jobs=[
            AdvisoryJobResponse(
                job_id=j.id,
                status=j.status,
                stage=j.stage,
                progress=j.progress,
                job_type=j.job_type,
                created_at=j.created_at,
                started_at=j.started_at,
                completed_at=j.completed_at,
                error_code=j.error_code,
                error_message=j.error_message,
            )
            for j in jobs
        ],
        total=total,
    )


@router.get(
    "/trips/{trip_id}/advisory/insights",
    response_model=AdvisoryInsightListResponse,
)
async def list_advisory_insights(
    trip_id: UUID,
    category: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get advisories for inbox: status IN ('pending', 'delivered')."""
    service = AdvisoryService(db)
    advisories, total = service.get_trip_advisories(
        user_id=current_user.id,
        trip_id=trip_id,
        category=category,
        page=page,
        page_size=page_size,
    )
    return AdvisoryInsightListResponse(
        insights=[AdvisoryInsightResponse.model_validate(a) for a in advisories],
        total=total,
    )


@router.post(
    "/advisory/{advisory_id}/action",
    response_model=AdvisoryActionResponse,
)
async def record_advisory_action(
    advisory_id: UUID,
    request: AdvisoryActionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Record a user engagement action (append-only) and update the brain."""
    service = AdvisoryService(db)
    action = service.record_user_action(
        user_id=current_user.id,
        advisory_id=advisory_id,
        action=request.action.value,
        action_metadata=request.action_metadata,
    )
    # Feedback → brain (streak reset + implicit resume if inactivity-paused).
    try:
        TripBrainService(db).apply_feedback(advisory_id, action.action)
    except Exception:  # noqa: BLE001 — brain update is best-effort
        pass
    return AdvisoryActionResponse(
        id=action.id,
        action=action.action,
        created_at=action.created_at,
    )


# ───────────────────────────── Brain control plane ─────────────────────────


@router.post(
    "/trips/{trip_id}/advisory/pause",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def pause_advisory(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Manually pause the advisory brain for this trip (reason='user').

    Manual pauses are sticky: only an explicit resume call clears them;
    incoming advisory actions won't auto-resume the pipeline.
    """
    _owned_brain(db, trip_id, current_user)
    TripBrainService(db).pause(trip_id, reason="user")


@router.post(
    "/trips/{trip_id}/advisory/resume",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def resume_advisory(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Explicit user resume — clears manual pauses."""
    _owned_brain(db, trip_id, current_user)
    TripBrainService(db).resume(trip_id, explicit_user_action=True)


@router.get("/trips/{trip_id}/advisory/state")
async def get_advisory_state(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return sanitized brain state for debugging.

    Gated: requires owner + settings.EXPOSE_ADVISORY_STATE_ENDPOINT.
    """
    if not settings.EXPOSE_ADVISORY_STATE_ENDPOINT:
        raise HTTPException(status_code=404, detail="not_found")
    brain = _owned_brain(db, trip_id, current_user)
    return {
        "trip_id": str(brain.trip_id),
        "lifecycle_state": brain.lifecycle_state,
        "trip_class": brain.trip_class,
        "cadence_seconds": brain.cadence_seconds,
        "mode": brain.mode,
        "last_cycle_at": brain.last_cycle_at,
        "next_eligible_at": brain.next_eligible_at,
        "last_seed_at": brain.last_seed_at,
        "last_seed_reason": brain.last_seed_reason,
        "ignore_streak": brain.ignore_streak,
        "advised_localities_count": len(brain.advised_locality_keys or []),
        "advised_pois_count": len(brain.advised_poi_place_ids or []),
        "pending_reseed_reasons": brain.pending_reseed_reasons or [],
        "paused_reason": brain.paused_reason,
        "paused_at": brain.paused_at,
        "brightdata_call_count": brain.brightdata_call_count,
    }
