"""add tracking media batch table and compiler source-kind expansion

Revision ID: f4b8c9d1e2a3
Revises: 9d1c4e7b2a6f
Create Date: 2026-04-01 00:45:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "f4b8c9d1e2a3"
down_revision: Union[str, None] = "9d1c4e7b2a6f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "trip_tracking_event_media",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_media_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_event_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("media_type", sa.String(length=16), nullable=False),
        sa.Column("bind_mode", sa.String(length=16), nullable=False),
        sa.Column("trip_place_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("anchor_latitude", sa.Float(), nullable=True),
        sa.Column("anchor_longitude", sa.Float(), nullable=True),
        sa.Column("upload_ref", sa.Text(), nullable=False),
        sa.Column("mime_type", sa.String(length=128), nullable=True),
        sa.Column("file_size_bytes", sa.Integer(), nullable=True),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
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
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["event_id"],
            ["trip_tracking_events.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(["trip_place_id"], ["trip_places.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "user_id",
            "client_media_id",
            name="uq_tracking_event_media_trip_user_client_media",
        ),
        sa.CheckConstraint(
            "media_type IN ('photo', 'media')",
            name="check_trip_tracking_event_media_type",
        ),
        sa.CheckConstraint(
            "bind_mode IN ('place', 'route')",
            name="check_trip_tracking_event_media_bind_mode",
        ),
        sa.CheckConstraint(
            "(bind_mode != 'place') OR trip_place_id IS NOT NULL",
            name="check_trip_tracking_event_media_place_mode",
        ),
        sa.CheckConstraint(
            "(bind_mode != 'route') OR "
            "(anchor_latitude IS NOT NULL AND anchor_longitude IS NOT NULL)",
            name="check_trip_tracking_event_media_route_mode",
        ),
        sa.CheckConstraint(
            "anchor_latitude IS NULL OR (anchor_latitude >= -90 AND anchor_latitude <= 90)",
            name="check_trip_tracking_event_media_anchor_latitude",
        ),
        sa.CheckConstraint(
            "anchor_longitude IS NULL OR (anchor_longitude >= -180 AND anchor_longitude <= 180)",
            name="check_trip_tracking_event_media_anchor_longitude",
        ),
    )
    op.create_index(
        "idx_trip_tracking_event_media_trip_captured_at",
        "trip_tracking_event_media",
        ["trip_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_event_media_user_captured_at",
        "trip_tracking_event_media",
        ["user_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_event_media_event_captured_at",
        "trip_tracking_event_media",
        ["event_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_event_media_bind_mode_captured_at",
        "trip_tracking_event_media",
        ["bind_mode", "captured_at"],
        unique=False,
    )

    op.drop_constraint(
        "check_compiled_projection_source_kind",
        "trip_compiled_projection_items",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_source_kind",
        "trip_compiled_projection_items",
        "source_kind IN ('tracking_event', 'tracking_event_media')",
    )

    op.drop_constraint(
        "check_compiled_projection_event_type",
        "trip_compiled_projection_items",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_event_type",
        "trip_compiled_projection_items",
        "event_type IN ('note', 'warn', 'tag', 'photo', 'media')",
    )

    op.drop_constraint(
        "check_compiled_projection_override_source_kind",
        "trip_compiled_projection_overrides",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_override_source_kind",
        "trip_compiled_projection_overrides",
        "source_kind IN ('tracking_event', 'tracking_event_media')",
    )


def downgrade() -> None:
    op.drop_constraint(
        "check_compiled_projection_override_source_kind",
        "trip_compiled_projection_overrides",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_override_source_kind",
        "trip_compiled_projection_overrides",
        "source_kind IN ('tracking_event')",
    )

    op.drop_constraint(
        "check_compiled_projection_event_type",
        "trip_compiled_projection_items",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_event_type",
        "trip_compiled_projection_items",
        "event_type IN ('note', 'warn', 'tag')",
    )

    op.drop_constraint(
        "check_compiled_projection_source_kind",
        "trip_compiled_projection_items",
        type_="check",
    )
    op.create_check_constraint(
        "check_compiled_projection_source_kind",
        "trip_compiled_projection_items",
        "source_kind IN ('tracking_event')",
    )

    op.drop_index(
        "idx_trip_tracking_event_media_bind_mode_captured_at",
        table_name="trip_tracking_event_media",
    )
    op.drop_index(
        "idx_trip_tracking_event_media_event_captured_at",
        table_name="trip_tracking_event_media",
    )
    op.drop_index(
        "idx_trip_tracking_event_media_user_captured_at",
        table_name="trip_tracking_event_media",
    )
    op.drop_index(
        "idx_trip_tracking_event_media_trip_captured_at",
        table_name="trip_tracking_event_media",
    )
    op.drop_table("trip_tracking_event_media")
