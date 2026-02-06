# **Phase 2B: Intelligent Search Foundation - Complete PRD**

**Phase:** 2B  
**Sessions:** 14, 15, 16  
**Duration:** 3 weeks  
**Goal:** Build production-grade, scalable search system that learns and improves over time

---

## **Phase Overview**

### **What Phase 2B Builds**

A multi-layered search system that:
- Searches user-contributed places (local database)
- Falls back to external APIs (Foursquare) when needed
- Deduplicates intelligently (prioritizes user data)
- Ranks results by relevance
- Collects behavioral signals (moat foundation)
- Improves over time through learning

### **Why Phase 2B Matters**

**Without search:**
- Users manually enter coordinates (painful UX)
- No place discovery
- Low engagement

**With Phase 2B:**
- Type "coffee shop" → instant results
- Smart ranking (user favorites > generic chains)
- System learns from every search
- Moat: 1000 searches = unique behavioral dataset

---

## **Architecture Principles**

### **Layered Design**

```
Session 14: Foundation Layer
├── Database indexes (fast queries)
├── Signal collection (moat data)
└── Normalization utilities (cache efficiency)

Session 15: Retrieval Layer
├── Local DB search (user data first)
├── External API providers (fill gaps)
└── Result merging (intelligent deduplication)

Session 16: Intelligence Layer
├── Ranking algorithm (relevance scoring)
├── Public API (search endpoints)
└── Signal logging (learning system)
```

### **Core Principles**

1. **Local First:** Always prioritize user-contributed data over external sources
2. **Graceful Degradation:** External API failure = return local results only
3. **Signal Collection:** Log every search, click, save (moat foundation)
4. **Cache Ready:** Build hooks now, plug Redis later (zero rewrites)
5. **Provider Abstraction:** Easy to add new search sources (Mapbox, Google, etc.)

---

## **Unified Result Schema**

All search results MUST conform to this format:

```
{
    "id": string | null              // "local:uuid" or "foursquare:fsq_id"
    "name": string                   // Place name
    "lat": float                     // Latitude
    "lng": float                     // Longitude
    "address": string | null         // Full address (if available)
    "source": string                 // "local" | "foursquare"
    "distance_m": float              // Distance from search center (meters)
    "rating": float | null           // 0-10 scale (if available)
    "popularity": integer | null     // Save count (local) or null (external)
    "has_user_content": boolean      // True if source="local"
}
```

**Why This Schema:**
- Consistent across all sources
- Frontend gets predictable data
- Ranking algorithm works uniformly
- Easy to add new sources

---

## **File Structure**

```
backend/
  alembic/
    versions/
      xxx_add_search_index.py           (Session 14)
      yyy_create_signal_tables.py       (Session 14)
  app/
    models/
      search_signals.py                 (Session 14)
    services/
      search_service.py                 (Session 14-16, extended each session)
      providers/
        __init__.py                     (Session 15)
        base.py                         (Session 15)
        local_provider.py               (Session 15)
        foursquare_provider.py          (Session 15)
    utils/
      search_normalizer.py              (Session 14)
      cache_keys.py                     (Session 14)
      geo.py                            (Session 15)
    api/v1/
      search.py                         (Session 16)
    schemas/
      search.py                         (Session 16)
  tests/
    test_search_utils.py                (Session 14)
    test_search_service.py              (Session 14)
    test_search_retrieval.py            (Session 15)
    test_search_ranking.py              (Session 16)
    test_search_api.py                  (Session 16)
  test_session_14.py                    (Session 14 integration test)
```

---

## **Configuration**

### **Environment Variables**

Add to `.env`:
```
FOURSQUARE_API_KEY=fsq3xxxxxxxxxxxxx
```

Add to `backend/app/config.py`:
```python
FOURSQUARE_API_KEY: str
```

### **Dependencies**

Add to `requirements.txt`:
```
httpx>=0.24.0              # Async HTTP client
rapidfuzz>=3.0.0           # Fast fuzzy string matching
```

### **API Limits**

**Foursquare (Free Tier):**
- 100,000 calls/month
- ~3 calls/second rate limit
- No rate limiting needed for MVP (won't hit limits)

---

# **SESSION 14: Search Foundation**

**Duration:** 1 week  
**Objective:** Build infrastructure for scalable, intelligent search

---

## **Session 14 Overview**

**What Gets Built:**
1. Full-text search index on `trip_places` table
2. Signal collection tables (search_events, place_views, place_saves)
3. Normalization utilities (query, coords, radius)
4. Cache key generator (hooks ready, Redis later)
5. SearchService skeleton (foundation for Sessions 15-16)

**Why Session 14:**
- Makes search FAST (GIN index = instant lookups)
- Starts collecting moat data (signals)
- Prevents cache waste (normalization)
- Future-proof (cache hooks ready)

---

## **Session 14 Tasks**

### **Task 1: Database Migrations**

#### **Migration 1: Add Search Index**

**File:** `alembic/versions/xxx_add_search_index.py`

**Purpose:** Enable fast full-text search on places

**What It Creates:**
1. `search_vector` column (tsvector type)
2. GIN index on `search_vector` (instant text search)
3. Auto-update trigger (keeps search_vector in sync)
4. Populates existing data

**Key SQL Components:**

**Column:**
```sql
ALTER TABLE trip_places ADD COLUMN search_vector tsvector;
```

**Index:**
```sql
CREATE INDEX idx_trip_places_search 
ON trip_places USING GIN(search_vector);
```

**Trigger Function:**
```sql
CREATE OR REPLACE FUNCTION trip_places_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW.search_vector := to_tsvector('english',
    coalesce(NEW.name, '') || ' ' ||
    coalesce(NEW.user_notes, '') || ' ' ||
    coalesce(NEW.place_type, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**
```sql
CREATE TRIGGER tsvector_update 
BEFORE INSERT OR UPDATE ON trip_places
FOR EACH ROW EXECUTE FUNCTION trip_places_search_trigger();
```

**Populate Existing:**
```sql
UPDATE trip_places 
SET search_vector = to_tsvector('english',
    coalesce(name, '') || ' ' ||
    coalesce(user_notes, '') || ' ' ||
    coalesce(place_type, '')
)
WHERE search_vector IS NULL;
```

**Downgrade (Clean Rollback):**
```sql
DROP TRIGGER IF EXISTS tsvector_update ON trip_places;
DROP FUNCTION IF EXISTS trip_places_search_trigger();
DROP INDEX IF EXISTS idx_trip_places_search;
ALTER TABLE trip_places DROP COLUMN IF EXISTS search_vector;
```

**Critical Notes:**
- Use `CREATE OR REPLACE FUNCTION` (idempotent)
- Use `CREATE INDEX IF NOT EXISTS` (safe reruns)
- Complete downgrade (no leftover artifacts)

---

#### **Migration 2: Create Signal Tables**

**File:** `alembic/versions/yyy_create_signal_tables.py`

**Purpose:** Collect user behavior data (moat foundation)

**What It Creates:**

**1. search_events Table:**
```
id: UUID (primary key, auto-generated)
user_id: UUID (foreign key to users, cascade delete)
query: TEXT (search text)
lat: FLOAT (search center latitude)
lng: FLOAT (search center longitude)
radius_km: FLOAT (search radius)
results_count: INTEGER (how many results returned)
created_at: TIMESTAMP (when search happened)
```

**Indexes:**
- `idx_search_events_user` on `user_id`
- `idx_search_events_created` on `created_at`

**2. place_views Table:**
```
id: UUID (primary key, auto-generated)
user_id: UUID (foreign key to users, cascade delete)
place_id: UUID (foreign key to trip_places, cascade delete)
source: VARCHAR(50) (where result came from: "local" or "foursquare")
created_at: TIMESTAMP (when viewed)
```

**Indexes:**
- `idx_place_views_user` on `user_id`
- `idx_place_views_place` on `place_id`

**3. place_saves Table:**
```
id: UUID (primary key, auto-generated)
user_id: UUID (foreign key to users, cascade delete)
place_id: UUID (foreign key to trip_places, cascade delete)
created_at: TIMESTAMP (when saved to trip)
```

**Indexes:**
- `idx_place_saves_user` on `user_id`
- `idx_place_saves_place` on `place_id`

**Critical Notes:**
- All `id` columns use `server_default=gen_random_uuid()` (database generates UUIDs)
- All foreign keys have `ON DELETE CASCADE` (clean cleanup)
- All timestamps use `server_default=func.now()` (database sets timestamp)

**Why These Tables:**
- **search_events:** Identify trending searches, missing places
- **place_views:** Which results get clicked (quality signal)
- **place_saves:** Strongest signal (user took action)
- **Combined:** Unique behavioral dataset = moat

---

### **Task 2: Create ORM Models**

**File:** `app/models/search_signals.py`

**Purpose:** SQLAlchemy models for signal tables

**Requirements:**
- Import from `app.database.Base`
- Use UUID primary keys
- Use server_default for id and timestamps
- Include `__repr__` for debugging
- Add proper docstrings

**Models to Create:**
1. `SearchEvent` (maps to search_events table)
2. `PlaceView` (maps to place_views table)
3. `PlaceSave` (maps to place_saves table)

**Update `app/models/__init__.py`:**
```python
from app.models.search_signals import SearchEvent, PlaceView, PlaceSave
```

---

### **Task 3: Create Normalization Utilities**

**File:** `app/utils/search_normalizer.py`

**Purpose:** Standardize inputs for consistent cache keys and queries

#### **Function 1: normalize_query**

**Signature:**
```python
def normalize_query(query: str) -> str
```

**Purpose:** Clean search text for consistency

**Requirements:**
- Trim leading/trailing whitespace
- Convert to lowercase
- Remove special characters (except: spaces, hyphens, apostrophes)
- Collapse multiple spaces to single space
- Keep accented characters (café stays café)

**Examples:**
```
"  Coffee  SHOP!!  " → "coffee shop"
"Café" → "café"
"O'Brien's Pub" → "o'brien's pub"
"co-op store" → "co-op store"
"   " → ""
```

**Why:**
- Cache efficiency (same query = same key)
- Better search (case-insensitive)
- Cleaner analytics data

---

#### **Function 2: normalize_coords**

**Signature:**
```python
def normalize_coords(lat: float, lng: float) -> tuple[float, float]
```

**Purpose:** Round coordinates to prevent GPS jitter cache misses

**Requirements:**
- Round to 4 decimal places (~11 meter precision)
- Handle edge cases (None, out of range)

**Examples:**
```
(48.858370123, 2.294481987) → (48.8584, 2.2945)
(48.8584, 2.2945) → (48.8584, 2.2945)  # Already rounded
(999, 999) → ValueError  # Invalid coords
```

**Why:**
- GPS jitter: 48.8583 vs 48.8584 should hit same cache
- 4 decimals = 11m precision (good enough for "near me")
- More cache hits = faster responses, lower costs

---

#### **Function 3: normalize_radius**

**Signature:**
```python
def normalize_radius(radius_km: float, max_radius: float = 50.0) -> float
```

**Purpose:** Clamp radius to reasonable range

**Requirements:**
- Clamp to max_radius (default 50km)
- If negative or zero, return default (5km)
- If > max, return max

**Examples:**
```
5.0 → 5.0
100 → 50.0  # Clamped to max
-10 → 5.0   # Default
0 → 5.0     # Default
```

**Why:**
- Prevent abuse (radius=1000km)
- Reasonable UX (50km ≈ 1 hour drive)
- Consistent cache keys

---

### **Task 4: Create Cache Key Generator**

**File:** `app/utils/cache_keys.py`

**Purpose:** Generate deterministic cache keys (Redis comes later)

#### **Function: make_search_key**

**Signature:**
```python
def make_search_key(
    query: str,
    lat: float,
    lng: float,
    radius_km: float,
    filters: dict | None = None
) -> str
```

**Purpose:** Create consistent, human-readable cache key

**Requirements:**
- Deterministic (same inputs = same key every time)
- Human-readable (for debugging)
- Handle optional filters
- Format: `"search:{query}:{lat}:{lng}:{radius}"`

**Examples:**
```
("coffee", 48.8584, 2.2945, 5.0, None)
→ "search:coffee:48.8584:2.2945:5.0"

("coffee", 48.8584, 2.2945, 5.0, {"type": "cafe"})
→ "search:coffee:48.8584:2.2945:5.0:type=cafe"
```

**Why:**
- Predictable (testing, debugging)
- Readable (monitoring, logs)
- Future-proof (Redis drops in with no changes)

**Important:** Cache backend NOT implemented in Session 14. Just generate keys, don't use them yet.

---

### **Task 5: Create SearchService Skeleton**

**File:** `app/services/search_service.py`

**Purpose:** Foundation for search orchestration (filled in Sessions 15-16)

**Class Structure:**
```python
class SearchService:
    def __init__(self, db: Session):
        """Initialize with database session."""
    
    async def search_places(
        self,
        query: str,
        lat: float,
        lng: float,
        radius_km: float = 5.0,
        limit: int = 10
    ) -> List[dict]:
        """
        Search for places (multi-source, deduplicated, ranked).
        
        Session 14: Normalizes inputs, generates cache key, returns empty list
        Session 15: Adds retrieval (local + Foursquare) and deduplication
        Session 16: Adds ranking and signal logging
        """
```

**Session 14 Implementation:**
- Accept parameters
- Normalize using utilities
- Generate cache key
- Log cache key (for verification)
- Return empty list (retrieval in Session 15)

**Why Skeleton:**
- Clear contract for Sessions 15-16
- Testable from day 1
- Incremental development

---

## **Session 14 Testing Requirements**

### **Test File 1: Utility Tests**

**File:** `tests/test_search_utils.py`

**Test Coverage:**

**Query Normalization:**
- Basic normalization (uppercase, whitespace)
- Special character handling
- Whitespace collapsing
- Empty string handling
- Unicode/accent preservation

**Coordinate Normalization:**
- Rounding to 4 decimals
- Already-rounded coordinates
- Invalid coordinates (error handling)

**Radius Normalization:**
- Valid values pass through
- Max clamping
- Negative becomes default
- Zero becomes default

**Cache Keys:**
- Deterministic (same inputs = same key)
- Different inputs = different keys
- Human-readable format
- Filter handling

**Coverage Target:** 95%+ for utilities

---

### **Test File 2: Service Tests**

**File:** `tests/test_search_service.py`

**Test Coverage (Session 14 Only):**

**Service Initialization:**
- Can create with db session
- Stores db reference

**Input Normalization:**
- Calls normalize functions
- Doesn't crash on bad inputs

**Returns Empty List:**
- Returns list type
- List is empty (no retrieval yet)

**Coverage Target:** 90%+ for SearchService skeleton

---

### **Integration Test Script**

**File:** `test_session_14.py`

**Purpose:** Manual verification of all Session 14 components

**Tests:**
1. Normalization utilities work correctly
2. Cache keys are deterministic
3. SearchService can be initialized
4. Database schema correct (search_vector, signal tables, indexes, trigger)

**Run:** `python test_session_14.py`

**Expected Output:**
```
====================================================
SESSION 14 INTEGRATION TEST
====================================================

=== Testing Normalization ===
✅ All normalization tests passed

=== Testing Cache Keys ===
✅ Cache key tests passed

=== Testing SearchService ===
✅ SearchService tests passed

=== Testing Database Schema ===
✅ search_vector column exists
✅ Signal tables exist
✅ Auto-update trigger exists
✅ Database schema tests passed

====================================================
✅ ALL SESSION 14 TESTS PASSED
====================================================

Session 14 complete! Ready for Session 15.
```

---

## **Session 14 Success Criteria**

- ✅ Migrations run without errors
- ✅ `search_vector` column exists with GIN index
- ✅ Trigger auto-updates search_vector on place changes
- ✅ Signal tables created with proper indexes
- ✅ All normalization functions tested and working
- ✅ Cache key generator produces deterministic keys
- ✅ SearchService skeleton exists and testable
- ✅ All tests pass (>90% coverage)
- ✅ Integration test passes
- ✅ Code committed to git

---

## **Session 14 Non-Goals**

**Do NOT implement:**
- ❌ Actual search retrieval (Session 15)
- ❌ Foursquare API integration (Session 15)
- ❌ Deduplication logic (Session 15)
- ❌ Ranking algorithm (Session 16)
- ❌ Search endpoints (Session 16)
- ❌ Redis caching (post-MVP)

---

# **SESSION 15: Retrieval Layer**

**Duration:** 1 week  
**Objective:** Implement multi-source search with intelligent deduplication

---

## **Session 15 Overview**

**What Gets Built:**
1. Provider abstraction (base interface for all search sources)
2. Local DB search provider (PostGIS + full-text)
3. Foursquare API provider (external fallback)
4. Geo utilities (haversine distance calculation)
5. Deduplication logic (smart merging, local priority)
6. Extended SearchService (orchestrates retrieval)

**Why Session 15:**
- Local-first = fast, personalized results
- External fallback = comprehensive coverage
- Deduplication = clean UX (no duplicates)
- Provider pattern = easy to add more sources

---

## **Session 15 Architecture**

### **Search Flow:**
```
1. Normalize inputs (Session 14 utilities)
2. Generate cache key (logged but not used)
3. Search local DB (PostGIS + full-text)
4. If results < limit → Query Foursquare
5. Merge results (local + external)
6. Deduplicate (remove duplicates, local wins)
7. Return unified format
```

### **Provider Abstraction:**
```
BaseSearchProvider (interface)
├── LocalSearchProvider (database)
└── FoursquareSearchProvider (API)

Future: Add more providers without changing core logic
├── MapboxSearchProvider
├── GooglePlacesProvider
└── CustomProvider
```

---

## **Session 15 Tasks**

### **Task 1: Create Provider Abstraction**

**File:** `app/services/providers/base.py`

**Purpose:** Define interface all search providers must implement

**Requirements:**
- Use ABC (Abstract Base Class)
- Define `search()` method signature
- Document unified schema in docstring
- All providers inherit from this

**Interface Contract:**
```
async def search(
    query: str,           # Normalized search text
    lat: float,           # Normalized latitude
    lng: float,           # Normalized longitude
    radius_km: float,     # Normalized radius
    limit: int = 10       # Max results
) -> List[dict]:          # Unified schema
```

**File:** `app/services/providers/__init__.py`

Export all providers for easy imports.

---

### **Task 2: Implement Local Search Provider**

**File:** `app/services/providers/local_provider.py`

**Purpose:** Search user-contributed places using PostgreSQL + PostGIS

#### **Query Requirements:**

**Full-Text Search:**
- Use `search_vector @@ plainto_tsquery()`
- Use `ts_rank_cd()` for relevance scoring

**Geo Filtering:**
- Use `ST_DWithin()` for radius search
- Use `ST_Distance()` for distance calculation
- Convert radius_km to meters (multiply by 1000)
- Use geography type (accurate over long distances)

**Privacy:**
- Only return `visibility IN ('public', 'unlisted')`
- Never return `'private'` places to other users

**Ordering:**
- Sort by distance (closest first)
- Apply limit

**Popularity:**
- Count saves from `place_saves` table
- Join or separate query (performance vs simplicity)

#### **Result Mapping to Unified Schema:**

```
TripPlace → Unified Result:

id → "local:{place.id}"
name → place.name
lat → ST_Y(location)
lng → ST_X(location)
address → None (not stored in TripPlace)
source → "local"
distance_m → ST_Distance result (in meters)
rating → None (not in TripPlace model)
popularity → COUNT from place_saves
has_user_content → True
```

**Edge Cases:**
- Handle places with no saves (popularity = 0)
- Handle places with missing coordinates (skip)
- Handle empty results (return empty list)

---

### **Task 3: Implement Foursquare Provider**

**File:** `app/services/providers/foursquare_provider.py`

**Purpose:** Query Foursquare Places API with retry logic and error handling

#### **API Details:**

**Endpoint:**
```
GET https://api.foursquare.com/v3/places/search
```

**Headers:**
```
Authorization: {FOURSQUARE_API_KEY}
Accept: application/json
```

**Query Parameters:**
```
query: {search_text}
ll: {lat},{lng}
radius: {radius_km * 1000}  // Convert to meters
limit: {limit}
fields: fsq_id,name,geocodes,location,distance,rating
```

**Implementation Requirements:**

1. **HTTP Client:**
   - Use `httpx.AsyncClient`
   - Set timeout: 2 seconds
   - Use async/await

2. **Error Handling:**
   - 401 (invalid key) → Log error, return empty list
   - 429 (rate limit) → Log warning, return empty list
   - 400 (bad request) → Log error, return empty list
   - 500/502/503 → Retry once, then return empty list
   - Timeout → Return empty list
   - Network error → Return empty list

3. **Retry Logic:**
   - Only retry on 500/502/503/timeout
   - Wait 1 second before retry
   - Max 1 retry (2 total attempts)
   - Graceful degradation (return empty on failure)

4. **Response Parsing:**
   - Extract `results` array
   - Handle missing fields gracefully
   - Map to unified schema

#### **Result Mapping to Unified Schema:**

```
Foursquare Response → Unified Result:

fsq_id → "foursquare:{fsq_id}"
name → name
geocodes.main.latitude → lat
geocodes.main.longitude → lng
location.{address, locality, postcode} → combined address
(none) → source = "foursquare"
distance → distance_m (API provides in meters)
rating → rating (if present)
(none) → popularity = None
(none) → has_user_content = False
```

**Address Formatting:**
```
location.address: "Rue de Rivoli"
location.locality: "Paris"
location.postcode: "75001"

Combined → "Rue de Rivoli, Paris, 75001"

If any missing → skip that part
If all missing → address = None
```

**Edge Cases:**
- Missing geocodes → Skip result
- Missing name → Skip result
- API returns empty results → Return empty list
- API completely down → Return empty list (logged)

---

### **Task 4: Implement Geo Utilities**

**File:** `app/utils/geo.py`

**Purpose:** Calculate distance when APIs don't provide it

#### **Function: haversine_distance**

**Signature:**
```python
def haversine_distance(
    lat1: float,
    lng1: float,
    lat2: float,
    lng2: float
) -> float
```

**Purpose:** Calculate great-circle distance between two points on Earth

**Formula:**
```
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1−a))
distance = R × c

Where:
R = 6,371,000 meters (Earth's radius)
Δlat = lat2 - lat1 (in radians)
Δlng = lng2 - lng1 (in radians)
```

**Returns:** Distance in **meters** (not kilometers)

**Test Cases:**
```
Same point:
haversine_distance(48.8584, 2.2945, 48.8584, 2.2945) → 0.0

Paris to Eiffel Tower (~2km):
haversine_distance(48.8566, 2.3522, 48.8584, 2.2945) → ~2000 meters

Very long distance:
haversine_distance(48.8584, 2.2945, 40.7128, -74.0060) → ~5,800,000 meters
```

---

### **Task 5: Implement Deduplication**

**File:** `app/services/search_service.py` (add methods)

**Purpose:** Remove duplicate places from merged results

#### **Deduplication Rules:**

Two results are duplicates if **BOTH** conditions met:
1. **Name similarity ≥ 90%** (rapidfuzz)
2. **Distance ≤ 50 meters** (haversine)

#### **Priority Rules:**

When duplicates found:
```
Local ALWAYS wins over external:
  Result A: source="local"
  Result B: source="foursquare"
  → Keep A, discard B

Both same source:
  → Keep higher rating
  → If ratings equal, keep first
```

#### **Edge Cases:**

**Case 1: Name Variations**
```
"Café de Flore" vs "Cafe de Flore"
→ Normalize: strip accents, lowercase
→ Then compare
```

**Case 2: Null Coordinates**
```
Either result missing lat/lng:
→ Skip distance check
→ Use name similarity only (≥95% threshold)
```

**Case 3: Chain Restaurants**
```
"Starbucks" appears 5 times within 500m
→ Don't deduplicate if distance > 100m
→ Exception: If similarity = 100% AND distance > 100m → likely different locations
```

#### **Implementation Guidance:**

**Name Normalization:**
- Use `unicodedata.normalize('NFKD', name)`
- Strip combining characters (accents)
- Lowercase
- Strip whitespace

**Similarity:**
- Use `rapidfuzz.fuzz.ratio()`
- Returns 0-100 (percentage)
- Threshold: 90

**Distance:**
- Use `haversine_distance()` from geo utils
- Threshold: 50 meters

**Deduplication Algorithm:**
```
1. Separate local and external results
2. For each external result:
   a. Check against ALL local results
   b. If duplicate found → discard external
   c. If not duplicate → keep external
3. Deduplicate within external results (same logic)
4. Return: local_results + unique_external_results
```

---

### **Task 6: Extend SearchService**

**File:** `app/services/search_service.py`

**Purpose:** Orchestrate multi-source search with deduplication

**Updated `search_places` Method:**

```
Flow:
1. Normalize inputs (Session 14 utilities)
2. Generate cache key (not used yet)
3. Search local DB via LocalProvider
4. If len(local_results) < limit:
   a. Calculate remaining = limit - len(local_results)
   b. Search Foursquare via FoursquareProvider (limit=remaining)
   c. Handle API failures gracefully
5. Merge: all_results = local_results + external_results
6. Deduplicate: unique_results = deduplicate(all_results)
7. Limit: return unique_results[:limit]
```

**Requirements:**
- Initialize providers in `__init__`
- Call providers async
- Handle exceptions (don't crash on API failure)
- Log errors (print or proper logging)
- Return results in unified schema

**Error Handling:**
```
Foursquare fails:
→ Log error
→ Return local results only
→ Don't crash, don't propagate exception
```

---

## **Session 15 Testing Requirements**

### **Test File: Retrieval Tests**

**File:** `tests/test_search_retrieval.py`

**Test Coverage:**

#### **Test 1: Local Search Only**
- **Setup:** 12 places in DB matching "coffee"
- **Action:** Search with limit=10
- **Assert:** 
  - Returns 10 results
  - All source="local"
  - All has_user_content=True
  - Ordered by distance
  - No Foursquare call made

#### **Test 2: Foursquare Fallback**
- **Setup:** 2 local places, mock Foursquare returns 8
- **Action:** Search with limit=10
- **Assert:**
  - Returns 10 results total
  - 2 from local, 8 from Foursquare
  - Local appear first
  - Foursquare mock called with correct params

#### **Test 3: Deduplication**
- **Setup:** 
  - Local: "Café de Flore" at (48.8542, 2.3325)
  - Foursquare: "Cafe de Flore" at (48.8543, 2.3326)
- **Action:** Search
- **Assert:**
  - Returns 1 result (not 2)
  - Result has source="local"
  - Foursquare duplicate removed

#### **Test 4: Empty Results**
- **Setup:** No local matches, Foursquare returns empty
- **Action:** Search "xyzabc123"
- **Assert:**
  - Returns empty list
  - No errors raised

#### **Test 5: API Failure**
- **Setup:** 3 local results, Foursquare raises timeout
- **Action:** Search
- **Assert:**
  - Returns 3 results (local only)
  - No exception propagated
  - Warning logged

#### **Test 6: Invalid Coordinates**
- **Setup:** lat=999, lng=999
- **Action:** Search
- **Assert:**
  - Raises 400 error or handles gracefully

#### **Test 7: Unified Schema Compliance**
- **Setup:** Mixed results (local + Foursquare)
- **Action:** Search
- **Assert:**
  - All results have required fields
  - All match unified schema structure
  - No null where not allowed

**Coverage Target:** 85%+ for providers, 90%+ for SearchService

---

## **Session 15 Success Criteria**

- ✅ Provider abstraction created (base interface)
- ✅ LocalSearchProvider works (PostGIS + full-text)
- ✅ FoursquareProvider works (API integration)
- ✅ Geo utilities tested (haversine accurate)
- ✅ Deduplication logic correct (local priority)
- ✅ SearchService orchestrates correctly
- ✅ All results match unified schema
- ✅ Error handling works (graceful degradation)
- ✅ All tests pass (>85% coverage)
- ✅ Mock Foursquare in tests (no real API calls)
- ✅ Code committed to git

---

## **Session 15 Non-Goals**

**Do NOT implement:**
- ❌ Ranking/scoring (Session 16)
- ❌ Search endpoints (Session 16)
- ❌ Signal logging in API (Session 16)
- ❌ Redis caching (post-MVP)
- ❌ Mapbox provider (add later if needed)
- ❌ External result persistence (skip for MVP)

---

# **SESSION 16: Intelligence Layer**

**Duration:** 1 week  
**Objective:** Add ranking, expose API, enable learning system

---

## **Session 16 Overview**

**What Gets Built:**
1. Ranking algorithm (weighted scoring)
2. Score explanation system (debugging)
3. Search API endpoints (public interface)
4. Signal logging integration (background tasks)
5. API tests (comprehensive coverage)

**Why Session 16:**
- Ranking = relevant results first (UX)
- API = frontend can use search
- Signals = system learns and improves
- Explainability = easy to debug/tune

---

## **Session 16 Architecture**

### **Ranking Flow:**
```
1. Get unranked results (from Session 15)
2. Calculate score for each result
3. Sort by score (highest first)
4. Optionally add score explanation (debug mode)
5. Return ranked results
```

### **API Flow:**
```
1. Receive search request (authenticated)
2. Validate parameters
3. Call SearchService.search_places()
4. Log search event (background task)
5. Return ranked results to user
```

---

## **Session 16 Tasks**

### **Task 1: Implement Ranking Algorithm**

**File:** `app/services/search_service.py` (add ranking methods)

**Purpose:** Score and sort results by relevance

#### **Ranking Formula:**

```
score = (
    source_weight * 0.4 +
    text_relevance * 0.3 +
    popularity * 0.2 +
    freshness * 0.1
)

Range: 0.0 to 1.0 (higher = better)
```

#### **Component 1: Source Weight (40%)**

**Purpose:** Prioritize user-contributed data

```
Weights:
local: 1.0
foursquare: 0.6
mapbox: 0.6  (future)
```

**Why 40%:** Source is most important (user data > corporate data)

---

#### **Component 2: Text Relevance (30%)**

**Purpose:** Match quality (exact > partial)

**Local Results:**
- Use `ts_rank_cd` from PostgreSQL
- Already returns 0.0-1.0 scale
- Higher = better match

**External Results:**
- Exact match in name: 1.0
- Partial word match: 0.7
- Category match only: 0.5
- Weak match: 0.3

**Implementation:**
```
query = "coffee"

"Coffee Bean" → 1.0 (exact word match)
"Café Latte" → 0.7 (related)
"Gift Shop" → 0.3 (weak)
```

---

#### **Component 3: Popularity (20%)**

**Purpose:** Wisdom of the crowd

**Local Results:**
```
save_count = COUNT from place_saves table
max_saves = 100 (calibrate based on data)
popularity_score = min(save_count / max_saves, 1.0)
```

**External Results:**
```
If Foursquare provides popularity/rating:
  popularity_score = rating / 10
Else:
  popularity_score = 0.1 (neutral default)
```

**Why 20%:** Important but not dominant (avoids echo chamber)

---

#### **Component 4: Freshness (10%)**

**Purpose:** Trending vs stale

**Local Results:**
```
age_days = (now - created_at).days

< 7 days: 1.0
< 30 days: 0.8
< 90 days: 0.5
older: 0.3
```

**External Results:**
```
freshness_score = 0.5 (neutral, no creation date)
```

**Why 10%:** Least important (quality > newness)

---

#### **Score Calculation Example:**

```
Result: "Coffee Lab Paris"
- source: local → 1.0
- text_match: "coffee" exact → 1.0
- popularity: 20 saves → 0.2
- freshness: 5 days old → 1.0

score = 1.0*0.4 + 1.0*0.3 + 0.2*0.2 + 1.0*0.1
      = 0.4 + 0.3 + 0.04 + 0.1
      = 0.84

→ Highly ranked!
```

---

### **Task 2: Implement Score Explanation**

**File:** `app/services/search_service.py`

**Purpose:** Debug and tune ranking

**Add to Result Schema (Optional, Debug Mode):**
```
"_debug": {
    "source_score": 1.0,
    "source_contribution": 0.4,
    "text_score": 1.0,
    "text_contribution": 0.3,
    "popularity_score": 0.2,
    "popularity_contribution": 0.04,
    "freshness_score": 1.0,
    "freshness_contribution": 0.1,
    "final_score": 0.84,
    "breakdown": "0.4 + 0.3 + 0.04 + 0.1 = 0.84"
}
```

**Usage:**
```
GET /search/places?query=coffee&lat=48.8&lng=2.3&debug=true

→ Returns results with _debug field
```

**Why:**
- See why result ranked high/low
- Tune weights based on feedback
- Debug user complaints

---

### **Task 3: Create Search Schemas**

**File:** `app/schemas/search.py`

**Purpose:** Pydantic models for API validation

#### **SearchQuery (Request)**

```
query: str (1-100 chars, required)
lat: float (-90 to 90, required)
lng: float (-180 to 180, required)
radius_km: float (0.1 to 50, default 5.0)
limit: int (1 to 50, default 10)
debug: bool (default False)
```

**Validation:**
- Query not empty
- Coordinates in valid range
- Radius reasonable
- Limit reasonable

---

#### **SearchResult (Response)**

```
Unified schema from Sessions 15:
id: str | None
name: str
lat: float
lng: float
address: str | None
source: str
distance_m: float
rating: float | None
popularity: int | None
has_user_content: bool

Added in Session 16:
score: float (ranking score, 0-1)
_debug: dict | None (only if debug=True)
```

---

#### **SearchResponse (List)**

```
results: List[SearchResult]
count: int
query: str (echoed back)
```

---

### **Task 4: Create Search API Endpoints**

**File:** `app/api/v1/search.py`

**Purpose:** Public search interface

#### **Endpoint: GET /api/v1/search/places**

**Authentication:** Required

**Query Parameters:**
```
query: str
lat: float
lng: float
radius_km: float = 5.0
limit: int = 10
debug: bool = False
```

**Response:** `SearchResponse` (list of ranked results)

**Implementation Requirements:**

1. **Validate inputs** (use SearchQuery schema)
2. **Get current user** (from auth dependency)
3. **Call SearchService.search_places()**
4. **Log search event** (background task)
5. **Return results**

**Background Task:**
```python
background_tasks.add_task(
    log_search_event,
    db=db,
    user_id=current_user.id,
    query=query,
    lat=lat,
    lng=lng,
    radius_km=radius_km,
    results_count=len(results)
)
```

**Error Handling:**
```
400: Invalid parameters (bad coords, empty query)
401: Not authenticated
500: Internal error (log and return generic message)
```

---

### **Task 5: Integrate Signal Logging**

**File:** `app/services/search_service.py` (add helper function)

**Purpose:** Log search events without blocking requests

#### **Function: log_search_event**

**Signature:**
```python
def log_search_event(
    db: Session,
    user_id: UUID,
    query: str,
    lat: float,
    lng: float,
    radius_km: float,
    results_count: int
)
```

**Implementation:**
```
1. Create new SearchEvent model instance
2. Add to session
3. Commit
4. Handle errors gracefully (log, don't crash)
5. Close session (background task owns session)
```

**Important:**
- Runs in background (after response sent)
- Creates NEW db session (don't reuse request session)
- Catches ALL exceptions (can't crash background task)
- Logs errors but doesn't propagate
- Keeps task lightweight (< 100ms)

**Why Background:**
- User gets response faster (doesn't wait for DB write)
- Non-critical operation (logging)
- Improves perceived performance

---

### **Task 6: Update Place Endpoints**

**File:** `app/api/v1/places.py` (extend existing endpoints)

**Purpose:** Log place views when users access place details

#### **Extend GET /api/v1/places/{place_id}**

**Add:**
```python
# After fetching place, before returning:
background_tasks.add_task(
    log_place_view,
    db=db,
    user_id=current_user.id,
    place_id=place_id,
    source="local"  # Or determine from place metadata
)
```

#### **Extend POST /api/v1/places**

**Add:**
```python
# After creating place:
background_tasks.add_task(
    log_place_save,
    db=db,
    user_id=current_user.id,
    place_id=new_place.id
)
```

**Helper Functions:**

Similar to `log_search_event`, create:
- `log_place_view()`
- `log_place_save()`

---

## **Session 16 Testing Requirements**

### **Test File: API Tests**

**File:** `tests/test_search_api.py`

**Test Coverage:**

#### **Test 1: Successful Search**
- **Setup:** Auth user, 5 places in DB
- **Action:** GET /search/places?query=coffee&lat=48.8&lng=2.3
- **Assert:**
  - 200 status
  - Returns results
  - Results ranked (scores descending)
  - search_events table has entry

#### **Test 2: Authentication Required**
- **Action:** Request without auth token
- **Assert:** 401 Unauthorized

#### **Test 3: Invalid Parameters**
- **Action:** lat=999 (invalid)
- **Assert:** 400 Bad Request

#### **Test 4: Empty Results**
- **Action:** Search nonsense query
- **Assert:**
  - 200 status
  - Empty results list
  - search_events still logged

#### **Test 5: Debug Mode**
- **Action:** debug=true in query
- **Assert:**
  - Results have _debug field
  - _debug has score breakdown

#### **Test 6: Ranking Order**
- **Setup:** 
  - Place A: local, 50 saves, recent
  - Place B: foursquare, no saves
- **Action:** Search
- **Assert:** Place A ranked higher than B

#### **Test 7: Signal Logging**
- **Action:** Multiple searches
- **Assert:**
  - search_events table grows
  - Correct user_id logged
  - Correct query logged

**Coverage Target:** 90%+ for API endpoints

---

### **Test File: Ranking Tests**

**File:** `tests/test_search_ranking.py`

**Test Coverage:**

#### **Test 1: Source Weight Dominates**
- **Setup:** 2 results, same text/popularity/freshness
  - A: source=local
  - B: source=foursquare
- **Assert:** A scores higher

#### **Test 2: Popularity Matters**
- **Setup:** 2 local results
  - A: 50 saves
  - B: 5 saves
- **Assert:** A scores higher

#### **Test 3: Freshness Bonus**
- **Setup:** 2 local results, same popularity
  - A: 3 days old
  - B: 300 days old
- **Assert:** A scores higher

#### **Test 4: Score Calculation**
- **Setup:** Known values
- **Action:** Calculate score
- **Assert:** Matches expected formula

#### **Test 5: Score Explanation**
- **Action:** Generate debug breakdown
- **Assert:**
  - All components present
  - Math adds up correctly

**Coverage Target:** 95%+ for ranking logic

---

## **Session 16 Success Criteria**

- ✅ Ranking algorithm implemented (weighted formula)
- ✅ Score explanation working (debug mode)
- ✅ Search API endpoint created
- ✅ Signal logging integrated (background tasks)
- ✅ Place endpoints updated (view/save logging)
- ✅ All tests pass (>90% coverage)
- ✅ API returns ranked results
- ✅ search_events table populating
- ✅ Debug mode shows score breakdown
- ✅ Code committed to git

---

## **Session 16 Non-Goals**

**Do NOT implement:**
- ❌ Redis caching (post-MVP)
- ❌ ML-based ranking (Phase 5+)
- ❌ Personalized results (Phase 5+)
- ❌ Autocomplete/suggestions (future)
- ❌ Search history UI (frontend)
- ❌ Analytics dashboard (future)

---

# **Phase 2B Completion Checklist**

## **Session 14 Complete:**
- [ ] search_vector column + GIN index
- [ ] Auto-update trigger working
- [ ] Signal tables created
- [ ] Normalization utilities tested
- [ ] Cache key generator tested
- [ ] SearchService skeleton exists
- [ ] All Session 14 tests pass
- [ ] Integration test passes

## **Session 15 Complete:**
- [ ] Provider abstraction created
- [ ] LocalSearchProvider working
- [ ] FoursquareSearchProvider working
- [ ] Geo utilities tested
- [ ] Deduplication logic correct
- [ ] SearchService retrieval working
- [ ] All Session 15 tests pass
- [ ] Mock Foursquare in tests

## **Session 16 Complete:**
- [ ] Ranking algorithm working
- [ ] Score explanation implemented
- [ ] Search API endpoint created
- [ ] Signal logging integrated
- [ ] Place endpoints updated
- [ ] All Session 16 tests pass
- [ ] End-to-end search working

## **Phase 2B Success:**
- [ ] User can search for places via API
- [ ] Results ranked by relevance
- [ ] Local data prioritized
- [ ] Foursquare fills gaps
- [ ] No duplicates in results
- [ ] Every search logged (signals)
- [ ] System ready for Phase 3A (Frontend)

---

# **Post-Phase 2B: What's Next**

## **Phase 3A: Frontend Integration**
- Build search UI component
- Integrate with search API
- Display ranked results
- Handle errors gracefully

## **Future Enhancements (Post-MVP)**

### **Performance:**
- Add Redis caching (use existing cache keys)
- Implement request debouncing
- Add pagination

### **Features:**
- Autocomplete/suggestions
- Search filters (price, rating, category)
- Recent searches
- Saved searches

### **Intelligence:**
- ML-based ranking (use signals)
- Personalized results
- Trending places
- Discovery feed

### **Sources:**
- Add Mapbox provider
- Add Google Places provider
- Add user-submitted sources

---

# **AI Agent Implementation Notes**

## **General Guidelines**

1. **Follow existing patterns:**
   - Model structure matches Trip/Place models
   - Service structure matches PlaceService
   - API structure matches existing endpoints

2. **Type hints everywhere:**
   - All function parameters
   - All return types
   - Use `List`, `Dict`, `Optional` from typing

3. **Docstrings required:**
   - All classes
   - All public methods
   - Include Args, Returns, Raises sections

4. **Error handling:**
   - Never let exceptions crash the app
   - Log errors, return graceful fallbacks
   - User sees clean error messages

5. **Testing:**
   - Write tests before implementation (TDD)
   - Mock external services (Foursquare)
   - Aim for >90% coverage

6. **Incremental development:**
   - Complete Session 14 fully before 15
   - Complete Session 15 fully before 16
   - Test after each session

7. **No premature optimization:**
   - Build cache hooks, don't implement Redis
   - Simple queries first, optimize later
   - Focus on correctness over performance

## **Session-Specific Notes**

### **Session 14:**
- Migrations must be idempotent (`IF NOT EXISTS`, `OR REPLACE`)
- Complete downgrade paths (clean rollback)
- Test trigger auto-updates search_vector
- Verify all indexes created

### **Session 15:**
- Mock Foursquare in ALL tests (no real API calls)
- Test deduplication edge cases thoroughly
- Provider pattern strict (all inherit from base)
- Unified schema enforced everywhere

### **Session 16:**
- Background tasks don't share DB session
- Ranking weights can be tuned later
- Debug mode optional (query param)
- Signal logging never blocks user

---

**END OF PHASE 2B PRD**