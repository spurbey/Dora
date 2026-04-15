"""add user_metadata and trip_advisory_state (brain) + routes.geom_sig/route_geom + trip_advisories.poi_place_id/weather_snapshot

Revision ID: a1b2c3d4e5f6
Revises: ffd82b6d69e4
Create Date: 2026-04-15 12:00:00.000000

Slice: advisory pipeline — trip brain, cycle engine, POI selector, feedback loop.

Adds:
    - user_metadata (per-user advisory preferences, 1:1 optional with users)
    - trip_advisory_state (per-trip "brain", 1:1 with trips)
    - routes.geom_sig (sha256 of route_geojson; reseed trigger)
    - routes.route_geom (PostGIS Geography LINESTRING, 4326; off-route query)
    - idx_routes_geom_gist (GIST index on route_geom)
    - trip_advisories.poi_place_id (GMaps place_id when advisory is a POI pick)
    - trip_advisories.weather_snapshot (JSONB forecast at delivery)

Does not touch any existing V1 tables destructively.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from geoalchemy2 import Geography


# revision identifiers, used by Alembic.
revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, None] = "ffd82b6d69e4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ------------------------------------------------------------------
    # user_metadata
    # ------------------------------------------------------------------
    op.create_table(
        "user_metadata",
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            nullable=False,
            comment="Owner user ID",
        ),
        sa.Column(
            "dietary_restrictions",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
            comment="Dietary restrictions (e.g. vegetarian, halal, gluten_free)",
        ),
        sa.Column(
            "budget_range",
            sa.String(length=20),
            nullable=True,
            comment="shoestring|budget|mid|premium|luxury",
        ),
        sa.Column(
            "preferred_travel_style",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
            comment="Travel style tags mirroring trip_metadata.travel_style",
        ),
        sa.Column(
            "dislikes",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
            comment="Free-form dislike tags for advisory filtering",
        ),
        sa.Column(
            "notification_enabled",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
            comment="Master push notification switch",
        ),
        sa.Column(
            "advisory_quiet_hours",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Quiet hours for advisory pushes",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "budget_range IS NULL OR budget_range IN "
            "('shoestring', 'budget', 'mid', 'premium', 'luxury')",
            name="check_user_metadata_budget_range",
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )

    # ------------------------------------------------------------------
    # trip_advisory_state (the "brain")
    # ------------------------------------------------------------------
    op.create_table(
        "trip_advisory_state",
        sa.Column(
            "trip_id",
            postgresql.UUID(as_uuid=True),
            nullable=False,
            comment="Owner trip",
        ),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            nullable=False,
            comment="Denormalized owner",
        ),
        sa.Column(
            "lifecycle_state",
            sa.String(length=20),
            nullable=False,
            server_default=sa.text("'seeded'"),
            comment="seeded|active|paused|completed|errored",
        ),
        sa.Column(
            "trip_class",
            sa.String(length=30),
            nullable=False,
            server_default=sa.text("'unclassified'"),
            comment="long_road|short_road|intra_city|day_trip|multi_day_leisure|unclassified",
        ),
        sa.Column(
            "cadence_seconds",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("3600"),
        ),
        sa.Column(
            "mode",
            sa.String(length=10),
            nullable=False,
            server_default=sa.text("'route'"),
            comment="route|radius",
        ),
        sa.Column(
            "trip_metadata_snapshot",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column(
            "user_metadata_snapshot",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column(
            "route_samples",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="{samples:[...], polyline_version, sample_count}",
        ),
        sa.Column(
            "baseline_findings",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Aggregated Reddit seed findings",
        ),
        sa.Column(
            "recent_categories",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Rolling category counter",
        ),
        sa.Column("last_seed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_seed_reason", sa.String(length=30), nullable=True),
        sa.Column("last_cycle_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("next_eligible_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "ignore_streak",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("0"),
        ),
        sa.Column(
            "advised_locality_keys",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
        ),
        sa.Column(
            "advised_poi_place_ids",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
        ),
        sa.Column(
            "pending_reseed_reasons",
            postgresql.ARRAY(sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::text[]"),
        ),
        sa.Column(
            "no_pick_attempts",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="{locality_key: count} — retry budget tracker",
        ),
        sa.Column(
            "brightdata_call_count",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("0"),
        ),
        sa.Column("paused_reason", sa.String(length=30), nullable=True),
        sa.Column("paused_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "lifecycle_state IN "
            "('seeded', 'active', 'paused', 'completed', 'errored')",
            name="check_trip_advisory_state_lifecycle",
        ),
        sa.CheckConstraint(
            "mode IN ('route', 'radius')",
            name="check_trip_advisory_state_mode",
        ),
        sa.CheckConstraint(
            "trip_class IN ('long_road', 'short_road', 'intra_city', "
            "'day_trip', 'multi_day_leisure', 'unclassified')",
            name="check_trip_advisory_state_trip_class",
        ),
        sa.CheckConstraint(
            "paused_reason IS NULL OR paused_reason IN "
            "('inactivity', 'user', 'error', 'trip_ended')",
            name="check_trip_advisory_state_paused_reason",
        ),
        sa.CheckConstraint(
            "ignore_streak >= 0",
            name="check_trip_advisory_state_ignore_streak_nonneg",
        ),
        sa.CheckConstraint(
            "cadence_seconds > 0",
            name="check_trip_advisory_state_cadence_positive",
        ),
        sa.CheckConstraint(
            "brightdata_call_count >= 0",
            name="check_trip_advisory_state_brightdata_nonneg",
        ),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("trip_id"),
    )
    op.create_index(
        "idx_trip_advisory_state_active_due",
        "trip_advisory_state",
        ["lifecycle_state", "next_eligible_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_advisory_state_user",
        "trip_advisory_state",
        ["user_id"],
        unique=False,
    )
    op.create_index(
        "idx_trip_advisory_state_advised_localities",
        "trip_advisory_state",
        ["advised_locality_keys"],
        unique=False,
        postgresql_using="gin",
    )
    op.create_index(
        "idx_trip_advisory_state_advised_pois",
        "trip_advisory_state",
        ["advised_poi_place_ids"],
        unique=False,
        postgresql_using="gin",
    )

    # ------------------------------------------------------------------
    # routes: add geom_sig + route_geom + GIST index
    # ------------------------------------------------------------------
    op.add_column(
        "routes",
        sa.Column(
            "geom_sig",
            sa.String(length=64),
            nullable=True,
            comment="sha256(route_geojson) — reseed trigger",
        ),
    )
    op.add_column(
        "routes",
        sa.Column(
            "route_geom",
            Geography(geometry_type="LINESTRING", srid=4326),
            nullable=True,
            comment="PostGIS geography projection of route_geojson",
        ),
    )
    # Best-effort backfill — only for rows where route_geojson holds a
    # top-level LineString. Malformed / non-LineString rows stay NULL; the
    # route_service is responsible for maintaining this column on write.
    op.execute(
        """
        UPDATE routes
        SET route_geom = ST_GeomFromGeoJSON(route_geojson::text)::geography
        WHERE route_geom IS NULL
          AND route_geojson IS NOT NULL
          AND route_geojson->>'type' = 'LineString'
        """
    )
    op.create_index(
        "idx_routes_geom_gist",
        "routes",
        ["route_geom"],
        unique=False,
        postgresql_using="gist",
    )

    # ------------------------------------------------------------------
    # trip_advisories: poi_place_id + weather_snapshot
    # ------------------------------------------------------------------
    op.add_column(
        "trip_advisories",
        sa.Column(
            "poi_place_id",
            sa.String(length=64),
            nullable=True,
            comment="GMaps place_id when this advisory is a POI pick",
        ),
    )
    op.add_column(
        "trip_advisories",
        sa.Column(
            "weather_snapshot",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Open-Meteo forecast at delivery time",
        ),
    )


def downgrade() -> None:
    # trip_advisories additions
    op.drop_column("trip_advisories", "weather_snapshot")
    op.drop_column("trip_advisories", "poi_place_id")

    # routes additions
    op.drop_index("idx_routes_geom_gist", table_name="routes")
    op.drop_column("routes", "route_geom")
    op.drop_column("routes", "geom_sig")

    # trip_advisory_state
    op.drop_index(
        "idx_trip_advisory_state_advised_pois",
        table_name="trip_advisory_state",
    )
    op.drop_index(
        "idx_trip_advisory_state_advised_localities",
        table_name="trip_advisory_state",
    )
    op.drop_index(
        "idx_trip_advisory_state_user",
        table_name="trip_advisory_state",
    )
    op.drop_index(
        "idx_trip_advisory_state_active_due",
        table_name="trip_advisory_state",
    )
    op.drop_table("trip_advisory_state")

    # user_metadata
    op.drop_table("user_metadata")
