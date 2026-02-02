"""
PlaceMetadata model for semantic place information.

Stores optional metadata for places to enable filtering and recommendations.
Uses PostgreSQL ARRAY types with GIN indexes for efficient tag queries.
"""

from sqlalchemy import Column, Text, Boolean, Float, Integer, Numeric, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class PlaceMetadata(Base):
    """
    Semantic metadata for places/components.

    Attributes:
        place_id: UUID foreign key to trip_places.id (primary key)
        component_type: Type of component (city, place, activity, accommodation, food, transport)
        experience_tags: Array of experience descriptors (romantic, adventurous, peaceful, crowded, instagram-worthy)
        best_for: Array of audience types (solo-travelers, couples, families, photographers, foodies)
        budget_per_person: Estimated cost per person in USD
        duration_hours: Recommended time to spend in hours
        difficulty_rating: Physical difficulty rating (1-5)
        physical_demand: Physical demand level (low, medium, high)
        best_time: Optimal time to visit (sunrise, morning, afternoon, sunset, night, anytime)
        is_public: Whether place can be discovered publicly
        contribution_score: Quality score for this component (0-1)
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Business Rules:
        - Optional 1:1 relationship with TripPlace (metadata can exist without place creating it)
        - Cascade delete: removing place removes metadata
        - All array fields use PostgreSQL ARRAY type with GIN indexes
        - Enum fields validated by CHECK constraints
        - contribution_score calculated by system (future: Phase E1)

    Indexes:
        - GIN indexes on array fields (experience_tags, best_for)
        - Partial index on is_public WHERE true
        - Index on component_type for filtering
    """

    __tablename__ = "place_metadata"

    # Primary key (also FK to trip_places)
    place_id = Column(
        UUID(as_uuid=True),
        ForeignKey("trip_places.id", ondelete="CASCADE"),
        primary_key=True,
        comment="Place ID (FK to trip_places.id)"
    )

    # Component categorization
    component_type = Column(
        Text,
        default="place",
        server_default="place",
        comment="city, place, activity, accommodation, food, transport"
    )

    # Experience descriptors
    experience_tags = Column(
        ARRAY(Text),
        comment="romantic, adventurous, peaceful, crowded, instagram-worthy"
    )
    best_for = Column(
        ARRAY(Text),
        comment="solo-travelers, couples, families, photographers, foodies"
    )

    # Practical information
    budget_per_person = Column(
        Numeric(10, 2),
        comment="Estimated cost per person (USD)"
    )
    duration_hours = Column(
        Float,
        comment="Recommended time to spend (hours)"
    )

    # Difficulty & demand
    difficulty_rating = Column(
        Integer,
        comment="Physical difficulty 1-5"
    )
    physical_demand = Column(
        Text,
        comment="low, medium, high"
    )

    # Timing
    best_time = Column(
        Text,
        comment="sunrise, morning, afternoon, sunset, night, anytime"
    )

    # Discovery settings
    is_public = Column(
        Boolean,
        nullable=False,
        default=False,
        server_default='false',
        comment="Can this place be discovered publicly?"
    )
    contribution_score = Column(
        Float,
        nullable=False,
        default=0.0,
        server_default='0.0',
        comment="Quality score for this component (0-1)"
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

    # Relationship to TripPlace (optional, for convenience)
    # Uncomment if needed: place = relationship("TripPlace", back_populates="metadata")

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "component_type IN ('city', 'place', 'activity', 'accommodation', 'food', 'transport') OR component_type IS NULL",
            name="check_component_type"
        ),
        CheckConstraint(
            "physical_demand IN ('low', 'medium', 'high') OR physical_demand IS NULL",
            name="check_physical_demand"
        ),
        CheckConstraint(
            "best_time IN ('sunrise', 'morning', 'afternoon', 'sunset', 'night', 'anytime') OR best_time IS NULL",
            name="check_best_time"
        ),
        CheckConstraint(
            "difficulty_rating >= 1 AND difficulty_rating <= 5 OR difficulty_rating IS NULL",
            name="check_difficulty_rating_range"
        ),
        CheckConstraint(
            "contribution_score >= 0.0 AND contribution_score <= 1.0",
            name="check_contribution_score_range"
        ),
        CheckConstraint(
            "duration_hours > 0 OR duration_hours IS NULL",
            name="check_duration_hours_positive"
        ),
        CheckConstraint(
            "budget_per_person >= 0 OR budget_per_person IS NULL",
            name="check_budget_per_person_positive"
        ),
    )

    def __repr__(self):
        return f"<PlaceMetadata(place_id={self.place_id}, component_type={self.component_type})>"
