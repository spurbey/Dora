import { useCallback, useState } from 'react';
import { mapboxDirections, type DirectionsResult, type MapboxProfile } from '@/services/mapboxDirections';
import type { Route } from '@/types/route';
import type { TempWaypoint, Waypoint } from '@/types/waypoint';
import { useEditorStore } from '@/store/editorStore';

const PROFILE_BY_MODE: Record<Route['transport_mode'], MapboxProfile> = {
  car: 'driving',
  bike: 'cycling',
  foot: 'walking',
  air: 'driving',
  bus: 'driving',
  train: 'driving',
};

function extractLineString(routeGeojson: Route['route_geojson']): GeoJSON.LineString | null {
  if (!routeGeojson) return null;
  if (routeGeojson.type === 'LineString') return routeGeojson;
  if (routeGeojson.type === 'FeatureCollection') {
    const feature = routeGeojson.features.find((item) => item.geometry.type === 'LineString');
    return feature ? (feature.geometry as GeoJSON.LineString) : null;
  }
  return null;
}

export function useWaypointManagement() {
  const tempWaypoint = useEditorStore((state) => state.tempWaypoint);
  const setTempWaypoint = useEditorStore((state) => state.setTempWaypoint);

  const [isRecalculating, setIsRecalculating] = useState(false);
  const [updatedRoute, setUpdatedRoute] = useState<DirectionsResult | null>(null);

  const recalculateRoute = useCallback(
    async (
      route: Route,
      existingWaypoints: Waypoint[],
      newWaypoint?: { lat: number; lng: number; insertIndex: number }
    ): Promise<DirectionsResult | null> => {
      const line = extractLineString(route.route_geojson);
      if (!line || line.coordinates.length < 2) return null;

      setIsRecalculating(true);
      try {
        const start = line.coordinates[0] as [number, number];
        const end = line.coordinates[line.coordinates.length - 1] as [number, number];

        const sortedWaypoints = [...existingWaypoints];
        if (newWaypoint) {
          sortedWaypoints.splice(newWaypoint.insertIndex, 0, {
            lat: newWaypoint.lat,
            lng: newWaypoint.lng,
          } as Waypoint);
        }

        sortedWaypoints.sort((a, b) => a.order_in_route - b.order_in_route);

        const coordinates: Array<[number, number]> = [
          start,
          ...sortedWaypoints.map((w) => [w.lng, w.lat] as [number, number]),
          end,
        ];

        const profile = PROFILE_BY_MODE[route.transport_mode] ?? 'driving';
        const result = await mapboxDirections.getRoute(coordinates, profile);
        setUpdatedRoute(result);
        return result;
      } catch (error) {
        console.error('Failed to recalculate route', error);
        return null;
      } finally {
        setIsRecalculating(false);
      }
    },
    []
  );

  const addWaypointAtPosition = useCallback(
    async (route: Route, waypoints: Waypoint[], lat: number, lng: number) => {
      const insertIndex = waypoints.length;
      const nextWaypoint: TempWaypoint = {
        lat,
        lng,
        route_id: route.id,
        insertIndex,
      };

      setTempWaypoint(nextWaypoint);
      await recalculateRoute(route, waypoints, nextWaypoint);
    },
    [recalculateRoute, setTempWaypoint]
  );

  const clearTempWaypoint = useCallback(() => {
    setTempWaypoint(null);
    setUpdatedRoute(null);
  }, [setTempWaypoint]);

  return {
    tempWaypoint,
    isRecalculating,
    updatedRoute,
    addWaypointAtPosition,
    recalculateRoute,
    clearTempWaypoint,
  };
}
