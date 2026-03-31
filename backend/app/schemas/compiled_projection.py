"""
Schemas for compiled projection endpoints.
"""

from datetime import date, datetime
from typing import Any, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class CompiledTimelineEntry(BaseModel):
    entry_id: str
    source_kind: str
    source_id: UUID
    event_type: str
    captured_at: datetime
    bucket_type: str
    place_id: Optional[UUID] = None
    place_name: Optional[str] = None
    bind_source: str
    bind_confidence: Optional[float] = None
    reason_code: Optional[str] = None
    title: str
    subtitle: Optional[str] = None
    payload: dict[str, Any] = Field(default_factory=dict)


class CompiledTimelineDayGroup(BaseModel):
    day: date
    place_entries: list[CompiledTimelineEntry] = Field(default_factory=list)
    on_route_entries: list[CompiledTimelineEntry] = Field(default_factory=list)


class CompiledRouteSegment(BaseModel):
    segment_id: str
    session_id: Optional[UUID] = None
    started_at: datetime
    ended_at: datetime
    distance_m: float
    raw_point_count: int
    simplified_point_count: int
    geometry: dict[str, Any] = Field(default_factory=dict)


class CompiledProjectionStats(BaseModel):
    raw_event_count: int = 0
    compiled_event_count: int = 0
    raw_point_count: int = 0
    compiled_route_segment_count: int = 0
    has_drift: bool = False
    raw_event_count_delta: int = 0
    compiled_event_count_delta: int = 0
    compiled_route_segment_count_delta: int = 0
    raw_vs_compiled_event_delta: int = 0
    drift_reasons: list[str] = Field(default_factory=list)


class CompiledProjectionResponse(BaseModel):
    trip_id: UUID
    compiler_version: int
    stale: bool
    compiled_at: Optional[datetime] = None
    timeline_entries: list[CompiledTimelineEntry] = Field(default_factory=list)
    timeline_groups: list[CompiledTimelineDayGroup] = Field(default_factory=list)
    route_segments: list[CompiledRouteSegment] = Field(default_factory=list)
    stats: CompiledProjectionStats = Field(default_factory=CompiledProjectionStats)


class CompiledRebindRequest(BaseModel):
    source_event_id: UUID
    action: str = Field(..., pattern="^(bind|unbind)$")
    trip_place_id: Optional[UUID] = None
