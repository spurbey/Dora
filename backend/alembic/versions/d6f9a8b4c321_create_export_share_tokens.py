"""create export_share_tokens table

Revision ID: d6f9a8b4c321
Revises: b1e4c7d9f2a1
Create Date: 2026-03-08 12:00:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "d6f9a8b4c321"
down_revision: Union[str, None] = "b1e4c7d9f2a1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "export_share_tokens",
        sa.Column("id", sa.UUID(), nullable=False, comment="Share token row ID"),
        sa.Column("token", sa.String(length=96), nullable=False, comment="Opaque share token"),
        sa.Column("user_id", sa.UUID(), nullable=False, comment="Owner user ID"),
        sa.Column("trip_id", sa.UUID(), nullable=False, comment="Trip ID for privacy enforcement"),
        sa.Column("job_id", sa.UUID(), nullable=False, comment="Export job ID"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["job_id"], ["export_jobs.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token", name="uq_export_share_tokens_token"),
    )

    op.create_index(
        "idx_export_share_tokens_job_active",
        "export_share_tokens",
        ["job_id", "revoked_at", "expires_at"],
        unique=False,
    )
    op.create_index(
        "idx_export_share_tokens_trip",
        "export_share_tokens",
        ["trip_id"],
        unique=False,
    )
    op.create_index(
        "idx_export_share_tokens_user",
        "export_share_tokens",
        ["user_id"],
        unique=False,
    )

    op.execute(
        """
        CREATE OR REPLACE FUNCTION set_export_share_tokens_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        """
    )
    op.execute(
        """
        CREATE TRIGGER trg_export_share_tokens_updated_at
        BEFORE UPDATE ON export_share_tokens
        FOR EACH ROW
        EXECUTE PROCEDURE set_export_share_tokens_updated_at();
        """
    )


def downgrade() -> None:
    op.execute("DROP TRIGGER IF EXISTS trg_export_share_tokens_updated_at ON export_share_tokens")
    op.execute("DROP FUNCTION IF EXISTS set_export_share_tokens_updated_at()")
    op.drop_index("idx_export_share_tokens_user", table_name="export_share_tokens")
    op.drop_index("idx_export_share_tokens_trip", table_name="export_share_tokens")
    op.drop_index("idx_export_share_tokens_job_active", table_name="export_share_tokens")
    op.drop_table("export_share_tokens")
