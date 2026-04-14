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
from app.services.advisory_service import AdvisoryService

router = APIRouter(tags=["Advisory"])


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
    """Record a user engagement action (append-only)."""
    service = AdvisoryService(db)
    action = service.record_user_action(
        user_id=current_user.id,
        advisory_id=advisory_id,
        action=request.action.value,
        action_metadata=request.action_metadata,
    )
    return AdvisoryActionResponse(
        id=action.id,
        action=action.action,
        created_at=action.created_at,
    )
