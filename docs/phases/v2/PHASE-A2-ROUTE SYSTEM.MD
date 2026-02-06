

# **PHASE A2: Route System - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** A2  
**Duration:** 4 days  
**Dependencies:** Phase A1 (completed)  
**Goal:** Add route drawing and waypoint infrastructure

---

## **🎯 Objectives**

Enable users to draw/save routes between places with metadata (transport mode, road quality, safety).

**Deliverables:**
- 3 new tables: `routes`, `waypoints`, `route_metadata`
- 10 API endpoints for route/waypoint CRUD
- Mapbox Directions API integration
- Tests

---

## **🗄️ Database Schema**

### **Table 1: routes**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | PK |
| `trip_id` | UUID | NO | FK to trips |
| `user_id` | UUID | NO | FK to users |
| `route_geojson` | JSONB | NO | GeoJSON LineString |
| `polyline_encoded` | TEXT | YES | Google-encoded polyline (optional) |
| `start_place_id` | UUID | YES | FK to trip_places |
| `end_place_id` | UUID | YES | FK to trip_places |
| `transport_mode` | TEXT | NO | 'car', 'bike', 'foot', 'air', 'bus', 'train' |
| `route_category` | TEXT | NO | 'ground', 'air' |
| `distance_km` | FLOAT | YES | Auto-calculated |
| `duration_mins` | INTEGER | YES | Auto-calculated |
| `order_in_trip` | INTEGER | NO | Display order |
| `name` | TEXT | YES | Optional route name |
| `description` | TEXT | YES | User notes |
| `created_at` | TIMESTAMP | NO | NOW() |
| `updated_at` | TIMESTAMP | NO | NOW() |

**Indexes:**
```sql
PRIMARY KEY (id)
FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
FOREIGN KEY (start_place_id) REFERENCES trip_places(id) ON DELETE SET NULL
FOREIGN KEY (end_place_id) REFERENCES trip_places(id) ON DELETE SET NULL

CREATE INDEX idx_routes_trip ON routes(trip_id);
CREATE INDEX idx_routes_order ON routes(trip_id, order_in_trip);
```

**Constraints:**
```sql
CHECK (transport_mode IN ('car', 'bike', 'foot', 'air', 'bus', 'train'))
CHECK (route_category IN ('ground', 'air'))
CHECK (distance_km >= 0 OR distance_km IS NULL)
CHECK (duration_mins >= 0 OR duration_mins IS NULL)
CHECK (order_in_trip >= 0)
```

---

### **Table 2: waypoints**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | PK |
| `route_id` | UUID | NO | FK to routes |
| `trip_id` | UUID | NO | FK to trips |
| `user_id` | UUID | NO | FK to users |
| `lat` | FLOAT | NO | Latitude |
| `lng` | FLOAT | NO | Longitude |
| `name` | TEXT | NO | Waypoint label |
| `waypoint_type` | TEXT | NO | 'stop', 'note', 'photo', 'poi' |
| `notes` | TEXT | YES | User notes |
| `order_in_route` | INTEGER | NO | Position along route |
| `stopped_at` | TIMESTAMP | YES | When user stopped here |
| `created_at` | TIMESTAMP | NO | NOW() |

**Indexes:**
```sql
PRIMARY KEY (id)
FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE

CREATE INDEX idx_waypoints_route ON waypoints(route_id, order_in_route);
```

**Constraints:**
```sql
CHECK (waypoint_type IN ('stop', 'note', 'photo', 'poi'))
CHECK (lat >= -90 AND lat <= 90)
CHECK (lng >= -180 AND lng <= 180)
CHECK (order_in_route >= 0)
```

---

### **Table 3: route_metadata**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `route_id` | UUID | NO | PK, FK to routes |
| `route_quality` | TEXT | YES | 'scenic', 'fastest', 'offbeat' |
| `road_condition` | TEXT | YES | 'excellent', 'good', 'poor', 'offroad' |
| `scenic_rating` | INTEGER | YES | 1-5 |
| `safety_rating` | INTEGER | NO | 1-5, default 3 |
| `solo_safe` | BOOLEAN | NO | Default TRUE |
| `fuel_cost` | DECIMAL(10,2) | YES | Estimated cost |
| `toll_cost` | DECIMAL(10,2) | YES | Toll charges |
| `highlights` | TEXT[] | YES | ['waterfall', 'viewpoint'] |
| `is_public` | BOOLEAN | NO | Default FALSE |
| `created_at` | TIMESTAMP | NO | NOW() |
| `updated_at` | TIMESTAMP | NO | NOW() |

**Indexes:**
```sql
PRIMARY KEY (route_id)
FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE

CREATE INDEX idx_route_metadata_public ON route_metadata(is_public) WHERE is_public = true;
CREATE INDEX idx_route_metadata_highlights ON route_metadata USING GIN(highlights);
```

**Constraints:**
```sql
CHECK (route_quality IN ('scenic', 'fastest', 'offbeat') OR route_quality IS NULL)
CHECK (road_condition IN ('excellent', 'good', 'poor', 'offroad') OR road_condition IS NULL)
CHECK (scenic_rating >= 1 AND scenic_rating <= 5 OR scenic_rating IS NULL)
CHECK (safety_rating >= 1 AND safety_rating <= 5)
CHECK (fuel_cost >= 0 OR fuel_cost IS NULL)
CHECK (toll_cost >= 0 OR toll_cost IS NULL)
```

---

## **📁 File Structure**

```
backend/
├── app/
│   ├── models/
│   │   ├── route.py              (NEW)
│   │   ├── waypoint.py           (NEW)
│   │   └── route_metadata.py     (NEW)
│   ├── schemas/
│   │   ├── route.py              (NEW)
│   │   ├── waypoint.py           (NEW)
│   │   └── route_metadata.py     (NEW)
│   ├── api/v1/
│   │   └── routes.py             (NEW)
│   └── services/
│       └── route_service.py      (NEW)
├── migrations/versions/
│   └── xxx_add_route_tables.py   (NEW)
└── tests/
    └── test_routes.py            (NEW)
```

---

## **🔧 API Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/trips/{trip_id}/routes` | List routes for trip |
| POST | `/api/v1/trips/{trip_id}/routes` | Create route |
| GET | `/api/v1/routes/{route_id}` | Get route details |
| PATCH | `/api/v1/routes/{route_id}` | Update route |
| DELETE | `/api/v1/routes/{route_id}` | Delete route |
| POST | `/api/v1/routes/{route_id}/waypoints` | Add waypoint |
| GET | `/api/v1/routes/{route_id}/waypoints` | List waypoints |
| PATCH | `/api/v1/waypoints/{waypoint_id}` | Update waypoint |
| DELETE | `/api/v1/waypoints/{waypoint_id}` | Delete waypoint |
| POST | `/api/v1/routes/generate` | Auto-generate route from coordinates |

---

## **📄 Pydantic Schemas**

**app/schemas/route.py:**
```python
class RouteBase(BaseModel):
    name: str | None = None
    description: str | None = None
    transport_mode: Literal['car', 'bike', 'foot', 'air', 'bus', 'train']
    route_category: Literal['ground', 'air']
    start_place_id: UUID | None = None
    end_place_id: UUID | None = None
    order_in_trip: int = 0

class RouteCreate(RouteBase):
    route_geojson: dict  # Must be valid GeoJSON LineString
    
class RouteUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    route_geojson: dict | None = None
    order_in_trip: int | None = None

class RouteResponse(RouteBase):
    id: UUID
    trip_id: UUID
    user_id: UUID
    route_geojson: dict
    distance_km: float | None
    duration_mins: int | None
    created_at: datetime
    updated_at: datetime
    
class RouteListResponse(BaseModel):
    routes: list[RouteResponse]
    total: int
```

**app/schemas/waypoint.py, route_metadata.py:** Similar structure.

---

## **🛠️ External Service Integration**

**app/services/route_service.py:**

```python
class RouteService:
    MAPBOX_API_URL = "https://api.mapbox.com/directions/v5"
    
    async def generate_route(
        self,
        coordinates: list[tuple[float, float]],
        mode: str = 'driving'
    ) -> dict:
        """
        Call Mapbox Directions API
        
        Args:
            coordinates: [(lng, lat), (lng, lat), ...]
            mode: 'driving', 'walking', 'cycling'
        
        Returns:
            {
                'route_geojson': {...},
                'distance_km': float,
                'duration_mins': int
            }
        """
        # Implementation: Call Mapbox API
        # Parse response
        # Return GeoJSON + metadata
```

**Environment Variable:**
```env
MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

---

## **✅ Success Criteria**

### **Database:**
- [ ] 3 tables created (routes, waypoints, route_metadata)
- [ ] All indexes exist
- [ ] Foreign keys work (cascade deletes)
- [ ] Constraints validated
- [ ] Migration reversible

### **API:**
- [ ] All 10 endpoints return correct status codes
- [ ] POST creates route with GeoJSON
- [ ] GET retrieves routes for trip
- [ ] PATCH updates route
- [ ] DELETE removes route + waypoints + metadata (cascade)
- [ ] Auth checks (only owner can modify)
- [ ] `/generate` endpoint calls Mapbox API

### **Testing:**
- [ ] Create route → verify in DB
- [ ] Add waypoints → correct order
- [ ] Delete route → waypoints deleted (cascade)
- [ ] Non-owner can't modify
- [ ] Invalid transport mode rejected
- [ ] GeoJSON validation works

### **V1 Compatibility:**
- [ ] Existing trips/places unchanged
- [ ] V1 endpoints still work

---

## **🧪 Test Cases**

**tests/test_routes.py** (30+ tests):
```python
# Route CRUD
test_create_route()
test_get_routes_for_trip()
test_update_route()
test_delete_route_cascades()

# Waypoints
test_add_waypoint_to_route()
test_waypoint_ordering()
test_delete_waypoint()

# Auth
test_non_owner_cannot_modify_route()

# Validation
test_invalid_transport_mode_rejected()
test_invalid_geojson_rejected()

# Mapbox Integration
test_generate_route_from_coordinates()

# Cascade
test_delete_trip_deletes_routes()
```

---

## **🚀 Deployment Steps**

1. **Apply migration:** `alembic upgrade head`
2. **Verify tables:** `\d routes`
4. **Run tests:** `pytest tests/test_routes.py -v`

---

## **⚠️ Common Pitfalls**

1. **GeoJSON Validation:** Must be valid LineString (not Point/Polygon)
2. **Cascade Deletes:** Routes must delete when trip deleted
3. **Ordering:** `order_in_trip` must be unique per trip
4. **Mapbox API:** Handle rate limits/errors gracefully

---

## **📦 Deliverables**

1. 3 model files (route, waypoint, route_metadata)
2. 3 schema files
3. 1 API router (10 endpoints)
4. 1 service file (Mapbox integration)
5. 1 migration file
6. 1 test file

**LOC Estimate:** ~800 LOC

---

**END OF PHASE A2 PRD**

