"""add stories feed keyset index

Revision ID: d8b7c6a5e4f3
Revises: c4d1e7b9a2f5
Create Date: 2026-04-27
"""

from typing import Sequence, Union

from alembic import op


revision: str = "d8b7c6a5e4f3"
down_revision: Union[str, None] = "b8a3d6f1c5e2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_stories_feed_active_keyset
        ON stories (published_at DESC, id DESC, author_user_id, expires_at)
        WHERE status = 'published'
          AND deleted_at IS NULL
          AND published_at IS NOT NULL
          AND expires_at IS NOT NULL
        """
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS idx_stories_feed_active_keyset")
