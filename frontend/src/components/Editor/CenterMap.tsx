import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { mapboxgl } from '@/lib/mapbox';
import { useEditorStore } from '@/store/editorStore';
import { useRouteDrawing } from '@/hooks/useRouteDrawing';
import { RouteDrawer } from '@/components/Editor/RouteDrawer';
import { WaypointMarker } from '@/components/Editor/WaypointMarker';
import { WaypointPanel } from '@/components/Editor/WaypointPanel';
import { WaypointForm } from '@/components/Editor/WaypointForm';
import { RouteMetadataBadge } from '@/components/Editor/RouteMetadataBadge';
import {
  useWaypoints,
  useCreateWaypoint,
  useUpdateWaypoint,
  useDeleteWaypoint,
} from '@/hooks/useWaypoints';
import { useWaypointManagement } from '@/hooks/useWaypointManagement';
import { routeService } from '@/services/routeService';
import type { DirectionsResult } from '@/services/mapboxDirections';
import { Dialog, DialogContent } from '@/components/ui/dialog';
import type { Route } from '@/types/route';
import type { Waypoint, WaypointCreate } from '@/types/waypoint';

export function CenterMap() {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markers = useRef<Record<string, mapboxgl.Marker>>({});
  const tempMarkers = useRef<mapboxgl.Marker[]>([]);
  const routeLayerIds = useRef<string[]>([]);
  const [isMapLoaded, setIsMapLoaded] = useState(false);
  const [selectedWaypoint, setSelectedWaypoint] = useState<Waypoint | null>(null);
  const [editingWaypoint, setEditingWaypoint] = useState<Waypoint | null>(null);

  const {
    places,
    routes,
    trip,
    tripMetadata,
    placeMetadata,
    mapViewport,
    setMapViewport,
    editMode,
    tempRoute,
    drawingTransportMode,
    selectedItem,
    selectedItemSource,
    highlightedItem,
    selectedRoute,
    setSelectedItem,
    setSelectedRoute,
    setHighlightedItem,
    waypoints: waypointsByRoute,
    setWaypoints,
    addWaypoint,
    updateWaypoint,
    removeWaypoint,
    updateItem,
    routeMetadata,
  } = useEditorStore();

  const tripIsPublic = trip?.visibility === 'public' && (tripMetadata?.is_discoverable ?? false);

  const { addPoint, isLoading } = useRouteDrawing();
  const {
    tempWaypoint,
    isRecalculating,
    updatedRoute,
    addWaypointAtPosition,
    recalculateRoute,
    clearTempWaypoint,
  } = useWaypointManagement();

  const tempRouteSourceId = 'temp-route-preview';
  const tempRouteLayerId = 'temp-route-preview-layer';

  const selectedRouteId = selectedRoute?.id ?? '';
  const { data: waypointsData = [] } = useWaypoints(selectedRouteId);
  const createWaypoint = useCreateWaypoint(selectedRouteId);
  const updateWaypointMutation = useUpdateWaypoint(selectedRouteId);
  const deleteWaypointMutation = useDeleteWaypoint(selectedRouteId);

  const activeWaypoints = useMemo(
    () => (selectedRouteId ? waypointsByRoute[selectedRouteId] ?? waypointsData : []),
    [selectedRouteId, waypointsByRoute, waypointsData]
  );

  const waypointsSignature = useCallback((items: Waypoint[]) => {
    if (!items.length) return '';
    return items
      .map((item) =>
        [
          item.id,
          item.updated_at ?? '',
          item.order_in_route ?? '',
          item.lat ?? '',
          item.lng ?? '',
        ].join(':')
      )
      .sort()
      .join('|');
  }, []);

  useEffect(() => {
    if (!selectedRouteId) return;

    const existing = waypointsByRoute[selectedRouteId] ?? [];
    const incomingSignature = waypointsSignature(waypointsData);
    const existingSignature = waypointsSignature(existing);

    if (incomingSignature !== existingSignature) {
      setWaypoints(selectedRouteId, waypointsData);
    }
  }, [
    selectedRouteId,
    setWaypoints,
    waypointsByRoute,
    waypointsData,
    waypointsSignature,
  ]);

  const persistRouteUpdate = async (
    route: Route,
    result: DirectionsResult | null | undefined
  ) => {
    if (!result) return;

    const updated = await routeService.updateRoute(route.id, {
      route_geojson: result.geojson,
      distance_km: result.distance_km,
      duration_mins: result.duration_mins,
    });
    updateItem('route', route.id, updated);
  };

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
      Object.values(markers.current).forEach((marker) => marker.remove());
      markers.current = {};
      tempMarkers.current.forEach((marker) => marker.remove());
      tempMarkers.current = [];
      routeLayerIds.current.forEach((id) => {
        if (!mapInstance.getLayer(id)) return;
        mapInstance.removeLayer(id);
        mapInstance.removeSource(id);
      });
      if (mapInstance.getLayer(tempRouteLayerId)) {
        mapInstance.removeLayer(tempRouteLayerId);
      }
      if (mapInstance.getSource(tempRouteSourceId)) {
        mapInstance.removeSource(tempRouteSourceId);
      }
      mapInstance.remove();
      map.current = null;
      setIsMapLoaded(false);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update place markers
  useEffect(() => {
    if (!map.current) return;

    Object.values(markers.current).forEach((marker) => marker.remove());
    markers.current = {};

    places.forEach((place) => {
      const isPublic = tripIsPublic && Boolean(placeMetadata[place.id]?.is_public);
      const el = document.createElement('div');
      el.style.width = '14px';
      el.style.height = '14px';
      el.style.borderRadius = '9999px';
      el.style.background = '#10b981';
      el.style.border = '2px solid rgba(15, 23, 42, 0.8)';
      el.style.boxShadow = isPublic ? '0 0 0 4px rgba(16, 185, 129, 0.25)' : '0 0 0 0 rgba(16, 185, 129, 0)';
      el.style.transition = 'transform 150ms ease, box-shadow 150ms ease';
      el.dataset.public = isPublic ? 'true' : 'false';

      el.addEventListener('click', (event) => {
        event.stopPropagation();
        setSelectedItem({ type: 'place', id: place.id }, 'map');
      });

      el.addEventListener('mouseenter', () => {
        setHighlightedItem({ type: 'place', id: place.id });
      });

      el.addEventListener('mouseleave', () => {
        setHighlightedItem(null);
      });

      const marker = new mapboxgl.Marker({ element: el })
        .setLngLat([place.lng, place.lat])
        .addTo(map.current!);
      markers.current[place.id] = marker;
    });

    if (isMapLoaded && places.length > 0) {
      const bounds = new mapboxgl.LngLatBounds();
      places.forEach((place) => bounds.extend([place.lng, place.lat]));
      map.current.fitBounds(bounds, { padding: 80, duration: 800 });
    }
  }, [
    places,
    isMapLoaded,
    placeMetadata,
    setHighlightedItem,
    setSelectedItem,
    tripIsPublic,
  ]);

  useEffect(() => {
    const selectedPlaceId = selectedItem?.type === 'place' ? selectedItem.id : null;
    const highlightedPlaceId = highlightedItem?.type === 'place' ? highlightedItem.id : null;

    Object.entries(markers.current).forEach(([id, marker]) => {
      const el = marker.getElement();
      const isPublic = el.dataset.public === 'true';
      if (id === selectedPlaceId) {
        el.style.transform = 'scale(1.25)';
        el.style.boxShadow = '0 0 0 6px rgba(16, 185, 129, 0.35)';
      } else if (id === highlightedPlaceId) {
        el.style.transform = 'scale(1.15)';
        el.style.boxShadow = '0 0 0 4px rgba(16, 185, 129, 0.25)';
      } else {
        el.style.transform = 'scale(1)';
        el.style.boxShadow = isPublic
          ? '0 0 0 4px rgba(16, 185, 129, 0.25)'
          : '0 0 0 0 rgba(16, 185, 129, 0)';
      }
    });
  }, [highlightedItem, selectedItem]);

  const getRouteStyle = useCallback((route: Route) => {
    const metadata = routeMetadata[route.id];
    let lineColor = '#0891B2';
    let lineWidth = 3;
    let lineDash: number[] | null = null;
    const isHighlighted =
      highlightedItem?.type === 'route' && highlightedItem.id === route.id;

    if (metadata?.road_condition === 'offroad') {
      lineDash = [2, 2];
      lineColor = '#D4A373';
    }
    if (metadata?.route_quality === 'scenic') {
      lineColor = '#059669';
      lineWidth = 5;
    }
    if (metadata?.route_quality === 'offbeat') {
      lineColor = '#7C3AED';
    }

    if (selectedRoute?.id === route.id) {
      lineWidth = Math.max(lineWidth, 5);
    }
    if (isHighlighted && selectedRoute?.id !== route.id) {
      lineWidth = Math.max(lineWidth, 4);
      lineColor = '#22d3ee';
    }

    return { lineColor, lineWidth, lineDash };
  }, [highlightedItem, routeMetadata, selectedRoute]);

  const fitRouteBounds = useCallback((route: Route) => {
    if (!map.current) return;

    const bounds = new mapboxgl.LngLatBounds();
    const collectCoords = (geometry: GeoJSON.Geometry | GeoJSON.Feature | GeoJSON.FeatureCollection) => {
      if (!geometry) return;
      if (geometry.type === 'FeatureCollection') {
        geometry.features.forEach((feature) => collectCoords(feature));
        return;
      }
      if (geometry.type === 'Feature') {
        collectCoords(geometry.geometry);
        return;
      }
      if (geometry.type === 'LineString') {
        geometry.coordinates.forEach((coord) => bounds.extend(coord as [number, number]));
        return;
      }
      if (geometry.type === 'MultiLineString') {
        geometry.coordinates.forEach((line) =>
          line.forEach((coord) => bounds.extend(coord as [number, number]))
        );
      }
    };

    collectCoords(route.route_geojson as GeoJSON.FeatureCollection);
    if (!bounds.isEmpty()) {
      map.current.fitBounds(bounds, { padding: 80, duration: 800 });
    }
  }, []);

  useEffect(() => {
    if (!map.current || !isMapLoaded) return;
    if (!selectedItem || selectedItemSource !== 'timeline') return;

    if (selectedItem.type === 'place') {
      const place = places.find((item) => item.id === selectedItem.id);
      if (!place) return;
      map.current.flyTo({ center: [place.lng, place.lat], zoom: 15, duration: 900 });
      return;
    }

    if (selectedItem.type === 'route') {
      const route = routes.find((item) => item.id === selectedItem.id);
      if (!route) return;
      fitRouteBounds(route);
    }
  }, [fitRouteBounds, isMapLoaded, places, routes, selectedItem, selectedItemSource]);

  // Update route lines
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    const addRouteLayer = (route: Route) => {
      if (!map.current) return;

      const { lineColor, lineWidth, lineDash } = getRouteStyle(route);
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
          'line-color': lineColor,
          'line-width': lineWidth,
          'line-opacity': 0.8,
          ...(lineDash ? { 'line-dasharray': lineDash } : {}),
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
  }, [routes, isMapLoaded, getRouteStyle]);

  // Update route styles on metadata/selection changes
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    routes.forEach((route) => {
      const layerId = `route-${route.id}`;
      if (!map.current?.getLayer(layerId)) return;
      const { lineColor, lineWidth, lineDash } = getRouteStyle(route);
      map.current.setPaintProperty(layerId, 'line-color', lineColor);
      map.current.setPaintProperty(layerId, 'line-width', lineWidth);
      if (lineDash) {
        map.current.setPaintProperty(layerId, 'line-dasharray', lineDash);
      } else {
        map.current.setPaintProperty(layerId, 'line-dasharray', [1, 0]);
      }
    });
  }, [isMapLoaded, routes, getRouteStyle]);

  // Handle map clicks for route drawing / selection / waypoint
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    const handleClick = (event: mapboxgl.MapMouseEvent) => {
      if (editMode === 'draw-route') {
        void addPoint(event.lngLat.lng, event.lngLat.lat, drawingTransportMode);
        return;
      }

      if (editMode === 'add-waypoint' && selectedRoute) {
        const layerId = `route-${selectedRoute.id}`;
        const features = map.current?.queryRenderedFeatures(event.point, { layers: [layerId] }) || [];
        if (features.length > 0) {
          void addWaypointAtPosition(selectedRoute, activeWaypoints, event.lngLat.lat, event.lngLat.lng);
        }
        return;
      }

      if (editMode === 'view') {
        if (routeLayerIds.current.length === 0) return;
        const features = map.current?.queryRenderedFeatures(event.point, {
          layers: routeLayerIds.current,
        }) || [];
        const firstFeature = features[0];
        if (!firstFeature) return;

        const layerId = firstFeature.layer?.id;
        if (!layerId) return;
        const routeId = layerId.replace('route-', '');
        const route = routes.find((item) => item.id === routeId);
        if (route) {
          setSelectedItem({ type: 'route', id: route.id }, 'map');
        }
      }
    };

    const canvas = map.current.getCanvas();
    if (editMode === 'draw-route' || editMode === 'add-waypoint') {
      canvas.style.cursor = 'crosshair';
    } else {
      canvas.style.cursor = '';
    }

    map.current.on('click', handleClick);

    return () => {
      map.current?.off('click', handleClick);
    };
  }, [
    activeWaypoints,
    addPoint,
    addWaypointAtPosition,
    drawingTransportMode,
    editMode,
    isMapLoaded,
    routes,
    selectedRoute,
    setSelectedItem,
  ]);

  // Render temporary route points
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    tempMarkers.current.forEach((marker) => marker.remove());
    tempMarkers.current = [];

    if (!tempRoute?.points?.length) return;

    tempRoute.points.forEach((point, index) => {
      const el = document.createElement('div');
      el.className =
        'flex h-6 w-6 items-center justify-center rounded-full border-2 border-white bg-blue-500 text-[10px] font-semibold text-white';
      el.textContent = `${index + 1}`;

      const marker = new mapboxgl.Marker({ element: el })
        .setLngLat([point.lng, point.lat])
        .addTo(map.current!);
      tempMarkers.current.push(marker);
    });
  }, [isMapLoaded, tempRoute?.points]);

  // Render temporary route preview line
  useEffect(() => {
    if (!map.current || !isMapLoaded) return;

    if (!tempRoute?.preview) {
      if (map.current.getLayer(tempRouteLayerId)) {
        map.current.removeLayer(tempRouteLayerId);
      }
      if (map.current.getSource(tempRouteSourceId)) {
        map.current.removeSource(tempRouteSourceId);
      }
      return;
    }

    const data: GeoJSON.Feature<GeoJSON.LineString> = {
      type: 'Feature',
      properties: {},
      geometry: tempRoute.preview.geojson,
    };

    if (map.current.getSource(tempRouteSourceId)) {
      (map.current.getSource(tempRouteSourceId) as mapboxgl.GeoJSONSource).setData(data);
    } else {
      map.current.addSource(tempRouteSourceId, {
        type: 'geojson',
        data,
      });
      map.current.addLayer({
        id: tempRouteLayerId,
        type: 'line',
        source: tempRouteSourceId,
        paint: {
          'line-color': '#3b82f6',
          'line-width': 4,
          'line-opacity': 0.85,
        },
      });
    }
  }, [isMapLoaded, tempRoute?.preview]);

  const handleSaveTempWaypoint = async (data: WaypointCreate) => {
    if (!selectedRoute || !tempWaypoint) return;

    const payload: WaypointCreate = {
      ...data,
      lat: tempWaypoint.lat,
      lng: tempWaypoint.lng,
      order_in_route: tempWaypoint.insertIndex,
    };

    const newWaypoint = await createWaypoint.mutateAsync(payload);
    addWaypoint(newWaypoint);
    await persistRouteUpdate(selectedRoute, updatedRoute);
    clearTempWaypoint();
  };

  const handleUpdateWaypoint = async (waypoint: Waypoint, updates: WaypointCreate) => {
    const updated = await updateWaypointMutation.mutateAsync({ id: waypoint.id, data: updates });
    updateWaypoint(updated);

    if (selectedRoute) {
      const nextWaypoints = activeWaypoints.map((item) =>
        item.id === updated.id ? updated : item
      );
      const result = await recalculateRoute(selectedRoute, nextWaypoints);
      await persistRouteUpdate(selectedRoute, result);
    }
  };

  const handleDeleteWaypoint = async (waypoint: Waypoint) => {
    await deleteWaypointMutation.mutateAsync(waypoint.id);
    if (selectedRoute) {
      removeWaypoint(selectedRoute.id, waypoint.id);
      const nextWaypoints = activeWaypoints.filter((item) => item.id !== waypoint.id);
      const result = await recalculateRoute(selectedRoute, nextWaypoints);
      await persistRouteUpdate(selectedRoute, result);
    }
  };

  return (
    <section className="relative h-[60vh] w-full overflow-hidden rounded-2xl border border-white/10 bg-white/5 xl:h-[calc(100vh-230px)] xl:flex-1">
      <div ref={mapContainer} className="h-full w-full" />
      {!mapboxgl.accessToken && (
        <div className="absolute inset-0 flex items-center justify-center text-sm text-white/70">
          Mapbox token missing - set VITE_MAPBOX_TOKEN
        </div>
      )}
      {editMode === 'add-waypoint' && (
        <div className="pointer-events-none absolute left-4 top-4 rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/80">
          Click on a route line to add a waypoint
        </div>
      )}
      <RouteDrawer isDrawing={editMode === 'draw-route'} isLoading={isLoading || isRecalculating} />

      {map.current &&
        routes.map((route) => {
          const metadata = routeMetadata[route.id];
          if (!metadata) return null;
          return (
            <RouteMetadataBadge
              key={`badge-${route.id}`}
              map={map.current!}
              route={route}
              metadata={metadata}
              onClick={() => setSelectedRoute(route)}
            />
          );
        })}

      {map.current &&
        activeWaypoints.map((waypoint) => (
          <WaypointMarker
            key={waypoint.id}
            waypoint={waypoint}
            map={map.current!}
            onClick={(selected) => setSelectedWaypoint(selected)}
            onDrag={async (selected, newLat, newLng) => {
              const updated = await updateWaypointMutation.mutateAsync({
                id: selected.id,
                data: { lat: newLat, lng: newLng },
              });
              updateWaypoint(updated);
              if (selectedRoute) {
                const nextWaypoints = activeWaypoints.map((item) =>
                  item.id === updated.id ? updated : item
                );
                const result = await recalculateRoute(selectedRoute, nextWaypoints);
                await persistRouteUpdate(selectedRoute, result);
              }
            }}
          />
        ))}

      {selectedWaypoint && (
        <WaypointPanel
          waypoint={selectedWaypoint}
          onEdit={() => {
            setEditingWaypoint(selectedWaypoint);
            setSelectedWaypoint(null);
          }}
          onDelete={() => {
            void handleDeleteWaypoint(selectedWaypoint);
            setSelectedWaypoint(null);
          }}
          onClose={() => setSelectedWaypoint(null)}
        />
      )}

      <Dialog
        open={Boolean(tempWaypoint || editingWaypoint)}
        onOpenChange={(open) => {
          if (!open) {
            clearTempWaypoint();
            setEditingWaypoint(null);
          }
        }}
      >
        <DialogContent className="max-w-md">
          <WaypointForm
            initialData={
              editingWaypoint
                ? {
                    name: editingWaypoint.name,
                    waypoint_type: editingWaypoint.waypoint_type,
                    notes: editingWaypoint.notes ?? '',
                    lat: editingWaypoint.lat,
                    lng: editingWaypoint.lng,
                    order_in_route: editingWaypoint.order_in_route,
                  }
                : tempWaypoint
                  ? {
                      lat: tempWaypoint.lat,
                      lng: tempWaypoint.lng,
                      order_in_route: tempWaypoint.insertIndex,
                    }
                  : undefined
            }
            onSubmit={(data) => {
              if (editingWaypoint) {
                void handleUpdateWaypoint(editingWaypoint, data);
                setEditingWaypoint(null);
              } else {
                void handleSaveTempWaypoint(data);
              }
            }}
            onCancel={() => {
              clearTempWaypoint();
              setEditingWaypoint(null);
            }}
            isLoading={createWaypoint.isPending || updateWaypointMutation.isPending}
          />
        </DialogContent>
      </Dialog>
    </section>
  );
}
