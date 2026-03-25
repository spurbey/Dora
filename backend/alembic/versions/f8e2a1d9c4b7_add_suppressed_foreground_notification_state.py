"""add suppressed_foreground notification delivery state

Revision ID: f8e2a1d9c4b7
Revises: b3f1d8c7e2a4
Create Date: 2026-03-25 15:10:00.000000

Rollback notes:
- Restores previous delivery_state check constraint without `suppressed_foreground`.
- Existing rows using `suppressed_foreground` are rewritten to `terminal_failure` on downgrade.
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "f8e2a1d9c4b7"
down_revision: Union[str, None] = "b3f1d8c7e2a4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_constraint(
        "check_tracking_notifications_delivery_state",
        "trip_tracking_notifications",
        type_="check",
    )
    op.create_check_constraint(
        "check_tracking_notifications_delivery_state",
        "trip_tracking_notifications",
        (
            "delivery_state IN ("
            "'pending',"
            "'sent',"
            "'retryable_failure',"
            "'transport_unavailable',"
            "'no_tokens',"
            "'suppressed_foreground',"
            "'terminal_failure',"
            "'acted'"
            ")"
        ),
    )


def downgrade() -> None:
    op.execute(
        sa.text(
            """
            UPDATE trip_tracking_notifications
            SET delivery_state = 'terminal_failure'
            WHERE delivery_state = 'suppressed_foreground'
            """
        )
    )
    op.drop_constraint(
        "check_tracking_notifications_delivery_state",
        "trip_tracking_notifications",
        type_="check",
    )
    op.create_check_constraint(
        "check_tracking_notifications_delivery_state",
        "trip_tracking_notifications",
        (
            "delivery_state IN ("
            "'pending',"
            "'sent',"
            "'retryable_failure',"
            "'transport_unavailable',"
            "'no_tokens',"
            "'terminal_failure',"
            "'acted'"
            ")"
        ),
    )
