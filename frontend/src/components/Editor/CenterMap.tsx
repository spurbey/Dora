import { useEffect, useRef, useState } from 'react';
import { mapboxgl } from '@/lib/mapbox';
import { useEditorStore } from '@/store/editorStore';
import type { Route } from '@/types/route';

export function CenterMap() {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markers = useRef<mapboxgl.Marker[]>([]);
  const routeLayerIds = useRef<string[]>([]);
  const [isMapLoaded, setIsMapLoaded] = useState(false);

  const { places, routes, mapViewport, setMapViewport } = useEditorStore();

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || map.current) return;
    if (!mapboxgl.accessToken) return;

    const mapInstance = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [mapViewport.lng, mapViewport.lat],
      zoom: mapViewport.zoom,
    });

    mapInstance.on('move', () => {
      const center = mapInstance.getCenter();
      setMapViewport({
        lat: center.lat,
        lng: center.lng,
        zoom: mapInstance.getZoom(),
      });
    });

    mapInstance.on('load', () => {
      setIsMapLoaded(true);
    });

    map.current = mapInstance;

    return () => {
      markers.current.forEach((marker) => marker.remove());
      markers.current = [];
      routeLayerIds.current.forEach((id) => {
        if (!mapInstance.getLayer(id)) return;
        mapInstance.removeLayer(id);
        mapInstance.removeSource(id);
      });
      mapInstance.remove();
      map.current = null;
      setIsMapLoaded(false);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update place markers
  useEffect(() => {
    if (!map.current) return;

    markers.current.forEach((marker) => marker.remove());
    markers.current = [];

    places.forEach((place) => {
      const marker = new mapboxgl.Marker({ color: '#10b981' })
        .setLngLat([place.lng, place.lat])
        .addTo(map.current!);
      markers.current.push(marker);
    });

    if (isMapLoaded && places.length > 0) {
      const bounds = new mapboxgl.LngLatBounds();
      places.forEach((place) => bounds.extend([place.lng, place.lat]));
      map.current.fitBounds(bounds, { padding: 80, duration: 800 });
    }
  }, [places, isMapLoaded]);

  // Update route lines
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    const addRouteLayer = (route: Route) => {
      if (!map.current) return;

      const layerId = `route-${route.id}`;
      map.current.addSource(layerId, {
        type: 'geojson',
        data: route.route_geojson as GeoJSON.FeatureCollection | GeoJSON.Geometry,
      });
      map.current.addLayer({
        id: layerId,
        type: 'line',
        source: layerId,
        paint: {
          'line-color': '#0891B2',
          'line-width': 3,
          'line-opacity': 0.8,
        },
      });
      routeLayerIds.current.push(layerId);
    };

    routeLayerIds.current.forEach((id) => {
      if (map.current?.getLayer(id)) {
        map.current.removeLayer(id);
      }
      if (map.current?.getSource(id)) {
        map.current.removeSource(id);
      }
    });
    routeLayerIds.current = [];

    routes.forEach((route) => {
      addRouteLayer(route);
    });
  }, [routes, isMapLoaded]);

  return (
    <section className="relative h-[60vh] w-full overflow-hidden rounded-2xl border border-white/10 bg-white/5 xl:h-[calc(100vh-230px)] xl:flex-1">
      <div ref={mapContainer} className="h-full w-full" />
      {!mapboxgl.accessToken && (
        <div className="absolute inset-0 flex items-center justify-center text-sm text-white/70">
          Mapbox token missing — set VITE_MAPBOX_TOKEN
        </div>
      )}
    </section>
  );
}
