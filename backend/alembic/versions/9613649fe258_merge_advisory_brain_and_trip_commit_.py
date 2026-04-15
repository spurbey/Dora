"""merge advisory brain and trip commit manifest heads

Revision ID: 9613649fe258
Revises: 2a9c5d7e4f11, a1b2c3d4e5f6
Create Date: 2026-04-16 03:22:10.708339

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9613649fe258'
down_revision: Union[str, None] = ('2a9c5d7e4f11', 'a1b2c3d4e5f6')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
