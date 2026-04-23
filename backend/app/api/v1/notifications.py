"""
Notification device token lifecycle endpoints.
"""

import hashlib
import json
from datetime import datetime, timedelta, timezone
from typing import Any, Callable

from fastapi import APIRouter, Depends, Header, HTTPException, Response, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.api_idempotency_record import ApiIdempotencyRecord
from app.models.user import User
from app.models.user_device_token import UserDeviceToken
from app.schemas.notification_token import (
    DeviceTokenDeactivateRequest,
    DeviceTokenMutationResponse,
    DeviceTokenPayload,
    DeviceTokenRegisterRequest,
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])
IDEMPOTENCY_TTL_HOURS = 72


def _require_idempotency_key(
    idempotency_key: str | None,
    legacy_idempotency_key: str | None,
) -> str:
    value = idempotency_key or legacy_idempotency_key
    if value is None or not value.strip():
        raise HTTPException(
            status_code=400,
            detail={
                "error_code": "invalid_payload",
                "message": "Idempotency-Key header is required.",
            },
        )
    return value.strip()


def _to_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _request_hash(payload: dict[str, Any]) -> str:
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def _extract_constraint_name(error: IntegrityError) -> str | None:
    original = getattr(error, "orig", None)
    message = str(original or error)
    if "uq_idempotency_user_endpoint_key" in message:
        return "uq_idempotency_user_endpoint_key"
    return None


def _idempotency_conflict() -> None:
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail={
            "error_code": "idempotency_conflict",
            "message": "Idempotency-Key was reused with a different payload.",
        },
    )


def _run_idempotent_mutation(
    *,
    db: Session,
    user_id,
    endpoint_signature: str,
    idempotency_key: str,
    request_payload: dict[str, Any],
    operation: Callable[[], tuple[int, dict[str, Any]]],
) -> tuple[int, dict[str, Any], bool]:
    now = _utcnow()
    payload = jsonable_encoder(request_payload)
    request_hash = _request_hash(payload)

    record = (
        db.query(ApiIdempotencyRecord)
        .filter(
            ApiIdempotencyRecord.user_id == user_id,
            ApiIdempotencyRecord.endpoint_signature == endpoint_signature,
            ApiIdempotencyRecord.idempotency_key == idempotency_key,
        )
        .first()
    )
    if record is not None:
        if record.expires_at <= now:
            db.delete(record)
            db.flush()
        else:
            if record.request_hash != request_hash:
                _idempotency_conflict()
            record.replay_count = int(record.replay_count or 0) + 1
            record.last_replayed_at = now
            db.commit()
            return record.response_status, record.response_body or {}, True

    try:
        status_code, body = operation()
        encoded = jsonable_encoder(body)
        db.add(
            ApiIdempotencyRecord(
                user_id=user_id,
                endpoint_signature=endpoint_signature,
                idempotency_key=idempotency_key,
                request_hash=request_hash,
                response_status=status_code,
                response_body=encoded,
                replay_count=0,
                first_seen_at=now,
                expires_at=now + timedelta(hours=IDEMPOTENCY_TTL_HOURS),
            )
        )
        db.commit()
        return status_code, encoded, False
    except HTTPException:
        db.rollback()
        raise
    except IntegrityError as exc:
        constraint_name = _extract_constraint_name(exc)
        db.rollback()
        if constraint_name == "uq_idempotency_user_endpoint_key":
            replay = (
                db.query(ApiIdempotencyRecord)
                .filter(
                    ApiIdempotencyRecord.user_id == user_id,
                    ApiIdempotencyRecord.endpoint_signature == endpoint_signature,
                    ApiIdempotencyRecord.idempotency_key == idempotency_key,
                )
                .first()
            )
            if replay is None:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail={
                        "error_code": "idempotency_retry_pending",
                        "message": "Idempotent request is still being resolved.",
                    },
                )
            if replay.request_hash != request_hash:
                _idempotency_conflict()
            replay.replay_count = int(replay.replay_count or 0) + 1
            replay.last_replayed_at = now
            db.commit()
            return replay.response_status, replay.response_body or {}, True
        raise


def _serialize_token(token_row: UserDeviceToken) -> DeviceTokenPayload:
    return DeviceTokenPayload(
        id=token_row.id,
        user_id=token_row.user_id,
        platform=token_row.platform,
        is_active=bool(token_row.is_active),
        failure_count=int(token_row.failure_count or 0),
        last_seen_at=token_row.last_seen_at,
        created_at=token_row.created_at,
        updated_at=token_row.updated_at,
    )


@router.post(
    "/device-tokens/register",
    response_model=DeviceTokenMutationResponse,
)
async def register_device_token(
    request: DeviceTokenRegisterRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    legacy_idempotency_key: str | None = Header(default=None, alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    idempotency_value = _require_idempotency_key(idempotency_key, legacy_idempotency_key)
    now = datetime.now(timezone.utc)
    seen_at = _to_utc(request.seen_at or now)
    request_payload = request.model_dump(mode="json")

    def _operation() -> tuple[int, dict[str, Any]]:
        token_row = (
            db.query(UserDeviceToken)
            .filter(UserDeviceToken.push_token == request.push_token)
            .one_or_none()
        )
        if token_row is None:
            token_row = UserDeviceToken(
                user_id=current_user.id,
                platform=request.platform,
                push_token=request.push_token,
                device_id=request.device_id,
                app_version=request.app_version,
                locale=request.locale,
                is_active=True,
                last_seen_at=seen_at,
                failure_count=0,
            )
            db.add(token_row)
        else:
            token_row.user_id = current_user.id
            token_row.platform = request.platform
            token_row.device_id = request.device_id
            token_row.app_version = request.app_version
            token_row.locale = request.locale
            token_row.is_active = True
            token_row.last_seen_at = seen_at
            token_row.failure_count = 0

        try:
            db.flush()
        except IntegrityError:
            # Concurrent writes to the same push token should converge to one row.
            db.rollback()
            winner = (
                db.query(UserDeviceToken)
                .filter(UserDeviceToken.push_token == request.push_token)
                .one_or_none()
            )
            if winner is None:
                raise
            winner.user_id = current_user.id
            winner.platform = request.platform
            winner.device_id = request.device_id
            winner.app_version = request.app_version
            winner.locale = request.locale
            winner.is_active = True
            winner.last_seen_at = seen_at
            winner.failure_count = 0
            db.flush()
            token_row = winner

        db.refresh(token_row)
        body = DeviceTokenMutationResponse(
            token=_serialize_token(token_row),
            idempotency_replayed=False,
        ).model_dump(mode="json")
        return status.HTTP_200_OK, body

    status_code, body, replayed = _run_idempotent_mutation(
        db=db,
        user_id=current_user.id,
        endpoint_signature="POST:/api/v1/notifications/device-tokens/register",
        idempotency_key=idempotency_value,
        request_payload=request_payload,
        operation=_operation,
    )
    body["idempotency_replayed"] = replayed
    response.status_code = status_code
    return body


@router.post(
    "/device-tokens/deactivate",
    response_model=DeviceTokenMutationResponse,
)
async def deactivate_device_token(
    request: DeviceTokenDeactivateRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    legacy_idempotency_key: str | None = Header(default=None, alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    idempotency_value = _require_idempotency_key(idempotency_key, legacy_idempotency_key)
    deactivated_at = _to_utc(request.deactivated_at or datetime.now(timezone.utc))
    request_payload = request.model_dump(mode="json")

    def _operation() -> tuple[int, dict[str, Any]]:
        token_row = (
            db.query(UserDeviceToken)
            .filter(
                UserDeviceToken.user_id == current_user.id,
                UserDeviceToken.push_token == request.push_token,
            )
            .one_or_none()
        )

        if token_row is None:
            body = DeviceTokenMutationResponse(
                token=None,
                idempotency_replayed=False,
            ).model_dump(mode="json")
            return status.HTTP_200_OK, body

        token_row.is_active = False
        token_row.last_seen_at = deactivated_at
        db.flush()
        db.refresh(token_row)
        body = DeviceTokenMutationResponse(
            token=_serialize_token(token_row),
            idempotency_replayed=False,
        ).model_dump(mode="json")
        return status.HTTP_200_OK, body

    status_code, body, replayed = _run_idempotent_mutation(
        db=db,
        user_id=current_user.id,
        endpoint_signature="POST:/api/v1/notifications/device-tokens/deactivate",
        idempotency_key=idempotency_value,
        request_payload=request_payload,
        operation=_operation,
    )
    body["idempotency_replayed"] = replayed
    response.status_code = status_code
    return body
