# **PHASE C3: Route Metadata UI - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** C3  
**Duration:** 3 days  
**Dependencies:** Phase C1 (Route Drawing), C2 (Waypoints)  
**Goal:** Add UI for tagging routes with metadata (transport mode, terrain, safety)

---

## **🎯 Objectives**

**Primary Goal:**  
User can add descriptive metadata to routes for future discovery and personalization.

**What Success Looks Like:**
- Click route → metadata panel opens
- Select transport mode (already set during drawing, can change)
- Add terrain tags (scenic, mountainous, bumpy)
- Set safety rating (1-5 stars)
- Mark solo-friendly, road condition, highlights
- Save metadata → stored in `route_metadata` table (Phase A2 backend)

---

## **🏗️ Architecture Overview**

### **Data Flow:**

```
User selects route
    ↓
Bottom panel slides up with metadata form
    ↓
User fills metadata fields:
  - Transport mode (dropdown)
  - Terrain tags (multi-select chips)
  - Safety rating (star selector)
  - Road condition (radio buttons)
  - Highlights (tag input)
    ↓
Click "Save Metadata"
    ↓
POST /api/v1/routes/{route_id}/metadata (Phase A2 endpoint)
    ↓
Metadata saved to DB
    ↓
Route badge updates (shows tags on map)
```

### **Backend Integration:**

**Uses Phase A2 endpoints:**
- `POST /api/v1/routes/{route_id}/metadata` - Create
- `GET /api/v1/routes/{route_id}/metadata` - Retrieve  
- `PATCH /api/v1/routes/{route_id}/metadata` - Update
- `DELETE /api/v1/routes/{route_id}/metadata` - Delete

**Schema Reference (from Phase A2):**
```typescript
interface RouteMetadata {
  route_id: string;
  route_quality?: 'scenic' | 'fastest' | 'offbeat';
  road_condition?: 'excellent' | 'good' | 'poor' | 'offroad';
  scenic_rating?: number;  // 1-5
  safety_rating: number;   // 1-5
  solo_safe: boolean;
  fuel_cost?: number;
  toll_cost?: number;
  highlights?: string[];   // ['waterfall', 'viewpoint']
  is_public: boolean;
}
```

---

## **📁 File Structure**

```
frontend/src/
├── components/Editor/
│   ├── BottomPanel.tsx               (UPDATE - Show metadata form)
│   ├── RouteMetadataForm.tsx         (NEW - Main form)
│   ├── TerrainTagSelector.tsx        (NEW - Multi-select chips)
│   ├── SafetyRatingInput.tsx         (NEW - Star rating)
│   ├── HighlightsInput.tsx           (NEW - Tag input field)
│   └── RouteMetadataBadge.tsx        (NEW - Shows tags on map)
├── services/
│   └── routeMetadataService.ts       (NEW - API calls)
├── hooks/
│   └── useRouteMetadata.ts           (NEW - React Query hooks)
└── types/
    └── routeMetadata.ts              (NEW - Type definitions)
```

---

## **🔧 Implementation Requirements**

### **1. Type Definitions**

**src/types/routeMetadata.ts:**

Match Phase A2 backend schema exactly:
```typescript
export interface RouteMetadata {
  route_id: string;
  route_quality?: 'scenic' | 'fastest' | 'offbeat';
  road_condition?: 'excellent' | 'good' | 'poor' | 'offroad';
  scenic_rating?: number;
  safety_rating: number;
  solo_safe: boolean;
  fuel_cost?: number;
  toll_cost?: number;
  highlights?: string[];
  is_public: boolean;
  created_at: string;
  updated_at: string;
}

export interface RouteMetadataCreate {
  route_quality?: 'scenic' | 'fastest' | 'offbeat';
  road_condition?: 'excellent' | 'good' | 'poor' | 'offroad';
  scenic_rating?: number;
  safety_rating?: number;
  solo_safe?: boolean;
  fuel_cost?: number;
  toll_cost?: number;
  highlights?: string[];
  is_public?: boolean;
}
```

---

### **2. Service Layer**

**src/services/routeMetadataService.ts:**

**Methods Required:**
- `getMetadata(routeId: string)` → GET endpoint
- `createMetadata(routeId: string, data)` → POST endpoint  
- `updateMetadata(routeId: string, data)` → PATCH endpoint
- `deleteMetadata(routeId: string)` → DELETE endpoint

**Pattern:** Same as `tripService.ts` and `placeService.ts` from Phase 2.

---

### **3. React Query Hooks**

**src/hooks/useRouteMetadata.ts:**

**Hooks Required:**
- `useRouteMetadata(routeId)` - Fetch metadata (useQuery)
- `useCreateRouteMetadata(routeId)` - Create mutation
- `useUpdateRouteMetadata(routeId)` - Update mutation  
- `useDeleteRouteMetadata(routeId)` - Delete mutation

**Pattern:** Same as `useTrips.ts` - query + 3 mutations with cache invalidation.

---

### **4. Bottom Panel Enhancement**

**src/components/Editor/BottomPanel.tsx (UPDATE):**

**Current State:** Collapsed/empty placeholder (from Phase B3)

**New Behavior:**
- When `selectedRoute` set in store → slide up from bottom
- Show 2 tabs: "Details" | "Metadata"
- Details tab: Route name, distance, duration, waypoint count
- Metadata tab: `<RouteMetadataForm />` component
- Close button → clear `selectedRoute`, slide down

**Trigger:** `useEditorStore().selectedRoute` changes

---

### **5. Route Metadata Form**

**src/components/Editor/RouteMetadataForm.tsx (NEW):**

**Form Fields:**

**Section 1: Route Characteristics**
- Transport Mode (already set, display-only with edit option)
- Route Quality (dropdown: Scenic / Fastest / Offbeat)
- Road Condition (radio: Excellent / Good / Poor / Offroad)

**Section 2: Ratings**
- Scenic Rating (1-5 stars, optional)
- Safety Rating (1-5 stars, required, default 3)
- Solo Safe (checkbox)

**Section 3: Costs (Optional)**
- Fuel Cost (number input, USD)
- Toll Cost (number input, USD)

**Section 4: Highlights**
- Tag input: Add highlights like "waterfall", "viewpoint", "local villages"
- Shows as chips, removable

**Section 5: Visibility**
- Public toggle (default: false)
- Explanation: "Allow others to discover this route"

**Buttons:**
- Save Metadata (primary)
- Cancel (secondary)

**Validation:**
- Safety rating required (1-5)
- All other fields optional
- Highlight tags max 50 chars each

---

### **6. Sub-Components**

**TerrainTagSelector.tsx:**
- Multi-select chip input
- Pre-defined suggestions: "scenic", "mountainous", "bumpy", "smooth", "winding"
- Allow custom input
- Max 10 tags
- Visual: Ocean teal chips with X to remove

**SafetyRatingInput.tsx:**
- 5 star icons (clickable)
- Hover preview
- Selected state (filled stars)
- Label: "How safe is this route?"

**HighlightsInput.tsx:**
- Text input with "Add" button
- Enter key also adds tag
- Shows tags as removable chips below input
- Suggestions dropdown (optional): "waterfall", "viewpoint", "temple", "cafe"

**RouteMetadataBadge.tsx:**
- Small badge overlaying route on map
- Shows 1-2 key tags (e.g., "🏔️ Scenic" or "⚠️ Bumpy")
- Click badge → open metadata panel
- Position: Near route midpoint

---

### **7. State Management**

**src/store/editorStore.ts (UPDATE):**

**Add:**
```typescript
interface EditorState {
  selectedRoute: Route | null;
  routeMetadata: Record<string, RouteMetadata>;  // Keyed by route_id
  
  setSelectedRoute: (route: Route | null) => void;
  setRouteMetadata: (routeId: string, metadata: RouteMetadata) => void;
}
```

**Behavior:**
- When route clicked → `setSelectedRoute(route)` → Bottom panel opens
- When metadata saved → `setRouteMetadata(route.id, metadata)` → Badge updates

---

### **8. Map Integration**

**src/components/Editor/CenterMap.tsx (UPDATE):**

**Changes:**
- Click route line → set `selectedRoute` in store
- Render `RouteMetadataBadge` for each route with metadata
- Badge positioned at route midpoint (calculate from GeoJSON coords)
- Route with metadata has different styling (e.g., thicker line, dashed if offroad)

**Visual Styling Based on Metadata:**
```typescript
// Example logic (not full code)
if (metadata.road_condition === 'offroad') {
  lineStyle = 'dashed';
  lineColor = '#D4A373';  // Sandy beige
}

if (metadata.route_quality === 'scenic') {
  lineWidth = 5;
  lineColor = '#059669';  // Forest green
}
```

---

## **🎨 UI/UX Specifications**

### **Bottom Panel:**
- Slide animation: 300ms ease-out
- Height: 40% of viewport when open
- Backdrop blur on map when open (optional)
- Tabs styled with Ocean/Forest colors

### **Form Layout:**
- 2-column grid on desktop
- Single column on mobile (future)
- Grouped sections with subtle borders
- Icons next to labels (star for ratings, shield for safety)

### **Tags/Chips:**
- Ocean teal background (#0891B2)
- White text
- Rounded corners
- X icon to remove
- Max 3 chips per row, wrap to next line

### **Star Rating:**
- Gold/yellow stars (#FFD700)
- Gray outline when not selected
- Smooth fill animation on click

---

## **✅ Success Criteria**

### **User Flow:**
- [ ] Click route on map → bottom panel slides up
- [ ] See Details tab (distance, duration, waypoints)
- [ ] Switch to Metadata tab
- [ ] Fill form fields (quality, condition, ratings, tags)
- [ ] Click "Save Metadata"
- [ ] Toast: "Metadata saved"
- [ ] Badge appears on route on map
- [ ] Refresh page → metadata persists

### **Technical:**
- [ ] POST /routes/{id}/metadata returns 201
- [ ] GET /routes/{id}/metadata retrieves data
- [ ] PATCH updates existing metadata
- [ ] Form validation works (safety rating required)
- [ ] Cache invalidation after save

### **Visual:**
- [ ] Panel slides smoothly
- [ ] Form styled with Ocean/Forest theme
- [ ] Stars interactive and clear
- [ ] Tags display as chips
- [ ] Badge visible on map

---

## **🧪 Test Cases**

**Manual Testing:**
```
1. Draw route (C1)
2. Click route → panel opens
3. Fill metadata:
   - Quality: Scenic
   - Condition: Good
   - Safety: 4 stars
   - Highlights: waterfall, cafe
4. Save → toast appears
5. See badge on map: "🏔️ Scenic"
6. Refresh → metadata persists
7. Edit metadata → update safety to 5 stars
8. Delete route → metadata also deleted (cascade)
```

---

## **⚠️ Common Pitfalls**

### **1. Backend Field Names**
- Frontend types MUST match Phase A2 backend schema exactly
- Use snake_case (e.g., `route_quality` not `routeQuality`)

### **2. Required vs Optional**
- Only `safety_rating` is required (backend default: 3)
- All other fields optional
- Form should handle partial saves

### **3. Highlights Array**
- Backend expects `TEXT[]` (PostgreSQL array)
- Send as JSON array: `["waterfall", "viewpoint"]`
- Not comma-separated string

### **4. Public Toggle**
- Default `is_public: false`
- Only set true if user explicitly toggles
- Show warning: "Public routes can be discovered by others"

---

## **📦 Deliverables**

1. 1 service file (routeMetadataService.ts)
2. 1 hooks file (useRouteMetadata.ts)
3. 1 main form component (RouteMetadataForm.tsx)
4. 3 sub-components (TerrainTagSelector, SafetyRatingInput, HighlightsInput)
5. 1 badge component (RouteMetadataBadge.tsx)
6. Updated BottomPanel (tabs + metadata tab)
7. Updated CenterMap (route click handler, badge rendering)
8. Updated types (routeMetadata.ts)

**LOC Estimate:** ~500 LOC

---

## **🔗 Integration Notes**

### **Phase A2 Backend Endpoints:**
All endpoints already implemented in Phase A2:
- `POST /api/v1/routes/{route_id}/metadata`
- `GET /api/v1/routes/{route_id}/metadata`  
- `PATCH /api/v1/routes/{route_id}/metadata`
- `DELETE /api/v1/routes/{route_id}/metadata`

**No backend work needed for C3.**

### **Phase C1/C2 Dependencies:**
- Route drawing must work (C1)
- Route selection on map (C1)
- Bottom panel exists (Phase B3)
- Store has `selectedRoute` state

### **Future Phases:**
- **Phase E:** Metadata used for trip-level tagging
- **Phase F:** Route metadata powers discovery search

---

## **📋 Acceptance Checklist**

**Before marking C3 complete:**
- [ ] All form fields map to backend schema
- [ ] Metadata saves successfully
- [ ] Metadata retrieves on route selection
- [ ] Metadata updates work (PATCH)
- [ ] Badge renders on map with metadata
- [ ] Form validation prevents invalid saves
- [ ] Bottom panel slides smoothly
- [ ] No breaking changes to C1/C2 functionality

---

**END OF PHASE C3 PRD**

---

## **🎯 Phase C Complete**

**With C1, C2, C3 done, you have:**
- ✅ Full route creation (draw, save, display)
- ✅ Waypoint management (add, edit, drag, delete)
- ✅ Route metadata tagging (semantic search foundation)
- ✅ Route discovery infrastructure ready

**Next:** Phase D (Timeline & Synchronization)

---

**Ready for AI Agent? START C3.**