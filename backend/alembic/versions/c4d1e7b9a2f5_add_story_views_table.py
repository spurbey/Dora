"""add story views receipt table for idempotent story view counting

Revision ID: c4d1e7b9a2f5
Revises: a7f9c2e4d8b1
Create Date: 2026-04-27
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "c4d1e7b9a2f5"
down_revision: Union[str, None] = "a7f9c2e4d8b1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "story_views",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("story_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("viewer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["story_id"], ["stories.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["viewer_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("story_id", "viewer_user_id", name="uq_story_views_story_viewer"),
    )
    op.create_index("ix_story_views_story_id", "story_views", ["story_id"])
    op.create_index("ix_story_views_viewer_user_id", "story_views", ["viewer_user_id"])
    op.create_index("idx_story_views_story_created", "story_views", ["story_id", "created_at"])


def downgrade() -> None:
    op.drop_index("idx_story_views_story_created", table_name="story_views")
    op.drop_index("ix_story_views_viewer_user_id", table_name="story_views")
    op.drop_index("ix_story_views_story_id", table_name="story_views")
    op.drop_table("story_views")
