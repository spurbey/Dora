from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, validator


class UserMetadataUpdate(BaseModel):
    dietary_restrictions: Optional[list[str]] = None
    dislikes: Optional[list[str]] = None
    preferred_travel_style: Optional[list[str]] = None
    budget_range: Optional[str] = None
    notification_enabled: Optional[bool] = None

    @validator("budget_range")
    def validate_budget_range(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            allowed = ["shoestring", "budget", "mid", "premium", "luxury"]
            if v not in allowed:
                raise ValueError(f'budget_range must be one of: {", ".join(allowed)}')
        return v


class UserMetadataResponse(BaseModel):
    user_id: UUID
    dietary_restrictions: list[str]
    budget_range: Optional[str] = None
    preferred_travel_style: list[str]
    dislikes: list[str]
    notification_enabled: bool
    advisory_quiet_hours: Optional[dict] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
