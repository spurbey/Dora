I'll continue with the remaining 6 screens to complete the full specification.

---

## **SCREEN 6: MY TRIPS (LIBRARY)**

### **Purpose**
User's personal trip collection with filtering and management

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  My Trips                    [Grid] [List]  │ ← Header (56px)
│  ┌─────────────────────────────────────┐   │
│  │ 🔍 Search trips...                  │   │ ← Search bar
│  └─────────────────────────────────────┘   │
│                                             │
│  [All] [Active] [Completed] [Shared]        │ ← Filter chips
├─────────────────────────────────────────────┤
│                                             │
│  ACTIVE (1)                                 │ ← Section header
│  ┌───────────────────────────────────────┐ │
│  │ [Trip cover image]                    │ │ ← Trip card (grid mode)
│  │                                       │ │   (157px width)
│  │ ✏️ Editing                            │ │ ← Status badge
│  │ Japan Adventure                       │ │
│  │ 5 places · 2 days                     │ │
│  │ Last edited 2h ago                    │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  COMPLETED (3)                              │
│  ┌────────┐ ┌────────┐ ┌────────┐         │ ← Grid 2 columns
│  │[Cover] │ │[Cover] │ │[Cover] │         │
│  │Iceland │ │Tokyo   │ │Europe  │         │
│  │8 days  │ │3 days  │ │14 days │         │
│  └────────┘ └────────┘ └────────┘         │
│                                             │
│  [+ Create New Trip]                        │ ← FAB (Floating Action)
│                                             │
├─────────────────────────────────────────────┤
│  Feed  Create  My Trips  Profile           │ ← Tab bar
└─────────────────────────────────────────────┘
```

**List View Mode:**
```
│  ┌───────────────────────────────────────┐ │
│  │ [Cover] Japan Adventure          [⋮] │ │ ← List item
│  │ 80x80   5 places · 2 days             │ │   (full width)
│  │         Last edited 2h ago            │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ [Cover] Iceland Road Trip        [⋮] │ │
│  │ 80x80   12 places · 8 days            │ │
│  │         Completed Oct 2024            │ │
│  └───────────────────────────────────────┘ │
```

---

### **Component Breakdown**

**Filter Chips**
```dart
FilterChipBar(
  selected: currentFilter,
  options: ['All', 'Active', 'Completed', 'Shared'],
  onFilterChanged: (filter) => applyFilter(filter),
)
```
- Height: 40px
- Spacing: `sm`
- Selected: `accent` background
- Unselected: `card` background

---

**Trip Card (Grid Mode)**
```dart
TripGridCard(
  trip: trip,
  onTap: () => openEditor(trip),
  onMenuTap: () => showTripMenu(trip),
)
```

**Layout:**
```
┌─────────────────┐
│ [Cover Image]   │ ← 157x120
│ ✏️ Editing       │ ← Status badge (overlay)
├─────────────────┤
│ Trip Name       │ ← H3 (max 2 lines)
│ 5 places · 2d   │ ← Caption
│ Last edited 2h  │ ← Caption, textSecondary
└─────────────────┘
```

**Status Badges:**
- Editing: Orange background, "✏️ Editing"
- Completed: Green background, "✓ Completed"
- Shared: Blue background, "🌍 Public"

---

**Trip Card (List Mode)**
```dart
TripListCard(
  trip: trip,
  onTap: () => openEditor(trip),
  onMenuTap: () => showTripMenu(trip),
)
```

**Layout:**
```
┌───────────────────────────────────┐
│ [Cover]  Trip Name           [⋮] │
│  80x80   5 places · 2 days        │
│          Last edited 2 hours ago  │
└───────────────────────────────────┘
```

---

**Floating Action Button (FAB)**
```dart
FloatingActionButton.extended(
  onPressed: () => navigateToPreCreate(),
  icon: Icon(Icons.add),
  label: Text('Create New Trip'),
  backgroundColor: AppColors.accent,
)
```
- Position: Bottom-right
- Margin: 16px from edges
- Elevation: 6

---

### **Trip Context Menu**
```
┌─────────────────────┐
│ Edit                │
│ Duplicate           │
│ Share               │
│ Export Video        │
│ ───────────         │
│ Delete              │ ← Destructive (red)
└─────────────────────┘
```

---

### **States**

**Empty State (No Trips):**
```
┌─────────────────────────────────┐
│          📚                      │
│                                 │
│  No trips yet                   │ ← H3
│                                 │
│  Create your first travelogue   │ ← Body
│  and start sharing your         │
│  adventures                     │
│                                 │
│  [+ Create Your First Trip]     │ ← Accent button
└─────────────────────────────────┘
```

**Empty Filter (e.g., No Shared Trips):**
```
┌─────────────────────────────────┐
│  No shared trips                │ ← H3, center
│  Make a trip public to share    │ ← Caption
└─────────────────────────────────┘
```

**Loading:**
- Shimmer cards in grid/list
- 6 placeholder cards

---

### **Interactions**

**Tap Trip Card:**
- Navigate to Editor Screen
- Resume editing

**Tap ⋮ Menu:**
- Show context menu (bottom sheet)
- Actions: Edit, Duplicate, Share, Export, Delete

**Tap "Duplicate":**
1. Show loading
2. Copy trip (new ID)
3. Add " (Copy)" to name
4. Toast: "Trip duplicated"
5. Refresh list

**Tap "Delete":**
1. Show confirmation:
   ```
   Delete "Trip Name"?
   
   This will permanently delete:
   • All places and routes
   • Photos and notes
   • Export history
   
   This cannot be undone.
   
   [Cancel] [Delete]
   ```
2. On confirm → Delete → Refresh

**Tap "Export Video":**
- Navigate to Export Studio
- Pre-select trip

**Long Press Card:**
- Quick actions menu (same as ⋮)

**Search Trips:**
- Filter by name
- Debounce 300ms
- Show results live

**Pull to Refresh:**
- Sync from server
- Show progress indicator

---

### **Dora Personality**

**Empty state:**
> "No trips yet"
> "Create your first travelogue and start sharing your adventures"

**Delete confirmation:**
> "Delete "{Trip Name}"?"
> "This cannot be undone."

**Success toasts:**
> "Trip duplicated"
> "Trip deleted"

---

### **Navigation**

**From My Trips:**
- Tap card → Editor Screen
- Tap FAB → Pre-Create Screen
- Tap Export → Export Studio Screen

---

## **SCREEN 7: PROFILE**

### **Purpose**
User stats, settings, and shared content

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  Profile                         [Settings] │ ← Header
├─────────────────────────────────────────────┤
│                                             │
│              [Avatar]                       │ ← Profile header
│            @username                        │   (centered)
│                                             │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐       │ ← Stats row
│  │  12 │  │  48 │  │  5  │  │ 2.4k│       │
│  │Trips│  │Places│ │Videos│ │Views │       │
│  └─────┘  └─────┘  └─────┘  └─────┘       │
│                                             │
│  TABS                                       │
│  [My Trips] [Shared] [Saved]                │ ← Segmented control
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────────┐ ┌───────────────┐      │ ← Grid 2 columns
│  │ [Trip Cover]  │ │ [Trip Cover]  │      │
│  │ Iceland       │ │ Tokyo         │      │
│  │ 🌍 Public     │ │ 🔒 Private    │      │
│  └───────────────┘ └───────────────┘      │
│                                             │
│  ┌───────────────┐ ┌───────────────┐      │
│  │ [Trip Cover]  │ │ [Trip Cover]  │      │
│  │ Europe        │ │ Japan         │      │
│  └───────────────┘ └───────────────┘      │
│                                             │
├─────────────────────────────────────────────┤
│  Feed  Create  My Trips  Profile           │ ← Tab bar
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Profile Header**
```dart
ProfileHeader(
  user: currentUser,
  onAvatarTap: () => changeAvatar(),
)
```
- Avatar: 80px circular
- Username: H2, `textPrimary`
- Background: `surface`
- Padding: `allLg`

---

**Stats Row**
```dart
StatsRow(
  stats: [
    Stat(label: 'Trips', value: tripCount),
    Stat(label: 'Places', value: placeCount),
    Stat(label: 'Videos', value: exportCount),
    Stat(label: 'Views', value: viewCount),
  ],
)
```
- Evenly spaced
- Value: H2, `textPrimary`
- Label: Caption, `textSecondary`

---

**Tab Content**

**My Trips Tab:**
- Same grid as My Trips screen
- Shows all trips (public + private)

**Shared Tab:**
- Only public trips
- Shows view count badge

**Saved Tab:**
- Trips saved from others
- Shows original author

---

### **Settings Screen (Separate)**

```
┌─────────────────────────────────────────────┐
│  ← Settings                                 │
├─────────────────────────────────────────────┤
│                                             │
│  ACCOUNT                                    │
│  ┌───────────────────────────────────────┐ │
│  │ Email                     →           │ │
│  │ user@example.com                      │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Change Password           →           │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  PREFERENCES                                │
│  ┌───────────────────────────────────────┐ │
│  │ Default Trip Privacy      →           │ │
│  │ Private                               │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Offline Map Downloads     →           │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  STORAGE                                    │
│  ┌───────────────────────────────────────┐ │
│  │ Clear Cache                           │ │
│  │ 156 MB cached                         │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ABOUT                                      │
│  ┌───────────────────────────────────────┐ │
│  │ Privacy Policy            →           │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Terms of Service          →           │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Version 1.0.0 (Build 1)               │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Sign Out]                                 │ ← Destructive button
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Interactions**

**Tap Avatar:**
- Show options:
  ```
  • Take Photo
  • Choose from Library
  • Remove Avatar
  ```

**Tap Stat:**
- Navigate to filtered view
  - Trips → My Trips screen
  - Videos → Exports list
  - (Views not interactive)

**Tap Settings Icon:**
- Navigate to Settings Screen

**Tap Sign Out:**
- Confirm:
  ```
  Sign out?
  
  Make sure all changes are synced
  
  [Cancel] [Sign Out]
  ```
- Clear local data
- Navigate to Login

---

### **Dora Personality**

**Empty saved trips:**
> "No saved trips yet"
> "Explore the feed to discover journeys"

**Settings:**
> "Default Trip Privacy"
> "Make sure all changes are synced"

---

## **SCREEN 8: PLACE SEARCH (FULL SCREEN)**

### **Purpose**
Dedicated place search during editor workflow

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  ← Cancel                     [GPS] [Filter]│ ← Header
│  ┌─────────────────────────────────────┐   │
│  │ 🔍 Search places...                 │   │ ← Search input (focused)
│  └─────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│                                             │
│  QUICK ADD                                  │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Use Current Location               │ │ ← Button (accent)
│  │ Drop pin here                         │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  NEARBY                                     │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Blue Bottle Coffee                 │ │ ← Place result
│  │ Coffee Shop · 200m away               │ │
│  │ $$                        [+ Add]     │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Tsukiji Fish Market                │ │
│  │ Market · 500m away                    │ │
│  │ $                         [+ Add]     │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  CATEGORIES                                 │
│  [🍽️ Food] [☕ Cafe] [🏨 Hotel] [🏛️ Sight] │ ← Category chips
│                                             │
└─────────────────────────────────────────────┘
```

**Search Results:**
```
┌─────────────────────────────────────────────┐
│  ← Cancel                                   │
│  ┌─────────────────────────────────────┐   │
│  │ 🔍 tokyo tower                      │   │
│  └─────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│  PLACES (5)                                 │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Tokyo Tower                        │ │
│  │ Landmark · Minato, Tokyo              │ │
│  │ ⭐ 4.5 (12,450)           [+ Add]     │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ 📍 Tokyo Skytree                      │ │
│  │ Landmark · Sumida, Tokyo              │ │
│  │ ⭐ 4.6 (15,230)           [+ Add]     │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  FROM FEED (2)                              │
│  ┌───────────────────────────────────────┐ │
│  │ 🗺️ Tokyo in 3 Days                    │ │
│  │ includes Tokyo Tower                  │ │
│  │ by @traveler              [View Trip] │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Place Result Card**
```dart
PlaceResultCard(
  place: place,
  onAdd: () => addPlaceToTrip(place),
  onTap: () => showPlaceDetails(place),
)
```

**Layout:**
```
┌─────────────────────────────────┐
│ 📍 Place Name (H3)              │
│ Category · Location             │ ← Caption
│ ⭐ 4.5 (1,234)      [+ Add]     │ ← Rating + button
└─────────────────────────────────┘
```

- Height: Auto (min 72px)
- Tap card body → Show details
- Tap [+ Add] → Add immediately

---

**Use Current Location Button**
```dart
CurrentLocationButton(
  onPressed: () => useCurrentLocation(),
)
```
- Full width
- Background: `accentSoft`
- Border: `accent` (1px)
- Icon: 📍
- Text: "Use Current Location" / "Drop pin here"

---

**Category Chips**
```dart
CategoryChipBar(
  categories: ['Food', 'Cafe', 'Hotel', 'Sight', 'Shop', 'Activity'],
  onCategoryTap: (category) => filterByCategory(category),
)
```
- Horizontal scroll
- Icons + labels
- Selected: `accent` background

---

### **Place Detail Bottom Sheet**

**Triggered by tapping place card:**
```
┌─────────────────────────────────────────────┐
│  [Drag handle]                              │
│                                             │
│  📍 Tokyo Tower                             │ ← H2
│  Landmark · Minato, Tokyo                   │ ← Caption
│  ⭐ 4.5 (12,450 reviews)                    │
│                                             │
│  ┌─────┐ ┌─────┐ ┌─────┐                   │ ← Photo carousel
│  │Photo│ │Photo│ │Photo│                   │
│  └─────┘ └─────┘ └─────┘                   │
│                                             │
│  ABOUT                                      │
│  Historic communications and observation    │ ← Description
│  tower in the heart of Tokyo...             │
│                                             │
│  DETAILS                                    │
│  📍 4-2-8 Shibakoen, Minato               │
│  🕐 9:00 AM - 11:00 PM                    │
│  💰 ¥1,200 entrance                        │
│  🌐 tokyotower.co.jp                       │
│                                             │
│  [+ Add to Trip]                            │ ← Accent button
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Interactions**

**Tap "Use Current Location":**
1. Request location permission (if needed)
2. Get GPS coordinates
3. Create place with coords
4. Add to trip
5. Navigate back to editor

**Tap GPS Icon (Header):**
- Pan map to current location
- Show nearby places

**Tap Filter Icon:**
- Show filters:
  ```
  • Price: $ $$ $$$
  • Open Now
  • Distance: 1km, 5km, 10km
  • Rating: 4+, 4.5+
  ```

**Tap Category:**
- Filter results by category
- Highlight selected chip

**Tap [+ Add]:**
1. Add place to trip
2. Show toast: "Added to trip"
3. Button becomes "✓ Added" (disabled)
4. Stay on search screen

**Tap Place Card (Body):**
- Show detail bottom sheet
- Half-screen overlay

**Tap [+ Add to Trip] (Detail Sheet):**
- Add place
- Close sheet
- Navigate back to editor
- Toast: "Tokyo Tower added"

---

### **States**

**Loading GPS:**
```
┌─────────────────────────────────┐
│ 📍 Getting your location...     │
└─────────────────────────────────┘
```

**Location Permission Denied:**
```
┌─────────────────────────────────┐
│ ⚠️ Location access needed       │
│ Enable in Settings to use GPS   │
│ [Open Settings]                 │
└─────────────────────────────────┘
```

**No Results:**
```
┌─────────────────────────────────┐
│ 🔍 No places found              │
│ Try different keywords          │
│ or use current location         │
└─────────────────────────────────┘
```

---

### **Dora Personality**

**Search placeholder:**
> "Search places..."

**Current location button:**
> "Use Current Location"
> "Drop pin here"

**Loading:**
> "Getting your location..."

**No results:**
> "No places found"
> "Try different keywords or use current location"

**Success toast:**
> "Tokyo Tower added"

---

### **Navigation**

**From Place Search:**
- Cancel → Editor Screen
- Add place → Editor Screen (with new place)

---

## **SCREEN 9: MEDIA UPLOAD FLOW**

### **Purpose**
Camera/gallery integration with compression and upload queue

---

### **Layout (Photo Picker)**

```
┌─────────────────────────────────────────────┐
│  ← Back          Photos (3/10)       [Done] │ ← Header
├─────────────────────────────────────────────┤
│  SELECTED (3)                               │
│  ┌─────┐ ┌─────┐ ┌─────┐                   │ ← Selected thumbnails
│  │Photo│ │Photo│ │Photo│                   │   (horizontal scroll)
│  │  ×  │ │  ×  │ │  ×  │                   │
│  └─────┘ └─────┘ └─────┘                   │
├─────────────────────────────────────────────┤
│  [Camera] [All Photos ▾]                    │ ← Filters
├─────────────────────────────────────────────┤
│  ┌───┬───┬───┐                              │ ← Photo grid (3 columns)
│  │ ✓ │   │   │                              │
│  ├───┼───┼───┤                              │
│  │   │ ✓ │   │                              │
│  ├───┼───┼───┤                              │
│  │   │   │ ✓ │                              │
│  └───┴───┴───┘                              │
│                                             │
└─────────────────────────────────────────────┘
```

**Camera Mode:**
```
┌─────────────────────────────────────────────┐
│  ×                                    Flash │ ← Camera overlay
│                                             │
│                                             │
│          [Camera Viewfinder]                │
│                                             │
│                                             │
│          ┌─────────────┐                    │
│          │  Capture    │                    │ ← Capture button
│          └─────────────┘                    │
│  [Gallery]                      [Flip]      │
└─────────────────────────────────────────────┘
```

---

### **Upload Progress Screen**

```
┌─────────────────────────────────────────────┐
│  ← Back to Editor                           │
├─────────────────────────────────────────────┤
│                                             │
│  Uploading Photos                           │ ← H2
│  3 of 5 uploaded                            │ ← Caption
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Thumbnail] photo_001.jpg             │ │ ← Upload item
│  │ ✓ Uploaded                            │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ [Thumbnail] photo_002.jpg             │ │
│  │ ✓ Uploaded                            │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ [Thumbnail] photo_003.jpg             │ │
│  │ ✓ Uploaded                            │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ [Thumbnail] photo_004.jpg             │ │
│  │ ████████░░ 80%                        │ │ ← Progress bar
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ [Thumbnail] photo_005.jpg             │ │
│  │ Waiting...                            │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Pause Upload] [Cancel All]                │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Photo Grid Item**
```dart
PhotoGridItem(
  photo: photo,
  isSelected: selectedPhotos.contains(photo),
  onTap: () => toggleSelection(photo),
)
```
- Size: 33% width (3 columns)
- Aspect: 1:1 (square)
- Selected: Checkmark overlay (accent)
- Max selection: 10 photos

---

**Selected Photo Chip**
```dart
SelectedPhotoChip(
  photo: photo,
  onRemove: () => deselectPhoto(photo),
)
```
- Size: 60x60
- Border: `accent` (2px)
- Remove button: ×  (top-right)

---

**Upload Queue Item**
```dart
UploadQueueItem(
  file: file,
  status: uploadStatus, // 'waiting' | 'uploading' | 'completed' | 'failed'
  progress: progress, // 0.0 - 1.0
  onRetry: () => retryUpload(file),
  onCancel: () => cancelUpload(file),
)
```

**States:**
- Waiting: Gray, "Waiting..."
- Uploading: Progress bar + percentage
- Completed: Green checkmark, "✓ Uploaded"
- Failed: Red, "Failed" + [Retry] button

---

### **Interactions**

**Tap Camera Button:**
1. Check camera permission
2. Open camera view
3. User takes photo
4. Show preview with Accept/Retake
5. Accept → Add to selection

**Tap Photo (Grid):**
- Toggle selection
- Update counter
- Add to selected row
- Max 10 photos

**Tap × (Selected Chip):**
- Remove from selection
- Update counter

**Tap [Done]:**
1. Start compression (client-side)
2. Show progress screen
3. Queue uploads (background)
4. Navigate back to editor
5. Uploads continue in background

**Background Upload:**
- Uses `background_fetch` package
- Continues even if app backgrounded
- Retry on failure (3 attempts)
- Persist queue in local DB

---

### **States**

**Camera Permission Denied:**
```
┌─────────────────────────────────┐
│ 📷 Camera access needed         │
│ Allow Dora to take photos       │
│ [Open Settings]                 │
└─────────────────────────────────┘
```

**Compressing:**
```
┌─────────────────────────────────┐
│ 🗜️ Preparing photos...          │
│ This may take a moment          │
│ [Progress bar]                  │
└─────────────────────────────────┘
```

**Upload Failed:**
```
┌─────────────────────────────────┐
│ [Thumbnail] photo_004.jpg       │
│ ⚠️ Upload failed                │
│ [Retry] [Remove]                │
└─────────────────────────────────┘
```

**All Uploads Complete:**
```
┌─────────────────────────────────┐
│ ✓ All photos uploaded           │
│ 5 photos added to Tokyo Tower   │
│ [Back to Editor]                │
└─────────────────────────────────┘
```

---

### **Dora Personality**

**Camera permission:**
> "Camera access needed"
> "Allow Dora to take photos"

**Compressing:**
> "Preparing photos..."
> "This may take a moment"

**Uploading:**
> "Uploading photos"
> "3 of 5 uploaded"

**Success:**
> "All photos uploaded"
> "5 photos added to Tokyo Tower"

---

### **Navigation**

**From Media Upload:**
- Cancel → Editor Screen (uploads continue)
- Done → Editor Screen (uploads continue)
- After upload → Editor Screen (auto-return)

---

## **SCREEN 10: EXPORT STUDIO (CINEMATIC MODE)**

### **Purpose**
Dark theme video export interface

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  ×                    Export Video          │ ← Header (dark bg)
├─────────────────────────────────────────────┤
│                                             │
│          [Video Preview Player]             │ ← Preview area
│          ┌─────────────────────┐            │   (16:9 or 9:16)
│          │                     │            │
│          │  Trip Preview       │            │
│          │  [Play ▶]           │            │
│          │                     │            │
│          └─────────────────────┘            │
│                                             │
│  TEMPLATE                                   │ ← Section (H3, white)
│  [Classic] [Cinematic] [Minimal] [Story]    │ ← Template chips
│                                             │
│  SETTINGS                                   │
│  ┌───────────────────────────────────────┐ │
│  │ Format                        →       │ │ ← Settings list
│  │ Instagram Story (9:16)                │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Quality                       →       │ │
│  │ High (720p)                           │ │
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ Duration                      →       │ │
│  │ 15 seconds                            │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Generate Video]                           │ ← Accent button
│                                             │
└─────────────────────────────────────────────┘
```

**During Export:**
```
┌─────────────────────────────────────────────┐
│  Generating Your Video...                   │
│                                             │
│  ⏱️ Estimated time: 2 minutes                │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ ████████████░░░░░░░░ 60%              │ │ ← Progress bar
│  └───────────────────────────────────────┘ │
│                                             │
│  Processing...                              │
│  • Preparing timeline ✓                     │
│  • Rendering map frames...                  │
│  • Adding transitions                       │
│  • Encoding video                           │
│                                             │
│  [Cancel]                                   │
└─────────────────────────────────────────────┘
```

**Export Complete:**
```
┌─────────────────────────────────────────────┐
│  ✓ Video Ready!                             │
│                                             │
│  ┌─────────────────────┐                   │
│  │ [Video Thumbnail]   │                   │ ← Preview thumbnail
│  │ ▶ Play              │                   │
│  └─────────────────────┘                   │
│                                             │
│  15 sec · 8.5 MB                            │
│                                             │
│  [Share to Instagram]                       │ ← Primary action
│  [Share to TikTok]                          │
│  [Save to Gallery]                          │
│  [Share Other...]                           │
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Video Preview Player**
```dart
VideoPreviewPlayer(
  previewUrl: previewVideoUrl,
  aspectRatio: selectedFormat.aspectRatio,
  onPlay: () => playPreview(),
)
```
- Background: Black
- Controls: Play/pause only
- Aspect: Match selected format
- Auto-loop preview

---

**Template Chip**
```dart
TemplateChip(
  template: template,
  isSelected: selectedTemplate == template,
  onTap: () => selectTemplate(template),
)
```
- Height: 100px
- Shows preview thumbnail
- Selected: Accent border (2px)
- Label: Template name

**Templates:**
- **Classic:** Map + photos, simple transitions
- **Cinematic:** Parallax, smooth camera
- **Minimal:** Clean, fast cuts
- **Story:** Instagram-style vertical

---

**Settings List Item**
```dart
SettingsListItem(
  title: 'Format',
  value: 'Instagram Story (9:16)',
  onTap: () => showFormatPicker(),
)
```
- Background: `darkSurface`
- Border: `darkMuted` (1px)
- Arrow icon: →

---

### **Format Options**

**Format Picker (Bottom Sheet):**
```
┌─────────────────────────────────┐
│ Select Format                   │
│                                 │
│ [✓] Instagram Story (9:16)      │ ← Selected
│ [ ] Instagram Feed (1:1)        │
│ [ ] YouTube (16:9)              │
│ [ ] TikTok (9:16)               │
│                                 │
│ [Done]                          │
└─────────────────────────────────┘
```

**Quality Options:**
- Standard (480p) - Faster
- High (720p) - Recommended
- Ultra (1080p) - Slower

**Duration:**
- 10 seconds
- 15 seconds (default)
- 30 seconds
- 60 seconds

---

### **Export Flow**

**Step 1: Configure**
- Select template
- Choose format
- Set quality/duration
- Preview shows sample

**Step 2: Generate**
1. Tap [Generate Video]
2. Send job to backend:
   ```json
   POST /api/v1/trips/{trip_id}/export
   {
     "template": "classic",
     "aspect_ratio": "9:16",
     "duration": 15
   }
   ```
3. Receive job ID
4. Poll for status every 2 seconds

**Step 3: Processing**
- Show progress screen
- Backend renders video
- Status updates:
  - queued → processing → rendering → encoding → completed

**Step 4: Complete**
- Download video URL
- Show share options
- Allow replay/re-share

---

### **Interactions**

**Tap Template:**
- Select template
- Preview updates
- Highlight selected

**Tap Settings Item:**
- Show picker bottom sheet
- Select option
- Update preview

**Tap [Generate Video]:**
- Start export job
- Navigate to progress screen
- Background processing

**Tap [Cancel] (During Export):**
- Confirm:
  ```
  Cancel export?
  
  Your progress will be lost
  
  [Keep Generating] [Cancel]
  ```
- If confirmed → Cancel job

**Tap [Share to Instagram]:**
- Check if Instagram installed
- Open Instagram share sheet
- Pre-fill with video
- User posts from Instagram

**Tap [Save to Gallery]:**
- Download video
- Save to camera roll
- Toast: "Saved to gallery"

---

### **States**

**Loading Preview:**
```
┌─────────────────────────────────┐
│ [Shimmer video player]          │
│ Generating preview...           │
└─────────────────────────────────┘
```

**Export Queued:**
```
┌─────────────────────────────────┐
│ ⏳ Your video is in the queue   │
│ Estimated wait: 30 seconds      │
└─────────────────────────────────┘
```

**Export Failed:**
```
┌─────────────────────────────────┐
│ ⚠️ Export failed                │
│                                 │
│ Something went wrong            │
│ Please try again                │
│                                 │
│ [Retry] [Contact Support]       │
└─────────────────────────────────┘
```

---

### **Dora Personality**

**Header:**
> "Export Video"

**Processing:**
> "Generating Your Video..."
> "This is where the magic happens"

**Success:**
> "✓ Video Ready!"
> "Your journey is ready to share"

**Failed:**
> "Export failed"
> "Something went wrong. Please try again"

---

### **Navigation**

**From Export Studio:**
- × Close → Editor Screen
- After share → Editor Screen or Exit

---

## **SCREEN 11: TEMPLATE PICKER (MODAL)**

### **Purpose**
Select video template before export

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  [Drag handle]                              │
│                                             │
│  Choose Your Style                          │ ← H2 (white, dark mode)
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Preview GIF/Video - Classic]         │ │ ← Template card
│  │                                       │ │   (full width)
│  │ Classic                               │ │
│  │ Simple map journey with photos        │ │
│  │                              [Select] │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Preview GIF - Cinematic]             │ │
│  │                                       │ │
│  │ Cinematic                             │ │
│  │ Smooth camera, parallax effects       │ │
│  │                              [Select] │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Preview GIF - Minimal]               │ │
│  │                                       │ │
│  │ Minimal                               │ │
│  │ Clean, fast transitions               │ │
│  │                              [Select] │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ [Preview GIF - Story]                 │ │
│  │                                       │ │
│  │ Story                                 │ │
│  │ Instagram-style vertical format       │ │
│  │                              [Select] │ │
│  └───────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Template Descriptions**

**Classic:**
- Map-first layout
- Photos slide in at locations
- Simple fade transitions
- Good for: Multi-day trips, route focus

**Cinematic:**
- 3D camera movements
- Parallax photo effects
- Smooth easing
- Good for: Scenic trips, impressions

**Minimal:**
- Clean typography
- Fast cuts
- Photo emphasis
- Good for: City trips, food focus

**Story:**
- Vertical 9:16 format
- Instagram-optimized
- Text overlays
- Good for: Social sharing, quick posts

---

### **Interactions**

**Tap [Select]:**
- Select template
- Close modal
- Update Export Studio preview

**Swipe Down:**
- Dismiss modal
- Keep previous selection

---

### **Dora Personality**

**Header:**
> "Choose Your Style"

**Descriptions:**
> "Simple map journey with photos"
> "Smooth camera, parallax effects"

---

## **SCREEN 12: SHARE PREVIEW (POST-EXPORT)**

### **Purpose**
Final video preview with sharing options

---

### **Layout**

```
┌─────────────────────────────────────────────┐
│  ×                      Share               │ ← Header (dark)
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │                                       │ │ ← Video player
│  │  [Video Preview]                      │ │   (Full width)
│  │  ▶                                    │ │
│  │                                       │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  Iceland Road Trip                          │ ← H2, white
│  15 sec · 8.5 MB · 720p                    │ ← Caption, gray
│                                             │
│  SHARE TO                                   │
│  ┌───────────┬───────────┬───────────┐    │ ← Share buttons
│  │ Instagram │  TikTok   │   Copy    │    │   (3 columns)
│  │   📱      │    📱     │    🔗     │    │
│  └───────────┴───────────┴───────────┘    │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ Save to Gallery                       │ │ ← Button
│  └───────────────────────────────────────┘ │
│  ┌───────────────────────────────────────┐ │
│  │ More Options...                       │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Download Video]                           │ ← Link (small)
│                                             │
└─────────────────────────────────────────────┘
```

---

### **Component Breakdown**

**Share Platform Button**
```dart
SharePlatformButton(
  platform: Platform.instagram,
  icon: Icons.instagram,
  label: 'Instagram',
  onPressed: () => shareToInstagram(),
)
```
- Size: 100x100
- Background: `darkSurface`
- Icon: Platform logo (60px)
- Label: Platform name

---

### **Share Implementations**

**Instagram:**
```dart
void shareToInstagram() async {
  final file = await downloadVideo();
  await Share.shareXFiles(
    [XFile(file.path)],
    text: trip.name,
  );
}
```

**TikTok:**
- Similar to Instagram
- Use system share sheet
- TikTok auto-detected if installed

**Copy Link:**
```dart
void copyVideoLink() {
  Clipboard.setData(ClipboardData(text: videoUrl));
  showToast('Link copied');
}
```

---

### **Interactions**

**Tap Instagram:**
- Download video (if not cached)
- Open system share → Instagram
- User posts from Instagram app

**Tap TikTok:**
- Download video
- Open system share → TikTok

**Tap Copy Link:**
- Copy video URL to clipboard
- Toast: "Link copied"

**Tap Save to Gallery:**
- Download video
- Save to Photos/Gallery
- Request storage permission (if needed)
- Toast: "Saved to gallery"

**Tap More Options:**
- Open system share sheet
- Show all apps (WhatsApp, Twitter, etc.)

**Tap Download Video:**
- Direct download
- Save to Downloads folder
- Show in file manager

---

### **States**

**Downloading:**
```
┌─────────────────────────────────┐
│ Preparing video...              │
│ ████████░░ 80%                  │
└─────────────────────────────────┘
```

**Share Failed:**
```
┌─────────────────────────────────┐
│ ⚠️ Couldn't share               │
│ Please try again                │
│ [Retry]                         │
└─────────────────────────────────┘
```

---

### **Dora Personality**

**Header:**
> "Share"

**Success toast:**
> "Link copied"
> "Saved to gallery"

**Download:**
> "Preparing video..."

---

### **Navigation**

**From Share Preview:**
- × Close → Export Studio or Editor
- After share → Return to previous screen

---

## **✅ ALL 12 SCREENS COMPLETE**

---

## **📋 Screen Summary**

| # | Screen | Purpose | Key Features |
|---|--------|---------|--------------|
| 1 | Feed | Discovery | Public trips, search, ongoing banner |
| 2 | Search | Find & Plan | Places, AI advisor, templates |
| 3 | Trip Detail | Browse | Public trip view, save components |
| 4 | Pre-Create | Trip Setup | Form before editor |
| 5 | Editor | Creation | Map + timeline + tools workspace |
| 6 | My Trips | Library | User's trip collection |
| 7 | Profile | Account | Stats, settings, shared content |
| 8 | Place Search | Add Places | Search, GPS, categories |
| 9 | Media Upload | Photos | Camera, gallery, queue |
| 10 | Export Studio | Video Gen | Templates, settings, export |
| 11 | Template Picker | Choose Style | Video template selection |
| 12 | Share Preview | Distribution | Social sharing, download |

---

## **🎯 Next Steps**

**You now have:**
✅ Complete Flutter Architecture
✅ All 12 Screen Specifications