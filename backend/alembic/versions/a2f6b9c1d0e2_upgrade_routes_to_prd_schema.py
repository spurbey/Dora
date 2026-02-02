"""upgrade routes to Phase A2 PRD schema

Revision ID: a2f6b9c1d0e2
Revises: 6e11ad2da6d0
Create Date: 2026-02-02 23:30:00.000000

Production-safe migration: transforms legacy A2 routes schema
to the PRD-compliant schema without manual alembic_version edits.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "a2f6b9c1d0e2"
down_revision: Union[str, None] = "6e11ad2da6d0"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # -------------------------------------------------------------------------
    # ROUTES TABLE: add PRD columns, migrate legacy data, enforce constraints
    # -------------------------------------------------------------------------
    op.add_column("routes", sa.Column("route_geojson", postgresql.JSONB(), nullable=True, comment="GeoJSON LineString"))
    op.add_column("routes", sa.Column("polyline_encoded", sa.Text(), nullable=True, comment="Google-encoded polyline (optional)"))
    op.add_column("routes", sa.Column("route_category", sa.Text(), nullable=True, comment="ground, air"))
    op.add_column("routes", sa.Column("duration_mins", sa.Integer(), nullable=True, comment="Auto-calculated"))
    op.add_column("routes", sa.Column("name", sa.Text(), nullable=True, comment="Optional route name"))

    # Rename legacy columns to PRD names
    op.alter_column("routes", "from_place_id", new_column_name="start_place_id")
    op.alter_column("routes", "to_place_id", new_column_name="end_place_id")
    op.alter_column("routes", "notes", new_column_name="description")

    # Normalize transport_mode values to PRD set
    op.execute(
        """
        UPDATE routes
        SET transport_mode = CASE
            WHEN transport_mode = 'flight' THEN 'air'
            WHEN transport_mode = 'walk' THEN 'foot'
            WHEN transport_mode IN ('ferry', 'other') THEN 'car'
            WHEN transport_mode IS NULL THEN 'car'
            ELSE transport_mode
        END
        """
    )

    # Derive route_category from transport_mode
    op.execute(
        """
        UPDATE routes
        SET route_category = CASE
            WHEN transport_mode = 'air' THEN 'air'
            ELSE 'ground'
        END
        WHERE route_category IS NULL
        """
    )

    # Convert duration_hours -> duration_mins
    op.execute(
        """
        UPDATE routes
        SET duration_mins = ROUND(duration_hours * 60)::int
        WHERE duration_hours IS NOT NULL
        """
    )

    # Ensure order_in_trip is non-null
    op.execute(
        """
        UPDATE routes
        SET order_in_trip = 0
        WHERE order_in_trip IS NULL
        """
    )

    # Backfill route_geojson from start/end place coordinates
    op.execute(
        """
        UPDATE routes r
        SET route_geojson = jsonb_build_object(
            'type', 'LineString',
            'coordinates', jsonb_build_array(
                jsonb_build_array(sp.lng, sp.lat),
                jsonb_build_array(ep.lng, ep.lat)
            )
        )
        FROM trip_places sp, trip_places ep
        WHERE r.start_place_id = sp.id
          AND r.end_place_id = ep.id
          AND r.route_geojson IS NULL
        """
    )

    # If only one endpoint exists, create a zero-length LineString at that point
    op.execute(
        """
        UPDATE routes r
        SET route_geojson = jsonb_build_object(
            'type', 'LineString',
            'coordinates', jsonb_build_array(
                jsonb_build_array(sp.lng, sp.lat),
                jsonb_build_array(sp.lng, sp.lat)
            )
        )
        FROM trip_places sp
        WHERE r.start_place_id = sp.id
          AND r.end_place_id IS NULL
          AND r.route_geojson IS NULL
        """
    )
    op.execute(
        """
        UPDATE routes r
        SET route_geojson = jsonb_build_object(
            'type', 'LineString',
            'coordinates', jsonb_build_array(
                jsonb_build_array(ep.lng, ep.lat),
                jsonb_build_array(ep.lng, ep.lat)
            )
        )
        FROM trip_places ep
        WHERE r.end_place_id = ep.id
          AND r.start_place_id IS NULL
          AND r.route_geojson IS NULL
        """
    )

    # Final fallback to satisfy NOT NULL (should be rare)
    op.execute(
        """
        UPDATE routes
        SET route_geojson = jsonb_build_object(
            'type', 'LineString',
            'coordinates', jsonb_build_array(
                jsonb_build_array(0, 0),
                jsonb_build_array(0, 0)
            )
        )
        WHERE route_geojson IS NULL
        """
    )

    # Enforce PRD constraints (drop legacy transport constraint, set NOT NULL)
    op.drop_constraint("check_transport_mode", "routes", type_="check")
    op.alter_column("routes", "transport_mode", nullable=False)
    op.alter_column("routes", "route_category", nullable=False)
    op.alter_column("routes", "route_geojson", nullable=False)
    op.alter_column("routes", "order_in_trip", nullable=False)

    op.create_check_constraint(
        "check_transport_mode",
        "routes",
        "transport_mode IN ('car', 'bike', 'foot', 'air', 'bus', 'train')"
    )
    op.create_check_constraint(
        "check_route_category",
        "routes",
        "route_category IN ('ground', 'air')"
    )

    # -------------------------------------------------------------------------
    # WAYPOINTS TABLE: create new PRD table and backfill from legacy JSONB
    # -------------------------------------------------------------------------
    op.create_table(
        "waypoints",
        sa.Column("id", sa.UUID(), nullable=False, comment="Waypoint ID"),
        sa.Column("route_id", sa.UUID(), nullable=False, comment="FK to routes"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="FK to trips"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="FK to users"),
        sa.Column("lat", sa.Float(), nullable=False, comment="Latitude"),
        sa.Column("lng", sa.Float(), nullable=False, comment="Longitude"),
        sa.Column("name", sa.Text(), nullable=False, comment="Waypoint label"),
        sa.Column("waypoint_type", sa.Text(), nullable=False, comment="stop, note, photo, poi"),
        sa.Column("notes", sa.Text(), nullable=True, comment="User notes"),
        sa.Column("order_in_route", sa.Integer(), nullable=False, comment="Position along route"),
        sa.Column("stopped_at", sa.DateTime(timezone=True), nullable=True, comment="When user stopped here"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False, comment="Creation timestamp"),
        sa.ForeignKeyConstraint(["route_id"], ["routes.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint("waypoint_type IN ('stop', 'note', 'photo', 'poi')", name="check_waypoint_type"),
        sa.CheckConstraint("lat >= -90 AND lat <= 90", name="check_lat_range"),
        sa.CheckConstraint("lng >= -180 AND lng <= 180", name="check_lng_range"),
        sa.CheckConstraint("order_in_route >= 0", name="check_waypoint_order_positive"),
    )
    op.create_index("idx_waypoints_route", "waypoints", ["route_id", "order_in_route"], unique=False)

    # Backfill waypoints from legacy routes.waypoints JSONB
    op.execute(
        """
        INSERT INTO waypoints (id, route_id, trip_id, user_id, lat, lng, name, waypoint_type, order_in_route, created_at)
        SELECT
            gen_random_uuid(),
            r.id,
            r.trip_id,
            r.user_id,
            (elem.value->>'lat')::float,
            (elem.value->>'lng')::float,
            COALESCE(elem.value->>'name', 'Waypoint ' || COALESCE(elem.value->>'order', ordinality::text)),
            COALESCE(elem.value->>'type', 'poi'),
            COALESCE((elem.value->>'order')::int, (ordinality - 1)),
            now()
        FROM routes r
        CROSS JOIN LATERAL jsonb_array_elements(r.waypoints) WITH ORDINALITY AS elem(value, ordinality)
        WHERE r.waypoints IS NOT NULL
        """
    )

    # Drop legacy columns not in PRD (after backfill)
    op.drop_column("routes", "duration_hours")
    op.drop_column("routes", "waypoints")

    # Indexes per PRD
    op.create_index("idx_routes_trip", "routes", ["trip_id"], unique=False)
    op.create_index("idx_routes_order", "routes", ["trip_id", "order_in_trip"], unique=False)

    # -------------------------------------------------------------------------
    # ROUTE_METADATA TABLE: add PRD columns, migrate legacy data
    # -------------------------------------------------------------------------
    op.add_column("route_metadata", sa.Column("route_quality", sa.Text(), nullable=True, comment="scenic, fastest, offbeat"))
    op.add_column("route_metadata", sa.Column("road_condition", sa.Text(), nullable=True, comment="excellent, good, poor, offroad"))
    op.add_column("route_metadata", sa.Column("safety_rating", sa.Integer(), nullable=False, server_default="3", comment="1-5, default 3"))
    op.add_column("route_metadata", sa.Column("solo_safe", sa.Boolean(), nullable=False, server_default="true", comment="Default TRUE"))
    op.add_column("route_metadata", sa.Column("fuel_cost", sa.Numeric(10, 2), nullable=True, comment="Estimated cost"))
    op.add_column("route_metadata", sa.Column("toll_cost", sa.Numeric(10, 2), nullable=True, comment="Toll charges"))
    op.add_column("route_metadata", sa.Column("highlights", postgresql.ARRAY(sa.Text()), nullable=True, comment="['waterfall', 'viewpoint']"))

    # Migrate legacy data
    op.execute(
        """
        UPDATE route_metadata
        SET fuel_cost = cost_estimate
        WHERE fuel_cost IS NULL AND cost_estimate IS NOT NULL
        """
    )
    op.execute(
        """
        UPDATE route_metadata
        SET highlights = tags
        WHERE highlights IS NULL AND tags IS NOT NULL
        """
    )
    op.execute(
        """
        UPDATE route_metadata
        SET safety_rating = 3
        WHERE safety_rating IS NULL
        """
    )

    # Drop legacy columns
    op.execute("DROP INDEX IF EXISTS idx_route_metadata_tags")
    op.drop_column("route_metadata", "difficulty_rating")
    op.drop_column("route_metadata", "cost_estimate")
    op.drop_column("route_metadata", "currency")
    op.drop_column("route_metadata", "tags")

    # Replace constraints
    op.execute("ALTER TABLE route_metadata DROP CONSTRAINT IF EXISTS check_difficulty_rating_range")
    op.execute("ALTER TABLE route_metadata DROP CONSTRAINT IF EXISTS check_cost_positive")

    op.create_check_constraint(
        "check_route_quality",
        "route_metadata",
        "route_quality IN ('scenic', 'fastest', 'offbeat') OR route_quality IS NULL"
    )
    op.create_check_constraint(
        "check_road_condition",
        "route_metadata",
        "road_condition IN ('excellent', 'good', 'poor', 'offroad') OR road_condition IS NULL"
    )
    op.create_check_constraint(
        "check_safety_rating_range",
        "route_metadata",
        "safety_rating >= 1 AND safety_rating <= 5"
    )
    op.create_check_constraint(
        "check_fuel_cost_positive",
        "route_metadata",
        "fuel_cost >= 0 OR fuel_cost IS NULL"
    )
    op.create_check_constraint(
        "check_toll_cost_positive",
        "route_metadata",
        "toll_cost >= 0 OR toll_cost IS NULL"
    )

    # New highlights index
    op.create_index(
        "idx_route_metadata_highlights",
        "route_metadata",
        ["highlights"],
        unique=False,
        postgresql_using="gin"
    )


def downgrade() -> None:
    # NOTE: Best-effort downgrade. Data for new columns may be lost.

    # Drop highlights index and PRD columns
    op.drop_index("idx_route_metadata_highlights", table_name="route_metadata")
    op.drop_column("route_metadata", "highlights")
    op.drop_column("route_metadata", "toll_cost")
    op.drop_column("route_metadata", "fuel_cost")
    op.drop_column("route_metadata", "solo_safe")
    op.drop_column("route_metadata", "safety_rating")
    op.drop_column("route_metadata", "road_condition")
    op.drop_column("route_metadata", "route_quality")

    # Restore legacy columns
    op.add_column("route_metadata", sa.Column("difficulty_rating", sa.Integer(), nullable=True))
    op.add_column("route_metadata", sa.Column("cost_estimate", sa.Numeric(10, 2), nullable=True))
    op.add_column("route_metadata", sa.Column("currency", sa.Text(), nullable=True, server_default="USD"))
    op.add_column("route_metadata", sa.Column("tags", postgresql.ARRAY(sa.Text()), nullable=True))
    op.create_index("idx_route_metadata_tags", "route_metadata", ["tags"], unique=False, postgresql_using="gin")

    # Drop waypoints table
    op.drop_index("idx_waypoints_route", table_name="waypoints")
    op.drop_table("waypoints")

    # Restore legacy routes columns
    op.add_column("routes", sa.Column("duration_hours", sa.Float(), nullable=True))
    op.add_column("routes", sa.Column("waypoints", postgresql.JSONB(), nullable=True))
    op.alter_column("routes", "start_place_id", new_column_name="from_place_id")
    op.alter_column("routes", "end_place_id", new_column_name="to_place_id")
    op.alter_column("routes", "description", new_column_name="notes")

    op.drop_index("idx_routes_order", table_name="routes")
    op.drop_index("idx_routes_trip", table_name="routes")

    op.drop_column("routes", "name")
    op.drop_column("routes", "duration_mins")
    op.drop_column("routes", "route_category")
    op.drop_column("routes", "polyline_encoded")
    op.drop_column("routes", "route_geojson")
