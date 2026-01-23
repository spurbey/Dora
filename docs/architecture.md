# System Architecture - Travel Memory Vault

## Overview
Hybrid architecture using Supabase for infrastructure + FastAPI for business logic.

## Tech Stack
- Backend: FastAPI (Python 3.11+)
- Database: Supabase PostgreSQL + PostGIS
- Auth: Supabase Auth (JWT)
- Storage: Supabase Storage (S3-compatible)
- Frontend: React 18 + Vite + TypeScript
- Maps: Mapbox GL JS
- External APIs: Foursquare (places), Mapbox (geocoding)

---

## Complete Project Structure
```
travel-memory-vault/
│
├── .git/                           # Git repository
├── .gitignore                      # Git ignore rules
├── README.md                       # Project overview
│
├── .claude/                        # AI development instructions
│   ├── CLAUDE.md                   # Main AI instructions (~150 lines)
│   ├── PROJECT_STATUS.md           # Current state, progress tracking
│   ├── CURRENT_PHASE.md            # Active phase details
│   │
│   ├── skills/                     # Reusable commands
│   │   ├── new-session.md          # Start session workflow
│   │   ├── commit.md               # Structured commit format
│   │   ├── close-session.md        # End session workflow
│   │   ├── api-endpoint.md         # FastAPI endpoint pattern
│   │   ├── supabase-table.md       # Table creation with RLS
│   │   ├── react-page.md           # React page pattern
│   │   ├── search-service.md       # Multi-source search pattern
│   │   └── media-upload.md         # Supabase Storage upload pattern
│   │
│   ├── agents/                     # Autonomous workflows
│   │   ├── backend-builder.md      # Build API resource autonomously
│   │   ├── frontend-builder.md     # Build React page autonomously
│   │   ├── test-runner.md          # Run tests, fix failures
│   │   └── code-reviewer.md        # Pre-commit review checklist
│   │
│   └── hooks/                      # Automation triggers
│       ├── pre-commit.md           # Lint, type check, secret detection
│       └── post-task.md            # Update PROJECT_STATUS.md
│
├── docs/                           # Reference documentation
│   ├── architecture.md             # This file - system design
│   │
│   ├── phases/                     # Mini-PRDs (one per session)
│   │   ├── phase-0-manual-setup.md # Human does this first
│   │   ├── phase-0-setup.md        # Sessions 1-2: Supabase + FastAPI
│   │   ├── phase-1a-auth.md        # Sessions 3-4: Authentication
│   │   ├── phase-1b-trips.md       # Sessions 5-7: Trip CRUD
│   │   ├── phase-1c-places.md      # Sessions 8-10: Places + PostGIS
│   │   ├── phase-2a-media.md       # Sessions 11-13: Media upload
│   │   ├── phase-2b-search.md      # Sessions 14-16: Multi-source search
│   │   ├── phase-3a-frontend.md    # Sessions 17-20: React + Mapbox
│   │   └── phase-3b-integration.md # Sessions 21-25: Integration + Deploy
│   │
│   ├── schemas/                    # Database schema reference
│   │   └── database.md             # Complete SQL schema + PostGIS functions
│   │
│   ├── apis/                       # External API integration guides
│   │   ├── foursquare.md           # Foursquare Places API
│   │   ├── mapbox.md               # Mapbox Geocoding/Search/Directions
│   │   └── supabase.md             # Supabase client usage
│   │
│   └── supabase/                   # Supabase setup guides
│       ├── setup-guide.md          # Initial project setup
│       ├── rls-policies.md         # Row-Level Security policies
│       └── storage-buckets.md      # Storage bucket configuration
│
├── backend/                        # FastAPI backend
│   ├── CLAUDE.md                   # Backend-specific AI instructions
│   ├── .env.example                # Environment variables template
│   ├── .env                        # Actual credentials (gitignored)
│   ├── requirements.txt            # Python dependencies
│   ├── requirements-dev.txt        # Development dependencies
│   ├── pyproject.toml              # Ruff and mypy configuration
│   ├── pytest.ini                  # Pytest configuration
│   │
│   ├── alembic/                    # Database migrations
│   │   ├── versions/               # Migration files
│   │   ├── env.py                  # Alembic environment config
│   │   └── script.py.mako          # Migration template
│   ├── alembic.ini                 # Alembic configuration
│   │
│   ├── app/                        # Main application code
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI app, CORS, router registration
│   │   ├── config.py               # Settings from environment variables
│   │   ├── database.py             # SQLAlchemy engine, session, Base
│   │   ├── dependencies.py         # Shared dependencies (get_db, get_current_user)
│   │   │
│   │   ├── models/                 # SQLAlchemy ORM models
│   │   │   ├── __init__.py
│   │   │   ├── user.py             # User model
│   │   │   ├── trip.py             # Trip model
│   │   │   ├── place.py            # TripPlace model (with PostGIS)
│   │   │   ├── route.py            # TripRoute model (with PostGIS)
│   │   │   ├── media.py            # MediaFile model
│   │   │   └── subscription.py     # Subscription model
│   │   │
│   │   ├── schemas/                # Pydantic request/response schemas
│   │   │   ├── __init__.py
│   │   │   ├── user.py             # UserCreate, UserUpdate, UserResponse
│   │   │   ├── trip.py             # TripCreate, TripUpdate, TripResponse
│   │   │   ├── place.py            # PlaceCreate, PlaceUpdate, PlaceResponse
│   │   │   ├── route.py            # RouteCreate, RouteResponse
│   │   │   ├── media.py            # MediaCreate, MediaResponse
│   │   │   ├── auth.py             # Token, Login schemas
│   │   │   └── common.py           # Shared schemas (Pagination, Coordinates)
│   │   │
│   │   ├── api/                    # API routes
│   │   │   ├── __init__.py
│   │   │   └── v1/                 # API version 1
│   │   │       ├── __init__.py
│   │   │       ├── auth.py         # Auth endpoints (/me)
│   │   │       ├── users.py        # User profile endpoints
│   │   │       ├── trips.py        # Trip CRUD endpoints
│   │   │       ├── places.py       # Place CRUD endpoints
│   │   │       ├── routes.py       # Route endpoints
│   │   │       ├── media.py        # Media upload/management
│   │   │       ├── search.py       # Multi-source search
│   │   │       └── subscriptions.py # Stripe subscription endpoints
│   │   │
│   │   ├── services/               # Business logic layer
│   │   │   ├── __init__.py
│   │   │   ├── auth_service.py     # JWT validation, user auth
│   │   │   ├── user_service.py     # User CRUD, stats
│   │   │   ├── trip_service.py     # Trip CRUD, bounds calculation
│   │   │   ├── place_service.py    # Place CRUD, geospatial queries
│   │   │   ├── route_service.py    # Route creation, distance calc
│   │   │   ├── media_service.py    # Upload to Supabase Storage
│   │   │   ├── storage_service.py  # S3/R2 abstraction
│   │   │   ├── search_service.py   # Multi-source place search
│   │   │   ├── foursquare_service.py # Foursquare API wrapper
│   │   │   ├── mapbox_service.py   # Mapbox API wrapper
│   │   │   ├── osm_service.py      # Nominatim/OSM queries
│   │   │   └── stripe_service.py   # Stripe integration
│   │   │
│   │   └── utils/                  # Helper utilities
│   │       ├── __init__.py
│   │       ├── security.py         # Password hashing, JWT creation
│   │       ├── validators.py       # Custom validators
│   │       ├── geo.py              # Geospatial helpers (distance, bounds)
│   │       └── email.py            # Email sending (optional)
│   │
│   └── tests/                      # Pytest test suite
│       ├── __init__.py
│       ├── conftest.py             # Pytest fixtures (client, db, auth)
│       ├── test_auth.py            # Auth endpoint tests
│       ├── test_users.py           # User endpoint tests
│       ├── test_trips.py           # Trip CRUD tests
│       ├── test_places.py          # Place CRUD tests
│       ├── test_places_spatial.py  # PostGIS query tests
│       ├── test_routes.py          # Route tests
│       ├── test_media.py           # Media upload tests
│       └── test_search.py          # Search service tests
│
└── frontend/                       # React frontend
    ├── CLAUDE.md                   # Frontend-specific AI instructions
    ├── .env.example                # Environment variables template
    ├── .env                        # Actual credentials (gitignored)
    ├── package.json                # Node dependencies
    ├── package-lock.json           # Locked dependencies
    ├── vite.config.ts              # Vite configuration
    ├── tsconfig.json               # TypeScript configuration
    ├── tsconfig.node.json          # TypeScript for Vite
    ├── tailwind.config.js          # Tailwind CSS configuration
    ├── postcss.config.js           # PostCSS configuration
    ├── index.html                  # HTML entry point
    │
    ├── public/                     # Static assets
    │   ├── favicon.ico
    │   └── assets/
    │       └── images/
    │
    └── src/                        # Source code
        ├── main.tsx                # React entry point
        ├── App.tsx                 # Root component with routing
        ├── index.css               # Global styles (Tailwind imports)
        │
        ├── components/             # Reusable UI components
        │   ├── ui/                 # shadcn/ui components
        │   │   ├── button.tsx
        │   │   ├── input.tsx
        │   │   ├── dialog.tsx
        │   │   ├── card.tsx
        │   │   └── ...
        │   │
        │   ├── Map/                # Mapbox components
        │   │   ├── MapView.tsx              # Main map wrapper
        │   │   ├── PlaceMarker.tsx          # Custom markers
        │   │   ├── RouteLayer.tsx           # Route drawing
        │   │   ├── MapControls.tsx          # Zoom, geolocation
        │   │   └── MapSearchBox.tsx         # Search within map
        │   │
        │   ├── Trip/               # Trip-specific components
        │   │   ├── TripCard.tsx             # Trip list item
        │   │   ├── TripForm.tsx             # Create/edit modal
        │   │   ├── TripTimeline.tsx         # Timeline view
        │   │   ├── TripMap.tsx              # Trip map view
        │   │   ├── TripHeader.tsx           # Title, dates, share
        │   │   └── TripStats.tsx            # Distance, place count
        │   │
        │   ├── Place/              # Place-specific components
        │   │   ├── PlaceCard.tsx            # Place display
        │   │   ├── PlaceForm.tsx            # Add/edit place
        │   │   ├── PlaceSearch.tsx          # Search places to add
        │   │   ├── PlacePhotos.tsx          # Photo gallery
        │   │   ├── PlaceDetailSidebar.tsx   # Sidebar with details
        │   │   └── PlaceListItem.tsx        # Place in timeline
        │   │
        │   ├── Media/              # Media components
        │   │   ├── PhotoUpload.tsx          # Drag-drop upload
        │   │   ├── PhotoGallery.tsx         # Photo grid
        │   │   ├── Lightbox.tsx             # Full-screen viewer
        │   │   └── VideoPlayer.tsx          # Video playback
        │   │
        │   ├── Layout/             # Layout components
        │   │   ├── Navbar.tsx               # Top navigation
        │   │   ├── Sidebar.tsx              # Side navigation
        │   │   ├── Footer.tsx               # Footer
        │   │   └── PageContainer.tsx        # Page wrapper
        │   │
        │   ├── Auth/               # Auth components
        │   │   ├── LoginForm.tsx            # Login modal
        │   │   ├── RegisterForm.tsx         # Registration modal
        │   │   ├── ForgotPasswordForm.tsx   # Password reset
        │   │   └── ProtectedRoute.tsx       # Route guard
        │   │
        │   └── Shared/             # Shared utilities
        │       ├── LoadingSpinner.tsx       # Loading states
        │       ├── EmptyState.tsx           # No data placeholder
        │       ├── ErrorBoundary.tsx        # Error handling
        │       ├── ConfirmDialog.tsx        # Confirmation modals
        │       └── ShareButton.tsx          # Copy link
        │
        ├── pages/                  # Route pages
        │   ├── Home.tsx                     # Landing page
        │   ├── Login.tsx                    # Login page
        │   ├── Register.tsx                 # Registration page
        │   ├── Dashboard.tsx                # User's trip list
        │   ├── TripDetail.tsx               # Single trip (map mode)
        │   ├── TripEdit.tsx                 # Edit trip mode
        │   ├── TripTimeline.tsx             # Timeline view
        │   ├── Profile.tsx                  # User profile
        │   ├── Settings.tsx                 # Account settings
        │   ├── Pricing.tsx                  # Premium pricing
        │   ├── Discover.tsx                 # Public trips (Phase 2)
        │   ├── NotFound.tsx                 # 404 page
        │   └── PrivacyPolicy.tsx            # Legal page
        │
        ├── hooks/                  # Custom React hooks
        │   ├── useAuth.ts                   # Authentication state
        │   ├── useTrips.ts                  # Trip CRUD with React Query
        │   ├── usePlaces.ts                 # Place operations
        │   ├── useRoutes.ts                 # Route operations
        │   ├── useMap.ts                    # Mapbox instance management
        │   ├── useMediaUpload.ts            # File upload with progress
        │   ├── useGeolocation.ts            # User's current location
        │   ├── useDebounce.ts               # Debounce for search
        │   └── useLocalStorage.ts           # Persist state
        │
        ├── services/               # API client layer
        │   ├── api.ts                       # Axios instance with interceptors
        │   ├── authService.ts               # Login, register, logout
        │   ├── tripService.ts               # Trip CRUD
        │   ├── placeService.ts              # Place CRUD
        │   ├── routeService.ts              # Route CRUD
        │   ├── mediaService.ts              # Upload, delete media
        │   ├── searchService.ts             # Place search (multi-source)
        │   ├── userService.ts               # User profile
        │   └── subscriptionService.ts       # Stripe checkout, billing
        │
        ├── store/                  # Zustand global state
        │   ├── authStore.ts                 # User, token, isAuthenticated
        │   ├── tripStore.ts                 # Current trip context
        │   ├── mapStore.ts                  # Map viewport, selected place
        │   └── uiStore.ts                   # Modals, toasts, sidebar
        │
        ├── lib/                    # Third-party configs
        │   ├── supabase.ts                  # Supabase client
        │   ├── queryClient.ts               # React Query config
        │   └── stripe.ts                    # Stripe.js setup (optional)
        │
        ├── utils/                  # Helper functions
        │   ├── constants.ts                 # API URLs, config
        │   ├── validators.ts                # Form validation
        │   ├── formatters.ts                # Date, distance, currency
        │   ├── geo.ts                       # Lat/lng calculations
        │   ├── storage.ts                   # localStorage helpers
        │   └── errors.ts                    # Error message mapping
        │
        ├── types/                  # TypeScript interfaces
        │   ├── user.ts                      # User, UserProfile
        │   ├── trip.ts                      # Trip, TripCreate, TripUpdate
        │   ├── place.ts                     # Place, PlaceCreate, Coordinates
        │   ├── route.ts                     # Route, RouteGeometry
        │   ├── media.ts                     # MediaFile, UploadProgress
        │   ├── subscription.ts              # Subscription, Plan
        │   └── api.ts                       # ApiResponse, PaginatedResponse
        │
        └── styles/                 # Additional styles
            ├── globals.css                  # Global CSS, Tailwind imports
            ├── mapbox.css                   # Mapbox style overrides
            └── animations.css               # Custom animations
```

---

## Data Flow Diagrams

### Authentication Flow
```
User Registration:
Frontend → Supabase Auth → JWT token → Frontend stores in localStorage

API Request:
Frontend → Include JWT in Authorization header → FastAPI validates JWT → 
Extract user_id from token → Query Supabase DB → Return user object
```

### Place Search Flow
```
User Search Query:
Frontend → FastAPI /search/places → SearchService:
  1. Query local DB (PostGIS spatial query)
  2. If < 5 results → Query Foursquare API
  3. If < 5 results → Query Mapbox Search API
  4. Deduplicate by name + fuzzy coords
  5. Rank: user_contributed > external
→ Return merged results → Frontend displays
```

### Photo Upload Flow
```
User selects photo:
Frontend → Validate file (type, size) → POST /media/upload (multipart/form-data) → 
FastAPI → Check ownership → Upload to Supabase Storage → Get public URL → 
Save metadata to media_files table → Return URL → Frontend displays
```

### Trip Display Flow
```
User opens trip:
Frontend → GET /trips/{id} → FastAPI:
  1. Query trip from DB
  2. Query places for trip (with PostGIS)
  3. Calculate bounds: SELECT MIN(lat), MAX(lat), MIN(lng), MAX(lng)
  4. Include photos from media_files
→ Return complete trip object → Frontend renders on Mapbox
```

---

## Key Architectural Decisions

### Why Supabase + FastAPI (Hybrid)?
- **Supabase handles:** Auth, Database hosting, Storage, Realtime (future)
- **FastAPI handles:** Business logic, external API integration, complex queries
- **Benefit:** Managed infrastructure + custom logic flexibility

### Why PostGIS?
- Need spatial queries: "places within 5km", "calculate distance"
- PostGIS provides: ST_Distance, ST_DWithin, GIST indexes
- Alternative (just lat/lng) would require complex Haversine formulas in Python

### Why Mapbox (not Google Maps)?
- **Legal:** Google Maps ToS forbids use with non-Google map tiles
- **Cost:** Mapbox cheaper ($5 per 1k loads vs Google $7)
- **Flexibility:** Full control over styling, interactions

### Why Multi-Source Search?
- **Coverage:** No single API has all places (especially local, hidden gems)
- **Cost:** Query free local DB first, expensive APIs only when needed
- **Quality:** User-contributed places are highest quality (verified by travelers)

---

## Database Schema (Core Tables)

See `docs/schemas/database.md` for complete schema.

**Key tables:**
- `users` - User accounts, premium status
- `trips` - User's travel trips
- `trip_places` - Places within trips (PostGIS Geography column)
- `trip_routes` - Routes between places (PostGIS LineString)
- `media_files` - Photos/videos metadata
- `subscriptions` - Stripe subscription tracking

**PostGIS columns:**
- `trip_places.location` - Geography(Point, 4326)
- `trip_routes.path` - Geography(LineString, 4326)

**Spatial indexes:**
- `idx_trip_places_location` - GIST index for fast radius queries
- `idx_trip_routes_path` - GIST index for route queries

---

## External API Integration

### Foursquare Places API
- **Purpose:** Restaurant, hotel, attraction search
- **Endpoint:** `/v3/places/search`
- **Free tier:** 100k calls/month
- **Usage:** Fallback when local DB has < 5 results

### Mapbox APIs
- **Geocoding:** Address ↔ coordinates conversion
- **Search:** POI search with type filters
- **Directions:** A→B routing (optional, or use OSRM)
- **Free tier:** 100k requests/month per API

### Supabase APIs
- **Auth:** User signup, login, JWT validation
- **Storage:** Photo/video upload, signed URLs
- **Database:** Direct SQL queries (via FastAPI connection)

---

## Security Model

### Authentication
- Supabase Auth generates JWT tokens
- FastAPI validates JWT on every request
- User identity from JWT payload (`sub` field)

### Authorization
- All queries filtered by `user_id`
- Update/delete endpoints check resource ownership
- RLS policies in Supabase as backup (defense-in-depth)

### Data Privacy
- Private trips: Only owner can view
- Unlisted trips: Anyone with link can view
- Public trips: Anyone can view
- Storage bucket folders: `{user_id}/` (user-specific)

---

## Deployment Architecture

### Production Setup
```
Frontend (Vercel)
   ↓ HTTPS
Backend (Railway/Fly.io)
   ↓ PostgreSQL connection
Supabase (managed)
   ├── PostgreSQL + PostGIS
   ├── Auth service
   └── Storage buckets
```

### Environment Separation
- **Development:** localhost, Supabase dev project
- **Production:** Vercel + Railway, Supabase prod project
- **Environment variables:** Separate .env files, never committed

---

## Performance Considerations

### Database
- Spatial indexes for fast geoqueries
- Foreign key indexes for joins
- Connection pooling (SQLAlchemy)

### API
- Pagination on list endpoints (default 20 items)
- Caching external API responses (Redis, optional)
- Async HTTP calls (httpx) for external APIs

### Frontend
- React.memo for expensive components
- React Query caching (5 min default)
- Lazy loading for images
- Code splitting for routes

---

## Cost Estimates (Monthly)

### Free Tier (0-1000 users)
- Supabase: $0 (free tier)
- Mapbox: $0 (free tier 50k loads)
- Foursquare: $0 (free tier 100k calls)
- Railway: $5 (backend hosting)
- Vercel: $0 (hobby tier)
**Total: ~$5/month**

### Paid Tier (1k-10k users)
- Supabase Pro: $25
- Mapbox: $50 (beyond free tier)
- Foursquare: $50 (beyond free tier)
- Railway: $20
- Vercel: $20
**Total: ~$165/month**

---

## File Naming Conventions

### Backend (Python)
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions: `snake_case`
- Constants: `UPPER_SNAKE_CASE`

### Frontend (TypeScript)
- Components: `PascalCase.tsx`
- Hooks: `use*.ts`
- Services: `*Service.ts`
- Types: `*.ts`
- Utils: `camelCase.ts`

### Database
- Tables: `snake_case` (plural)
- Columns: `snake_case`
- Indexes: `idx_table_column`

---

**This architecture provides Claude Code with complete context for where every file should live and how components interact.**