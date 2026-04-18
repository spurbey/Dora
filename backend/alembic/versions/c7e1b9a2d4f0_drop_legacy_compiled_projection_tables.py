"""drop legacy compiled projection tables

Revision ID: c7e1b9a2d4f0
Revises: 9613649fe258
Create Date: 2026-04-18 19:35:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "c7e1b9a2d4f0"
down_revision: Union[str, None] = "9613649fe258"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("DROP TABLE IF EXISTS trip_compiled_projection_overrides CASCADE")
    op.execute("DROP TABLE IF EXISTS trip_compiled_route_segments CASCADE")
    op.execute("DROP TABLE IF EXISTS trip_compiled_projection_items CASCADE")
    op.execute("DROP TABLE IF EXISTS trip_compiled_projection_state CASCADE")


def downgrade() -> None:
    op.create_table(
        "trip_compiled_projection_state",
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("compiler_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("dirty", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("stale", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("raw_event_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("compiled_event_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("raw_point_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("compiled_route_segment_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_compiled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_error", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("trip_id"),
    )
    op.create_index(
        "ix_trip_compiled_projection_state_user_id",
        "trip_compiled_projection_state",
        ["user_id"],
        unique=False,
    )

    op.create_table(
        "trip_compiled_projection_items",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("entry_id", sa.String(length=160), nullable=False),
        sa.Column("source_kind", sa.String(length=32), nullable=False),
        sa.Column("source_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event_type", sa.String(length=32), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("day_key", sa.Date(), nullable=False),
        sa.Column("bucket_type", sa.String(length=32), nullable=False),
        sa.Column("place_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("place_name", sa.String(length=255), nullable=True),
        sa.Column("bind_source", sa.String(length=16), nullable=False, server_default="none"),
        sa.Column("bind_confidence", sa.Float(), nullable=True),
        sa.Column("reason_code", sa.String(length=64), nullable=True),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("subtitle", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("order_index", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("compiler_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.CheckConstraint(
            "source_kind IN ('tracking_event', 'tracking_event_media')",
            name="check_compiled_projection_source_kind",
        ),
        sa.CheckConstraint(
            "event_type IN ('note', 'warn', 'tag', 'photo', 'media')",
            name="check_compiled_projection_event_type",
        ),
        sa.CheckConstraint("bucket_type IN ('place', 'on_route')", name="check_compiled_projection_bucket_type"),
        sa.CheckConstraint("bind_source IN ('auto', 'manual', 'none')", name="check_compiled_projection_bind_source"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["place_id"], ["trip_places.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "entry_id",
            "compiler_version",
            name="uq_trip_compiled_projection_items_trip_entry_version",
        ),
    )
    op.create_index(
        "idx_compiled_projection_items_trip_day_order",
        "trip_compiled_projection_items",
        ["trip_id", "day_key", "order_index"],
        unique=False,
    )
    op.create_index(
        "idx_compiled_projection_items_trip_captured",
        "trip_compiled_projection_items",
        ["trip_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_compiled_projection_items_trip_bucket",
        "trip_compiled_projection_items",
        ["trip_id", "bucket_type"],
        unique=False,
    )

    op.create_table(
        "trip_compiled_route_segments",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("segment_key", sa.String(length=160), nullable=False),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("distance_m", sa.Float(), nullable=False, server_default="0"),
        sa.Column("raw_point_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("simplified_point_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("geometry", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("compiler_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.CheckConstraint("distance_m >= 0", name="check_compiled_route_segment_distance"),
        sa.CheckConstraint("raw_point_count >= 0", name="check_compiled_route_segment_raw_points"),
        sa.CheckConstraint(
            "simplified_point_count >= 0",
            name="check_compiled_route_segment_simplified_points",
        ),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_id"], ["trip_tracking_sessions.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "segment_key",
            "compiler_version",
            name="uq_trip_compiled_route_segments_trip_key_version",
        ),
    )
    op.create_index(
        "idx_compiled_route_segments_trip_start",
        "trip_compiled_route_segments",
        ["trip_id", "started_at"],
        unique=False,
    )
    op.create_index(
        "idx_compiled_route_segments_trip_session",
        "trip_compiled_route_segments",
        ["trip_id", "session_id"],
        unique=False,
    )

    op.create_table(
        "trip_compiled_projection_overrides",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("source_kind", sa.String(length=32), nullable=False),
        sa.Column("source_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("action", sa.String(length=16), nullable=False),
        sa.Column("trip_place_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.CheckConstraint(
            "source_kind IN ('tracking_event', 'tracking_event_media')",
            name="check_compiled_projection_override_source_kind",
        ),
        sa.CheckConstraint("action IN ('bind', 'unbind')", name="check_compiled_projection_override_action"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_place_id"], ["trip_places.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "source_kind",
            "source_id",
            name="uq_trip_compiled_projection_overrides_source",
        ),
    )
    op.create_index(
        "ix_trip_compiled_projection_overrides_trip_id",
        "trip_compiled_projection_overrides",
        ["trip_id"],
        unique=False,
    )
