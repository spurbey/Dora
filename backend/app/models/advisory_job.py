"""
AdvisoryJob model for durable advisory pipeline lifecycle tracking.

Follows the same state machine pattern as ExportJob.
"""

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class AdvisoryJob(Base):
    """
    Durable advisory job model.

    Status state machine:
        queued → processing → completed | failed | blocked
        processing → cancel_requested → canceled
        failed → queued (retry with backoff)
    """

    __tablename__ = "advisory_jobs"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Advisory job ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Target trip ID",
    )

    status = Column(
        String(32),
        nullable=False,
        default="queued",
        comment="queued|processing|cancel_requested|completed|failed|canceled|blocked",
    )
    stage = Column(
        String(32),
        nullable=True,
        comment="Current pipeline stage",
    )
    progress = Column(
        Float,
        nullable=False,
        default=0.0,
        comment="Progress 0.0..1.0",
    )

    job_type = Column(
        String(32),
        nullable=False,
        comment="pre_trip|on_demand|location_trigger",
    )
    request_hash = Column(
        String(64),
        nullable=False,
        comment="SHA-256 of (job_type, normalized_query) for idempotency",
    )

    query_text = Column(
        Text,
        nullable=True,
        comment="Raw NL query for on_demand jobs",
    )
    parent_message_id = Column(
        UUID(as_uuid=True),
        ForeignKey("advisory_conversation_messages.id", ondelete="SET NULL"),
        nullable=True,
        comment="Conversation message that triggered this job (on_demand only)",
    )
    parsed_filters = Column(
        JSONB,
        nullable=True,
        comment="LLM-parsed intent from query_text (populated by worker)",
    )
    scrape_plan = Column(
        JSONB,
        nullable=True,
        comment="Orchestrator output: seeds, keywords, extraction instructions",
    )
    result_summary = Column(
        JSONB,
        nullable=True,
        comment="Intermediate results accumulated across stages",
    )

    error_code = Column(String(64), nullable=True, comment="Structured error code")
    error_message = Column(Text, nullable=True, comment="Human-readable error")
    retry_count = Column(Integer, nullable=False, default=0, comment="Attempt count")
    max_retries = Column(Integer, nullable=False, default=3, comment="Max retry attempts")
    next_attempt_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Retry eligibility time",
    )

    worker_session_id = Column(String(64), nullable=True, comment="Current worker session")

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
    started_at = Column(DateTime(timezone=True), nullable=True, comment="Worker claim time")
    completed_at = Column(DateTime(timezone=True), nullable=True, comment="Terminal time")

    __table_args__ = (
        CheckConstraint(
            "status IN ('queued', 'processing', 'cancel_requested', 'completed', 'failed', 'canceled', 'blocked')",
            name="check_advisory_job_status",
        ),
        CheckConstraint(
            "stage IS NULL OR stage IN ("
            "'route_segmentation', 'reddit_scrape', 'tripadvisor_scrape', "
            "'gmaps_scrape', 'llm_extraction', 'scoring', 'delivery')",
            name="check_advisory_job_stage",
        ),
        CheckConstraint(
            "progress >= 0.0 AND progress <= 1.0",
            name="check_advisory_job_progress_range",
        ),
        CheckConstraint(
            "job_type IN ('pre_trip', 'on_demand', 'location_trigger')",
            name="check_advisory_job_type",
        ),
        CheckConstraint(
            "retry_count >= 0",
            name="check_advisory_job_retry_non_negative",
        ),
        CheckConstraint(
            "max_retries >= 0",
            name="check_advisory_job_max_retries_non_negative",
        ),
        Index("idx_advisory_jobs_status_next_attempt", "status", "next_attempt_at"),
        Index("idx_advisory_jobs_user_status", "user_id", "status"),
        Index("idx_advisory_jobs_trip", "trip_id"),
        Index(
            "uq_advisory_jobs_active_per_trip",
            "trip_id",
            "job_type",
            "request_hash",
            unique=True,
            postgresql_where=text("status IN ('queued', 'processing')"),
        ),
    )

    def __repr__(self) -> str:
        return f"<AdvisoryJob(id={self.id}, trip_id={self.trip_id}, type={self.job_type}, status={self.status})>"
