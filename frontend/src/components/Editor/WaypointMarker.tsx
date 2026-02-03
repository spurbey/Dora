import { useEffect, useRef } from 'react';
import { mapboxgl } from '@/lib/mapbox';
import type { Waypoint } from '@/types/waypoint';

interface WaypointMarkerProps {
  waypoint: Waypoint;
  map: mapboxgl.Map;
  onClick?: (waypoint: Waypoint) => void;
  onDrag?: (waypoint: Waypoint, newLat: number, newLng: number) => void;
}

export function WaypointMarker({ waypoint, map, onClick, onDrag }: WaypointMarkerProps) {
  const markerRef = useRef<mapboxgl.Marker | null>(null);

  useEffect(() => {
    const el = document.createElement('div');
    el.className =
      'flex h-8 w-8 items-center justify-center rounded-full border-2 border-white bg-orange-500 text-[10px] font-semibold text-white shadow-lg';
    el.textContent = 'W';

    const marker = new mapboxgl.Marker({ element: el, draggable: true })
      .setLngLat([waypoint.lng, waypoint.lat])
      .addTo(map);

    el.addEventListener('click', () => {
      onClick?.(waypoint);
    });

    marker.on('dragend', () => {
      const lngLat = marker.getLngLat();
      onDrag?.(waypoint, lngLat.lat, lngLat.lng);
    });

    markerRef.current = marker;

    return () => {
      marker.remove();
    };
  }, [map, onClick, onDrag, waypoint]);

  return null;
}
