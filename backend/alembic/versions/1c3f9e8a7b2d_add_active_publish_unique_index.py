"""add active publish uniqueness index

Revision ID: 1c3f9e8a7b2d
Revises: a6e0b4d2f113
Create Date: 2026-04-13 12:30:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "1c3f9e8a7b2d"
down_revision: Union[str, None] = "a6e0b4d2f113"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_index(
        "uq_trip_commit_manifest_trip_active_publish",
        "trip_commit_manifest",
        ["trip_server_id"],
        unique=True,
        postgresql_where=sa.text(
            "operation_kind = 'trip_publish' AND status IN ('started','failed_retryable')"
        ),
    )


def downgrade() -> None:
    op.drop_index(
        "uq_trip_commit_manifest_trip_active_publish",
        table_name="trip_commit_manifest",
    )

