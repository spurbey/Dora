# **PHASE C1: Route Drawing Tools - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** C1  
**Duration:** 5 days  
**Dependencies:** Phase A2 (Backend Routes), Phase B (Editor Shell)  
**Goal:** Enable users to draw routes on map and save to backend

---

## **🎯 Objectives**

**Primary Goal:**  
User can draw a route on the map, preview it snapped to roads, and save it to their trip.

**What Success Looks Like:**
- Click "Add Route" button → map enters drawing mode
- Click points on map → route auto-snaps to roads via Mapbox Directions
- Preview route shows distance + duration
- Click "Save Route" → route saved to backend
- Route appears in trip data (visible on map)

---

## **🏗️ Architecture Overview**

### **Route Drawing Flow:**

```
User clicks "Add Route" button
    ↓
Editor enters drawing mode (editMode: 'draw-route')
    ↓
User clicks point A on map
    ↓
User clicks point B on map
    ↓
Call Mapbox Directions API (A → B)
    ↓
Display route preview (blue line)
    ↓
Show distance, duration in sidebar
    ↓
User clicks "Save Route"
    ↓
POST /api/v1/trips/{trip_id}/routes
    ↓
Route saved to DB
    ↓
Editor exits drawing mode
    ↓
Route appears on map (permanent)
```

### **State Flow:**

```
editorStore.editMode = 'draw-route'
    ↓
editorStore.tempRoute = { points: [...], preview: {...} }
    ↓
User confirms
    ↓
POST to backend
    ↓
editorStore.routes.push(newRoute)
    ↓
editorStore.editMode = 'view'
    ↓
editorStore.tempRoute = null
```

---

## **📁 File Structure**

```
frontend/src/
├── components/Editor/
│   ├── RightToolbar.tsx           (UPDATE - Add route button)
│   ├── CenterMap.tsx              (UPDATE - Drawing mode)
│   ├── RouteDrawer.tsx            (NEW - Drawing UI overlay)
│   └── RoutePreviewPanel.tsx      (NEW - Shows preview details)
├── services/
│   ├── routeService.ts            (NEW - Backend API calls)
│   └── mapboxDirections.ts        (NEW - Mapbox Directions API)
├── hooks/
│   ├── useRouteDrawing.ts         (NEW - Drawing state logic)
│   └── useCreateRoute.ts          (NEW - React Query mutation)
├── store/
│   └── editorStore.ts             (UPDATE - Add drawing state)
└── types/
    └── route.ts                   (NEW - Route types)
```

---

## **🔧 Implementation Specification**

### **1. TypeScript Types**

**src/types/route.ts:**

```typescript
export interface Route {
  id: string;
  trip_id: string;
  user_id: string;
  route_geojson: GeoJSON.LineString;
  polyline_encoded?: string;
  start_place_id?: string;
  end_place_id?: string;
  transport_mode: 'car' | 'bike' | 'foot' | 'air' | 'bus' | 'train';
  route_category: 'ground' | 'air';
  distance_km?: number;
  duration_mins?: number;
  order_in_trip: number;
  name?: string;
  description?: string;
  created_at: string;
  updated_at: string;
}

export interface RouteCreate {
  route_geojson: GeoJSON.LineString;
  transport_mode: 'car' | 'bike' | 'foot' | 'air' | 'bus' | 'train';
  route_category: 'ground' | 'air';
  start_place_id?: string;
  end_place_id?: string;
  name?: string;
  description?: string;
  order_in_trip: number;
}

export interface TempRoute {
  points: Array<{ lng: number; lat: number }>;
  preview?: {
    geojson: GeoJSON.LineString;
    distance_km: number;
    duration_mins: number;
  };
  transport_mode: 'car' | 'bike' | 'foot';
}

export interface MapboxDirectionsResponse {
  routes: Array<{
    geometry: GeoJSON.LineString;
    distance: number;  // meters
    duration: number;  // seconds
  }>;
}
```

---

### **2. Mapbox Directions Service**

**src/services/mapboxDirections.ts:**

```typescript
import axios from 'axios';

const MAPBOX_API_URL = 'https://api.mapbox.com/directions/v5/mapbox';
const MAPBOX_TOKEN = import.meta.env.VITE_MAPBOX_TOKEN;

export class MapboxDirectionsService {
  /**
   * Get route between multiple points
   * 
   * @param coordinates - Array of [lng, lat] pairs
   * @param profile - 'driving', 'walking', 'cycling'
   * @returns Route geometry + metadata
   */
  async getRoute(
    coordinates: Array<[number, number]>,
    profile: 'driving' | 'walking' | 'cycling' = 'driving'
  ): Promise<{
    geojson: GeoJSON.LineString;
    distance_km: number;
    duration_mins: number;
  }> {
    // Format: lng,lat;lng,lat;lng,lat
    const coords = coordinates.map(c => `${c[0]},${c[1]}`).join(';');
    
    const url = `${MAPBOX_API_URL}/${profile}/${coords}`;
    
    const response = await axios.get(url, {
      params: {
        access_token: MAPBOX_TOKEN,
        geometries: 'geojson',
        overview: 'full',
      },
    });
    
    const route = response.data.routes[0];
    
    return {
      geojson: route.geometry,
      distance_km: route.distance / 1000,
      duration_mins: Math.round(route.duration / 60),
    };
  }
}

export const mapboxDirections = new MapboxDirectionsService();
```

**Key Points:**
- Uses Mapbox Directions API v5
- Supports driving/walking/cycling profiles
- Returns GeoJSON LineString
- Converts meters → km, seconds → minutes

---

### **3. Route Service (Backend API)**

**src/services/routeService.ts:**

```typescript
import api from './api';
import type { Route, RouteCreate } from '@/types/route';

export const routeService = {
  /**
   * Create a new route for a trip
   */
  async createRoute(tripId: string, data: RouteCreate): Promise<Route> {
    return api.post(`/trips/${tripId}/routes`, data);
  },
  
  /**
   * Get all routes for a trip
   */
  async getRoutes(tripId: string): Promise<Route[]> {
    const response = await api.get(`/trips/${tripId}/routes`);
    return response.routes || [];
  },
  
  /**
   * Update a route
   */
  async updateRoute(routeId: string, data: Partial<RouteCreate>): Promise<Route> {
    return api.patch(`/routes/${routeId}`, data);
  },
  
  /**
   * Delete a route
   */
  async deleteRoute(routeId: string): Promise<void> {
    return api.delete(`/routes/${routeId}`);
  },
};
```

---

### **4. React Query Hooks**

**src/hooks/useCreateRoute.ts:**

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { routeService } from '@/services/routeService';
import type { RouteCreate } from '@/types/route';
import { useToast } from '@/components/ui/use-toast';

export function useCreateRoute(tripId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  
  return useMutation({
    mutationFn: (data: RouteCreate) => routeService.createRoute(tripId, data),
    
    onSuccess: (newRoute) => {
      // Invalidate components query (refetch timeline)
      queryClient.invalidateQueries(['editor-components', tripId]);
      
      toast({
        title: 'Route saved',
        description: `${newRoute.distance_km?.toFixed(1)} km route added`,
      });
    },
    
    onError: (error: any) => {
      toast({
        title: 'Failed to save route',
        description: error.response?.data?.detail || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}
```

---

### **5. Route Drawing Hook**

**src/hooks/useRouteDrawing.ts:**

```typescript
import { useState, useCallback } from 'react';
import { mapboxDirections } from '@/services/mapboxDirections';
import type { TempRoute } from '@/types/route';

export function useRouteDrawing() {
  const [tempRoute, setTempRoute] = useState<TempRoute | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  
  /**
   * Add a point to the route being drawn
   */
  const addPoint = useCallback(async (
    lng: number, 
    lat: number,
    transportMode: 'car' | 'bike' | 'foot' = 'car'
  ) => {
    const newPoint = { lng, lat };
    
    setTempRoute(prev => {
      const points = prev ? [...prev.points, newPoint] : [newPoint];
      return { points, transport_mode: transportMode };
    });
    
    // If we have 2+ points, fetch route preview
    if (tempRoute && tempRoute.points.length >= 1) {
      setIsLoading(true);
      
      try {
        const coordinates: Array<[number, number]> = [
          ...tempRoute.points.map(p => [p.lng, p.lat] as [number, number]),
          [lng, lat],
        ];
        
        const profile = transportMode === 'car' ? 'driving' : 
                       transportMode === 'bike' ? 'cycling' : 'walking';
        
        const routeData = await mapboxDirections.getRoute(coordinates, profile);
        
        setTempRoute(prev => ({
          ...prev!,
          preview: routeData,
        }));
      } catch (error) {
        console.error('Failed to fetch route:', error);
      } finally {
        setIsLoading(false);
      }
    }
  }, [tempRoute]);
  
  /**
   * Clear the current drawing
   */
  const clearRoute = useCallback(() => {
    setTempRoute(null);
  }, []);
  
  /**
   * Remove last point
   */
  const undoLastPoint = useCallback(() => {
    setTempRoute(prev => {
      if (!prev || prev.points.length === 0) return null;
      
      const points = prev.points.slice(0, -1);
      return points.length > 0 ? { points, transport_mode: prev.transport_mode } : null;
    });
  }, []);
  
  return {
    tempRoute,
    isLoading,
    addPoint,
    clearRoute,
    undoLastPoint,
  };
}
```

---

### **6. Update Editor Store**

**src/store/editorStore.ts (UPDATE):**

```typescript
interface EditorState {
  // ... existing fields
  
  // NEW: Route drawing state
  editMode: 'view' | 'add-place' | 'draw-route' | 'add-waypoint';
  tempRoute: TempRoute | null;
  drawingTransportMode: 'car' | 'bike' | 'foot';
  
  // NEW: Actions
  setEditMode: (mode: EditorState['editMode']) => void;
  setTempRoute: (route: TempRoute | null) => void;
  setDrawingTransportMode: (mode: 'car' | 'bike' | 'foot') => void;
}

export const useEditorStore = create<EditorState>()(
  devtools(
    immer((set) => ({
      // ... existing state
      
      editMode: 'view',
      tempRoute: null,
      drawingTransportMode: 'car',
      
      setEditMode: (mode) => set({ editMode: mode }),
      setTempRoute: (route) => set({ tempRoute: route }),
      setDrawingTransportMode: (mode) => set({ drawingTransportMode: mode }),
    }))
  )
);
```

---

### **7. Right Toolbar (Add Route Button)**

**src/components/Editor/RightToolbar.tsx (UPDATE):**

```typescript
import { Car, Bike, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';

export function RightToolbar() {
  const { editMode, setEditMode, drawingTransportMode, setDrawingTransportMode } = 
    useEditorStore();
  
  const isDrawing = editMode === 'draw-route';
  
  return (
    <div className="w-20 bg-white border-l border-gray-200 flex flex-col items-center py-4 space-y-4">
      
      {/* Route Drawing Button */}
      <div className="space-y-2">
        <Button
          variant={isDrawing ? 'default' : 'outline'}
          size="icon"
          className="w-14 h-14"
          onClick={() => {
            if (isDrawing) {
              setEditMode('view');
            } else {
              setEditMode('draw-route');
            }
          }}
        >
          <svg className="w-6 h-6" /* Route icon SVG */>...</svg>
        </Button>
        
        {/* Transport Mode Selector (visible when drawing) */}
        {isDrawing && (
          <div className="flex flex-col space-y-1">
            <Button
              variant={drawingTransportMode === 'car' ? 'default' : 'ghost'}
              size="icon"
              className="w-10 h-10"
              onClick={() => setDrawingTransportMode('car')}
            >
              <Car className="w-4 h-4" />
            </Button>
            
            <Button
              variant={drawingTransportMode === 'bike' ? 'default' : 'ghost'}
              size="icon"
              className="w-10 h-10"
              onClick={() => setDrawingTransportMode('bike')}
            >
              <Bike className="w-4 h-4" />
            </Button>
            
            <Button
              variant={drawingTransportMode === 'foot' ? 'default' : 'ghost'}
              size="icon"
              className="w-10 h-10"
              onClick={() => setDrawingTransportMode('foot')}
            >
              <User className="w-4 h-4" />
            </Button>
          </div>
        )}
      </div>
      
      {/* Other tool buttons (Phase C2/C3) */}
    </div>
  );
}
```

---

### **8. Map Canvas (Drawing Mode)**

**src/components/Editor/CenterMap.tsx (UPDATE):**

```typescript
import { useEffect, useRef } from 'react';
import mapboxgl from 'mapbox-gl';
import { useEditorStore } from '@/store/editorStore';
import { useRouteDrawing } from '@/hooks/useRouteDrawing';

export function CenterMap() {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  
  const { editMode, routes, places, drawingTransportMode } = useEditorStore();
  const { tempRoute, addPoint, isLoading } = useRouteDrawing();
  
  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || map.current) return;
    
    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [0, 0],
      zoom: 2,
    });
    
    return () => map.current?.remove();
  }, []);
  
  // Handle drawing mode clicks
  useEffect(() => {
    if (!map.current) return;
    
    const handleClick = (e: mapboxgl.MapMouseEvent) => {
      if (editMode === 'draw-route') {
        addPoint(e.lngLat.lng, e.lngLat.lat, drawingTransportMode);
      }
    };
    
    if (editMode === 'draw-route') {
      map.current.getCanvas().style.cursor = 'crosshair';
      map.current.on('click', handleClick);
    } else {
      map.current.getCanvas().style.cursor = '';
      map.current.off('click', handleClick);
    }
    
    return () => {
      map.current?.off('click', handleClick);
    };
  }, [editMode, addPoint, drawingTransportMode]);
  
  // Render temp route points
  useEffect(() => {
    if (!map.current || !tempRoute) return;
    
    // Add markers for clicked points
    tempRoute.points.forEach((point, idx) => {
      const el = document.createElement('div');
      el.className = 'w-4 h-4 bg-blue-500 rounded-full border-2 border-white';
      
      new mapboxgl.Marker(el)
        .setLngLat([point.lng, point.lat])
        .addTo(map.current!);
    });
    
    // Clean up markers on unmount
    return () => {
      // Markers auto-removed when map removed
    };
  }, [tempRoute?.points]);
  
  // Render temp route preview line
  useEffect(() => {
    if (!map.current || !tempRoute?.preview) return;
    
    const sourceId = 'temp-route-preview';
    const layerId = 'temp-route-layer';
    
    if (map.current.getSource(sourceId)) {
      (map.current.getSource(sourceId) as mapboxgl.GeoJSONSource).setData(
        tempRoute.preview.geojson
      );
    } else {
      map.current.addSource(sourceId, {
        type: 'geojson',
        data: tempRoute.preview.geojson,
      });
      
      map.current.addLayer({
        id: layerId,
        type: 'line',
        source: sourceId,
        paint: {
          'line-color': '#3b82f6',  // Blue
          'line-width': 4,
          'line-opacity': 0.8,
        },
      });
    }
    
    return () => {
      if (map.current?.getLayer(layerId)) {
        map.current.removeLayer(layerId);
      }
      if (map.current?.getSource(sourceId)) {
        map.current.removeSource(sourceId);
      }
    };
  }, [tempRoute?.preview]);
  
  return (
    <div className="relative w-full h-full">
      <div ref={mapContainer} className="w-full h-full" />
      
      {/* Loading indicator */}
      {isLoading && (
        <div className="absolute top-4 right-4 bg-white px-4 py-2 rounded shadow">
          Calculating route...
        </div>
      )}
    </div>
  );
}
```

---

### **9. Route Preview Panel**

**src/components/Editor/RoutePreviewPanel.tsx (NEW):**

```typescript
import { Check, X, Undo } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';
import { useRouteDrawing } from '@/hooks/useRouteDrawing';
import { useCreateRoute } from '@/hooks/useCreateRoute';

export function RoutePreviewPanel({ tripId }: { tripId: string }) {
  const { editMode, setEditMode, drawingTransportMode, routes } = useEditorStore();
  const { tempRoute, clearRoute, undoLastPoint } = useRouteDrawing();
  const createRoute = useCreateRoute(tripId);
  
  if (editMode !== 'draw-route' || !tempRoute) return null;
  
  const handleSave = async () => {
    if (!tempRoute.preview) return;
    
    const routeData: RouteCreate = {
      route_geojson: tempRoute.preview.geojson,
      transport_mode: drawingTransportMode,
      route_category: 'ground',
      distance_km: tempRoute.preview.distance_km,
      duration_mins: tempRoute.preview.duration_mins,
      order_in_trip: routes.length,  // Add to end
    };
    
    await createRoute.mutateAsync(routeData);
    
    // Exit drawing mode
    clearRoute();
    setEditMode('view');
  };
  
  return (
    <div className="absolute bottom-20 left-1/2 -translate-x-1/2 bg-white rounded-lg shadow-lg p-4 min-w-[300px]">
      <h3 className="font-semibold mb-2">Route Preview</h3>
      
      {tempRoute.preview ? (
        <>
          <div className="space-y-1 text-sm mb-4">
            <div className="flex justify-between">
              <span className="text-gray-600">Distance:</span>
              <span className="font-medium">
                {tempRoute.preview.distance_km.toFixed(1)} km
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Duration:</span>
              <span className="font-medium">
                {tempRoute.preview.duration_mins} mins
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Mode:</span>
              <span className="font-medium capitalize">
                {drawingTransportMode}
              </span>
            </div>
          </div>
          
          <div className="flex gap-2">
            <Button
              size="sm"
              className="flex-1"
              onClick={handleSave}
              disabled={createRoute.isPending}
            >
              <Check className="w-4 h-4 mr-1" />
              Save Route
            </Button>
            
            <Button
              size="sm"
              variant="outline"
              onClick={undoLastPoint}
            >
              <Undo className="w-4 h-4" />
            </Button>
            
            <Button
              size="sm"
              variant="destructive"
              onClick={() => {
                clearRoute();
                setEditMode('view');
              }}
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
        </>
      ) : (
        <p className="text-sm text-gray-600">
          Click {2 - tempRoute.points.length} more point(s) to create route
        </p>
      )}
    </div>
  );
}
```

---

### **10. Integrate into Editor**

**src/pages/TripEditor.tsx (UPDATE):**

```typescript
import { RoutePreviewPanel } from '@/components/Editor/RoutePreviewPanel';

export function TripEditor() {
  const { id } = useParams<{ id: string }>();
  
  return (
    <EditorLayout>
      <TopBar />
      <EditorContent>
        <LeftTimeline />
        <CenterMap />
        <RightToolbar />
      </EditorContent>
      <BottomPanel />
      
      {/* NEW: Route preview (shows when drawing) */}
      {id && <RoutePreviewPanel tripId={id} />}
    </EditorLayout>
  );
}
```

---

## **✅ Success Criteria**

### **User Flow:**
- [ ] Click "Route" button → cursor changes to crosshair
- [ ] Click point A → blue marker appears
- [ ] Click point B → route line appears between A-B
- [ ] Preview panel shows distance + duration
- [ ] Click "Save" → route saved to backend
- [ ] Route appears on map (permanent)
- [ ] Click X → cancel, remove preview

### **Technical:**
- [ ] Mapbox Directions API called correctly
- [ ] Route GeoJSON stored in backend
- [ ] POST /trips/{id}/routes returns 201
- [ ] Components query invalidated (timeline updates)
- [ ] Drawing mode exits after save
- [ ] No console errors

### **Visual:**
- [ ] Blue preview line snaps to roads
- [ ] Markers show clicked points
- [ ] Preview panel styled correctly
- [ ] Loading indicator during API call
- [ ] Toast notification on success

---

## **🧪 Test Cases**

**Manual Testing:**
```
1. Open editor for trip
2. Click "Route" button
3. Click 2 points on map
4. Verify route line appears
5. Verify preview shows distance/duration
6. Click "Save Route"
7. Verify toast "Route saved"
8. Verify route persists on refresh
9. Click "Undo" → last point removed
10. Click "Cancel" → drawing cleared
```

---

## **⚠️ Common Pitfalls**

### **1. Mapbox Coordinates Order**
```typescript
// ❌ WRONG
[lat, lng]

// ✅ CORRECT
[lng, lat]  // Mapbox uses [longitude, latitude]
```

### **2. GeoJSON Format**
```typescript
// ✅ CORRECT
{
  type: 'LineString',
  coordinates: [[lng, lat], [lng, lat], ...]
}
```

### **3. API Token**
```typescript
// Must be in .env
VITE_MAPBOX_TOKEN=pk.your_token_here
```

### **4. Marker Cleanup**
```typescript
// Store marker refs to remove on unmount
const markersRef = useRef<mapboxgl.Marker[]>([]);

useEffect(() => {
  return () => {
    markersRef.current.forEach(m => m.remove());
  };
}, []);
```

---

## **📦 Deliverables**

1. 1 Mapbox service (mapboxDirections.ts)
2. 1 Route service (routeService.ts)
3. 2 Hooks (useRouteDrawing, useCreateRoute)
4. 1 Route preview panel
5. Updated map component (drawing mode)
6. Updated toolbar (route button)
7. Updated types (route.ts)
8. Updated store (drawing state)

**LOC Estimate:** ~600 LOC

---

**END OF PHASE C1 PRD**

**Next:** Phase C2 (Waypoint Management)

---

**Ready for AI Agent? START C1.**