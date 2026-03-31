"""
Compiled projection endpoints.
"""

from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.compiled_projection import (
    CompiledProjectionResponse,
    CompiledRebindRequest,
)
from app.services.trip_projection_compiler import TripProjectionCompilerService


router = APIRouter(tags=["CompiledProjection"])


@router.get(
    "/trips/{trip_id}/compiled/projection",
    response_model=CompiledProjectionResponse,
)
async def get_compiled_projection(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = TripProjectionCompilerService(db)
    return service.get_compiled_projection(
        trip_id=trip_id,
        user_id=current_user.id,
    )


@router.post(
    "/trips/{trip_id}/compiled/rebind",
    response_model=CompiledProjectionResponse,
)
async def rebind_compiled_projection_item(
    trip_id: UUID,
    request: CompiledRebindRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = TripProjectionCompilerService(db)
    service.save_manual_rebind(
        trip_id=trip_id,
        user_id=current_user.id,
        source_event_id=request.source_event_id,
        action=request.action,
        trip_place_id=request.trip_place_id,
    )
    return service.get_compiled_projection(
        trip_id=trip_id,
        user_id=current_user.id,
    )

