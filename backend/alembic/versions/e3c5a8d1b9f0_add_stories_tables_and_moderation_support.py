"""add stories tables and moderation support

Revision ID: e3c5a8d1b9f0
Revises: d2f4e8a91b56
Create Date: 2026-04-21

"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "e3c5a8d1b9f0"
down_revision = "d2f4e8a91b56"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "stories",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("client_story_id", sa.String(length=64), nullable=False),
        sa.Column("author_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("media_type", sa.String(length=16), nullable=False),
        sa.Column("media_url", sa.Text(), nullable=True),
        sa.Column("thumbnail_url", sa.Text(), nullable=True),
        sa.Column("duration_ms", sa.BigInteger(), nullable=True),
        sa.Column("center_lat", sa.Float(), nullable=False),
        sa.Column("center_lng", sa.Float(), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="draft"),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("view_count", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("last_error_code", sa.String(length=64), nullable=True),
        sa.Column("last_error_message", sa.Text(), nullable=True),
        sa.Column("storage_object_path", sa.Text(), nullable=True),
        sa.Column("thumbnail_object_path", sa.Text(), nullable=True),
        sa.Column("media_purged_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("thumbnail_purged_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["author_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.CheckConstraint("media_type IN ('photo', 'video')", name="ck_stories_media_type"),
        sa.CheckConstraint(
            "status IN ('draft', 'publishing', 'published', 'failed', 'expired', 'deleted', 'moderation_hidden')",
            name="ck_stories_status",
        ),
        sa.UniqueConstraint("client_story_id", name="uq_stories_client_story_id"),
    )
    op.create_index("ix_stories_author_user_id", "stories", ["author_user_id"])
    op.create_index("ix_stories_status", "stories", ["status"])
    op.create_index("ix_stories_published_at", "stories", ["published_at"])
    op.create_index("ix_stories_expires_at", "stories", ["expires_at"])
    op.create_index("ix_stories_deleted_at", "stories", ["deleted_at"])
    op.create_index(
        "idx_stories_author_status_published",
        "stories",
        ["author_user_id", "status", "published_at"],
    )
    op.create_index(
        "idx_stories_active_window",
        "stories",
        ["status", "published_at", "expires_at"],
    )

    op.create_table(
        "story_author_mutes",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("muted_author_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["muted_author_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "muted_author_id", name="uq_story_author_mutes_user_author"),
    )
    op.create_index("ix_story_author_mutes_user_id", "story_author_mutes", ["user_id"])
    op.create_index("ix_story_author_mutes_muted_author_id", "story_author_mutes", ["muted_author_id"])

    op.create_table(
        "story_reports",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("story_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reporter_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.String(length=64), nullable=False),
        sa.Column("details", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["story_id"], ["stories.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["reporter_user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_story_reports_story_id", "story_reports", ["story_id"])
    op.create_index("ix_story_reports_reporter_user_id", "story_reports", ["reporter_user_id"])
    op.create_index("idx_story_reports_story_created", "story_reports", ["story_id", "created_at"])


def downgrade() -> None:
    op.drop_index("idx_story_reports_story_created", table_name="story_reports")
    op.drop_index("ix_story_reports_reporter_user_id", table_name="story_reports")
    op.drop_index("ix_story_reports_story_id", table_name="story_reports")
    op.drop_table("story_reports")

    op.drop_index("ix_story_author_mutes_muted_author_id", table_name="story_author_mutes")
    op.drop_index("ix_story_author_mutes_user_id", table_name="story_author_mutes")
    op.drop_table("story_author_mutes")

    op.drop_index("idx_stories_active_window", table_name="stories")
    op.drop_index("idx_stories_author_status_published", table_name="stories")
    op.drop_index("ix_stories_deleted_at", table_name="stories")
    op.drop_index("ix_stories_expires_at", table_name="stories")
    op.drop_index("ix_stories_published_at", table_name="stories")
    op.drop_index("ix_stories_status", table_name="stories")
    op.drop_index("ix_stories_author_user_id", table_name="stories")
    op.drop_table("stories")
