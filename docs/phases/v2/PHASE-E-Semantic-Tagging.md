# **PHASE E: Semantic Tagging System - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** E  
**Duration:** 1.5 weeks  
**Dependencies:** Phase A1 (Metadata Backend), Phase D (Timeline)  
**Goal:** Add UI for semantic tagging of trips and components for discovery

**Combines:** E1 (Component Metadata Forms), E2 (Trip Profile Builder), E3 (Public/Private Controls)

---

## **🎯 Objectives**

**Primary Goal:**  
Enable users to tag trips and components with semantic metadata for future intelligent search and discovery.

**What Success Looks Like:**
- User can tag individual places/routes with experience tags
- User can set trip-level profile (traveler type, budget, activity focus)
- User can mark components/trips as public (discoverable)
- Metadata powers Phase F discovery engine
- Quality scores auto-calculate based on completeness

---

## **🏗️ Architecture Overview**

### **Data Flow:**

```
Component-Level Metadata (Places/Routes):
User clicks place/route in timeline
    ↓
Bottom panel shows metadata form
    ↓
Fill tags: best_for, experience_tags, difficulty
    ↓
POST /api/v1/places/{id}/metadata (Phase A1 endpoint)
    ↓
Metadata saved, component badge updates

Trip-Level Metadata:
User opens trip settings (top bar)
    ↓
Trip profile form opens (modal)
    ↓
Fill: traveler_type, age_group, budget, activity_focus
    ↓
POST /api/v1/trips/{trip_id}/metadata (Phase A1 endpoint)
    ↓
Trip tagged for discovery

Public/Private Toggle:
User toggles "Make Public" in trip settings
    ↓
Updates trip.visibility AND metadata.is_discoverable
    ↓
Components inherit public flag (show in discovery)
```

### **Backend Integration:**

**Uses Phase A1 endpoints (already implemented):**

**Place Metadata:**
- `POST /api/v1/places/{place_id}/metadata`
- `GET /api/v1/places/{place_id}/metadata`
- `PATCH /api/v1/places/{place_id}/metadata`

**Trip Metadata:**
- `POST /api/v1/trips/{trip_id}/metadata`
- `GET /api/v1/trips/{trip_id}/metadata`
- `PATCH /api/v1/trips/{trip_id}/metadata`

---

## **📁 File Structure**

```
frontend/src/
├── components/Editor/
│   ├── PlaceMetadataForm.tsx         (NEW - E1)
│   ├── RouteMetadataForm.tsx         (EXISTING - from C3)
│   ├── TripProfileModal.tsx          (NEW - E2)
│   ├── ExperienceTagSelector.tsx     (NEW - E1)
│   ├── BestForSelector.tsx           (NEW - E1)
│   ├── DifficultyRating.tsx          (NEW - E1)
│   ├── TravelerTypeSelector.tsx      (NEW - E2)
│   ├── ActivityFocusSelector.tsx     (NEW - E2)
│   ├── PublicToggle.tsx              (NEW - E3)
│   ├── QualityScoreBadge.tsx         (NEW - E3)
│   └── TopBar.tsx                    (UPDATE - Add settings button)
├── services/
│   ├── placeMetadataService.ts       (NEW - E1)
│   └── tripMetadataService.ts        (NEW - E2)
├── hooks/
│   ├── usePlaceMetadata.ts           (NEW - E1)
│   ├── useTripMetadata.ts            (NEW - E2)
│   └── useQualityScore.ts            (NEW - E3)
└── utils/
    └── qualityScoreCalculator.ts     (NEW - E3)
```

---

## **🔧 E1: Component Metadata Forms**

### **Goal:** Tag individual places/routes with experience metadata

### **Backend Schema Reference (Phase A1):**

**PlaceMetadata:**
```typescript
interface PlaceMetadata {
  place_id: string;
  component_type: 'place' | 'activity' | 'accommodation' | 'food';
  experience_tags: string[];  // ['romantic', 'adventurous', 'peaceful']
  best_for: string[];         // ['solo-travelers', 'couples', 'families']
  budget_per_person?: number;
  duration_hours?: number;
  difficulty_rating?: number; // 1-5
  physical_demand?: 'low' | 'medium' | 'high';
  best_time?: 'sunrise' | 'morning' | 'afternoon' | 'sunset' | 'night';
  is_public: boolean;
  contribution_score: number; // Auto-calculated
}
```

### **Place Metadata Form:**

**Trigger:** Click place in timeline → bottom panel → "Metadata" tab

**Form Sections:**

**Section 1: Classification**
- Component Type (dropdown): Place / Activity / Accommodation / Food
- Auto-suggest based on `place_type` from search

**Section 2: Experience Tags**
- Multi-select chips
- Pre-defined options: romantic, adventurous, peaceful, crowded, instagram-worthy, hidden-gem, touristy, authentic, spiritual, scenic
- Allow custom tags (max 10)
- Visual: Coral accent (#FB923C) chips

**Section 3: Best For**
- Multi-select chips
- Options: solo-travelers, couples, families, photographers, foodies, adventurers, budget-travelers, luxury-travelers
- Max 5 selections

**Section 4: Practical Info**
- Budget per Person (optional, USD input)
- Duration (optional, hours slider: 0.5 - 8 hours)
- Best Time (dropdown: sunrise/morning/afternoon/sunset/night/anytime)

**Section 5: Difficulty**
- Difficulty Rating (1-5 scale with icons)
- Physical Demand (radio: Low / Medium / High)
- Help text: "How physically demanding is this place/activity?"

**Section 6: Visibility**
- Public checkbox
- Explanation: "Allow others to discover this place"
- Only enabled if trip is public

**Buttons:**
- Save Metadata (primary)
- Cancel (secondary)

### **Route Metadata Integration:**

**Note:** Route metadata form already exists from Phase C3

**Enhancement for E1:**
- Add same visibility controls (is_public checkbox)
- Add contribution score display
- Link to trip-level public setting

---

## **🔧 E2: Trip Profile Builder**

### **Goal:** Tag entire trip with traveler profile for discovery

### **Backend Schema Reference (Phase A1):**

**TripMetadata:**
```typescript
interface TripMetadata {
  trip_id: string;
  traveler_type: string[];      // ['solo', 'couple', 'family', 'group']
  age_group?: 'gen-z' | 'millennial' | 'gen-x' | 'boomer';
  travel_style: string[];       // ['adventure', 'luxury', 'budget', 'cultural']
  difficulty_level?: 'easy' | 'moderate' | 'challenging' | 'extreme';
  budget_category?: 'budget' | 'mid-range' | 'luxury';
  activity_focus: string[];     // ['hiking', 'food', 'photography', 'nightlife']
  is_discoverable: boolean;
  quality_score: number;        // Auto-calculated
  tags: string[];               // User-defined custom tags
}
```

### **Trip Profile Modal:**

**Trigger:** Click settings icon in top bar → "Trip Profile"

**Modal Layout:** Full-screen overlay with scrollable form

**Form Sections:**

**Section 1: Traveler Profile**
- Traveler Type (multi-select): Solo / Couple / Family / Group
- Age Group (single-select): Gen Z / Millennial / Gen X / Boomer
- Travel Style (multi-select): Adventure / Luxury / Budget / Cultural / Relaxed
- Max 3 selections for travel style

**Section 2: Trip Characteristics**
- Difficulty Level (single-select with icons):
  - Easy (☕): Mostly relaxed, minimal physical activity
  - Moderate (🥾): Some walking/activity, generally accessible
  - Challenging (⛰️): Requires fitness, some difficult terrain
  - Extreme (🏔️): High physical demand, remote locations
- Budget Category (radio): Budget / Mid-Range / Luxury
- Visual: Show price icons ($ / $$ / $$$)

**Section 3: Activity Focus**
- Multi-select chips
- Pre-defined: hiking, food, photography, nightlife, beaches, culture, history, wildlife, shopping, adventure-sports, relaxation, spirituality
- Allow custom activities
- Max 5 selections

**Section 4: Custom Tags**
- Tag input field
- Examples: "monsoon-travel", "off-season", "road-trip", "backpacking"
- Tags used for search keywords
- Max 10 custom tags

**Section 5: Discovery Settings**
- "Make this trip discoverable" toggle
- Explanation: "Allow others to find this trip when searching for similar experiences"
- Shows quality score preview
- Warns if score < 0.5 ("Add more details to improve discoverability")

**Quality Score Display:**
- Real-time calculation as user fills form
- Progress bar (0-100%)
- Breakdown tooltip:
  - Trip metadata: 30%
  - Component metadata: 40%
  - Media attachments: 20%
  - Timeline completeness: 10%

**Buttons:**
- Save Profile (primary, disabled if quality < 0.3 and is_discoverable = true)
- Cancel (secondary)

---

## **🔧 E3: Public/Private Controls**

### **Goal:** Manage visibility and calculate quality scores

### **Visibility Hierarchy:**

```
Trip Level:
  trip.visibility = 'private' | 'unlisted' | 'public'
  trip_metadata.is_discoverable = true/false

Component Level (inherits from trip):
  place_metadata.is_public = true/false
  route_metadata.is_public = true/false

Rules:
- If trip is private → all components private (force)
- If trip is public → components can be public (user choice)
- If trip is unlisted → shareable link only, not discoverable
```

### **Public Toggle Component:**

**Location:** Trip settings modal (top section)

**Visual Design:**
- Large toggle switch (Ocean teal when on)
- Label: "Make trip discoverable"
- Sub-text: "Your trip will appear in search results for other travelers"
- Warning (if enabled): "All public components will be visible"

**Behavior:**
- Toggle ON:
  - Checks quality score
  - If quality < 0.5 → show warning modal
  - "Your trip needs more details to be discoverable. Continue anyway?"
  - If confirmed → set `is_discoverable = true`
  - Updates `trip.visibility = 'public'`
  
- Toggle OFF:
  - Set `is_discoverable = false`
  - Keep `trip.visibility` (can be 'unlisted' for sharing)

### **Quality Score Calculation:**

**Algorithm (Frontend):**

**Total Score = 1.0 (100%)**

**Breakdown:**
```
Trip Metadata (30%):
  - Has traveler_type: 5%
  - Has age_group: 5%
  - Has travel_style: 5%
  - Has difficulty_level: 5%
  - Has budget_category: 5%
  - Has activity_focus: 5%

Component Metadata (40%):
  - % of places with metadata: 20%
  - % of routes with metadata: 20%

Media (20%):
  - Has cover photo: 5%
  - Photos per place (avg > 2): 10%
  - Has route photos: 5%

Timeline Completeness (10%):
  - Has description: 5%
  - Has dates (start/end): 5%
```

**Formula:**
```typescript
score = (
  tripMetadataScore * 0.30 +
  componentMetadataScore * 0.40 +
  mediaScore * 0.20 +
  timelineScore * 0.10
)
```

**Display:**
- 0.0 - 0.3: Poor (red, not recommended for public)
- 0.3 - 0.6: Fair (yellow, needs improvement)
- 0.6 - 0.8: Good (green, ready for public)
- 0.8 - 1.0: Excellent (ocean teal, highly discoverable)

### **Quality Score Badge:**

**Location:** 
- Top bar (next to trip title)
- Trip profile modal (prominent display)

**Visual:**
- Circular progress ring
- Percentage in center
- Color-coded by quality tier
- Tooltip on hover showing breakdown

**Interaction:**
- Click badge → open trip profile modal
- Shows suggestions to improve score

### **Component Public Indicators:**

**Timeline Items:**
- Public components show small globe icon (🌍)
- Private components show lock icon (🔒)
- Click icon → toggle component visibility (opens metadata form)

**Map:**
- Public markers have subtle glow/outline
- Private markers standard styling
- No difference in functionality, just visual

---

## **✅ Success Criteria**

### **E1: Component Metadata**
- [ ] Place metadata form opens from timeline
- [ ] All fields save to backend correctly
- [ ] Experience tags display as chips
- [ ] Best-for selections work (multi-select)
- [ ] Difficulty rating functional (1-5 scale)
- [ ] Public checkbox syncs with trip setting
- [ ] Form validation prevents invalid data
- [ ] Metadata appears in timeline item badges

### **E2: Trip Profile**
- [ ] Trip profile modal opens from top bar
- [ ] All profile fields map to backend schema
- [ ] Traveler type multi-select works
- [ ] Activity focus selector works
- [ ] Custom tags can be added/removed
- [ ] Quality score updates in real-time
- [ ] Save updates trip metadata in DB
- [ ] Profile data persists on refresh

### **E3: Public/Private**
- [ ] Public toggle works (trip level)
- [ ] Quality score calculates correctly
- [ ] Score < 0.5 shows warning on public toggle
- [ ] Component public flags inherit from trip
- [ ] Timeline shows public indicators (globe/lock)
- [ ] Quality score badge displays in top bar
- [ ] Click badge opens profile modal
- [ ] Score breakdown tooltip shows details

---

## **🧪 Test Cases**

**Manual Testing:**
```
E1: Component Metadata
1. Open trip with 3 places
2. Click first place in timeline
3. Bottom panel → Metadata tab
4. Fill form:
   - Type: Activity
   - Tags: adventurous, scenic
   - Best for: solo-travelers, photographers
   - Budget: $50
   - Duration: 3 hours
   - Difficulty: 4/5
5. Save → toast "Metadata saved"
6. Timeline item shows tags badge
7. Refresh → metadata persists

E2: Trip Profile
1. Click settings icon → Trip Profile
2. Modal opens
3. Fill profile:
   - Traveler: Solo
   - Age: Millennial
   - Style: Adventure, Budget
   - Difficulty: Challenging
   - Budget: Budget
   - Activities: hiking, photography
4. Watch quality score increase
5. Save → toast "Profile updated"
6. Close modal
7. Top bar shows quality badge (e.g., 65%)

E3: Public Toggle
1. Open trip profile modal
2. Quality score = 45% (Fair)
3. Toggle "Make discoverable" ON
4. Warning appears: "Score below 50%"
5. Confirm → trip.is_discoverable = true
6. Add more metadata to places
7. Quality score increases to 72%
8. Badge turns green
9. Timeline shows globe icons on items
10. Toggle OFF → globe icons disappear
```

---

## **⚠️ Common Pitfalls**

### **1. Quality Score Sync**
- Score calculated frontend (real-time preview)
- Backend also calculates on save (source of truth)
- Frontend must refetch after save to get accurate score
- Don't rely solely on frontend calculation

### **2. Public Flag Hierarchy**
- Trip private → force all components private
- Don't allow component.is_public = true if trip private
- Form should disable component public checkbox when trip private

### **3. Tag Array Format**
- Backend expects PostgreSQL ARRAY type: `['tag1', 'tag2']`
- Not comma-separated string
- Send as JSON array in request

### **4. Experience Tags vs Custom Tags**
- Experience tags: Pre-defined set for consistency
- Custom tags: User-defined for flexibility
- Both stored in same array field, but UI treats differently

### **5. Metadata Completeness**
- User can save partial metadata (all fields optional except defaults)
- Quality score penalizes missing data
- Don't force required fields, but incentivize completion

---

## **📦 Deliverables**

**E1: Component Metadata Forms**
1. 1 place metadata form (PlaceMetadataForm.tsx)
2. 3 selector components (ExperienceTagSelector, BestForSelector, DifficultyRating)
3. 1 service file (placeMetadataService.ts)
4. 1 hooks file (usePlaceMetadata.ts)

**E2: Trip Profile Builder**
1. 1 trip profile modal (TripProfileModal.tsx)
2. 2 selector components (TravelerTypeSelector, ActivityFocusSelector)
3. 1 service file (tripMetadataService.ts)
4. 1 hooks file (useTripMetadata.ts)

**E3: Public/Private Controls**
1. 1 toggle component (PublicToggle.tsx)
2. 1 badge component (QualityScoreBadge.tsx)
3. 1 calculator utility (qualityScoreCalculator.ts)
4. 1 hooks file (useQualityScore.ts)
5. Updated TopBar (settings button)
6. Updated timeline items (public indicators)

**Total LOC Estimate:** ~900 LOC

---

## **🔗 Integration Notes**

### **Phase Dependencies:**
- **Phase A1:** Metadata backend endpoints (already built)
- **Phase D:** Timeline component (for displaying badges)
- **Phase C:** Route metadata form (enhance for E1)

### **No Backend Changes:**
- All endpoints from Phase A1
- `POST/GET/PATCH /places/{id}/metadata`
- `POST/GET/PATCH /trips/{id}/metadata`
- Quality score calculated frontend + backend

### **Future Phases:**
- **Phase F:** Metadata powers search algorithm
- **Phase F:** Quality score affects search ranking
- **Phase F:** Public trips appear in discovery feed

---

## **📋 Acceptance Checklist**

**Before marking Phase E complete:**
- [ ] Place metadata form functional
- [ ] Trip profile modal functional
- [ ] All form fields save to backend correctly
- [ ] Quality score calculates accurately
- [ ] Public toggle works (trip + components)
- [ ] Public indicators show in timeline
- [ ] Quality badge displays in top bar
- [ ] Form validation prevents bad data
- [ ] Metadata persists on refresh
- [ ] No breaking changes to Phases A-D

---

**END OF PHASE E PRD**

---

## **🎯 Phases A-E Complete**

**With A, B, C, D, E done, you have:**
- ✅ Backend: Full metadata infrastructure
- ✅ Frontend: Complete editor with all features
- ✅ Semantic tagging: Ready for discovery
- ✅ V2 Editor: 95% complete

**Next:** Phase F (Discovery Engine) - Search, ranking, recommendations

---

**Ready for AI Agent? START PHASE E.**