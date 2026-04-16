"""
Route API endpoints for Phase A2.

Implements 10 endpoints:
- 5 route endpoints (list, create, get, update, delete)
- 4 waypoint endpoints (create, list, update, delete)
- 1 generate endpoint (Mapbox integration)
"""

import asyncio
import hashlib
import json
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.trip import Trip
from app.models.place import TripPlace
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.route_metadata import RouteMetadata
from app.schemas.route import (
    RouteCreate, RouteUpdate, RouteResponse, RouteListResponse,
    RouteGenerateRequest, RouteGenerateResponse
)
from app.schemas.waypoint import (
    WaypointCreate, WaypointUpdate, WaypointResponse, WaypointListResponse
)
from app.schemas.route_metadata import (
    RouteMetadataCreate, RouteMetadataUpdate, RouteMetadataResponse
)
from app.database import SessionLocal
from app.services.route_service import RouteService
from app.services.trip_brain_service import TripBrainService


router = APIRouter(tags=["Routes"])
logger = logging.getLogger(__name__)


def _route_geom_sig(route_geojson: dict | None) -> str | None:
    if not route_geojson:
        return None
    normalized = json.dumps(route_geojson, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()


def _refresh_route_geometry(db: Session, route_id: UUID) -> None:
    """Best-effort route_geom projection update; skip if PostGIS unavailable."""
    try:
        db.execute(
            text(
                """
                UPDATE routes
                SET route_geom = ST_GeomFromGeoJSON(route_geojson::text)::geography
                WHERE id = :route_id
                  AND route_geojson IS NOT NULL
                """
            ),
            {"route_id": str(route_id)},
        )
        db.commit()
    except Exception as exc:  # noqa: BLE001
        db.rollback()
        logger.warning(
            "[ROUTES] route_geom refresh skipped route_id=%s: %s",
            route_id,
            exc,
        )


def _best_effort_route_reseed(db: Session, trip_id: UUID) -> None:
    """Non-blocking advisory reseed hook for route changes."""
    async def _run() -> None:
        local_db = SessionLocal()
        try:
            await TripBrainService(local_db).reseed(
                trip_id, reasons=["route_changed"]
            )
        except Exception as exc:  # noqa: BLE001
            logger.warning(
                "[ROUTES] route_changed reseed hook failed trip_id=%s: %s",
                trip_id,
                exc,
            )
        finally:
            local_db.close()

    try:
        loop = asyncio.get_running_loop()
        loop.create_task(_run())
    except RuntimeError:
        # No running loop in current context. Keep hook best-effort.
        pass


# ============================================================================
# ROUTE ENDPOINTS (5)
# ============================================================================

@router.get("/trips/{trip_id}/routes", response_model=RouteListResponse)
async def list_trip_routes(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List routes for a trip."""
    # Check trip exists
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    # Check access
    is_owner = trip.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    # Get routes
    routes = db.query(Route).filter(Route.trip_id == trip_id).order_by(Route.order_in_trip).all()

    return RouteListResponse(
        routes=[RouteResponse.model_validate(r) for r in routes],
        total=len(routes)
    )


@router.post("/trips/{trip_id}/routes", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
async def create_route(
    trip_id: UUID,
    route_data: RouteCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a route for a trip."""
    # Check trip exists and user owns it
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    if trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this trip")

    # Verify places belong to trip if provided
    if route_data.start_place_id:
        start_place = db.query(TripPlace).filter(
            TripPlace.id == route_data.start_place_id,
            TripPlace.trip_id == trip_id
        ).first()
        if not start_place:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="start_place_id must belong to this trip")

    if route_data.end_place_id:
        end_place = db.query(TripPlace).filter(
            TripPlace.id == route_data.end_place_id,
            TripPlace.trip_id == trip_id
        ).first()
        if not end_place:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="end_place_id must belong to this trip")

    # Create route
    route = Route(
        trip_id=trip_id,
        user_id=current_user.id,
        **route_data.model_dump()
    )
    route.geom_sig = _route_geom_sig(route.route_geojson)
    db.add(route)
    db.commit()
    _refresh_route_geometry(db, route.id)
    _best_effort_route_reseed(db, trip_id)
    db.refresh(route)

    return RouteResponse.model_validate(route)


@router.get("/routes/{route_id}", response_model=RouteResponse)
async def get_route(
    route_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get route details."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")

    # Check access via parent trip
    trip = db.query(Trip).filter(Trip.id == route.trip_id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Parent trip not found")

    is_owner = route.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    return RouteResponse.model_validate(route)


@router.patch("/routes/{route_id}", response_model=RouteResponse)
async def update_route(
    route_id: UUID,
    route_data: RouteUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    # Validate place IDs if being updated
    update_data = route_data.model_dump(exclude_unset=True)

    # Check start_place_id if provided
    if 'start_place_id' in update_data and update_data['start_place_id'] is not None:
        start_place = db.query(TripPlace).filter(
            TripPlace.id == update_data['start_place_id'],
            TripPlace.trip_id == route.trip_id
        ).first()
        if not start_place:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="start_place_id must belong to this trip"
            )

    # Check end_place_id if provided
    if 'end_place_id' in update_data and update_data['end_place_id'] is not None:
        end_place = db.query(TripPlace).filter(
            TripPlace.id == update_data['end_place_id'],
            TripPlace.trip_id == route.trip_id
        ).first()
        if not end_place:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="end_place_id must belong to this trip"
            )

    # Update only provided fields
    old_sig = route.geom_sig
    route_geojson_changed = "route_geojson" in update_data
    for field, value in update_data.items():
        setattr(route, field, value)

    if route_geojson_changed:
        route.geom_sig = _route_geom_sig(route.route_geojson)

    db.commit()
    if route_geojson_changed:
        _refresh_route_geometry(db, route.id)
    if route_geojson_changed and route.geom_sig != old_sig:
        _best_effort_route_reseed(db, route.trip_id)
    db.refresh(route)

    return RouteResponse.model_validate(route)


@router.delete("/routes/{route_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_route(
    route_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    trip_id = route.trip_id
    db.delete(route)
    db.commit()
    _best_effort_route_reseed(db, trip_id)


# ============================================================================
# WAYPOINT ENDPOINTS (4)
# ============================================================================

@router.post("/routes/{route_id}/waypoints", response_model=WaypointResponse, status_code=status.HTTP_201_CREATED)
async def add_waypoint(
    route_id: UUID,
    waypoint_data: WaypointCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add waypoint to a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    # Create waypoint
    waypoint = Waypoint(
        route_id=route_id,
        trip_id=route.trip_id,
        user_id=current_user.id,
        **waypoint_data.model_dump()
    )
    db.add(waypoint)
    db.commit()
    db.refresh(waypoint)

    return WaypointResponse.model_validate(waypoint)


@router.get("/routes/{route_id}/waypoints", response_model=WaypointListResponse)
async def list_waypoints(
    route_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List waypoints for a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")

    # Check access via parent trip
    trip = db.query(Trip).filter(Trip.id == route.trip_id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Parent trip not found")

    is_owner = route.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    # Get waypoints
    waypoints = db.query(Waypoint).filter(
        Waypoint.route_id == route_id
    ).order_by(Waypoint.order_in_route).all()

    return WaypointListResponse(
        waypoints=[WaypointResponse.model_validate(w) for w in waypoints],
        total=len(waypoints)
    )


@router.patch("/waypoints/{waypoint_id}", response_model=WaypointResponse)
async def update_waypoint(
    waypoint_id: UUID,
    waypoint_data: WaypointUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a waypoint."""
    waypoint = db.query(Waypoint).filter(Waypoint.id == waypoint_id).first()
    if not waypoint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Waypoint not found")
    if waypoint.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this waypoint")

    # Update only provided fields
    update_data = waypoint_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(waypoint, field, value)

    db.commit()
    db.refresh(waypoint)

    return WaypointResponse.model_validate(waypoint)


@router.delete("/waypoints/{waypoint_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_waypoint(
    waypoint_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a waypoint."""
    waypoint = db.query(Waypoint).filter(Waypoint.id == waypoint_id).first()
    if not waypoint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Waypoint not found")
    if waypoint.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this waypoint")

    db.delete(waypoint)
    db.commit()


# ============================================================================
# ROUTE GENERATION ENDPOINT (1)
# ============================================================================

@router.post("/routes/generate", response_model=RouteGenerateResponse)
async def generate_route(
    request: RouteGenerateRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Auto-generate route from coordinates using Mapbox Directions API.

    Requires MAPBOX_ACCESS_TOKEN in environment.
    """
    service = RouteService()

    try:
        result = await service.generate_route(
            coordinates=request.coordinates,
            mode=request.mode
        )
        return RouteGenerateResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger = logging.getLogger(__name__)
        response = getattr(e, "response", None)
        status_code = getattr(response, "status_code", None)
        if status_code is not None:
            logger.error(
                "Mapbox API error type=%s status=%s",
                e.__class__.__name__,
                status_code,
            )
        else:
            logger.error("Mapbox API error type=%s", e.__class__.__name__)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Route generation failed. Please try again later."
        )


# ============================================================================
# ROUTE METADATA ENDPOINTS (Optional - not in 10 count but useful)
# ============================================================================

@router.post("/routes/{route_id}/metadata", response_model=RouteMetadataResponse, status_code=status.HTTP_201_CREATED)
async def create_route_metadata(
    route_id: UUID,
    metadata_data: RouteMetadataCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create metadata for a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    # Check metadata doesn't already exist
    existing = db.query(RouteMetadata).filter(RouteMetadata.route_id == route_id).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Metadata already exists. Use PATCH to update.")

    # Create metadata
    metadata = RouteMetadata(route_id=route_id, **metadata_data.model_dump())
    db.add(metadata)
    db.commit()
    db.refresh(metadata)

    return RouteMetadataResponse.model_validate(metadata)


@router.get("/routes/{route_id}/metadata", response_model=RouteMetadataResponse)
async def get_route_metadata(
    route_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get metadata for a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")

    # Check access via parent trip
    trip = db.query(Trip).filter(Trip.id == route.trip_id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Parent trip not found")

    is_owner = route.user_id == current_user.id
    is_public = trip.visibility in ["public", "unlisted"]
    if not is_owner and not is_public:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    metadata = db.query(RouteMetadata).filter(RouteMetadata.route_id == route_id).first()
    if not metadata:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Metadata not found")

    return RouteMetadataResponse.model_validate(metadata)


@router.patch("/routes/{route_id}/metadata", response_model=RouteMetadataResponse)
async def update_route_metadata(
    route_id: UUID,
    metadata_data: RouteMetadataUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update metadata for a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    metadata = db.query(RouteMetadata).filter(RouteMetadata.route_id == route_id).first()
    if not metadata:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Metadata not found")

    # Update only provided fields
    update_data = metadata_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(metadata, field, value)

    db.commit()
    db.refresh(metadata)

    return RouteMetadataResponse.model_validate(metadata)


@router.delete("/routes/{route_id}/metadata", status_code=status.HTTP_204_NO_CONTENT)
async def delete_route_metadata(
    route_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete metadata for a route."""
    route = db.query(Route).filter(Route.id == route_id).first()
    if not route:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Route not found")
    if route.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You don't own this route")

    metadata = db.query(RouteMetadata).filter(RouteMetadata.route_id == route_id).first()
    if not metadata:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Metadata not found")

    db.delete(metadata)
    db.commit()
