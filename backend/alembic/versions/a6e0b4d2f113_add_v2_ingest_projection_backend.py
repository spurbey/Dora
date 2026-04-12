"""add v2 ingest and projection backend tables

Revision ID: a6e0b4d2f113
Revises: f4b8c9d1e2a3
Create Date: 2026-04-12 12:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "a6e0b4d2f113"
down_revision: Union[str, None] = "f4b8c9d1e2a3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "trips",
        sa.Column(
            "v2_backend_enabled",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
            comment="Whether strict V2 ingest/projection backend lane is enabled for this trip",
        ),
    )

    op.create_table(
        "trip_session_raw",
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("client_session_id", sa.String(length=128), nullable=False),
        sa.Column("timezone", sa.String(length=64), nullable=True),
        sa.Column("device_id", sa.String(length=128), nullable=True),
        sa.Column(
            "device_context",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="active"),
        sa.Column("commit_token", sa.String(length=128), nullable=True),
        sa.Column("stop_client_event_id", sa.String(length=128), nullable=True),
        sa.Column("seal_version", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("stop_server_pending", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("stop_reason", sa.String(length=128), nullable=True),
        sa.Column("schema_version", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("session_server_id"),
        sa.UniqueConstraint("trip_server_id", "client_session_id", name="uq_trip_session_raw_trip_client_session"),
    )
    op.create_index("idx_trip_session_raw_trip_started", "trip_session_raw", ["trip_server_id", "started_at"], unique=False)
    op.create_index("idx_trip_session_raw_trip_status", "trip_session_raw", ["trip_server_id", "status"], unique=False)

    op.create_table(
        "trip_event_raw",
        sa.Column("event_server_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("client_event_id", sa.String(length=128), nullable=False),
        sa.Column("event_type", sa.String(length=32), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("resolver_state", sa.String(length=32), nullable=False),
        sa.Column("decision_source", sa.String(length=64), nullable=True),
        sa.Column("manual_lock", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("place_bind_kind", sa.String(length=32), nullable=True),
        sa.Column("place_bind_id", sa.String(length=128), nullable=True),
        sa.Column("place_bind_name", sa.String(length=255), nullable=True),
        sa.Column("geotag_final_reason", sa.String(length=64), nullable=True),
        sa.Column("payload_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("event_seq", sa.Integer(), nullable=True),
        sa.Column("captured_while_paused", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("candidate_set_version", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("event_server_id"),
        sa.UniqueConstraint("trip_server_id", "client_event_id", name="uq_trip_event_raw_trip_client_event"),
    )
    op.create_index("idx_trip_event_raw_trip_captured", "trip_event_raw", ["trip_server_id", "captured_at"], unique=False)
    op.create_index(
        "idx_trip_event_raw_trip_resolver_captured",
        "trip_event_raw",
        ["trip_server_id", "resolver_state", "captured_at"],
        unique=False,
    )

    op.create_table(
        "trip_media_raw",
        sa.Column("media_server_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("event_server_id", sa.UUID(), nullable=False),
        sa.Column("client_media_id", sa.String(length=128), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("media_type", sa.String(length=32), nullable=False),
        sa.Column("storage_ref", sa.String(length=512), nullable=False),
        sa.Column("mime_type", sa.String(length=128), nullable=True),
        sa.Column("bytes_size", sa.Integer(), nullable=True),
        sa.Column("width_px", sa.Integer(), nullable=True),
        sa.Column("height_px", sa.Integer(), nullable=True),
        sa.Column("duration_ms", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["event_server_id"], ["trip_event_raw.event_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("media_server_id"),
        sa.UniqueConstraint("trip_server_id", "client_media_id", name="uq_trip_media_raw_trip_client_media"),
    )
    op.create_index("idx_trip_media_raw_trip_captured", "trip_media_raw", ["trip_server_id", "captured_at"], unique=False)
    op.create_index("idx_trip_media_raw_event", "trip_media_raw", ["event_server_id"], unique=False)

    op.create_table(
        "trip_route_raw_point",
        sa.Column("point_server_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("client_point_id", sa.String(length=128), nullable=True),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("accuracy_m", sa.Float(), nullable=True),
        sa.Column("speed_mps", sa.Float(), nullable=True),
        sa.Column("bearing_deg", sa.Float(), nullable=True),
        sa.Column("altitude_m", sa.Float(), nullable=True),
        sa.Column("source", sa.String(length=32), nullable=True),
        sa.Column("point_seq", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("point_server_id"),
        sa.UniqueConstraint("session_server_id", "point_seq", name="uq_trip_route_raw_point_session_seq"),
    )
    op.create_index("idx_trip_route_raw_point_trip_captured", "trip_route_raw_point", ["trip_server_id", "captured_at"], unique=False)
    op.create_index("idx_trip_route_raw_point_session_seq", "trip_route_raw_point", ["session_server_id", "point_seq"], unique=False)

    op.create_table(
        "trip_commit_manifest",
        sa.Column("manifest_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("client_session_id", sa.String(length=128), nullable=False),
        sa.Column("client_job_id", sa.String(length=128), nullable=False),
        sa.Column("session_commit_token", sa.String(length=128), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("operation_kind", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("phase", sa.String(length=32), nullable=False),
        sa.Column("schema_version", sa.Integer(), nullable=False),
        sa.Column("request_fingerprint", sa.String(length=128), nullable=False),
        sa.Column("response_fingerprint", sa.String(length=128), nullable=True),
        sa.Column("session_summary", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("media_manifest", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("media_manifest_digest", sa.String(length=128), nullable=False),
        sa.Column("accepted_media_refs", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("payload_chunks", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("step_idempotency", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("payload_total_bytes", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("error_code", sa.String(length=64), nullable=True),
        sa.Column("error_message", sa.Text(), nullable=True),
        sa.Column("raw_ingest_completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("projection_compiled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("committed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("manifest_id"),
        sa.UniqueConstraint("trip_server_id", "operation_kind", "idempotency_key", name="uq_trip_commit_manifest_trip_operation_key"),
        sa.UniqueConstraint("session_commit_token", name="uq_trip_commit_manifest_session_commit_token"),
    )
    op.create_index("idx_trip_commit_manifest_trip_created", "trip_commit_manifest", ["trip_server_id", "created_at"], unique=False)
    op.create_index("idx_trip_commit_manifest_session_status", "trip_commit_manifest", ["session_server_id", "status"], unique=False)

    op.create_table(
        "trip_timeline_projection_v2",
        sa.Column("projection_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("entry_id", sa.String(length=160), nullable=False),
        sa.Column("entry_kind", sa.String(length=32), nullable=False),
        sa.Column("source_server_id", sa.UUID(), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("bucket_type", sa.String(length=32), nullable=False),
        sa.Column("place_bind_name", sa.String(length=255), nullable=True),
        sa.Column("place_bind_id", sa.String(length=128), nullable=True),
        sa.Column("decision_source", sa.String(length=64), nullable=True),
        sa.Column("manual_lock", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("anchor_latitude", sa.Float(), nullable=False),
        sa.Column("anchor_longitude", sa.Float(), nullable=False),
        sa.Column("route_segment_key", sa.String(length=128), nullable=True),
        sa.Column("route_distance_m", sa.Float(), nullable=True),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("subtitle", sa.Text(), nullable=True),
        sa.Column("render_payload_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("compiler_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("compiled_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("projection_id"),
        sa.UniqueConstraint("trip_server_id", "entry_id", name="uq_trip_timeline_projection_v2_trip_entry"),
    )
    op.create_index(
        "idx_trip_timeline_projection_v2_trip_captured_entry",
        "trip_timeline_projection_v2",
        ["trip_server_id", "captured_at", "entry_id"],
        unique=False,
    )
    op.create_index(
        "idx_trip_timeline_projection_v2_trip_bucket_captured",
        "trip_timeline_projection_v2",
        ["trip_server_id", "bucket_type", "captured_at"],
        unique=False,
    )

    op.create_table(
        "trip_route_projection_v2",
        sa.Column("projection_id", sa.UUID(), nullable=False),
        sa.Column("trip_server_id", sa.UUID(), nullable=False),
        sa.Column("session_server_id", sa.UUID(), nullable=False),
        sa.Column("segment_key", sa.String(length=128), nullable=False),
        sa.Column("segment_index", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("point_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("raw_point_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("geometry_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("is_simplified", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("compiler_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("compiled_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["trip_server_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_server_id"], ["trip_session_raw.session_server_id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("projection_id"),
        sa.UniqueConstraint("trip_server_id", "segment_key", name="uq_trip_route_projection_v2_trip_segment"),
    )
    op.create_index("idx_trip_route_projection_v2_trip_segment_index", "trip_route_projection_v2", ["trip_server_id", "segment_index"], unique=False)
    op.create_index("idx_trip_route_projection_v2_trip_session", "trip_route_projection_v2", ["trip_server_id", "session_server_id"], unique=False)


def downgrade() -> None:
    op.drop_index("idx_trip_route_projection_v2_trip_session", table_name="trip_route_projection_v2")
    op.drop_index("idx_trip_route_projection_v2_trip_segment_index", table_name="trip_route_projection_v2")
    op.drop_table("trip_route_projection_v2")

    op.drop_index("idx_trip_timeline_projection_v2_trip_bucket_captured", table_name="trip_timeline_projection_v2")
    op.drop_index("idx_trip_timeline_projection_v2_trip_captured_entry", table_name="trip_timeline_projection_v2")
    op.drop_table("trip_timeline_projection_v2")

    op.drop_index("idx_trip_commit_manifest_session_status", table_name="trip_commit_manifest")
    op.drop_index("idx_trip_commit_manifest_trip_created", table_name="trip_commit_manifest")
    op.drop_table("trip_commit_manifest")

    op.drop_index("idx_trip_route_raw_point_session_seq", table_name="trip_route_raw_point")
    op.drop_index("idx_trip_route_raw_point_trip_captured", table_name="trip_route_raw_point")
    op.drop_table("trip_route_raw_point")

    op.drop_index("idx_trip_media_raw_event", table_name="trip_media_raw")
    op.drop_index("idx_trip_media_raw_trip_captured", table_name="trip_media_raw")
    op.drop_table("trip_media_raw")

    op.drop_index("idx_trip_event_raw_trip_resolver_captured", table_name="trip_event_raw")
    op.drop_index("idx_trip_event_raw_trip_captured", table_name="trip_event_raw")
    op.drop_table("trip_event_raw")

    op.drop_index("idx_trip_session_raw_trip_status", table_name="trip_session_raw")
    op.drop_index("idx_trip_session_raw_trip_started", table_name="trip_session_raw")
    op.drop_table("trip_session_raw")

    op.drop_column("trips", "v2_backend_enabled")
