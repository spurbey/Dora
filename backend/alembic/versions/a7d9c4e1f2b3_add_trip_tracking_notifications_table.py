"""add trip tracking notifications table for inbox parity

Revision ID: a7d9c4e1f2b3
Revises: f1c5a9e2d4b6
Create Date: 2026-03-22 03:35:00.000000

Rollback notes:
- Drops `trip_tracking_notifications` and associated indexes/check constraints.
- Notification audit/inbox state rows are permanently removed on downgrade.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "a7d9c4e1f2b3"
down_revision: Union[str, None] = "f1c5a9e2d4b6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "trip_tracking_notifications",
        sa.Column("id", sa.UUID(), nullable=False, comment="Notification row ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Parent trip ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("candidate_id", sa.UUID(), nullable=False, comment="Linked check-in candidate ID"),
        sa.Column("channel", sa.String(length=16), nullable=False, comment="inbox|push"),
        sa.Column(
            "delivery_state",
            sa.String(length=32),
            nullable=False,
            server_default=sa.text("'pending'::character varying"),
            comment="pending|sent|retryable_failure|transport_unavailable|no_tokens|terminal_failure|acted",
        ),
        sa.Column(
            "attempt_count",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("0"),
            comment="Total push attempts recorded for this channel/candidate",
        ),
        sa.Column("last_error", sa.Text(), nullable=True, comment="Latest error message (if any)"),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
            comment="Auxiliary metadata for delivery/inbox routing",
        ),
        sa.Column("last_attempt_at", sa.DateTime(timezone=True), nullable=True, comment="Most recent push dispatch attempt time"),
        sa.Column(
            "delivered_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When notification channel reached sent/delivered state",
        ),
        sa.Column("acknowledged_at", sa.DateTime(timezone=True), nullable=True, comment="When user acted on the candidate in-app"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.CheckConstraint(
            "channel IN ('inbox', 'push')",
            name="check_tracking_notifications_channel",
        ),
        sa.CheckConstraint(
            "delivery_state IN ('pending', 'sent', 'retryable_failure', 'transport_unavailable', 'no_tokens', 'terminal_failure', 'acted')",
            name="check_tracking_notifications_delivery_state",
        ),
        sa.CheckConstraint(
            "attempt_count >= 0",
            name="check_tracking_notifications_attempt_count",
        ),
        sa.ForeignKeyConstraint(["candidate_id"], ["trip_checkin_candidates.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("candidate_id", "channel", name="uq_tracking_notifications_candidate_channel"),
    )
    op.create_index(
        "idx_tracking_notifications_user_created",
        "trip_tracking_notifications",
        ["user_id", "created_at"],
        unique=False,
    )
    op.create_index(
        "idx_tracking_notifications_trip_created",
        "trip_tracking_notifications",
        ["trip_id", "created_at"],
        unique=False,
    )
    op.create_index(
        "idx_tracking_notifications_channel_state",
        "trip_tracking_notifications",
        ["channel", "delivery_state", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("idx_tracking_notifications_channel_state", table_name="trip_tracking_notifications")
    op.drop_index("idx_tracking_notifications_trip_created", table_name="trip_tracking_notifications")
    op.drop_index("idx_tracking_notifications_user_created", table_name="trip_tracking_notifications")
    op.drop_table("trip_tracking_notifications")
