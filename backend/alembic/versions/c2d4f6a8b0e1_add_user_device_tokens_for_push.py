"""add user device tokens for push notifications

Revision ID: c2d4f6a8b0e1
Revises: f3a7b8c9d0e1
Create Date: 2026-03-21 21:05:00.000000

Rollback notes:
- Drops `user_device_tokens` table and related indexes/check constraints.
- Device token registrations are permanently removed on downgrade.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "c2d4f6a8b0e1"
down_revision: Union[str, None] = "f3a7b8c9d0e1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "user_device_tokens",
        sa.Column("id", sa.UUID(), nullable=False, comment="Device token row ID"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("platform", sa.String(length=16), nullable=False, comment="ios|android|web"),
        sa.Column(
            "push_token",
            sa.String(length=512),
            nullable=False,
            comment="Platform push token (FCM/APNs)",
        ),
        sa.Column("device_id", sa.String(length=128), nullable=True, comment="Client device identifier"),
        sa.Column("app_version", sa.String(length=32), nullable=True, comment="Client app version"),
        sa.Column("locale", sa.String(length=32), nullable=True, comment="Client locale"),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
            comment="Whether token is active for dispatch",
        ),
        sa.Column(
            "last_seen_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
            comment="Last token refresh/seen timestamp",
        ),
        sa.Column(
            "last_sent_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Last successful send timestamp",
        ),
        sa.Column(
            "failure_count",
            sa.Integer(),
            nullable=False,
            server_default=sa.text("0"),
            comment="Consecutive delivery failure count",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "push_token", name="uq_user_device_tokens_user_token"),
        sa.CheckConstraint(
            "platform IN ('ios', 'android', 'web')",
            name="check_user_device_tokens_platform",
        ),
        sa.CheckConstraint(
            "failure_count >= 0",
            name="check_user_device_tokens_failure_count",
        ),
    )
    op.create_index(
        "idx_user_device_tokens_user_active",
        "user_device_tokens",
        ["user_id", "is_active"],
        unique=False,
    )
    op.create_index(
        "idx_user_device_tokens_last_seen",
        "user_device_tokens",
        ["last_seen_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("idx_user_device_tokens_last_seen", table_name="user_device_tokens")
    op.drop_index("idx_user_device_tokens_user_active", table_name="user_device_tokens")
    op.drop_table("user_device_tokens")
