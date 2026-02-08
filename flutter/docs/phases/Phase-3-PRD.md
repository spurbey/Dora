# **FLUTTER PHASE 3 PRD: MY TRIPS & PROFILE**

## **Complete Implementation Guide**

---

## **📋 Phase Overview**

**Phase ID:** Flutter Phase 3  
**Duration:** 3 weeks  
**Dependencies:** Phase 1 (Foundation), Phase 2 (Feed & Discovery)  
**Goal:** Build user's personal trip management and profile features

---

## **🎯 Objectives**

**Primary Goal:**  
Users can manage their personal trip collection, view statistics, and configure settings.

**What Success Looks Like:**
- User sees their trips in grid/list view
- User can filter trips (All, Active, Completed, Shared)
- User can duplicate/delete trips
- User can switch view modes (grid/list)
- Profile shows stats (trips, places, videos, views)
- Settings screen functional
- User can sign out

**Phase 1 & 2 Foundation Used:**
- ✅ Theme system (all UI uses tokens)
- ✅ Navigation shell (My Trips + Profile tabs populated)
- ✅ Auth (user context, sign out)
- ✅ Drift DB (cache user trips)
- ✅ Riverpod (manage state)
- ✅ Repository pattern (offline-first)

---

## **🏗️ Architecture Alignment**

### **References Architecture Document:**
- Folder Structure (features/trips/, features/profile/)
- Offline-First Architecture (Repository pattern)
- State Management (Riverpod providers)
- Authentication (sign out flow)

### **References Screen Specifications:**
- Screen 6: My Trips (Library)
- Screen 7: Profile

### **References Design System:**
- Section 8: Component Rules (Cards, FAB, Context Menus)
- Section 9: Navigation & Layout Rules

---

## **📁 Deliverables Overview**

**Files to Create: ~25 files**

```
lib/
├── features/
│   ├── trips/
│   │   ├── data/
│   │   │   ├── trips_repository.dart
│   │   │   ├── trips_api.dart
│   │   │   └── models/
│   │   │       ├── user_trip.dart
│   │   │       └── trip_stats.dart
│   │   ├── domain/
│   │   │   └── trips_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── my_trips_screen.dart
│   │       ├── widgets/
│   │       │   ├── trip_grid_card.dart
│   │       │   ├── trip_list_card.dart
│   │       │   ├── filter_chip_bar.dart
│   │       │   └── trip_context_menu.dart
│   │       └── providers/
│   │           └── trips_provider.dart
│   │
│   └── profile/
│       ├── data/
│       │   ├── profile_repository.dart
│       │   └── models/
│       │       └── user_profile.dart
│       ├── domain/
│       │   └── profile_state.dart
│       └── presentation/
│           ├── screens/
│           │   ├── profile_screen.dart
│           │   └── settings_screen.dart
│           ├── widgets/
│           │   ├── profile_header.dart
│           │   ├── stats_row.dart
│           │   └── settings_list_item.dart
│           └── providers/
│               └── profile_provider.dart
│
├── core/
│   └── storage/
│       └── tables/
│           └── user_trips_table.dart  (new)
│
└── shared/
    └── widgets/
        ├── view_mode_toggle.dart  (new)
        └── confirmation_dialog.dart  (new)
```

---

## **🔧 WEEK 1: MY TRIPS SCREEN**

### **Goal:** User sees their trip collection with grid/list views

---

### **W1.1: Data Layer - User Trips**

**Create files:**

**1. lib/core/storage/tables/user_trips_table.dart**

**Requirements:**
- Drift table for user's personal trips
- Mirror backend Trip model
- Add offline sync metadata
- Add local-only fields: `lastEditedAt`, `status` (editing/completed)

**Reference:** Architecture Doc (Offline-First Architecture, Drift tables)

**Key fields:**
- id, userId, name, description
- coverPhotoUrl, startDate, endDate
- visibility (private/public)
- placeCount (computed or cached)
- status (editing/completed/shared)
- lastEditedAt, localUpdatedAt, serverUpdatedAt, syncStatus

**Update:** `drift_database.dart` to include this table

---

**2. lib/features/trips/data/models/user_trip.dart**

**Requirements:**
- Freezed immutable model
- Matches Drift table structure
- JSON serialization for API
- Helper methods: `isActive`, `isCompleted`, `isShared`

**Reference:** Architecture Doc (Freezed models)

**Status values:**
- 'editing' - Work in progress
- 'completed' - Finished, not public
- 'shared' - Public on feed

---

**3. lib/features/trips/data/models/trip_stats.dart**

**Requirements:**
- User's aggregate statistics
- Fields: totalTrips, totalPlaces, totalVideos, totalViews

**Pattern:** Simple Freezed model with 4 integer fields

---

**4. lib/features/trips/data/trips_api.dart**

**Requirements:**
- Use OpenAPI generated client
- Methods: `getUserTrips()`, `deleteTrip(id)`, `duplicateTrip(id)`, `updateTripVisibility(id, visibility)`
- Handle pagination (optional for v1)

**Reference:** Architecture Doc (OpenAPI Integration)

**API Strategy:**
- For Phase 3: **Mock these endpoints** (backend doesn't have them yet)
- Create `mock_trips_api.dart` with hardcoded responses
- Return 5-10 sample UserTrip objects
- Comment: "// TODO: Replace with real API"

---

**5. lib/features/trips/data/trips_repository.dart**

**Requirements:**
- Offline-first pattern
- CRUD operations: get, create, update, delete
- Duplicate trip logic
- Update visibility (private ↔ public)
- Cache management

**Reference:** Architecture Doc (Repository Pattern, Offline-First)

**Key methods:**
- `getUserTrips({filter, viewMode})` - Try local first, then API
- `deleteTrip(id)` - Mark deleted locally, queue sync
- `duplicateTrip(id)` - Clone locally, add "(Copy)" to name
- `updateVisibility(id, visibility)` - Update local + queue sync

**Offline behavior:**
- Always return local data immediately
- Sync in background
- Show "Offline" indicator if sync pending

---

### **W1.2: Domain Layer - State**

**Create files:**

**6. lib/features/trips/domain/trips_state.dart**

**Requirements:**
- Freezed state model
- Fields: trips list, current filter, view mode (grid/list), loading states

**Reference:** Architecture Doc (State Management)

**State shape:**
```
trips: List<UserTrip>
currentFilter: 'all' | 'active' | 'completed' | 'shared'
viewMode: 'grid' | 'list'
isLoading: bool
```

---

**7. lib/features/trips/presentation/providers/trips_provider.dart**

**Requirements:**
- Riverpod AsyncNotifier pattern
- Load user trips
- Apply filters
- Toggle view mode
- Delete trip action
- Duplicate trip action

**Reference:** Architecture Doc (Riverpod 2.x)

**Provider methods:**
- `build()` - Load initial trips
- `applyFilter(filter)` - Filter by status
- `toggleViewMode()` - Switch grid ↔ list
- `deleteTrip(id)` - Delete with confirmation
- `duplicateTrip(id)` - Clone trip

**State management:**
- Use `AsyncNotifier<TripsState>`
- Optimistic updates for delete/duplicate
- Show loading during operations

---

### **W1.3: Presentation Layer - Widgets**

**Create files:**

**8. lib/shared/widgets/view_mode_toggle.dart**

**Requirements:**
- Toggle button (grid/list icons)
- Highlighted current mode
- Tap to switch

**Reference:** Design System (buttons)

**Design:**
- Two icon buttons side by side
- Active: accent background
- Inactive: transparent

---

**9. lib/features/trips/presentation/widgets/filter_chip_bar.dart**

**Requirements:**
- Horizontal chip bar
- Options: All, Active, Completed, Shared
- Selected state
- Tap to apply filter

**Reference:** Screen Spec #6 (Filter chips), Design System (chips)

**Design:**
- Height: 40px
- Selected: accent background + white text
- Unselected: card background + textSecondary

---

**10. lib/features/trips/presentation/widgets/trip_grid_card.dart**

**Requirements:**
- Match Screen Spec #6 layout
- Cover image (157x120)
- Status badge overlay (Editing/Completed/Public)
- Trip name (max 2 lines)
- Meta: "X places · Y days"
- Last edited timestamp
- Tap to open editor

**Reference:** Screen Spec #6 (Trip Grid Card), Design System (Cards)

**Badge colors:**
- Editing: Orange (#F59E0B)
- Completed: Green (#059669)
- Shared: Blue (#1F6F78 - accent)

---

**11. lib/features/trips/presentation/widgets/trip_list_card.dart**

**Requirements:**
- Full-width horizontal layout
- Cover thumbnail (80x80, left)
- Trip info (center)
- Menu button (right)
- Same meta as grid card

**Reference:** Screen Spec #6 (List mode)

---

**12. lib/features/trips/presentation/widgets/trip_context_menu.dart**

**Requirements:**
- Bottom sheet modal
- Actions: Edit, Duplicate, Share, Export, Delete
- Delete is destructive (red)

**Reference:** Screen Spec #6 (Context menu), Design System (Bottom sheets)

**Actions:**
- Edit → Navigate to editor
- Duplicate → Clone trip, show toast
- Share → Change visibility, show toast
- Export → Navigate to export studio (Phase 5)
- Delete → Show confirmation dialog

---

**13. lib/shared/widgets/confirmation_dialog.dart**

**Requirements:**
- Reusable alert dialog
- Title, message, cancel/confirm buttons
- Destructive option (red confirm button)

**Reference:** Design System (Dialogs)

**Props:**
- title: String
- message: String
- confirmText: String
- cancelText: String
- isDestructive: bool
- onConfirm: Callback

---

### **W1.4: My Trips Screen**

**Create files:**

**14. lib/features/trips/presentation/screens/my_trips_screen.dart**

**Requirements:**
- Match Screen Spec #6 layout exactly
- Header with search bar + view toggle
- Filter chips row
- Grid/List view (conditional)
- FAB (Create New Trip)
- Empty state
- Loading/Error states
- Pull to refresh

**Reference:** Screen Spec #6 (Complete layout)

**Layout components:**
- Header: "My Trips" + [Grid] [List] toggle
- Search bar (placeholder, non-functional in Phase 3)
- Filter chips: All, Active, Completed, Shared
- Trip cards (grid 2-col or list full-width)
- FAB: "Create New Trip" (navigate to Pre-Create)

**States:**
- Empty: Icon 📚, "No trips yet", CTA button
- Loading: Shimmer cards (6 placeholders)
- Error: Standard ErrorView with retry

**Interactions:**
- Tap card → Navigate to Editor
- Long-press card → Show context menu
- Tap ⋮ menu → Show context menu
- Tap FAB → Navigate to Pre-Create
- Pull down → Refresh from server

---

### **Week 1 Checkpoint:**

**Deliverable:**
- My Trips screen functional
- User's trips load (mocked data OK)
- Grid/List view toggle works
- Filters work (All, Active, Completed, Shared)
- Context menu shows
- Duplicate works (creates copy)
- Delete shows confirmation
- FAB navigates to Pre-Create

**Test:**
```
Manual Test Flow:
□ Navigate to My Trips tab
□ See trips in grid view
□ Tap [List] → Switches to list
□ Tap [Active] filter → Shows only editing trips
□ Tap ⋮ on card → Menu appears
□ Tap Duplicate → New trip appears with "(Copy)"
□ Tap Delete → Confirmation shows → Confirm → Trip removed
□ Tap FAB → Navigates to Pre-Create
```

---

## **🔧 WEEK 2: PROFILE SCREEN**

### **Goal:** User sees stats and can access settings

---

### **W2.1: Profile Data Layer**

**Create files:**

**15. lib/features/profile/data/models/user_profile.dart**

**Requirements:**
- Freezed model
- Fields: userId, username, email, avatarUrl, stats (TripStats object)

**Reference:** Architecture Doc (Freezed models)

**Note:** For Phase 3, stats can be computed locally from user's trips count

---

**16. lib/features/profile/data/profile_repository.dart**

**Requirements:**
- Get current user profile
- Update avatar (future)
- Get aggregate stats

**Methods:**
- `getProfile()` - Fetch user data + compute stats
- `updateAvatar(file)` - Placeholder for Phase 4
- `getStats()` - Count trips, places, videos from local DB

**Backend integration:**
- For Phase 3: Use Supabase `auth.currentUser` for basic info
- Compute stats locally from Drift DB
- Mock video/view counts (return 0)

---

### **W2.2: Profile State Management**

**Create files:**

**17. lib/features/profile/presentation/providers/profile_provider.dart**

**Requirements:**
- Riverpod provider
- Load user profile
- Expose stats
- Handle sign out

**Reference:** Architecture Doc (Riverpod 2.x)

**Provider structure:**
- `@riverpod` annotation
- `build()` loads profile from repository
- `signOut()` calls AuthService.signOut()
- Returns `AsyncValue<UserProfile>`

---

### **W2.3: Profile UI Widgets**

**Create files:**

**18. lib/features/profile/presentation/widgets/profile_header.dart**

**Requirements:**
- Centered avatar (80px circular)
- Username below (H2)
- Tap avatar to change (show toast "Coming soon")

**Reference:** Screen Spec #7 (Profile header)

**Design:**
- Background: surface
- Padding: allLg
- Avatar: Circular, grey placeholder if no image
- Username: textPrimary, centered

---

**19. lib/features/profile/presentation/widgets/stats_row.dart**

**Requirements:**
- 4 evenly-spaced stat columns
- Each: Large number (H2) + Label (Caption)
- Labels: Trips, Places, Videos, Views

**Reference:** Screen Spec #7 (Stats row)

**Design:**
- Row with MainAxisAlignment.spaceEvenly
- Each stat: Column with number above label
- Number: textPrimary
- Label: textSecondary

---

**20. lib/features/profile/presentation/widgets/settings_list_item.dart**

**Requirements:**
- List tile with label + value + arrow
- Tap to navigate or show picker

**Reference:** Screen Spec #7 (Settings screen)

**Props:**
- title: String
- value: String (optional)
- onTap: Callback
- trailing: Widget (default arrow icon)

---

### **W2.4: Profile & Settings Screens**

**Create files:**

**21. lib/features/profile/presentation/screens/profile_screen.dart**

**Requirements:**
- Match Screen Spec #7 layout
- Header with Settings button
- Profile header (avatar + username)
- Stats row
- Tabs: My Trips, Shared, Saved
- Trip grid (reuse from My Trips)

**Reference:** Screen Spec #7 (Complete layout)

**Layout:**
- AppBar: "Profile" + [Settings] icon
- Profile header widget
- Stats row widget
- TabBar: My Trips, Shared, Saved
- TabBarView: Trip grids for each tab

**Tab content:**
- My Trips: All user trips
- Shared: Filter where visibility = 'public'
- Saved: Empty for Phase 3 (show EmptyState)

**Empty state (Saved tab):**
- Icon: bookmark_border
- Title: "No saved trips yet"
- Description: "Explore the feed to discover journeys"

---

**22. lib/features/profile/presentation/screens/settings_screen.dart**

**Requirements:**
- Match Screen Spec #7 Settings layout
- Sections: Account, Preferences, Storage, About
- Settings items (mostly placeholders)
- Sign Out button (functional)

**Reference:** Screen Spec #7 (Settings screen)

**Sections:**

**ACCOUNT:**
- Email (show current, non-editable)
- Change Password → Toast "Coming soon"

**PREFERENCES:**
- Default Trip Privacy → Show picker (Private/Public)
- Offline Map Downloads → Toast "Coming soon"

**STORAGE:**
- Clear Cache → Show confirmation → Clear Drift cache → Toast "Cache cleared"

**ABOUT:**
- Privacy Policy → Open URL (placeholder link)
- Terms of Service → Open URL (placeholder link)
- Version → Show app version (non-interactive)

**Sign Out:**
- Destructive button (red, full width)
- Show confirmation dialog
- On confirm: Call auth.signOut(), navigate to Login

---

### **Week 2 Checkpoint:**

**Deliverable:**
- Profile screen shows user info
- Stats display (computed from local data)
- Tabs work (My Trips, Shared, Saved)
- Settings screen functional
- Sign out works
- Clear cache works

**Test:**
```
Manual Test Flow:
□ Navigate to Profile tab
□ See username + stats
□ Tap stats → No action (correct)
□ Switch tabs → Content updates
□ Tap Settings → Navigate to settings
□ Tap Sign Out → Confirmation → Confirm → Logged out
□ Login again
□ Tap Clear Cache → Confirmation → Cache cleared toast
```

---

## **🔧 WEEK 3: POLISH & INTEGRATION**

### **Goal:** Connect all pieces, handle edge cases, polish UX

---

### **W3.1: Navigation Integration**

**Tasks:**

**Update routes.dart:**
- Add `/trips` route (already exists, verify)
- Add `/profile` route (already exists, verify)
- Add `/settings` route (new)

**Update app_router.dart:**
- Ensure My Trips tab shows MyTripsScreen
- Ensure Profile tab shows ProfileScreen
- Add Settings route

**Reference:** Architecture Doc (Navigation)

---

### **W3.2: Active Trip Detection**

**Goal:** Show "Continue Your Journey" banner on Feed if user has active trip

**Tasks:**

**1. Add to TripsRepository:**
- Method: `getActiveTrip()` - Returns trip with status='editing'

**2. Add to FeedProvider:**
- Check for active trip on build
- Pass to FeedScreen

**3. Update FeedScreen (from Phase 2):**
- Show OngoingTripBanner if activeTrip != null
- Tap banner → Navigate to Editor with tripId

**Reference:** Screen Spec #1 (Ongoing Trip Banner)

---

### **W3.3: Search Integration**

**Goal:** Enable search bar on My Trips

**Tasks:**

**Update MyTripsScreen:**
- Search bar currently placeholder
- Make functional: filter trips by name (local only)
- Debounce 300ms
- Show filtered results

**Search logic:**
- Filter `trips.where((t) => t.name.toLowerCase().contains(query.toLowerCase()))`
- No API call needed

---

### **W3.4: Error Handling & Edge Cases**

**Tasks:**

**1. Handle empty trips gracefully:**
- Show EmptyState with CTA

**2. Handle delete last trip:**
- Show empty state after deletion

**3. Handle duplicate with long name:**
- Truncate if needed to fit UI

**4. Handle offline sync failures:**
- Show "Sync failed" indicator
- Retry button

**5. Handle sign out with pending changes:**
- Check for unsaved trips
- Warn user: "You have unsaved changes. Sign out anyway?"

---

### **W3.5: Loading States & Shimmer**

**Tasks:**

**Create shimmer placeholders:**
- Trip card shimmer (grid + list)
- Profile header shimmer
- Stats row shimmer

**Reference:** Design System (loading indicators)

**Use:** `shimmer` package or custom shimmer widget

**Apply to:**
- MyTripsScreen while loading
- ProfileScreen while loading

---

### **W3.6: Pull to Refresh**

**Tasks:**

**Add to MyTripsScreen:**
- Wrap ListView in RefreshIndicator
- Color: accent
- onRefresh: Call repository.getUserTrips(forceRefresh: true)

**Add to ProfileScreen:**
- Same pattern for each tab

**Reference:** Screen Spec #6 (Pull to Refresh)

---

### **W3.7: Confirmation Dialogs**

**Tasks:**

**Delete Trip Confirmation:**
- Use ConfirmationDialog widget
- Title: "Delete "{Trip Name}"?"
- Message: Multi-line explaining what gets deleted
- Destructive: true

**Reference:** Screen Spec #6 (Delete confirmation), Design System (Dora microcopy)

**Microcopy:**
```
Delete "{Trip Name}"?

This will permanently delete:
• All places and routes
• Photos and notes
• Export history

This cannot be undone.
```

**Sign Out Confirmation:**
- Title: "Sign out?"
- Message: "Make sure all changes are synced"

---

### **W3.8: Toast Messages**

**Tasks:**

**Success toasts:**
- Trip duplicated
- Trip deleted
- Cache cleared
- Visibility changed

**Error toasts:**
- Delete failed
- Duplicate failed
- Sync failed

**Reference:** Design System (Dora microcopy)

**Dora voice:**
- Success: "Trip duplicated", "Trip deleted"
- Error: "Couldn't delete trip", "Something went wrong"

---

### **Week 3 Checkpoint:**

**Deliverable:**
- All navigation works
- Active trip banner shows on Feed
- Search on My Trips works
- All error states handled
- Shimmer loading states
- Pull to refresh works
- All confirmations show
- Toasts use Dora microcopy

**Test:**
```
End-to-End Test:
□ Fresh install → Login
□ Create 3 trips (via FAB)
□ Go to My Trips → See 3 trips
□ One has status 'editing'
□ Go to Feed → See "Continue Your Journey" banner
□ Tap banner → Opens editor
□ Back to My Trips
□ Search "trip" → Filters list
□ Duplicate trip → See "(Copy)" version
□ Delete trip → Confirmation → Deleted
□ Switch to List view → Layout changes
□ Pull to refresh → Updates
□ Go to Profile → See stats (3 trips)
□ Tap Settings → Navigate
□ Sign out → Confirmation → Logged out
```

---

## **✅ Phase 3 Success Criteria**

### **Functional Requirements:**

**My Trips:**
- [ ] User's trips load from local DB
- [ ] Grid/List view toggle works
- [ ] Filters work (All, Active, Completed, Shared)
- [ ] Search filters trips by name
- [ ] Duplicate creates copy
- [ ] Delete removes trip (with confirmation)
- [ ] Context menu shows all actions
- [ ] FAB navigates to Pre-Create
- [ ] Pull to refresh works
- [ ] Empty state shows

**Profile:**
- [ ] Profile loads user data
- [ ] Stats show correct counts
- [ ] Tabs work (My Trips, Shared, Saved)
- [ ] Shared tab filters public trips
- [ ] Saved tab shows empty state
- [ ] Settings navigate works
- [ ] Sign out works (with confirmation)
- [ ] Clear cache works

**Integration:**
- [ ] Active trip banner shows on Feed (if exists)
- [ ] Tap banner navigates to Editor
- [ ] All navigation flows work
- [ ] All confirmations use Dora microcopy
- [ ] All toasts use Dora voice

**Code Quality:**
- [ ] All operations through repository
- [ ] Offline-first pattern followed
- [ ] All theme values from tokens
- [ ] Freezed models used
- [ ] Riverpod providers follow pattern
- [ ] No hardcoded strings (use Dora microcopy)

---

## **🧪 Testing Strategy**

### **Manual Testing Checklist:**

```
MY TRIPS SCREEN:
□ Load screen → Trips display
□ Grid view → 2 columns
□ List view → Full width cards
□ Filter All → Shows all
□ Filter Active → Shows editing only
□ Filter Completed → Shows completed only
□ Filter Shared → Shows public only
□ Search "trip" → Filters list
□ Clear search → Shows all
□ Tap card → Opens editor
□ Long-press card → Context menu
□ Tap ⋮ → Context menu
□ Duplicate → Creates copy with "(Copy)"
□ Delete → Confirmation → Removes
□ FAB → Navigate to Pre-Create
□ Pull to refresh → Updates
□ Empty state → Shows when no trips

PROFILE SCREEN:
□ Load → Shows username
□ Stats → Correct counts
□ My Trips tab → All trips
□ Shared tab → Public only
□ Saved tab → Empty state
□ Tap Settings → Navigate
□ Back to Profile → Returns

SETTINGS SCREEN:
□ Email → Displays correctly
□ Change Password → Toast "Coming soon"
□ Privacy picker → Shows dialog
□ Select Private → Updates
□ Clear Cache → Confirmation → Toast
□ Privacy Policy → Opens URL
□ Sign Out → Confirmation → Logs out

INTEGRATION:
□ Create trip in editor
□ Navigate to Feed → Banner shows
□ Tap banner → Returns to editor
□ Complete trip
□ Navigate to Feed → Banner gone
□ Profile stats → Count increased
```

---

## **⚠️ Common Pitfalls**

### **1. Not Filtering Tabs Correctly**

**Problem:** Shared tab shows all trips

**Solution:** Filter where `visibility === 'public'` in provider

---

### **2. Stats Not Updating After Delete**

**Problem:** Profile shows old count after trip deleted

**Solution:** Invalidate profile provider when trips change:
```dart
ref.invalidate(profileProvider);
```

---

### **3. Duplicate Doesn't Add "(Copy)"**

**Problem:** Duplicated trip has same name

**Solution:** In repository, append " (Copy)" to name field

---

### **4. Search Not Debounced**

**Problem:** Filters on every keystroke

**Solution:** Use Timer with 300ms delay

---

### **5. Context Menu Doesn't Dismiss**

**Problem:** Menu stays open after action

**Solution:** Call `Navigator.pop(context)` before executing action

---

## **📋 Handoff to Phase 4**

**What Phase 4 will build on:**
- ✅ My Trips infrastructure (add editor integration)
- ✅ Profile infrastructure (add avatar upload)
- ✅ Settings infrastructure (add preferences)

**What Phase 4 will build:**
- Pre-Create screen (trip form)
- Editor workspace (map + timeline)
- Place search integration
- Route drawing
- Media upload

---

## **🎯 Phase 3 Completion Definition**

**Phase 3 is complete when:**

1. ✅ All ~25 files created
2. ✅ My Trips screen shows user's trips
3. ✅ Grid/List toggle works
4. ✅ Filters work
5. ✅ Search works (local)
6. ✅ Duplicate/Delete work
7. ✅ Profile shows stats
8. ✅ Settings functional
9. ✅ Sign out works
10. ✅ Active trip banner shows on Feed
11. ✅ All confirmations use Dora voice
12. ✅ Passes manual testing checklist

---

**END OF PHASE 3 PRD**

---

**Next:** Phase 4 PRD (Trip Creation & Editor - 4 weeks)

**Instruction for AI Agent:**

```
Phase 3 Strategy:

MOCK DATA:
- Use local mock data for user trips (5-10 sample trips)
- Compute stats from local trip count
- Repository returns mocked data, no real API calls yet
- Comment all mocks: "// TODO: Replace with API"

UI FOCUS:
- Build complete UI flows
- All interactions functional
- Proper loading/error states
- Dora microcopy throughout

INTEGRATION:
- Connect Feed ← Active trip detection
- Connect Profile ← Trip stats
- All navigation flows complete

DEFER TO PHASE 4:
- Actual trip editing (just navigate for now)
- Photo upload
- Real backend sync
```

**Ready to build Phase 3?** 🚀