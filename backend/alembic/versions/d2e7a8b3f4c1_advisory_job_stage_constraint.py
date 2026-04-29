"""Update advisory_jobs.stage CHECK constraint to include clarify_intent and merge_dedup.

Phase 4/5 introduced two new pipeline stages — `clarify_intent` (LLM ask-first
gate) and `merge_dedup` (renamed from the misleading `llm_extraction`) — but
the CHECK constraint on advisory_jobs.stage was never updated. The advisory
worker's UPDATE to advance a job into either of these stages fails with
CheckViolation, leaving the job stuck in route_segmentation forever.

This migration drops the old constraint and recreates it with the expanded
allowed set. `llm_extraction` stays in the list as an alias for backward
compatibility with any in-flight jobs from before the rename.

Revision ID: d2e7a8b3f4c1
Revises: d8b7c6a5e4f3
Create Date: 2026-04-29
"""

from typing import Sequence, Union

from alembic import op


revision: str = "d2e7a8b3f4c1"
down_revision: Union[str, None] = "d8b7c6a5e4f3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_NEW_STAGES = (
    "route_segmentation",
    "reddit_scrape",
    "tripadvisor_scrape",
    "gmaps_scrape",
    "llm_extraction",
    "merge_dedup",
    "clarify_intent",
    "scoring",
    "delivery",
)
_OLD_STAGES = (
    "route_segmentation",
    "reddit_scrape",
    "tripadvisor_scrape",
    "gmaps_scrape",
    "llm_extraction",
    "scoring",
    "delivery",
)


def _stage_check_sql(stages: tuple[str, ...]) -> str:
    quoted = ", ".join(f"'{s}'" for s in stages)
    return f"stage IS NULL OR stage IN ({quoted})"


def upgrade() -> None:
    op.execute("ALTER TABLE advisory_jobs DROP CONSTRAINT IF EXISTS check_advisory_job_stage")
    op.create_check_constraint(
        "check_advisory_job_stage",
        "advisory_jobs",
        _stage_check_sql(_NEW_STAGES),
    )


def downgrade() -> None:
    op.execute("ALTER TABLE advisory_jobs DROP CONSTRAINT IF EXISTS check_advisory_job_stage")
    op.create_check_constraint(
        "check_advisory_job_stage",
        "advisory_jobs",
        _stage_check_sql(_OLD_STAGES),
    )
