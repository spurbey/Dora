
## **PHASE B: Immersive Editor Shell (Frontend Foundation)**

### **Duration:** 1.5 weeks
### **Goal:** Create editor UI skeleton without breaking V1

---

### **B1: Editor Layout & Navigation (3 days)**

**File:** `phase-b1-editor-layout.md`

**What AI Agent Will Build:**

```typescript
// NEW: src/pages/TripEditor.tsx
export function TripEditor() {
  return (
    <EditorLayout>
      <TopBar />
      <EditorContent>
        <LeftTimeline />
        <CenterMap />
        <RightToolbar />
      </EditorContent>
      <BottomPanel />
    </EditorLayout>
  );
}

// NEW: src/components/Editor/EditorLayout.tsx
// Full-screen layout with 5 panels

// NEW: src/components/Editor/TopBar.tsx
// Search, title, save, share buttons

// NEW: src/components/Editor/LeftTimeline.tsx
// Timeline skeleton (populated in Phase D)

// NEW: src/components/Editor/CenterMap.tsx  
// Map canvas (enhanced in Phase C)

// NEW: src/components/Editor/RightToolbar.tsx
// Tool buttons (functional in Phase C)

// NEW: src/components/Editor/BottomPanel.tsx
// Slidable detail panel
```

**Routing:**
```typescript
// src/App.tsx (UPDATE)

<Route path="/trips/:id/edit" element={<TripEditor />} />
<Route path="/trips/:id" element={<TripDetail />} />  // V1 still works
```

**Navigation Flow:**
```typescript
// src/pages/Dashboard.tsx (UPDATE)

<TripCard
  onEdit={() => navigate(`/trips/${trip.id}/edit`)}  // NEW: Go to editor
  onView={() => navigate(`/trips/${trip.id}`)}       // V1 view
/>
```

**Success Criteria:**
- [ ] Editor route accessible
- [ ] 5-panel layout renders
- [ ] Responsive on desktop (mobile later)
- [ ] V1 detail page still works
- [ ] Navigation between V1/V2 works

---

### **B2: State Management (3 days)**

**File:** `phase-b2-editor-state.md`

**What AI Agent Will Build:**

```typescript
// NEW: src/store/editorStore.ts

interface EditorState {
  // Trip Data
  trip: Trip | null;
  places: Place[];
  routes: Route[];
  waypoints: Waypoint[];
  
  // Timeline Order (unified view)
  timeline: TimelineItem[];  // [{ type: 'place'|'route', id, order }]
  
  // UI State
  selectedItem: { type: string; id: string } | null;
  editMode: 'view' | 'add-place' | 'draw-route' | 'add-waypoint';
  mapViewport: { lat: number; lng: number; zoom: number };
  bottomPanelOpen: boolean;
  
  // Unsaved Changes
  hasUnsavedChanges: boolean;
  isDirty: boolean;
  autoSaveEnabled: boolean;
  lastSavedAt: Date | null;
  
  // Actions
  loadTrip: (tripId: string) => Promise<void>;
  addPlace: (place: Place) => void;
  addRoute: (route: Route) => void;
  updateItem: (type: string, id: string, data: any) => void;
  deleteItem: (type: string, id: string) => void;
  reorderTimeline: (newOrder: TimelineItem[]) => void;
  selectItem: (type: string, id: string) => void;
  setEditMode: (mode: string) => void;
  saveTrip: () => Promise<void>;
  setMapViewport: (viewport: Viewport) => void;
}

export const useEditorStore = create<EditorState>()(
  devtools(
    immer((set, get) => ({
      // ... implementation
    }))
  )
);
```

**React Query Hooks:**
```typescript
// NEW: src/hooks/useEditor.ts

export function useEditorTrip(tripId: string) {
  return useQuery({
    queryKey: ['editor-trip', tripId],
    queryFn: () => api.get(`/trips/${tripId}`),
  });
}

export function useEditorComponents(tripId: string) {
  return useQuery({
    queryKey: ['editor-components', tripId],
    queryFn: () => api.get(`/trips/${tripId}/components`),
  });
}

export function useSaveTrip() {
  return useMutation({
    mutationFn: (data) => api.patch(`/trips/${data.id}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['editor-trip']);
    },
  });
}
```

**Auto-save:**
```typescript
// NEW: src/hooks/useAutoSave.ts

export function useAutoSave(interval = 30000) {
  const { hasUnsavedChanges, saveTrip } = useEditorStore();
  
  useEffect(() => {
    if (!hasUnsavedChanges) return;
    
    const timer = setInterval(() => {
      saveTrip();
    }, interval);
    
    return () => clearInterval(timer);
  }, [hasUnsavedChanges, saveTrip, interval]);
}
```

**Success Criteria:**
- [ ] Store initializes correctly
- [ ] Trip data loads
- [ ] State updates work
- [ ] Auto-save triggers
- [ ] No state conflicts with V1

---

### **B3: Map Canvas Setup (2 days)**

**File:** `phase-b3-map-canvas.md`

**What AI Agent Will Build:**

```typescript
// UPDATE: src/components/Editor/CenterMap.tsx

import mapboxgl from 'mapbox-gl';
import { useEditorStore } from '@/store/editorStore';

export function CenterMap() {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  
  const { places, routes, selectedItem, mapViewport, setMapViewport } = 
    useEditorStore();
  
  // Initialize map
  useEffect(() => {
    if (!mapContainer.current) return;
    
    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [mapViewport.lng, mapViewport.lat],
      zoom: mapViewport.zoom,
    });
    
    map.current.on('move', () => {
      const center = map.current.getCenter();
      const zoom = map.current.getZoom();
      setMapViewport({ lat: center.lat, lng: center.lng, zoom });
    });
    
    return () => map.current?.remove();
  }, []);
  
  // Add place markers
  useEffect(() => {
    if (!map.current) return;
    
    places.forEach(place => {
      new mapboxgl.Marker()
        .setLngLat([place.lng, place.lat])
        .addTo(map.current);
    });
  }, [places]);
  
  // Add route lines (basic)
  useEffect(() => {
    if (!map.current) return;
    
    routes.forEach(route => {
      map.current.addSource(`route-${route.id}`, {
        type: 'geojson',
        data: route.route_geojson,
      });
      
      map.current.addLayer({
        id: `route-${route.id}`,
        type: 'line',
        source: `route-${route.id}`,
        paint: {
          'line-color': '#0891B2',
          'line-width': 3,
        },
      });
    });
  }, [routes]);
  
  return <div ref={mapContainer} className="w-full h-full" />;
}
```

**Success Criteria:**
- [ ] Map renders in editor
- [ ] Places show as markers
- [ ] Routes show as lines
- [ ] Map state syncs with store
- [ ] Viewport persists

---

## **PHASE C: Route Creation System**

### **Duration:** 2 weeks
### **Goal:** Full route drawing and editing
