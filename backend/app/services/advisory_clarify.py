"""
Clarify-intent stage — ask the user before guessing.

The advisory pipeline used to "guess and produce garbage" when it had thin
signals for a (locality, intent) pair. Now we read brain.locality_confidence
and either:

  >= 0.7   — high confidence; skip the clarifying question, scrape immediately
  0.5-0.7  — medium confidence; skip clarify, but the ranker downstream weights
             findings carefully (no separate ask-back path here)
  < 0.5    — low confidence; ask one focused clarifying question via the LLM,
             persist as a `clarifying_question` conversation message,
             block the job, send a push.

When the user answers via POST /trips/{id}/conversation/answer:
  - that endpoint patches the blocked job: scrape_plan.clarified=True,
    scrape_plan.clarified_filters={answer, metadata}, status='queued'
  - worker re-claims, runs clarify_intent again, sees `clarified=True`, no-ops,
    proceeds to the rest of the path.

Stage is feature-flagged via settings.ADVISORY_CLARIFY_ENABLED so we can roll
it out gradually. When disabled, this stage is a no-op.
"""

from __future__ import annotations

import logging
from typing import Optional
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from app.config import settings
from app.models.advisory_job import AdvisoryJob
from app.models.advisory_conversation_message import AdvisoryConversationMessage
from app.models.trip_advisory_state import TripAdvisoryState
from app.services import conversation_service
from app.services.advisory_cache import advisory_cache
from app.services.llm import chat_json

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Confidence math
# ---------------------------------------------------------------------------

# Tunables. Anything above HIGH skips clarify entirely. Anything below LOW
# triggers clarify (when feature flag is on). The middle band proceeds without
# clarifying but is still flagged in logs.
CONFIDENCE_HIGH = 0.7
CONFIDENCE_LOW = 0.5

# Soft "first interaction free pass" — if a trip has zero advisories and zero
# user_query messages so far, we don't ask a clarifying question on the very
# first job. Better to deliver something (even imperfect) than greet the user
# with a question.
FIRST_INTERACTION_FREE_PASS = True


def lookup_confidence(
    brain: TripAdvisoryState,
    locality_key: Optional[str],
    intent_categories: list[str],
) -> float:
    """Read max-of confidence across (locality, intent) for the categories
    we plan to deliver. Empty → 0."""
    if not locality_key:
        return 0.0
    by_locality = (brain.locality_confidence or {}).get(locality_key) or {}
    if not by_locality:
        return 0.0
    if not intent_categories:
        # No intent specified — average across whatever we have.
        scores = [
            float(v) for k, v in by_locality.items()
            if not k.startswith("_") and isinstance(v, (int, float))
        ]
        return max(scores) if scores else 0.0
    scores: list[float] = []
    for cat in intent_categories:
        v = by_locality.get(cat)
        if isinstance(v, (int, float)):
            scores.append(float(v))
    return max(scores) if scores else 0.0


def update_confidence(
    db: Session,
    trip_id: UUID,
    locality_key: str,
    *,
    delivered_categories: list[str],
    insights_count_per_category: Optional[dict[str, int]] = None,
) -> None:
    """Bump locality_confidence after a delivery.

    We use a simple heuristic:
      - Each delivered category for this locality gets +0.15 confidence,
        capped at 1.0.
      - If insights_count_per_category is provided, scale by log10(count + 1).
      - Records aggregated _signals counter for debugging.

    Updates run as a single jsonb_set call so concurrent writers don't
    clobber each other.
    """
    if not locality_key or not delivered_categories:
        return

    # Build an ordered list of (path, value) mutations. We do this in Python
    # then collapse into a single SQL UPDATE with chained jsonb_set so the
    # whole thing is atomic.
    counts = insights_count_per_category or {}
    now_value = {}
    for cat in delivered_categories:
        n = max(1, int(counts.get(cat, 1)))
        # Each delivered insight contributes diminishing returns.
        bump = min(0.15 * (n ** 0.5), 0.45)
        now_value[cat] = bump

    # We'll fetch existing, merge, write back. Simpler than chained jsonb_set
    # for this size and confidence scores aren't a hot write path.
    row = db.execute(
        text(
            "SELECT COALESCE(locality_confidence, '{}'::jsonb) AS lc "
            "FROM trip_advisory_state WHERE trip_id = :tid"
        ),
        {"tid": str(trip_id)},
    ).fetchone()
    if row is None:
        return
    current: dict = row[0] or {}
    by_loc = dict(current.get(locality_key) or {})
    for cat, bump in now_value.items():
        prev = float(by_loc.get(cat) or 0.0)
        # Bump exists → cap at 1.0; new → use bump as starting confidence.
        by_loc[cat] = round(min(1.0, prev + bump), 3)
    # Track raw signal counters for debugging.
    sig = dict(by_loc.get("_signals") or {})
    sig["delivered"] = int(sig.get("delivered", 0)) + sum(
        int(counts.get(c, 1)) for c in delivered_categories
    )
    by_loc["_signals"] = sig
    current[locality_key] = by_loc

    import json
    db.execute(
        text(
            "UPDATE trip_advisory_state "
            "SET locality_confidence = CAST(:lc AS jsonb), updated_at = now() "
            "WHERE trip_id = :tid"
        ),
        {"lc": json.dumps(current), "tid": str(trip_id)},
    )
    db.commit()


# ---------------------------------------------------------------------------
# LLM prompt — compact, JSON-strict
# ---------------------------------------------------------------------------


_CLARIFY_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "status": {"type": "string", "enum": ["ready", "clarify", "impossible"]},
        "question": {"type": ["string", "null"], "minLength": 6, "maxLength": 140},
        "options": {
            "type": ["array", "null"],
            "minItems": 2,
            "maxItems": 4,
            "items": {"type": "string", "minLength": 2, "maxLength": 40},
        },
        "reason": {"type": ["string", "null"], "maxLength": 160},
    },
    "required": ["status"],
}


def _build_messages(
    *,
    locality: str,
    intent_categories: list[str],
    trip_metadata: dict,
    user_metadata: dict,
    user_query: Optional[str],
    confidence: float,
    conversation_tail: list[dict],
) -> list[dict]:
    convo_tail = "\n".join(
        f"{m.get('role','?')}: {(m.get('content') or '')[:160]}"
        for m in (conversation_tail or [])[-6:]
    )
    convo_block = f"\nRecent conversation:\n{convo_tail}\n" if convo_tail else ""
    user_q_block = f"\nUser said: {user_query!r}\n" if user_query else ""
    intent = ", ".join(intent_categories) if intent_categories else "general travel"

    system = (
        "You are Dora, a warm travel companion. Decide whether you have enough "
        "context to help the traveler, or if ONE focused question would help. "
        "Return JSON per schema. Prefer 'ready' when you can make a reasonable "
        "guess from trip metadata + locality. Only ask 'clarify' when the "
        "answer would materially change which places/insights to surface. "
        "If the request can't be helped (off-topic, harmful, infeasible), "
        "return 'impossible' with a short reason. "
        "When clarifying: question must be friendly, concrete, <= 80 chars; "
        "provide 2-4 short option chips (each <= 30 chars) PLUS one 'Skip'. "
        "Never ask about things already in trip_metadata / user_metadata."
    )
    user = (
        f"Locality: {locality}\n"
        f"Traveler intent: {intent}\n"
        f"Confidence we already have for this locality+intent: {confidence:.2f}\n"
        f"Trip metadata: activity_focus={trip_metadata.get('activity_focus') or []}, "
        f"travel_style={trip_metadata.get('travel_style') or []}, "
        f"budget={trip_metadata.get('budget_category') or 'any'}\n"
        f"User metadata: dietary={user_metadata.get('dietary_restrictions') or []}, "
        f"dislikes={user_metadata.get('dislikes') or []}\n"
        f"{user_q_block}{convo_block}"
    )
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


# ---------------------------------------------------------------------------
# Stage entry point — called from advisory_worker
# ---------------------------------------------------------------------------


async def maybe_clarify(db: Session, job: AdvisoryJob) -> bool:
    """Run the clarify-intent decision for this job.

    Returns:
        True if the job should proceed to the next stage.
        False if the job has been blocked waiting for user response
        (caller must short-circuit; do not run further stages).
    """
    # Feature flag — disabled = no-op pass-through.
    if not getattr(settings, "ADVISORY_CLARIFY_ENABLED", False):
        return True

    plan = dict(job.scrape_plan or {})

    # Already cleared by a previous /conversation/answer? Skip.
    if plan.get("clarified"):
        return True

    # Only on_demand jobs ask the user back. Cycle/pre_trip jobs run
    # autonomously — asking would be confusing.
    if job.job_type != "on_demand":
        return True

    brain = (
        db.query(TripAdvisoryState)
        .filter(TripAdvisoryState.trip_id == job.trip_id)
        .one_or_none()
    )
    if brain is None:
        return True

    locality_key = (
        plan.get("target", {}).get("locality_key")
        if isinstance(plan.get("target"), dict)
        else None
    ) or (brain.advised_locality_keys[0] if brain.advised_locality_keys else None)

    intent_categories: list[str] = list(plan.get("focus_categories") or [])
    if not intent_categories:
        intent_categories = list(plan.get("intent_categories") or [])

    confidence = lookup_confidence(brain, locality_key, intent_categories)

    if confidence >= CONFIDENCE_HIGH:
        logger.info(
            "[clarify] job=%s skipping ask: high conf=%.2f for loc=%s intent=%s",
            job.id, confidence, locality_key, intent_categories,
        )
        return True

    if confidence >= CONFIDENCE_LOW:
        logger.info(
            "[clarify] job=%s medium conf=%.2f — proceeding without ask",
            job.id, confidence,
        )
        return True

    # First-interaction free pass — don't greet a brand-new trip with a question.
    if FIRST_INTERACTION_FREE_PASS:
        existing_user_msgs = (
            db.query(AdvisoryConversationMessage)
            .filter(
                AdvisoryConversationMessage.trip_id == job.trip_id,
                AdvisoryConversationMessage.role == "user",
            )
            .count()
        )
        if existing_user_msgs <= 1:
            # The current user_query is the first or only message — let it pass.
            logger.info(
                "[clarify] job=%s first-interaction free pass (user_msgs=%d)",
                job.id, existing_user_msgs,
            )
            return True

    # Low confidence + flag on + not first-interaction → ask the LLM.
    convo_tail = await advisory_cache.get_conversation_tail(str(job.trip_id))
    if convo_tail is None:
        convo_tail = []
        rows = (
            db.query(AdvisoryConversationMessage)
            .filter(AdvisoryConversationMessage.trip_id == job.trip_id)
            .order_by(AdvisoryConversationMessage.created_at.desc())
            .limit(10)
            .all()
        )
        rows.reverse()
        convo_tail = [m.to_dict() for m in rows]

    messages = _build_messages(
        locality=locality_key or "this destination",
        intent_categories=intent_categories,
        trip_metadata=dict(brain.trip_metadata_snapshot or {}),
        user_metadata=dict(brain.user_metadata_snapshot or {}),
        user_query=job.query_text,
        confidence=confidence,
        conversation_tail=convo_tail,
    )

    try:
        out = await chat_json(
            messages=messages,
            schema=_CLARIFY_SCHEMA,
            timeout_seconds=15.0,
            label="clarify_intent",
        )
    except Exception:  # noqa: BLE001
        logger.warning("[clarify] LLM call threw; proceeding without ask")
        return True

    if out is None:
        logger.info("[clarify] LLM unavailable; proceeding without ask")
        return True

    status = out.get("status")
    if status == "ready":
        plan["clarified"] = True
        job.scrape_plan = plan
        flag_modified(job, "scrape_plan")
        db.commit()
        return True

    if status == "impossible":
        # Persist a friendly system_note so the user sees something.
        await conversation_service.persist_message(
            db,
            trip_id=job.trip_id,
            user_id=job.user_id,
            role="system",
            message_type="system_note",
            content=(out.get("reason") or "I can't help with that one — try Google Maps directly."),
            message_metadata={"reason_code": "clarify_impossible"},
            advisory_job_id=job.id,
        )
        # Mark the job complete with no advisories. This is a deliberate skip,
        # not a failure.
        job.status = "completed"
        job.stage = "clarify_intent"
        job.progress = 1.0
        from datetime import datetime, timezone
        job.completed_at = datetime.now(timezone.utc)
        plan["clarify_outcome"] = "impossible"
        job.scrape_plan = plan
        flag_modified(job, "scrape_plan")
        db.commit()
        return False

    # status == "clarify"
    question_text = (out.get("question") or "").strip()
    options = out.get("options") or []
    if not question_text or not options:
        logger.info(
            "[clarify] LLM returned clarify but missing question/options; proceeding"
        )
        return True

    # Always include a Skip option so the user isn't trapped.
    if not any(o.lower().startswith("skip") for o in options):
        options = list(options) + ["Skip"]

    msg = await conversation_service.persist_message(
        db,
        trip_id=job.trip_id,
        user_id=job.user_id,
        role="dora",
        message_type="clarifying_question",
        content=question_text,
        message_metadata={
            "options": options,
            "blocked_job_id": str(job.id),
            "locality_key": locality_key,
            "intent_categories": intent_categories,
        },
        advisory_job_id=job.id,
    )

    await advisory_cache.set_pending_question(
        str(job.trip_id), str(msg.id), str(job.id)
    )

    # Block the job until the user answers.
    job.status = "blocked"
    job.stage = "clarify_intent"
    plan["clarify_outcome"] = "asked"
    plan["clarify_message_id"] = str(msg.id)
    job.scrape_plan = plan
    flag_modified(job, "scrape_plan")
    db.commit()

    logger.info(
        "[clarify] job=%s asked: %r options=%s",
        job.id, question_text[:80], options,
    )
    return False
