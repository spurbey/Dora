"""
Component service for unified timeline operations.

Handles reordering and detail resolution for trip components (places + routes).
"""

from sqlalchemy.orm import Session
from uuid import UUID
from typing import Optional

from app.models.place import TripPlace
from app.models.route import Route
from app.models.trip_component import TripComponent


class ComponentService:
    """
    Service for component operations.

    Provides:
    - Bulk reordering with normalization
    - Component detail resolution (auto-detect type)
    """

    def __init__(self, db: Session):
        """Initialize service with database session."""
        self.db = db

    async def reorder_components(
        self,
        trip_id: UUID,
        items: list[dict]
    ) -> int:
        """
        Bulk reorder places and routes with normalization.

        Ensures clean sequential ordering: 0, 1, 2, 3... (no gaps, no duplicates).

        Algorithm:
        1. Sort items by new_order (ascending)
        2. Assign sequential integers starting from 0
        3. Update source tables (trip_places, routes)

        Args:
            trip_id: Trip UUID
            items: List of dicts with keys:
                - id: Component UUID
                - component_type: 'place' or 'route'
                - new_order: Desired order (will be normalized)

        Returns:
            Number of components successfully updated

        Example:
            Input:  [place(8), route(2), place(5)]
            Output: [route(0), place(1), place(2)]
        """
        # Sort by new_order first
        sorted_items = sorted(items, key=lambda x: x['new_order'])

        updated_count = 0

        # Normalize to sequential integers (0, 1, 2, 3...)
        for idx, item in enumerate(sorted_items):
            if item['component_type'] == 'place':
                place = self.db.query(TripPlace).filter(
                    TripPlace.id == item['id'],
                    TripPlace.trip_id == trip_id
                ).first()

                if place:
                    place.order_in_trip = idx
                    updated_count += 1

            elif item['component_type'] == 'route':
                route = self.db.query(Route).filter(
                    Route.id == item['id'],
                    Route.trip_id == trip_id
                ).first()

                if route:
                    route.order_in_trip = idx
                    updated_count += 1

        self.db.commit()
        return updated_count

    async def get_component_details(
        self,
        trip_id: UUID,
        component_id: UUID
    ) -> Optional[dict]:
        """
        Fetch full details of a component.

        Auto-detects type from view (no type parameter needed).
        Returns full entity data from source table.

        Args:
            trip_id: Trip UUID
            component_id: Component UUID

        Returns:
            dict with keys:
                - id: Component UUID
                - component_type: 'place' or 'route'
                - order_in_trip: Display order
                - place_data: Full PlaceResponse (if place) or None
                - route_data: Full RouteResponse (if route) or None

            Returns None if component not found.

        Example:
            >>> details = await service.get_component_details(trip_id, component_id)
            >>> if details['component_type'] == 'place':
            >>>     print(details['place_data'].name)
        """
        # Step 1: Get component from view to determine type
        component = self.db.query(TripComponent).filter(
            TripComponent.id == component_id,
            TripComponent.trip_id == trip_id
        ).first()

        if not component:
            return None

        # Step 2: Fetch full entity based on type
        if component.component_type == 'place':
            place = self.db.query(TripPlace).filter(
                TripPlace.id == component.source_id
            ).first()

            return {
                'id': component_id,
                'component_type': 'place',
                'order_in_trip': component.order_in_trip,
                'place_data': place,
                'route_data': None
            }

        elif component.component_type == 'route':
            route = self.db.query(Route).filter(
                Route.id == component.source_id
            ).first()

            return {
                'id': component_id,
                'component_type': 'route',
                'order_in_trip': component.order_in_trip,
                'place_data': None,
                'route_data': route
            }

        return None
