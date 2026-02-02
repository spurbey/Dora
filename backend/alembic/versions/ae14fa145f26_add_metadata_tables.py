"""add metadata tables

Revision ID: ae14fa145f26
Revises: fc795732477e
Create Date: 2026-02-02 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'ae14fa145f26'
down_revision: Union[str, None] = 'fc795732477e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create trip_metadata table
    op.create_table(
        'trip_metadata',
        sa.Column('trip_id', sa.UUID(), nullable=False, comment='Trip ID (FK to trips.id)'),
        sa.Column('traveler_type', postgresql.ARRAY(sa.Text()), nullable=True, comment='solo, couple, family, group'),
        sa.Column('age_group', sa.Text(), nullable=True, comment='gen-z, millennial, gen-x, boomer'),
        sa.Column('travel_style', postgresql.ARRAY(sa.Text()), nullable=True, comment='adventure, luxury, budget, cultural, relaxed'),
        sa.Column('difficulty_level', sa.Text(), nullable=True, comment='easy, moderate, challenging, extreme'),
        sa.Column('budget_category', sa.Text(), nullable=True, comment='budget, mid-range, luxury'),
        sa.Column('activity_focus', postgresql.ARRAY(sa.Text()), nullable=True, comment='hiking, food, photography, nightlife, beaches'),
        sa.Column('is_discoverable', sa.Boolean(), nullable=False, server_default='false', comment='Can this trip be found in public search?'),
        sa.Column('quality_score', sa.Float(), nullable=False, server_default='0.0', comment='System-calculated quality (0-1)'),
        sa.Column('tags', postgresql.ARRAY(sa.Text()), nullable=True, comment='User-defined tags'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['trip_id'], ['trips.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('trip_id'),
        sa.CheckConstraint(
            "age_group IN ('gen-z', 'millennial', 'gen-x', 'boomer') OR age_group IS NULL",
            name='check_age_group'
        ),
        sa.CheckConstraint(
            "difficulty_level IN ('easy', 'moderate', 'challenging', 'extreme') OR difficulty_level IS NULL",
            name='check_difficulty_level'
        ),
        sa.CheckConstraint(
            "budget_category IN ('budget', 'mid-range', 'luxury') OR budget_category IS NULL",
            name='check_budget_category'
        ),
        sa.CheckConstraint(
            'quality_score >= 0.0 AND quality_score <= 1.0',
            name='check_quality_score_range'
        ),
    )

    # Create indexes for trip_metadata
    op.create_index(
        'idx_trip_metadata_discoverable',
        'trip_metadata',
        ['is_discoverable'],
        unique=False,
        postgresql_where=sa.text('is_discoverable = true')
    )
    op.create_index(
        'idx_trip_metadata_tags',
        'trip_metadata',
        ['tags'],
        unique=False,
        postgresql_using='gin'
    )
    op.create_index(
        'idx_trip_metadata_traveler_type',
        'trip_metadata',
        ['traveler_type'],
        unique=False,
        postgresql_using='gin'
    )
    op.create_index(
        'idx_trip_metadata_activity_focus',
        'trip_metadata',
        ['activity_focus'],
        unique=False,
        postgresql_using='gin'
    )

    # Create place_metadata table
    op.create_table(
        'place_metadata',
        sa.Column('place_id', sa.UUID(), nullable=False, comment='Place ID (FK to trip_places.id)'),
        sa.Column('component_type', sa.Text(), nullable=True, server_default='place', comment='city, place, activity, accommodation, food, transport'),
        sa.Column('experience_tags', postgresql.ARRAY(sa.Text()), nullable=True, comment='romantic, adventurous, peaceful, crowded, instagram-worthy'),
        sa.Column('best_for', postgresql.ARRAY(sa.Text()), nullable=True, comment='solo-travelers, couples, families, photographers, foodies'),
        sa.Column('budget_per_person', sa.Numeric(10, 2), nullable=True, comment='Estimated cost per person (USD)'),
        sa.Column('duration_hours', sa.Float(), nullable=True, comment='Recommended time to spend (hours)'),
        sa.Column('difficulty_rating', sa.Integer(), nullable=True, comment='Physical difficulty 1-5'),
        sa.Column('physical_demand', sa.Text(), nullable=True, comment='low, medium, high'),
        sa.Column('best_time', sa.Text(), nullable=True, comment='sunrise, morning, afternoon, sunset, night, anytime'),
        sa.Column('is_public', sa.Boolean(), nullable=False, server_default='false', comment='Can this place be discovered publicly?'),
        sa.Column('contribution_score', sa.Float(), nullable=False, server_default='0.0', comment='Quality score for this component (0-1)'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Creation timestamp'),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False, comment='Last update timestamp'),
        sa.ForeignKeyConstraint(['place_id'], ['trip_places.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('place_id'),
        sa.CheckConstraint(
            "component_type IN ('city', 'place', 'activity', 'accommodation', 'food', 'transport') OR component_type IS NULL",
            name='check_component_type'
        ),
        sa.CheckConstraint(
            "physical_demand IN ('low', 'medium', 'high') OR physical_demand IS NULL",
            name='check_physical_demand'
        ),
        sa.CheckConstraint(
            "best_time IN ('sunrise', 'morning', 'afternoon', 'sunset', 'night', 'anytime') OR best_time IS NULL",
            name='check_best_time'
        ),
        sa.CheckConstraint(
            'difficulty_rating >= 1 AND difficulty_rating <= 5 OR difficulty_rating IS NULL',
            name='check_difficulty_rating_range'
        ),
        sa.CheckConstraint(
            'contribution_score >= 0.0 AND contribution_score <= 1.0',
            name='check_contribution_score_range'
        ),
        sa.CheckConstraint(
            'duration_hours > 0 OR duration_hours IS NULL',
            name='check_duration_hours_positive'
        ),
        sa.CheckConstraint(
            'budget_per_person >= 0 OR budget_per_person IS NULL',
            name='check_budget_per_person_positive'
        ),
    )

    # Create indexes for place_metadata
    op.create_index(
        'idx_place_metadata_public',
        'place_metadata',
        ['is_public'],
        unique=False,
        postgresql_where=sa.text('is_public = true')
    )
    op.create_index(
        'idx_place_metadata_component_type',
        'place_metadata',
        ['component_type'],
        unique=False
    )
    op.create_index(
        'idx_place_metadata_tags',
        'place_metadata',
        ['experience_tags'],
        unique=False,
        postgresql_using='gin'
    )
    op.create_index(
        'idx_place_metadata_best_for',
        'place_metadata',
        ['best_for'],
        unique=False,
        postgresql_using='gin'
    )


def downgrade() -> None:
    # Drop place_metadata table and indexes
    op.drop_index('idx_place_metadata_best_for', table_name='place_metadata')
    op.drop_index('idx_place_metadata_tags', table_name='place_metadata')
    op.drop_index('idx_place_metadata_component_type', table_name='place_metadata')
    op.drop_index('idx_place_metadata_public', table_name='place_metadata')
    op.drop_table('place_metadata')

    # Drop trip_metadata table and indexes
    op.drop_index('idx_trip_metadata_activity_focus', table_name='trip_metadata')
    op.drop_index('idx_trip_metadata_traveler_type', table_name='trip_metadata')
    op.drop_index('idx_trip_metadata_tags', table_name='trip_metadata')
    op.drop_index('idx_trip_metadata_discoverable', table_name='trip_metadata')
    op.drop_table('trip_metadata')
