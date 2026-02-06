# **PHASE D: Timeline & Synchronization - Complete PRD**

---

## **📋 Phase Overview**

**Phase ID:** D  
**Duration:** 1.5 weeks  
**Dependencies:** Phase A3 (Components API), Phase B (Editor Shell), Phase C (Routes)  
**Goal:** Build interactive timeline that syncs with map

**Combines:** D1 (Timeline Component), D2 (Map-Timeline Sync), D3 (Drag & Drop Reordering)

---

## **🎯 Objectives**

**Primary Goal:**  
Create left sidebar timeline showing all trip components (places + routes) in chronological order with bi-directional sync to map.

**What Success Looks Like:**
- Left sidebar shows unified timeline (places + routes ordered)
- Click timeline item → map flies to that location
- Click map marker/route → timeline item highlights
- Drag timeline items → reorder components
- Add/delete components → timeline auto-updates
- Visual indicators (icons, colors, order numbers)

---

## **🏗️ Architecture Overview**

### **Data Flow:**

```
Backend: GET /api/v1/trips/{trip_id}/components
    ↓
Returns unified list: [{type: 'place', ...}, {type: 'route', ...}]
    ↓
Frontend: Store in editorStore.timeline
    ↓
Timeline component renders list
    ↓
User interactions:
  - Click item → map.flyTo(location)
  - Drag item → PATCH /components/reorder
  - Delete item → DELETE endpoint → refetch timeline
    ↓
Map interactions:
  - Click marker/route → highlightTimelineItem(id)
  - Map viewport changes → no timeline change
```

### **Synchronization:**

```
Timeline → Map (One-way):
- Click place item → map.flyTo([place.lng, place.lat])
- Click route item → map.fitBounds(route.geojson)
- Hover item → highlight on map

Map → Timeline (One-way):
- Click marker → scroll timeline to item + highlight
- Click route → scroll timeline to item + highlight
- Selection persists until next click
```

---

## **📁 File Structure**

```
frontend/src/
├── components/Editor/
│   ├── LeftTimeline.tsx              (UPDATE from Phase B skeleton)
│   ├── TimelineItem.tsx              (NEW - Single item component)
│   ├── TimelinePlaceItem.tsx         (NEW - Place-specific rendering)
│   ├── TimelineRouteItem.tsx         (NEW - Route-specific rendering)
│   ├── TimelineHeader.tsx            (NEW - Add component buttons)
│   ├── CenterMap.tsx                 (UPDATE - Sync handlers)
│   └── BottomPanel.tsx               (UPDATE - Show item details)
├── hooks/
│   ├── useTimeline.ts                (NEW - Timeline state/logic)
│   ├── useTimelineSync.ts            (NEW - Map ↔ Timeline sync)
│   └── useReorderComponents.ts       (NEW - Drag & drop mutation)
├── store/
│   └── editorStore.ts                (UPDATE - Timeline state)
└── utils/
    └── timelineHelpers.ts            (NEW - Sorting, formatting)
```

---

## **🔧 D1: Dynamic Timeline Component**

### **Goal:** Render scrollable timeline with all components

### **Backend Integration:**

**Endpoint:** `GET /api/v1/trips/{trip_id}/components` (Phase A3)

**Response:**
```json
{
  "components": [
    {
      "id": "uuid-1",
      "component_type": "place",
      "name": "Eiffel Tower",
      "order_in_trip": 0,
      "created_at": "2025-02-01T10:00:00Z"
    },
    {
      "id": "uuid-2",
      "component_type": "route",
      "name": "Drive to Louvre",
      "order_in_trip": 1,
      "created_at": "2025-02-01T10:30:00Z"
    }
  ],
  "total": 2,
  "trip_id": "trip-uuid"
}
```

### **Timeline Layout:**

**Left Sidebar Structure:**
```
┌─────────────────────────┐
│  Timeline               │
│  [+ Place] [+ Route]    │ ← Header with add buttons
├─────────────────────────┤
│                         │
│  ①  📍 Eiffel Tower     │ ← Place item
│      10:00 AM           │
│      [3 photos]         │
│                         │
│  │                      │ ← Connector line
│  ↓                      │
│                         │
│  ②  🚗 Drive to Louvre  │ ← Route item
│      15.3 km · 25 mins  │
│      2 waypoints        │
│                         │
│  │                      │
│  ↓                      │
│                         │
│  ③  📍 Louvre Museum    │ ← Place item
│      2:00 PM            │
│      [5 photos]         │
│                         │
└─────────────────────────┘
```

### **Component Hierarchy:**

**LeftTimeline.tsx:**
- Container with header
- Scrollable list
- Empty state ("Add your first place")
- Loading skeleton

**TimelineItem.tsx:**
- Wrapper for both place/route
- Renders appropriate sub-component based on `component_type`
- Handles click → trigger sync
- Drag handle (for Phase D3)
- Connector line to next item

**TimelinePlaceItem.tsx:**
- Place icon (based on `place_type`)
- Place name
- Timestamp (if `visit_date` exists)
- Photo count badge
- Edit/delete menu (three dots)

**TimelineRouteItem.tsx:**
- Transport icon (car/bike/foot/air)
- Route name or "Route"
- Distance + duration
- Waypoint count
- Terrain tags (if metadata exists)
- Edit/delete menu

### **Visual Design:**

**Item States:**
- Default: White background
- Hover: Light gray background
- Selected: Ocean teal border + light teal background
- Active (map synced): Bold text, highlighted

**Icons:**
- Places: 📍 (monument), 🏨 (hotel), 🍽️ (restaurant), etc.
- Routes: 🚗 (car), 🚴 (bike), 🚶 (foot), ✈️ (air)
- Order numbers: Circled 1, 2, 3... (Ocean teal)

**Connector Line:**
- Vertical line connecting items
- Dotted for routes, solid for places
- Ocean teal color

---

## **🔧 D2: Map-Timeline Synchronization**

### **Goal:** Bi-directional interaction between map and timeline

### **Timeline → Map Sync:**

**Click Timeline Item:**
1. Determine item type (place or route)
2. If place:
   - `map.flyTo([place.lng, place.lat], { zoom: 15, duration: 1000 })`
   - Highlight marker (pulse animation)
3. If route:
   - `map.fitBounds(routeBounds, { padding: 50, duration: 1000 })`
   - Highlight route line (increase width temporarily)
4. Update `editorStore.selectedItem = { type, id }`
5. Open bottom panel with item details

**Hover Timeline Item:**
- Temporarily highlight corresponding map element
- No viewport change
- Subtle glow effect on marker/route

### **Map → Timeline Sync:**

**Click Map Marker:**
1. Get place ID from marker data
2. Find timeline item by ID
3. Scroll timeline to item (smooth scroll)
4. Highlight timeline item (background change)
5. Update `editorStore.selectedItem`
6. Open bottom panel

**Click Map Route:**
1. Get route ID from layer data
2. Find timeline item by ID
3. Scroll timeline to item
4. Highlight timeline item
5. Update `editorStore.selectedItem`
6. Open bottom panel

### **Scroll Behavior:**

**Timeline Scroll to Item:**
```typescript
// Pseudo-code
const scrollToTimelineItem = (itemId: string) => {
  const element = document.getElementById(`timeline-item-${itemId}`);
  element?.scrollIntoView({ 
    behavior: 'smooth', 
    block: 'center' 
  });
}
```

**Map Fly Animation:**
- Duration: 1000ms
- Easing: ease-in-out
- Zoom level: 15 for places, auto-fit for routes

### **State Management:**

**editorStore updates:**
```typescript
interface EditorState {
  selectedItem: { type: 'place' | 'route', id: string } | null;
  highlightedItem: { type: 'place' | 'route', id: string } | null;
  
  selectItem: (type, id) => void;      // Click
  highlightItem: (type, id) => void;   // Hover
  clearHighlight: () => void;
}
```

### **Sync Hook:**

**useTimelineSync.ts:**
- Listens to `selectedItem` changes
- Triggers map viewport changes
- Triggers timeline scroll
- Handles highlight states
- Cleanup on unmount

---

## **🔧 D3: Drag & Drop Reordering**

### **Goal:** Reorder timeline items via drag and drop

### **Backend Integration:**

**Endpoint:** `PATCH /api/v1/trips/{trip_id}/components/reorder` (Phase A3)

**Request:**
```json
{
  "items": [
    {"id": "place-1", "component_type": "place", "new_order": 2},
    {"id": "route-1", "component_type": "route", "new_order": 0},
    {"id": "place-2", "component_type": "place", "new_order": 1}
  ]
}
```

**Response:**
```json
{
  "message": "Components reordered successfully",
  "updated_count": 3
}
```

**Backend Behavior (Phase A3):**
- Normalizes order to 0, 1, 2, 3... (no gaps)
- Updates both `trip_places.order_in_trip` and `routes.order_in_trip`
- Single transaction (all-or-nothing)

### **Drag & Drop Library:**

**Use:** `@dnd-kit/core` + `@dnd-kit/sortable`

**Why:** 
- Accessible (keyboard support)
- Touch-friendly (mobile future)
- Customizable animations
- React 18 compatible

**Installation:**
```bash
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

### **Implementation Pattern:**

**LeftTimeline.tsx:**
- Wrap timeline items in `<SortableContext>`
- Provide `items` array (timeline components)
- Handle `onDragEnd` event
- Optimistic update + backend call

**TimelineItem.tsx:**
- Use `useSortable` hook
- Render drag handle (⋮⋮ icon)
- Apply transform styles during drag
- Show placeholder when dragging

### **Drag Behavior:**

**Visual Feedback:**
- Item being dragged: Semi-transparent, elevated shadow
- Drop target: Blue indicator line between items
- Other items: Smooth reorder animation (200ms)
- Drag handle: Visible on hover, always grabbable

**Drag Handle:**
- Position: Left edge of item
- Icon: Six dots (⋮⋮)
- Color: Gray (default), Ocean teal (hover/drag)
- Cursor: grab (idle), grabbing (dragging)

### **Reorder Logic:**

**On Drag End:**
1. Calculate new order based on drop position
2. Optimistically update local state (instant UI feedback)
3. Build reorder request payload
4. Call `PATCH /components/reorder`
5. On success: Invalidate timeline query (refetch)
6. On error: Revert optimistic update + show toast

**Optimistic Update:**
```typescript
// Pseudo-code
const handleDragEnd = (event) => {
  const { active, over } = event;
  
  // Calculate new order
  const newOrder = calculateNewOrder(active.id, over.id, timeline);
  
  // Optimistic update
  setTimeline(newOrder);
  
  // Backend call
  reorderMutation.mutate(newOrder);
};
```

### **Edge Cases:**

**Drag Between Types:**
- Can drag place above/below route
- Can drag route above/below place
- Order is unified (no separate place/route ordering)

**First/Last Position:**
- Drop above first item → `order: 0`
- Drop below last item → `order: lastIndex + 1`
- Backend normalizes to sequential

**Cancel Drag:**
- Press ESC → revert to original order
- Drag outside timeline → revert
- No backend call on cancel

---

## **✅ Success Criteria**

### **D1: Timeline Component**
- [ ] Timeline renders all components (places + routes)
- [ ] Items show correct icons, names, metadata
- [ ] Order numbers display correctly (1, 2, 3...)
- [ ] Empty state shows when no components
- [ ] Loading skeleton while fetching
- [ ] Scroll works smoothly

### **D2: Synchronization**
- [ ] Click timeline item → map flies to location
- [ ] Click map marker → timeline scrolls + highlights
- [ ] Hover timeline item → map element highlights
- [ ] Selection state persists
- [ ] Bottom panel opens with correct details
- [ ] Animations smooth (no jank)

### **D3: Reordering**
- [ ] Drag handle visible on hover
- [ ] Can drag items up/down
- [ ] Visual feedback during drag (placeholder, shadow)
- [ ] Drop updates order instantly (optimistic)
- [ ] Backend call succeeds
- [ ] Refresh page → order persists
- [ ] ESC cancels drag
- [ ] Error handling (revert on failure)

---

## **🧪 Test Cases**

**Manual Testing:**
```
D1: Timeline Display
1. Open trip with 3 places + 2 routes
2. Verify timeline shows 5 items
3. Verify order numbers: 1,2,3,4,5
4. Verify icons correct (place vs route)
5. Verify connector lines between items

D2: Timeline → Map Sync
1. Click place item in timeline
2. Map flies to place location
3. Marker pulses/highlights
4. Bottom panel opens
5. Click route item
6. Map fits route bounds
7. Route line highlights

D2: Map → Timeline Sync
1. Click marker on map
2. Timeline scrolls to place item
3. Item highlights with teal border
4. Bottom panel opens
5. Click route on map
6. Timeline scrolls to route item

D3: Drag & Drop
1. Hover timeline item → drag handle appears
2. Drag item #3 to position #1
3. Items reorder smoothly
4. Release → backend call
5. Toast: "Order updated"
6. Refresh page
7. Order persists
8. Drag item → press ESC → reverts
```

---

## **⚠️ Common Pitfalls**

### **1. Component Type Confusion**
- Backend returns `component_type: 'place' | 'route'`
- Don't confuse with `place_type` (restaurant, hotel, etc.)
- Route items may not have `name` → fallback to "Route"

### **2. Map Viewport Race Conditions**
- Timeline click triggers map.flyTo()
- Map click triggers timeline scroll
- Can create infinite loop if not careful
- Use debounce or flag to prevent

### **3. Order Normalization**
- User drags item #5 to position #0
- Backend normalizes to sequential: 0,1,2,3,4
- Frontend must refetch to get normalized order
- Don't assume user's order is final

### **4. Drag Handle Mobile**
- Touch events different from mouse
- @dnd-kit handles this, but test on touch devices
- Drag handle needs sufficient hit area (min 44x44px)

### **5. Timeline Scroll Position**
- Scroll timeline programmatically can conflict with user scroll
- Only auto-scroll when map item clicked (not on hover)
- Use `scrollIntoView({ block: 'center' })` for best UX

---

## **📦 Deliverables**

**D1: Timeline Component**
1. 1 container component (LeftTimeline.tsx - updated)
2. 3 item components (TimelineItem, TimelinePlaceItem, TimelineRouteItem)
3. 1 header component (TimelineHeader.tsx)
4. 1 utils file (timelineHelpers.ts)

**D2: Synchronization**
1. 1 sync hook (useTimelineSync.ts)
2. Updated CenterMap (click handlers)
3. Updated BottomPanel (detail display)
4. Updated editorStore (selected/highlighted state)

**D3: Reordering**
1. 1 reorder hook (useReorderComponents.ts)
2. Updated LeftTimeline (drag & drop setup)
3. Updated TimelineItem (sortable item)

**Total LOC Estimate:** ~800 LOC

---

## **🔗 Integration Notes**

### **Phase Dependencies:**
- **Phase A3:** Components API must be complete
- **Phase B:** Editor shell + store must exist
- **Phase C:** Routes/places rendering on map must work

### **No Backend Changes:**
- All endpoints from Phase A3 (already built)
- `GET /trips/{id}/components` - fetch timeline
- `PATCH /trips/{id}/components/reorder` - reorder items

### **Future Phases:**
- **Phase E:** Timeline shows metadata badges (tags, ratings)
- **Phase F:** Timeline filtering (show only places, only routes)

---

## **📋 Acceptance Checklist**

**Before marking Phase D complete:**
- [ ] Timeline fetches from `/components` endpoint
- [ ] All component types render correctly
- [ ] Click timeline → map syncs (with animation)
- [ ] Click map → timeline syncs (with scroll)
- [ ] Drag & drop reorders items
- [ ] Reorder persists to backend
- [ ] Reorder persists on refresh
- [ ] No infinite sync loops
- [ ] No breaking changes to Phases B/C
- [ ] Loading/error states handled

---

**END OF PHASE D PRD**

---

## **🎯 Phases A-D Complete**

**With A, B, C, D done, you have:**
- ✅ Backend: Metadata, Routes, Components API
- ✅ Frontend: Editor shell, Map, Route drawing, Timeline
- ✅ Core V2 functionality working
- ✅ 70% of immersive editor complete

**Next:** Phase E (Semantic Tagging) - Trip/component metadata UI

---

**Ready for AI Agent? START PHASE D.**