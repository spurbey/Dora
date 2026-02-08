# **FLUTTER PHASE 4 PRD: TRIP CREATION & EDITOR**

## **Complete Implementation Guide**

---

## **📋 Phase Overview**

**Phase ID:** Flutter Phase 4  
**Duration:** 4 weeks  
**Dependencies:** Phase 1 (Foundation), Phase 2 (Feed), Phase 3 (My Trips)  
**Goal:** Build complete trip creation and editing workspace

---

## **🎯 Objectives**

**Primary Goal:**  
Users can create trips, add places, draw routes, and manage timeline in a powerful editor workspace.

**What Success Looks Like:**
- User fills Pre-Create form and enters editor
- Editor shows map + timeline split view
- User can search and add places to timeline
- Places appear as markers on map
- User can draw routes between places
- Timeline is drag-reorderable
- Auto-save works (every 30s)
- User can navigate back with changes saved
- Works offline with sync queue

**Phase 1-3 Foundation Used:**
- ✅ Theme system
- ✅ Navigation
- ✅ Map abstraction (AppMapController)
- ✅ Offline-first (Drift + Repository)
- ✅ Riverpod state management
- ✅ My Trips integration

---

## **🏗️ Architecture Alignment**

### **Critical References:**

**Architecture Document:**
- **Section: Map Abstraction Layer** ⚠️ **MANDATORY**
  - Never import `mapbox_gl` directly in UI
  - Always use `AppMapController` interface
  - Use `AppLatLng`, `AppMarker`, `AppRoute` models
- Folder Structure (features/create/)
- Offline-First Architecture (optimistic updates)
- State Management (complex multi-view state)

**Screen Specifications:**
- Screen 4: Pre-Create (Trip Form)
- Screen 5: Editor Workspace (Map + Timeline)
- Screen 8: Place Search (Full Screen)

**Design System:**
- Section 10: Map UI Rules (overlays, controls)
- Section 11: Timeline & Editor Modes (browse vs edit)

---

## **📁 Deliverables Overview**

**Files to Create: ~35 files**

```
lib/
├── features/
│   └── create/
│       ├── data/
│       │   ├── trip_repository.dart (UPDATE from Phase 3)
│       │   ├── place_repository.dart (NEW)
│       │   ├── route_repository.dart (NEW)
│       │   └── models/
│       │       ├── trip.dart (UPDATE)
│       │       ├── place.dart (NEW)
│       │       ├── route.dart (NEW)
│       │       └── editor_mode.dart (NEW)
│       ├── domain/
│       │   ├── editor_state.dart
│       │   ├── timeline_state.dart
│       │   └── map_state.dart
│       └── presentation/
│           ├── screens/
│           │   ├── pre_create_screen.dart
│           │   ├── editor_screen.dart
│           │   └── place_search_screen.dart
│           ├── widgets/
│           │   ├── editor_header.dart
│           │   ├── timeline_sidebar.dart
│           │   ├── timeline_item.dart
│           │   ├── map_canvas.dart
│           │   ├── floating_tool_panel.dart
│           │   ├── bottom_detail_panel.dart
│           │   ├── place_detail_form.dart
│           │   └── route_detail_form.dart
│           └── providers/
│               ├── editor_provider.dart
│               ├── timeline_provider.dart
│               ├── map_provider.dart
│               └── place_search_provider.dart
│
├── core/
│   ├── map/ (UPDATE existing)
│   │   ├── app_map_view.dart (ensure complete)
│   │   ├── app_map_controller.dart (ensure complete)
│   │   └── adapters/
│   │       └── mapbox_adapter.dart (verify implementation)
│   │
│   └── storage/
│       ├── tables/
│       │   ├── places_table.dart (NEW)
│       │   └── routes_table.dart (NEW)
│       └── daos/
│           ├── place_dao.dart (NEW)
│           └── route_dao.dart (NEW)
│
└── shared/
    └── widgets/
        ├── date_picker_field.dart (NEW)
        ├── tag_selector.dart (NEW)
        └── draggable_list.dart (NEW)
```

---

## **🗺️ CRITICAL: Map Abstraction Compliance**

### **⚠️ Non-Negotiable Rules**

**Before writing ANY map-related code, read Architecture Doc Section: Map Abstraction Layer**

**NEVER do this:**
```dart
// ❌ FORBIDDEN - Direct Mapbox import
import 'package:mapbox_gl/mapbox_gl.dart';

class EditorScreen extends StatelessWidget {
  final MapboxMapController controller; // WRONG
}
```

**ALWAYS do this:**
```dart
// ✅ CORRECT - Abstraction layer
import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';

class EditorScreen extends StatelessWidget {
  final AppMapController controller; // CORRECT
}
```

**Why this matters:**
- Map engine may change (Mapbox → Flutter Map)
- Video export needs separate rendering
- UI must never depend on vendor SDK types

**Reference for all map work:** Architecture Doc - Map Abstraction Layer (complete patterns provided)

---

## **🔧 WEEK 1: PRE-CREATE FORM & DATA MODELS**

### **Goal:** User fills trip form and creates trip skeleton

---

### **W1.1: Trip Data Models**

**Create files:**

**1. lib/features/create/data/models/trip.dart**

**Requirements:**
- Freezed immutable model
- Extends UserTrip from Phase 3
- Add editor-specific fields: `centerPoint` (AppLatLng), `zoom` (double)
- Sync metadata for offline

**Reference:** Architecture Doc (Freezed models, Offline sync metadata)

**Key structure:**
```dart
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String userId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<String> tags,
    @Default('private') String visibility,
    
    // Editor-specific
    AppLatLng? centerPoint,
    @Default(12.0) double zoom,
    
    // Sync metadata
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Trip;
  
  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
```

**Note:** `AppLatLng` comes from `core/map/models/app_latlng.dart` (already exists from Architecture)

---

**2. lib/features/create/data/models/place.dart**

**Requirements:**
- Freezed model for trip places
- Fields: id, tripId, name, address, coordinates (AppLatLng), notes, visitTime, dayNumber, orderIndex, photoUrls
- Sync metadata

**Reference:** Architecture Doc (Freezed), Screen Spec #5 (Place data)

**Key structure:**
```dart
@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String tripId,
    required String name,
    String? address,
    required AppLatLng coordinates,
    String? notes,
    String? visitTime, // 'morning', 'afternoon', 'evening'
    int? dayNumber,
    required int orderIndex,
    @Default([]) List<String> photoUrls,
    
    // Sync metadata
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Place;
  
  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
```

---

**3. lib/features/create/data/models/route.dart**

**Requirements:**
- Freezed model for routes between places
- Fields: id, tripId, coordinates (List<AppLatLng>), transportMode, distance, duration, dayNumber
- Sync metadata

**Reference:** Architecture Doc (Freezed), Screen Spec #5 (Route data)

**Key structure:**
```dart
@freezed
class Route with _$Route {
  const factory Route({
    required String id,
    required String tripId,
    required List<AppLatLng> coordinates,
    @Default('car') String transportMode, // 'car', 'bike', 'walk', 'air'
    double? distance, // km
    int? duration, // minutes
    int? dayNumber,
    
    // Sync metadata
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Route;
  
  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
}
```

---

**4. lib/features/create/data/models/editor_mode.dart**

**Requirements:**
- Enum for editor modes
- Values: view, addPlace, drawRoute, editItem

**Pattern:**
```dart
enum EditorMode {
  view,       // Default: browse mode
  addPlace,   // Search and add places
  drawRoute,  // Draw route between places
  editItem,   // Edit selected place/route
}
```

---

### **W1.2: Drift Tables for Places & Routes**

**Create files:**

**5. lib/core/storage/tables/places_table.dart**

**Requirements:**
- Mirror Place model
- Foreign key to Trips table
- Index on tripId for fast queries
- JSON column for coordinates (convert AppLatLng to JSON)

**Reference:** Architecture Doc (Drift tables)

**Key fields:**
```dart
class Places extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get coordinates => text().map(const LatLngConverter())(); // JSON
  TextColumn get notes => text().nullable()();
  TextColumn get visitTime => text().nullable()();
  IntColumn get dayNumber => integer().nullable()();
  IntColumn get orderIndex => integer()();
  TextColumn get photoUrls => text().map(const StringListConverter())(); // JSON array
  
  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Converter for AppLatLng
class LatLngConverter extends TypeConverter<AppLatLng, String> {
  const LatLngConverter();
  
  @override
  AppLatLng fromSql(String fromDb) {
    final json = jsonDecode(fromDb);
    return AppLatLng.fromJson(json);
  }
  
  @override
  String toSql(AppLatLng value) {
    return jsonEncode(value.toJson());
  }
}
```

---

**6. lib/core/storage/tables/routes_table.dart**

**Requirements:**
- Mirror Route model
- Foreign key to Trips
- JSON column for coordinates array

**Reference:** Architecture Doc (Drift tables)

**Similar pattern to Places table, with coordinates as List<AppLatLng>**

---

**7. Create DAOs:**

**lib/core/storage/daos/place_dao.dart**
**lib/core/storage/daos/route_dao.dart**

**Requirements:**
- CRUD operations
- Query by tripId
- Order by orderIndex
- Batch insert

**Reference:** Architecture Doc (DAOs)

**Key methods:**
```dart
// PlaceDao
Future<List<Place>> getPlacesByTrip(String tripId);
Future<void> insertPlace(Place place);
Future<void> updatePlace(Place place);
Future<void> deletePlace(String id);
Future<void> reorderPlaces(String tripId, List<String> newOrder);
```

---

### **W1.3: Pre-Create Form UI**

**Create widgets:**

**8. lib/shared/widgets/date_picker_field.dart**

**Requirements:**
- Text field that opens date picker on tap
- Display formatted date
- Optional (can be null)

**Reference:** Design System (Input fields)

**Pattern:**
```dart
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onDateSelected;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(/*...*/);
        if (picked != null) onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value != null 
            ? DateFormat('MMM d, yyyy').format(value!) 
            : 'Select date'
        ),
      ),
    );
  }
}
```

---

**9. lib/shared/widgets/tag_selector.dart**

**Requirements:**
- Chip selector for tags
- Pre-defined suggestions + custom
- Multi-select
- Max 5 tags

**Reference:** Screen Spec #4 (Tag selector)

**Pattern:**
```dart
class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onTagsChanged;
  final int maxTags;
}

// UI: Wrap of chips
// Selected: accent background
// Tap to toggle
// Show "+ Custom" button for user input
```

---

**10. lib/features/create/presentation/screens/pre_create_screen.dart**

**Requirements:**
- Match Screen Spec #4 layout exactly
- Form validation (name required)
- Date range validation (end > start)
- Blurred background preview
- Centered form card

**Reference:** Screen Spec #4 (Complete layout), Design System (Forms, Cards)

**Layout components:**
- Header: × Close button
- Background: Blurred editor preview (static image)
- Form card (327px width, centered):
  - Title: "Start Your Journey"
  - Trip Name input (required)
  - Description textarea (optional)
  - Start/End date pickers (optional)
  - Tag selector (optional)
  - Create button (disabled until name filled)

**Interactions:**
- Tap × → Confirm discard if form dirty
- Tap Create → Validate → Create trip → Navigate to Editor
- Auto-capitalize trip name

**State:**
- Form validation state
- Loading state during creation

**Dora microcopy:**
- Form title: "Start Your Journey"
- Name placeholder: "e.g., Summer in Japan"
- Description placeholder: "Tell your story..."
- Success toast: "Let's build your journey!"

---

### **Week 1 Checkpoint:**

**Deliverable:**
- Pre-Create form functional
- User fills form and creates trip
- Trip saved to Drift DB
- Navigate to Editor (placeholder OK)
- Form validation works
- Discard confirmation works

**Test:**
```
□ Tap FAB on My Trips
□ Pre-Create screen appears
□ Fill trip name "Iceland Adventure"
□ Select dates, tags
□ Tap Create
□ Trip created
□ Navigates to editor (can be blank screen for now)
□ Back to My Trips
□ See "Iceland Adventure" in list
```

---

## **🔧 WEEK 2: EDITOR WORKSPACE LAYOUT**

### **Goal:** Build editor split-view layout (map + timeline)

---

### **W2.1: Editor State Management**

**Create files:**

**11. lib/features/create/domain/editor_state.dart**

**Requirements:**
- Complex state for editor
- Current trip, places, routes
- Selected item, editor mode
- Saving state

**Reference:** Architecture Doc (State Management - complex state)

**State structure:**
```dart
@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    required Trip trip,
    @Default([]) List<Place> places,
    @Default([]) List<Route> routes,
    
    // Selection
    String? selectedItemId,
    String? selectedItemType, // 'place' | 'route'
    
    // Modes
    @Default(EditorMode.view) EditorMode mode,
    
    // UI state
    @Default(false) bool saving,
    @Default(false) bool bottomPanelExpanded,
    
    // Map state
    AppMapController? mapController,
  }) = _EditorState;
}
```

---

**12. lib/features/create/presentation/providers/editor_provider.dart**

**Requirements:**
- Riverpod AsyncNotifier
- Load trip with places/routes
- Add/remove/update items
- Reorder timeline
- Auto-save (debounced)
- Map integration

**Reference:** Architecture Doc (Riverpod 2.x), Screen Spec #5 (Editor interactions)

**Provider structure:**
```dart
@riverpod
class EditorController extends _$EditorController {
  Timer? _autoSaveTimer;
  
  @override
  Future<EditorState> build(String tripId) async {
    final repo = ref.watch(tripRepositoryProvider);
    final trip = await repo.getTrip(tripId);
    final places = await repo.getPlaces(tripId);
    final routes = await repo.getRoutes(tripId);
    
    return EditorState(
      trip: trip,
      places: places,
      routes: routes,
    );
  }
  
  // Actions
  void selectPlace(String id) { /*...*/ }
  void addPlace(Place place) { /*...*/ }
  void removePlace(String id) { /*...*/ }
  void updatePlace(Place place) { /*...*/ }
  void reorderPlaces(int oldIndex, int newIndex) { /*...*/ }
  
  void setMode(EditorMode mode) { /*...*/ }
  void toggleBottomPanel() { /*...*/ }
  
  Future<void> save() async { /*...*/ }
  void _scheduleAutoSave() { /*...*/ } // Debounce 30s
}
```

**Auto-save pattern:**
```dart
void _scheduleAutoSave() {
  _autoSaveTimer?.cancel();
  _autoSaveTimer = Timer(const Duration(seconds: 30), () {
    save();
  });
}

// Call after every change:
void addPlace(Place place) {
  state = AsyncData(state.value!.copyWith(
    places: [...state.value!.places, place],
  ));
  _scheduleAutoSave();
}
```

---

### **W2.2: Editor Layout Components**

**Create widgets:**

**13. lib/features/create/presentation/widgets/editor_header.dart**

**Requirements:**
- Back button (with save check)
- Trip name (editable inline)
- Export button
- More menu (⋮)

**Reference:** Screen Spec #5 (Header), Design System (Headers)

**Layout:**
```
[← Back]  Trip Name  [Export] [⋮More]
```

**Interactions:**
- Tap ← → Confirm if unsaved → Navigate back
- Tap Trip Name → Inline edit mode
- Tap Export → Navigate to Export Studio (Phase 5)
- Tap ⋮ → Show menu (Settings, Preview, Delete)

---

**14. lib/features/create/presentation/widgets/timeline_sidebar.dart**

**Requirements:**
- Scrollable list of places/routes
- Day headers (sticky)
- Drag to reorder
- Selected state highlight
- [+ Add] button at bottom

**Reference:** Screen Spec #5 (Timeline sidebar), Design System (Lists)

**Layout:**
```
┌──────────────┐
│ Day 1        │ ← Sticky header
├──────────────┤
│ ① Tokyo      │ ← Place item
│    Morning   │
├──────────────┤
│ ② 25km       │ ← Route item
├──────────────┤
│ ③ Kyoto      │
└──────────────┘
```

**States:**
- Default: white background
- Selected: accentSoft background + accent border
- Dragging: elevated shadow

**Interactions:**
- Tap item → Select + fly map to location
- Long press → Show drag handle
- Drag up/down → Reorder, update orderIndex
- Tap [+ Add] → Show add menu (Place/Route)

---

**15. lib/shared/widgets/draggable_list.dart**

**Requirements:**
- Reusable draggable list widget
- Drag handles
- Reorder callback
- Works with any item type

**Reference:** Flutter `ReorderableListView`

**Usage pattern:**
```dart
DraggableList<Place>(
  items: places,
  itemBuilder: (place) => TimelineItem(place: place),
  onReorder: (oldIndex, newIndex) => reorderPlaces(oldIndex, newIndex),
)
```

---

**16. lib/features/create/presentation/widgets/timeline_item.dart**

**Requirements:**
- Display place or route
- Icon, name, meta
- Selected state
- Drag handle (on long press)

**Reference:** Screen Spec #5 (Timeline items)

**Two variants:**
- PlaceTimelineItem: 📍 icon, name, time of day
- RouteTimelineItem: Transport icon, distance, duration

---

**17. lib/features/create/presentation/widgets/map_canvas.dart**

**Requirements:**
- ⚠️ **CRITICAL:** Use AppMapView (abstraction)
- Display places as markers
- Display routes as polylines
- Tap marker → Select place
- Zoom, pan controls

**Reference:** Architecture Doc (Map Abstraction Layer - complete example), Screen Spec #5 (Map)

**MUST use abstraction:**
```dart
class MapCanvas extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorControllerProvider(tripId));
    
    return editorState.when(
      data: (state) => AppMapView(  // ← Abstraction widget
        initialCenter: state.trip.centerPoint ?? AppLatLng(lat: 0, lng: 0),
        initialZoom: state.trip.zoom,
        markers: _buildMarkers(state.places),
        routes: _buildRoutes(state.routes),
        onMapCreated: (controller) {
          // Store controller in state
          ref.read(editorControllerProvider(tripId).notifier)
            .setMapController(controller);
        },
      ),
      loading: () => LoadingIndicator(),
      error: (e, st) => ErrorView(),
    );
  }
  
  List<AppMarker> _buildMarkers(List<Place> places) {
    return places.asMap().entries.map((entry) {
      final index = entry.key;
      final place = entry.value;
      return AppMarker(
        id: place.id,
        position: place.coordinates, // Already AppLatLng
        title: place.name,
        // Label with order number
      );
    }).toList();
  }
  
  List<AppRoute> _buildRoutes(List<Route> routes) {
    return routes.map((route) => AppRoute(
      id: route.id,
      coordinates: route.coordinates, // Already List<AppLatLng>
      color: _getColorForMode(route.transportMode),
      width: 4.0,
    )).toList();
  }
}
```

**Reference:** See Architecture Doc Map Abstraction section for complete `AppMapView` usage

---

**18. lib/features/create/presentation/widgets/floating_tool_panel.dart**

**Requirements:**
- Floating on top-right of map
- Tool buttons: ➕ Add, ✏️ Edit, 📍 Places, 🗺️ Routes, 📸 Media
- Highlight current mode
- Blur background

**Reference:** Screen Spec #5 (Tool panel), Design System (Floating panels)

**Layout:**
```
┌──────────┐
│ ➕ Add   │
│ ✏️ Edit  │
│ 📍 Places│
│ 🗺️ Routes│
│ 📸 Media │
└──────────┘
```

**Design:**
- Background: card with blur
- Border radius: lg
- Shadow: elevated
- Active tool: accent background

---

**19. lib/features/create/presentation/widgets/bottom_detail_panel.dart**

**Requirements:**
- Collapsed by default (48px height)
- Expands to show place/route details
- Drag handle
- Context-sensitive content

**Reference:** Screen Spec #5 (Bottom panel)

**States:**
- Collapsed: "Tap to view details"
- Expanded (Place): Place detail form
- Expanded (Route): Route detail form

**Use:** DraggableScrollableSheet for expand/collapse

---

### **W2.3: Editor Screen Assembly**

**Create files:**

**20. lib/features/create/presentation/screens/editor_screen.dart**

**Requirements:**
- Match Screen Spec #5 layout exactly
- Split view: Timeline (left/bottom) + Map (right/main)
- Responsive: Side-by-side on tablet, bottom sheet on mobile
- Floating tool panel
- Bottom detail panel
- Auto-save indicator

**Reference:** Screen Spec #5 (Complete layout)

**Layout structure:**
```dart
Scaffold(
  body: Column(
    children: [
      EditorHeader(),
      Expanded(
        child: Row( // Or Stack for mobile
          children: [
            TimelineSidebar(width: 280), // Tablet only
            Expanded(
              child: Stack(
                children: [
                  MapCanvas(),
                  FloatingToolPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
      BottomDetailPanel(), // Collapsed by default
    ],
  ),
)
```

**Mobile adaptation:**
- Timeline as bottom sheet (swipe up)
- Map full screen
- Tool panel smaller

**Auto-save indicator:**
- Show in header when saving
- "Saving..." text + spinner
- "All changes saved" when done

---

### **Week 2 Checkpoint:**

**Deliverable:**
- Editor screen layout complete
- Timeline shows on left (tablet) or bottom (mobile)
- Map shows in center
- Tool panel floats
- Bottom panel collapses/expands
- Empty trip shows "Add your first place" state
- Map renders with abstraction (no direct Mapbox imports)

**Test:**
```
□ Create trip via Pre-Create
□ Editor opens
□ See timeline (empty)
□ See map centered
□ See tool panel
□ Tap timeline item (none yet)
□ Bottom panel collapsed
□ Drag bottom panel → Expands
□ Tablet: Timeline sidebar visible
□ Mobile: Timeline bottom sheet
□ No direct mapbox_gl imports anywhere
```

---

## **🔧 WEEK 3: PLACE SEARCH & ADDING**

### **Goal:** User can search and add places to trip

---

### **W3.1: Place Search Integration**

**Create files:**

**21. lib/features/create/presentation/screens/place_search_screen.dart**

**Requirements:**
- Match Screen Spec #8 layout
- Full-screen overlay over editor
- Search input (auto-focus)
- GPS button (use current location)
- Category filters
- Place results
- Nearby places

**Reference:** Screen Spec #8 (Complete layout)

**Layout:**
```
[← Cancel]  [GPS] [Filter]
[🔍 Search places...]

QUICK ADD
[📍 Use Current Location]

NEARBY
• Coffee Shop (200m)
• Restaurant (500m)

CATEGORIES
[🍽️ Food] [☕ Cafe] [🏨 Hotel]
```

**Data source:**
- Use FeedApi.searchPlaces() from Phase 2
- For Phase 4: Can use mock data or real Foursquare/Google API

**Interactions:**
- Type to search → Debounce 300ms → Show results
- Tap GPS → Get current location → Search nearby
- Tap category → Filter by category
- Tap place → Show detail sheet
- Tap [+ Add] on place → Add to trip → Navigate back

---

**22. Place Detail Bottom Sheet**

**Requirements:**
- Half-screen modal
- Place photo carousel
- Name, category, address
- Rating, hours, price
- Description
- [+ Add to Trip] button

**Reference:** Screen Spec #8 (Place detail sheet)

**Actions:**
- Tap [+ Add to Trip] → Create Place object → Add to editor state → Close sheet → Toast

---

### **W3.2: Adding Places to Timeline**

**Update EditorController:**

**Add method:**
```dart
Future<void> addPlace(PlaceSearchResult searchResult) async {
  final place = Place(
    id: Uuid().v4(),
    tripId: state.value!.trip.id,
    name: searchResult.name,
    address: searchResult.address,
    coordinates: AppLatLng(
      latitude: searchResult.latitude,
      longitude: searchResult.longitude,
    ),
    orderIndex: state.value!.places.length,
    dayNumber: 1, // Default to Day 1
    localUpdatedAt: DateTime.now(),
    serverUpdatedAt: DateTime.now(),
  );
  
  // Add to state
  state = AsyncData(state.value!.copyWith(
    places: [...state.value!.places, place],
  ));
  
  // Save to DB
  await ref.read(placeRepositoryProvider).savePlace(place);
  
  // Fly map to new place
  state.value!.mapController?.flyTo(place.coordinates, zoom: 15);
  
  // Auto-save
  _scheduleAutoSave();
}
```

---

### **W3.3: Place Detail Editing**

**Create files:**

**23. lib/features/create/presentation/widgets/place_detail_form.dart**

**Requirements:**
- Form for editing place
- Shown in bottom panel when place selected
- Fields: Notes (textarea), Visit Time (chips), Photos (thumbnails + add)
- Save/Delete buttons

**Reference:** Screen Spec #5 (Bottom panel expanded - Place)

**Layout:**
```
📍 Tokyo Tower
Minato, Tokyo

[Photo] [Photo] [+ Add]

Notes
[Textarea]

Visit Time
[Morning] [Afternoon] [Evening]

[Delete Place]  [Save]
```

**Interactions:**
- Edit notes → Auto-save on blur
- Tap visit time chip → Toggle selection
- Tap [+ Add] photo → Open media upload (Phase 4.5)
- Tap Delete → Confirmation → Remove from timeline

---

### **Week 3 Checkpoint:**

**Deliverable:**
- Place search works
- User can add places to trip
- Places appear in timeline
- Places appear as markers on map
- Tap place in timeline → Map flies to it
- Bottom panel shows place details
- Can edit notes, visit time
- Can delete place

**Test:**
```
□ Open editor
□ Tap 📍 Places tool
□ Search "tokyo tower"
□ See results
□ Tap result → Detail sheet
□ Tap [+ Add to Trip]
□ Place appears in timeline as ① Tokyo Tower
□ Marker appears on map
□ Tap timeline item → Map flies to marker
□ Bottom panel expands
□ Edit notes "Amazing views"
□ Select "Morning" visit time
□ Tap Save → Updates
□ Tap Delete → Confirmation → Removed
```

---

## **🔧 WEEK 4: ROUTE DRAWING & POLISH**

### **Goal:** User can draw routes, reorder timeline, finalize editor

---

### **W4.1: Route Drawing**

**Update EditorController:**

**Add route drawing methods:**

```dart
void startDrawingRoute() {
  state = AsyncData(state.value!.copyWith(
    mode: EditorMode.drawRoute,
  ));
  
  // Show instruction overlay on map
}

Future<void> drawRoute(String startPlaceId, String endPlaceId) async {
  final startPlace = state.value!.places.firstWhere((p) => p.id == startPlaceId);
  final endPlace = state.value!.places.firstWhere((p) => p.id == endPlaceId);
  
  // Call Mapbox Directions API (or mock)
  final routeData = await _getDirections(
    startPlace.coordinates, 
    endPlace.coordinates
  );
  
  final route = Route(
    id: Uuid().v4(),
    tripId: state.value!.trip.id,
    coordinates: routeData.coordinates,
    distance: routeData.distance,
    duration: routeData.duration,
    transportMode: 'car', // Default
    localUpdatedAt: DateTime.now(),
    serverUpdatedAt: DateTime.now(),
  );
  
  // Add to state
  state = AsyncData(state.value!.copyWith(
    routes: [...state.value!.routes, route],
    mode: EditorMode.view,
  ));
  
  // Save to DB
  await ref.read(routeRepositoryProvider).saveRoute(route);
  
  _scheduleAutoSave();
}
```

---

**Route Drawing UX:**

**Requirements:**
- Tap 🗺️ Routes tool → Enter draw mode
- Map shows instruction overlay: "Tap places to connect"
- Tap first place marker → Highlight
- Tap second place marker → Calculate route → Show preview
- Confirm button → Add route to timeline
- Cancel button → Exit draw mode

**Reference:** Screen Spec #5 (Draw route mode)

**Map overlay during drawing:**
```
┌─────────────────────────────┐
│ Tap places to connect       │
│ [Cancel] [Done]             │
└─────────────────────────────┘
```

**After selecting two places:**
```
┌─────────────────────────────┐
│ Route: 25.3 km · 30 min     │
│ [Change Mode] [Add Route]   │
└─────────────────────────────┘
```

---

### **W4.2: Route Detail Editing**

**Create files:**

**24. lib/features/create/presentation/widgets/route_detail_form.dart**

**Requirements:**
- Form for editing route
- Shown in bottom panel when route selected
- Fields: Transport mode (chips), Waypoints (list), Distance/Duration (read-only)
- Save/Delete buttons

**Reference:** Screen Spec #5 (Bottom panel expanded - Route)

**Layout:**
```
🚗 Route Details

Distance: 25.3 km
Duration: ~30 mins

Transport
[🚗 Car] [🚴 Bike] [🚶 Walk] [✈️ Air]

Waypoints (optional)
• Gas Station
• Viewpoint
[+ Add Waypoint]

[Delete Route]  [Save]
```

**Transport mode chips:**
- Car (default): 🚗
- Bike: 🚴
- Walk: 🚶
- Air: ✈️

**Interactions:**
- Tap transport chip → Update mode → Re-calculate route (optional)
- Tap Delete → Confirmation → Remove from timeline

---

### **W4.3: Timeline Reordering**

**Update TimelineSidebar:**

**Requirements:**
- Long-press item → Show drag handle
- Drag up/down → Reorder
- Drop → Update orderIndex for all items
- Auto-assign day numbers based on order

**Reference:** Screen Spec #5 (Timeline reorder)

**Implementation:**
- Use ReorderableListView or custom DraggableList
- On reorder: Update all orderIndex values
- Optionally re-assign dayNumber (e.g., 5 items per day)
- Save all updates to DB
- Auto-save

**Day assignment logic:**
```dart
void reorderPlaces(int oldIndex, int newIndex) {
  final items = List<Place>.from(state.value!.places);
  final place = items.removeAt(oldIndex);
  items.insert(newIndex, place);
  
  // Update orderIndex
  final updated = items.asMap().entries.map((entry) {
    return entry.value.copyWith(
      orderIndex: entry.key,
      dayNumber: (entry.key ~/ 5) + 1, // 5 items per day
    );
  }).toList();
  
  state = AsyncData(state.value!.copyWith(places: updated));
  _scheduleAutoSave();
}
```

---

### **W4.4: Auto-Save & Offline Sync**

**Requirements:**
- Auto-save every 30 seconds after any change
- Show "Saving..." indicator in header
- Show "All changes saved" when complete
- Queue sync to backend when online
- Show offline indicator when offline

**Reference:** Architecture Doc (Offline-first, Sync Manager)

**Auto-save pattern:**
```dart
Timer? _autoSaveTimer;

void _scheduleAutoSave() {
  _autoSaveTimer?.cancel();
  _autoSaveTimer = Timer(const Duration(seconds: 30), () {
    save();
  });
}

Future<void> save() async {
  state = AsyncData(state.value!.copyWith(saving: true));
  
  try {
    final repo = ref.read(tripRepositoryProvider);
    await repo.updateTrip(state.value!.trip);
    await repo.savePlaces(state.value!.places);
    await repo.saveRoutes(state.value!.routes);
    
    state = AsyncData(state.value!.copyWith(saving: false));
  } catch (e) {
    // Show error toast
    state = AsyncData(state.value!.copyWith(saving: false));
  }
}
```

**Repository implementation:**
```dart
// TripRepository
Future<void> updateTrip(Trip trip) async {
  final updated = trip.copyWith(
    localUpdatedAt: DateTime.now(),
    syncStatus: 'pending',
  );
  
  // Save locally
  await _db.tripDao.updateTrip(updated);
  
  // Queue sync
  _syncManager.queueUpdate(updated);
}
```

---

### **W4.5: Empty States & Instructions**

**Requirements:**
- Empty trip: "Your journey starts here" + [+ Add Your First Place] button
- Draw route mode: Instruction overlay on map
- No internet: "Offline Mode" banner

**Reference:** Screen Spec #5 (Empty state, Offline state)

**Empty timeline:**
```
┌─────────────────────────────┐
│        🗺️                    │
│                             │
│ Your journey starts here    │
│                             │
│ [+ Add Your First Place]    │
└─────────────────────────────┘
```

**Offline banner:**
```
┌─────────────────────────────┐
│ 📡 Offline Mode              │
│ Changes will sync when online│
└─────────────────────────────┘
```

**Position:** Top of editor, dismissible

---

### **W4.6: Exit Confirmation**

**Requirements:**
- Tap back button → Check if auto-save pending
- If unsaved changes → Show confirmation
- If all saved → Navigate back

**Reference:** Screen Spec #5 (Exit confirmation)

**Confirmation dialog:**
```
Leave editor?

All changes are saved.

[Stay] [Leave]
```

**Implementation:**
```dart
Future<bool> _onWillPop() async {
  final hasUnsaved = state.value?.saving ?? false;
  
  if (!hasUnsaved) return true;
  
  return await showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: 'Leave editor?',
      message: 'Saving in progress...',
      confirmText: 'Leave',
      onConfirm: () => Navigator.pop(context, true),
    ),
  ) ?? false;
}
```

---

### **W4.7: Map Interaction Polishing**

**Requirements:**
- Tap empty area on map → Deselect item
- Tap marker → Select place in timeline + expand bottom panel
- Tap route → Select route in timeline + expand bottom panel
- Zoom controls visible
- Compass visible
- "Locate me" button

**Reference:** Architecture Doc (Map Abstraction), Screen Spec #5 (Map interactions)

**Map controls:**
```dart
AppMapView(
  // ... existing props
  onMapTap: (position) {
    // Deselect current item
    ref.read(editorControllerProvider(tripId).notifier).deselectAll();
  },
  markers: places.map((p) => AppMarker(
    id: p.id,
    position: p.coordinates,
    onTap: () {
      ref.read(editorControllerProvider(tripId).notifier).selectPlace(p.id);
    },
  )).toList(),
  showControls: true, // Zoom, compass
  showUserLocation: true, // "Locate me" button
)
```

---

### **Week 4 Checkpoint:**

**Deliverable:**
- Route drawing works
- User can connect two places with route
- Route appears as polyline on map
- Route appears in timeline
- Timeline reordering works (drag & drop)
- Auto-save works (30s debounce)
- Saving indicator shows
- Empty states show
- Exit confirmation works
- All map interactions via abstraction

**Test:**
```
COMPLETE EDITOR FLOW:
□ Create new trip "Iceland"
□ Add place "Reykjavik"
□ Add place "Thingvellir"
□ Tap 🗺️ Routes
□ Map shows "Tap places to connect"
□ Tap Reykjavik marker
□ Tap Thingvellir marker
□ Route calculates → Preview shows
□ Tap [Add Route]
□ Route appears in timeline between places
□ Polyline appears on map
□ Drag Thingvellir above Reykjavik
□ Order updates
□ Wait 30s → "Saving..." appears
□ After save → "All changes saved"
□ Tap place in timeline → Map flies to it
□ Bottom panel expands → Edit notes
□ Tap back → "Leave editor?" → Leave
□ Return to My Trips → Trip updated
□ Re-open trip → All data persists
```

---

## **✅ Phase 4 Success Criteria**

### **Functional Requirements:**

**Pre-Create:**
- [ ] Form validates (name required)
- [ ] Date range validates (end > start)
- [ ] Tags selector works (max 5)
- [ ] Create button disabled until valid
- [ ] Creates trip and navigates to editor
- [ ] Discard confirmation works

**Editor Layout:**
- [ ] Timeline sidebar shows (tablet) or bottom sheet (mobile)
- [ ] Map canvas shows with abstraction (no direct Mapbox imports)
- [ ] Floating tool panel shows
- [ ] Bottom detail panel collapses/expands
- [ ] Header shows trip name
- [ ] Auto-save indicator works

**Place Management:**
- [ ] Can search places
- [ ] Can add places to timeline
- [ ] Places appear as markers on map
- [ ] Tap timeline item → Map flies to marker
- [ ] Can edit place notes
- [ ] Can set visit time
- [ ] Can delete place
- [ ] Timeline updates immediately

**Route Management:**
- [ ] Can enter draw route mode
- [ ] Can connect two places
- [ ] Route calculates (mock OK)
- [ ] Route appears as polyline on map
- [ ] Route appears in timeline
- [ ] Can change transport mode
- [ ] Can delete route

**Timeline:**
- [ ] Places and routes ordered correctly
- [ ] Drag to reorder works
- [ ] Day numbers auto-assigned
- [ ] Selected item highlighted

**Persistence:**
- [ ] Auto-save works (30s debounce)
- [ ] All changes saved to Drift DB
- [ ] Offline mode works
- [ ] Sync queued when online
- [ ] Exit confirmation checks for unsaved

**Code Quality:**
- [ ] **CRITICAL:** No direct `mapbox_gl` imports anywhere
- [ ] All map code uses AppMapController/AppMapView abstraction
- [ ] All coordinates use AppLatLng type
- [ ] Repository pattern followed
- [ ] Offline-first pattern followed
- [ ] All theme values from tokens
- [ ] Freezed models used everywhere

---

## **🧪 Testing Strategy**

### **Manual Testing Checklist:**

```
PRE-CREATE:
□ Open Pre-Create form
□ Leave name empty → Create disabled
□ Fill name → Create enabled
□ Select start date
□ Select end date before start → Validation error
□ Fix dates → Validation passes
□ Add 3 tags
□ Tap Create → Trip created
□ Navigate to editor

EDITOR - EMPTY STATE:
□ Editor opens
□ Timeline empty with "Add first place"
□ Map centered on default location
□ Tool panel visible
□ Bottom panel collapsed

PLACE OPERATIONS:
□ Tap 📍 Places tool
□ Search screen opens
□ Search "tokyo tower"
□ Results appear
□ Tap result → Detail sheet
□ Tap [+ Add to Trip]
□ Place appears in timeline
□ Marker appears on map
□ Repeat for 2 more places

TIMELINE INTERACTION:
□ Tap place in timeline
□ Map flies to marker
□ Bottom panel expands
□ Shows place details
□ Edit notes "Great view"
□ Select "Morning" time
□ Tap Save
□ Changes persist

ROUTE DRAWING:
□ Tap 🗺️ Routes tool
□ Map shows instructions
□ Tap first place marker
□ Marker highlights
□ Tap second place marker
□ Route preview appears
□ Tap [Add Route]
□ Polyline appears on map
□ Route appears in timeline

REORDERING:
□ Long-press place item
□ Drag handle appears
□ Drag to new position
□ Release
□ Order updates
□ Day numbers recalculate

AUTO-SAVE:
□ Make changes
□ Wait 30 seconds
□ "Saving..." appears
□ Save completes
□ "All changes saved" shows

OFFLINE MODE:
□ Enable airplane mode
□ Make changes
□ "Offline Mode" banner shows
□ Changes save locally
□ Disable airplane mode
□ Sync occurs in background

EXIT & PERSISTENCE:
□ Tap back button
□ Confirmation appears
□ Leave editor
□ Return to My Trips
□ Trip shows updated count
□ Re-open trip
□ All places/routes still there

MAP ABSTRACTION VERIFICATION:
□ Search codebase for "import.*mapbox_gl"
□ MUST return 0 results in features/
□ ONLY allowed in core/map/adapters/
□ All coordinates are AppLatLng type
□ All markers are AppMarker type
```

---

## **⚠️ Common Pitfalls**

### **1. Breaking Map Abstraction**

**Problem:** Importing mapbox_gl directly

**Solution:**
```dart
// ❌ FORBIDDEN
import 'package:mapbox_gl/mapbox_gl.dart';

// ✅ CORRECT
import 'package:dora/core/map/app_map_view.dart';
import 'package:dora/core/map/models/app_latlng.dart';
```

**Verify:** Run `grep -r "import.*mapbox_gl" lib/features/` → Should be empty

---

### **2. Not Using Auto-Save**

**Problem:** Forgetting to call `_scheduleAutoSave()` after changes

**Solution:** Every state mutation must call it:
```dart
void addPlace(Place place) {
  // ... update state
  _scheduleAutoSave(); // ← REQUIRED
}
```

---

### **3. Timeline Order Conflicts**

**Problem:** orderIndex values duplicate after reordering

**Solution:** Always reassign ALL orderIndex values:
```dart
final updated = items.asMap().entries.map((e) => 
  e.value.copyWith(orderIndex: e.key)
).toList();
```

---

### **4. Map Not Centering on Place**

**Problem:** Map doesn't fly to place when selected

**Solution:** Call mapController.flyTo() in selectPlace():
```dart
void selectPlace(String id) {
  final place = state.value!.places.firstWhere((p) => p.id == id);
  state.value!.mapController?.flyTo(place.coordinates, zoom: 15);
  // ... rest
}
```

---

### **5. Sync Metadata Missing**

**Problem:** Models created without sync fields

**Solution:** Always include localUpdatedAt, serverUpdatedAt, syncStatus:
```dart
Place(
  // ... fields
  localUpdatedAt: DateTime.now(),
  serverUpdatedAt: DateTime.now(),
  syncStatus: 'pending',
)
```

---

## **📋 Handoff to Phase 5**

**What Phase 5 will build on:**
- ✅ Complete trip editor (extend with media)
- ✅ Place/route management (add bulk operations)
- ✅ Timeline (add day planning)
- ✅ Map integration (add offline tiles)

**What Phase 5 will build:**
- Media upload (camera + gallery)
- Photo compression and thumbnails
- Media management in places
- Background upload queue
- Media gallery view

---

## **🎯 Phase 4 Completion Definition**

**Phase 4 is complete when:**

1. ✅ All ~35 files created
2. ✅ Pre-Create form works
3. ✅ Editor layout complete (map + timeline)
4. ✅ **Map abstraction verified (zero direct Mapbox imports in features/)**
5. ✅ Place search and add works
6. ✅ Route drawing works
7. ✅ Timeline reordering works
8. ✅ Auto-save works (30s debounce)
9. ✅ Offline mode works
10. ✅ All data persists in Drift DB
11. ✅ Exit confirmation works
12. ✅ Passes complete manual test checklist

---

**END OF PHASE 4 PRD**

---

**Next:** Phase 5 PRD (Media Upload & Management - 2 weeks)

**Critical Instruction for AI Agent:**

```
Phase 4 Map Abstraction Compliance:

BEFORE WRITING ANY MAP CODE:
1. Read Architecture Doc - Map Abstraction Layer section
2. Understand AppMapController interface
3. Understand AppLatLng, AppMarker, AppRoute models
4. See complete AppMapView usage example

RULES:
1. NEVER import mapbox_gl in features/ folder
2. ALWAYS use AppMapView widget
3. ALWAYS use AppLatLng for coordinates
4. ALWAYS use AppMarker for markers
5. ALWAYS use AppRoute for routes
6. Store AppMapController in state
7. Call controller methods, not Mapbox methods

VERIFY:
After implementation, run:
grep -r "import.*mapbox_gl" lib/features/

Output MUST be empty. If not, refactor immediately.

This is NON-NEGOTIABLE for Phase 4 completion.
```

**Ready to build Phase 4?** Start with `lib/features/create/data/models/trip.dart` 🚀