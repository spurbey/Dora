"""
RouteMetadata model for route quality and safety information.

Stores route metadata including quality ratings, costs, and highlights.
Follows Phase A2 PRD specification.
"""

from sqlalchemy import Column, Text, Boolean, Integer, Numeric, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func

from app.database import Base


class RouteMetadata(Base):
    """
    Metadata for routes.

    Attributes:
        route_id: UUID primary key, foreign key to routes table
        route_quality: Quality type (scenic, fastest, offbeat)
        road_condition: Condition (excellent, good, poor, offroad)
        scenic_rating: Scenic rating 1-5 (optional)
        safety_rating: Safety rating 1-5 (default 3, required)
        solo_safe: Safe for solo travelers (default TRUE)
        fuel_cost: Estimated fuel cost (optional)
        toll_cost: Toll charges (optional)
        highlights: Array of highlights (waterfall, viewpoint, etc.)
        is_public: Whether route can be discovered publicly (default FALSE)
        created_at: Creation timestamp
        updated_at: Last update timestamp

    Business Rules:
        - route_quality must be: scenic, fastest, or offbeat
        - road_condition must be: excellent, good, poor, or offroad
        - scenic_rating must be between 1 and 5
        - safety_rating must be between 1 and 5 (default 3)
        - solo_safe defaults to TRUE
        - is_public defaults to FALSE
        - highlights uses GIN index for array search
    """

    __tablename__ = "route_metadata"

    # Primary key (also FK to routes)
    route_id = Column(
        UUID(as_uuid=True),
        ForeignKey("routes.id", ondelete="CASCADE"),
        primary_key=True,
        comment="PK, FK to routes"
    )

    # Quality fields
    route_quality = Column(
        Text,
        nullable=True,
        comment="scenic, fastest, offbeat"
    )
    road_condition = Column(
        Text,
        nullable=True,
        comment="excellent, good, poor, offroad"
    )
    scenic_rating = Column(
        Integer,
        nullable=True,
        comment="1-5"
    )

    # Safety fields
    safety_rating = Column(
        Integer,
        nullable=False,
        server_default='3',
        comment="1-5, default 3"
    )
    solo_safe = Column(
        Boolean,
        nullable=False,
        server_default='true',
        comment="Default TRUE"
    )

    # Cost fields
    fuel_cost = Column(
        Numeric(10, 2),
        nullable=True,
        comment="Estimated cost"
    )
    toll_cost = Column(
        Numeric(10, 2),
        nullable=True,
        comment="Toll charges"
    )

    # Highlights and visibility
    highlights = Column(
        ARRAY(Text),
        nullable=True,
        comment="['waterfall', 'viewpoint']"
    )
    is_public = Column(
        Boolean,
        nullable=False,
        server_default='false',
        comment="Default FALSE"
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

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "route_quality IN ('scenic', 'fastest', 'offbeat') OR route_quality IS NULL",
            name="check_route_quality"
        ),
        CheckConstraint(
            "road_condition IN ('excellent', 'good', 'poor', 'offroad') OR road_condition IS NULL",
            name="check_road_condition"
        ),
        CheckConstraint(
            "scenic_rating >= 1 AND scenic_rating <= 5 OR scenic_rating IS NULL",
            name="check_scenic_rating_range"
        ),
        CheckConstraint(
            "safety_rating >= 1 AND safety_rating <= 5",
            name="check_safety_rating_range"
        ),
        CheckConstraint(
            "fuel_cost >= 0 OR fuel_cost IS NULL",
            name="check_fuel_cost_positive"
        ),
        CheckConstraint(
            "toll_cost >= 0 OR toll_cost IS NULL",
            name="check_toll_cost_positive"
        ),
    )

    def __repr__(self):
        return f"<RouteMetadata(route_id={self.route_id}, quality={self.route_quality})>"
