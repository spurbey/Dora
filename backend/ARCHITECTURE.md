# Backend Architecture Documentation

> Auto-generated from codebase exploration. Use this as reference instead of re-exploring.

## Overview

**Stack**: FastAPI + PostgreSQL + PostGIS + Supabase
**Purpose**: Two-sided travel platform API - Creators build travelogues, Planners discover content.

---

## API Endpoints Reference

### Authentication (`/api/v1/auth`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/auth/me` | Get current user info + stats (trip_count, place_count) | Required |

### Users (`/api/v1/users`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/users/me` | Get current user profile | Required |
| PATCH | `/users/me` | Update profile (username, full_name, bio, avatar_url) | Required |
| GET | `/users/me/stats` | Get detailed stats (trips, places, views, saves, photos) | Required |
| GET | `/users/me/profile` | Get complete profile with stats | Required |

### Trips (`/api/v1/trips`)

| Method | Endpoint | Purpose | Auth | Access |
|--------|----------|---------|------|--------|
| POST | `/trips` | Create new trip | Required | Owner |
| GET | `/trips` | List user's trips (paginated) | Required | Owner |
| GET | `/trips/{trip_id}` | Get trip details (increments view count) | Required | Owner or Public/Unlisted |
| PATCH | `/trips/{trip_id}` | Update trip | Required | Owner only |
| DELETE | `/trips/{trip_id}` | Delete trip (cascades to places/routes) | Required | Owner only |
| GET | `/trips/{trip_id}/bounds` | Get map bounding box for places | Required | Owner or Public/Unlisted |

**Pagination**: `page` (1+), `page_size` (1-100, default 20)
**Limits**: Free tier = 3 trips, Premium = unlimited

### Places (`/api/v1/places`)

| Method | Endpoint | Purpose | Auth | Access |
|--------|----------|---------|------|--------|
| POST | `/places` | Create place in trip | Required | Owner |
| GET | `/places?trip_id=...` | List places for trip (ordered) | Required | Owner or Public/Unlisted |
| GET | `/places/nearby` | Find nearby places (PostGIS spatial) | Required | Own places |
| GET | `/places/{place_id}` | Get place details + media | Required | Owner or Public/Unlisted |
| PATCH | `/places/{place_id}` | Update place | Required | Owner only |
| DELETE | `/places/{place_id}` | Delete place | Required | Owner only |

**Nearby params**: `lat`, `lng`, `radius` (0.1-50 km, default 5)

### Media (`/api/v1/media`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | `/media/upload` | Upload photo (multipart) | Required, Owner |
| GET | `/media/{media_id}` | Get media details | Required |
| DELETE | `/media/{media_id}` | Delete media + storage file | Required, Owner |

**Storage**: Supabase Storage at `photos/{user_id}/{uuid}.ext`
**Limits**: Free = 10MB/photo, Premium = 100MB/photo

### Search (`/api/v1/search`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/search/places` | Multi-source search (local + Foursquare) | Required |

**Params**: `query` (1-100 chars), `lat`, `lng`, `radius_km` (0.1-50), `limit` (1-50), `debug`
**Strategy**: Local DB first → Foursquare fallback → Deduplicate (90% name + 50m distance) → Rank

### Routes (`/api/v1/routes`)

| Method | Endpoint | Purpose | Auth | Access |
|--------|----------|---------|------|--------|
| GET | `/trips/{trip_id}/routes` | List routes for trip | Required | Owner or Public/Unlisted |
| POST | `/trips/{trip_id}/routes` | Create route | Required | Owner only |
| GET | `/routes/{route_id}` | Get route details | Required | Owner or Public/Unlisted |
| PATCH | `/routes/{route_id}` | Update route | Required | Owner only |
| DELETE | `/routes/{route_id}` | Delete route | Required | Owner only |
| POST | `/routes/generate` | Auto-generate via Mapbox Directions | Required | - |

**Generate params**: `coordinates` (array of [lng, lat]), `mode` (driving|cycling|walking)
**Returns**: `distance_km`, `duration_mins`, `route_geojson`, `polyline_encoded`

### Waypoints (`/api/v1/routes`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | `/routes/{route_id}/waypoints` | Add waypoint to route | Required, Owner |
| GET | `/routes/{route_id}/waypoints` | List waypoints for route | Required |
| PATCH | `/waypoints/{waypoint_id}` | Update waypoint | Required, Owner |
| DELETE | `/waypoints/{waypoint_id}` | Delete waypoint | Required, Owner |

### Trip Metadata (`/api/v1`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | `/trips/{trip_id}/metadata` | Create trip metadata | Required, Owner |
| GET | `/trips/{trip_id}/metadata` | Get trip metadata | Required |
| PATCH | `/trips/{trip_id}/metadata` | Update metadata | Required, Owner |
| DELETE | `/trips/{trip_id}/metadata` | Delete metadata (trip preserved) | Required, Owner |

### Place Metadata (`/api/v1`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | `/places/{place_id}/metadata` | Create place metadata | Required, Owner |
| GET | `/places/{place_id}/metadata` | Get place metadata | Required |
| PATCH | `/places/{place_id}/metadata` | Update metadata | Required, Owner |
| DELETE | `/places/{place_id}/metadata` | Delete metadata | Required, Owner |

### Route Metadata (`/api/v1`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | `/routes/{route_id}/metadata` | Create route metadata | Required, Owner |
| GET | `/routes/{route_id}/metadata` | Get route metadata | Required |
| PATCH | `/routes/{route_id}/metadata` | Update metadata | Required, Owner |
| DELETE | `/routes/{route_id}/metadata` | Delete metadata | Required, Owner |

### Components (Unified Timeline) (`/api/v1`)

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/trips/{trip_id}/components` | Get unified timeline (places + routes) | Required |
| PATCH | `/trips/{trip_id}/components/reorder` | Bulk reorder components | Required, Owner |
| GET | `/trips/{trip_id}/components/{id}` | Get component details | Required |

---

## Data Models

### User
```python
id: UUID                    # Matches Supabase Auth
email: str                  # Unique, indexed
username: str               # 3-50 chars, unique, indexed
hashed_password: str        # Bcrypt
full_name: str | None
avatar_url: str | None
bio: str | None
is_premium: bool            # Default: false
is_verified: bool           # Default: false
subscription_ends_at: datetime | None
created_at: datetime
updated_at: datetime
last_login: datetime | None
```

### Trip
```python
id: UUID
user_id: UUID               # FK to users, CASCADE
title: str                  # 1-255 chars, required
description: str | None
start_date: date | None
end_date: date | None       # Must be >= start_date
cover_photo_url: str | None
visibility: str             # private|unlisted|public, default: private
views_count: int            # Default: 0
saves_count: int            # Default: 0
created_at: datetime
updated_at: datetime
```

### TripPlace (with PostGIS)
```python
id: UUID
trip_id: UUID               # FK to trips, CASCADE
user_id: UUID               # FK to users, CASCADE
name: str                   # Required
place_type: str | None      # restaurant, hotel, attraction, etc.
location: Geography(Point)  # PostGIS, SRID=4326
lat: float                  # Convenience column
lng: float                  # Convenience column
user_notes: str | None
user_rating: int | None     # 1-5
visit_date: date | None
photos: JSONB               # Array of media IDs
videos: JSONB               # Array of video objects
external_data: JSONB        # Cached Foursquare/Mapbox data
order_in_trip: int          # Position in itinerary
search_vector: TSVECTOR     # Full-text search, auto-updated
created_at: datetime
updated_at: datetime
```

**Indexes**: GIST spatial index on `location`, GIN on `search_vector`

### Route
```python
id: UUID
trip_id: UUID               # FK to trips, CASCADE
user_id: UUID               # FK to users, CASCADE
route_geojson: JSONB        # GeoJSON LineString, required
polyline_encoded: str | None
start_place_id: UUID | None # FK to trip_places, SET NULL
end_place_id: UUID | None   # FK to trip_places, SET NULL
transport_mode: str         # car|bike|foot|air|bus|train, required
route_category: str         # ground|air, required
distance_km: float | None   # Auto-calculated
duration_mins: int | None   # Auto-calculated
order_in_trip: int          # Required, >= 0
name: str | None
description: str | None
created_at: datetime
updated_at: datetime
```

### Waypoint
```python
id: UUID
route_id: UUID              # FK to routes, CASCADE
trip_id: UUID               # FK to trips, CASCADE
user_id: UUID               # FK to users, CASCADE
lat: float                  # Required
lng: float                  # Required
order_in_route: int         # Required
name: str | None
notes: str | None
created_at: datetime
updated_at: datetime
```

### MediaFile
```python
id: UUID
user_id: UUID               # FK to users, CASCADE, indexed
trip_place_id: UUID         # FK to trip_places, CASCADE, indexed
file_url: str               # Supabase Storage URL
file_type: str              # photo|video
file_size_bytes: int
mime_type: str              # image/jpeg, image/png, video/mp4, etc.
width: int | None           # For images
height: int | None          # For images
thumbnail_url: str          # Supabase transformation URL
caption: str | None
taken_at: datetime | None
created_at: datetime
```

**Storage Path**: `photos/{user_id}/{uuid}.{ext}`

### TripMetadata
```python
trip_id: UUID               # PK, FK to trips, CASCADE

# Traveler Profile
traveler_type: list[str]    # [solo, couple, family, group]
age_group: str | None       # gen-z, millennial, gen-x, boomer

# Trip Characteristics
travel_style: list[str]     # [adventure, luxury, budget, cultural, relaxed]
difficulty_level: str | None # easy, moderate, challenging, extreme
budget_category: str | None  # budget, mid-range, luxury
activity_focus: list[str]   # [hiking, food, photography, nightlife, beaches]

# Discovery
is_discoverable: bool       # Default: false
quality_score: float | None # 0-1, system-calculated
tags: list[str]             # User-defined, GIN indexed

created_at: datetime
updated_at: datetime
```

**Indexes**: GIN indexes on all ARRAY fields

### PlaceMetadata
```python
place_id: UUID              # PK, FK to trip_places, CASCADE

# Content
component_type: str | None  # city, place, activity, accommodation, food, transport
experience_tags: list[str]  # e.g., ["scenic", "peaceful"]
best_for: list[str]         # e.g., ["families", "couples"]

# Details
budget_per_person: float | None  # USD
duration_hours: float | None     # Recommended time
difficulty_rating: int | None    # 1-5
physical_demand: str | None      # low, medium, high
best_time: str | None            # Seasonal guidance
is_public: bool                  # Discoverable

created_at: datetime
updated_at: datetime
```

### RouteMetadata
```python
route_id: UUID              # PK, FK to routes, CASCADE
transport_style: str | None # adventurous, scenic, fastest, etc.
difficulty_rating: int | None # 1-5
best_for: list[str]
created_at: datetime
updated_at: datetime
```

---

## Authentication Flow

### Supabase JWT Verification
1. Extract token from `Authorization: Bearer {token}` header
2. Fetch Supabase JWKS (public keys) via `GET /.well-known/jwks.json`
3. Verify JWT signature with **ES256** (asymmetric, not HS256)
4. Validate audience claim = "authenticated"
5. Extract `user_id` from "sub" claim
6. Query database for user
7. If user not found: Auto-create from token (email, full_name, avatar)
8. Return User object

### Error Responses
- **401**: Invalid/expired token, missing user
- **503**: JWKS endpoint unreachable

### Important Notes
- Backend **never creates tokens** - Supabase Auth handles login/signup
- No `SUPABASE_JWT_SECRET` stored (uses JWKS verification)
- Token refresh handled by client using Supabase SDK

---

## External API Integrations

### Foursquare Places API
**Location**: `backend/app/services/providers.py` (FoursquareSearchProvider)

```
Endpoint: https://api.foursquare.com/v3/places/search
Auth: API key in X-Foursquare-API-Key header
Env: FOURSQUARE_API_KEY
```

**Search Strategy**:
1. Search local database first (user-contributed places)
2. If results < limit, query Foursquare
3. Deduplicate: Name similarity >= 90% (rapidfuzz) AND distance <= 50m
4. Local results ALWAYS win over Foursquare
5. Rank by relevance score

### Mapbox Directions API
**Location**: `backend/app/services/route_service.py`

```
Endpoint: https://api.mapbox.com/directions/v5/mapbox/{mode}
Modes: driving, cycling, walking
Auth: access_token query param
Env: MAPBOX_API_KEY
```

**Usage**: `POST /api/v1/routes/generate` calls Mapbox and returns formatted GeoJSON

---

## File Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app entry
│   ├── models/              # SQLAlchemy models
│   │   ├── user.py
│   │   ├── trip.py
│   │   ├── trip_place.py
│   │   ├── route.py
│   │   ├── waypoint.py
│   │   ├── media.py
│   │   ├── trip_metadata.py
│   │   ├── place_metadata.py
│   │   └── route_metadata.py
│   ├── schemas/             # Pydantic schemas
│   │   ├── user.py
│   │   ├── trip.py
│   │   ├── place.py
│   │   ├── route.py
│   │   ├── media.py
│   │   └── metadata.py
│   ├── api/v1/              # API endpoints
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── trips.py
│   │   ├── places.py
│   │   ├── media.py
│   │   ├── search.py
│   │   ├── routes.py
│   │   ├── waypoints.py
│   │   ├── trip_metadata.py
│   │   ├── place_metadata.py
│   │   ├── route_metadata.py
│   │   └── components.py
│   ├── services/            # Business logic
│   │   ├── auth_service.py
│   │   ├── trip_service.py
│   │   ├── place_service.py
│   │   ├── media_service.py
│   │   ├── search_service.py
│   │   ├── route_service.py
│   │   └── providers.py     # Foursquare provider
│   ├── core/
│   │   ├── config.py        # Settings
│   │   ├── database.py      # DB connection
│   │   └── security.py      # JWT utils
│   └── dependencies/
│       └── auth.py          # get_current_user
├── migrations/              # Alembic migrations
│   └── versions/
├── tests/
└── CLAUDE.md               # Backend-specific rules
```

---

## Environment Variables

```bash
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=<public_key>
SUPABASE_SERVICE_ROLE_KEY=<secret_key>
SUPABASE_DB_URL=postgresql://user:pass@host:5432/db

# External APIs
FOURSQUARE_API_KEY=<key>
MAPBOX_API_KEY=<key>

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success (GET, PATCH with body) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad Request (validation) |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (not owner, trip private) |
| 404 | Not Found |
| 409 | Conflict (resource exists) |
| 422 | Validation Error (enum fields) |
| 500 | Server Error |
| 503 | External API unavailable |

---

## Key Patterns

### Resource Ownership
- All resources (trips, places, routes) are user-owned
- Access: Owner always allowed, non-owners only if public/unlisted
- Backend enforces: Never trust client-provided user_id

### Pagination
- Supported on: `/trips` list
- Params: `page` (1+), `page_size` (1-100, default 20)
- Response: `{ items[], total, page, page_size, total_pages }`

### Partial Updates
- All PATCH endpoints support partial updates
- Only provided fields are updated
- Request body: All fields optional

### PostGIS Spatial
- `GET /places/nearby?lat=X&lng=Y&radius=R`
- Uses Geography type for accuracy
- GIST spatial index for performance
- ST_DWithin for radius searches

### Metadata Pattern
- Not stored in main resource table
- 1:1 optional relationship (can exist later)
- Separate CRUD endpoints per resource type
- Enables soft feature rollout

---

*Last updated: 2026-02-04*
