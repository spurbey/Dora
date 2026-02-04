# Frontend Architecture Documentation

> Auto-generated from codebase exploration. Use this as reference instead of re-exploring.

## Overview

**Stack**: React 18 + Vite + TypeScript + Tailwind CSS + Mapbox GL JS
**Purpose**: Web interface for Travel Memory Vault - trip creation, viewing, and editing.

---

## Application Structure

```
frontend/
├── src/
│   ├── main.tsx              # Entry point
│   ├── App.tsx               # Routing (react-router-dom)
│   ├── components/
│   │   ├── Auth/             # Login, Register, ProtectedRoute
│   │   ├── Trip/             # Trip cards, forms, lists
│   │   ├── Place/            # Place forms, cards, details
│   │   ├── Map/              # MapView (V1)
│   │   ├── Media/            # Photo upload, gallery, lightbox
│   │   ├── Editor/           # V2 immersive editor components
│   │   ├── Shared/           # Spinner, EmptyState, etc.
│   │   └── ui/               # shadcn/ui components
│   ├── pages/
│   │   ├── Login.tsx
│   │   ├── Register.tsx
│   │   ├── Dashboard.tsx     # Trip list
│   │   ├── TripDetail.tsx    # V1 trip view
│   │   └── TripEditor.tsx    # V2 immersive editor
│   ├── hooks/                # React Query hooks
│   ├── services/             # API client services
│   ├── store/                # Zustand stores
│   ├── types/                # TypeScript interfaces
│   ├── lib/                  # Mapbox, Supabase, QueryClient
│   └── utils/                # Helpers, constants, features
├── CLAUDE.md                 # Frontend-specific rules
└── ARCHITECTURE.md           # This file
```

---

## Routing

```typescript
// App.tsx
<Routes>
  <Route path="/login" element={<Login />} />
  <Route path="/register" element={<Register />} />

  <Route element={<ProtectedRoute />}>
    <Route path="/dashboard" element={<Dashboard />} />
    <Route path="/trips/:id" element={<TripDetail />} />
    {FEATURES.EDITOR && <Route path="/trips/:id/edit" element={<TripEditor />} />}
  </Route>

  <Route path="/" element={<Navigate to="/dashboard" />} />
  <Route path="*" element={<Navigate to="/dashboard" />} />
</Routes>
```

**Feature Flag**: `VITE_FEATURE_EDITOR=true` enables `/trips/:id/edit` route

---

## Pages & User Flows

### 1. Authentication Flow
- **Login** (`/login`) - Supabase Auth form
- **Register** (`/register`) - Create new account
- **ProtectedRoute** - Wraps authenticated pages, redirects to login if no token

### 2. Dashboard (`/dashboard`)
- Lists all user trips in grid
- Create new trip button → TripForm dialog
- Edit/Delete actions per trip card
- Trip statistics display
- Empty state for new users

### 3. Trip Detail (`/trips/:id`) - V1
Three-tab view:
- **Timeline Tab**: Ordered list of places
- **Map Tab**: Interactive Mapbox map with markers
- **Photos Tab**: Gallery grid of all trip photos

Features:
- Edit trip via header button → TripForm modal
- Delete trip with confirmation
- Click place marker → sidebar detail view
- Photo lightbox with swipe navigation

### 4. Trip Editor (`/trips/:id/edit`) - V2
Four-panel immersive layout:

```
┌─────────────────────────────────────────────────┐
│           TOP BAR (Save / Exit)                 │
├──────────────┬─────────────────────┬────────────┤
│ LEFT:        │     CENTER:         │   RIGHT:   │
│ Timeline     │     Mapbox GL       │   Toolbar  │
│ (Draggable)  │     (Interactive)   │   Buttons  │
├──────────────┴─────────────────────┴────────────┤
│      BOTTOM PANEL (Context/Details)             │
│      ROUTE PREVIEW PANEL (Overlay)              │
└─────────────────────────────────────────────────┘
```

---

## Key Components

### Auth Components (`components/Auth/`)

| Component | Purpose |
|-----------|---------|
| `LoginForm.tsx` | Email/password login form |
| `RegisterForm.tsx` | Registration form |
| `ProtectedRoute.tsx` | Auth wrapper, redirects if not authenticated |

### Trip Components (`components/Trip/`)

| Component | Purpose |
|-----------|---------|
| `TripCard.tsx` | Card display for dashboard grid |
| `TripForm.tsx` | Create/edit trip modal |
| `TripList.tsx` | Grid container for trips |

### Place Components (`components/Place/`)

| Component | Purpose |
|-----------|---------|
| `PlaceCard.tsx` | Place display in timeline |
| `PlaceForm.tsx` | Create/edit place with search |
| `PlaceDetail.tsx` | Full place details sidebar |
| `PlaceSidebar.tsx` | Slide-out sidebar for selected place |

### Map Components (`components/Map/`)

| Component | Purpose |
|-----------|---------|
| `MapView.tsx` | V1 map with markers (read-only) |

### Media Components (`components/Media/`)

| Component | Purpose |
|-----------|---------|
| `PhotoUpload.tsx` | Upload photo to place |
| `PhotoGallery.tsx` | Grid display of photos |
| `PhotoLightbox.tsx` | Full-screen viewer with swipe |

### Editor Components (`components/Editor/`) - V2

| Component | Purpose |
|-----------|---------|
| `CenterMap.tsx` | Interactive map canvas with drawing |
| `LeftSidebar.tsx` | Timeline panel (drag-drop) |
| `RightToolbar.tsx` | Tool palette buttons |
| `BottomPanel.tsx` | Context panel for selected item |
| `RoutePreviewPanel.tsx` | Route details overlay |
| `TimelineItem.tsx` | Draggable place/route item |
| `RouteMetadataForm.tsx` | Route metadata editing |

---

## State Management

### Auth Store (`store/authStore.ts`)
```typescript
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;
  hydrate: () => void;  // Restore from localStorage
}
```

### Editor Store (`store/editorStore.ts`) - V2
```typescript
interface EditorState {
  // Trip Data
  trip: Trip | null;
  places: Place[];
  routes: Route[];
  waypoints: Record<string, Waypoint[]>;  // routeId -> waypoints
  routeMetadata: Record<string, RouteMetadata>;
  timeline: TimelineItem[];  // Unified places + routes

  // UI State
  selectedItem: { type: 'place' | 'route' | 'waypoint'; id: string } | null;
  selectedItemSource: 'map' | 'timeline' | null;
  highlightedItem: { type: string; id: string } | null;
  selectedRoute: Route | null;
  editMode: 'view' | 'add-place' | 'draw-route' | 'add-waypoint';
  mapViewport: { lat: number; lng: number; zoom: number };
  bottomPanelOpen: boolean;

  // Drawing State
  tempRoute: TempRoute | null;  // Preview while drawing
  drawingTransportMode: 'car' | 'bike' | 'foot';
  tempWaypoint: TempWaypoint | null;

  // Save State
  hasUnsavedChanges: boolean;
  isDirty: boolean;
  autoSaveEnabled: boolean;
  lastSavedAt: Date | null;
}
```

---

## Services (API Clients)

### API Client (`services/api.ts`)
```typescript
// Axios instance with JWT interceptor
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
});

// Request: Adds Authorization header
// Response: Handles 401 with token refresh
```

**Token Refresh**: On 401, attempts Supabase session refresh before redirecting to login.

### Auth Service (`services/authService.ts`)
```typescript
login(email, password): Promise<AuthSession>
register(email, username, password): Promise<AuthSession>
getCurrentUser(): Promise<User>
logout(): Promise<void>
getToken(): string | null
setToken(token: string): void
```

### Trip Service (`services/tripService.ts`)
```typescript
getTrips(page?, pageSize?): Promise<TripListResponse>
getTrip(id): Promise<Trip>
createTrip(data): Promise<Trip>
updateTrip(id, data): Promise<Trip>
deleteTrip(id): Promise<void>
getTripBounds(id): Promise<Bounds | null>
```

### Place Service (`services/placeService.ts`)
```typescript
getPlaces(tripId): Promise<PlaceListResponse>
getPlace(id): Promise<Place>
createPlace(data): Promise<Place>
updatePlace(id, data): Promise<Place>
deletePlace(id): Promise<void>
getNearbyPlaces(lat, lng, radius): Promise<PlaceListResponse>
```

### Media Service (`services/mediaService.ts`)
```typescript
uploadPhoto(file, tripPlaceId, caption?, takenAt?): Promise<MediaFile>
getMedia(id): Promise<MediaFile>
deleteMedia(id): Promise<void>
```

### Search Service (`services/searchService.ts`)
```typescript
searchPlaces(query, lat, lng, radiusKm?, limit?): Promise<SearchResult[]>
```

### Route Service (`services/routeService.ts`)
```typescript
getRoutes(tripId): Promise<RouteListResponse>
getRoute(id): Promise<Route>
createRoute(tripId, data): Promise<Route>
updateRoute(id, data): Promise<Route>
deleteRoute(id): Promise<void>
generateRoute(coordinates, mode): Promise<GeneratedRoute>
```

### Waypoint Service (`services/waypointService.ts`)
```typescript
getWaypoints(routeId): Promise<WaypointListResponse>
createWaypoint(routeId, data): Promise<Waypoint>
updateWaypoint(id, data): Promise<Waypoint>
deleteWaypoint(id): Promise<void>
```

### Mapbox Directions (`services/mapboxDirections.ts`)
```typescript
getDirections(coordinates, mode): Promise<DirectionsResponse>
// Calls Mapbox API directly for route preview
```

---

## React Query Hooks (`hooks/`)

| Hook | Purpose |
|------|---------|
| `useTrips()` | Fetch user's trip list |
| `useTrip(id)` | Fetch single trip |
| `useCreateTrip()` | Create trip mutation |
| `useUpdateTrip()` | Update trip mutation |
| `useDeleteTrip()` | Delete trip mutation |
| `usePlaces(tripId)` | Fetch places for trip |
| `usePlace(placeId)` | Fetch single place |
| `useCreatePlace()` | Create place mutation |
| `useUpdatePlace()` | Update place mutation |
| `useDeletePlace()` | Delete place mutation |
| `useRoutes(tripId)` | Fetch routes for trip |
| `useWaypoints(routeId)` | Fetch waypoints for route |
| `useSearch()` | Search places mutation |
| `useComponents(tripId)` | Fetch unified timeline |
| `useReorderComponents()` | Reorder timeline mutation |

---

## Data Types

### User
```typescript
interface User {
  id: string;
  email: string;
  username: string;
  full_name: string | null;
  avatar_url: string | null;
  bio: string | null;
  is_premium: boolean;
  is_verified: boolean;
  created_at: string;
  updated_at: string;
}
```

### Trip
```typescript
interface Trip {
  id: string;
  user_id: string;
  title: string;
  description: string | null;
  start_date: string | null;  // ISO date
  end_date: string | null;    // ISO date
  cover_photo_url: string | null;
  visibility: 'private' | 'unlisted' | 'public';
  views_count: number;
  saves_count: number;
  created_at: string;
  updated_at: string;
}
```

### Place
```typescript
interface Place {
  id: string;
  trip_id: string;
  user_id: string;
  name: string;
  lat: number;            // -90 to 90
  lng: number;            // -180 to 180
  place_type: string | null;
  user_notes: string | null;
  photos: MediaFile[];
  external_place_id: string | null;
  order_in_trip: number | null;
  created_at: string;
  updated_at: string;
}
```

### Route
```typescript
interface Route {
  id: string;
  trip_id: string;
  user_id: string;
  name: string | null;
  description: string | null;
  transport_mode: 'car' | 'bike' | 'foot' | 'air' | 'bus' | 'train';
  route_category: 'ground' | 'air';
  start_place_id: string | null;
  end_place_id: string | null;
  route_geojson: GeoJSON.Geometry | GeoJSON.FeatureCollection;
  polyline_encoded: string | null;
  distance_km: number | null;
  duration_mins: number | null;
  order_in_trip: number;
  created_at: string;
  updated_at: string;
}
```

### Waypoint
```typescript
interface Waypoint {
  id: string;
  route_id: string;
  trip_id: string;
  user_id: string;
  lat: number;
  lng: number;
  order_in_route: number;
  name: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}
```

### MediaFile
```typescript
interface MediaFile {
  id: string;
  file_url: string;
  file_type: 'photo' | 'video';
  file_size_bytes: number;
  mime_type: string;
  width: number | null;
  height: number | null;
  thumbnail_url: string;
  caption: string | null;
  taken_at: string | null;
  created_at: string;
}
```

### Component (Timeline Item)
```typescript
interface Component {
  id: string;
  trip_id: string;
  component_type: 'place' | 'route';
  name: string;
  order_in_trip: number;
  created_at: string;
}
```

### SearchResult
```typescript
interface SearchResult {
  id: string | null;        // "local:uuid" or "foursquare:id"
  name: string;
  lat: number;
  lng: number;
  address: string | null;
  source: 'local' | 'foursquare';
  distance_m: number;
  rating: number | null;    // Foursquare only
  popularity: number | null;
  has_user_content: boolean;
  score?: number;           // Ranking score
}
```

---

## UI Framework & Styling

### Tech Stack
- **Tailwind CSS** - Utility-first styling
- **shadcn/ui** - Component library (Dialog, Form, Button, etc.)
- **Lucide React** - Icon library

### Theme
- Dark background: `bg-slate-900`, `bg-slate-950`
- Primary accent: `emerald-600`, `emerald-400`
- Borders: `white/10` for subtle divisions
- Text: `text-white`, `text-white/70` for muted

### Common Patterns
```tsx
// Dark card
<div className="bg-slate-900 border border-white/10 rounded-lg p-4">

// Primary button
<Button className="bg-emerald-600 hover:bg-emerald-700">

// Form input
<Input className="bg-slate-800 border-white/10">
```

---

## Map Integration

### V1 MapView (`components/Map/MapView.tsx`)
```typescript
// Read-only map with place markers
const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/dark-v11',
  center: [lng, lat],
  zoom: 10,
});

// Add numbered markers for places
places.forEach((place, index) => {
  new mapboxgl.Marker({ element: createMarkerElement(index + 1) })
    .setLngLat([place.lng, place.lat])
    .addTo(map);
});

// Fit bounds to show all places
map.fitBounds(bounds, { padding: 50 });
```

### V2 CenterMap (`components/Editor/CenterMap.tsx`)
- Full drawing capabilities
- Route layer rendering (GeoJSON)
- Waypoint markers
- Temp route preview during drawing
- Interactive selection (click marker → select in store)
- Highlight sync with timeline

---

## Authentication Flow

### Token Management
1. User logs in via Supabase Auth
2. JWT token stored in `localStorage.setItem('token', token)`
3. API client adds `Authorization: Bearer {token}` to all requests
4. On 401 error:
   - Try Supabase session refresh
   - If refresh succeeds, retry request with new token
   - If refresh fails, redirect to `/login`

### Session Listener (`App.tsx`)
```typescript
useEffect(() => {
  const { data: { subscription } } = supabase.auth.onAuthStateChange(
    (_event, session) => {
      if (session?.access_token) {
        localStorage.setItem('token', session.access_token);
      } else {
        localStorage.removeItem('token');
      }
    }
  );
  return () => subscription.unsubscribe();
}, []);
```

### ProtectedRoute
1. Hydrates auth state from localStorage
2. Verifies token with backend (`GET /auth/me`)
3. Shows spinner while checking
4. Redirects to `/login` if not authenticated
5. Renders children if authenticated

---

## Feature Flags

```typescript
// utils/features.ts
export const FEATURES = {
  EDITOR: import.meta.env.VITE_FEATURE_EDITOR === 'true',
};
```

**Usage**:
```tsx
{FEATURES.EDITOR && <Route path="/trips/:id/edit" element={<TripEditor />} />}
```

---

## Environment Variables

```bash
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_MAPBOX_TOKEN=your_mapbox_token
VITE_FEATURE_EDITOR=true
```

---

## Editor Workflow (V2)

### Add Place
1. Click "Add Place" in toolbar → `editMode = 'add-place'`
2. Click on map → Opens PlaceForm
3. Search for place (Foursquare) or enter manually
4. Save → Creates place via API
5. Place appears in timeline + map

### Draw Route
1. Click "Draw Route" in toolbar → `editMode = 'draw-route'`
2. Select transport mode (car/bike/walk)
3. Click points on map → `tempRoute` stores coordinates
4. Each click: Mapbox Directions API calculates preview
5. Click save → Creates route via API
6. Route appears in timeline + map as polyline

### Add Waypoint
1. Select existing route
2. Click "Add Waypoint" → `editMode = 'add-waypoint'`
3. Click on map → Creates waypoint
4. Route recalculates with waypoint included

### Timeline Reorder
1. Drag item in LeftSidebar timeline
2. Drop at new position
3. Calls `PATCH /trips/{id}/components/reorder`
4. Updates local state optimistically

### Selection Sync
- Click marker on map → Highlights in timeline
- Click item in timeline → Highlights on map
- `selectedItem` state shared across components

---

## Commands

```bash
# Development
cd frontend && npm run dev

# Build
cd frontend && npm run build

# Type check
cd frontend && npm run type-check

# Lint
cd frontend && npm run lint
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `src/App.tsx` | Routing + auth listener |
| `src/services/api.ts` | Axios client + interceptors |
| `src/store/authStore.ts` | Auth state (Zustand) |
| `src/store/editorStore.ts` | Editor state (V2) |
| `src/lib/supabase.ts` | Supabase client config |
| `src/lib/mapbox.ts` | Mapbox GL initialization |
| `src/components/Auth/ProtectedRoute.tsx` | Auth guard |
| `src/components/Editor/CenterMap.tsx` | V2 map canvas |
| `src/pages/TripEditor.tsx` | V2 editor page |
| `src/pages/TripDetail.tsx` | V1 trip view |
| `src/pages/Dashboard.tsx` | Trip list |

---

*Last updated: 2026-02-04*
