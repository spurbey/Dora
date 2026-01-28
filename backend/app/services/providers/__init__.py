"""
Search provider implementations.

Providers:
    - BaseSearchProvider: Abstract interface
    - LocalSearchProvider: Database search (PostGIS + full-text)
    - FoursquareSearchProvider: Foursquare Places API

All providers return results in unified schema format.
"""

from app.services.providers.base import BaseSearchProvider
from app.services.providers.local_provider import LocalSearchProvider
from app.services.providers.foursquare_provider import FoursquareSearchProvider

__all__ = ["BaseSearchProvider", "LocalSearchProvider", "FoursquareSearchProvider"]
