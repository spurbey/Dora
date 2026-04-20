"""
AdvisoryConversationMessage model — per-trip conversation thread between
Dora and the user.

One thread per trip (keyed by trip_id). Messages are append-only; roles are
dora | user | system. Message types cover advisory suggestions, clarifying
questions, user queries/responses, and system notes.
"""

import uuid

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func

from app.database import Base


class AdvisoryConversationMessage(Base):
    __tablename__ = "advisory_conversation_messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    role = Column(
        String(16),
        nullable=False,
        comment="dora | user | system",
    )
    message_type = Column(
        String(32),
        nullable=False,
        comment=(
            "advisory_suggestion | clarifying_question | user_query | "
            "user_response | system_note | greeting"
        ),
    )

    content = Column(Text, nullable=True, comment="User-visible text")
    message_metadata = Column(
        JSONB,
        nullable=True,
        comment="Type-specific payload (options, advisory_id, etc.)",
    )

    advisory_job_id = Column(
        UUID(as_uuid=True),
        ForeignKey("advisory_jobs.id", ondelete="SET NULL"),
        nullable=True,
    )
    advisory_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_advisories.id", ondelete="SET NULL"),
        nullable=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
    )

    __table_args__ = (
        Index("ix_conv_trip_created", "trip_id", "created_at"),
        CheckConstraint(
            "role IN ('dora', 'user', 'system')",
            name="ck_conv_role",
        ),
    )

    def to_dict(self) -> dict:
        return {
            "id": str(self.id),
            "trip_id": str(self.trip_id),
            "user_id": str(self.user_id),
            "role": self.role,
            "message_type": self.message_type,
            "content": self.content,
            "message_metadata": self.message_metadata,
            "advisory_job_id": str(self.advisory_job_id) if self.advisory_job_id else None,
            "advisory_id": str(self.advisory_id) if self.advisory_id else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
