"""add route tables

Revision ID: 90383dc1f729
Revises: fdacf42ca8c0
Create Date: 2026-02-02 02:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '90383dc1f729'
down_revision: Union[str, None] = 'fdacf42ca8c0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create routes table
    op.create_table(
        'routes',
        sa.Column('id', sa.UUID(), nullable=False, comment='Route ID'),
        sa.Column('trip_id', sa.UUID(), nullable=False, comment='FK to trips'),
        sa.Column('user_id', sa.UUID(), nullable=False, comment='FK to users'),
        sa.Column('route_geojson', postgresql.JSONB(), nullable=False, comment='GeoJSON LineString'),
        sa.Column('polyline_encoded', sa.Text(), nullable=True, comment='Google-encoded polyline (optional)'),
        sa.Column('start_place_id', sa.UUID(), nullable=True, comment='FK to trip_places'),
        sa.Column('end_place_id', sa.UUID(), nullable=True, comment='FK to trip_places'),
        sa.Column('transport_mode', sa.Text(), nullable=False, comment='car, bike, foot, air, bus, train'),
        sa.Column('route_category', sa.Text(), nullable=False, comment='ground, air'),
        sa.Column('distance_km', sa.Float(), nullable=True, comment='Auto-calculated'),
        sa.Column('duration_mins', sa.Integer(), nullable=True, comment='Auto-calculated'),
        sa.Column('order_in_trip', sa.Integer(), nullable=False, comment='Display order'),
        sa.Column('name', sa.Text(), nullable=True, comment='Optional route name'),
        sa.Column('description', sa.Text(), nullable=True, comment='User notes'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['trip_id'], ['trips.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['start_place_id'], ['trip_places.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['end_place_id'], ['trip_places.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
        sa.CheckConstraint(
            "transport_mode IN ('car', 'bike', 'foot', 'air', 'bus', 'train')",
            name='check_transport_mode'
        ),
        sa.CheckConstraint(
            "route_category IN ('ground', 'air')",
            name='check_route_category'
        ),
        sa.CheckConstraint(
            'distance_km >= 0 OR distance_km IS NULL',
            name='check_distance_positive'
        ),
        sa.CheckConstraint(
            'duration_mins >= 0 OR duration_mins IS NULL',
            name='check_duration_positive'
        ),
        sa.CheckConstraint(
            'order_in_trip >= 0',
            name='check_order_positive'
        ),
    )

    # Create indexes for routes
    op.create_index('idx_routes_trip', 'routes', ['trip_id'], unique=False)
    op.create_index('idx_routes_order', 'routes', ['trip_id', 'order_in_trip'], unique=False)

    # Create waypoints table
    op.create_table(
        'waypoints',
        sa.Column('id', sa.UUID(), nullable=False, comment='Waypoint ID'),
        sa.Column('route_id', sa.UUID(), nullable=False, comment='FK to routes'),
        sa.Column('trip_id', sa.UUID(), nullable=False, comment='FK to trips'),
        sa.Column('user_id', sa.UUID(), nullable=False, comment='FK to users'),
        sa.Column('lat', sa.Float(), nullable=False, comment='Latitude'),
        sa.Column('lng', sa.Float(), nullable=False, comment='Longitude'),
        sa.Column('name', sa.Text(), nullable=False, comment='Waypoint label'),
        sa.Column('waypoint_type', sa.Text(), nullable=False, comment='stop, note, photo, poi'),
        sa.Column('notes', sa.Text(), nullable=True, comment='User notes'),
        sa.Column('order_in_route', sa.Integer(), nullable=False, comment='Position along route'),
        sa.Column('stopped_at', sa.DateTime(timezone=True), nullable=True, comment='When user stopped here'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.ForeignKeyConstraint(['route_id'], ['routes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['trip_id'], ['trips.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.CheckConstraint(
            "waypoint_type IN ('stop', 'note', 'photo', 'poi')",
            name='check_waypoint_type'
        ),
        sa.CheckConstraint(
            'lat >= -90 AND lat <= 90',
            name='check_lat_range'
        ),
        sa.CheckConstraint(
            'lng >= -180 AND lng <= 180',
            name='check_lng_range'
        ),
        sa.CheckConstraint(
            'order_in_route >= 0',
            name='check_waypoint_order_positive'
        ),
    )

    # Create indexes for waypoints
    op.create_index('idx_waypoints_route', 'waypoints', ['route_id', 'order_in_route'], unique=False)

    # Create route_metadata table
    op.create_table(
        'route_metadata',
        sa.Column('route_id', sa.UUID(), nullable=False, comment='PK, FK to routes'),
        sa.Column('route_quality', sa.Text(), nullable=True, comment='scenic, fastest, offbeat'),
        sa.Column('road_condition', sa.Text(), nullable=True, comment='excellent, good, poor, offroad'),
        sa.Column('scenic_rating', sa.Integer(), nullable=True, comment='1-5'),
        sa.Column('safety_rating', sa.Integer(), nullable=False, server_default='3', comment='1-5, default 3'),
        sa.Column('solo_safe', sa.Boolean(), nullable=False, server_default='true', comment='Default TRUE'),
        sa.Column('fuel_cost', sa.Numeric(10, 2), nullable=True, comment='Estimated cost'),
        sa.Column('toll_cost', sa.Numeric(10, 2), nullable=True, comment='Toll charges'),
        sa.Column('highlights', postgresql.ARRAY(sa.Text()), nullable=True, comment="['waterfall', 'viewpoint']"),
        sa.Column('is_public', sa.Boolean(), nullable=False, server_default='false', comment='Default FALSE'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['route_id'], ['routes.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('route_id'),
        sa.CheckConstraint(
            "route_quality IN ('scenic', 'fastest', 'offbeat') OR route_quality IS NULL",
            name='check_route_quality'
        ),
        sa.CheckConstraint(
            "road_condition IN ('excellent', 'good', 'poor', 'offroad') OR road_condition IS NULL",
            name='check_road_condition'
        ),
        sa.CheckConstraint(
            'scenic_rating >= 1 AND scenic_rating <= 5 OR scenic_rating IS NULL',
            name='check_scenic_rating_range'
        ),
        sa.CheckConstraint(
            'safety_rating >= 1 AND safety_rating <= 5',
            name='check_safety_rating_range'
        ),
        sa.CheckConstraint(
            'fuel_cost >= 0 OR fuel_cost IS NULL',
            name='check_fuel_cost_positive'
        ),
        sa.CheckConstraint(
            'toll_cost >= 0 OR toll_cost IS NULL',
            name='check_toll_cost_positive'
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
        'idx_route_metadata_highlights',
        'route_metadata',
        ['highlights'],
        unique=False,
        postgresql_using='gin'
    )


def downgrade() -> None:
    # Drop route_metadata table and indexes
    op.drop_index('idx_route_metadata_highlights', table_name='route_metadata')
    op.drop_index('idx_route_metadata_public', table_name='route_metadata')
    op.drop_table('route_metadata')

    # Drop waypoints table and indexes
    op.drop_index('idx_waypoints_route', table_name='waypoints')
    op.drop_table('waypoints')

    # Drop routes table and indexes
    op.drop_index('idx_routes_order', table_name='routes')
    op.drop_index('idx_routes_trip', table_name='routes')
    op.drop_table('routes')
