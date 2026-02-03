import { useEffect, useRef } from 'react';
import { mapboxgl } from '@/lib/mapbox';
import type { Route } from '@/types/route';
import type { RouteMetadata } from '@/types/routeMetadata';

interface RouteMetadataBadgeProps {
  map: mapboxgl.Map;
  route: Route;
  metadata: RouteMetadata;
  onClick: () => void;
}

function getRouteMidpoint(route: Route['route_geojson']): [number, number] | null {
  if (!route) return null;
  if (route.type === 'LineString') {
    const coords = route.coordinates;
    if (!coords.length) return null;
    return coords[Math.floor(coords.length / 2)] as [number, number];
  }
  if (route.type === 'FeatureCollection') {
    const feature = route.features.find((item) => item.geometry.type === 'LineString');
    if (!feature) return null;
    const coords = (feature.geometry as GeoJSON.LineString).coordinates;
    if (!coords.length) return null;
    return coords[Math.floor(coords.length / 2)] as [number, number];
  }
  return null;
}

function getBadgeLabel(metadata: RouteMetadata) {
  if (metadata.route_quality === 'scenic') return 'Scenic';
  if (metadata.route_quality === 'offbeat') return 'Offbeat';
  if (metadata.road_condition === 'offroad') return 'Offroad';
  if (metadata.safety_rating && metadata.safety_rating <= 2) return 'Caution';
  return 'Route';
}

export function RouteMetadataBadge({ map, route, metadata, onClick }: RouteMetadataBadgeProps) {
  const markerRef = useRef<mapboxgl.Marker | null>(null);

  useEffect(() => {
    const midpoint = getRouteMidpoint(route.route_geojson);
    if (!midpoint) return;

    const el = document.createElement('button');
    el.type = 'button';
    el.className =
      'rounded-full border border-white/10 bg-emerald-600/80 px-3 py-1 text-xs font-semibold text-white shadow';
    el.textContent = getBadgeLabel(metadata);
    el.addEventListener('click', (event) => {
      event.stopPropagation();
      onClick();
    });

    const marker = new mapboxgl.Marker({ element: el })
      .setLngLat(midpoint)
      .addTo(map);

    markerRef.current = marker;

    return () => {
      marker.remove();
    };
  }, [map, metadata, onClick, route.route_geojson]);

  return null;
}
