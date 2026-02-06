 # **PHASE A1: Metadata Infrastructure - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** A1  
**Phase Name:** Metadata Infrastructure   
**Dependencies:** V1 backend (completed)  
**Deliverables:** Database tables + API endpoints for semantic metadata  

---

## **🎯 Objectives**

### **Primary Goal:**
Enable semantic tagging of trips and places to support future intelligent search and discovery.

### **Why This Phase Matters:**
- **Foundation for V2:** Metadata is core to the two-sided marketplace vision
- **Future-proofing:** Easier to add metadata structure now than retrofit later
- **No disruption:** V1 trips continue working; metadata is optional
- **Data quality:** Early metadata capture = better search later

### **What Success Looks Like:**
- Trip creators can tag their trip with traveler profile (solo/couple/family, budget level, travel style)
- Places can be categorized and tagged with experience characteristics
- Metadata is stored in queryable format (PostgreSQL)
- API endpoints allow CRUD operations on metadata
- V1 functionality remains 100% unchanged

---

## **🏗️ Architecture Overview**

### **Data Model Strategy:**

```
Current V1 Architecture:
┌─────────┐
│  trips  │─────┐
└─────────┘     │
                ├──→ Simple CRUD
┌─────────────┐ │
│ trip_places │─┘
└─────────────┘

Phase A1 Architecture (Additive):
┌─────────┐          ┌──────────────────┐
│  trips  │────1:1───│ trip_metadata    │ (NEW)
└─────────┘          └──────────────────┘
     │
     │ 1:N
     ↓
┌─────────────┐      ┌──────────────────┐
│ trip_places │─1:1──│ place_metadata   │ (NEW)
└─────────────┘      └──────────────────┘
```

**Key Principle:** **Separation of Concerns**
- Core entities (`trips`, `trip_places`) remain unchanged
- Metadata lives in separate tables (1:1 relationship)
- Nullable foreign keys = optional metadata
- V1 code unaffected

---

## **🗄️ Database Schema Design**

### **Table 1: trip_metadata**

**Purpose:** Store semantic information about the trip for search/discovery

**Schema:**

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `trip_id` | UUID | NO | - | PK, FK to trips.id |
| `traveler_type` | TEXT[] | YES | NULL | ['solo', 'couple', 'family', 'group'] |
| `age_group` | TEXT | YES | NULL | 'gen-z', 'millennial', 'gen-x', 'boomer' |
| `travel_style` | TEXT[] | YES | NULL | ['adventure', 'luxury', 'budget', 'cultural', 'relaxed'] |
| `difficulty_level` | TEXT | YES | NULL | 'easy', 'moderate', 'challenging', 'extreme' |
| `budget_category` | TEXT | YES | NULL | 'budget', 'mid-range', 'luxury' |
| `activity_focus` | TEXT[] | YES | NULL | ['hiking', 'food', 'photography', 'nightlife', 'beaches'] |
| `is_discoverable` | BOOLEAN | NO | FALSE | Can this trip be found in public search? |
| `quality_score` | FLOAT | NO | 0.0 | System-calculated quality (0-1), used for ranking |
| `tags` | TEXT[] | YES | NULL | User-defined tags ['monsoon-travel', 'solo-friendly'] |
| `created_at` | TIMESTAMP | NO | NOW() | When metadata was created |
| `updated_at` | TIMESTAMP | NO | NOW() | Last update timestamp |

**Indexes:**
```sql
-- Primary key
PRIMARY KEY (trip_id)

-- Foreign key
FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE

-- Search optimization
CREATE INDEX idx_trip_metadata_discoverable ON trip_metadata(is_discoverable) WHERE is_discoverable = true;
CREATE INDEX idx_trip_metadata_tags ON trip_metadata USING GIN(tags);
CREATE INDEX idx_trip_metadata_traveler_type ON trip_metadata USING GIN(traveler_type);
CREATE INDEX idx_trip_metadata_activity_focus ON trip_metadata USING GIN(activity_focus);
```

**Constraints:**
```sql
-- Enum validation
CHECK (age_group IN ('gen-z', 'millennial', 'gen-x', 'boomer') OR age_group IS NULL)
CHECK (difficulty_level IN ('easy', 'moderate', 'challenging', 'extreme') OR difficulty_level IS NULL)
CHECK (budget_category IN ('budget', 'mid-range', 'luxury') OR budget_category IS NULL)

-- Quality score range
CHECK (quality_score >= 0.0 AND quality_score <= 1.0)
```

---

### **Table 2: place_metadata**

**Purpose:** Store semantic information about places/components for filtering and recommendations

**Schema:**

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `place_id` | UUID | NO | - | PK, FK to trip_places.id |
| `component_type` | TEXT | YES | 'place' | 'city', 'place', 'activity', 'accommodation', 'food', 'transport' |
| `experience_tags` | TEXT[] | YES | NULL | ['romantic', 'adventurous', 'peaceful', 'crowded', 'instagram-worthy'] |
| `best_for` | TEXT[] | YES | NULL | ['solo-travelers', 'couples', 'families', 'photographers', 'foodies'] |
| `budget_per_person` | DECIMAL(10,2) | YES | NULL | Estimated cost per person (USD) |
| `duration_hours` | FLOAT | YES | NULL | Recommended time to spend (hours) |
| `difficulty_rating` | INTEGER | YES | NULL | Physical difficulty 1-5 |
| `physical_demand` | TEXT | YES | NULL | 'low', 'medium', 'high' |
| `best_time` | TEXT | YES | NULL | 'sunrise', 'morning', 'afternoon', 'sunset', 'night', 'anytime' |
| `is_public` | BOOLEAN | NO | FALSE | Can this place be discovered publicly? |
| `contribution_score` | FLOAT | NO | 0.0 | Quality score for this component (0-1) |
| `created_at` | TIMESTAMP | NO | NOW() | When metadata was created |
| `updated_at` | TIMESTAMP | NO | NOW() | Last update timestamp |

**Indexes:**
```sql
-- Primary key
PRIMARY KEY (place_id)

-- Foreign key
FOREIGN KEY (place_id) REFERENCES trip_places(id) ON DELETE CASCADE

-- Search optimization
CREATE INDEX idx_place_metadata_public ON place_metadata(is_public) WHERE is_public = true;
CREATE INDEX idx_place_metadata_component_type ON place_metadata(component_type);
CREATE INDEX idx_place_metadata_tags ON place_metadata USING GIN(experience_tags);
CREATE INDEX idx_place_metadata_best_for ON place_metadata USING GIN(best_for);
```

**Constraints:**
```sql
-- Enum validation
CHECK (component_type IN ('city', 'place', 'activity', 'accommodation', 'food', 'transport') OR component_type IS NULL)
CHECK (physical_demand IN ('low', 'medium', 'high') OR physical_demand IS NULL)
CHECK (best_time IN ('sunrise', 'morning', 'afternoon', 'sunset', 'night', 'anytime') OR best_time IS NULL)

-- Rating ranges
CHECK (difficulty_rating >= 1 AND difficulty_rating <= 5 OR difficulty_rating IS NULL)
CHECK (contribution_score >= 0.0 AND contribution_score <= 1.0)
CHECK (duration_hours > 0 OR duration_hours IS NULL)
CHECK (budget_per_person >= 0 OR budget_per_person IS NULL)
```

---

## **📁 File Structure**

```
backend/
├── app/
│   ├── models/
│   │   ├── trip_metadata.py          (NEW)
│   │   └── place_metadata.py         (NEW)
│   ├── schemas/
│   │   ├── trip_metadata.py          (NEW)
│   │   └── place_metadata.py         (NEW)
│   ├── api/
│   │   └── v1/
│   │       └── metadata.py           (NEW)
│   └── services/
│       └── metadata_service.py       (NEW - optional)
├── migrations/
│   └── versions/
│       └── xxx_add_metadata_tables.py (NEW - Alembic migration)
└── tests/
    └── test_metadata.py              (NEW)
```

---

## **🔧 Backend Implementation Specification**

### **1. Database Models**

**File:** `app/models/trip_metadata.py`

**Requirements:**
- SQLAlchemy ORM model matching schema above
- Use `ARRAY` type for list fields (PostgreSQL native)
- Use `Mapped` type hints (SQLAlchemy 2.0 style)
- Include `relationship` to `Trip` model
- Auto-update `updated_at` on modification

**Reference Pattern (from existing codebase):**
```python
# See: app/models/user.py for Mapped syntax
# See: app/models/trip.py for relationship patterns
```

---

**File:** `app/models/place_metadata.py`

**Requirements:**
- SQLAlchemy ORM model matching schema above
- Similar structure to `trip_metadata.py`
- Include `relationship` to `TripPlace` model

---

### **2. Pydantic Schemas**

**File:** `app/schemas/trip_metadata.py`

**Required Schemas:**

```python
# Base schema (shared fields)
class TripMetadataBase(BaseModel):
    traveler_type: list[str] | None = None
    age_group: str | None = None
    travel_style: list[str] | None = None
    difficulty_level: str | None = None
    budget_category: str | None = None
    activity_focus: list[str] | None = None
    is_discoverable: bool = False
    tags: list[str] | None = None

# Create schema (API request)
class TripMetadataCreate(TripMetadataBase):
    pass  # No additional fields

# Update schema (partial updates)
class TripMetadataUpdate(BaseModel):
    traveler_type: list[str] | None = None
    age_group: str | None = None
    travel_style: list[str] | None = None
    difficulty_level: str | None = None
    budget_category: str | None = None
    activity_focus: list[str] | None = None
    is_discoverable: bool | None = None
    tags: list[str] | None = None

# Response schema (API response)
class TripMetadataResponse(TripMetadataBase):
    trip_id: UUID
    quality_score: float
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
```

---

**File:** `app/schemas/place_metadata.py`

**Required Schemas:**

```python
class PlaceMetadataBase(BaseModel):
    component_type: str | None = "place"
    experience_tags: list[str] | None = None
    best_for: list[str] | None = None
    budget_per_person: Decimal | None = None
    duration_hours: float | None = None
    difficulty_rating: int | None = None
    physical_demand: str | None = None
    best_time: str | None = None
    is_public: bool = False

class PlaceMetadataCreate(PlaceMetadataBase):
    pass

class PlaceMetadataUpdate(BaseModel):
    component_type: str | None = None
    experience_tags: list[str] | None = None
    best_for: list[str] | None = None
    budget_per_person: Decimal | None = None
    duration_hours: float | None = None
    difficulty_rating: int | None = None
    physical_demand: str | None = None
    best_time: str | None = None
    is_public: bool | None = None

class PlaceMetadataResponse(PlaceMetadataBase):
    place_id: UUID
    contribution_score: float
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
```

---

### **3. API Endpoints**

**File:** `app/api/v1/metadata.py`

**Required Endpoints:**

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/v1/trips/{trip_id}/metadata` | Create trip metadata | Yes (trip owner) |
| GET | `/api/v1/trips/{trip_id}/metadata` | Get trip metadata | Yes (trip owner or public) |
| PATCH | `/api/v1/trips/{trip_id}/metadata` | Update trip metadata | Yes (trip owner) |
| DELETE | `/api/v1/trips/{trip_id}/metadata` | Delete trip metadata | Yes (trip owner) |
| POST | `/api/v1/places/{place_id}/metadata` | Create place metadata | Yes (place owner) |
| GET | `/api/v1/places/{place_id}/metadata` | Get place metadata | Yes (place owner or public) |
| PATCH | `/api/v1/places/{place_id}/metadata` | Update place metadata | Yes (place owner) |
| DELETE | `/api/v1/places/{place_id}/metadata` | Delete place metadata | Yes (place owner) |

---

**Endpoint Behavior Specification:**

#### **POST /api/v1/trips/{trip_id}/metadata**

**Request:**
```json
{
  "traveler_type": ["solo", "adventure"],
  "age_group": "gen-z",
  "budget_category": "budget",
  "activity_focus": ["hiking", "photography"],
  "is_discoverable": true,
  "tags": ["monsoon", "western-ghats"]
}
```

**Response (201 Created):**
```json
{
  "trip_id": "123e4567-e89b-12d3-a456-426614174000",
  "traveler_type": ["solo", "adventure"],
  "age_group": "gen-z",
  "budget_category": "budget",
  "activity_focus": ["hiking", "photography"],
  "is_discoverable": true,
  "quality_score": 0.0,
  "tags": ["monsoon", "western-ghats"],
  "created_at": "2025-02-02T10:30:00Z",
  "updated_at": "2025-02-02T10:30:00Z"
}
```

**Error Cases:**
- `404 Not Found` - Trip doesn't exist
- `403 Forbidden` - User doesn't own this trip
- `409 Conflict` - Metadata already exists (use PATCH to update)
- `422 Unprocessable Entity` - Invalid enum values

---

#### **GET /api/v1/trips/{trip_id}/metadata**

**Response (200 OK):**
```json
{
  "trip_id": "123e4567-e89b-12d3-a456-426614174000",
  "traveler_type": ["solo"],
  "age_group": "millennial",
  "budget_category": "mid-range",
  "quality_score": 0.75,
  "is_discoverable": true,
  "created_at": "2025-02-02T10:30:00Z",
  "updated_at": "2025-02-02T10:30:00Z"
}
```

**Error Cases:**
- `404 Not Found` - Trip or metadata doesn't exist
- `403 Forbidden` - Trip is private and user is not owner

---

#### **PATCH /api/v1/trips/{trip_id}/metadata**

**Request (partial update):**
```json
{
  "is_discoverable": true,
  "tags": ["beach", "relaxation"]
}
```

**Response (200 OK):**
```json
{
  "trip_id": "123e4567-e89b-12d3-a456-426614174000",
  "traveler_type": ["solo"],
  "is_discoverable": true,
  "tags": ["beach", "relaxation"],
  "quality_score": 0.75,
  "updated_at": "2025-02-02T11:00:00Z",
  ...
}
```

**Behavior:**
- Only update fields provided in request
- Auto-update `updated_at` timestamp
- Return full metadata object

---

#### **Similar patterns for Place Metadata endpoints**

---

### **4. Database Migration**

**File:** `migrations/versions/xxx_add_metadata_tables.py`

**Migration Requirements:**

```python
"""Add metadata tables for trips and places

Revision ID: xxx
Revises: yyy (previous migration)
Create Date: 2025-02-02
"""

# Migration must:
# 1. Create trip_metadata table with all columns, indexes, constraints
# 2. Create place_metadata table with all columns, indexes, constraints
# 3. Be reversible (downgrade removes tables)
# 4. NOT modify existing tables (trips, trip_places)
# 5. Include GIN indexes for array columns (PostgreSQL)

# upgrade():
#   - CREATE TABLE trip_metadata
#   - CREATE TABLE place_metadata
#   - CREATE INDEXes
#   - ADD CONSTRAINTS

# downgrade():
#   - DROP TABLE place_metadata
#   - DROP TABLE trip_metadata
```

**Testing Migration:**
```bash
# Apply migration
alembic upgrade head

# Verify tables created
psql -d travelogue -c "\d trip_metadata"
psql -d travelogue -c "\d place_metadata"

# Test rollback
alembic downgrade -1
alembic upgrade head
```

---

## **🔗 Integration Points**

### **Where This Phase Connects:**

**Existing V1 Code (NO CHANGES REQUIRED):**
- `app/models/trip.py` - Continues working as-is
- `app/models/trip_place.py` - Continues working as-is
- `app/api/v1/trips.py` - All existing endpoints unchanged
- `app/api/v1/places.py` - All existing endpoints unchanged

**Optional Enhancement (Not Required for Phase A1):**
- Could add `metadata` field to `TripResponse` schema (include metadata in trip GET response)
- This is **Phase B integration work**, not Phase A1

---

## **✅ Success Criteria Checklist**

### **Database:**
- [ ] `trip_metadata` table created with correct schema
- [ ] `place_metadata` table created with correct schema
- [ ] All indexes created (verify with `\d+ trip_metadata` in psql)
- [ ] Foreign key constraints work (cascading delete)
- [ ] Enum constraints validated (try inserting invalid values - should fail)
- [ ] Migration is reversible (downgrade works)

### **API Endpoints:**
- [ ] All 8 endpoints return correct status codes
- [ ] POST creates metadata successfully
- [ ] GET retrieves metadata
- [ ] PATCH updates only specified fields
- [ ] DELETE removes metadata (trip/place still exists)
- [ ] Auth checks work (can't edit other users' metadata)
- [ ] Validation works (invalid enum values rejected)

### **Testing:**
- [ ] Create trip → create metadata → verify in DB
- [ ] Update metadata → check `updated_at` changed
- [ ] Delete metadata → trip still exists
- [ ] Delete trip → metadata auto-deleted (cascade)
- [ ] Non-owner can't modify metadata
- [ ] Public metadata visible to non-owners
- [ ] Private metadata hidden from non-owners

### **Backward Compatibility:**
- [ ] V1 trip creation still works (no metadata required)
- [ ] V1 place creation still works (no metadata required)
- [ ] Existing trips continue functioning
- [ ] No breaking changes to existing API responses

---

## **📊 Testing Strategy**

### **Unit Tests:**

**File:** `tests/test_metadata.py`

**Test Cases Required:**

```python
# Trip Metadata Tests
def test_create_trip_metadata():
    # POST /api/v1/trips/{trip_id}/metadata
    # Verify 201 status, correct response

def test_get_trip_metadata():
    # GET /api/v1/trips/{trip_id}/metadata
    # Verify 200 status, all fields present

def test_update_trip_metadata():
    # PATCH with partial data
    # Verify only specified fields updated

def test_delete_trip_metadata():
    # DELETE metadata
    # Verify trip still exists

def test_trip_cascade_delete():
    # Delete trip
    # Verify metadata auto-deleted

def test_trip_metadata_validation():
    # POST with invalid enum
    # Verify 422 error

# Place Metadata Tests (similar structure)
def test_create_place_metadata():
    ...

def test_place_metadata_auth():
    # Non-owner can't edit
    ...

# Integration Tests
def test_metadata_with_existing_trip():
    # Create trip in V1 style
    # Add metadata
    # Verify both work together
```

---

## **🚀 Deployment Steps**

### **Step 1: Apply Migration**
```bash
cd backend
alembic upgrade head
```

### **Step 2: Verify Tables**
```bash
psql -d travelogue_dev -c "SELECT COUNT(*) FROM trip_metadata;"
# Should return 0 (empty table, but exists)
```

### **Step 3: Test Endpoints**
```bash
# Using Swagger UI at /docs
# Or using curl/Postman

# Create test trip (V1 endpoint)
POST /api/v1/trips
{
  "title": "Test Trip",
  "description": "Testing metadata"
}

# Add metadata (new endpoint)
POST /api/v1/trips/{trip_id}/metadata
{
  "traveler_type": ["solo"],
  "budget_category": "budget",
  "is_discoverable": true
}

# Verify metadata exists
GET /api/v1/trips/{trip_id}/metadata
```

### **Step 4: Verify V1 Still Works**
```bash
# Existing endpoints should work unchanged
GET /api/v1/trips
GET /api/v1/trips/{trip_id}
GET /api/v1/places?trip_id={trip_id}

# No errors, no changes to response structure
```

## ** Common Pitfalls to Avoid**

### **1. PostgreSQL ARRAY Type**
**Problem:** Using JSON arrays instead of native PostgreSQL arrays  
**Solution:** Use `ARRAY` column type with GIN indexes

### **2. Cascade Deletes**
**Problem:** Orphaned metadata when trip/place deleted  
**Solution:** Set `ON DELETE CASCADE` on foreign keys

### **3. Quality Score Calculation**
**Problem:** Manually setting quality score  
**Solution:** Phase A1 sets default 0.0; Phase E1 will auto-calculate

### **4. Breaking V1**
**Problem:** Modifying existing schemas  
**Solution:** Only add new tables; never ALTER existing tables

### **5. Auth Checks**
**Problem:** Anyone can edit any trip's metadata  
**Solution:** Verify `current_user.id == trip.user_id` before allowing updates

---

## **🔄 Handoff to Next Phase**

### **What Next Phase (A2) Will Need:**

**From Database:**
- `trip_metadata.trip_id` → will link to routes
- `place_metadata.place_id` → routes can connect places

**From API:**
- Metadata endpoints working
- Auth patterns established
- Validation patterns established

**Key Files for Next Phase:**
- `app/models/trip_metadata.py` - reference for Route model
- `app/schemas/trip_metadata.py` - reference for Route schemas
- `app/api/v1/metadata.py` - reference for Route endpoints

### **Questions for Phase A2:**
- How to link routes to trip metadata?
- Should route metadata be separate table or embedded?
- How to order routes + places in unified timeline?

---

## **📦 Deliverables Summary**

**By end of Phase A1, AI agent should deliver:**

1. ✅ **2 new database tables** (trip_metadata, place_metadata)
2. ✅ **1 migration file** (Alembic)
3. ✅ **2 model files** (SQLAlchemy)
4. ✅ **2 schema files** (Pydantic)
5. ✅ **1 API router file** (8 endpoints)
6. ✅ **1 test file** (unit + integration tests)

**Lines of Code Estimate:** ~500-600 LOC

**Ready for:** Phase A2 (Route System)

---

## **🎓 Reference Materials**

**For AI Agent:**
- Existing V1 models: `app/models/trip.py`, `app/models/user.py`
- Existing V1 schemas: `app/schemas/trip.py`
- Existing V1 endpoints: `app/api/v1/trips.py`
- Migration example: Latest migration in `migrations/versions/`

---

**END OF PHASE A1 PRD**

---

**Next Steps:**
1. AI agent implements Phase A1 per this spec
2. Tests pass
3. Migration applied to dev database
4. V1 functionality verified unchanged
5. Proceed to Phase A2 PRD (Route System)

---

**Clarifications Needed Before Starting?**