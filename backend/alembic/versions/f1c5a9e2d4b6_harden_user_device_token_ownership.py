"""harden user device token ownership uniqueness

Revision ID: f1c5a9e2d4b6
Revises: d4e9c2a1b7f0
Create Date: 2026-03-22 02:45:00.000000

Rollback notes:
- Downgrade restores per-user token uniqueness.
- Rows deleted during duplicate-token reconciliation are not recoverable on downgrade.
"""

from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = "f1c5a9e2d4b6"
down_revision: Union[str, None] = "d4e9c2a1b7f0"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Keep a single winner row per push_token before adding global uniqueness.
    op.execute(
        """
        WITH ranked AS (
            SELECT
                id,
                ROW_NUMBER() OVER (
                    PARTITION BY push_token
                    ORDER BY
                        is_active DESC,
                        last_seen_at DESC NULLS LAST,
                        updated_at DESC NULLS LAST,
                        created_at DESC NULLS LAST,
                        id DESC
                ) AS rn
            FROM user_device_tokens
        )
        DELETE FROM user_device_tokens AS udt
        USING ranked
        WHERE udt.id = ranked.id
          AND ranked.rn > 1;
        """
    )

    op.drop_constraint(
        "uq_user_device_tokens_user_token",
        "user_device_tokens",
        type_="unique",
    )
    op.create_unique_constraint(
        "uq_user_device_tokens_push_token",
        "user_device_tokens",
        ["push_token"],
    )


def downgrade() -> None:
    op.drop_constraint(
        "uq_user_device_tokens_push_token",
        "user_device_tokens",
        type_="unique",
    )
    op.create_unique_constraint(
        "uq_user_device_tokens_user_token",
        "user_device_tokens",
        ["user_id", "push_token"],
    )

