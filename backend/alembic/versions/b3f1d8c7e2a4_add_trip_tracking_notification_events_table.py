"""add append-only trip tracking notification events

Revision ID: b3f1d8c7e2a4
Revises: a7d9c4e1f2b3
Create Date: 2026-03-22 04:20:00.000000

Rollback notes:
- Drops `trip_tracking_notification_events` and related indexes/check constraints.
- Historical notification transition rows are permanently removed on downgrade.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "b3f1d8c7e2a4"
down_revision: Union[str, None] = "a7d9c4e1f2b3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "trip_tracking_notification_events",
        sa.Column("id", sa.UUID(), nullable=False, comment="Notification event row ID"),
        sa.Column("notification_id", sa.UUID(), nullable=False, comment="Parent notification snapshot row"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Parent trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("candidate_id", sa.UUID(), nullable=False, comment="Linked check-in candidate ID"),
        sa.Column("channel", sa.String(length=16), nullable=False, comment="inbox|push"),
        sa.Column("event_type", sa.String(length=24), nullable=False, comment="handoff|dispatch|action"),
        sa.Column(
            "delivery_state",
            sa.String(length=32),
            nullable=False,
            comment="Snapshot state at this event transition",
        ),
        sa.Column(
            "attempt_count",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("0"),
            comment="Attempt count at this event transition",
        ),
        sa.Column("last_error", sa.Text(), nullable=True, comment="Error snapshot at this event transition"),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Transition payload snapshot",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
            comment="Transition timestamp",
        ),
        sa.CheckConstraint(
            "channel IN ('inbox', 'push')",
            name="check_tracking_notification_events_channel",
        ),
        sa.CheckConstraint(
            "event_type IN ('handoff', 'dispatch', 'action')",
            name="check_tracking_notification_events_event_type",
        ),
        sa.CheckConstraint(
            "attempt_count >= 0",
            name="check_tracking_notification_events_attempt_count",
        ),
        sa.ForeignKeyConstraint(["notification_id"], ["trip_tracking_notifications.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["candidate_id"], ["trip_checkin_candidates.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "idx_tracking_notification_events_notification_created",
        "trip_tracking_notification_events",
        ["notification_id", "created_at"],
        unique=False,
    )
    op.create_index(
        "idx_tracking_notification_events_user_created",
        "trip_tracking_notification_events",
        ["user_id", "created_at"],
        unique=False,
    )
    op.create_index(
        "idx_tracking_notification_events_candidate_created",
        "trip_tracking_notification_events",
        ["candidate_id", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        "idx_tracking_notification_events_candidate_created",
        table_name="trip_tracking_notification_events",
    )
    op.drop_index(
        "idx_tracking_notification_events_user_created",
        table_name="trip_tracking_notification_events",
    )
    op.drop_index(
        "idx_tracking_notification_events_notification_created",
        table_name="trip_tracking_notification_events",
    )
    op.drop_table("trip_tracking_notification_events")

