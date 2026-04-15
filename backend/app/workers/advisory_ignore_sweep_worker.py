"""
Advisory Ignore Sweep Worker — implicit-ignore detection for delivered advisories.

Runs every 10 minutes. Any TripAdvisory still in 'delivered' after
ADVISORY_IGNORE_TTL_SECONDS with no AdvisoryUserAction row gets flipped to
'expired' atomically. Each expired advisory calls brain.apply_feedback
with action_type='implicit_ignore' so the trip brain can increment
ignore_streak and auto-pause after the threshold.

The UPDATE is race-safe:
    - Single guarded SQL: WHERE status='delivered' AND NOT EXISTS (action).
    - A user action arriving between statement planning and execution
      causes the NOT EXISTS to fail at execution time — the row is
      skipped, no expiration recorded.
    - The brain's apply_feedback adds defense-in-depth by re-checking
      advisory_user_actions under its own row lock before incrementing
      ignore_streak.

Run with: python -m app.workers.advisory_ignore_sweep_worker
"""

from __future__ import annotations

import asyncio
import logging
import time
from typing import List

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.config import settings
from app.database import SessionLocal
from app.services.trip_brain_service import TripBrainService

logger = logging.getLogger(__name__)


_SWEEP_INTERVAL_SECONDS = 600  # 10 minutes


def expire_stale_delivered(db: Session) -> List[tuple[str, str]]:
    """Flip stale delivered advisories to expired; return (advisory_id, trip_id)."""
    rows = db.execute(
        text(
            """
            UPDATE trip_advisories ta
            SET status = 'expired', updated_at = now()
            WHERE ta.status = 'delivered'
              AND ta.delivered_at < now()
                - make_interval(secs => :ttl_seconds)
              AND NOT EXISTS (
                  SELECT 1
                  FROM advisory_user_actions aua
                  WHERE aua.advisory_id = ta.id
              )
            RETURNING ta.id, ta.trip_id;
            """
        ),
        {"ttl_seconds": settings.ADVISORY_IGNORE_TTL_SECONDS},
    ).fetchall()
    db.commit()
    return [(str(r[0]), str(r[1])) for r in rows]


async def run_tick() -> int:
    """Run one sweep pass; return count of newly-expired advisories."""
    with SessionLocal() as db:
        expired = expire_stale_delivered(db)
    if not expired:
        return 0

    brain_touched = 0
    for advisory_id, _trip_id in expired:
        with SessionLocal() as db:
            try:
                TripBrainService(db).apply_feedback(
                    advisory_id, "implicit_ignore"
                )
                brain_touched += 1
            except Exception as exc:  # noqa: BLE001
                logger.warning(
                    "[IGNORE_SWEEP] apply_feedback error advisory_id=%s: %s",
                    advisory_id,
                    exc,
                )
    logger.info(
        "[IGNORE_SWEEP] expired=%d brain_touched=%d",
        len(expired),
        brain_touched,
    )
    return len(expired)


def run_forever() -> None:
    interval = _SWEEP_INTERVAL_SECONDS
    consecutive_errors = 0
    logger.info("[IGNORE_SWEEP_WORKER] starting interval=%ds", interval)
    while True:
        try:
            asyncio.run(run_tick())
            consecutive_errors = 0
            time.sleep(interval)
        except Exception as exc:  # noqa: BLE001
            consecutive_errors += 1
            backoff = min(interval, 30.0 * consecutive_errors)
            logger.error(
                "[IGNORE_SWEEP_WORKER] tick error #%d (retry in %.1fs): %s",
                consecutive_errors,
                backoff,
                exc,
            )
            time.sleep(backoff)


if __name__ == "__main__":
    run_forever()
