"""
UserMetadata model — per-user preferences for advisory personalization.

1:1 optional with users. Populated on first advisory interaction or explicit
settings write. Absent row ⇒ defaults are used by the advisory pipeline.
"""

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    String,
    Boolean,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID, TEXT
from sqlalchemy.sql import func, text

from app.database import Base


class UserMetadata(Base):
    """
    Per-user preferences for the advisory pipeline.

    Fields:
        user_id: PK / FK → users (1:1)
        dietary_restrictions: TEXT[] e.g. ['vegetarian','halal','gluten_free']
        budget_range: shoestring|budget|mid|premium|luxury
        preferred_travel_style: TEXT[] mirrors trip_metadata.travel_style values
        dislikes: TEXT[] free tags, e.g. ['crowded_places','seafood']
        notification_enabled: master push switch
        advisory_quiet_hours: JSONB e.g. {start:'22:00', end:'07:00',
            timezone_source:'trip'}
    """

    __tablename__ = "user_metadata"

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
        comment="Owner user ID",
    )

    dietary_restrictions = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="Dietary restrictions (e.g. vegetarian, halal, gluten_free)",
    )
    budget_range = Column(
        String(20),
        nullable=True,
        comment="shoestring|budget|mid|premium|luxury",
    )
    preferred_travel_style = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="Travel style tags mirroring trip_metadata.travel_style",
    )
    dislikes = Column(
        ARRAY(TEXT()),
        nullable=False,
        server_default=text("'{}'::text[]"),
        comment="Free-form dislike tags for advisory filtering",
    )
    notification_enabled = Column(
        Boolean,
        nullable=False,
        server_default=text("true"),
        comment="Master push notification switch",
    )
    advisory_quiet_hours = Column(
        JSONB,
        nullable=True,
        comment="Quiet hours for advisory pushes, e.g. "
        "{start:'22:00', end:'07:00', timezone_source:'trip'}",
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

    __table_args__ = (
        CheckConstraint(
            "budget_range IS NULL OR budget_range IN "
            "('shoestring', 'budget', 'mid', 'premium', 'luxury')",
            name="check_user_metadata_budget_range",
        ),
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<UserMetadata(user_id={self.user_id})>"
