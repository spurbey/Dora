"""
Stories API endpoints.
"""

from __future__ import annotations

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.story import (
    StoryFeedResponse,
    StoryModerationResponse,
    StoryMuteResponse,
    StoryReportRequest,
    StoryResponse,
)
from app.services.story_service import StoryService

router = APIRouter(prefix="/stories", tags=["Stories"])


def _serialize_story(story, *, is_own: bool = False, distance_km: Optional[float] = None) -> StoryResponse:
    return StoryResponse(
        id=story.id,
        client_story_id=story.client_story_id,
        author_user_id=story.author_user_id,
        media_type=story.media_type,
        media_url=story.media_url,
        thumbnail_url=story.thumbnail_url,
        duration_ms=story.duration_ms,
        center_lat=story.center_lat,
        center_lng=story.center_lng,
        status=story.status,
        published_at=story.published_at,
        expires_at=story.expires_at,
        deleted_at=story.deleted_at,
        view_count=int(story.view_count or 0),
        created_at=story.created_at,
        updated_at=story.updated_at,
        is_own=is_own,
        distance_km=distance_km,
    )


@router.post("/publish", response_model=StoryResponse, status_code=status.HTTP_201_CREATED)
async def publish_story(
    client_story_id: str = Form(..., min_length=6, max_length=64),
    media_type: str = Form(..., description="photo | video"),
    center_lat: float = Form(...),
    center_lng: float = Form(...),
    duration_ms: Optional[int] = Form(None, ge=0),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if center_lat < -90 or center_lat > 90 or center_lng < -180 or center_lng > 180:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid story location coordinates",
        )
    service = StoryService(db)
    row = await service.publish_story(
        user_id=current_user.id,
        client_story_id=client_story_id.strip(),
        media_type=media_type.strip(),
        center_lat=center_lat,
        center_lng=center_lng,
        file=file,
        duration_ms=duration_ms,
    )
    return _serialize_story(row, is_own=row.author_user_id == current_user.id)


@router.get("/feed", response_model=StoryFeedResponse)
async def get_story_feed(
    lat: Optional[float] = Query(None),
    lng: Optional[float] = Query(None),
    radius_km: str = Query("5", description="1 | 5 | 25 | all"),
    cursor: Optional[str] = Query(None),
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    radius_value: Optional[float]
    normalized = radius_km.strip().lower()
    if normalized == "all":
        radius_value = None
    else:
        try:
            radius_value = float(normalized)
        except ValueError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="radius_km must be a number or 'all'",
            ) from exc
        if radius_value < 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="radius_km must be non-negative",
            )

    service = StoryService(db)
    rows, next_cursor = service.list_feed(
        user_id=current_user.id,
        viewer_lat=lat,
        viewer_lng=lng,
        radius_km=radius_value,
        cursor=cursor,
        limit=limit,
    )
    stories = [
        _serialize_story(row, is_own=is_own, distance_km=distance_km)
        for row, distance_km, is_own in rows
    ]
    return StoryFeedResponse(stories=stories, next_cursor=next_cursor)


@router.get("/{story_id}", response_model=StoryResponse)
async def get_story(
    story_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    story = service.get_story_for_viewer(story_id=story_id, user_id=current_user.id)
    return _serialize_story(story, is_own=story.author_user_id == current_user.id)


@router.delete("/{story_id}", response_model=StoryResponse)
async def delete_story(
    story_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    story = service.delete_story(story_id=story_id, user_id=current_user.id)
    return _serialize_story(story, is_own=True)


@router.post("/{story_id}/report", status_code=status.HTTP_202_ACCEPTED)
async def report_story(
    story_id: UUID,
    body: StoryReportRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    service.report_story(
        story_id=story_id,
        reporter_user_id=current_user.id,
        reason=body.reason,
        details=body.details,
    )
    return {"accepted": True}


@router.post("/authors/{author_id}/mute", response_model=StoryMuteResponse)
async def mute_story_author(
    author_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    row = service.mute_author(
        user_id=current_user.id,
        muted_author_id=author_id,
    )
    return StoryMuteResponse(muted_author_id=row.muted_author_id, muted=True)


@router.post("/{story_id}/view", response_model=StoryResponse)
async def mark_story_viewed(
    story_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    row = service.record_view(story_id=story_id, viewer_user_id=current_user.id)
    return _serialize_story(row, is_own=row.author_user_id == current_user.id)


@router.post("/{story_id}/moderation-hide", response_model=StoryModerationResponse)
async def moderation_hide_story(
    story_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = StoryService(db)
    row = service.moderation_hide(
        story_id=story_id,
        moderator_user_id=current_user.id,
    )
    return StoryModerationResponse(story_id=row.id, status=row.status)
