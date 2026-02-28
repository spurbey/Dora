"""
Pydantic schemas for export API contracts.
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class ExportStatus(str, Enum):
    queued = "queued"
    processing = "processing"
    cancel_requested = "cancel_requested"
    completed = "completed"
    failed = "failed"
    canceled = "canceled"
    blocked = "blocked"


class ExportStage(str, Enum):
    snapshotting = "snapshotting"
    asset_fetch = "asset_fetch"
    rendering = "rendering"
    encoding = "encoding"
    uploading = "uploading"
    finalizing = "finalizing"


class ExportTemplate(str, Enum):
    classic = "classic"
    cinematic = "cinematic"


class ExportAspectRatio(str, Enum):
    vertical = "9:16"
    square = "1:1"
    horizontal = "16:9"


class ExportQuality(str, Enum):
    p480 = "480p"
    p720 = "720p"
    p1080 = "1080p"


class ExportCreateRequest(BaseModel):
    template: ExportTemplate = Field(default=ExportTemplate.classic)
    aspect_ratio: ExportAspectRatio = Field(default=ExportAspectRatio.vertical)
    duration_sec: int = Field(default=15, ge=1, le=60)
    quality: ExportQuality = Field(default=ExportQuality.p720)
    fps: int = Field(default=30, ge=1, le=60)


class ExportCreateResponse(BaseModel):
    job_id: UUID
    status: ExportStatus
    stage: Optional[ExportStage] = None
    progress: float = Field(ge=0.0, le=1.0)


class ExportStatusResponse(BaseModel):
    job_id: UUID
    status: ExportStatus
    stage: Optional[ExportStage] = None
    progress: float = Field(ge=0.0, le=1.0)
    output_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    error_code: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None


class ExportCancelResponse(BaseModel):
    status: ExportStatus


class ExportDownloadUrlResponse(BaseModel):
    download_url: str
    expires_at: datetime
    ttl_seconds: int


class ExportShareUrlResponse(BaseModel):
    share_url: str
    expires_at: datetime
    ttl_seconds: int


class ExportDuplicateErrorResponse(BaseModel):
    error: str = "duplicate_job"
    existing_job_id: UUID
    detail: str


class ExportPreconditionFailedResponse(BaseModel):
    error: str = "export_precondition_failed"
    reason: str
    detail: str
