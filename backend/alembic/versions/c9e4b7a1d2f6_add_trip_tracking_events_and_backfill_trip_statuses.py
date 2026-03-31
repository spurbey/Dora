"""add trip_tracking_events and backfill legacy tracking trip statuses

Revision ID: c9e4b7a1d2f6
Revises: f8e2a1d9c4b7
Create Date: 2026-03-31 10:05:00.000000

Notes:
- Adds `trip_tracking_events` for local-first live-capture event ingestion.
- Backfills legacy tracking-driven trip statuses to `planned` so session state
  becomes the authoritative runtime lifecycle signal.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "c9e4b7a1d2f6"
down_revision: Union[str, None] = "f8e2a1d9c4b7"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "trip_tracking_events",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("client_event_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event_type", sa.String(length=32), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["session_id"], ["trip_tracking_sessions.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "trip_id",
            "user_id",
            "client_event_id",
            name="uq_tracking_event_trip_user_client_event",
        ),
        sa.CheckConstraint(
            "event_type IN ('note', 'warn', 'tag', 'photo', 'media')",
            name="check_trip_tracking_event_type",
        ),
        sa.CheckConstraint(
            "latitude IS NULL OR (latitude >= -90 AND latitude <= 90)",
            name="check_trip_tracking_event_latitude",
        ),
        sa.CheckConstraint(
            "longitude IS NULL OR (longitude >= -180 AND longitude <= 180)",
            name="check_trip_tracking_event_longitude",
        ),
    )
    op.create_index(
        "idx_trip_tracking_events_trip_captured_at",
        "trip_tracking_events",
        ["trip_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_events_user_captured_at",
        "trip_tracking_events",
        ["user_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_events_session_captured_at",
        "trip_tracking_events",
        ["session_id", "captured_at"],
        unique=False,
    )
    op.create_index(
        "idx_trip_tracking_events_type_captured_at",
        "trip_tracking_events",
        ["event_type", "captured_at"],
        unique=False,
    )

    # Legacy status cleanup: tracking runtime is now sourced from session state.
    op.execute(
        sa.text(
            """
            UPDATE trips
            SET status = 'planned'
            WHERE status IN ('tracking_active', 'tracking_paused', 'review_pending')
            """
        )
    )


def downgrade() -> None:
    op.drop_index("idx_trip_tracking_events_type_captured_at", table_name="trip_tracking_events")
    op.drop_index("idx_trip_tracking_events_session_captured_at", table_name="trip_tracking_events")
    op.drop_index("idx_trip_tracking_events_user_captured_at", table_name="trip_tracking_events")
    op.drop_index("idx_trip_tracking_events_trip_captured_at", table_name="trip_tracking_events")
    op.drop_table("trip_tracking_events")
