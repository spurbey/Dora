import asyncio
import logging
from typing import Any, Callable, Coroutine

from app.database import SessionLocal

logger = logging.getLogger(__name__)


def spawn_best_effort(
    coro_factory: Callable[..., Coroutine[Any, Any, Any]],
    *args: Any,
    label: str = "background_task",
) -> None:
    """Fire-and-forget an async task with a fresh DB session.

    coro_factory receives (db_session, *args).
    """

    async def _run() -> None:
        local_db = SessionLocal()
        try:
            await coro_factory(local_db, *args)
        except Exception:
            logger.warning("%s failed", label, exc_info=True)
        finally:
            local_db.close()

    try:
        asyncio.get_running_loop().create_task(_run())
    except RuntimeError:
        logger.warning("%s skipped: no running event loop", label)
