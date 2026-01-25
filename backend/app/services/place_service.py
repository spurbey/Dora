"""
Place service layer for business logic.

Handles:
    - Place CRUD operations
    - PostGIS Geography conversion from lat/lng
    - Geospatial queries (nearby places, distance calculations)
    - Order management in trip itinerary
"""

from sqlalchemy.orm import Session
from sqlalchemy import func, cast, desc
from geoalchemy2 import Geography
from fastapi import HTTPException, status
from typing import Optional, List
from uuid import UUID

from app.models.place import TripPlace
from app.models.trip import Trip
from app.schemas.place import PlaceCreate, PlaceUpdate, PlaceListResponse, PlaceResponse


class PlaceService:
    """
    Service layer for place operations.

    Attributes:
        db: Database session

    Methods:
        get_place_by_id: Get place by UUID
        list_trip_places: List all places for a trip (ordered)
        create_place: Create new place with Geography conversion
        update_place: Update existing place (with ownership check)
        delete_place: Delete place (with ownership check)
        get_places_near_location: Geospatial query for nearby places
        _check_trip_ownership: Internal ownership validation
        _get_next_order_in_trip: Get next order position for trip
    """

    def __init__(self, db: Session):
        """
        Initialize place service.

        Args:
            db: SQLAlchemy database session
        """
        self.db = db

    def get_place_by_id(self, place_id: UUID) -> Optional[TripPlace]:
        """
        Get place by ID.

        Args:
            place_id: Place UUID

        Returns:
            TripPlace object or None if not found

        Usage:
            Used by detail, update, and delete endpoints.
            Caller is responsible for access control checks.
        """
        return self.db.query(TripPlace).filter(TripPlace.id == place_id).first()

    def _check_trip_ownership(self, trip_id: UUID, user_id: UUID) -> Trip:
        """
        Verify user owns the trip.

        Args:
            trip_id: Trip UUID
            user_id: User ID to check

        Returns:
            Trip object if ownership verified

        Raises:
            HTTPException 404: Trip not found
            HTTPException 403: User does not own trip

        Security:
            - Prevents users from adding places to others' trips
            - Must be called before any create/update/delete operation
        """
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        if trip.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this trip"
            )

        return trip

    def _get_next_order_in_trip(self, trip_id: UUID) -> int:
        """
        Get next order position for a trip.

        Args:
            trip_id: Trip UUID

        Returns:
            int: Next order position (max + 1, or 0 if no places)

        Usage:
            Automatically sets order_in_trip when creating a place
            without explicit order.
        """
        max_order = self.db.query(func.max(TripPlace.order_in_trip)).filter(
            TripPlace.trip_id == trip_id
        ).scalar()

        return (max_order + 1) if max_order is not None else 0

    def create_place(self, user_id: UUID, place_data: PlaceCreate) -> TripPlace:
        """
        Create new place with PostGIS Geography conversion.

        Args:
            user_id: Owner user ID
            place_data: Place creation data

        Returns:
            Created TripPlace object

        Raises:
            HTTPException 403: User does not own trip
            HTTPException 404: Trip not found

        Business Logic:
            1. Check user owns trip (ownership validation)
            2. Convert lat/lng to PostGIS Geography point
            3. Auto-set order_in_trip if not provided
            4. Create place with user_id
            5. Commit to database

        PostGIS Conversion:
            - Creates Geography POINT from lat/lng
            - Uses SRID 4326 (WGS84)
            - Format: SRID=4326;POINT(lng lat)
            - NOTE: Longitude first, then latitude!

        Side Effects:
            - Inserts row into trip_places table
            - Auto-generates UUID primary key
            - Auto-sets created_at, updated_at timestamps
        """
        # Check trip ownership
        self._check_trip_ownership(place_data.trip_id, user_id)

        # Auto-set order if not provided
        if place_data.order_in_trip is None:
            order = self._get_next_order_in_trip(place_data.trip_id)
        else:
            order = place_data.order_in_trip

        # Convert lat/lng to PostGIS Geography POINT
        # Format: SRID=4326;POINT(longitude latitude)
        # IMPORTANT: longitude first, then latitude!
        location_wkt = f"SRID=4326;POINT({place_data.lng} {place_data.lat})"

        # Create place instance
        place = TripPlace(
            trip_id=place_data.trip_id,
            user_id=user_id,
            name=place_data.name,
            place_type=place_data.place_type,
            location=location_wkt,
            lat=place_data.lat,
            lng=place_data.lng,
            user_notes=place_data.user_notes,
            user_rating=place_data.user_rating,
            visit_date=place_data.visit_date,
            order_in_trip=order
        )

        self.db.add(place)
        self.db.commit()
        self.db.refresh(place)

        return place

    def list_trip_places(self, trip_id: UUID, user_id: UUID) -> PlaceListResponse:
        """
        List all places for a trip (ordered by order_in_trip).

        Args:
            trip_id: Trip UUID
            user_id: User ID (for ownership/access check)

        Returns:
            PlaceListResponse with places and count

        Raises:
            HTTPException 403: User does not own trip and trip is private
            HTTPException 404: Trip not found

        Business Logic:
            - Returns places ordered by order_in_trip ASC
            - Access control based on trip visibility:
              - Owner can always view
              - Non-owner can view if trip is public/unlisted
            - Empty list if trip has no places

        Query Pattern:
            1. Check user can access trip (ownership or visibility)
            2. Query places for trip_id
            3. Order by order_in_trip ASC (itinerary order)
            4. Return places + count
        """
        # Get trip to check access
        trip = self.db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )

        # Access control
        is_owner = trip.user_id == user_id
        if not is_owner and trip.visibility == "private":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to view this trip"
            )

        # Query places
        places = self.db.query(TripPlace).filter(
            TripPlace.trip_id == trip_id
        ).order_by(TripPlace.order_in_trip).all()

        return PlaceListResponse(
            places=[PlaceResponse.model_validate(place) for place in places],
            total=len(places),
            trip_id=trip_id
        )

    def update_place(
        self,
        place_id: UUID,
        user_id: UUID,
        place_update: PlaceUpdate
    ) -> TripPlace:
        """
        Update existing place.

        Args:
            place_id: Place UUID
            user_id: User ID (for ownership check)
            place_update: Update data

        Returns:
            Updated TripPlace object

        Raises:
            HTTPException 404: Place not found
            HTTPException 403: User does not own trip

        Business Logic:
            1. Fetch place by ID
            2. Check user owns parent trip
            3. Apply partial update (only provided fields)
            4. If lat/lng updated, update Geography column
            5. Commit to database

        PostGIS Update:
            - If lat or lng is updated, Geography column is recalculated
            - Uses same POINT(lng lat) format as create
        """
        # Fetch place
        place = self.get_place_by_id(place_id)
        if not place:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Place not found"
            )

        # Check trip ownership
        self._check_trip_ownership(place.trip_id, user_id)

        # Get update data (only fields provided)
        update_data = place_update.model_dump(exclude_unset=True)

        # Check if coordinates are being updated
        lat_updated = 'lat' in update_data
        lng_updated = 'lng' in update_data

        # If either coordinate is updated, recalculate Geography
        if lat_updated or lng_updated:
            new_lat = update_data.get('lat', place.lat)
            new_lng = update_data.get('lng', place.lng)

            # Update Geography column
            location_wkt = f"SRID=4326;POINT({new_lng} {new_lat})"
            place.location = location_wkt

            # Update convenience columns
            place.lat = new_lat
            place.lng = new_lng

            # Remove lat/lng from update_data to avoid duplicate update
            update_data.pop('lat', None)
            update_data.pop('lng', None)

        # Apply remaining updates
        for field, value in update_data.items():
            setattr(place, field, value)

        self.db.commit()
        self.db.refresh(place)

        return place

    def delete_place(self, place_id: UUID, user_id: UUID) -> None:
        """
        Delete place.

        Args:
            place_id: Place UUID
            user_id: User ID (for ownership check)

        Raises:
            HTTPException 404: Place not found
            HTTPException 403: User does not own trip

        Business Logic:
            1. Fetch place by ID
            2. Check user owns parent trip
            3. Delete from database

        Side Effects:
            - Deletes place row from database
            - No cascading (places are leaf nodes)

        Note:
            - Permanent deletion (no soft delete)
            - Order gaps are okay (itinerary reordering is separate endpoint)
        """
        # Fetch place
        place = self.get_place_by_id(place_id)
        if not place:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Place not found"
            )

        # Check trip ownership
        self._check_trip_ownership(place.trip_id, user_id)

        # Delete
        self.db.delete(place)
        self.db.commit()

    def get_places_near_location(
        self,
        lat: float,
        lng: float,
        radius_km: float = 5.0,
        user_id: Optional[UUID] = None
    ) -> List[TripPlace]:
        """
        Find places within radius of a location (PostGIS geospatial query).

        Args:
            lat: Center latitude
            lng: Center longitude
            radius_km: Search radius in kilometers (default: 5.0)
            user_id: Optional user ID to filter only their places

        Returns:
            List of TripPlace objects within radius

        PostGIS Query:
            - Uses ST_DWithin for efficient spatial search
            - Creates Geography POINT from lat/lng
            - Converts radius from km to meters
            - Uses GIST index on location column (fast!)

        Business Logic:
            - If user_id provided, only returns user's places
            - Results ordered by distance (closest first)
            - Maximum radius: 50km (to prevent expensive queries)

        Query Pattern:
            1. Create Geography POINT from search coordinates
            2. Use ST_DWithin to filter places within radius
            3. Calculate distance for each place with ST_Distance
            4. Order by distance ASC
            5. Return places
        """
        # Cap radius at 50km to prevent expensive queries
        if radius_km > 50:
            radius_km = 50

        # Convert km to meters
        radius_meters = radius_km * 1000

        # Build query
        # Create Geography POINT from lat/lng
        # IMPORTANT: ST_MakePoint takes (longitude, latitude)
        search_point = func.ST_SetSRID(
            func.ST_MakePoint(lng, lat),
            4326
        ).cast(Geography)

        query = self.db.query(TripPlace).filter(
            func.ST_DWithin(
                TripPlace.location,
                search_point,
                radius_meters
            )
        )

        # Filter by user if provided
        if user_id:
            query = query.filter(TripPlace.user_id == user_id)

        # Order by distance (closest first)
        query = query.order_by(
            func.ST_Distance(TripPlace.location, search_point)
        )

        return query.all()
