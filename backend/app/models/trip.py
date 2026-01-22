"""
Trip model for travel itineraries.

A trip represents a travel journey with places, routes, and metadata.
Users can create multiple trips and organize places within them.
"""

from sqlalchemy import Column, String, Text, Date, Integer, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class Trip(Base):
    """
    Trip model for user's travel itineraries.
    
    Attributes:
        id: UUID primary key
        user_id: Foreign key to users table (owner)
        title: Trip title (required, 1-255 chars)
        description: Optional trip description
        start_date: Optional trip start date
        end_date: Optional trip end date
        cover_photo_url: URL to cover photo
        visibility: private | unlisted | public
        views_count: Number of times trip has been viewed
        saves_count: Number of times trip has been saved by others
        created_at: Creation timestamp
        updated_at: Last update timestamp
        
    Business Rules:
        - Free users: max 3 trips
        - Premium users: unlimited trips
        - end_date must be >= start_date
        - Default visibility: private
        - Only owner can update/delete
        
    Visibility Levels:
        - private: Only owner can view
        - unlisted: Anyone with link can view
        - public: Listed in discovery, anyone can view
    """
    
    __tablename__ = "trips"
    
    # Primary key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="Trip ID"
    )
    
    # Ownership
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Owner user ID"
    )
    
    # Trip info
    title = Column(
        String(255),
        nullable=False,
        comment="Trip title"
    )
    description = Column(
        Text,
        comment="Trip description"
    )
    start_date = Column(
        Date,
        comment="Trip start date"
    )
    end_date = Column(
        Date,
        comment="Trip end date"
    )
    cover_photo_url = Column(
        Text,
        comment="Cover photo URL"
    )
    
    # Privacy
    visibility = Column(
        String(20),
        default="private",
        index=True,
        comment="Visibility: private | unlisted | public"
    )
    
    # Engagement metrics
    views_count = Column(
        Integer,
        default=0,
        comment="Number of views"
    )
    saves_count = Column(
        Integer,
        default=0,
        comment="Number of saves"
    )
    
    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Creation time"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update time"
    )
    
    # Constraints
    __table_args__ = (
        CheckConstraint(
            "visibility IN ('private', 'unlisted', 'public')",
            name="check_visibility"
        ),
        CheckConstraint(
            "end_date IS NULL OR end_date >= start_date",
            name="check_valid_dates"
        ),
    )
    
    def __repr__(self):
        return f"<Trip(id={self.id}, title={self.title}, user_id={self.user_id})>"