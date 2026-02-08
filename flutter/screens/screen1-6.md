# 📱 **DORA SCREEN SPECIFICATIONS - v1.0**

## **Complete UI Blueprint (12 Core Screens)**

---

## **📋 Document Purpose**

**Developer-ready specifications for all screens.**

Each spec contains:
- ASCII wireframe (visual layout)
- Component breakdown (what exists)
- Interaction flows (what happens)
- Dora personality (microcopy)
- States (loading, error, empty)
- Navigation (where it goes)

**For AI agents:** Build exactly as specified using Dora theme tokens.

---

## **🗺️ Navigation Architecture**

### **Bottom Tab Bar (Persistent)**

```
┌─────────────────────────────────────────────────────┐
│  Feed    Create    My Trips    Profile              │
│   🏠       ➕         📚          👤                  │
└─────────────────────────────────────────────────────┘
```

**Tabs:**
1. **Feed** - Discovery, public trips, search
2. **Create** - Travelogue builder (direct access)
3. **My Trips** - User's trip library
4. **Profile** - Stats, settings, shared content

**Navigation Rules:**
- Tab bar always visible (except Export Studio)
- Deep links preserve tab context
- Back button respects tab hierarchy

---

## **SCREEN 1: FEED (EXPLORE)**

### **Purpose**
Discovery feed + powerful search + ongoing trip banner

---

### **Layout (ASCII Wireframe)**

```
┌─────────────────────────────────────────────┐
│  ┌───────────────────────────────────────┐  │ ← Header (80px)
│  │  Dora                    [Filter] 🔍  │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │ 🔍 Plan, advise, or search...   │  │  │ ← Search bar (56px)
│  │  └─────────────────────────────────┘  │  │
│  └───────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│                                             │
│  ╔═══════════════════════════════════════╗ │ ← IF user has active trip
│  ║  Continue Your Journey                 ║ │
│  ║  ┌───────────────────────────────────┐ ║ │
│  ║  │ 📍 Japan Adventure (5 places)      │ ║ │
│  ║  │ Last edited 2 hours ago            │ ║ │
│  ║  │ [Continue editing →]               │ ║ │
│  ║  └───────────────────────────────────┘ ║ │
│  ╚═══════════════════════════════════════╝ │
│                                             │
│  Discover Travelogues                       │ ← Section (H2)
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Large Image - Trip Cover]            │ │ ← Trip Card
│  │                                       │ │   (335px wide)
│  │ 🗺️ Iceland Road Trip                  │ │
│  │ 📸 12 places · 8 days                 │ │
│  │ by @explorer                          │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Large Image]                         │ │
│  │ 🗺️ Tokyo in 3 Days                    │ │
│  │ 📸 8 places · 3 days                  │ │
│  │ by @traveler                          │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Infinite scroll...]                       │
│                                             │
├─────────────────────────────────────────────┤
│  Feed  Create  My Trips  Profile           │ ← Tab Bar (56px)
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Header (Custom Widget)**
```dart
DoraHeader(
  title: 'Dora',
  actions: [
    IconButton(icon: Icons.tune, onPressed: showFilters),
    IconButton(icon: Icons.search, onPressed: focusSearch),
  ],
)
```
- Height: 80px
- Background: `surface`
- Title: H1, `textPrimary`
- Elevation: None

---

**Search Bar (Material 3)**
```dart
SearchBar(
  hintText: 'Plan, advise, or search...',
  leading: Icon(Icons.explore, color: AppColors.accent),
  backgroundColor: AppColors.card,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.borderMd,
  ),
  onTap: () => navigateToSearch(),
)
```
- Height: 56px
- Margin: `horizontalMd`
- Placeholder: "Plan, advise, or search..."
- Action: Navigate to Search Screen

---

**Ongoing Trip Banner (Custom Widget)**
```dart
OngoingTripBanner(
  trip: activeTrip,
  onTap: () => resumeEditor(activeTrip),
)
```
- Only shown if `user.activeTrip != null`
- Background: `accentSoft` (#E6F2F3)
- Border: `accent` (1px)
- Border radius: `lg`
- Padding: `allMd`
- Margin: `horizontalMd`, `verticalLg`

**Content:**
- Title: "Continue Your Journey" (H3, `accent`)
- Trip name (Body, bold)
- Meta: "Last edited X ago" (Caption, `textSecondary`)
- Button: "Continue editing →" (accent color)

---

**Trip Card (Custom Widget)**
```dart
TripCard(
  trip: publicTrip,
  onTap: () => navigateToTripDetail(trip),
)
```
- Width: 335px (centered)
- Background: `card`
- Border radius: `md`
- Shadow: Soft (8px blur, 2px offset)
- Margin: `verticalMd`

**Layout:**
```
┌─────────────────────────┐
│ [Image 335x200]         │ ← Cover photo
├─────────────────────────┤
│ Padding: 16px           │
│                         │
│ 🗺️ Trip Name (H3)       │
│ 📸 12 places · 5 days   │ ← Caption, textSecondary
│ by @username            │ ← Caption, accent
└─────────────────────────┘
```

---

### **States**

**Loading State:**
```
┌─────────────────────────────────┐
│  [Shimmer Header]               │
│  [Shimmer Search Bar]           │
│  [Shimmer Card]                 │
│  [Shimmer Card]                 │
│  [Shimmer Card]                 │
└─────────────────────────────────┘
```

**Empty State:**
```
┌─────────────────────────────────┐
│          🌍                      │
│                                 │
│  No travelogues yet             │ ← H3, textPrimary
│                                 │
│  Be the first to share          │ ← Body, textSecondary
│  your journey!                  │
│                                 │
│  [Create Your First Trip]       │ ← Accent button
└─────────────────────────────────┘
```
- Icon: 🌍 (64px)
- Vertical center
- Button navigates to Create tab

**Error State:**
```
┌─────────────────────────────────┐
│          ⚠️                      │
│                                 │
│  Couldn't load travelogues      │ ← H3
│                                 │
│  Check your connection          │ ← Caption
│  and try again                  │
│                                 │
│  [Retry]                        │ ← Outlined button
└─────────────────────────────────┘
```

---

### **Interactions**

**Pull to Refresh:**
- Drag down from top
- Show loading indicator (accent color)
- Refresh feed from API

**Infinite Scroll:**
- Detect scroll position (85% down)
- Load next page
- Show bottom loading indicator

**Tap Search Bar:**
- Navigate to Search Screen (full screen)
- Keyboard auto-focus

**Tap Filter Icon:**
- Show bottom sheet with filters:
  - Duration (1 day, 3 days, 1 week, 2+ weeks)
  - Budget (Budget, Mid-range, Luxury)
  - Travel style (Adventure, Relaxed, Cultural)
- Apply filters → Refresh feed

**Tap Trip Card:**
- Navigate to Trip Detail Screen (full screen)
- Hero animation (image)

**Tap Ongoing Banner:**
- Navigate to Editor Screen
- Resume editing active trip

---

### **Dora Personality (Microcopy)**

**Search placeholder:**
> "Plan, advise, or search..."

**Ongoing banner title:**
> "Continue Your Journey"

**Empty state:**
> "No travelogues yet"
> "Be the first to share your journey!"

**Error state:**
> "Couldn't load travelogues"
> "Check your connection and try again"

---

### **Navigation**

**From Feed:**
- Tap search → Search Screen
- Tap card → Trip Detail Screen
- Tap ongoing banner → Editor Screen
- Tap Create tab → Pre-Create Screen
- Tap My Trips tab → My Trips Screen
- Tap Profile tab → Profile Screen

---

## **SCREEN 2: SEARCH (PLANNER + ADVISOR)**

### **Purpose**
Unified search for planning, AI advice, and discovery

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  ← Back                            [Clear]  │ ← Header
│  ┌─────────────────────────────────────┐   │
│  │ 🔍 Type to search or ask...        │   │ ← Search input (active)
│  └─────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│                                             │
│  QUICK ACTIONS                              │ ← Section (Caption)
│  ┌─────────┐ ┌─────────┐ ┌─────────┐      │
│  │ 📍 Find │ │ 🤖 Ask  │ │ 🎯 Plan │      │ ← Chips
│  │ Places  │ │ Dora    │ │ Trip    │      │
│  └─────────┘ └─────────┘ └─────────┘      │
│                                             │
│  RECENT SEARCHES                            │
│  ┌───────────────────────────────────────┐ │
│  │ 🕐 Tokyo restaurants                  │ │ ← Recent item
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ 🕐 Best time to visit Iceland        │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  SUGGESTIONS                                │
│  • Hidden gems in Paris                     │ ← Body, textSecondary
│  • Weekend trips from London                │
│  • Budget travel Southeast Asia             │
│                                             │
└─────────────────────────────────────────────┘
```

**When typing:**
```
┌─────────────────────────────────────────────┐
│  ← Back                            [Clear]  │
│  ┌─────────────────────────────────────┐   │
│  │ 🔍 tokyo tempura |                  │   │ ← Input active
│  └─────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│  PLACES                                     │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Tempura Kondo                      │ │
│  │ Ginza, Tokyo · $$$                    │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Tsunahachi Shinjuku                │ │
│  │ Shinjuku, Tokyo · $$                  │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  TRIPS                                      │
│  ┌───────────────────────────────────────┐ │
│  │ 🗺️ Tokyo Food Tour                    │ │
│  │ by @foodlover · 8 places              │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ASK DORA                                   │
│  ┌───────────────────────────────────────┐ │
│  │ 💬 "What's the best tempura in Tokyo?"│ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Search Input (Custom)**
```dart
SearchInput(
  autofocus: true,
  hintText: 'Type to search or ask...',
  onChanged: (query) => handleSearch(query),
  onSubmit: (query) => executeSearch(query),
)
```
- Height: 56px
- Background: `card`
- Border: `divider` (1px)
- Focus border: `accent` (2px)
- Border radius: `md`
- Icon: 🔍 (accent)

---

**Quick Action Chips**
```dart
Chip(
  label: Text('Find Places'),
  avatar: Icon(Icons.place),
  backgroundColor: AppColors.accentSoft,
  onPressed: () => setSearchMode('places'),
)
```
- Height: 40px
- Background: `accentSoft`
- Text: Body, `accent`
- Border radius: `lg`
- Spacing: `sm` between chips

---

**Recent Search Item**
```dart
ListTile(
  leading: Icon(Icons.history, color: AppColors.textSecondary),
  title: Text('Tokyo restaurants'),
  trailing: IconButton(
    icon: Icon(Icons.close),
    onPressed: () => removeRecent(item),
  ),
  onTap: () => executeSearch('Tokyo restaurants'),
)
```

---

**Place Search Result**
```dart
PlaceSearchResult(
  place: place,
  onTap: () => showPlaceDetails(place),
  onAdd: () => addToTrip(place),
)
```

**Layout:**
```
┌─────────────────────────────────┐
│ 📍 Place Name (H3)              │
│ Location · Price level          │ ← Caption
│                      [+ Add]    │ ← Accent button (small)
└─────────────────────────────────┘
```

---

**Dora AI Suggestion**
```dart
DoraAISuggestion(
  query: userQuery,
  onTap: () => askDora(query),
)
```
- Background: `accentSoft`
- Icon: 💬
- Text: `accent`
- Border radius: `lg`
- Padding: `allMd`

---

### **Search Modes**

**Mode 1: Find Places (Foursquare/Google)**
- User types place name/category
- Results from Foursquare Places API
- Show: Name, location, category, price
- Actions: View details, Add to trip

**Mode 2: Ask Dora (AI Advisor)**
- User types question
- Send to backend AI endpoint
- Show conversational response
- Suggest related places/trips

**Mode 3: Plan Trip (Template)**
- User types destination
- Show pre-built itineraries
- Allow customization
- Fork to create own trip

---

### **States**

**Empty (No Query):**
- Show quick actions
- Show recent searches
- Show suggestions

**Typing (Active Search):**
- Debounce 300ms
- Show loading indicator
- Live results update

**Results:**
- Group by type (Places, Trips, Users)
- Max 5 per section
- "See all" link

**No Results:**
```
┌─────────────────────────────────┐
│          🔍                      │
│  No results for "xyz"           │
│  Try different keywords         │
│                                 │
│  ASK DORA                        │
│  💬 "Where should I go in xyz?" │
└─────────────────────────────────┘
```

---

### **Interactions**

**Tap Quick Action:**
- "Find Places" → Pre-fill search with place mode
- "Ask Dora" → Show AI input helper
- "Plan Trip" → Navigate to trip planning flow

**Tap Recent Search:**
- Execute search again
- Move to top of recent list

**Tap Suggestion:**
- Execute suggested search
- Track engagement

**Tap Place Result:**
- Show place detail bottom sheet
- Show: Photos, description, ratings
- Actions: Add to trip, Save for later

**Tap "Ask Dora" Suggestion:**
- Send query to AI
- Show conversational response
- Show related results

---

### **Dora Personality**

**Search placeholder:**
> "Type to search or ask..."

**Quick actions:**
> "Find Places" / "Ask Dora" / "Plan Trip"

**No results:**
> "No results for "{query}""
> "Try different keywords"

**AI suggestion:**
> "Ask Dora: What's the best tempura in Tokyo?"

**Suggestions:**
> "Hidden gems in Paris"
> "Weekend trips from London"
> "Budget travel Southeast Asia"

---

### **Navigation**

**From Search:**
- Back button → Feed Screen
- Tap place → Place Detail Bottom Sheet
- Tap trip → Trip Detail Screen
- Add to trip → Trip Selector Modal

---

## **SCREEN 3: TRIP DETAIL (PUBLIC VIEW)**

### **Purpose**
Immersive view of public travelogue with save/copy functionality

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  [Full-screen cover image]                  │ ← Hero image
│                                             │   (375x300)
│  ← Back                        [Share] [⋯]  │ ← Overlay
└─────────────────────────────────────────────┘
│  ╔═══════════════════════════════════════╗ │
│  ║ Iceland Road Trip                     ║ │ ← Trip Header
│  ║ by @explorer                          ║ │   (overlaps image)
│  ║ 📸 12 places · 8 days                 ║ │
│  ║ ⭐ Adventure · Solo-friendly           ║ │
│  ╚═══════════════════════════════════════╝ │
├─────────────────────────────────────────────┤
│  TABS                                       │
│  [Timeline] [Map] [Photos]                  │ ← Segmented control
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────────────────────────────────┐ │ ← Timeline item
│  │ Day 1                                 │ │
│  │                                       │ │
│  │ 📍 Reykjavik City Center             │ │
│  │ "Started the journey at..."          │ │
│  │ [3 photos]                            │ │
│  │                        [Save to trip] │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🚗 Drive to Golden Circle (65km)     │ │ ← Route item
│  │ 1h 15min · Scenic route               │ │
│  │                        [Copy route]   │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Gullfoss Waterfall                │ │
│  │ "Absolutely breathtaking..."          │ │
│  │ [2 photos]                            │ │
│  │                        [Save to trip] │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Continue scrolling...]                    │
│                                             │
├─────────────────────────────────────────────┤
│  [Copy Entire Trip]                         │ ← Sticky bottom button
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Cover Image (Custom)**
```dart
TripCoverImage(
  imageUrl: trip.coverPhotoUrl,
  height: 300,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black.withOpacity(0.3),
    ],
  ),
)
```
- Height: 300px
- Aspect: 5:4
- Dark gradient overlay (bottom)
- Back button (top-left, white)
- Share button (top-right, white)

---

**Trip Header Card**
```dart
TripHeaderCard(
  trip: trip,
  overlapsImage: true,
)
```
- Background: `card`
- Border radius: `xl` (top only)
- Shadow: Strong
- Margin top: -40px (overlaps image)
- Padding: `allLg`

**Content:**
```
Iceland Road Trip                 ← H1
by @explorer                      ← Body, accent (clickable)
📸 12 places · 8 days             ← Caption, textSecondary
⭐ Adventure · Solo-friendly       ← Tags (chips, accentSoft)
```

---

**Tab Selector**
```dart
TabBar(
  tabs: [
    Tab(text: 'Timeline'),
    Tab(text: 'Map'),
    Tab(text: 'Photos'),
  ],
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: AppColors.accent, width: 2),
  ),
)
```
- Height: 48px
- Background: `card`
- Selected: `accent`
- Unselected: `textSecondary`

---

**Timeline Place Item**
```dart
TimelinePlaceItem(
  place: place,
  dayNumber: 1,
  onSave: () => saveToTrip(place),
)
```

**Layout:**
```
┌─────────────────────────────────┐
│ Day 1                           │ ← Caption, textSecondary
│                                 │
│ 📍 Place Name (H3)              │
│ "User notes about place..."     │ ← Body (max 3 lines)
│                                 │
│ [Photo] [Photo] [Photo]         │ ← Horizontal scroll
│                                 │
│                  [Save to trip] │ ← Outlined button (accent)
└─────────────────────────────────┘
```

---

**Timeline Route Item**
```dart
TimelineRouteItem(
  route: route,
  onCopy: () => copyRoute(route),
)
```

**Layout:**
```
┌─────────────────────────────────┐
│ 🚗 Route description            │ ← H3 with transport icon
│ 65km · 1h 15min · Scenic        │ ← Caption, textSecondary
│                                 │
│ [Route map preview]             │ ← Static map image
│                                 │
│                  [Copy route]   │ ← Outlined button
└─────────────────────────────────┘
```

---

**Bottom Action Button**
```dart
StickyBottomButton(
  label: 'Copy Entire Trip',
  icon: Icons.file_copy,
  onPressed: () => copyTrip(trip),
)
```
- Background: `accent`
- Text: White
- Height: 56px
- Position: Fixed bottom
- Shadow: Elevated

---

### **Tabs**

**Timeline Tab (Default):**
- Chronological list
- Places + routes mixed
- Day separators
- Individual save actions

**Map Tab:**
```
┌─────────────────────────────────┐
│ [Full-screen map view]          │ ← Map with all markers
│                                 │
│ All places + routes visible     │
│ Tap marker → Show place card    │
│ Tap route → Highlight path      │
│                                 │
│ [Legend: Day 1, Day 2, Day 3]   │ ← Color-coded by day
└─────────────────────────────────┘
```

**Photos Tab:**
```
┌─────────────────────────────────┐
│ [Photo grid 2x columns]         │ ← All trip photos
│                                 │
│ [Photo] [Photo]                 │
│ [Photo] [Photo]                 │
│ [Photo] [Photo]                 │
│                                 │
│ Tap photo → Full-screen gallery │
└─────────────────────────────────┘
```

---

### **Interactions**

**Tap "by @username":**
- Navigate to user profile

**Tap Tag (Adventure, Solo-friendly):**
- Navigate to search with tag filter

**Tap "Save to trip" (Place):**
- Show trip selector modal
- User picks trip (or creates new)
- Place copied to trip
- Toast: "Saved to [Trip Name]"

**Tap "Copy route":**
- Show trip selector
- Route copied with waypoints
- Toast: "Route copied"

**Tap "Copy Entire Trip":**
- Show confirmation dialog:
  ```
  Copy "Iceland Road Trip"?
  
  This will create a new trip with:
  • All 12 places
  • All 3 routes
  • Original photos and notes
  
  [Cancel] [Create Copy]
  ```
- On confirm:
  - Create trip copy
  - Navigate to My Trips
  - Toast: "Trip copied! Ready to customize."

**Tap Photo:**
- Open full-screen gallery
- Swipe to browse all photos
- Show place context (which place)

---

### **States**

**Loading:**
```
[Shimmer cover image]
[Shimmer header card]
[Shimmer timeline items]
```

**Error:**
```
┌─────────────────────────────────┐
│          ⚠️                      │
│  Couldn't load trip             │
│  This trip may be private       │
│  or no longer available         │
│                                 │
│  [Back to Feed]                 │
└─────────────────────────────────┘
```

---

### **Dora Personality**

**Empty notes:**
> "No notes for this place"

**Copy confirmation:**
> "Copy "Iceland Road Trip"?"
> "This will create a new trip with all places, routes, and notes."

**Success toast:**
> "Trip copied! Ready to customize."
> "Saved to [Trip Name]"

**Photo caption (if no user caption):**
> "Photo from [Place Name]"

---

### **Navigation**

**From Trip Detail:**
- Back → Feed Screen
- Tap username → User Profile (future)
- Tap Share → System share sheet
- Tap ⋯ → Options menu (Report, etc.)
- After copy → My Trips Screen

---

## **SCREEN 4: PRE-CREATE (TRIP FORM)**

### **Purpose**
Gather trip metadata before opening editor workspace

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  × Close                                    │ ← Header
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │ [Blurred editor background preview]  │  │ ← Background
│  │                                      │  │   (shows what's coming)
│  └──────────────────────────────────────┘  │
│                                             │
│  ╔═══════════════════════════════════════╗ │
│  ║ Start Your Journey                    ║ │ ← Form overlay
│  ║                                       ║ │   (centered card)
│  ║ Trip Name *                           ║ │
│  ║ ┌─────────────────────────────────┐  ║ │
│  ║ │ e.g., Summer in Japan           │  ║ │
│  ║ └─────────────────────────────────┘  ║ │
│  ║                                       ║ │
│  ║ Description (Optional)                ║ │
│  ║ ┌─────────────────────────────────┐  ║ │
│  ║ │ Tell your story...              │  ║ │
│  ║ │                                 │  ║ │
│  ║ └─────────────────────────────────┘  ║ │
│  ║                                       ║ │
│  ║ When did you go?                      ║ │
│  ║ ┌──────────────┐ ┌──────────────┐   ║ │
│  ║ │ Start Date   │ │ End Date     │   ║ │
│  ║ └──────────────┘ └──────────────┘   ║ │
│  ║                                       ║ │
│  ║ Tags (Optional)                       ║ │
│  ║ [Solo] [Adventure] [Budget] [+]       ║ │
│  ║                                       ║ │
│  ║ ┌───────────────────────────────────┐║ │
│  ║ │ Create Trip                       │║ │ ← Accent button
│  ║ └───────────────────────────────────┘║ │
│  ╚═══════════════════════════════════════╝ │
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Form Card**
```dart
PreCreateForm(
  onSubmit: (tripData) => createAndOpenEditor(tripData),
  onCancel: () => Navigator.pop(),
)
```
- Width: 327px (centered)
- Background: `card`
- Border radius: `xl`
- Shadow: Elevated
- Padding: `allLg`

---

**Trip Name Input**
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Trip Name',
    hintText: 'e.g., Summer in Japan',
  ),
  validator: (value) => 
    value?.isEmpty ? 'Trip name required' : null,
)
```
- Required field
- Max length: 100 chars
- Auto-capitalize words

---

**Description Input**
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Description (Optional)',
    hintText: 'Tell your story...',
  ),
  maxLines: 3,
  maxLength: 500,
)
```
- Optional
- Multiline (3 lines visible)
- Max length: 500 chars
- Counter shown

---

**Date Pickers**
```dart
Row(
  children: [
    DatePickerField(
      label: 'Start Date',
      onDateSelected: (date) => setStartDate(date),
    ),
    SizedBox(width: AppSpacing.md),
    DatePickerField(
      label: 'End Date',
      onDateSelected: (date) => setEndDate(date),
    ),
  ],
)
```
- Both optional
- Default: Today for start, +7 days for end
- Validation: End must be after start

---

**Tag Selector**
```dart
TagSelector(
  selectedTags: tags,
  suggestions: ['Solo', 'Couple', 'Family', 'Adventure', 'Relaxed', 'Budget', 'Luxury'],
  onTagsChanged: (newTags) => setTags(newTags),
)
```
- Multi-select chips
- Pre-defined + custom
- Max 5 tags
- Background: `accentSoft`
- Text: `accent`

---

### **States**

**Initial:**
- All fields empty
- Create button disabled

**Typing (Valid):**
- Name filled
- Create button enabled (accent)

**Submitting:**
- Show loading spinner
- Disable all inputs
- Button text: "Creating..."

**Error:**
```
┌─────────────────────────────────┐
│ ⚠️ Something went wrong         │
│ Please try again                │
│ [Retry]                         │
└─────────────────────────────────┘
```
- Show below form
- Keep form data

---

### **Interactions**

**Tap "×" Close:**
- Confirm if form has data:
  ```
  Discard trip?
  
  Your changes will be lost.
  
  [Cancel] [Discard]
  ```

**Tap "Create Trip":**
1. Validate form
2. Create trip (local + queued sync)
3. Navigate to Editor Screen
4. Toast: "Let's build your journey!"

**Background Preview:**
- Subtle animation (parallax on scroll)
- Shows empty editor layout
- Blurred (focus on form)

---

### **Dora Personality**

**Form title:**
> "Start Your Journey"

**Placeholders:**
> "e.g., Summer in Japan"
> "Tell your story..."

**Success toast:**
> "Let's build your journey!"

**Discard confirmation:**
> "Discard trip?"
> "Your changes will be lost."

---

### **Navigation**

**From Pre-Create:**
- × Close → Create Tab (empty state)
- Create Trip → Editor Screen (new trip)

---

## **SCREEN 5: EDITOR WORKSPACE**

### **Purpose**
Full trip creation environment: map + timeline + tools

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  ← Trip Name              [Export] [⋮More] │ ← Header (56px)
├──────────────┬──────────────────────────────┤
│              │                              │
│  Timeline    │  Map View                    │ ← Split view
│  (Sidebar)   │  (Main canvas)               │
│              │                              │
│  ┌────────┐  │  [Mapbox map with markers]   │
│  │ Day 1  │  │                              │
│  ├────────┤  │  ┌──────────────────────┐   │
│  │ 📍 Place│  │  │ Floating Tools       │   │ ← Tool panel
│  │ Tokyo   │  │  │ [+] [✏️] [📍] [🗺️]  │   │   (right side)
│  ├────────┤  │  └──────────────────────┘   │
│  │ 🚗 Route│  │                              │
│  │ 65km    │  │                              │
│  ├────────┤  │                              │
│  │ 📍 Place│  │                              │
│  │ Kyoto   │  │                              │
│  └────────┘  │                              │
│              │                              │
│  [+ Add]     │                              │
│              │                              │
├──────────────┴──────────────────────────────┤
│  [Bottom Panel - Context Sensitive]         │ ← Detail panel (collapsed)
└─────────────────────────────────────────────┘
```

**Editor Modes:**
- **View Mode:** Browse, select items
- **Place Mode:** Search/add places
- **Route Mode:** Draw routes
- **Edit Mode:** Modify selected item

---

### **Component Breakdown**

**Header Bar**
```dart
EditorHeader(
  tripName: trip.name,
  onBack: () => confirmExit(),
  actions: [
    IconButton(
      icon: Icons.ios_share,
      onPressed: () => showExportOptions(),
    ),
    PopupMenuButton(
      items: [
        'Trip Settings',
        'Preview',
        'Delete Trip',
      ],
    ),
  ],
)
```
- Height: 56px
- Background: `card`
- Shadow: Subtle

---

**Timeline Sidebar (Left)**
```dart
TimelineSidebar(
  trip: trip,
  selectedItem: selectedItem,
  onItemTap: (item) => selectAndFlyTo(item),
  onReorder: (oldIndex, newIndex) => reorderTimeline(oldIndex, newIndex),
)
```
- Width: 280px (tablet), full-width bottom sheet (mobile)
- Background: `card`
- Border right: `divider`
- Scrollable
- Drag handles for reordering

**Timeline Item:**
```
┌──────────────────────┐
│ Day 1                │ ← Day header (sticky)
├──────────────────────┤
│ ① 📍 Tokyo Tower     │ ← Place
│    Morning           │   (Caption, textSecondary)
├──────────────────────┤
│ ② 🚗 25km · 30min   │ ← Route
├──────────────────────┤
│ ③ 📍 Senso-ji        │
│    Afternoon         │
└──────────────────────┘
```

**States:**
- Default: White background
- Selected: `accentSoft` background, `accent` border
- Hover: `surface` background

---

**Map Canvas (Center)**
```dart
AppMapView(
  initialCenter: trip.centerPoint ?? AppLatLng(lat: 0, lng: 0),
  markers: placeMarkers,
  routes: routePolylines,
  onMapCreated: (controller) => setMapController(controller),
  onMapTap: (position) => handleMapTap(position),
)
```
- Full remaining width/height
- Controls: Zoom, compass, locate me
- Gestures: Pan, zoom, rotate (enabled)

**Marker Design:**
```
📍 (Place marker)
- Color: Accent
- Label: Order number (①②③)
- Size: 32px
- Shadow: Yes

🚗🚴🚶✈️ (Route icons)
- Along route path
- Color: Match transport mode
```

---

**Floating Tool Panel (Right)**
```dart
FloatingToolPanel(
  currentMode: editorMode,
  onToolSelected: (tool) => setEditorMode(tool),
)
```
- Position: Top-right, 16px margin
- Background: `card` with blur
- Border radius: `lg`
- Shadow: Elevated

**Tools:**
```
┌──────────────┐
│  ➕ Add      │ ← Place/route selector
│  ✏️ Edit     │ ← Modify selected
│  📍 Places   │ ← Search places
│  🗺️ Routes   │ ← Draw routes
│  📸 Media    │ ← Upload photos
└──────────────┘
```

---

**Bottom Panel (Context-Sensitive)**

**Collapsed (Default):**
```
┌─────────────────────────────────┐
│ [Drag handle]                   │ ← 48px height
│ Tap to view details             │
└─────────────────────────────────┘
```

**Expanded (Place Selected):**
```
┌─────────────────────────────────────┐
│ [Drag handle]                       │
│                                     │
│ 📍 Tokyo Tower                      │ ← H2
│ Minato, Tokyo                       │ ← Caption
│                                     │
│ ┌─────┐ ┌─────┐ ┌─────┐            │ ← Photos (horizontal)
│ │Photo│ │Photo│ │ +Add│            │
│ └─────┘ └─────┘ └─────┘            │
│                                     │
│ Notes                               │
│ ┌─────────────────────────────────┐│
│ │ Add your notes...               ││
│ └─────────────────────────────────┘│
│                                     │
│ Visit Time                          │
│ [Morning] [Afternoon] [Evening]     │ ← Chips
│                                     │
│ [Delete Place]        [Save]        │
└─────────────────────────────────────┘
```

**Expanded (Route Selected):**
```
┌─────────────────────────────────────┐
│ 🚗 Route Details                    │
│                                     │
│ Distance: 25.3 km                   │
│ Duration: ~30 mins                  │
│                                     │
│ Transport                           │
│ [🚗 Car] [🚴 Bike] [🚶 Walk] [✈️ Air]│ ← Mode selector
│                                     │
│ Waypoints (2)                       │
│ • Gas Station                       │
│ • Viewpoint                         │
│ [+ Add Waypoint]                    │
│                                     │
│ [Delete Route]        [Save]        │
└─────────────────────────────────────┘
```

---

### **Editor Modes**

**Mode: View (Default)**
- Timeline visible
- Map interactive
- Tap items to select
- Bottom panel shows details

**Mode: Add Place**
1. Tap "+ Add" or "📍 Places"
2. Show search overlay:
   ```
   ┌─────────────────────────────┐
   │ Search places...            │ ← Search input
   │                             │
   │ Use current location        │ ← Button
   │                             │
   │ Nearby:                     │
   │ • Coffee Shop (200m)        │
   │ • Restaurant (500m)         │
   └─────────────────────────────┘
   ```
3. Select place → Add to timeline
4. Marker appears on map
5. Return to view mode

**Mode: Draw Route**
1. Tap "🗺️ Routes"
2. Map shows instruction:
   ```
   ┌─────────────────────────────┐
   │ Tap places to connect       │
   │ [Cancel] [Done]             │
   └─────────────────────────────┘
   ```
3. Tap start place → Tap end place
4. Route calculated (Mapbox Directions)
5. Preview shown
6. Confirm → Route added
7. Return to view mode

**Mode: Add Media**
1. Select place
2. Tap "📸 Media" or camera icon in bottom panel
3. Show options:
   ```
   ┌─────────────────────────────┐
   │ Take Photo                  │
   │ Choose from Gallery         │
   │ Cancel                      │
   └─────────────────────────────┘
   ```
4. Photo selected → Upload queue
5. Thumbnail appears in place detail

---

### **Interactions**

**Timeline Item Tap:**
- Select item (highlight)
- Map flies to location
- Bottom panel expands with details

**Timeline Item Long Press:**
- Show context menu:
  ```
  • Edit
  • Duplicate
  • Delete
  • Move to Day X
  ```

**Timeline Drag & Drop:**
- Long press → Drag handle appears
- Drag up/down to reorder
- Drop → Update order
- Map animates to new order

**Map Marker Tap:**
- Select corresponding timeline item
- Fly to marker
- Show bottom panel

**Map Tap (Empty Area):**
- Deselect current item
- Collapse bottom panel

**Tool Button Tap:**
- Enter tool mode
- UI adapts (show relevant controls)
- Map interaction changes

---

### **States**

**Loading (New Trip):**
```
[Shimmer sidebar]
[Loading map tiles]
```

**Empty Trip:**
```
┌─────────────────────────────────┐
│        Timeline                 │
│                                 │
│        🗺️                        │
│                                 │
│   Your journey starts here      │
│                                 │
│   [+ Add Your First Place]      │
└─────────────────────────────────┘
```
- Center of screen
- Gentle animation
- Call-to-action button

**Saving:**
- Show "Saving..." in header
- Spinner icon
- Auto-save every 30 seconds

**Offline:**
```
┌─────────────────────────────────┐
│ 📡 Offline Mode                  │
│ Changes will sync when online   │
└─────────────────────────────────┘
```
- Banner at top
- Orange background
- Dismissible

---

### **Dora Personality**

**Empty state:**
> "Your journey starts here"
> "Add your first place to begin"

**Drawing route:**
> "Tap places to connect"
> "Great! Now tap the destination"

**Saving:**
> "Saving your progress..."

**Offline:**
> "Offline Mode"
> "Changes will sync when online"

**Exit confirmation:**
> "Leave editor?"
> "All changes are saved"

---

### **Navigation**

**From Editor:**
- Back (← Trip Name) → Confirm → My Trips Screen
- Export → Export Studio Screen
- ⋮ More → Trip Settings Modal

---

## **NEXT SCREENS COMING:**

**Remaining screens (6-12):**
6. My Trips (Library)
7. Profile
8. Place Search (Full)
9. Media Upload Flow
10. Export Studio
11. Template Picker
12. Share/Preview

---

**Ready to continue with screens 6-12?**

**Respond:** "Continue screens 6-12" 🚀