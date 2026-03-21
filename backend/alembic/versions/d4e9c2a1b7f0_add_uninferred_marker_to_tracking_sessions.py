"""add uninferred marker to tracking sessions

Revision ID: d4e9c2a1b7f0
Revises: b7c2e1d4f9a3
Create Date: 2026-03-22 01:05:00.000000

Rollback notes:
- Drops uninferred marker column/index from trip_tracking_sessions.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "d4e9c2a1b7f0"
down_revision: Union[str, None] = "b7c2e1d4f9a3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "trip_tracking_sessions",
        sa.Column(
            "oldest_uninferred_point_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Oldest ingested point timestamp not yet considered by inference",
        ),
    )
    op.create_index(
        "idx_tracking_sessions_uninferred_marker",
        "trip_tracking_sessions",
        ["state", "oldest_uninferred_point_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("idx_tracking_sessions_uninferred_marker", table_name="trip_tracking_sessions")
    op.drop_column("trip_tracking_sessions", "oldest_uninferred_point_at")
