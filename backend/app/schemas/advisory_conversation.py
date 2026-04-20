"""Pydantic schemas for the advisory conversation thread."""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class ConversationMessageResponse(BaseModel):
    id: UUID
    trip_id: UUID
    user_id: UUID
    role: str  # dora | user | system
    message_type: str
    content: Optional[str] = None
    message_metadata: Optional[dict] = None
    advisory_job_id: Optional[UUID] = None
    advisory_id: Optional[UUID] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ConversationListResponse(BaseModel):
    messages: list[ConversationMessageResponse]
    has_more: bool = False


class SendMessageRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=1000)
    reply_to_message_id: Optional[UUID] = None


class SendMessageResponse(BaseModel):
    message: ConversationMessageResponse
    job_id: UUID


class AnswerQuestionRequest(BaseModel):
    question_message_id: UUID
    answer: str = Field(..., min_length=1, max_length=500)
    metadata: Optional[dict] = None


class AnswerQuestionResponse(BaseModel):
    message: ConversationMessageResponse
    resumed_job_id: UUID
