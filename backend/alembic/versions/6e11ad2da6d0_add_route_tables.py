"""add route tables

Revision ID: 6e11ad2da6d0
Revises: ae14fa145f26
Create Date: 2026-02-02 01:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from geoalchemy2 import Geography

# revision identifiers, used by Alembic.
revision: str = '6e11ad2da6d0'
down_revision: Union[str, None] = 'ae14fa145f26'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create routes table
    op.create_table(
        'routes',
        sa.Column('id', sa.UUID(), nullable=False, comment='Route ID'),
        sa.Column('trip_id', sa.UUID(), nullable=False, comment='Trip ID (FK to trips.id)'),
        sa.Column('user_id', sa.UUID(), nullable=False, comment='Owner user ID'),
        sa.Column('from_place_id', sa.UUID(), nullable=True, comment='Starting place ID (nullable for trip start)'),
        sa.Column('to_place_id', sa.UUID(), nullable=True, comment='Ending place ID (nullable for trip end)'),
        sa.Column('transport_mode', sa.Text(), nullable=True, comment='flight, car, train, bus, ferry, walk, bike, other'),
        sa.Column('distance_km', sa.Float(), nullable=True, comment='Distance in kilometers'),
        sa.Column('duration_hours', sa.Float(), nullable=True, comment='Duration in hours'),
        sa.Column('waypoints', postgresql.JSONB(), nullable=True, comment='Array of waypoint objects: [{lat, lng, order}]'),
        sa.Column('notes', sa.Text(), nullable=True, comment='User notes about this route'),
        sa.Column('order_in_trip', sa.Integer(), nullable=True, comment='Position in trip timeline'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['trip_id'], ['trips.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['from_place_id'], ['trip_places.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['to_place_id'], ['trip_places.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
        sa.CheckConstraint(
            "transport_mode IN ('flight', 'car', 'train', 'bus', 'ferry', 'walk', 'bike', 'other') OR transport_mode IS NULL",
            name='check_transport_mode'
        ),
        sa.CheckConstraint(
            'distance_km >= 0 OR distance_km IS NULL',
            name='check_distance_positive'
        ),
        sa.CheckConstraint(
            'duration_hours > 0 OR duration_hours IS NULL',
            name='check_duration_positive'
        ),
    )

    # Create indexes for routes
    op.create_index('ix_routes_trip_id', 'routes', ['trip_id'], unique=False)
    op.create_index('ix_routes_user_id', 'routes', ['user_id'], unique=False)
    op.create_index('ix_routes_from_place_id', 'routes', ['from_place_id'], unique=False)
    op.create_index('ix_routes_to_place_id', 'routes', ['to_place_id'], unique=False)

    # Create route_metadata table
    op.create_table(
        'route_metadata',
        sa.Column('route_id', sa.UUID(), nullable=False, comment='Route ID (FK to routes.id)'),
        sa.Column('scenic_rating', sa.Integer(), nullable=True, comment='Scenic rating 1-5'),
        sa.Column('difficulty_rating', sa.Integer(), nullable=True, comment='Difficulty rating 1-5'),
        sa.Column('cost_estimate', sa.Numeric(10, 2), nullable=True, comment='Estimated cost'),
        sa.Column('currency', sa.Text(), nullable=True, server_default='USD', comment='Currency code (USD, EUR, etc.)'),
        sa.Column('tags', postgresql.ARRAY(sa.Text()), nullable=True, comment='User-defined tags'),
        sa.Column('is_public', sa.Boolean(), nullable=False, server_default='false', comment='Can this route be discovered publicly?'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['route_id'], ['routes.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('route_id'),
        sa.CheckConstraint(
            'scenic_rating >= 1 AND scenic_rating <= 5 OR scenic_rating IS NULL',
            name='check_scenic_rating_range'
        ),
        sa.CheckConstraint(
            'difficulty_rating >= 1 AND difficulty_rating <= 5 OR difficulty_rating IS NULL',
            name='check_difficulty_rating_range'
        ),
        sa.CheckConstraint(
            'cost_estimate >= 0 OR cost_estimate IS NULL',
            name='check_cost_positive'
        ),
    )

    # Create indexes for route_metadata
    op.create_index(
        'idx_route_metadata_public',
        'route_metadata',
        ['is_public'],
        unique=False,
        postgresql_where=sa.text('is_public = true')
    )
    op.create_index(
        'idx_route_metadata_tags',
        'route_metadata',
        ['tags'],
        unique=False,
        postgresql_using='gin'
    )


def downgrade() -> None:
    # Drop route_metadata table and indexes
    op.drop_index('idx_route_metadata_tags', table_name='route_metadata')
    op.drop_index('idx_route_metadata_public', table_name='route_metadata')
    op.drop_table('route_metadata')

    # Drop routes table and indexes
    op.drop_index('ix_routes_to_place_id', table_name='routes')
    op.drop_index('ix_routes_from_place_id', table_name='routes')
    op.drop_index('ix_routes_user_id', table_name='routes')
    op.drop_index('ix_routes_trip_id', table_name='routes')
    op.drop_table('routes')
