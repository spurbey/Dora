"""
Story retention worker.

Runs periodic lifecycle maintenance:
    - marks published rows as expired when TTL passes
    - purges story media objects after expiry + grace window
    - hard-deletes old rows after minimum retention window
"""

from __future__ import annotations

import logging
import time

from app.database import SessionLocal
from app.services.story_service import StoryService

logger = logging.getLogger(__name__)
POLL_SECONDS = 300


def run_tick() -> dict[str, int]:
    with SessionLocal() as db:
        service = StoryService(db)
        return service.run_retention_cleanup()


def run_forever() -> None:
    logger.info("[STORY_RETENTION] starting poll=%ss", POLL_SECONDS)
    while True:
        try:
            stats = run_tick()
            logger.info(
                "[STORY_RETENTION] expired=%s purged=%s deleted=%s",
                stats.get("expired_marked", 0),
                stats.get("media_purged", 0),
                stats.get("rows_deleted", 0),
            )
        except Exception as exc:  # noqa: BLE001
            logger.exception("[STORY_RETENTION] tick failed: %s", exc)
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    run_forever()
