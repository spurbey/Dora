"""
SQLAlchemy models for Travel Memory Vault.

Models:
    - User: User accounts and authentication
    - Trip: Travel itineraries
    - TripPlace: Places within trips (with PostGIS)
    - MediaFile: Photo/video metadata
    
All models inherit from Base (declarative_base).
Import all models here for Alembic autogenerate to work.
"""

from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.media import MediaFile

__all__ = ["User", "Trip", "TripPlace", "MediaFile"]