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
    - TripMetadata: Semantic metadata for trips (V2)
    - PlaceMetadata: Semantic metadata for places (V2)
    - Route: Routes/paths between places (V2 Phase A2)
    - Waypoint: Waypoints along routes (V2 Phase A2)
    - RouteMetadata: Semantic metadata for routes (V2 Phase A2)

All models inherit from Base (declarative_base).
Import all models here for Alembic autogenerate to work.
"""

from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.media import MediaFile
from app.models.search_signals import SearchEvent, PlaceView, PlaceSave
from app.models.trip_metadata import TripMetadata
from app.models.place_metadata import PlaceMetadata
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.route_metadata import RouteMetadata
from app.models.export_job import ExportJob
from app.models.export_share_token import ExportShareToken
from app.models.api_idempotency_record import ApiIdempotencyRecord
from app.models.user_device_token import UserDeviceToken
from app.models.trip_tracking_event import TripTrackingEvent
from app.models.trip_tracking_event_media import TripTrackingEventMedia
from app.models.trip_location_point import TripLocationPoint
from app.models.trip_compiled_projection_state import TripCompiledProjectionState
from app.models.trip_compiled_projection_item import TripCompiledProjectionItem
from app.models.trip_compiled_route_segment import TripCompiledRouteSegment
from app.models.trip_compiled_projection_override import TripCompiledProjectionOverride
from app.models.trip_session_raw import TripSessionRaw
from app.models.trip_event_raw import TripEventRaw
from app.models.trip_media_raw import TripMediaRaw
from app.models.trip_route_raw_point import TripRouteRawPoint
from app.models.trip_commit_manifest import TripCommitManifest
from app.models.trip_timeline_projection_v2 import TripTimelineProjectionV2
from app.models.trip_route_projection_v2 import TripRouteProjectionV2
from app.models.advisory_job import AdvisoryJob
from app.models.trip_advisory import TripAdvisory
from app.models.advisory_user_action import AdvisoryUserAction
from app.models.trip_advisory_state import TripAdvisoryState
from app.models.user_metadata import UserMetadata

__all__ = [
    "User",
    "Trip",
    "TripPlace",
    "MediaFile",
    "SearchEvent",
    "PlaceView",
    "PlaceSave",
    "TripMetadata",
    "PlaceMetadata",
    "Route",
    "Waypoint",
    "RouteMetadata",
    "ExportJob",
    "ExportShareToken",
    "ApiIdempotencyRecord",
    "UserDeviceToken",
    "TripTrackingEvent",
    "TripTrackingEventMedia",
    "TripLocationPoint",
    "TripCompiledProjectionState",
    "TripCompiledProjectionItem",
    "TripCompiledRouteSegment",
    "TripCompiledProjectionOverride",
    "TripSessionRaw",
    "TripEventRaw",
    "TripMediaRaw",
    "TripRouteRawPoint",
    "TripCommitManifest",
    "TripTimelineProjectionV2",
    "TripRouteProjectionV2",
    "AdvisoryJob",
    "TripAdvisory",
    "AdvisoryUserAction",
    "TripAdvisoryState",
    "UserMetadata",
]
