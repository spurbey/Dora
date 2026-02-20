"""
Route service for Mapbox Directions API integration.

Provides route generation functionality using Mapbox Directions API.
Follows Phase A2 PRD specification.
"""

import httpx
from app.config import settings


class RouteService:
    """
    Service for generating routes using Mapbox Directions API.

    Attributes:
        MAPBOX_API_URL: Base URL for Mapbox Directions API
    """

    MAPBOX_API_URL = "https://api.mapbox.com/directions/v5"

    def __init__(self):
        """Initialize the route service."""
        self.mapbox_token = (
            getattr(settings, 'MAPBOX_ACCESS_TOKEN', None)
            or getattr(settings, 'MAPBOX_API_KEY', None)
        )

    async def generate_route(
        self,
        coordinates: list[tuple[float, float]],
        mode: str = 'driving'
    ) -> dict:
        """
        Call Mapbox Directions API to generate a route.

        Args:
            coordinates: List of (lng, lat) tuples (minimum 2 points)
            mode: Transport mode ('driving', 'walking', 'cycling')

        Returns:
            dict: {
                'route_geojson': dict,  # GeoJSON LineString
                'distance_km': float,   # Distance in kilometers
                'duration_mins': int,   # Duration in minutes
                'polyline_encoded': str # Optional encoded polyline
            }

        Raises:
            ValueError: If mapbox token not configured or invalid coordinates
            httpx.HTTPError: If Mapbox API request fails

        Example:
            >>> service = RouteService()
            >>> result = await service.generate_route(
            ...     [(77.5946, 12.9716), (77.6000, 13.0000)],
            ...     mode='driving'
            ... )
            >>> print(result['distance_km'])
            10.5
        """
        if not self.mapbox_token:
            raise ValueError(
                "Mapbox token not configured in settings "
                "(expected MAPBOX_API_KEY or MAPBOX_ACCESS_TOKEN). "
                "Please add it to your .env file."
            )

        if len(coordinates) < 2:
            raise ValueError("At least 2 coordinates required for route generation")

        # Map mode to Mapbox profile
        mode_mapping = {
            'driving': 'mapbox/driving',
            'walking': 'mapbox/walking',
            'cycling': 'mapbox/cycling'
        }
        profile = mode_mapping.get(mode, 'mapbox/driving')

        # Format coordinates as "lng,lat;lng,lat;..."
        coords_str = ';'.join([f"{lng},{lat}" for lng, lat in coordinates])

        # Build Mapbox API URL
        url = f"{self.MAPBOX_API_URL}/{profile}/{coords_str}"

        # Query parameters
        params = {
            'access_token': self.mapbox_token,
            'geometries': 'geojson',  # Return GeoJSON geometry
            'overview': 'full',        # Full route geometry
            'steps': 'false'           # Don't need turn-by-turn steps
        }

        # Make API request
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()

        # Parse response
        if 'routes' not in data or len(data['routes']) == 0:
            raise ValueError("No route found by Mapbox API")

        route = data['routes'][0]

        # Extract route data
        route_geojson = {
            'type': 'LineString',
            'coordinates': route['geometry']['coordinates']
        }

        # Distance in kilometers (Mapbox returns meters)
        distance_km = round(route['distance'] / 1000, 2)

        # Duration in minutes (Mapbox returns seconds)
        duration_mins = round(route['duration'] / 60)

        return {
            'route_geojson': route_geojson,
            'distance_km': distance_km,
            'duration_mins': duration_mins,
            'polyline_encoded': None  # Not provided by Mapbox in geojson mode
        }

    async def calculate_distance(
        self,
        start_coords: tuple[float, float],
        end_coords: tuple[float, float],
        mode: str = 'driving'
    ) -> float:
        """
        Calculate distance between two points using Mapbox API.

        Args:
            start_coords: Starting point (lng, lat)
            end_coords: Ending point (lng, lat)
            mode: Transport mode

        Returns:
            float: Distance in kilometers
        """
        result = await self.generate_route([start_coords, end_coords], mode)
        return result['distance_km']
