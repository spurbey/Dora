"""add advisory_conversation_messages table and parent_message_id FK

Revision ID: d2f4e8a91b56
Revises: c7e1b9a2d4f0
Create Date: 2026-04-20

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "d2f4e8a91b56"
down_revision = "c7e1b9a2d4f0"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "advisory_conversation_messages",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("trip_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("role", sa.String(length=16), nullable=False),
        sa.Column("message_type", sa.String(length=32), nullable=False),
        sa.Column("content", sa.Text(), nullable=True),
        sa.Column("message_metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("advisory_job_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("advisory_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["trip_id"], ["trips.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["advisory_job_id"], ["advisory_jobs.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["advisory_id"], ["trip_advisories.id"], ondelete="SET NULL"),
        sa.CheckConstraint("role IN ('dora', 'user', 'system')", name="ck_conv_role"),
    )
    op.create_index(
        "ix_advisory_conversation_messages_trip_id",
        "advisory_conversation_messages",
        ["trip_id"],
    )
    op.create_index(
        "ix_advisory_conversation_messages_user_id",
        "advisory_conversation_messages",
        ["user_id"],
    )
    op.create_index(
        "ix_advisory_conversation_messages_created_at",
        "advisory_conversation_messages",
        ["created_at"],
    )
    op.create_index(
        "ix_conv_trip_created",
        "advisory_conversation_messages",
        ["trip_id", "created_at"],
    )

    # Add parent_message_id FK to advisory_jobs
    op.add_column(
        "advisory_jobs",
        sa.Column(
            "parent_message_id",
            postgresql.UUID(as_uuid=True),
            nullable=True,
        ),
    )
    op.create_foreign_key(
        "fk_advisory_jobs_parent_message",
        "advisory_jobs",
        "advisory_conversation_messages",
        ["parent_message_id"],
        ["id"],
        ondelete="SET NULL",
    )


def downgrade() -> None:
    op.drop_constraint("fk_advisory_jobs_parent_message", "advisory_jobs", type_="foreignkey")
    op.drop_column("advisory_jobs", "parent_message_id")
    op.drop_index("ix_conv_trip_created", table_name="advisory_conversation_messages")
    op.drop_index(
        "ix_advisory_conversation_messages_created_at",
        table_name="advisory_conversation_messages",
    )
    op.drop_index(
        "ix_advisory_conversation_messages_user_id",
        table_name="advisory_conversation_messages",
    )
    op.drop_index(
        "ix_advisory_conversation_messages_trip_id",
        table_name="advisory_conversation_messages",
    )
    op.drop_table("advisory_conversation_messages")
