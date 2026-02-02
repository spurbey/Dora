"""merge heads

Revision ID: fdacf42ca8c0
Revises: a6cdd60d760c, ae14fa145f26
Create Date: 2026-02-02 20:05:12.304214

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fdacf42ca8c0'
down_revision: Union[str, None] = ('a6cdd60d760c', 'ae14fa145f26')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
