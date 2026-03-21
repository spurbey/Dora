"""drop legacy duplicate routes trip_id index

Revision ID: f3a7b8c9d0e1
Revises: e9b3f0a7c1d2
Create Date: 2026-03-21 19:10:00.000000

"""

from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = "f3a7b8c9d0e1"
down_revision: Union[str, None] = "e9b3f0a7c1d2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drop duplicate legacy index; idx_routes_trip remains authoritative.
    op.execute("DROP INDEX IF EXISTS ix_routes_trip_id")


def downgrade() -> None:
    op.execute("CREATE INDEX IF NOT EXISTS ix_routes_trip_id ON routes (trip_id)")
