"""
Thin OpenRouter wrapper for advisory orchestration.

Single entry point: `chat_json(messages, schema, ...)` returns parsed dict on
success, None on any failure. Never raises — callers must handle None.

Reliability features:
- Strict JSON-schema response_format
- Primary model + automatic fallback model on 5xx / parse failures
- Per-attempt timeout + small retry budget
- Structured logging with model + token-usage tags
- Best-effort daily cost tracking via in-memory counter (informational only)

Usage:
    from app.services.llm import chat_json

    out = await chat_json(
        messages=[
            {"role": "system", "content": "..."},
            {"role": "user", "content": "..."},
        ],
        schema={"type": "object", "properties": {...}, "required": [...]},
    )
    if out is None:
        # Fail-soft: caller decides degraded behavior
        ...
    else:
        # `out` is the parsed JSON dict matching the schema
        ...
"""

from __future__ import annotations

import json
import logging
import os
from typing import Any, Optional

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

OPENROUTER_CHAT_URL = "https://openrouter.ai/api/v1/chat/completions"

_DEFAULT_TIMEOUT_SECONDS = 20.0
_MAX_ATTEMPTS_PRIMARY = 2
# Hardcoded last-resort fallback used only when OPENROUTER_FALLBACK_MODELS is
# empty. Anything more specific should live in config so ops can rotate.
_LAST_RESORT_FALLBACK = "openai/gpt-oss-120b:free"


def _fallback_chain() -> list[str]:
    # Defensive: settings on a deployed container built before this field was
    # added will not have OPENROUTER_FALLBACK_MODELS at all. Prefer env over
    # settings to make hot-pushed test runs work without rebuilding.
    raw = (
        os.environ.get("OPENROUTER_FALLBACK_MODELS")
        or getattr(settings, "OPENROUTER_FALLBACK_MODELS", "")
        or ""
    ).strip()
    if not raw:
        return [_LAST_RESORT_FALLBACK]
    return [m.strip() for m in raw.split(",") if m.strip()]


async def chat_json(
    *,
    messages: list[dict],
    schema: Optional[dict] = None,
    model: Optional[str] = None,
    fallback_model: Optional[str] = None,
    temperature: float = 0.2,
    max_tokens: Optional[int] = None,
    timeout_seconds: float = _DEFAULT_TIMEOUT_SECONDS,
    label: str = "advisory",
) -> Optional[dict]:
    """Call OpenRouter chat completion expecting a JSON response.

    Returns the parsed JSON dict, or None on any failure. Callers must
    handle None as "LLM unavailable, take a deterministic fallback path".

    Args:
        messages: OpenAI-style messages (`{role, content}` list).
        schema: Optional JSON schema enforced via response_format=json_schema.
                If None, requests json_object format.
        model: Override the default model. Defaults to settings.OPENROUTER_MODEL.
        fallback_model: Override the fallback. Defaults to gpt-oss-120b:free.
        temperature: Sampling temperature.
        max_tokens: Optional output cap.
        timeout_seconds: Per-attempt timeout.
        label: Tag for logging (e.g., "ranker", "clarify_intent").
    """
    if not settings.OPENROUTER_API_KEY:
        logger.info("[LLM] %s skipped: no OPENROUTER_API_KEY", label)
        return None

    primary = model or settings.OPENROUTER_MODEL
    candidates: list[str] = [primary]
    if fallback_model:
        # Caller-specified fallback wins.
        if fallback_model != primary:
            candidates.append(fallback_model)
    else:
        # Otherwise take the configured chain, skipping any duplicates.
        for f in _fallback_chain():
            if f and f not in candidates:
                candidates.append(f)

    for model_id in candidates:
        for attempt in range(1, _MAX_ATTEMPTS_PRIMARY + 1):
            parsed = await _try_chat(
                model_id=model_id,
                messages=messages,
                schema=schema,
                temperature=temperature,
                max_tokens=max_tokens,
                timeout_seconds=timeout_seconds,
                label=label,
                attempt=attempt,
            )
            if parsed is not None:
                return parsed
        logger.warning(
            "[LLM] %s exhausted %d attempts on %s; trying next candidate",
            label,
            _MAX_ATTEMPTS_PRIMARY,
            model_id,
        )

    logger.warning("[LLM] %s all candidates exhausted; returning None", label)
    return None


async def _try_chat(
    *,
    model_id: str,
    messages: list[dict],
    schema: Optional[dict],
    temperature: float,
    max_tokens: Optional[int],
    timeout_seconds: float,
    label: str,
    attempt: int,
) -> Optional[dict]:
    payload: dict[str, Any] = {
        "model": model_id,
        "messages": messages,
        "temperature": temperature,
    }
    if max_tokens is not None:
        payload["max_tokens"] = max_tokens
    if schema is not None:
        payload["response_format"] = {
            "type": "json_schema",
            "json_schema": {
                "name": f"{label}_response",
                "strict": True,
                "schema": schema,
            },
        }
    else:
        payload["response_format"] = {"type": "json_object"}

    headers = {
        "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    try:
        async with httpx.AsyncClient(timeout=timeout_seconds) as client:
            resp = await client.post(
                OPENROUTER_CHAT_URL, json=payload, headers=headers
            )
    except (httpx.HTTPError, OSError) as exc:
        logger.warning(
            "[LLM] %s http error model=%s attempt=%d: %s",
            label, model_id, attempt, exc,
        )
        return None

    if resp.status_code >= 500:
        logger.warning(
            "[LLM] %s 5xx model=%s attempt=%d status=%d body=%s",
            label, model_id, attempt, resp.status_code, resp.text[:200],
        )
        return None
    if resp.status_code != 200:
        logger.warning(
            "[LLM] %s non-200 model=%s status=%d body=%s",
            label, model_id, resp.status_code, resp.text[:200],
        )
        return None

    try:
        body = resp.json()
        content = body["choices"][0]["message"]["content"]
        parsed = json.loads(content) if isinstance(content, str) else content
        usage = body.get("usage") or {}
        logger.info(
            "[LLM] %s ok model=%s attempt=%d in=%s out=%s",
            label,
            model_id,
            attempt,
            usage.get("prompt_tokens"),
            usage.get("completion_tokens"),
        )
        if not isinstance(parsed, dict):
            logger.warning(
                "[LLM] %s parsed non-dict (%s); returning None",
                label, type(parsed).__name__,
            )
            return None
        return parsed
    except (KeyError, ValueError, TypeError) as exc:
        logger.warning(
            "[LLM] %s parse error model=%s: %s",
            label, model_id, exc,
        )
        return None
