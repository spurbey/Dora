"""add_trip_components_view

Revision ID: 44f915b7a490
Revises: cca061e41224
Create Date: 2026-02-03 01:18:22.522067

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '44f915b7a490'
down_revision: Union[str, None] = 'cca061e41224'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create view combining places and routes
    # NOTE: No ORDER BY in view - PostgreSQL doesn't guarantee view ordering
    # Always use ORDER BY in SELECT queries from this view
    op.execute("""
        CREATE OR REPLACE VIEW trip_components_view AS
        SELECT
            id,
            trip_id,
            user_id,
            'place'::text as component_type,
            name,
            order_in_trip,
            created_at,
            updated_at,
            'trip_places'::text as source_table,
            id as source_id
        FROM trip_places
        UNION ALL
        SELECT
            id,
            trip_id,
            user_id,
            'route'::text as component_type,
            COALESCE(name, 'Route'::text) as name,
            order_in_trip,
            created_at,
            updated_at,
            'routes'::text as source_table,
            id as source_id
        FROM routes;
    """)


def downgrade() -> None:
    # Drop the view
    op.execute("DROP VIEW IF EXISTS trip_components_view;")
