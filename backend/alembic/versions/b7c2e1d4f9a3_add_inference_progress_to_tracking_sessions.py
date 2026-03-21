"""add inference progress cursor to tracking sessions

Revision ID: b7c2e1d4f9a3
Revises: c2d4f6a8b0e1
Create Date: 2026-03-22 00:10:00.000000

Rollback notes:
- Drops inference progress columns and index from trip_tracking_sessions.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "b7c2e1d4f9a3"
down_revision: Union[str, None] = "c2d4f6a8b0e1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "trip_tracking_sessions",
        sa.Column(
            "inference_cursor_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Latest point timestamp processed by inference worker",
        ),
    )
    op.add_column(
        "trip_tracking_sessions",
        sa.Column(
            "inference_updated_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Last successful inference processing timestamp",
        ),
    )
    op.create_index(
        "idx_tracking_sessions_inference_progress",
        "trip_tracking_sessions",
        ["state", "last_point_at", "inference_cursor_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("idx_tracking_sessions_inference_progress", table_name="trip_tracking_sessions")
    op.drop_column("trip_tracking_sessions", "inference_updated_at")
    op.drop_column("trip_tracking_sessions", "inference_cursor_at")
