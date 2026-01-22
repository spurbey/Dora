"""
User model for authentication and profile management.

This model stores user accounts with authentication info and premium status.
Users are created via Supabase Auth, then synced to this table.
"""

from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.database import Base


class User(Base):
    """
    User account model.
    
    Attributes:
        id: UUID primary key (matches Supabase Auth user ID)
        email: Unique email address
        username: Unique username (3-50 chars)
        hashed_password: Bcrypt hashed password
        full_name: Optional full name
        avatar_url: URL to profile picture
        bio: User bio/description
        is_premium: Premium subscription status
        is_verified: Email verification status
        subscription_ends_at: When premium subscription expires
        created_at: Account creation timestamp
        updated_at: Last update timestamp
        last_login: Last login timestamp
        
    Business Rules:
        - Email must be unique
        - Username must be unique
        - Free users: limited to 3 trips
        - Premium users: unlimited trips
    """
    
    __tablename__ = "users"
    
    # Primary key (matches Supabase Auth UUID)
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        comment="User ID (matches Supabase Auth)"
    )
    
    # Authentication
    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
        comment="User email address"
    )
    username = Column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
        comment="Unique username"
    )
    hashed_password = Column(
        String(255),
        nullable=False,
        comment="Bcrypt hashed password"
    )
    
    # Profile
    full_name = Column(String(255), comment="Full name")
    avatar_url = Column(String, comment="Profile picture URL")
    bio = Column(String, comment="User bio")
    
    # Premium status
    is_premium = Column(
        Boolean,
        default=False,
        comment="Premium subscription status"
    )
    is_verified = Column(
        Boolean,
        default=False,
        comment="Email verification status"
    )
    subscription_ends_at = Column(
        DateTime(timezone=True),
        comment="Premium subscription end date"
    )
    
    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Account creation time"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        comment="Last update time"
    )
    last_login = Column(
        DateTime(timezone=True),
        comment="Last login time"
    )
    
    def __repr__(self):
        return f"<User(id={self.id}, username={self.username}, email={self.email})>"