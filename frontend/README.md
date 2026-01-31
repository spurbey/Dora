# Travel Memory Vault Frontend - Developer Handbook

This document is intentionally long and detailed. It is meant to be a full onboarding guide and a day-to-day reference for frontend development in this repo.
It explains the architecture, structure, conventions, and integration strategy with the backend, and provides playbooks for common tasks.

Audience: new interns, junior developers, and reviewers who need to understand how the frontend works and how to extend it safely.

## Table of Contents
- 1. Overview
- 2. Tech Stack
- 3. Repository Layout
- 4. Environment and Setup
- 5. Scripts and Commands
- 6. Architecture Overview
- 7. Data Flow and API Strategy
- 8. Authentication Flow
- 9. Routing and Navigation
- 10. State Management (React Query + Zustand)
- 11. Services Layer
- 12. Types and Schema Alignment
- 13. UI Components and Styling
- 14. Feature Areas
- 15. Error Handling and UX
- 16. Performance Guidelines
- 17. Accessibility Guidelines
- 18. Testing and Verification
- 19. Debugging Playbooks
- 20. Deployment Notes
- 21. Contribution Workflow
- 22. File Index
- 23. Appendices and Reference

## 1. Overview
The frontend is a React + TypeScript single-page application built with Vite. It is designed to work with an existing FastAPI backend and Supabase Auth.
The app provides authentication, trip management, place search, and trip timelines, with maps and media planned for Phase 4.

Key goals:
- Keep the UI fast and responsive.
- Match backend schemas exactly (snake_case) to avoid mapping bugs.
- Use React Query for server state and Zustand for lightweight client state.
- Provide clear error handling and loading states.
- Make it easy for new contributors to add features.

## 2. Tech Stack
- React 18 + TypeScript
- Vite for bundling and dev server
- Tailwind CSS for styling
- shadcn/ui for UI primitives
- React Router for routing
- React Query (TanStack) for server state
- Zustand for client state
- Axios for HTTP requests
- Supabase Auth for authentication

Why this stack:
- Vite provides fast reloads and a simple build pipeline.
- Tailwind + shadcn give consistent UI with low CSS overhead.
- React Query handles caching and background refresh safely.
- Zustand is minimal and avoids heavy boilerplate.

## 3. Repository Layout
Repository root:
- backend/ contains FastAPI backend
- frontend/ contains this frontend app
- docs/ contains phase PRDs and planning
- .claude/ contains project status and planning notes

Frontend root:
- frontend/README.md (this file)
- frontend/src/ (application code)
- frontend/public/ (static assets)
- frontend/index.html (Vite entry HTML)
- frontend/vite.config.ts (Vite config)
- frontend/tailwind.config.ts (Tailwind config)
- frontend/tsconfig*.json (TypeScript config)

## 4. Environment and Setup
Required Node version: use a modern LTS (18+ recommended).
Install dependencies from the frontend folder:

```bash
cd frontend
npm install
```

Environment variables (frontend/.env):
```bash
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_MAPBOX_TOKEN=your_mapbox_public_token
```

Important notes:
- All env vars must be prefixed with VITE_ to be exposed to the app.
- Do not commit secrets. Use placeholders in docs.
- The backend must be running for API calls to work.

## 5. Scripts and Commands
Common scripts:
- npm run dev: Start Vite dev server.
- npm run build: Build for production.
- npm run preview: Preview production build.
- npm run lint: Run ESLint.

Backend dev command (from backend/):
```bash
uvicorn app.main:app --reload
```

## 6. Architecture Overview
High-level layers:
- UI layer: Pages and components render data and handle user input.
- Hooks layer: Data fetching and mutations (React Query).
- Service layer: API wrappers (Axios).
- State layer: Zustand for local state, React Query for server state.
- Backend: FastAPI endpoints + Supabase Auth verification.

Directory roles:
- src/pages: Route-level views.
- src/components: Reusable UI components.
- src/services: API service wrappers.
- src/hooks: Query hooks and UI hooks.
- src/store: Zustand stores for local state.
- src/types: TypeScript interfaces matching backend schemas.
- src/utils: Helpers and constants.
- src/lib: Client libraries (Supabase, QueryClient, Mapbox).

## 7. Data Flow and API Strategy
All API calls go through the service layer in src/services.
Services wrap Axios and apply base URL + auth header automatically via api.ts.
React Query hooks call services and manage caching, refetching, and invalidation.

Request flow (typical):
- Component triggers action
- Hook calls service
- Service hits backend endpoint
- Hook updates cache and returns data
- Component renders new state

Response shape rules:
- Keep types snake_case to match backend.
- If backend returns wrappers (e.g., places list), unwrap in hook.

## 8. Authentication Flow
Auth is handled by Supabase Auth (frontend only) and /auth/me for user profile.
We do not call /auth/login or /auth/register on the backend.

Login:
- User enters email and password.
- supabase.auth.signInWithPassword returns session and access_token.
- Token saved to localStorage.
- Frontend calls GET /auth/me with Bearer token to get user profile.

Register:
- supabase.auth.signUp is called with email/password and username metadata.
- If email confirmation is required, UI should show a message.
- If session returned, token saved and /auth/me is called to create/fetch user.

Logout:
- supabase.auth.signOut
- Clear localStorage token

Where to look in code:
- src/services/authService.ts
- src/store/authStore.ts
- src/hooks/useAuth.ts

## 9. Routing and Navigation
Routing uses React Router (Routes in src/App.tsx).
Protected routes are wrapped by ProtectedRoute to require auth.

Routes:
- /login -> Login page
- /register -> Register page
- /dashboard -> Dashboard (protected)
- /trips/:id -> Trip detail (protected)

Navigation components:
- Navbar (top bar, global search)
- Sidebar (left nav, collapsible)

## 10. State Management (React Query + Zustand)
We use React Query for server state (remote data).
We use Zustand for local UI state and auth state.

React Query guidance:
- Keep query keys stable and scoped by resource.
- Use enabled to guard queries requiring IDs or auth.
- Invalidate queries on mutations rather than manual cache edits for now.

Zustand guidance:
- Auth state is in authStore.
- UI state (sidebar collapse) is in uiStore.
- Keep stores small and focused.

## 11. Services Layer
Services encapsulate HTTP calls and return typed data.
All services use api.ts, which adds the Authorization header and handles 401s.

Service files:
- src/services/api.ts
- src/services/authService.ts
- src/services/tripService.ts
- src/services/placeService.ts
- src/services/searchService.ts
- src/services/mediaService.ts (Phase 4)

Common patterns:
- api.get<T>(url) returns data only (response.data).
- Use generic typing for request/response types.
- Prefer to normalize data in hooks, not components.

## 12. Types and Schema Alignment
All types are in src/types and must match backend Pydantic schemas exactly.
We use snake_case in frontend types to match backend responses.

Core type files:
- src/types/user.ts
- src/types/trip.ts
- src/types/place.ts
- src/types/search.ts
- src/types/media.ts (Phase 4)

Schema rules:
- Do not rename backend fields in frontend types.
- Use optional fields for nullable backend fields.
- Keep enums as union types of string literals.

## 13. UI Components and Styling
We use Tailwind CSS + shadcn/ui components.
The design uses an ocean/forest theme with dark gradients and teal accents.

Guidelines:
- Prefer shadcn/ui components for base elements (Button, Dialog, Input).
- Keep layout consistent: PageContainer + Navbar + Sidebar.
- Use consistent spacing and typography tokens.
- Use data attributes for shadcn states when needed.

Folders:
- src/components/Shared: generic components like EmptyState.
- src/components/Layout: Navbar, Sidebar, PageContainer.
- src/components/Auth: LoginForm, RegisterForm, ProtectedRoute.
- src/components/Trip: TripCard, TripForm, TripHeader, TripTimeline.
- src/components/Place: PlaceSearch, PlaceForm, PlaceListItem, PlaceCard.

## 14. Feature Areas
This section gives a quick summary of each feature area and its components.

Auth:
- Login and Register pages with form validation.
- Supabase auth with token stored in localStorage.
- ProtectedRoute wraps private routes.

Trips:
- Dashboard shows trip cards and create/edit/delete flows.
- TripDetail shows timeline tab (places) and placeholders for map/photos.

Places:
- Search via /search/places endpoint (local + Foursquare).
- Add place to trip via PlaceForm modal.
- Timeline list of places per trip.

Search:
- Global search in Navbar with dropdown results.
- Search hook debounces input and uses lat/lng center.

Map + Media (Phase 4):
- Mapbox GL JS for map rendering.
- Media uploads via /media/upload.
- Photo gallery and lightbox planned.

## 15. Error Handling and UX
Error handling principles:
- API errors should be shown as user-friendly messages.
- 401 errors trigger logout and redirect to /login.
- Components should show empty states when there is no data.
- Loading states should avoid flashing content.

Common UI states:
- Loading: show spinner or skeleton.
- Empty: show EmptyState component.
- Error: show inline message or alert.

## 16. Performance Guidelines
Performance basics:
- Keep React Query stale times reasonable if needed.
- Use memoization in heavy lists if necessary.
- Avoid unnecessary re-renders by selecting Zustand slices.
- Debounce search inputs to avoid API spam.

Images:
- For media gallery, use thumbnails when available.
- Avoid loading full-size images in list views.

## 17. Accessibility Guidelines
Accessibility basics:
- Ensure buttons have accessible labels.
- Use semantic HTML where possible.
- Ensure focus styles are visible.
- Use aria attributes for custom components.

Forms:
- Label inputs clearly.
- Provide inline validation messages.
- Keep color contrast sufficient.

## 18. Testing and Verification
There is no full frontend test suite yet. Use manual verification.
Recommended checks:
- Login works with valid credentials.
- Register works and prompts for email confirmation if required.
- Dashboard loads trips.
- Create/edit/delete trip works.
- Search results appear with query and location.
- Adding a place creates a timeline item.
- Refreshing keeps auth state intact.

Linting:
- npm run lint should pass or only show known warnings.

## 19. Debugging Playbooks
Use this section to diagnose common issues quickly.

Auth fails:
- Check VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.
- Check localStorage token value.
- Verify /auth/me returns 200 with Authorization header.

Search returns no results:
- Check lat/lng. Searching Pune with Paris coordinates returns 0 results.
- Verify backend /search/places response in Network tab.
- Verify Foursquare API key configuration in backend.

Places timeline error:
- Ensure list endpoint returns PlaceListResponse with places array.
- Confirm hook unwraps response.places.

401 Unauthorized:
- Token missing or expired.
- Authorization header should be Bearer <token>.
- Check backend logs for auth errors.

## 20. Deployment Notes
Build artifacts:
- Vite outputs to frontend/dist.

Environment differences:
- Production API base URL must be set correctly.
- Supabase and Mapbox tokens should be set in deployment environment.

## 21. Contribution Workflow
Recommended workflow:
- Create or checkout the correct branch.
- Implement changes in small, reviewable chunks.
- Run lint before commit.
- Update project status docs if a phase milestone is reached.
- Use descriptive commit messages (see Phase 1/2 examples).

## 22. File Index
This section lists frontend files with short descriptions. Update as needed.

- `src/App.tsx` - Route definitions
- `src/components/Auth/LoginForm.tsx` - Auth component
- `src/components/Auth/ProtectedRoute.tsx` - Auth component
- `src/components/Auth/RegisterForm.tsx` - Auth component
- `src/components/Layout/Navbar.tsx` - Layout component
- `src/components/Layout/PageContainer.tsx` - Layout component
- `src/components/Layout/Sidebar.tsx` - Layout component
- `src/components/Map/MapControls.tsx` - Map UI component
- `src/components/Map/MapView.tsx` - Map UI component
- `src/components/Media/Lightbox.tsx` - Media UI component
- `src/components/Media/PhotoGallery.tsx` - Media UI component
- `src/components/Media/PhotoUpload.tsx` - Media UI component
- `src/components/Place/PlaceCard.tsx` - Place UI component
- `src/components/Place/PlaceDetailSidebar.tsx` - Place UI component
- `src/components/Place/PlaceForm.tsx` - Place UI component
- `src/components/Place/PlaceListItem.tsx` - Place UI component
- `src/components/Place/PlaceSearch.tsx` - Place UI component
- `src/components/Shared/ConfirmDialog.tsx` - Shared UI component
- `src/components/Shared/EmptyState.tsx` - Shared UI component
- `src/components/Shared/ErrorBoundary.tsx` - Shared UI component
- `src/components/Shared/LoadingSpinner.tsx` - Shared UI component
- `src/components/Shared/Spinner.tsx` - Shared UI component
- `src/components/Trip/TripCard.tsx` - Trip UI component
- `src/components/Trip/TripForm.tsx` - Trip UI component
- `src/components/Trip/TripHeader.tsx` - Trip UI component
- `src/components/Trip/TripTimeline.tsx` - Trip UI component
- `src/components/ui/alert-dialog.tsx` - shadcn/ui primitive
- `src/components/ui/alert.tsx` - shadcn/ui primitive
- `src/components/ui/button.tsx` - shadcn/ui primitive
- `src/components/ui/card.tsx` - shadcn/ui primitive
- `src/components/ui/dialog.tsx` - shadcn/ui primitive
- `src/components/ui/dropdown-menu.tsx` - shadcn/ui primitive
- `src/components/ui/form.tsx` - shadcn/ui primitive
- `src/components/ui/input.tsx` - shadcn/ui primitive
- `src/components/ui/label.tsx` - shadcn/ui primitive
- `src/components/ui/select.tsx` - shadcn/ui primitive
- `src/components/ui/tabs.tsx` - shadcn/ui primitive
- `src/components/ui/textarea.tsx` - shadcn/ui primitive
- `src/hooks/useAuth.ts` - Custom hook
- `src/hooks/useDebounce.ts` - Custom hook
- `src/hooks/useMediaUpload.ts` - Custom hook
- `src/hooks/usePlaces.ts` - Custom hook
- `src/hooks/useSearch.ts` - Custom hook
- `src/hooks/useTrips.ts` - Custom hook
- `src/index.css` - Global styles
- `src/lib/mapbox.ts` - Library setup
- `src/lib/queryClient.ts` - Library setup
- `src/lib/supabase.ts` - Library setup
- `src/lib/utils.ts` - Library setup
- `src/main.tsx` - App bootstrap
- `src/pages/Dashboard.tsx` - File
- `src/pages/Login.tsx` - File
- `src/pages/Register.tsx` - File
- `src/pages/TripDetail.tsx` - File
- `src/services/api.ts` - API service wrapper
- `src/services/authService.ts` - API service wrapper
- `src/services/mediaService.ts` - API service wrapper
- `src/services/placeService.ts` - API service wrapper
- `src/services/searchService.ts` - API service wrapper
- `src/services/tripService.ts` - API service wrapper
- `src/store/authStore.ts` - Zustand store
- `src/store/mapStore.ts` - Zustand store
- `src/store/tripStore.ts` - Zustand store
- `src/store/uiStore.ts` - Zustand store
- `src/types/api.ts` - TypeScript types
- `src/types/media.ts` - TypeScript types
- `src/types/place.ts` - TypeScript types
- `src/types/search.ts` - TypeScript types
- `src/types/trip.ts` - TypeScript types
- `src/types/user.ts` - TypeScript types
- `src/utils/constants.ts` - Utility helper
- `src/vite-env.d.ts` - File

## 23. Appendices and Reference

This section contains focused reference material that helps contributors debug and extend the frontend.
It avoids filler and should be updated as the project grows.

### 23.1 Practical Playbooks
These playbooks reflect the actual codebase and common workflows.

#### Auth Playbook
- Confirm Supabase env vars are set in `frontend/.env`
- Use `supabase.auth.signInWithPassword` in `authService.ts`
- Verify `localStorage.token` exists after login
- Call `GET /auth/me` to fetch user profile
- On 401, ensure header is `Authorization: Bearer <token>`

#### Places + Timeline Playbook
- Create place via `POST /places` and ensure `trip_id` is correct
- List places via `GET /places?trip_id=...` (returns `{ places, total }`)
- `usePlaces` must unwrap `response.places` before rendering
- Trip timeline sorts by `order_in_trip`, falls back to `created_at`
- If UI shows ?places is not iterable?, check list response shape

#### Search Playbook
- Verify `/search/places` request includes lat/lng/radius_km
- Ensure location used for search matches user intent (not default Paris)
- For zero results, check query + coordinates in Network tab
- If backend returns results, confirm dropdown rendering and mapping

#### Trip CRUD Playbook
- Create/update/delete via `tripService.ts` functions
- Ensure React Query invalidates `trips` and `trip` queries
- Use `TripForm` for create/edit with proper default values

### 23.2 Troubleshooting Guide
Common issues and targeted fixes:
- Blank page: check console errors and React Router routes.
- 401 Unauthorized: verify token exists, header uses Bearer, and backend is running.
- Search returns 0 results: verify lat/lng location; change to nearby city to test.
- ?places is not iterable?: list endpoint returns object; unwrap `places` array.
- Register requires confirmation: Supabase project setting may still be on; verify dashboard.
- Map not loading (Phase 4): check Mapbox token and map container size.

### 23.3 Quality Checklists
Use these for reviews and before commits.

#### New Feature Checklist
- API endpoints and response shapes verified
- Types match backend schemas (snake_case)
- Hook added for queries/mutations with proper invalidation
- Loading/error/empty states included
- UI aligns with app theme and layout patterns
- Manual test completed in browser

#### Bug Fix Checklist
- Root cause identified and documented
- Fix covered in both service + UI if needed
- Regression risk considered (related features tested)
- Console/network checks show clean behavior

### 23.4 Glossary (Short)
- Auth Session: Supabase session with access token
- Bearer Token: JWT placed in Authorization header
- React Query: Caches server data with background refetch
- Zustand: Lightweight client-side store
- Trip: User-owned collection of places
- Place: Stored location with notes and metadata
- Search Result: Unified result from local DB or Foursquare
- Mapbox GL JS: Map rendering library used in Phase 4

### 23.5 API Reference (Frontend Perspective)
- GET /auth/me: current user profile
- GET /trips: list trips
- POST /trips: create trip
- GET /trips/{id}: trip detail
- PATCH /trips/{id}: update trip
- DELETE /trips/{id}: delete trip
- GET /places?trip_id=...: list places
- POST /places: create place
- GET /places/{id}: place detail
- PATCH /places/{id}: update place
- DELETE /places/{id}: delete place
- GET /search/places: search local + Foursquare
- POST /media/upload: upload photo (Phase 4)
- GET /media/{id}: media detail (Phase 4)
- DELETE /media/{id}: delete media (Phase 4)

### 23.6 Example Payloads
Login (Supabase Auth):
```json
{ "email": "user@example.com", "password": "password123" }
```
Create Trip:
```json
{ "title": "Paris Summer 2026", "description": "Two weeks" }
```
Create Place:
```json
{ "trip_id": "<uuid>", "name": "Eiffel Tower", "lat": 48.8584, "lng": 2.2945 }
```


## End of Handbook
If this file becomes too large, split it into multiple docs under `frontend/docs` and keep a short README that links to them.
