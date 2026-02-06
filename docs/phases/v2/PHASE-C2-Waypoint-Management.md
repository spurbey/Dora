# **PHASE C2: Waypoint Management - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** C2  
**Duration:** 4 days  
**Dependencies:** Phase C1 (Route Drawing)  
**Goal:** Add, edit, and manage waypoints along routes

---

## **🎯 Objectives**

**Primary Goal:**  
User can add intermediate waypoints to routes, creating custom paths with stops/notes.

**What Success Looks Like:**
- Click existing route → enters waypoint mode
- Click on route line → adds waypoint at that position
- Waypoints recalculate route (A → waypoint → B)
- Waypoints can have names, notes, and types
- Drag waypoints to adjust route path
- Delete waypoints to simplify route

---

## **🏗️ Architecture Overview**

### **Waypoint Flow:**

```
User clicks existing route
    ↓
Route selected (highlighted)
    ↓
User clicks "Add Waypoint" OR clicks on route line
    ↓
Waypoint marker added at click position
    ↓
Route recalculated: A → waypoint → B
    ↓
User adds name/notes to waypoint
    ↓
POST /api/v1/routes/{route_id}/waypoints
    ↓
Waypoint saved to DB
    ↓
Route updated with new geometry
```

### **State Flow:**

```
editorStore.selectedRoute = route
    ↓
editorStore.editMode = 'add-waypoint'
    ↓
User clicks on route line
    ↓
editorStore.tempWaypoint = { lat, lng, route_id }
    ↓
Recalculate route with waypoint
    ↓
User confirms
    ↓
POST to backend
    ↓
editorStore.waypoints.push(newWaypoint)
    ↓
editorStore.routes.update(route with new geometry)
```

---

## **📁 File Structure**

```
frontend/src/
├── components/Editor/
│   ├── WaypointMarker.tsx         (NEW - Custom waypoint marker)
│   ├── WaypointForm.tsx           (NEW - Add/edit waypoint details)
│   ├── WaypointPanel.tsx          (NEW - Shows waypoint info)
│   └── CenterMap.tsx              (UPDATE - Waypoint interactions)
├── services/
│   └── waypointService.ts         (NEW - Backend API calls)
├── hooks/
│   ├── useWaypoints.ts            (NEW - React Query hooks)
│   └── useWaypointManagement.ts   (NEW - Waypoint editing logic)
├── store/
│   └── editorStore.ts             (UPDATE - Waypoint state)
└── types/
    └── waypoint.ts                (NEW - Waypoint types)
```

---

## **🔧 Implementation Specification**

### **1. TypeScript Types**

**src/types/waypoint.ts:**

```typescript
export interface Waypoint {
  id: string;
  route_id: string;
  trip_id: string;
  user_id: string;
  lat: number;
  lng: number;
  name: string;
  waypoint_type: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string;
  order_in_route: number;
  stopped_at?: string;
  created_at: string;
}

export interface WaypointCreate {
  lat: number;
  lng: number;
  name: string;
  waypoint_type: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string;
  order_in_route: number;
  stopped_at?: string;
}

export interface WaypointUpdate {
  name?: string;
  waypoint_type?: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string;
  lat?: number;
  lng?: number;
  order_in_route?: number;
}

export interface TempWaypoint {
  lat: number;
  lng: number;
  route_id: string;
  insertIndex: number;  // Where in route to insert
}
```

---

### **2. Waypoint Service (Backend API)**

**src/services/waypointService.ts:**

```typescript
import api from './api';
import type { Waypoint, WaypointCreate, WaypointUpdate } from '@/types/waypoint';

export const waypointService = {
  /**
   * Get all waypoints for a route
   */
  async getWaypoints(routeId: string): Promise<Waypoint[]> {
    const response = await api.get(`/routes/${routeId}/waypoints`);
    return response.waypoints || [];
  },
  
  /**
   * Create a waypoint
   */
  async createWaypoint(
    routeId: string, 
    data: WaypointCreate
  ): Promise<Waypoint> {
    return api.post(`/routes/${routeId}/waypoints`, data);
  },
  
  /**
   * Update a waypoint
   */
  async updateWaypoint(
    waypointId: string, 
    data: WaypointUpdate
  ): Promise<Waypoint> {
    return api.patch(`/waypoints/${waypointId}`, data);
  },
  
  /**
   * Delete a waypoint
   */
  async deleteWaypoint(waypointId: string): Promise<void> {
    return api.delete(`/waypoints/${waypointId}`);
  },
};
```

---

### **3. React Query Hooks**

**src/hooks/useWaypoints.ts:**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { waypointService } from '@/services/waypointService';
import type { WaypointCreate, WaypointUpdate } from '@/types/waypoint';
import { useToast } from '@/components/ui/use-toast';

/**
 * Fetch waypoints for a route
 */
export function useWaypoints(routeId: string) {
  return useQuery({
    queryKey: ['waypoints', routeId],
    queryFn: () => waypointService.getWaypoints(routeId),
    enabled: !!routeId,
  });
}

/**
 * Create waypoint mutation
 */
export function useCreateWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  
  return useMutation({
    mutationFn: (data: WaypointCreate) => 
      waypointService.createWaypoint(routeId, data),
    
    onSuccess: (newWaypoint) => {
      queryClient.invalidateQueries(['waypoints', routeId]);
      
      toast({
        title: 'Waypoint added',
        description: `${newWaypoint.name} added to route`,
      });
    },
    
    onError: (error: any) => {
      toast({
        title: 'Failed to add waypoint',
        description: error.response?.data?.detail || 'Unknown error',
        variant: 'destructive',
      });
    },
  });
}

/**
 * Update waypoint mutation
 */
export function useUpdateWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: WaypointUpdate }) =>
      waypointService.updateWaypoint(id, data),
    
    onSuccess: () => {
      queryClient.invalidateQueries(['waypoints', routeId]);
      toast({ title: 'Waypoint updated' });
    },
  });
}

/**
 * Delete waypoint mutation
 */
export function useDeleteWaypoint(routeId: string) {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  
  return useMutation({
    mutationFn: (waypointId: string) => 
      waypointService.deleteWaypoint(waypointId),
    
    onSuccess: () => {
      queryClient.invalidateQueries(['waypoints', routeId]);
      toast({ title: 'Waypoint removed' });
    },
  });
}
```

---

### **4. Waypoint Management Hook**

**src/hooks/useWaypointManagement.ts:**

```typescript
import { useState, useCallback } from 'react';
import { mapboxDirections } from '@/services/mapboxDirections';
import type { Route } from '@/types/route';
import type { Waypoint, TempWaypoint } from '@/types/waypoint';

export function useWaypointManagement() {
  const [tempWaypoint, setTempWaypoint] = useState<TempWaypoint | null>(null);
  const [isRecalculating, setIsRecalculating] = useState(false);
  const [updatedRouteGeometry, setUpdatedRouteGeometry] = 
    useState<GeoJSON.LineString | null>(null);
  
  /**
   * Add a waypoint at a specific position on route
   */
  const addWaypointAtPosition = useCallback(async (
    route: Route,
    waypoints: Waypoint[],
    lat: number,
    lng: number
  ) => {
    // Determine insert position
    // For simplicity: add at end of waypoint list
    const insertIndex = waypoints.length;
    
    setTempWaypoint({
      lat,
      lng,
      route_id: route.id,
      insertIndex,
    });
    
    // Recalculate route with new waypoint
    await recalculateRoute(route, waypoints, { lat, lng, insertIndex });
  }, []);
  
  /**
   * Recalculate route with waypoints included
   */
  const recalculateRoute = useCallback(async (
    route: Route,
    existingWaypoints: Waypoint[],
    newWaypoint?: { lat: number; lng: number; insertIndex: number }
  ) => {
    setIsRecalculating(true);
    
    try {
      // Extract start/end from route
      const coords = route.route_geojson.coordinates;
      const start = coords[0];
      const end = coords[coords.length - 1];
      
      // Build waypoint list
      let allWaypoints = [...existingWaypoints];
      
      if (newWaypoint) {
        allWaypoints.splice(newWaypoint.insertIndex, 0, {
          lat: newWaypoint.lat,
          lng: newWaypoint.lng,
        } as any);
      }
      
      // Sort by order_in_route
      allWaypoints.sort((a, b) => a.order_in_route - b.order_in_route);
      
      // Build coordinate array: start → waypoints → end
      const coordinates: Array<[number, number]> = [
        start as [number, number],
        ...allWaypoints.map(w => [w.lng, w.lat] as [number, number]),
        end as [number, number],
      ];
      
      // Call Mapbox Directions
      const profile = route.transport_mode === 'car' ? 'driving' :
                     route.transport_mode === 'bike' ? 'cycling' : 'walking';
      
      const result = await mapboxDirections.getRoute(coordinates, profile);
      
      setUpdatedRouteGeometry(result.geojson);
      
    } catch (error) {
      console.error('Failed to recalculate route:', error);
    } finally {
      setIsRecalculating(false);
    }
  }, []);
  
  /**
   * Clear temp waypoint
   */
  const clearTempWaypoint = useCallback(() => {
    setTempWaypoint(null);
    setUpdatedRouteGeometry(null);
  }, []);
  
  return {
    tempWaypoint,
    isRecalculating,
    updatedRouteGeometry,
    addWaypointAtPosition,
    recalculateRoute,
    clearTempWaypoint,
  };
}
```

---

### **5. Update Editor Store**

**src/store/editorStore.ts (UPDATE):**

```typescript
interface EditorState {
  // ... existing fields
  
  // NEW: Waypoint state
  selectedRoute: Route | null;
  waypoints: Record<string, Waypoint[]>;  // keyed by route_id
  tempWaypoint: TempWaypoint | null;
  
  // NEW: Actions
  setSelectedRoute: (route: Route | null) => void;
  setWaypoints: (routeId: string, waypoints: Waypoint[]) => void;
  setTempWaypoint: (waypoint: TempWaypoint | null) => void;
  addWaypoint: (waypoint: Waypoint) => void;
  updateWaypoint: (waypoint: Waypoint) => void;
  removeWaypoint: (waypointId: string, routeId: string) => void;
}

export const useEditorStore = create<EditorState>()(
  devtools(
    immer((set) => ({
      // ... existing state
      
      selectedRoute: null,
      waypoints: {},
      tempWaypoint: null,
      
      setSelectedRoute: (route) => set({ selectedRoute: route }),
      
      setWaypoints: (routeId, waypoints) => set((state) => {
        state.waypoints[routeId] = waypoints;
      }),
      
      setTempWaypoint: (waypoint) => set({ tempWaypoint: waypoint }),
      
      addWaypoint: (waypoint) => set((state) => {
        if (!state.waypoints[waypoint.route_id]) {
          state.waypoints[waypoint.route_id] = [];
        }
        state.waypoints[waypoint.route_id].push(waypoint);
      }),
      
      updateWaypoint: (waypoint) => set((state) => {
        const routeWaypoints = state.waypoints[waypoint.route_id];
        if (routeWaypoints) {
          const idx = routeWaypoints.findIndex(w => w.id === waypoint.id);
          if (idx !== -1) {
            routeWaypoints[idx] = waypoint;
          }
        }
      }),
      
      removeWaypoint: (waypointId, routeId) => set((state) => {
        state.waypoints[routeId] = state.waypoints[routeId]?.filter(
          w => w.id !== waypointId
        ) || [];
      }),
    }))
  )
);
```

---

### **6. Waypoint Marker Component**

**src/components/Editor/WaypointMarker.tsx (NEW):**

```typescript
import { useRef, useEffect } from 'react';
import mapboxgl from 'mapbox-gl';
import { MapPin, Camera, StickyNote, Flag } from 'lucide-react';
import type { Waypoint } from '@/types/waypoint';

interface WaypointMarkerProps {
  waypoint: Waypoint;
  map: mapboxgl.Map;
  onClick?: (waypoint: Waypoint) => void;
  onDrag?: (waypoint: Waypoint, newLat: number, newLng: number) => void;
}

export function WaypointMarker({ 
  waypoint, 
  map, 
  onClick,
  onDrag 
}: WaypointMarkerProps) {
  const markerRef = useRef<mapboxgl.Marker | null>(null);
  
  useEffect(() => {
    // Create custom marker element
    const el = document.createElement('div');
    el.className = 'waypoint-marker';
    
    // Icon based on type
    const IconComponent = 
      waypoint.waypoint_type === 'stop' ? MapPin :
      waypoint.waypoint_type === 'photo' ? Camera :
      waypoint.waypoint_type === 'note' ? StickyNote : Flag;
    
    el.innerHTML = `
      <div class="w-10 h-10 bg-orange-500 rounded-full border-2 border-white shadow-lg flex items-center justify-center cursor-pointer hover:bg-orange-600 transition">
        ${/* Icon SVG */}
      </div>
    `;
    
    // Create marker
    const marker = new mapboxgl.Marker({
      element: el,
      draggable: true,
    })
      .setLngLat([waypoint.lng, waypoint.lat])
      .addTo(map);
    
    // Click handler
    el.addEventListener('click', () => {
      onClick?.(waypoint);
    });
    
    // Drag handler
    marker.on('dragend', () => {
      const lngLat = marker.getLngLat();
      onDrag?.(waypoint, lngLat.lat, lngLat.lng);
    });
    
    markerRef.current = marker;
    
    return () => {
      marker.remove();
    };
  }, [waypoint, map, onClick, onDrag]);
  
  return null;
}
```

---

### **7. Waypoint Form Component**

**src/components/Editor/WaypointForm.tsx (NEW):**

```typescript
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import type { WaypointCreate } from '@/types/waypoint';

interface WaypointFormProps {
  initialData?: Partial<WaypointCreate>;
  onSubmit: (data: WaypointCreate) => void;
  onCancel: () => void;
  isLoading?: boolean;
}

export function WaypointForm({
  initialData = {},
  onSubmit,
  onCancel,
  isLoading = false,
}: WaypointFormProps) {
  const [formData, setFormData] = useState<WaypointCreate>({
    lat: initialData.lat || 0,
    lng: initialData.lng || 0,
    name: initialData.name || '',
    waypoint_type: initialData.waypoint_type || 'stop',
    notes: initialData.notes || '',
    order_in_route: initialData.order_in_route || 0,
  });
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };
  
  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <Label htmlFor="name">Waypoint Name</Label>
        <Input
          id="name"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          placeholder="e.g., Gas station, Viewpoint"
          required
        />
      </div>
      
      <div>
        <Label htmlFor="type">Type</Label>
        <Select
          value={formData.waypoint_type}
          onValueChange={(value: any) => 
            setFormData({ ...formData, waypoint_type: value })
          }
        >
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="stop">Stop</SelectItem>
            <SelectItem value="photo">Photo Spot</SelectItem>
            <SelectItem value="note">Note</SelectItem>
            <SelectItem value="poi">Point of Interest</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      <div>
        <Label htmlFor="notes">Notes (Optional)</Label>
        <Textarea
          id="notes"
          value={formData.notes}
          onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
          placeholder="Add any notes about this waypoint..."
          rows={3}
        />
      </div>
      
      <div className="flex gap-2">
        <Button type="submit" disabled={isLoading} className="flex-1">
          {isLoading ? 'Saving...' : 'Save Waypoint'}
        </Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
```

---

### **8. Waypoint Panel Component**

**src/components/Editor/WaypointPanel.tsx (NEW):**

```typescript
import { X, Edit, Trash } from 'lucide-react';
import { Button } from '@/components/ui/button';
import type { Waypoint } from '@/types/waypoint';

interface WaypointPanelProps {
  waypoint: Waypoint;
  onEdit: () => void;
  onDelete: () => void;
  onClose: () => void;
}

export function WaypointPanel({
  waypoint,
  onEdit,
  onDelete,
  onClose,
}: WaypointPanelProps) {
  return (
    <div className="absolute top-20 right-4 bg-white rounded-lg shadow-xl p-4 w-80 max-h-96 overflow-y-auto">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-semibold text-lg">{waypoint.name}</h3>
          <p className="text-sm text-gray-500 capitalize">
            {waypoint.waypoint_type}
          </p>
        </div>
        <Button variant="ghost" size="icon" onClick={onClose}>
          <X className="w-4 h-4" />
        </Button>
      </div>
      
      {waypoint.notes && (
        <div className="mb-4">
          <p className="text-sm text-gray-700">{waypoint.notes}</p>
        </div>
      )}
      
      <div className="text-xs text-gray-500 mb-4">
        <div>Lat: {waypoint.lat.toFixed(6)}</div>
        <div>Lng: {waypoint.lng.toFixed(6)}</div>
      </div>
      
      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={onEdit} className="flex-1">
          <Edit className="w-3 h-3 mr-1" />
          Edit
        </Button>
        <Button size="sm" variant="destructive" onClick={onDelete}>
          <Trash className="w-3 h-3 mr-1" />
          Delete
        </Button>
      </div>
    </div>
  );
}
```

---

### **9. Update Map Canvas**

**src/components/Editor/CenterMap.tsx (UPDATE):**

```typescript
import { useState } from 'react';
import { WaypointMarker } from './WaypointMarker';
import { WaypointPanel } from './WaypointPanel';
import { WaypointForm } from './WaypointForm';
import { useWaypoints, useCreateWaypoint, useUpdateWaypoint, useDeleteWaypoint } from '@/hooks/useWaypoints';
import { useWaypointManagement } from '@/hooks/useWaypointManagement';
import { useEditorStore } from '@/store/editorStore';
import { Dialog, DialogContent } from '@/components/ui/dialog';

export function CenterMap() {
  const { selectedRoute, editMode } = useEditorStore();
  const [selectedWaypoint, setSelectedWaypoint] = useState<Waypoint | null>(null);
  const [editingWaypoint, setEditingWaypoint] = useState<Waypoint | null>(null);
  
  const { data: waypoints = [] } = useWaypoints(selectedRoute?.id || '');
  const createWaypoint = useCreateWaypoint(selectedRoute?.id || '');
  const updateWaypoint = useUpdateWaypoint(selectedRoute?.id || '');
  const deleteWaypoint = useDeleteWaypoint(selectedRoute?.id || '');
  
  const { 
    tempWaypoint, 
    addWaypointAtPosition, 
    clearTempWaypoint 
  } = useWaypointManagement();
  
  // ... existing map setup code
  
  // Handle click on route line to add waypoint
  useEffect(() => {
    if (!map.current || !selectedRoute || editMode !== 'add-waypoint') return;
    
    const handleRouteClick = (e: mapboxgl.MapMouseEvent) => {
      const features = map.current!.queryRenderedFeatures(e.point, {
        layers: [`route-${selectedRoute.id}`],
      });
      
      if (features.length > 0) {
        addWaypointAtPosition(
          selectedRoute,
          waypoints,
          e.lngLat.lat,
          e.lngLat.lng
        );
      }
    };
    
    map.current.on('click', handleRouteClick);
    
    return () => {
      map.current?.off('click', handleRouteClick);
    };
  }, [selectedRoute, waypoints, editMode, addWaypointAtPosition]);
  
  // Render waypoint markers
  const waypointMarkers = waypoints.map(waypoint => (
    <WaypointMarker
      key={waypoint.id}
      waypoint={waypoint}
      map={map.current!}
      onClick={(w) => setSelectedWaypoint(w)}
      onDrag={(w, newLat, newLng) => {
        updateWaypoint.mutate({
          id: w.id,
          data: { lat: newLat, lng: newLng },
        });
      }}
    />
  ));
  
  // Handle save temp waypoint
  const handleSaveTempWaypoint = (data: WaypointCreate) => {
    if (!tempWaypoint) return;
    
    createWaypoint.mutate({
      ...data,
      lat: tempWaypoint.lat,
      lng: tempWaypoint.lng,
      order_in_route: tempWaypoint.insertIndex,
    });
    
    clearTempWaypoint();
  };
  
  return (
    <div className="relative w-full h-full">
      <div ref={mapContainer} className="w-full h-full" />
      
      {/* Render waypoint markers */}
      {map.current && waypointMarkers}
      
      {/* Waypoint panel (when waypoint selected) */}
      {selectedWaypoint && (
        <WaypointPanel
          waypoint={selectedWaypoint}
          onEdit={() => {
            setEditingWaypoint(selectedWaypoint);
            setSelectedWaypoint(null);
          }}
          onDelete={() => {
            deleteWaypoint.mutate(selectedWaypoint.id);
            setSelectedWaypoint(null);
          }}
          onClose={() => setSelectedWaypoint(null)}
        />
      )}
      
      {/* Waypoint form dialog (temp waypoint or editing) */}
      <Dialog 
        open={!!tempWaypoint || !!editingWaypoint}
        onOpenChange={(open) => {
          if (!open) {
            clearTempWaypoint();
            setEditingWaypoint(null);
          }
        }}
      >
        <DialogContent>
          <WaypointForm
            initialData={editingWaypoint || tempWaypoint || undefined}
            onSubmit={(data) => {
              if (editingWaypoint) {
                updateWaypoint.mutate({
                  id: editingWaypoint.id,
                  data,
                });
                setEditingWaypoint(null);
              } else {
                handleSaveTempWaypoint(data);
              }
            }}
            onCancel={() => {
              clearTempWaypoint();
              setEditingWaypoint(null);
            }}
            isLoading={createWaypoint.isPending || updateWaypoint.isPending}
          />
        </DialogContent>
      </Dialog>
    </div>
  );
}
```

---

### **10. Update Right Toolbar**

**src/components/Editor/RightToolbar.tsx (UPDATE):**

```typescript
import { MapPin } from 'lucide-react';

export function RightToolbar() {
  const { editMode, setEditMode, selectedRoute } = useEditorStore();
  
  const isWaypointMode = editMode === 'add-waypoint';
  
  return (
    <div className="w-20 bg-white border-l border-gray-200 flex flex-col items-center py-4 space-y-4">
      
      {/* ... existing route button */}
      
      {/* Waypoint button (visible when route selected) */}
      {selectedRoute && (
        <Button
          variant={isWaypointMode ? 'default' : 'outline'}
          size="icon"
          className="w-14 h-14"
          onClick={() => {
            setEditMode(isWaypointMode ? 'view' : 'add-waypoint');
          }}
          title="Add Waypoint"
        >
          <MapPin className="w-6 h-6" />
        </Button>
      )}
    </div>
  );
}
```

---

## **✅ Success Criteria**

### **User Flow:**
- [ ] Click route → route highlighted, waypoint button appears
- [ ] Click "Add Waypoint" → cursor changes, can click on route
- [ ] Click on route line → waypoint marker appears
- [ ] Form opens → enter name/type/notes
- [ ] Click "Save" → waypoint saved, route recalculated
- [ ] Waypoint appears on map
- [ ] Drag waypoint → route updates
- [ ] Click waypoint → panel shows details
- [ ] Delete waypoint → route recalculated without it

### **Technical:**
- [ ] POST /routes/{id}/waypoints returns 201
- [ ] Route geometry updated with waypoints
- [ ] Waypoints ordered correctly
- [ ] Mapbox Directions called with waypoints
- [ ] Drag updates waypoint position in DB

### **Visual:**
- [ ] Waypoint markers distinct from place markers (orange vs blue)
- [ ] Draggable markers work smoothly
- [ ] Route recalculates during drag
- [ ] Panel styled correctly
- [ ] Form validation works

---

## **🧪 Test Cases**

**Manual Testing:**
```
1. Draw a route (Phase C1)
2. Click the route → waypoint button appears
3. Click "Add Waypoint"
4. Click on route line → marker appears
5. Fill form: "Gas Station", type: "Stop"
6. Save → waypoint appears, route updates
7. Drag waypoint → route recalculates
8. Click waypoint → panel opens
9. Edit → change name
10. Delete → waypoint removed, route simplified
```

---

## **⚠️ Common Pitfalls**

### **1. Route Recalculation Performance**
```typescript
// ❌ WRONG - Recalculate on every drag event
marker.on('drag', recalculate);

// ✅ CORRECT - Recalculate on drag end
marker.on('dragend', recalculate);
```

### **2. Waypoint Ordering**
```typescript
// ✅ Always sort waypoints before building coordinate array
const sorted = waypoints.sort((a, b) => a.order_in_route - b.order_in_route);
const coords = [start, ...sorted.map(w => [w.lng, w.lat]), end];
```### **3. Marker Cleanup**
```typescript
// Store marker refs
const markerRefs = useRef<Map<string, mapboxgl.Marker>>(new Map());

// Clean up on unmount
useEffect(() => {
  return () => {
    markerRefs.current.forEach(m => m.remove());
  };
}, []);
```

---

## **📦 Deliverables**

1. 1 Waypoint service (waypointService.ts)
2. 3 Hooks (useWaypoints, useWaypointManagement, queries)
3. 3 Components (WaypointMarker, WaypointForm, WaypointPanel)
4. Updated map component (waypoint interactions)
5. Updated toolbar (waypoint button)
6. Updated store (waypoint state)
7. Updated types (waypoint.ts)

**LOC Estimate:** ~700 LOC

---

**END OF PHASE C2 PRD**

**Next:** Phase C3 (Route Metadata UI)

---

**Ready for AI Agent? START C2.**