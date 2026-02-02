"""
TripMetadata model for semantic trip information.

Stores optional metadata for trips to enable intelligent search and discovery.
Uses PostgreSQL ARRAY types with GIN indexes for efficient tag queries.
"""

from sqlalchemy import Column, Text, Boolean, Float, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class TripMetadata(Base):
    """
    Semantic metadata for trips.

    Attributes:
        trip_id: UUID foreign key to trips.id (primary key)
        traveler_type: Array of traveler types (solo, couple, family, group)
        age_group: Target age group (gen-z, millennial, gen-x, boomer)
        travel_style: Array of travel styles (adventure, luxury, budget, cultural, relaxed)
        difficulty_level: Overall difficulty (easy, moderate, challenging, extreme)
        budget_category: Budget level (budget, mid-range, luxury)
        activity_focus: Array of activity types (hiking, food, photography, nightlife, beaches)
        is_discoverable: Whether trip can be found in public search
        quality_score: System-calculated quality score (0-1, used for ranking)
        tags: User-defined tags for categorization
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Business Rules:
        - Optional 1:1 relationship with Trip (metadata can exist without trip creating it)
        - Cascade delete: removing trip removes metadata
        - All array fields use PostgreSQL ARRAY type with GIN indexes
        - Enum fields validated by CHECK constraints
        - quality_score calculated by system (future: Phase E1)

    Indexes:
        - GIN indexes on array fields (tags, traveler_type, activity_focus)
        - Partial index on is_discoverable WHERE true
    """

    __tablename__ = "trip_metadata"

    # Primary key (also FK to trips)
    trip_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trips.id", ondelete="CASCADE"),
        primary_key=True,
        comment="Trip ID (FK to trips.id)"
    )

    # Traveler profile
    traveler_type = Column(
        ARRAY(Text),
        comment="solo, couple, family, group"
    )
    age_group = Column(
        Text,
        comment="gen-z, millennial, gen-x, boomer"
    )

    # Trip characteristics
    travel_style = Column(
        ARRAY(Text),
        comment="adventure, luxury, budget, cultural, relaxed"
    )
    difficulty_level = Column(
        Text,
        comment="easy, moderate, challenging, extreme"
    )
    budget_category = Column(
        Text,
        comment="budget, mid-range, luxury"
    )
    activity_focus = Column(
        ARRAY(Text),
        comment="hiking, food, photography, nightlife, beaches"
    )

    # Discovery settings
    is_discoverable = Column(
        Boolean,
        nullable=False,
        default=False,
        server_default='false',
        comment="Can this trip be found in public search?"
    )
    quality_score = Column(
        Float,
        nullable=False,
        default=0.0,
        server_default='0.0',
        comment="System-calculated quality (0-1)"
    )

    # User-defined tags
    tags = Column(
        ARRAY(Text),
        comment="User-defined tags"
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        comment="Creation timestamp"
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update timestamp"
    )

    # Relationship to Trip (optional, for convenience)
    # Uncomment if needed: trip = relationship("Trip", back_populates="metadata")

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "age_group IN ('gen-z', 'millennial', 'gen-x', 'boomer') OR age_group IS NULL",
            name="check_age_group"
        ),
        CheckConstraint(
            "difficulty_level IN ('easy', 'moderate', 'challenging', 'extreme') OR difficulty_level IS NULL",
            name="check_difficulty_level"
        ),
        CheckConstraint(
            "budget_category IN ('budget', 'mid-range', 'luxury') OR budget_category IS NULL",
            name="check_budget_category"
        ),
        CheckConstraint(
            "quality_score >= 0.0 AND quality_score <= 1.0",
            name="check_quality_score_range"
        ),
    )

    def __repr__(self):
        return f"<TripMetadata(trip_id={self.trip_id}, is_discoverable={self.is_discoverable})>"
