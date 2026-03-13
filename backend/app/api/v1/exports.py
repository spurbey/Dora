"""
Export control-plane API endpoints.
"""

from typing import Optional
from fastapi import APIRouter, Depends, Query, Response, status
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.export import (
    ExportCancelResponse,
    ExportCreateRequest,
    ExportCreateResponse,
    ExportDownloadUrlResponse,
    ExportJobListResponse,
    ExportShareUrlResponse,
    ExportStatus,
    ExportStatusResponse,
)
from app.services.export_service import ExportService


router = APIRouter(tags=["Exports"])


@router.post(
    "/trips/{trip_id}/export",
    response_model=ExportCreateResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def create_export(
    trip_id: UUID,
    request: ExportCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    job = service.create_export_job(user_id=current_user.id, trip_id=trip_id, request=request)
    return ExportCreateResponse(
        job_id=job.id,
        status=job.status,
        stage=job.stage,
        progress=job.progress,
    )


@router.get("/exports/{job_id}", response_model=ExportStatusResponse)
async def get_export_status(
    job_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    job = service.get_export_job(user_id=current_user.id, job_id=job_id)
    return ExportStatusResponse(
        job_id=job.id,
        status=job.status,
        stage=job.stage,
        progress=job.progress,
        output_url=job.output_url,
        thumbnail_url=job.thumbnail_url,
        error_code=job.error_code,
        error_message=job.error_message,
        render_duration_ms=job.render_duration_ms,
        created_at=job.created_at,
        started_at=job.started_at,
        completed_at=job.completed_at,
    )


@router.get("/exports", response_model=ExportJobListResponse)
async def list_exports(
    page: int = Query(1, ge=1, description="Page number (1-indexed)"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page"),
    status_filter: Optional[ExportStatus] = Query(
        None,
        alias="status",
        description="Optional status filter",
    ),
    trip_id: Optional[UUID] = Query(None, description="Optional trip filter"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    payload = service.list_export_jobs(
        user_id=current_user.id,
        page=page,
        page_size=page_size,
        status_filter=status_filter.value if status_filter else None,
        trip_id=trip_id,
    )
    return ExportJobListResponse(**payload)


@router.post("/exports/{job_id}/cancel", response_model=ExportCancelResponse)
async def cancel_export(
    job_id: UUID,
    response: Response,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    cancel_result = service.cancel_export_job(user_id=current_user.id, job_id=job_id)
    response.status_code = cancel_result.http_status
    return ExportCancelResponse(status=cancel_result.response_status)


@router.get("/exports/{job_id}/download-url", response_model=ExportDownloadUrlResponse)
async def get_export_download_url(
    job_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    payload = service.build_download_response(user_id=current_user.id, job_id=job_id)
    return ExportDownloadUrlResponse(**payload)


@router.get("/exports/{job_id}/share", response_model=ExportShareUrlResponse)
async def get_export_share_url(
    job_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    payload = service.build_share_response(user_id=current_user.id, job_id=job_id)
    return ExportShareUrlResponse(**payload)


@router.get("/shares/{token}", include_in_schema=False)
async def access_share_token(
    token: str,
    db: Session = Depends(get_db),
):
    service = ExportService(db)
    redirect_url = service.resolve_share_redirect(token=token)
    return RedirectResponse(url=redirect_url, status_code=status.HTTP_307_TEMPORARY_REDIRECT)
