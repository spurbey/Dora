"""
TripAdvisory model — delivered advisory insights for a trip.

Status tracks delivery lifecycle only (pending → delivered → expired).
User engagement (liked, saved, dismissed) is tracked separately in
AdvisoryUserAction (append-only).
"""

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class TripAdvisory(Base):
    __tablename__ = "trip_advisories"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        nullable=False,
    )
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    advisory_job_id = Column(
        UUID(as_uuid=True),
        ForeignKey("advisory_jobs.id", ondelete="SET NULL"),
        nullable=True,
        comment="Job that produced this advisory",
    )

    category = Column(
        String(32),
        nullable=False,
        comment="Insight category",
    )
    source = Column(
        String(32),
        nullable=False,
        comment="reddit|tripadvisor|google_maps|combined",
    )

    place_name = Column(Text, nullable=True, comment="Specific place/area name")
    place_lat = Column(Float, nullable=True)
    place_lng = Column(Float, nullable=True)

    title = Column(Text, nullable=False)
    body = Column(Text, nullable=False)
    context_signal = Column(Text, nullable=True, comment="e.g. '3 Reddit users agreed'")
    best_for = Column(Text, nullable=True, comment="e.g. 'solo female travelers'")

    confidence_score = Column(Float, nullable=False, default=0.5)
    source_urls = Column(ARRAY(Text), nullable=True, comment="Source page URLs")
    source_count = Column(Integer, nullable=False, default=1, comment="Corroborating source count")

    dedupe_key = Column(
        String(64),
        nullable=False,
        comment="SHA-256 hash of (place_name, category, body[:100])",
    )

    status = Column(
        String(32),
        nullable=False,
        default="pending",
        comment="Delivery-only: pending|delivered|expired",
    )

    observed_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="When source data was scraped",
    )
    delivered_at = Column(DateTime(timezone=True), nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=True)
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

    __table_args__ = (
        CheckConstraint(
            "category IN ("
            "'safety_warning', 'scam_alert', 'food_tip', 'photo_spot', "
            "'transport_tip', 'accommodation', 'cultural_etiquette', "
            "'must_do', 'avoid', 'general_tip')",
            name="check_advisory_category",
        ),
        CheckConstraint(
            "source IN ('reddit', 'tripadvisor', 'google_maps', 'combined')",
            name="check_advisory_source",
        ),
        CheckConstraint(
            "status IN ('pending', 'delivered', 'expired')",
            name="check_advisory_status",
        ),
        CheckConstraint(
            "confidence_score >= 0.0 AND confidence_score <= 1.0",
            name="check_advisory_confidence_range",
        ),
        UniqueConstraint("trip_id", "dedupe_key", name="uq_advisory_trip_dedupe"),
        Index("idx_advisory_trip_status", "trip_id", "status"),
        Index("idx_advisory_user_category", "user_id", "category"),
        Index("idx_advisory_job", "advisory_job_id"),
    )

    def __repr__(self) -> str:
        return f"<TripAdvisory(id={self.id}, category={self.category}, status={self.status})>"
