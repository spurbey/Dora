"""
Conversation service — orchestrates reads/writes to
`advisory_conversation_messages` with read-through / write-through caching.

DB is source of truth; cache (AdvisoryCache) is a hot tail. This module is
the single place where conversation messages are persisted so that cache
invalidation and appending stay consistent.
"""

from __future__ import annotations

import logging
from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlalchemy import desc
from sqlalchemy.orm import Session

from app.models.advisory_conversation_message import AdvisoryConversationMessage
from app.services.advisory_cache import advisory_cache

logger = logging.getLogger(__name__)


async def list_messages(
    db: Session,
    trip_id: UUID,
    limit: int = 50,
    before: Optional[datetime] = None,
) -> tuple[list[AdvisoryConversationMessage], bool]:
    """Return (messages_chronological, has_more).

    Read-through cache: if `before` is None and limit <= 30, try hot cache
    first. Otherwise go straight to DB for accuracy.
    """
    use_cache = before is None and limit <= advisory_cache._CONV_MAX_TAIL
    if use_cache:
        cached = await advisory_cache.get_conversation_tail(str(trip_id))
        if cached is not None:
            # cached is already chronological, newest at tail
            tail = cached[-limit:]
            has_more = len(cached) > limit
            return tail, has_more

    q = db.query(AdvisoryConversationMessage).filter(
        AdvisoryConversationMessage.trip_id == trip_id
    )
    if before is not None:
        q = q.filter(AdvisoryConversationMessage.created_at < before)
    rows = (
        q.order_by(desc(AdvisoryConversationMessage.created_at))
        .limit(limit + 1)
        .all()
    )
    has_more = len(rows) > limit
    rows = rows[:limit]
    rows.reverse()  # chronological order

    if use_cache and rows:
        try:
            await advisory_cache.set_conversation_tail(
                str(trip_id), [m.to_dict() for m in rows]
            )
        except Exception:  # noqa: BLE001 — cache warm is best-effort
            logger.warning("conversation cache warm failed", exc_info=True)

    return rows, has_more


async def persist_message(
    db: Session,
    trip_id: UUID,
    user_id: UUID,
    role: str,
    message_type: str,
    content: Optional[str] = None,
    message_metadata: Optional[dict] = None,
    advisory_job_id: Optional[UUID] = None,
    advisory_id: Optional[UUID] = None,
) -> AdvisoryConversationMessage:
    """Insert a conversation message, commit, and best-effort cache append."""
    msg = AdvisoryConversationMessage(
        trip_id=trip_id,
        user_id=user_id,
        role=role,
        message_type=message_type,
        content=content,
        message_metadata=message_metadata,
        advisory_job_id=advisory_job_id,
        advisory_id=advisory_id,
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)

    try:
        await advisory_cache.append_conversation_message(
            str(trip_id), msg.to_dict()
        )
    except Exception:  # noqa: BLE001
        logger.warning("conversation cache append failed", exc_info=True)

    return msg
