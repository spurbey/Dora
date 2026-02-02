"""merge route heads

Revision ID: cca061e41224
Revises: 90383dc1f729, a2f6b9c1d0e2
Create Date: 2026-02-03 00:54:37.031006

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'cca061e41224'
down_revision: Union[str, None] = ('90383dc1f729', 'a2f6b9c1d0e2')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
