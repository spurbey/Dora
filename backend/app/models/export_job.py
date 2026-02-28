"""
ExportJob model for durable video export lifecycle tracking.

This table is the control plane state for async export jobs.
"""

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class ExportJob(Base):
    """
    Durable export job model.

    Status state machine is defined in the Phase 6 PRD.
    """

    __tablename__ = "export_jobs"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Export job ID",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Owner user ID",
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
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
        comment="snapshotting|asset_fetch|rendering|encoding|uploading|finalizing",
    )
    progress = Column(
        Float,
        nullable=False,
        default=0.0,
        comment="Progress in range 0.0..1.0",
    )

    template = Column(String(50), nullable=False, comment="Export template key")
    aspect_ratio = Column(String(8), nullable=False, comment="9:16|1:1|16:9")
    duration_sec = Column(Integer, nullable=False, comment="Requested output duration")
    quality = Column(String(16), nullable=False, comment="480p|720p|1080p")
    fps = Column(Integer, nullable=False, default=30, comment="Frames per second")

    snapshot_json = Column(
        JSONB,
        nullable=False,
        comment="Immutable render snapshot payload (max 500KB, URL references only)",
    )
    snapshot_hash = Column(
        String(64),
        nullable=False,
        index=True,
        comment="SHA-256 hash of normalized snapshot + config",
    )

    output_url = Column(Text, nullable=True, comment="Final artifact URL")
    thumbnail_url = Column(Text, nullable=True, comment="Export thumbnail URL")
    pinned_at = Column(DateTime(timezone=True), nullable=True, comment="Artifact pin timestamp")
    revoked_at = Column(DateTime(timezone=True), nullable=True, comment="Share revocation timestamp")

    error_code = Column(String(64), nullable=True, comment="Structured terminal/retryable code")
    error_message = Column(Text, nullable=True, comment="Human-readable failure details")
    retry_count = Column(Integer, nullable=False, default=0, comment="Attempt count")
    max_retries = Column(Integer, nullable=False, default=3, comment="Maximum retry attempts")
    next_attempt_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Retry claim eligibility time",
    )

    worker_session_id = Column(String(64), nullable=True, comment="Current worker session token")
    renderer_job_id = Column(String(128), nullable=True, comment="Renderer-side render ID")

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Creation timestamp",
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update timestamp",
    )
    started_at = Column(DateTime(timezone=True), nullable=True, comment="Worker claim time")
    completed_at = Column(DateTime(timezone=True), nullable=True, comment="Terminal completion time")
    render_duration_ms = Column(
        BigInteger,
        nullable=True,
        comment="Total render duration in milliseconds",
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('queued', 'processing', 'cancel_requested', 'completed', 'failed', 'canceled', 'blocked')",
            name="check_export_job_status",
        ),
        CheckConstraint(
            "stage IS NULL OR stage IN ('snapshotting', 'asset_fetch', 'rendering', 'encoding', 'uploading', 'finalizing')",
            name="check_export_job_stage",
        ),
        CheckConstraint(
            "progress >= 0.0 AND progress <= 1.0",
            name="check_export_job_progress_range",
        ),
        CheckConstraint(
            "aspect_ratio IN ('9:16', '1:1', '16:9')",
            name="check_export_job_aspect_ratio",
        ),
        CheckConstraint(
            "quality IN ('480p', '720p', '1080p')",
            name="check_export_job_quality",
        ),
        CheckConstraint(
            "duration_sec > 0",
            name="check_export_job_duration_positive",
        ),
        CheckConstraint(
            "fps > 0",
            name="check_export_job_fps_positive",
        ),
        CheckConstraint(
            "retry_count >= 0",
            name="check_export_job_retry_count_non_negative",
        ),
        CheckConstraint(
            "max_retries >= 0",
            name="check_export_job_max_retries_non_negative",
        ),
    )

    def __repr__(self) -> str:
        return f"<ExportJob(id={self.id}, trip_id={self.trip_id}, status={self.status})>"
