"""
SQLAlchemy models for Travel Memory Vault.

Models:
    - User: User accounts and authentication
    - Trip: Travel itineraries
    - TripPlace: Places within trips (with PostGIS)
    - MediaFile: Photo/video metadata
    - SearchEvent: Search query logs
    - PlaceView: Place view logs
    - PlaceSave: Place save logs

All models inherit from Base (declarative_base).
Import all models here for Alembic autogenerate to work.
"""

from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.media import MediaFile
from app.models.search_signals import SearchEvent, PlaceView, PlaceSave

__all__ = ["User", "Trip", "TripPlace", "MediaFile", "SearchEvent", "PlaceView", "PlaceSave"]