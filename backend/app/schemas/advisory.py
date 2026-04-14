"""
Pydantic schemas for advisory pipeline API contracts.
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


# ---------- Enums ----------

class AdvisoryJobStatus(str, Enum):
    queued = "queued"
    processing = "processing"
    cancel_requested = "cancel_requested"
    completed = "completed"
    failed = "failed"
    canceled = "canceled"
    blocked = "blocked"


class AdvisoryJobStage(str, Enum):
    route_segmentation = "route_segmentation"
    reddit_scrape = "reddit_scrape"
    tripadvisor_scrape = "tripadvisor_scrape"
    gmaps_scrape = "gmaps_scrape"
    llm_extraction = "llm_extraction"
    scoring = "scoring"
    delivery = "delivery"


class AdvisoryJobType(str, Enum):
    pre_trip = "pre_trip"
    on_demand = "on_demand"
    location_trigger = "location_trigger"


class AdvisoryCategory(str, Enum):
    safety_warning = "safety_warning"
    scam_alert = "scam_alert"
    food_tip = "food_tip"
    photo_spot = "photo_spot"
    transport_tip = "transport_tip"
    accommodation = "accommodation"
    cultural_etiquette = "cultural_etiquette"
    must_do = "must_do"
    avoid = "avoid"
    general_tip = "general_tip"


class AdvisorySource(str, Enum):
    reddit = "reddit"
    tripadvisor = "tripadvisor"
    google_maps = "google_maps"
    combined = "combined"


class AdvisoryDeliveryStatus(str, Enum):
    pending = "pending"
    delivered = "delivered"
    expired = "expired"


class UserActionType(str, Enum):
    dismissed = "dismissed"
    liked = "liked"
    saved = "saved"
    acted_on = "acted_on"
    converted_to_place = "converted_to_place"


# ---------- Requests ----------

class AdvisoryStartRequest(BaseModel):
    job_type: AdvisoryJobType = Field(default=AdvisoryJobType.pre_trip)
    trigger_payload: Optional[dict] = Field(
        default=None,
        description="For location_trigger: segment/city context",
    )


class AdvisoryQueryRequest(BaseModel):
    query_text: str = Field(
        ...,
        min_length=3,
        max_length=500,
        description="Natural-language query, e.g. 'find me a quiet cafe'",
    )


class AdvisoryActionRequest(BaseModel):
    action: UserActionType
    action_metadata: Optional[dict] = Field(
        default=None,
        description="Extra context, e.g. place_id saved to",
    )


# ---------- Responses ----------

class AdvisoryJobResponse(BaseModel):
    job_id: UUID
    status: AdvisoryJobStatus
    stage: Optional[AdvisoryJobStage] = None
    progress: float
    job_type: AdvisoryJobType
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    error_code: Optional[str] = None
    error_message: Optional[str] = None

    class Config:
        from_attributes = True


class AdvisoryJobListResponse(BaseModel):
    jobs: list[AdvisoryJobResponse]
    total: int


class AdvisoryInsightResponse(BaseModel):
    id: UUID
    category: AdvisoryCategory
    source: AdvisorySource
    title: str
    body: str
    place_name: Optional[str] = None
    place_lat: Optional[float] = None
    place_lng: Optional[float] = None
    confidence_score: float
    context_signal: Optional[str] = None
    best_for: Optional[str] = None
    source_urls: Optional[list[str]] = None
    source_count: int = 1
    status: AdvisoryDeliveryStatus
    observed_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True


class AdvisoryInsightListResponse(BaseModel):
    insights: list[AdvisoryInsightResponse]
    total: int


class AdvisoryActionResponse(BaseModel):
    id: UUID
    action: UserActionType
    created_at: datetime

    class Config:
        from_attributes = True
