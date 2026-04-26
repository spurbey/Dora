"""advisory display_kind + place_polygon

Adds two columns to trip_advisories so each delivered advisory carries
enough info for a map-first UI to render it:

- display_kind: enum
    point          -> render as a marker at (place_lat, place_lng)
    polygon        -> render as an area overlay (warn zones, dirty
                      neighborhoods, scam-prone districts)
    route_overlay  -> render as a colored segment on the trip's route
                      (transport tips, road closures)
    ambient        -> no map rendering; lives in chat panel + brief
                      list (cultural_etiquette, generic tips)

- place_polygon: jsonb
    GeoJSON polygon for area-shaped advisories. NULL when display_kind
    != polygon. We don't generate polygons in this sprint; the column
    exists so future "warn zone" advisories from UGC or scrapers don't
    need another migration.

Existing rows default to display_kind='ambient' (safe fallback — won't
render on map). delivery stage will populate the right kind for new
advisories per the category mapping.

Revision ID: b8a3d6f1c5e2
Revises: c4d1e7b9a2f5
Create Date: 2026-04-27
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "b8a3d6f1c5e2"
down_revision: Union[str, None] = "c4d1e7b9a2f5"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


CHECK_NAME = "ck_trip_advisory_display_kind"


def upgrade() -> None:
    op.add_column(
        "trip_advisories",
        sa.Column(
            "display_kind",
            sa.String(length=20),
            nullable=False,
            server_default="ambient",
        ),
    )
    op.add_column(
        "trip_advisories",
        sa.Column(
            "place_polygon",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
        ),
    )
    op.create_check_constraint(
        CHECK_NAME,
        "trip_advisories",
        "display_kind IN ('point','polygon','route_overlay','ambient')",
    )
    # Useful for the live screen "show all map-renderable advisories" query.
    op.create_index(
        "idx_advisory_trip_display",
        "trip_advisories",
        ["trip_id", "display_kind"],
    )


def downgrade() -> None:
    op.drop_index("idx_advisory_trip_display", table_name="trip_advisories")
    op.drop_constraint(CHECK_NAME, "trip_advisories", type_="check")
    op.drop_column("trip_advisories", "place_polygon")
    op.drop_column("trip_advisories", "display_kind")
