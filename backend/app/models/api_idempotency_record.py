"""
Idempotency record model for write endpoints.

Stores request hash + response metadata for deterministic replay handling.
"""

import uuid

from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func

from app.database import Base


class ApiIdempotencyRecord(Base):
    """Idempotency key ledger for mutating API requests."""

    __tablename__ = "api_idempotency_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, comment="Idempotency row ID")
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    endpoint_signature = Column(
        String(160),
        nullable=False,
        comment="Normalized endpoint + method signature",
    )
    idempotency_key = Column(String(96), nullable=False, comment="Client idempotency key")
    request_hash = Column(String(128), nullable=False, comment="Hash of normalized request payload")
    response_status = Column(Integer, nullable=False, comment="Original HTTP response status")
    response_body = Column(JSONB, nullable=True, comment="Original response payload for replay")
    replay_count = Column(Integer, nullable=False, default=0, comment="Replay hit counter")
    first_seen_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    last_replayed_at = Column(DateTime(timezone=True), nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=False, comment="TTL cutoff for idempotency record")
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "endpoint_signature",
            "idempotency_key",
            name="uq_idempotency_user_endpoint_key",
        ),
    )
