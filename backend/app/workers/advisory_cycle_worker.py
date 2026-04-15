"""
Advisory Cycle Worker — drives the periodic "what's next for this trip?" loop.

Poll loop (every ADVISORY_CYCLE_POLL_SECONDS):

    Phase 1 (short-lock claim batch):
        CTE: SELECT due trips FOR UPDATE SKIP LOCKED LIMIT N
        UPDATE: bump next_eligible_at by processing_timeout (lease)
        RETURNING: trip_ids to process

    Phase 2 (per-trip independent transactions):
        For each trip_id:
            pick_next_target(trip_id)
              - found    → enqueue location_trigger AdvisoryJob
              - no_target→ brain.mark_cycle_outcome('no_target')
              - off_route→ brain.mark_cycle_outcome('off_route')

    Pending-reseed flush:
        Trips with non-empty pending_reseed_reasons and last_seed_at older
        than the debounce window get a single coalesced reseed run.

Run with: python -m app.workers.advisory_cycle_worker
"""

from __future__ import annotations

import asyncio
import logging
import time
from typing import List
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.config import settings
from app.database import SessionLocal
from app.models.trip_advisory_state import TripAdvisoryState
from app.services.advisory_service import AdvisoryService
from app.services.trip_brain_service import TargetContext, TripBrainService

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Phase 1 — claim batch
# ---------------------------------------------------------------------------


def claim_due_trips(db: Session, *, batch_size: int, lease_seconds: int) -> List[str]:
    """Atomically claim the next batch of due trips.

    Returns trip_ids (as strings). The UPDATE pushes next_eligible_at
    forward by lease_seconds so a crashed worker's claim is automatically
    re-claimable after the lease expires.
    """
    rows = db.execute(
        text(
            """
            WITH due AS (
                SELECT trip_id
                FROM trip_advisory_state
                WHERE lifecycle_state = 'active'
                  AND next_eligible_at IS NOT NULL
                  AND next_eligible_at <= now()
                ORDER BY next_eligible_at ASC
                LIMIT :batch_size
                FOR UPDATE SKIP LOCKED
            )
            UPDATE trip_advisory_state AS t
            SET next_eligible_at = now()
                + make_interval(secs => :lease_seconds),
                updated_at = now()
            FROM due
            WHERE t.trip_id = due.trip_id
            RETURNING t.trip_id;
            """
        ),
        {"batch_size": batch_size, "lease_seconds": lease_seconds},
    ).fetchall()
    db.commit()
    return [str(r[0]) for r in rows]


# ---------------------------------------------------------------------------
# Phase 2 — per-trip processing
# ---------------------------------------------------------------------------


async def process_trip(db: Session, trip_id: str) -> None:
    """Resolve pick_next_target for one trip and enqueue / outcome accordingly.

    Runs in its own transaction; never holds cross-trip locks.
    """
    brain_svc = TripBrainService(db)
    advisory_svc = AdvisoryService(db)

    decision = await brain_svc.pick_next_target(UUID(trip_id))
    outcome = decision.outcome
    target: TargetContext | None = decision.target

    if outcome == "found" and target is not None:
        # Load the owner's user_id for create_advisory_job.
        owner = (
            db.query(TripAdvisoryState.user_id)
            .filter(TripAdvisoryState.trip_id == trip_id)
            .first()
        )
        if owner is None:
            logger.warning("cycle_worker: brain missing for trip %s", trip_id)
            return
        user_id = owner[0]

        trigger_payload = dict(target.to_dict())
        # Tie request_hash to the locality so repeated triggers for the same
        # locality coalesce into a single active job.
        trigger_payload["segment_id"] = target.locality_key
        try:
            job = advisory_svc.create_advisory_job(
                user_id=user_id,
                trip_id=UUID(trip_id),
                job_type="location_trigger",
                trigger_payload=trigger_payload,
            )
            logger.info(
                "[CYCLE] enqueued location_trigger job_id=%s trip_id=%s locality=%s",
                job.id,
                trip_id,
                target.locality,
            )
        except Exception as exc:  # noqa: BLE001 — non-fatal; move on
            logger.warning(
                "[CYCLE] create_advisory_job failed trip_id=%s: %s",
                trip_id,
                exc,
            )
            # Mark as failed so next_eligible_at advances and we don't spin.
            try:
                await brain_svc.mark_cycle_outcome(
                    UUID(trip_id), "failed", target=target
                )
            except Exception as inner:  # noqa: BLE001
                logger.warning("[CYCLE] mark_cycle_outcome(failed) error: %s", inner)
        return

    # No target / off-route — advance next_eligible_at via retry backoff.
    try:
        await brain_svc.mark_cycle_outcome(UUID(trip_id), outcome)
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "[CYCLE] mark_cycle_outcome(%s) error trip_id=%s: %s",
            outcome,
            trip_id,
            exc,
        )


# ---------------------------------------------------------------------------
# Pending-reseed flush
# ---------------------------------------------------------------------------


def list_reseed_candidates(db: Session, limit: int = 25) -> List[tuple[str, list[str]]]:
    """Return (trip_id, pending_reseed_reasons) for trips whose debounce window elapsed."""
    rows = db.execute(
        text(
            """
            SELECT trip_id, pending_reseed_reasons
            FROM trip_advisory_state
            WHERE COALESCE(array_length(pending_reseed_reasons, 1), 0) > 0
              AND (
                last_seed_at IS NULL
                OR last_seed_at < now()
                    - make_interval(secs => :window)
              )
            ORDER BY updated_at ASC
            LIMIT :limit
            """
        ),
        {
            "window": settings.ADVISORY_RESEED_MIN_INTERVAL_SECONDS,
            "limit": limit,
        },
    ).fetchall()
    out: list[tuple[str, list[str]]] = []
    for r in rows:
        trip_id = str(r[0])
        reasons = list(r[1] or [])
        out.append((trip_id, reasons))
    return out


async def flush_pending_reseeds(db: Session, limit: int = 25) -> int:
    candidates = list_reseed_candidates(db, limit=limit)
    count = 0
    for trip_id, reasons in candidates:
        try:
            svc = TripBrainService(db)
            await svc.reseed(UUID(trip_id), reasons=reasons or ["coalesced_pending"])
            count += 1
            logger.info(
                "[CYCLE] reseed flushed trip_id=%s reasons=%s", trip_id, reasons
            )
        except Exception as exc:  # noqa: BLE001
            logger.warning(
                "[CYCLE] reseed flush error trip_id=%s: %s", trip_id, exc
            )
    return count


# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------


async def run_tick() -> int:
    """One full tick: flush reseeds + claim batch + process each trip.

    Returns the number of trips processed in this tick (excluding reseeds).
    """
    with SessionLocal() as db:
        await flush_pending_reseeds(db)

    with SessionLocal() as db:
        trip_ids = claim_due_trips(
            db,
            batch_size=settings.ADVISORY_CYCLE_BATCH_SIZE,
            lease_seconds=settings.ADVISORY_CYCLE_PROCESSING_TIMEOUT_SECONDS,
        )
    if not trip_ids:
        return 0

    processed = 0
    for trip_id in trip_ids:
        with SessionLocal() as db:
            try:
                await process_trip(db, trip_id)
                processed += 1
            except Exception as exc:  # noqa: BLE001
                logger.warning(
                    "[CYCLE] process_trip error trip_id=%s: %s", trip_id, exc
                )
    return processed


def run_forever() -> None:
    poll = settings.ADVISORY_CYCLE_POLL_SECONDS
    consecutive_errors = 0
    logger.info("[CYCLE_WORKER] starting poll=%.1fs", poll)
    while True:
        try:
            processed = asyncio.run(run_tick())
            consecutive_errors = 0
            if processed == 0:
                time.sleep(poll)
        except Exception as exc:  # noqa: BLE001
            consecutive_errors += 1
            backoff = min(60.0, 5.0 * (2 ** (consecutive_errors - 1)))
            logger.error(
                "[CYCLE_WORKER] tick error #%d (retry in %.1fs): %s",
                consecutive_errors,
                backoff,
                exc,
            )
            time.sleep(backoff)


if __name__ == "__main__":
    run_forever()
