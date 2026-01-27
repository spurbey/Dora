"""create signal tables

Revision ID: a6cdd60d760c
Revises: 6cfcf98fd21b
Create Date: 2026-01-28 02:28:45.111862

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import text


# revision identifiers, used by Alembic.
revision: str = 'a6cdd60d760c'
down_revision: Union[str, None] = '6cfcf98fd21b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create signal collection tables."""
    
    # Search events table
    op.create_table(
        'search_events',
        sa.Column(
            'id',
            sa.UUID(),
            server_default=text("gen_random_uuid()"),  # ChatGPT fix!
            nullable=False
        ),
        sa.Column('user_id', sa.UUID(), nullable=True),
        sa.Column('query', sa.Text(), nullable=False),
        sa.Column('lat', sa.Float(), nullable=True),
        sa.Column('lng', sa.Float(), nullable=True),
        sa.Column('radius_km', sa.Float(), nullable=True),
        sa.Column('results_count', sa.Integer(), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False
        ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_search_events_user', 'search_events', ['user_id'])
    op.create_index('idx_search_events_created', 'search_events', ['created_at'])
    
    # Place views table
    op.create_table(
        'place_views',
        sa.Column(
            'id',
            sa.UUID(),
            server_default=text("gen_random_uuid()"),  # ChatGPT fix!
            nullable=False
        ),
        sa.Column('user_id', sa.UUID(), nullable=True),
        sa.Column('place_id', sa.UUID(), nullable=True),
        sa.Column('source', sa.String(50), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False
        ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['place_id'], ['trip_places.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_place_views_user', 'place_views', ['user_id'])
    op.create_index('idx_place_views_place', 'place_views', ['place_id'])
    
    # Place saves table
    op.create_table(
        'place_saves',
        sa.Column(
            'id',
            sa.UUID(),
            server_default=text("gen_random_uuid()"),  # ChatGPT fix!
            nullable=False
        ),
        sa.Column('user_id', sa.UUID(), nullable=True),
        sa.Column('place_id', sa.UUID(), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False
        ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['place_id'], ['trip_places.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_place_saves_user', 'place_saves', ['user_id'])
    op.create_index('idx_place_saves_place', 'place_saves', ['place_id'])


def downgrade() -> None:
    """Drop signal collection tables."""
    
    op.drop_table('place_saves')
    op.drop_table('place_views')
    op.drop_table('search_events')
