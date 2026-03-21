"""
Persistent share-token records for export artifact sharing.
"""

from sqlalchemy import Column, DateTime, ForeignKey, Index, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class ExportShareToken(Base):
    __tablename__ = "export_share_tokens"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Share token row ID",
    )
    token = Column(
        String(96),
        nullable=False,
        comment="Opaque share token",
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Owner user ID",
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
        comment="Trip ID for privacy enforcement",
    )
    job_id = Column(
        UUID(as_uuid=True),
        ForeignKey("export_jobs.id", ondelete="CASCADE"),
        nullable=False,
        comment="Export job ID",
    )
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
    expires_at = Column(
        DateTime(timezone=True),
        nullable=False,
        comment="Share token expiry timestamp",
    )
    revoked_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Revocation timestamp",
    )

    __table_args__ = (
        UniqueConstraint("token", name="uq_export_share_tokens_token"),
        Index("idx_export_share_tokens_job_active", "job_id", "revoked_at", "expires_at"),
        Index("idx_export_share_tokens_trip", "trip_id"),
        Index("idx_export_share_tokens_user", "user_id"),
    )

    def __repr__(self) -> str:
        return f"<ExportShareToken(id={self.id}, job_id={self.job_id}, revoked_at={self.revoked_at})>"
