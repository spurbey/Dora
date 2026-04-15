"""widen trip_commit_manifest idempotency key length

Revision ID: 2a9c5d7e4f11
Revises: ffd82b6d69e4
Create Date: 2026-04-15 15:20:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "2a9c5d7e4f11"
down_revision: Union[str, None] = "ffd82b6d69e4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "trip_commit_manifest",
        "idempotency_key",
        existing_type=sa.String(length=128),
        type_=sa.String(length=256),
        existing_nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "trip_commit_manifest",
        "idempotency_key",
        existing_type=sa.String(length=256),
        type_=sa.String(length=128),
        existing_nullable=False,
    )

