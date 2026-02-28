"""create export_jobs table

Revision ID: b1e4c7d9f2a1
Revises: 44f915b7a490
Create Date: 2026-02-27 10:00:00.000000

Rollback notes:
- Downgrade drops `export_jobs` and all related indexes.
- Any queued/processing/completed export state is permanently removed.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "b1e4c7d9f2a1"
down_revision: Union[str, None] = "44f915b7a490"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "export_jobs",
        sa.Column("id", sa.UUID(), nullable=False, comment="Export job ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Target trip ID"),
        sa.Column(
            "status",
            sa.String(length=32),
            nullable=False,
            server_default="queued",
            comment="queued|processing|cancel_requested|completed|failed|canceled|blocked",
        ),
        sa.Column(
            "stage",
            sa.String(length=32),
            nullable=True,
            comment="snapshotting|asset_fetch|rendering|encoding|uploading|finalizing",
        ),
        sa.Column("progress", sa.Float(), nullable=False, server_default="0.0", comment="Progress 0.0..1.0"),
        sa.Column("template", sa.String(length=50), nullable=False, comment="Export template key"),
        sa.Column("aspect_ratio", sa.String(length=8), nullable=False, comment="9:16|1:1|16:9"),
        sa.Column("duration_sec", sa.Integer(), nullable=False, comment="Requested output duration"),
        sa.Column("quality", sa.String(length=16), nullable=False, comment="480p|720p|1080p"),
        sa.Column("fps", sa.Integer(), nullable=False, server_default="30", comment="Frames per second"),
        sa.Column(
            "snapshot_json",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Immutable render snapshot payload (max 500KB)",
        ),
        sa.Column("snapshot_hash", sa.String(length=64), nullable=False, comment="SHA-256 hash"),
        sa.Column("output_url", sa.Text(), nullable=True, comment="Final artifact URL"),
        sa.Column("thumbnail_url", sa.Text(), nullable=True, comment="Export thumbnail URL"),
        sa.Column("pinned_at", sa.DateTime(timezone=True), nullable=True, comment="Artifact pin timestamp"),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True, comment="Share revocation timestamp"),
        sa.Column("error_code", sa.String(length=64), nullable=True, comment="Structured error code"),
        sa.Column("error_message", sa.Text(), nullable=True, comment="Failure details"),
        sa.Column("retry_count", sa.Integer(), nullable=False, server_default="0", comment="Attempt count"),
        sa.Column("max_retries", sa.Integer(), nullable=False, server_default="3", comment="Maximum retry attempts"),
        sa.Column(
            "next_attempt_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Retry claim eligibility time",
        ),
        sa.Column("worker_session_id", sa.String(length=64), nullable=True, comment="Current worker session token"),
        sa.Column("renderer_job_id", sa.String(length=128), nullable=True, comment="Renderer-side render ID"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("render_duration_ms", sa.BigInteger(), nullable=True),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint(
            "status IN ('queued', 'processing', 'cancel_requested', 'completed', 'failed', 'canceled', 'blocked')",
            name="check_export_job_status",
        ),
        sa.CheckConstraint(
            "stage IS NULL OR stage IN ('snapshotting', 'asset_fetch', 'rendering', 'encoding', 'uploading', 'finalizing')",
            name="check_export_job_stage",
        ),
        sa.CheckConstraint("progress >= 0.0 AND progress <= 1.0", name="check_export_job_progress_range"),
        sa.CheckConstraint("aspect_ratio IN ('9:16', '1:1', '16:9')", name="check_export_job_aspect_ratio"),
        sa.CheckConstraint("quality IN ('480p', '720p', '1080p')", name="check_export_job_quality"),
        sa.CheckConstraint("duration_sec > 0", name="check_export_job_duration_positive"),
        sa.CheckConstraint("fps > 0", name="check_export_job_fps_positive"),
        sa.CheckConstraint("retry_count >= 0", name="check_export_job_retry_count_non_negative"),
        sa.CheckConstraint("max_retries >= 0", name="check_export_job_max_retries_non_negative"),
    )

    op.create_index("idx_export_jobs_user_status", "export_jobs", ["user_id", "status"], unique=False)
    op.create_index("idx_export_jobs_status_next_attempt", "export_jobs", ["status", "next_attempt_at"], unique=False)
    op.create_index("idx_export_jobs_trip", "export_jobs", ["trip_id"], unique=False)
    op.create_index("idx_export_jobs_snapshot_hash", "export_jobs", ["snapshot_hash"], unique=False)


def downgrade() -> None:
    op.drop_index("idx_export_jobs_snapshot_hash", table_name="export_jobs")
    op.drop_index("idx_export_jobs_trip", table_name="export_jobs")
    op.drop_index("idx_export_jobs_status_next_attempt", table_name="export_jobs")
    op.drop_index("idx_export_jobs_user_status", table_name="export_jobs")
    op.drop_table("export_jobs")
