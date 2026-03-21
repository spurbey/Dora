"""add live tracking phase1 schema

Revision ID: e9b3f0a7c1d2
Revises: d6f9a8b4c321
Create Date: 2026-03-21 00:00:00.000000

Rollback notes:
- Drops live-tracking tables, indexes, and constraints introduced by this migration.
- Removes trip/place/route live-tracking columns and related checks/FKs.
- Existing live-tracking data is permanently removed on downgrade.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "e9b3f0a7c1d2"
down_revision: Union[str, None] = "d6f9a8b4c321"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "trips",
        sa.Column(
            "status",
            sa.String(length=32),
            nullable=False,
            server_default="planned",
            comment="planned|tracking_active|tracking_paused|review_pending|completed|shared",
        ),
    )
    op.add_column(
        "trips",
        sa.Column(
            "tracking_enabled",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
            comment="Whether live tracking is enabled for this trip",
        ),
    )
    op.add_column(
        "trips",
        sa.Column(
            "tracking_started_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Tracking start time",
        ),
    )
    op.add_column(
        "trips",
        sa.Column(
            "tracking_ended_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Tracking end time",
        ),
    )
    op.add_column(
        "trips",
        sa.Column(
            "timezone",
            sa.String(length=64),
            nullable=True,
            comment="IANA timezone",
        ),
    )
    op.add_column(
        "trips",
        sa.Column(
            "auto_end_reason",
            sa.Text(),
            nullable=True,
            comment="Reason for automatic tracking stop",
        ),
    )
    op.create_check_constraint(
        "check_trip_status_live_tracking",
        "trips",
        "status IN ('planned', 'tracking_active', 'tracking_paused', 'review_pending', 'completed', 'shared')",
    )
    op.create_index("idx_trips_status", "trips", ["status"], unique=False)

    op.create_table(
        "trip_tracking_sessions",
        sa.Column("id", sa.UUID(), nullable=False, comment="Session ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Tracked trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("client_session_id", sa.String(length=64), nullable=False, comment="Client session ID"),
        sa.Column("state", sa.String(length=20), nullable=False, server_default="active", comment="active|paused|ended|abandoned"),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("paused_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("resumed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("abandoned_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_point_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("timezone", sa.String(length=64), nullable=True),
        sa.Column(
            "device_context",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint(
            "state IN ('active', 'paused', 'ended', 'abandoned')",
            name="check_tracking_session_state",
        ),
    )
    op.create_index("idx_tracking_sessions_trip_state", "trip_tracking_sessions", ["trip_id", "state"], unique=False)
    op.create_index("idx_tracking_sessions_user_state", "trip_tracking_sessions", ["user_id", "state"], unique=False)
    op.create_index(
        "uq_tracking_session_active_trip_user",
        "trip_tracking_sessions",
        ["trip_id", "user_id"],
        unique=True,
        postgresql_where=sa.text("state = 'active'"),
    )

    op.create_table(
        "trip_location_points",
        sa.Column("id", sa.UUID(), nullable=False, comment="Row ID"),
        sa.Column("session_id", sa.UUID(), nullable=False, comment="Tracking session ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("client_batch_id", sa.UUID(), nullable=False, comment="Client batch ID"),
        sa.Column("point_id", sa.UUID(), nullable=False, comment="Client point ID"),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False, comment="Device timestamp"),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("accuracy_m", sa.Float(), nullable=True),
        sa.Column("speed_mps", sa.Float(), nullable=True),
        sa.Column("heading_deg", sa.Float(), nullable=True),
        sa.Column("altitude_m", sa.Float(), nullable=True),
        sa.Column("provider", sa.String(length=32), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["session_id"], ["trip_tracking_sessions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("session_id", "point_id", name="uq_tracking_point_session_point"),
        sa.CheckConstraint("latitude >= -90 AND latitude <= 90", name="check_tracking_point_latitude"),
        sa.CheckConstraint("longitude >= -180 AND longitude <= 180", name="check_tracking_point_longitude"),
        sa.CheckConstraint("accuracy_m IS NULL OR accuracy_m >= 0", name="check_tracking_point_accuracy"),
        sa.CheckConstraint("speed_mps IS NULL OR speed_mps >= 0", name="check_tracking_point_speed"),
        sa.CheckConstraint(
            "heading_deg IS NULL OR (heading_deg >= 0 AND heading_deg <= 360)",
            name="check_tracking_point_heading",
        ),
    )
    op.create_index("idx_tracking_points_trip_time", "trip_location_points", ["trip_id", "recorded_at"], unique=False)
    op.create_index(
        "idx_tracking_points_session_time",
        "trip_location_points",
        ["session_id", "recorded_at"],
        unique=False,
    )

    op.create_table(
        "trip_checkin_candidates",
        sa.Column("id", sa.UUID(), nullable=False, comment="Candidate ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("session_id", sa.UUID(), nullable=True, comment="Origin session ID"),
        sa.Column("fingerprint", sa.String(length=128), nullable=False, comment="Dedup fingerprint"),
        sa.Column(
            "status",
            sa.String(length=20),
            nullable=False,
            server_default="pending",
            comment="pending|confirmed|rejected|snoozed|expired",
        ),
        sa.Column("confidence", sa.Float(), nullable=False, comment="0..1 confidence"),
        sa.Column("suggested_name", sa.Text(), nullable=True),
        sa.Column("suggested_latitude", sa.Float(), nullable=True),
        sa.Column("suggested_longitude", sa.Float(), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("confirmed_trip_place_id", sa.UUID(), nullable=True),
        sa.Column("rejected_reason", sa.Text(), nullable=True),
        sa.Column("snoozed_until", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cooldown_until", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_id"], ["trip_tracking_sessions.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["confirmed_trip_place_id"], ["trip_places.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint(
            "status IN ('pending', 'confirmed', 'rejected', 'snoozed', 'expired')",
            name="check_checkin_candidate_status",
        ),
        sa.CheckConstraint("confidence >= 0 AND confidence <= 1", name="check_checkin_candidate_confidence"),
        sa.CheckConstraint(
            "suggested_latitude IS NULL OR (suggested_latitude >= -90 AND suggested_latitude <= 90)",
            name="check_checkin_candidate_latitude",
        ),
        sa.CheckConstraint(
            "suggested_longitude IS NULL OR (suggested_longitude >= -180 AND suggested_longitude <= 180)",
            name="check_checkin_candidate_longitude",
        ),
    )
    op.create_index(
        "idx_checkin_candidates_trip_status",
        "trip_checkin_candidates",
        ["trip_id", "status"],
        unique=False,
    )
    op.create_index(
        "idx_checkin_candidates_user_status",
        "trip_checkin_candidates",
        ["user_id", "status"],
        unique=False,
    )
    op.create_index(
        "uq_checkin_candidate_active_fingerprint",
        "trip_checkin_candidates",
        ["trip_id", "user_id", "fingerprint"],
        unique=True,
        postgresql_where=sa.text("status IN ('pending', 'snoozed')"),
    )

    op.create_table(
        "trip_moments",
        sa.Column("id", sa.UUID(), nullable=False, comment="Moment ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("candidate_id", sa.UUID(), nullable=True, comment="Origin candidate ID"),
        sa.Column("linked_trip_place_id", sa.UUID(), nullable=True, comment="Linked place ID"),
        sa.Column("source", sa.String(length=20), nullable=False, server_default="manual", comment="manual|auto|edited_auto"),
        sa.Column("confidence", sa.Float(), nullable=True),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column(
            "media_refs",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'[]'::jsonb"),
        ),
        sa.Column(
            "extra_payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column(
            "locked_fields",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["candidate_id"], ["trip_checkin_candidates.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["linked_trip_place_id"], ["trip_places.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.CheckConstraint("source IN ('manual', 'auto', 'edited_auto')", name="check_trip_moment_source"),
        sa.CheckConstraint(
            "confidence IS NULL OR (confidence >= 0 AND confidence <= 1)",
            name="check_trip_moment_confidence",
        ),
        sa.CheckConstraint(
            "latitude IS NULL OR (latitude >= -90 AND latitude <= 90)",
            name="check_trip_moment_latitude",
        ),
        sa.CheckConstraint(
            "longitude IS NULL OR (longitude >= -180 AND longitude <= 180)",
            name="check_trip_moment_longitude",
        ),
    )
    op.create_index("idx_trip_moments_trip_captured_at", "trip_moments", ["trip_id", "captured_at"], unique=False)
    op.create_index("idx_trip_moments_user_captured_at", "trip_moments", ["user_id", "captured_at"], unique=False)

    op.create_table(
        "trip_auto_entity_tombstones",
        sa.Column("id", sa.UUID(), nullable=False, comment="Tombstone ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("entity_type", sa.String(length=32), nullable=False, comment="place|route|moment_link"),
        sa.Column("entity_fingerprint", sa.String(length=128), nullable=False),
        sa.Column("deleted_entity_id", sa.UUID(), nullable=True),
        sa.Column("cooldown_expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("reason", sa.String(length=128), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "user_id",
            "entity_type",
            "entity_fingerprint",
            name="uq_tombstone_trip_user_type_fp",
        ),
        sa.CheckConstraint(
            "entity_type IN ('place', 'route', 'moment_link')",
            name="check_tombstone_entity_type",
        ),
    )
    op.create_index(
        "idx_tombstones_trip_cooldown",
        "trip_auto_entity_tombstones",
        ["trip_id", "cooldown_expires_at"],
        unique=False,
    )

    op.create_table(
        "api_idempotency_records",
        sa.Column("id", sa.UUID(), nullable=False, comment="Idempotency row ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("endpoint_signature", sa.String(length=160), nullable=False),
        sa.Column("idempotency_key", sa.String(length=96), nullable=False),
        sa.Column("request_hash", sa.String(length=128), nullable=False),
        sa.Column("response_status", sa.Integer(), nullable=False),
        sa.Column("response_body", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("replay_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("last_replayed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "user_id",
            "endpoint_signature",
            "idempotency_key",
            name="uq_idempotency_user_endpoint_key",
        ),
    )
    op.create_index("idx_idempotency_expires_at", "api_idempotency_records", ["expires_at"], unique=False)
    op.create_index(
        "idx_idempotency_user_first_seen",
        "api_idempotency_records",
        ["user_id", "first_seen_at"],
        unique=False,
    )

    op.add_column(
        "trip_places",
        sa.Column(
            "source",
            sa.String(length=20),
            nullable=False,
            server_default="manual",
            comment="manual|auto|edited_auto",
        ),
    )
    op.add_column("trip_places", sa.Column("confidence", sa.Float(), nullable=True))
    op.add_column("trip_places", sa.Column("candidate_id", sa.UUID(), nullable=True))
    op.add_column(
        "trip_places",
        sa.Column(
            "locked_fields",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Field-level lock markers",
        ),
    )
    op.create_check_constraint(
        "check_trip_places_source",
        "trip_places",
        "source IN ('manual', 'auto', 'edited_auto')",
    )
    op.create_foreign_key(
        "fk_trip_places_candidate_id",
        "trip_places",
        "trip_checkin_candidates",
        ["candidate_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index("idx_trip_places_source", "trip_places", ["source"], unique=False)
    op.create_index("idx_trip_places_candidate_id", "trip_places", ["candidate_id"], unique=False)

    op.add_column(
        "routes",
        sa.Column(
            "source",
            sa.String(length=20),
            nullable=False,
            server_default="manual",
            comment="manual|auto|edited_auto",
        ),
    )
    op.add_column("routes", sa.Column("confidence", sa.Float(), nullable=True))
    op.add_column("routes", sa.Column("inferred_from_session_id", sa.UUID(), nullable=True))
    op.add_column(
        "routes",
        sa.Column(
            "locked_fields",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Field-level lock markers",
        ),
    )
    op.create_check_constraint(
        "check_routes_source",
        "routes",
        "source IN ('manual', 'auto', 'edited_auto')",
    )
    op.create_foreign_key(
        "fk_routes_inferred_from_session_id",
        "routes",
        "trip_tracking_sessions",
        ["inferred_from_session_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index("idx_routes_source", "routes", ["source"], unique=False)
    op.create_index(
        "idx_routes_inferred_from_session_id",
        "routes",
        ["inferred_from_session_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("idx_routes_inferred_from_session_id", table_name="routes")
    op.drop_index("idx_routes_source", table_name="routes")
    op.drop_constraint("fk_routes_inferred_from_session_id", "routes", type_="foreignkey")
    op.drop_constraint("check_routes_source", "routes", type_="check")
    op.drop_column("routes", "locked_fields")
    op.drop_column("routes", "inferred_from_session_id")
    op.drop_column("routes", "confidence")
    op.drop_column("routes", "source")

    op.drop_index("idx_trip_places_candidate_id", table_name="trip_places")
    op.drop_index("idx_trip_places_source", table_name="trip_places")
    op.drop_constraint("fk_trip_places_candidate_id", "trip_places", type_="foreignkey")
    op.drop_constraint("check_trip_places_source", "trip_places", type_="check")
    op.drop_column("trip_places", "locked_fields")
    op.drop_column("trip_places", "candidate_id")
    op.drop_column("trip_places", "confidence")
    op.drop_column("trip_places", "source")

    op.drop_index("idx_idempotency_user_first_seen", table_name="api_idempotency_records")
    op.drop_index("idx_idempotency_expires_at", table_name="api_idempotency_records")
    op.drop_table("api_idempotency_records")

    op.drop_index("idx_tombstones_trip_cooldown", table_name="trip_auto_entity_tombstones")
    op.drop_table("trip_auto_entity_tombstones")

    op.drop_index("idx_trip_moments_user_captured_at", table_name="trip_moments")
    op.drop_index("idx_trip_moments_trip_captured_at", table_name="trip_moments")
    op.drop_table("trip_moments")

    op.drop_index("uq_checkin_candidate_active_fingerprint", table_name="trip_checkin_candidates")
    op.drop_index("idx_checkin_candidates_user_status", table_name="trip_checkin_candidates")
    op.drop_index("idx_checkin_candidates_trip_status", table_name="trip_checkin_candidates")
    op.drop_table("trip_checkin_candidates")

    op.drop_index("idx_tracking_points_session_time", table_name="trip_location_points")
    op.drop_index("idx_tracking_points_trip_time", table_name="trip_location_points")
    op.drop_table("trip_location_points")

    op.drop_index("uq_tracking_session_active_trip_user", table_name="trip_tracking_sessions")
    op.drop_index("idx_tracking_sessions_user_state", table_name="trip_tracking_sessions")
    op.drop_index("idx_tracking_sessions_trip_state", table_name="trip_tracking_sessions")
    op.drop_table("trip_tracking_sessions")

    op.drop_index("idx_trips_status", table_name="trips")
    op.drop_constraint("check_trip_status_live_tracking", "trips", type_="check")
    op.drop_column("trips", "auto_end_reason")
    op.drop_column("trips", "timezone")
    op.drop_column("trips", "tracking_ended_at")
    op.drop_column("trips", "tracking_started_at")
    op.drop_column("trips", "tracking_enabled")
    op.drop_column("trips", "status")

