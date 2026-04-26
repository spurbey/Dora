"""brain phase machine + locality confidence

Adds two columns to trip_advisory_state to support the Mode A/B refactor:

- phase: 'planning' | 'live_companion' | 'paused'
    Drives stage routing in advisory_worker. Mode A (planning) uses
    Reddit + TripAdvisor for breadth and skips GMaps. Mode B
    (live_companion) flips on first V2 session start and adds GMaps
    for live POI lookups.

- locality_confidence: jsonb
    Per-(locality, intent_category) cached confidence from previously
    delivered advisories. Read by clarify_intent stage to decide
    whether to scrape, ask a clarifying question, or skip.
    Shape: {"khandala": {"food_tip": 0.85, "_signals": {...}}, ...}

Existing rows default to phase='planning' (correct: any seeded brain
that has not yet had enrich_on_tracking_start called is, by definition,
in the planning window). enrich_on_tracking_start will flip phase to
'live_companion' from a follow-up commit.

Revision ID: a7f9c2e4d8b1
Revises: e3c5a8d1b9f0
Create Date: 2026-04-26
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "a7f9c2e4d8b1"
down_revision: Union[str, None] = "e3c5a8d1b9f0"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


PHASE_CHECK_NAME = "ck_trip_advisory_state_phase"


def upgrade() -> None:
    op.add_column(
        "trip_advisory_state",
        sa.Column(
            "phase",
            sa.String(length=20),
            nullable=False,
            server_default="planning",
        ),
    )
    op.add_column(
        "trip_advisory_state",
        sa.Column(
            "locality_confidence",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
    )
    op.add_column(
        "trip_advisory_state",
        sa.Column(
            "last_phase_change_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )
    op.create_check_constraint(
        PHASE_CHECK_NAME,
        "trip_advisory_state",
        "phase IN ('planning','live_companion','paused')",
    )


def downgrade() -> None:
    op.drop_constraint(PHASE_CHECK_NAME, "trip_advisory_state", type_="check")
    op.drop_column("trip_advisory_state", "last_phase_change_at")
    op.drop_column("trip_advisory_state", "locality_confidence")
    op.drop_column("trip_advisory_state", "phase")
