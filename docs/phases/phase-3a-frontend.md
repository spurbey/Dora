# **Frontend Development PRD **

**Project:** Travel Memory Vault Frontend  
**Backend:** FastAPI + Supabase (existing, fully functional)  
**Frontend:** React + TypeScript + Vite + shadcn/ui  
**Integration Model:**  Build frontend → Test in main repo → Commit

---

## **Critical Integration Rules**

### **API Endpoint Alignment**

**ALL API calls MUST match existing backend exactly:**

```
Base URL: http://localhost:8000/api/v1

Auth:
POST   /auth/login
POST   /auth/register  
GET    /auth/me

Trips:
GET    /trips
POST   /trips
GET    /trips/{id}
PATCH  /trips/{id}
DELETE /trips/{id}

Places:
GET    /places?trip_id={id}
POST   /places
GET    /places/{id}
PATCH  /places/{id}
DELETE /places/{id}

Search:
GET    /search/places?query={q}&lat={lat}&lng={lng}&radius_km={r}&limit={n}

Media:
POST   /media/upload
GET    /media/{id}
DELETE /media/{id}
```

**Authentication:**
- All requests (except /auth/*) require `Authorization: Bearer {token}` header
- Token from login response: `response.data.access_token`
- Store in localStorage: `localStorage.setItem('token', access_token)`

---

## **TypeScript Type Alignment**

**MUST match backend Pydantic schemas exactly:**

### **User Types** (`types/user.ts`)
```typescript
// Matches backend User model
interface User {
  id: string;              // UUID
  email: string;
  username: string;
  is_premium: boolean;
  is_verified: boolean;
  created_at: string;      // ISO datetime
}

// Matches backend LoginResponse
interface AuthResponse {
  access_token: string;
  token_type: string;      // Always "bearer"
  user: User;
}
```

### **Trip Types** (`types/trip.ts`)
```typescript
// Matches backend Trip model
interface Trip {
  id: string;                           // UUID
  user_id: string;                      // UUID
  title: string;
  description: string | null;
  start_date: string | null;            // ISO date
  end_date: string | null;              // ISO date
  visibility: 'private' | 'unlisted' | 'public';
  cover_photo_url: string | null;
  created_at: string;                   // ISO datetime
  updated_at: string;                   // ISO datetime
}

// Matches backend TripCreate schema
interface TripCreate {
  title: string;                        // Required, 1-200 chars
  description?: string;                 // Optional
  start_date?: string;                  // ISO date format
  end_date?: string;                    // ISO date format
  visibility?: 'private' | 'unlisted' | 'public';
}

// Matches backend TripUpdate schema
interface TripUpdate {
  title?: string;
  description?: string;
  start_date?: string;
  end_date?: string;
  visibility?: 'private' | 'unlisted' | 'public';
  cover_photo_url?: string;
}
```

### **Place Types** (`types/place.ts`)
```typescript
// Matches backend TripPlace model
interface Place {
  id: string;                           // UUID
  trip_id: string;                      // UUID
  user_id: string;                      // UUID
  name: string;
  lat: number;                          // -90 to 90
  lng: number;                          // -180 to 180
  place_type: string | null;            // 'restaurant', 'hotel', etc.
  user_notes: string | null;
  photos: string[];                     // JSONB array of URLs
  external_place_id: string | null;
  order_in_trip: number | null;
  created_at: string;                   // ISO datetime
  updated_at: string;                   // ISO datetime
}

// Matches backend PlaceCreate schema
interface PlaceCreate {
  trip_id: string;                      // Required, UUID
  name: string;                         // Required, 1-200 chars
  lat: number;                          // Required, -90 to 90
  lng: number;                          // Required, -180 to 180
  place_type?: string;
  user_notes?: string;
  external_place_id?: string;
  order_in_trip?: number;
}

// Matches backend PlaceUpdate schema
interface PlaceUpdate {
  name?: string;
  lat?: number;
  lng?: number;
  place_type?: string;
  user_notes?: string;
  order_in_trip?: number;
}
```

### **Search Types** (`types/search.ts`)
```typescript
// Matches backend SearchResult (Session 16)
interface SearchResult {
  id: string | null;                    // "local:uuid" or "foursquare:id"
  name: string;
  lat: number;
  lng: number;
  address: string | null;
  source: 'local' | 'foursquare';
  distance_m: number;
  rating: number | null;
  popularity: number | null;
  has_user_content: boolean;
  score?: number;                       // Only if backend ranking implemented
}

// Matches backend SearchResponse
interface SearchResponse {
  results: SearchResult[];
  count: number;
  query: string;
}
```

### **Media Types** (`types/media.ts`)
```typescript
// Matches backend MediaFile model
interface MediaFile {
  id: string;                           // UUID
  user_id: string;                      // UUID
  trip_place_id: string;                // UUID
  file_url: string;                     // Full Supabase URL
  file_type: string;                    // 'photo' or 'video'
  file_size_bytes: number | null;
  mime_type: string | null;             // 'image/jpeg', 'image/png', etc.
  width: number | null;
  height: number | null;
  thumbnail_url: string | null;         // Supabase transformation URL
  caption: string | null;
  taken_at: string | null;              // ISO datetime
  created_at: string;                   // ISO datetime
}

// For upload (multipart/form-data)
interface MediaUploadData {
  file: File;                           // Required
  trip_place_id: string;                // Required, UUID
  caption?: string;
  taken_at?: string;                    // ISO datetime
}
```

---

## **Phase Structure Overview**

```
Phase 1: Foundation (Week 1)
├── Auth system (login/register)
├── API service layer
├── Type definitions
└── Protected routing

Phase 2: Trips (Week 1-2)
├── Trip list/grid
├── Trip CRUD
├── Trip detail shell
└── No map yet (Phase 4)

Phase 3: Places & Search (Week 2)
├── Place search integration
├── Place CRUD
├── Place list/timeline view
└── No map yet (Phase 4)

Phase 4: Map & Media (Week 3)
├── Mapbox integration
├── Place markers
├── Photo upload
└── Photo gallery

Phase 5: Polish (Post-MVP)
├── Landing page
├── Profile/settings
└── Advanced features
```

---

# **PHASE 1: Foundation & Authentication**

**Duration:** Week 1 (Days 1-2)  
**Goal:** Set up project structure, auth system, API integration

---

## **Phase 1 Tasks**

### **Task 1.1: Project Structure**

**Folder Structure:**
```
src/
├── components/
│   ├── Auth/
│   ├── Layout/
│   ├── Shared/
│   ├── Trip/      (Phase 2)
│   ├── Place/     (Phase 3)
│   ├── Media/     (Phase 4)
│   └── Map/       (Phase 4)
├── pages/
│   ├── Login.tsx
│   ├── Register.tsx
│   ├── Dashboard.tsx      (Phase 2)
│   ├── TripDetail.tsx     (Phase 2)
│   └── ... (other phases)
├── services/
│   ├── api.ts
│   ├── authService.ts
│   ├── tripService.ts     (Phase 2)
│   ├── placeService.ts    (Phase 3)
│   ├── searchService.ts   (Phase 3)
│   └── mediaService.ts    (Phase 4)
├── store/
│   ├── authStore.ts
│   ├── tripStore.ts       (Phase 2)
│   ├── uiStore.ts
│   └── mapStore.ts        (Phase 4)
├── types/
│   ├── user.ts
│   ├── trip.ts            (Phase 2)
│   ├── place.ts           (Phase 3)
│   ├── search.ts          (Phase 3)
│   ├── media.ts           (Phase 4)
│   └── api.ts
├── hooks/
│   ├── useAuth.ts
│   ├── useTrips.ts        (Phase 2)
│   ├── usePlaces.ts       (Phase 3)
│   └── useMediaUpload.ts  (Phase 4)
├── utils/
│   ├── constants.ts
│   ├── formatters.ts
│   └── validators.ts
└── lib/
    ├── queryClient.ts
    └── mapbox.ts          (Phase 4)
```

**Configuration Files:**

**`vite.config.ts`:**
```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
```

**`.env`:**
```
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_MAPBOX_TOKEN=your_token_here
```

---

### **Task 1.2: TypeScript Type Definitions**

**File:** `src/types/user.ts`

**Copy EXACT types from "TypeScript Type Alignment" section above**

**File:** `src/types/api.ts`

```typescript
export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface ApiError {
  detail: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  size: number;
}
```

---

### **Task 1.3: API Service Layer**

**File:** `src/services/api.ts`

**Requirements:**
- Axios instance with base URL from env
- Request interceptor: Add `Authorization: Bearer {token}` header
- Response interceptor: Handle 401 (logout), extract data
- Error handling: Transform backend errors to user-friendly messages

**Critical:**
```typescript
// Get token from localStorage
const token = localStorage.getItem('token');
if (token) {
  config.headers.Authorization = `Bearer ${token}`;
}

// Base URL
baseURL: import.meta.env.VITE_API_BASE_URL  // http://localhost:8000/api/v1
```

**File:** `src/utils/constants.ts`

```typescript
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    ME: '/auth/me',
  },
  TRIPS: {
    LIST: '/trips',
    CREATE: '/trips',
    DETAIL: (id: string) => `/trips/${id}`,
    UPDATE: (id: string) => `/trips/${id}`,
    DELETE: (id: string) => `/trips/${id}`,
  },
  PLACES: {
    LIST: '/places',
    CREATE: '/places',
    DETAIL: (id: string) => `/places/${id}`,
    UPDATE: (id: string) => `/places/${id}`,
    DELETE: (id: string) => `/places/${id}`,
  },
  SEARCH: {
    PLACES: '/search/places',
  },
  MEDIA: {
    UPLOAD: '/media/upload',
    DETAIL: (id: string) => `/media/${id}`,
    DELETE: (id: string) => `/media/${id}`,
  },
};
```

---

### **Task 1.4: Auth Service**

**File:** `src/services/authService.ts`

**Functions:**

```typescript
// POST /auth/login
async function login(email: string, password: string): Promise<AuthResponse>

// POST /auth/register  
async function register(email: string, username: string, password: string): Promise<AuthResponse>

// GET /auth/me
async function getCurrentUser(): Promise<User>

// Local storage management
function logout(): void  // Clear token, redirect
function getToken(): string | null
function setToken(token: string): void
```

**Request/Response Format:**

**Login Request:**
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**Login Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user": {
    "id": "123e4567-...",
    "email": "user@example.com",
    "username": "johndoe",
    "is_premium": false,
    "is_verified": true,
    "created_at": "2025-01-26T10:00:00Z"
  }
}
```

**Register Request:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "password123"
}
```

**Error Response (400/401):**
```json
{
  "detail": "Incorrect email or password"
}
```

---

### **Task 1.5: Auth State Management**

**File:** `src/store/authStore.ts`

**Using Zustand:**

```typescript
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  
  // Actions
  setUser: (user: User) => void;
  setToken: (token: string) => void;
  logout: () => void;
  
  // Hydration (from localStorage)
  hydrate: () => void;
}
```

**Implementation Requirements:**
- Initialize from localStorage on app load
- Sync token to localStorage on change
- Clear everything on logout
- Export as `useAuthStore` hook

---

### **Task 1.6: Auth Components**

**File:** `src/components/Auth/LoginForm.tsx`

**Requirements:**
- Form with email + password fields
- Validation: required fields, email format
- Loading state during submission
- Error display (from backend)
- "Register" link
- Call `authService.login()`
- Store token + user in authStore
- Redirect to /dashboard on success

**UI:**
- Glassmorphism card
- Ocean/Forest theme colors
- Smooth transitions
- shadcn/ui Form + Input components

---

**File:** `src/components/Auth/RegisterForm.tsx`

**Requirements:**
- Form with email + username + password + confirm password
- Validation:
  - Email format
  - Username 3-20 chars
  - Password min 8 chars
  - Passwords match
- Password strength indicator
- Loading state
- Error display
- "Login" link
- Call `authService.register()`
- Store token + user
- Redirect to /dashboard

---

**File:** `src/components/Auth/ProtectedRoute.tsx`

**Requirements:**
- Check `authStore.isAuthenticated`
- If not authenticated → redirect to /login
- If authenticated → render children
- Show loading spinner during check

---

### **Task 1.7: Auth Pages**

**File:** `src/pages/Login.tsx`

**Layout:**
- Full-screen background (ocean/forest gradient)
- Centered LoginForm card
- Animated transitions

---

**File:** `src/pages/Register.tsx`

**Layout:**
- Same as Login
- Centered RegisterForm card

---

### **Task 1.8: Routing Setup**

**File:** `src/App.tsx`

```typescript
<Routes>
  <Route path="/login" element={<Login />} />
  <Route path="/register" element={<Register />} />
  
  <Route element={<ProtectedRoute />}>
    <Route path="/dashboard" element={<Dashboard />} />  {/* Phase 2 */}
    <Route path="/trips/:id" element={<TripDetail />} />  {/* Phase 2 */}
  </Route>
  
  <Route path="/" element={<Navigate to="/dashboard" />} />
</Routes>
```

---

## **Phase 1 Testing Checklist**

**Before moving to Phase 2:**

- [ ] Login with valid credentials → redirects to /dashboard
- [ ] Login with invalid credentials → shows error
- [ ] Register new user → redirects to /dashboard
- [ ] Token stored in localStorage
- [ ] Protected routes redirect to /login when not authenticated
- [ ] Refresh page → user stays logged in (token persists)
- [ ] Logout → clears token, redirects to /login
- [ ] GET /auth/me works (fetches current user)

**API Verification:**
```bash
# Test in main repo
cd backend
uvicorn app.main:app --reload

# Test login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"password123"}'

# Should return access_token + user
```


**Test in Main Repo:**
1. Copy files
2. Start backend: `cd backend && uvicorn app.main:app --reload`
3. Start frontend: `npm run dev`
4. Test login/register flows
5. Verify token in localStorage
6. Verify protected routes work

**If all tests pass → Commit Phase 1 → Proceed to Phase 2**

---

# **PHASE 2: Trips Management**

**Duration:** Week 1-2 (Days 3-7)  
**Goal:** Trip CRUD, list view, detail page (NO MAP YET)

---

## **Phase 2 Prerequisites**

- ✅ Phase 1 complete (auth working)
- ✅ Backend running (`http://localhost:8000`)
- ✅ User can login and access /dashboard

---

## **Phase 2 Tasks**

### **Task 2.1: Trip Type Definitions**

**File:** `src/types/trip.ts`

**Copy EXACT types from "TypeScript Type Alignment" section above**

**Export:**
```typescript
export type { Trip, TripCreate, TripUpdate };
```

---

### **Task 2.2: Trip Service**

**File:** `src/services/tripService.ts`

**Functions:**

```typescript
// GET /trips
async function getTrips(): Promise<Trip[]>

// POST /trips
async function createTrip(data: TripCreate): Promise<Trip>

// GET /trips/{id}
async function getTrip(id: string): Promise<Trip>

// PATCH /trips/{id}
async function updateTrip(id: string, data: TripUpdate): Promise<Trip>

// DELETE /trips/{id}
async function deleteTrip(id: string): Promise<void>
```

**Request Examples:**

**Create Trip:**
```json
{
  "title": "Paris Summer 2025",
  "description": "Two weeks in France",
  "start_date": "2025-06-01",
  "end_date": "2025-06-14",
  "visibility": "private"
}
```

**Update Trip:**
```json
{
  "title": "Paris & Rome Summer 2025",
  "end_date": "2025-06-21"
}
```

---

### **Task 2.3: Trip State Management**

**File:** `src/store/tripStore.ts`

```typescript
interface TripState {
  trips: Trip[];
  currentTrip: Trip | null;
  isLoading: boolean;
  
  // Actions
  setTrips: (trips: Trip[]) => void;
  setCurrentTrip: (trip: Trip | null) => void;
  addTrip: (trip: Trip) => void;
  updateTrip: (id: string, trip: Trip) => void;
  removeTrip: (id: string) => void;
}
```

---

### **Task 2.4: Trip Custom Hook**

**File:** `src/hooks/useTrips.ts`

**Using React Query:**

```typescript
// List trips
function useTrips() {
  return useQuery({
    queryKey: ['trips'],
    queryFn: tripService.getTrips,
  });
}

// Get single trip
function useTrip(id: string) {
  return useQuery({
    queryKey: ['trip', id],
    queryFn: () => tripService.getTrip(id),
    enabled: !!id,
  });
}

// Create trip mutation
function useCreateTrip() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: tripService.createTrip,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trips'] });
    },
  });
}

// Update trip mutation
function useUpdateTrip() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: TripUpdate }) =>
      tripService.updateTrip(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['trips'] });
      queryClient.invalidateQueries({ queryKey: ['trip', variables.id] });
    },
  });
}

// Delete trip mutation
function useDeleteTrip() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: tripService.deleteTrip,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trips'] });
    },
  });
}
```

---

### **Task 2.5: Layout Components**

**File:** `src/components/Layout/Navbar.tsx`

**Requirements:**
- Fixed top navigation
- Logo/title (left)
- Search bar (center) - placeholder only in Phase 2, functional in Phase 3
- User menu dropdown (right): Profile, Settings, Logout
- Ocean theme gradient background
- Responsive (collapse on mobile)

---

**File:** `src/components/Layout/Sidebar.tsx`

**Requirements:**
- Collapsible side navigation
- Links: Dashboard, My Trips, Search (Phase 3), Profile
- Active route highlighting
- Collapse/expand button
- Store collapse state in `uiStore`

---

**File:** `src/components/Layout/PageContainer.tsx`

**Requirements:**
- Common wrapper for all pages
- Padding, max-width
- Responsive layout
- Children prop

---

### **Task 2.6: Shared Components**

**File:** `src/components/Shared/LoadingSpinner.tsx`

**Requirements:**
- Various sizes (sm, md, lg)
- Ocean teal color
- Smooth animation

---

**File:** `src/components/Shared/EmptyState.tsx`

**Requirements:**
- Illustration/icon
- Title + description
- Optional action button
- Ocean/Forest theme

---

**File:** `src/components/Shared/ConfirmDialog.tsx`

**Requirements:**
- Modal overlay
- Title + message
- Confirm/Cancel buttons
- Destructive variant (for delete)
- shadcn/ui AlertDialog

---

### **Task 2.7: Trip Components**

**File:** `src/components/Trip/TripCard.tsx`

**Props:**
```typescript
interface TripCardProps {
  trip: Trip;
  onEdit: (trip: Trip) => void;
  onDelete: (id: string) => void;
}
```

**UI:**
- Card with cover photo (or gradient if no photo)
- Title
- Date range (if set)
- Places count: "5 places" (from backend - add to Trip type if needed)
- Visibility badge (private/unlisted/public)
- Action menu (3-dot): Edit, Delete
- Click card → navigate to `/trips/{id}`
- Hover effects

---

**File:** `src/components/Trip/TripForm.tsx`

**Props:**
```typescript
interface TripFormProps {
  trip?: Trip;  // If editing
  onSubmit: (data: TripCreate | TripUpdate) => void;
  onCancel: () => void;
}
```

**UI:**
- Modal (shadcn/ui Dialog)
- Fields:
  - Title (required)
  - Description (optional, textarea)
  - Start date (date picker)
  - End date (date picker)
  - Visibility (select: private/unlisted/public)
- Validation:
  - Title required, 1-200 chars
  - End date >= start date (if both set)
- Submit/Cancel buttons
- Loading state during submission

---

**File:** `src/components/Trip/TripHeader.tsx`

**Props:**
```typescript
interface TripHeaderProps {
  trip: Trip;
  onEdit: () => void;
  onDelete: () => void;
}
```

**UI:**
- Trip title (large)
- Date range
- Visibility badge
- Edit/Delete buttons
- Share button (placeholder for Phase 5)

---

### **Task 2.8: Dashboard Page**

**File:** `src/pages/Dashboard.tsx`

**Layout:**
- Navbar + Sidebar + PageContainer
- Header: "My Trips" + "Create Trip" button
- Trip grid (responsive: 1 col mobile, 2 col tablet, 3 col desktop)
- Empty state if no trips: "Start your first adventure!"
- Loading skeletons while fetching
- Error state if API fails

**Functionality:**
- Fetch trips on mount (`useTrips` hook)
- Click "Create Trip" → open TripForm modal
- Click trip card → navigate to `/trips/{id}`
- Click Edit → open TripForm modal (pre-filled)
- Click Delete → open ConfirmDialog → delete trip

---

### **Task 2.9: Trip Detail Page**

**File:** `src/pages/TripDetail.tsx`

**Layout:**
- Navbar + Sidebar
- TripHeader component
- Tabs: "Map" (Phase 4), "Timeline" (Phase 3), "Photos" (Phase 4)
- **For Phase 2:** Just show "Places" tab with placeholder text
- Empty state: "No places added yet. Search to add places."

**Functionality:**
- Fetch trip on mount (`useTrip` hook with id from URL params)
- Loading state
- Error state (404 if trip not found)
- Tab navigation (controlled)

---

## **Phase 2 Testing Checklist**

**Before moving to Phase 3:**

- [ ] Dashboard shows list of trips
- [ ] Create trip → opens modal → submits → new trip appears
- [ ] Edit trip → pre-fills form → saves → updates UI
- [ ] Delete trip → confirms → removes trip
- [ ] Click trip card → navigates to detail page
- [ ] Trip detail shows trip header
- [ ] Empty state shows when no trips
- [ ] Loading states show during API calls
- [ ] Error messages show on API failures

**API Verification:**
```bash
# List trips
curl http://localhost:8000/api/v1/trips \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create trip
curl -X POST http://localhost:8000/api/v1/trips \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Trip","visibility":"private"}'

# Get trip
curl http://localhost:8000/api/v1/trips/TRIP_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## **Phase 2 Handoff to Main Repo**

**Files to Copy:**
```
src/
├── components/
│   ├── Layout/Navbar.tsx
│   ├── Layout/Sidebar.tsx
│   ├── Layout/PageContainer.tsx
│   ├── Shared/LoadingSpinner.tsx
│   ├── Shared/EmptyState.tsx
│   ├── Shared/ConfirmDialog.tsx
│   └── Trip/
│       ├── TripCard.tsx
│       ├── TripForm.tsx
│       └── TripHeader.tsx
├── pages/
│   ├── Dashboard.tsx
│   └── TripDetail.tsx
├── services/tripService.ts
├── store/tripStore.ts
├── hooks/useTrips.ts
└── types/trip.ts
```

**Test → Commit → Proceed to Phase 3**

---

# **PHASE 3: Places & Search**

**Duration:** Week 2 (Days 8-12)  
**Goal:** Search integration, place CRUD, timeline view (NO MAP YET)

---

## **Phase 3 Prerequisites**

- ✅ Phase 2 complete (trips working)
- ✅ Backend search endpoint live (`GET /search/places`)
- ✅ Backend places endpoints live

---

## **Phase 3 Tasks**

### **Task 3.1: Place & Search Type Definitions**

**File:** `src/types/place.ts`

**Copy EXACT types from "TypeScript Type Alignment" section above**

**File:** `src/types/search.ts`

**Copy EXACT types from "TypeScript Type Alignment" section above**

---

### **Task 3.2: Place Service**

**File:** `src/services/placeService.ts`

**Functions:**

```typescript
// GET /places?trip_id={id}
async function getPlaces(tripId: string): Promise<Place[]>

// POST /places
async function createPlace(data: PlaceCreate): Promise<Place>

// GET /places/{id}
async function getPlace(id: string): Promise<Place>

// PATCH /places/{id}
async function updatePlace(id: string, data: PlaceUpdate): Promise<Place>

// DELETE /places/{id}
async function deletePlace(id: string): Promise<void>
```

**Request Example:**

**Create Place:**
```json
{
  "trip_id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Eiffel Tower",
  "lat": 48.8584,
  "lng": 2.2945,
  "place_type": "attraction",
  "user_notes": "Must visit at sunset!"
}
```

---

### **Task 3.3: Search Service**

**File:** `src/services/searchService.ts`

**Functions:**

```typescript
// GET /search/places?query={q}&lat={lat}&lng={lng}&radius_km={r}&limit={n}
async function searchPlaces(params: {
  query: string;
  lat: number;
  lng: number;
  radius_km?: number;
  limit?: number;
}): Promise<SearchResponse>
```

**Request Example:**
```
GET /search/places?query=coffee&lat=48.8566&lng=2.3522&radius_km=5&limit=10
```

**Response Example:**
```json
{
  "results": [
    {
      "id": "local:123e4567...",
      "name": "Café de Flore",
      "lat": 48.8542,
      "lng": 2.3325,
      "address": null,
      "source": "local",
      "distance_m": 245.8,
      "rating": null,
      "popularity": 5,
      "has_user_content": true,
      "score": 0.84
    },
    {
      "id": "foursquare:4adcdaf3...",
      "name": "Starbucks",
      "lat": 48.8560,
      "lng": 2.3510,
      "address": "Rue de Rivoli, Paris",
      "source": "foursquare",
      "distance_m": 450.0,
      "rating": 7.5,
      "popularity": null,
      "has_user_content": false,
      "score": 0.62
    }
  ],
  "count": 2,
  "query": "coffee"
}
```

---

### **Task 3.4: Place Hooks**

**File:** `src/hooks/usePlaces.ts`

```typescript
// List places for trip
function usePlaces(tripId: string) {
  return useQuery({
    queryKey: ['places', tripId],
    queryFn: () => placeService.getPlaces(tripId),
    enabled: !!tripId,
  });
}

// Get single place
function usePlace(id: string) {
  return useQuery({
    queryKey: ['place', id],
    queryFn: () => placeService.getPlace(id),
    enabled: !!id,
  });
}

// Create place
function useCreatePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: placeService.createPlace,
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['places', data.trip_id] });
    },
  });
}

// Update place
function useUpdatePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: PlaceUpdate }) =>
      placeService.updatePlace(id, data),
    onSuccess: (data, variables) => {
      queryClient.invalidateQueries({ queryKey: ['places', data.trip_id] });
      queryClient.invalidateQueries({ queryKey: ['place', variables.id] });
    },
  });
}

// Delete place
function useDeletePlace() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: placeService.deletePlace,
    onSuccess: (_, tripId) => {
      queryClient.invalidateQueries({ queryKey: ['places', tripId] });
    },
  });
}
```

---

### **Task 3.5: Search Hook with Debounce**

**File:** `src/hooks/useSearch.ts`

```typescript
function useSearch() {
  const [query, setQuery] = useState('');
  const [location, setLocation] = useState({ lat: 0, lng: 0 });
  
  const debouncedQuery = useDebounce(query, 300); // 300ms delay
  
  return useQuery({
    queryKey: ['search', debouncedQuery, location.lat, location.lng],
    queryFn: () => searchService.searchPlaces({
      query: debouncedQuery,
      lat: location.lat,
      lng: location.lng,
      radius_km: 5,
      limit: 10,
    }),
    enabled: debouncedQuery.length >= 2 && location.lat !== 0,
  });
}
```

**File:** `src/hooks/useDebounce.ts`

Standard debounce hook implementation.

---

### **Task 3.6: Place Search Component**

**File:** `src/components/Place/PlaceSearch.tsx`

**Props:**
```typescript
interface PlaceSearchProps {
  tripId: string;
  onSelectPlace: (result: SearchResult) => void;
}
```

**UI:**
- Search input
- Dropdown results (appears when typing)
- Each result shows:
  - Name
  - Source badge (local/foursquare)
  - Distance ("250m away")
  - Address (if available)
- Loading state
- Empty state ("No results")
- Click result → calls `onSelectPlace`

**Behavior:**
- Debounced search (300ms)
- Use current trip's first place as search center (or default to Paris if no places)
- Dropdown closes on select
- Keyboard navigation (up/down arrows, enter to select)

---

### **Task 3.7: Place Form Component**

**File:** `src/components/Place/PlaceForm.tsx`

**Props:**
```typescript
interface PlaceFormProps {
  tripId: string;
  place?: Place;  // If editing
  initialData?: SearchResult;  // If creating from search
  onSubmit: (data: PlaceCreate | PlaceUpdate) => void;
  onCancel: () => void;
}
```

**UI:**
- Modal (shadcn/ui Dialog)
- If `initialData` provided (from search):
  - Pre-fill name, lat, lng
  - Show "Adding: {name}" header
- Fields:
  - Name (required, pre-filled if from search)
  - Latitude (number, pre-filled if from search)
  - Longitude (number, pre-filled if from search)
  - Place type (select: restaurant, hotel, attraction, etc.)
  - Notes (textarea)
- Validation:
  - Name required
  - Lat/lng valid ranges
- Submit/Cancel buttons
- Loading state

**Integration with Search:**
```typescript
// When user selects from search:
<PlaceForm
  tripId={tripId}
  initialData={selectedSearchResult}
  onSubmit={(data) => {
    createPlace.mutate(data);
    closeModal();
  }}
  onCancel={closeModal}
/>
```

---

### **Task 3.8: Place Components**

**File:** `src/components/Place/PlaceCard.tsx`

**Props:**
```typescript
interface PlaceCardProps {
  place: Place;
  onEdit: () => void;
  onDelete: () => void;
}
```

**UI:**
- Card with place name
- Place type badge
- User notes preview
- Photo count (if photos array has items)
- Action menu: Edit, Delete
- Click card → show detail sidebar (Phase 4) or modal

---

**File:** `src/components/Place/PlaceListItem.tsx`

**Props:**
```typescript
interface PlaceListItemProps {
  place: Place;
  index: number;  // For timeline numbering
  onEdit: () => void;
  onDelete: () => void;
}
```

**UI:**
- Timeline item with number badge
- Place name
- Distance/duration (if available - Phase 4)
- Notes preview
- Action buttons

---

### **Task 3.9: Trip Timeline Page**

**File:** `src/components/Trip/TripTimeline.tsx`

**Props:**
```typescript
interface TripTimelineProps {
  tripId: string;
}
```

**UI:**
- Vertical timeline
- Each place as PlaceListItem
- Ordered by `order_in_trip` (or created_at if null)
- Empty state if no places
- "Add Place" button → opens search modal

**Functionality:**
- Fetch places (`usePlaces` hook)
- Click "Add Place" → open search modal
- Select from search → open PlaceForm with pre-filled data → create place
- Edit place → open PlaceForm
- Delete place → confirm → delete

---

### **Task 3.10: Update Trip Detail Page**

**File:** `src/pages/TripDetail.tsx`

**Changes:**
- Add "Timeline" tab
- Tab content: `<TripTimeline tripId={trip.id} />`
- "Map" tab still placeholder (Phase 4)

---

### **Task 3.11: Navbar Search Integration**

**File:** `src/components/Layout/Navbar.tsx`

**Changes:**
- Search input in center of navbar
- Opens dropdown with search results
- Clicking result → opens "Add to Trip" modal
- Select trip → creates place in that trip
- Only show if user authenticated

---

## **Phase 3 Testing Checklist**

**Before moving to Phase 4:**

- [ ] Search for "coffee" → shows results (local + foursquare)
- [ ] Search results show distance, source badge
- [ ] Select search result → opens place form (pre-filled)
- [ ] Create place from search → adds to trip
- [ ] Timeline shows places in order
- [ ] Edit place → updates successfully
- [ ] Delete place → removes from list
- [ ] Empty state shows when no places
- [ ] Search debounces (doesn't spam API)
- [ ] Navbar search works globally

**API Verification:**
```bash
# Search places
curl "http://localhost:8000/api/v1/search/places?query=coffee&lat=48.8566&lng=2.3522&radius_km=5" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create place
curl -X POST http://localhost:8000/api/v1/places \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"trip_id":"TRIP_ID","name":"Eiffel Tower","lat":48.8584,"lng":2.2945}'

# List places for trip
curl "http://localhost:8000/api/v1/places?trip_id=TRIP_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```


---

# **PHASE 4: Map & Media**

**Duration:** Week 3 (Days 13-20)  
**Goal:** Mapbox integration, place markers, photo upload/gallery

---

## **Phase 4 Prerequisites**

- ✅ Phase 3 complete (places & search working)
- ✅ Mapbox account + access token
- ✅ `.env` has `VITE_MAPBOX_TOKEN`

---

## **Phase 4 Tasks**

### **Task 4.1: Media Type Definitions**

**File:** `src/types/media.ts`

**Copy EXACT types from "TypeScript Type Alignment" section above**

---

### **Task 4.2: Media Service**

**File:** `src/services/mediaService.ts`

**Functions:**

```typescript
// POST /media/upload (multipart/form-data)
async function uploadMedia(data: {
  file: File;
  trip_place_id: string;
  caption?: string;
  taken_at?: string;
}): Promise<MediaFile>

// GET /media/{id}
async function getMedia(id: string): Promise<MediaFile>

// DELETE /media/{id}
async function deleteMedia(id: string): Promise<void>
```

**Important - Upload Format:**
```typescript
const formData = new FormData();
formData.append('file', file);  // File object
formData.append('trip_place_id', trip_place_id);
if (caption) formData.append('caption', caption);
if (taken_at) formData.append('taken_at', taken_at);

// POST with Content-Type: multipart/form-data
await api.post('/media/upload', formData, {
  headers: { 'Content-Type': 'multipart/form-data' }
});
```

---

### **Task 4.3: Media Upload Hook**

**File:** `src/hooks/useMediaUpload.ts`

```typescript
function useMediaUpload() {
  const [uploadProgress, setUploadProgress] = useState(0);
  
  const uploadMutation = useMutation({
    mutationFn: mediaService.uploadMedia,
    onSuccess: (data) => {
      // Invalidate place query to refresh photos
      queryClient.invalidateQueries({ queryKey: ['place', data.trip_place_id] });
    },
  });
  
  const uploadWithProgress = async (file: File, placeId: string) => {
    // Track upload progress
    const config = {
      onUploadProgress: (progressEvent) => {
        const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total);
        setUploadProgress(percent);
      },
    };
    
    return uploadMutation.mutateAsync({ file, trip_place_id: placeId }, config);
  };
  
  return { uploadWithProgress, uploadProgress, isUploading: uploadMutation.isLoading };
}
```

---

### **Task 4.4: Mapbox Setup**

**File:** `src/lib/mapbox.ts`

```typescript
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN;

export { mapboxgl };
```

**Install:**
```bash
npm install mapbox-gl
npm install -D @types/mapbox-gl
```

---

### **Task 4.5: Map Store**

**File:** `src/store/mapStore.ts`

```typescript
interface MapState {
  viewport: {
    latitude: number;
    longitude: number;
    zoom: number;
  };
  selectedPlaceId: string | null;
  
  setViewport: (viewport: Partial<MapState['viewport']>) => void;
  setSelectedPlace: (id: string | null) => void;
  fitBounds: (places: Place[]) => void;  // Calculate bounds from places
}
```

---

### **Task 4.6: Map Components**

**File:** `src/components/Map/MapView.tsx`

**Props:**
```typescript
interface MapViewProps {
  places: Place[];
  onPlaceClick: (place: Place) => void;
  onMapClick?: (lat: number, lng: number) => void;  // For adding places
}
```

**Implementation:**
- Initialize Mapbox GL map
- Add markers for each place
- Fit bounds to show all places
- Click marker → call `onPlaceClick`
- Click map → call `onMapClick` (optional - for adding places at clicked location)
- Custom marker style (ocean theme)
- Animated markers (pulse effect)

---

**File:** `src/components/Map/PlaceMarker.tsx`

**Custom Marker:**
- Number badge (order_in_trip)
- Ocean teal color
- Pulse animation
- Hover effect
- Active state (selected place)

---

**File:** `src/components/Map/MapControls.tsx`

**UI:**
- Zoom in/out buttons
- Reset view button
- Geolocation button (center on user)
- Fullscreen toggle

---

### **Task 4.7: Media Components**

**File:** `src/components/Media/PhotoUpload.tsx`

**Props:**
```typescript
interface PhotoUploadProps {
  placeId: string;
  onUploadComplete: (media: MediaFile) => void;
}
```

**UI:**
- Drag & drop zone
- File input (click to browse)
- Upload progress bar
- Preview thumbnail before upload
- Multiple file support (upload one at a time)
- Validation: max 10MB, images only (JPEG, PNG, WebP)

**Functionality:**
- Drag file → show preview
- Click upload → upload to backend
- Show progress bar
- On complete → add to gallery
- On error → show error message

---

**File:** `src/components/Media/PhotoGallery.tsx`

**Props:**
```typescript
interface PhotoGalleryProps {
  placeId: string;
  photos: MediaFile[];
  onPhotoClick: (photo: MediaFile) => void;
  onPhotoDelete: (id: string) => void;
}
```

**UI:**
- Masonry grid layout (responsive)
- Each photo:
  - Thumbnail image
  - Caption overlay (hover)
  - Delete button (hover)
- Click photo → open lightbox
- Empty state if no photos

---

**File:** `src/components/Media/Lightbox.tsx`

**Props:**
```typescript
interface LightboxProps {
  photos: MediaFile[];
  currentIndex: number;
  onClose: () => void;
  onNext: () => void;
  onPrevious: () => void;
}
```

**UI:**
- Full-screen overlay
- Large photo display
- Previous/Next navigation
- Close button
- Photo caption
- Keyboard navigation (arrow keys, ESC)
- Swipe gestures (mobile)

---

### **Task 4.8: Place Detail Sidebar**

**File:** `src/components/Place/PlaceDetailSidebar.tsx`

**Props:**
```typescript
interface PlaceDetailSidebarProps {
  place: Place;
  isOpen: boolean;
  onClose: () => void;
  onEdit: () => void;
  onDelete: () => void;
}
```

**UI:**
- Slide-in panel from right
- Place name
- Place type
- Coordinates
- User notes
- Photo gallery
- Photo upload section
- Edit/Delete buttons
- Close button

**Functionality:**
- Show when place marker clicked
- Upload photos
- View photos in lightbox
- Delete photos
- Edit/delete place

---

### **Task 4.9: Update Trip Detail Page**

**File:** `src/pages/TripDetail.tsx`

**Changes:**
- "Map" tab now functional:
  - MapView component with all trip places
  - Click marker → open PlaceDetailSidebar
  - Place detail sidebar shows photos
- "Photos" tab:
  - All photos from all places in trip
  - Combined gallery view
  - Click photo → lightbox with all trip photos

---

## **Phase 4 Testing Checklist**

**Before moving to Phase 5:**

- [ ] Map shows all places as markers
- [ ] Markers numbered by order
- [ ] Click marker → opens detail sidebar
- [ ] Map fits bounds to show all places
- [ ] Drag & drop photo → uploads successfully
- [ ] Upload progress bar works
- [ ] Photos appear in gallery
- [ ] Click photo → opens lightbox
- [ ] Lightbox navigation works (prev/next)
- [ ] Delete photo → removes from gallery
- [ ] Multiple photos per place supported
- [ ] Map controls work (zoom, reset, geolocation)

**API Verification:**
```bash
# Upload photo
curl -X POST http://localhost:8000/api/v1/media/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/photo.jpg" \
  -F "trip_place_id=PLACE_ID" \
  -F "caption=Beautiful sunset"

# Should return MediaFile with file_url and thumbnail_url
```


---

# **PHASE 5: Polish & Landing** (Post-MVP)

**This phase is OPTIONAL and comes AFTER MVP launch**

**Includes:**
- Landing page
- Profile/Settings pages
- Pricing page
- Advanced animations
- Dark mode
- Social sharing
- Export features

**Do NOT build Phase 5 in Lovable until Phases 1-4 are complete, tested, and deployed.**

---

# **Lovable-Specific Implementation Notes**

## **Critical Rules for Lovable**

1. **NO Mock Data:**
   - Always use real API calls
   - Never hardcode fake trips/places/photos
   - Every feature must hit actual backend

2. **Type Safety:**
   - Match backend Pydantic schemas EXACTLY
   - No `any` types
   - Use provided type definitions

3. **Error Handling:**
   - Show user-friendly error messages
   - Handle 401 → redirect to login
   - Handle 403 → show "No permission"
   - Handle 404 → show "Not found"
   - Handle 500 → show "Server error, try again"

4. **Loading States:**
   - Show skeleton loaders during fetch
   - Show spinners during mutations
   - Show progress bars during uploads
   - Disable buttons during loading

5. **Authentication:**
   - All API calls include Bearer token
   - Token from localStorage
   - 401 → logout and redirect

6. **File Uploads:**
   - Use `multipart/form-data`
   - Show progress
   - Validate file type/size client-side BEFORE upload
   - Max 10MB per photo

7. **Map Integration:**
   - Use Mapbox GL JS (not React Map GL)
   - Token from env variable
   - Custom markers (not default)
   - Fit bounds to places

8. **React Query:**
   - Use for all API calls
   - Invalidate queries on mutations
   - Enable caching
   - Handle loading/error states

9. **shadcn/ui:**
   - Use existing components
   - Customize with Ocean/Forest theme
   - Don't recreate components that exist

10. **Responsive:**
    - Mobile-first
    - Test on mobile viewport
    - Hamburger menu on mobile
    - Touch gestures for lightbox/map

---

## **Testing Workflow**

### **After Each Phase in Lovable:**

1. **Build in Lovable:** Complete all tasks for phase
2. **Copy to Main Repo:** Copy changed files
3. **Test in Main Repo:**
   ```bash
   # Terminal 1: Backend
   cd backend
   uvicorn app.main:app --reload
   
   # Terminal 2: Frontend
   npm run dev
   
   # Open: http://localhost:5173
   ```
4. **Verify Integration:**
   - Check Network tab (API calls correct)
   - Check Console (no errors)
   - Test all CRUD operations
   - Test auth flows
5. **Fix Issues:** If errors, fix in Lovable, re-copy
6. **Commit:** Once working, commit phase to git
7. **Next Phase:** Move to next phase PRD

---

## **Common Integration Issues**

### **Issue 1: CORS Errors**

**Symptom:** "CORS policy blocked" in console

**Fix:** Backend has CORS configured, but check:
- Frontend hitting correct URL (`http://localhost:8000`)
- No trailing slashes in API_BASE_URL
- Credentials: 'include' if needed

---

### **Issue 2: 401 Unauthorized**

**Symptom:** All API calls return 401

**Fix:**
- Check token in localStorage (`localStorage.getItem('token')`)
- Check Authorization header format: `Bearer {token}` (capital B)
- Token not expired (backend tokens don't expire for MVP)

---

### **Issue 3: Type Mismatches**

**Symptom:** TypeScript errors, data not displaying

**Fix:**
- Compare frontend types to backend schemas EXACTLY
- Check field names (snake_case in backend, camelCase in frontend needs mapping)
- **IMPORTANT:** Backend uses snake_case, frontend TypeScript uses camelCase
- Either: Match backend exactly (snake_case in frontend too), OR add transformation layer

**Recommendation:** Use snake_case in frontend types to match backend exactly (easier)

---

### **Issue 4: Photo Upload Fails**

**Symptom:** 400 Bad Request on upload

**Fix:**
- Check Content-Type header: `multipart/form-data`
- Check FormData field names match backend: `file`, `trip_place_id`, `caption`, `taken_at`
- Check file is actual File object, not base64
- Check file size < 10MB

---

### **Issue 5: Map Doesn't Load**

**Symptom:** Blank map area

**Fix:**
- Check Mapbox token in .env
- Check mapbox-gl CSS imported
- Check container has height/width
- Check places array not empty
- Check console for Mapbox errors

---

## **Phase Completion Criteria**

**Each phase is complete when:**

- [ ] All tasks implemented in Lovable
- [ ] Files copied to main repo
- [ ] Backend running (`http://localhost:8000`)
- [ ] Frontend running (`http://localhost:5173`)
- [ ] All features tested and working
- [ ] No console errors
- [ ] No TypeScript errors
- [ ] All API calls succeed
- [ ] Changes committed to git
- [ ] README updated with progress

---

**END OF FRONTEND PRD**

**Start with Phase 1 (Auth) in Lovable. Do NOT proceed to Phase 2 until Phase 1 is tested and committed in main repo.**