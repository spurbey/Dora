# 📱 **DORA FLUTTER ARCHITECTURE - v1.0**

## **Complete Technical Foundation**

---

## **📋 Document Purpose**

This is the **technical constitution** for Dora mobile app development.

**Treat this as law:**
- All Flutter code must follow these patterns
- All AI agents must reference this document
- Deviations require explicit approval
- PRDs will enforce these principles

**Audience:**
- You (founder/reviewer)
- AI coding agents (Claude Code, Cursor)
- Future developers

---

## **🎯 Architecture Principles**

### **1. Separation of Concerns**

```
Presentation Layer (UI)
    ↓ (uses)
Domain Layer (Business Logic)
    ↓ (uses)
Data Layer (API, DB, External Services)
```

**Rules:**
- UI never calls APIs directly
- Domain never imports Flutter widgets
- Data never contains business logic
- Each layer has single responsibility

---

### **2. Abstraction Over Implementation**

**Problem:** Dependencies change (Mapbox → Flutter Map, moviepy → FFmpeg, Supabase → S3)

**Solution:** Program to interfaces, not implementations

```dart
// ❌ WRONG - Tight coupling
import 'package:mapbox_gl/mapbox_gl.dart';

class TripMap extends StatelessWidget {
  final MapboxMapController controller; // Mapbox type leaks
}

// ✅ CORRECT - Abstraction
import 'package:dora/core/map/app_map_controller.dart';

class TripMap extends StatelessWidget {
  final AppMapController controller; // Interface
}
```

**Mandatory abstractions:**
- Map (Mapbox → any engine)
- Video (moviepy → FFmpeg)
- Storage (Supabase → S3/CDN)
- Queue (BackgroundTasks → Celery)

---

### **3. Offline-First by Default**

**Every feature assumes:**
- Network may be unavailable
- Data reads from local DB first
- Writes queue for background sync
- UI shows cached data immediately

**Pattern:**
```dart
// Repository pattern
class TripRepository {
  Future<Trip> getTrip(String id) async {
    // 1. Try local first
    final local = await _db.getTrip(id);
    if (local != null) return local;
    
    // 2. Fetch from API
    final remote = await _api.getTrip(id);
    
    // 3. Cache locally
    await _db.saveTrip(remote);
    
    return remote;
  }
}
```

---

### **4. Type Safety Everywhere**

**No dynamic types. No JSON maps. No stringly-typed code.**

```dart
// ❌ WRONG
Map<String, dynamic> trip = {'id': '123', 'name': 'Japan'};

// ✅ CORRECT
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String name,
    required DateTime createdAt,
  }) = _Trip;
  
  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
```

**Tools:**
- Freezed (immutable models)
- JSON serialization (code generation)
- OpenAPI generator (API models)

---

### **5. Immutability by Default**

**All models immutable. No mutable state.**

```dart
// ❌ WRONG - Mutable
class Trip {
  String name;
  void updateName(String newName) => name = newName;
}

// ✅ CORRECT - Immutable
@freezed
class Trip with _$Trip {
  const factory Trip({required String name}) = _Trip;
}

// Update via copyWith
final updated = trip.copyWith(name: 'New Name');
```

**Why:** Prevents bugs, enables time-travel debugging, works with Riverpod

---

## **📁 Folder Structure**

### **Complete Directory Tree**

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget (theme, navigation)
│
├── core/                              # Shared infrastructure
│   ├── theme/
│   │   ├── app_theme.dart            # Material 3 + Dora theme
│   │   ├── app_colors.dart           # Color tokens
│   │   ├── app_typography.dart       # Type scale
│   │   ├── app_spacing.dart          # 8pt grid tokens
│   │   ├── app_radius.dart           # Border radius tokens
│   │   └── app_shadows.dart          # Elevation system
│   │
│   ├── navigation/
│   │   ├── app_router.dart           # GoRouter setup
│   │   ├── routes.dart               # Route definitions
│   │   └── navigation_shell.dart     # Bottom tab scaffold
│   │
│   ├── map/                           # ⚠️ ABSTRACTION LAYER
│   │   ├── app_map_controller.dart   # Interface (abstract class)
│   │   ├── app_map_view.dart         # Widget wrapper
│   │   ├── adapters/
│   │   │   ├── mapbox_adapter.dart   # Mapbox implementation
│   │   │   └── flutter_map_adapter.dart  # Future implementation
│   │   └── models/
│   │       ├── app_latlng.dart       # Not LatLng from Mapbox
│   │       ├── app_marker.dart       # Not Marker from Mapbox
│   │       ├── app_route.dart        # Not Polyline from Mapbox
│   │       └── app_bounds.dart       # Not LatLngBounds from Mapbox
│   │
│   ├── network/
│   │   ├── api_client.dart           # Dio + interceptors
│   │   ├── api_exception.dart        # Custom exceptions
│   │   ├── retry_interceptor.dart    # Auto-retry logic
│   │   ├── auth_interceptor.dart     # JWT token injection
│   │   └── offline_queue.dart        # Request queue for offline
│   │
│   ├── storage/
│   │   ├── drift_database.dart       # SQLite schema
│   │   ├── tables/
│   │   │   ├── trips_table.dart
│   │   │   ├── places_table.dart
│   │   │   ├── routes_table.dart
│   │   │   └── media_table.dart
│   │   ├── daos/
│   │   │   ├── trip_dao.dart         # Trip queries
│   │   │   ├── place_dao.dart
│   │   │   └── route_dao.dart
│   │   ├── sync_manager.dart         # Optimistic sync
│   │   ├── conflict_resolver.dart    # Timestamp-based conflicts
│   │   └── cache_policy.dart         # Cache expiration
│   │
│   ├── media/
│   │   ├── image_compressor.dart     # Flutter image compression
│   │   ├── thumbnail_generator.dart  # Preview generation
│   │   ├── upload_queue.dart         # Background upload
│   │   └── media_cache.dart          # Local media storage
│   │
│   ├── video/                         # ⚠️ ABSTRACTION LAYER
│   │   ├── video_renderer.dart       # Interface
│   │   ├── export_queue.dart         # Interface
│   │   ├── storage_provider.dart     # Interface
│   │   └── adapters/
│   │       └── supabase_storage_adapter.dart  # v1 implementation
│   │
│   ├── location/
│   │   ├── location_service.dart     # GPS wrapper
│   │   └── location_permission.dart  # Permission handling
│   │
│   ├── auth/
│   │   ├── auth_service.dart         # Supabase auth wrapper
│   │   └── token_manager.dart        # JWT storage
│   │
│   ├── config/
│   │   ├── env_config.dart           # Environment variables
│   │   ├── feature_flags.dart        # Remote config
│   │   └── app_constants.dart        # Static constants
│   │
│   └── utils/
│       ├── logger.dart                # Structured logging
│       ├── validators.dart            # Form validation
│       └── formatters.dart            # Date, number formatting
│
├── features/                          # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_api.dart
│   │   ├── domain/
│   │   │   ├── user.dart             # Freezed model
│   │   │   └── auth_state.dart       # Riverpod state
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       ├── widgets/
│   │       │   └── auth_form.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── feed/
│   │   ├── data/
│   │   │   ├── feed_repository.dart
│   │   │   └── feed_api.dart
│   │   ├── domain/
│   │   │   ├── public_trip.dart
│   │   │   └── feed_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── feed_screen.dart
│   │       │   └── trip_detail_screen.dart
│   │       ├── widgets/
│   │       │   ├── trip_card.dart
│   │       │   ├── ongoing_trip_banner.dart
│   │       │   └── search_bar.dart
│   │       └── providers/
│   │           └── feed_provider.dart
│   │
│   ├── create/
│   │   ├── data/
│   │   │   └── trip_repository.dart
│   │   ├── domain/
│   │   │   ├── trip.dart
│   │   │   ├── place.dart
│   │   │   └── route.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── pre_create_screen.dart
│   │       │   ├── editor_screen.dart
│   │       │   ├── timeline_view.dart
│   │       │   └── map_view.dart
│   │       ├── widgets/
│   │       │   ├── timeline_item.dart
│   │       │   ├── map_tools.dart
│   │       │   ├── route_drawer.dart
│   │       │   └── place_search.dart
│   │       └── providers/
│   │           ├── editor_provider.dart
│   │           ├── timeline_provider.dart
│   │           └── map_provider.dart
│   │
│   ├── trips/
│   │   ├── data/
│   │   │   └── trips_repository.dart
│   │   ├── domain/
│   │   │   └── trip_list_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── my_trips_screen.dart
│   │       ├── widgets/
│   │       │   ├── trip_grid_item.dart
│   │       │   └── trip_filter.dart
│   │       └── providers/
│   │           └── trips_provider.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart
│   │   ├── domain/
│   │   │   └── profile.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── profile_screen.dart
│   │       └── providers/
│   │           └── profile_provider.dart
│   │
│   └── export/
│       ├── data/
│       │   ├── export_repository.dart
│       │   └── export_api.dart
│       ├── domain/
│       │   ├── export_job.dart
│       │   ├── video_template.dart
│       │   └── export_state.dart
│       └── presentation/
│           ├── screens/
│           │   ├── export_studio_screen.dart
│           │   ├── template_picker_screen.dart
│           │   └── preview_screen.dart
│           ├── widgets/
│           │   ├── template_card.dart
│           │   ├── export_progress.dart
│           │   └── share_sheet.dart
│           └── providers/
│               └── export_provider.dart
│
├── generated/                         # Code generation output
│   ├── api/                          # OpenAPI generated
│   │   ├── api.dart
│   │   ├── api_client.dart
│   │   └── models/
│   │       ├── trip_dto.dart
│   │       ├── place_dto.dart
│   │       └── ...
│   └── intl/                         # Localization (future)
│
└── shared/                            # Shared UI components
    ├── widgets/
    │   ├── dora_button.dart
    │   ├── dora_card.dart
    │   ├── dora_bottom_sheet.dart
    │   ├── loading_indicator.dart
    │   ├── error_view.dart
    │   └── empty_state.dart
    └── animations/
        ├── fade_transition.dart
        └── slide_transition.dart
```

---

## **🎨 Theme System Implementation**

### **Dora Theme Tokens**

**File: `lib/core/theme/app_colors.dart`**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor
  
  // Primary Palette
  static const primary = Color(0xFF86726B);
  static const surface = Color(0xFFF5F2EF);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF5F5F5F);
  static const divider = Color(0xFFE0DDD8);
  
  // Accent Palette
  static const accent = Color(0xFF1F6F78);
  static const accentSoft = Color(0xFFE6F2F3);
  
  // Dark Mode (Export/Studio)
  static const darkBg = Color(0xFF121212);
  static const darkSurface = Color(0xFF1C1C1C);
  static const darkText = Color(0xFFFFFFFF);
  static const darkMuted = Color(0xFF9A9A9A);
  
  // Semantic Colors
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFF59E0B);
}
```

---

**File: `lib/core/theme/app_spacing.dart`**

```dart
class AppSpacing {
  AppSpacing._();
  
  // 8pt Grid System
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Edge Insets shortcuts
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
}
```

---

**File: `lib/core/theme/app_typography.dart`**

```dart
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();
  
  static const String fontFamily = 'SF Pro Display';
  
  // Type Scale
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    fontFamily: fontFamily,
  );
}
```

---

**File: `lib/core/theme/app_radius.dart`**

```dart
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();
  
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  
  // BorderRadius shortcuts
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  
  // Top-only (for bottom sheets)
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
```

---

**File: `lib/core/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.surface,
      error: AppColors.error,
    ),
    
    scaffoldBackgroundColor: AppColors.surface,
    
    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      showDragHandle: true,
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        elevation: 0,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall: AppTypography.h3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.caption,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.accent),
      ),
    ),
  );
  
  // Dark Theme (Export Studio Mode)
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.darkSurface,
      background: AppColors.darkBg,
    ),
    
    scaffoldBackgroundColor: AppColors.darkBg,
    
    // Rest similar to light theme with dark colors
  );
}
```

---

## **🗺️ Map Abstraction Layer**

### **Why Abstraction Matters**

**Problem:**
- Mapbox licensing may change
- Performance issues may require engine swap
- Video export needs map rendering separate from UI

**Solution:** Never depend on Mapbox types directly

---

### **Architecture**

```
UI Layer (Editor, Timeline)
    ↓ uses
AppMapController (abstract interface)
    ↓ implements
MapboxAdapter | FlutterMapAdapter
    ↓ wraps
mapbox_gl | flutter_map
```

---

### **File: `lib/core/map/models/app_latlng.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_latlng.freezed.dart';
part 'app_latlng.g.json';

@freezed
class AppLatLng with _$AppLatLng {
  const factory AppLatLng({
    required double latitude,
    required double longitude,
  }) = _AppLatLng;
  
  factory AppLatLng.fromJson(Map<String, dynamic> json) => 
      _$AppLatLngFromJson(json);
}
```

---

### **File: `lib/core/map/models/app_marker.dart`**

```dart
@freezed
class AppMarker with _$AppMarker {
  const factory AppMarker({
    required String id,
    required AppLatLng position,
    String? title,
    String? snippet,
    String? iconAsset,
    Color? color,
    VoidCallback? onTap,
  }) = _AppMarker;
}
```

---

### **File: `lib/core/map/models/app_route.dart`**

```dart
@freezed
class AppRoute with _$AppRoute {
  const factory AppRoute({
    required String id,
    required List<AppLatLng> coordinates,
    Color? color,
    double? width,
    bool? dashed,
  }) = _AppRoute;
}
```

---

### **File: `lib/core/map/app_map_controller.dart`**

```dart
abstract class AppMapController {
  // Camera Control
  Future<void> flyTo(AppLatLng target, {double? zoom, Duration? duration});
  Future<void> fitBounds(AppLatLngBounds bounds, {EdgeInsets? padding});
  Future<AppLatLng> getCenter();
  Future<double> getZoom();
  
  // Markers
  Future<void> addMarker(AppMarker marker);
  Future<void> removeMarker(String id);
  Future<void> updateMarker(AppMarker marker);
  Future<void> clearMarkers();
  
  // Routes
  Future<void> addRoute(AppRoute route);
  Future<void> removeRoute(String id);
  Future<void> updateRoute(AppRoute route);
  Future<void> clearRoutes();
  
  // User Location
  Future<void> showUserLocation(bool show);
  Future<AppLatLng?> getUserLocation();
  
  // Gestures
  void enableRotation(bool enable);
  void enableTilt(bool enable);
  void enableZoom(bool enable);
  
  // Lifecycle
  void dispose();
}
```

---

### **File: `lib/core/map/adapters/mapbox_adapter.dart`**

```dart
import 'package:mapbox_gl/mapbox_gl.dart';
import '../app_map_controller.dart';
import '../models/app_latlng.dart';
import '../models/app_marker.dart';
import '../models/app_route.dart';

class MapboxAdapter implements AppMapController {
  final MapboxMapController _controller;
  final Map<String, Symbol> _markers = {};
  final Map<String, Line> _routes = {};
  
  MapboxAdapter(this._controller);
  
  @override
  Future<void> flyTo(AppLatLng target, {double? zoom, Duration? duration}) async {
    await _controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(target.latitude, target.longitude),
        zoom ?? 15.0,
      ),
      duration: duration ?? const Duration(milliseconds: 1000),
    );
  }
  
  @override
  Future<void> addMarker(AppMarker marker) async {
    final symbol = await _controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(marker.position.latitude, marker.position.longitude),
        iconImage: marker.iconAsset ?? 'default-marker',
        textField: marker.title,
      ),
    );
    _markers[marker.id] = symbol;
  }
  
  @override
  Future<void> addRoute(AppRoute route) async {
    final line = await _controller.addLine(
      LineOptions(
        geometry: route.coordinates.map((c) => 
          LatLng(c.latitude, c.longitude)
        ).toList(),
        lineColor: route.color?.toHex() ?? '#1F6F78',
        lineWidth: route.width ?? 4.0,
      ),
    );
    _routes[route.id] = line;
  }
  
  // ... implement all other methods
  
  @override
  void dispose() {
    _markers.clear();
    _routes.clear();
  }
}
```

**Key Point:** UI code NEVER imports `mapbox_gl`. Only this adapter does.

---

### **File: `lib/core/map/app_map_view.dart`**

```dart
class AppMapView extends StatefulWidget {
  final AppLatLng initialCenter;
  final double initialZoom;
  final void Function(AppMapController controller)? onMapCreated;
  final List<AppMarker>? markers;
  final List<AppRoute>? routes;
  
  const AppMapView({
    Key? key,
    required this.initialCenter,
    this.initialZoom = 12.0,
    this.onMapCreated,
    this.markers,
    this.routes,
  }) : super(key: key);
  
  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  AppMapController? _controller;
  
  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Env.mapboxToken,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.initialCenter.latitude,
          widget.initialCenter.longitude,
        ),
        zoom: widget.initialZoom,
      ),
      onMapCreated: (MapboxMapController controller) {
        _controller = MapboxAdapter(controller);
        widget.onMapCreated?.call(_controller!);
        
        // Add initial markers/routes
        if (widget.markers != null) {
          for (final marker in widget.markers!) {
            _controller!.addMarker(marker);
          }
        }
        if (widget.routes != null) {
          for (final route in widget.routes!) {
            _controller!.addRoute(route);
          }
        }
      },
    );
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

**Usage in Features:**

```dart
// ✅ CORRECT - Uses abstraction
AppMapView(
  initialCenter: AppLatLng(latitude: 35.6762, longitude: 139.6503),
  markers: [
    AppMarker(
      id: 'place-1',
      position: AppLatLng(latitude: 35.6762, longitude: 139.6503),
      title: 'Tokyo Tower',
    ),
  ],
  onMapCreated: (controller) {
    // Store controller in state
    // All operations through AppMapController interface
  },
)
```

---

## **💾 Offline-First Architecture**

### **Database Schema (Drift)**

**File: `lib/core/storage/tables/trips_table.dart`**

```dart
import 'package:drift/drift.dart';

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get visibility => text().withDefault(const Constant('private'))();
  
  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()(); // 'pending' | 'synced' | 'conflict'
  
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

---

### **File: `lib/core/storage/drift_database.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/trips_table.dart';
import 'tables/places_table.dart';
import 'tables/routes_table.dart';
import 'daos/trip_dao.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Trips, Places, Routes],
  daos: [TripDao, PlaceDao, RouteDao],
)
classAppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations
    },
  );
  
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'dora.db'));
      return NativeDatabase(file);
    });
  }
}
```

---

### **Repository Pattern with Offline**

**File: `lib/features/create/data/trip_repository.dart`**

```dart
class TripRepository {
  final AppDatabase _db;
  final TripApi _api;
  final SyncManager _syncManager;
  
  TripRepository(this._db, this._api, this._syncManager);
  
  /// Get trip (offline-first)
  Future<Trip?> getTrip(String id) async {
    // 1. Try local first
    final local = await _db.tripDao.getTrip(id);
    if (local != null) {
      // Return cached immediately
      _syncInBackground(id); // Refresh in background
      return _mapToModel(local);
    }
    
    // 2. Not cached, fetch from API
    try {
      final remote = await _api.getTrip(id);
      
      // 3. Cache for offline
      await _db.tripDao.insertTrip(remote);
      
      return remote;
    } catch (e) {
      // Network error, no cache available
      return null;
    }
  }
  
  /// Create trip (optimistic)
  Future<Trip> createTrip(Trip trip) async {
    final now = DateTime.now();
    final localTrip = trip.copyWith(
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
    
    // 1. Save locally immediately
    await _db.tripDao.insertTrip(localTrip);
    
    // 2. Queue sync (background)
    _syncManager.queueCreate(localTrip);
    
    // 3. Return immediately (optimistic)
    return localTrip;
  }
  
  /// Update trip (optimistic with conflict check)
  Future<Trip> updateTrip(Trip trip) async {
    final now = DateTime.now();
    
    // Check for conflicts
    final existing = await _db.tripDao.getTrip(trip.id);
    if (existing != null && 
        existing.serverUpdatedAt.isAfter(trip.localUpdatedAt)) {
      throw ConflictException('Server version is newer');
    }
    
    final updated = trip.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    
    // Save locally
    await _db.tripDao.updateTrip(updated);
    
    // Queue sync
    _syncManager.queueUpdate(updated);
    
    return updated;
  }
  
  void _syncInBackground(String id) {
    _syncManager.syncTrip(id);
  }
}
```

---

## **🔐 Authentication (Supabase)**

**File: `lib/core/auth/auth_service.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;
  
  AuthService(this._supabase);
  
  /// Current user stream
  Stream<User?> get authStateChanges => 
      _supabase.auth.onAuthStateChange.map((e) => e.session?.user);
  
  /// Current user
  User? get currentUser => _supabase.auth.currentUser;
  
  /// Sign in with email
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  /// Get access token for API
  Future<String?> getAccessToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }
}
```

---

**File: `lib/core/network/auth_interceptor.dart`**

```dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  
  AuthInterceptor(this._authService);
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

---

## **🌐 OpenAPI Integration**

### **Code Generation Setup**

**File: `pubspec.yaml`**

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  openapi_generator: ^7.2.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```

---

**File: `openapi-generator-config.yaml`**

```yaml
generatorName: dart-dio
inputSpec: http://localhost:8000/openapi.json  # Your backend
outputDir: lib/generated/api/
additionalProperties:
  pubName: dora_api
  useEnumExtension: true
  enumUnknownDefaultCase: true
```

---

**Generation Command:**

```bash
# 1. Ensure backend is running (serves OpenAPI spec)
# 2. Generate API client
flutter pub run build_runner build --delete-conflicting-outputs

# Or use openapi-generator directly
openapi-generator-cli generate -c openapi-generator-config.yaml
```

---

**Usage in Repository:**

```dart
import 'package:dora/generated/api/api.dart';

class TripRepository {
  final DefaultApi _api;
  
  Future<Trip> getTrip(String id) async {
    final dto = await _api.tripsIdGet(id);
    return Trip.fromDto(dto); // Convert DTO → Domain model
  }
}
```

**Key Point:** Generated models are DTOs, convert to domain models (Freezed)

---

## **🎬 Video Export Abstraction**

### **Interface Design**

**File: `lib/core/video/video_renderer.dart`**

```dart
abstract class VideoRenderer {
  /// Render trip to video frames
  Future<List<VideoFrame>> renderTrip(
    Trip trip,
    VideoTemplate template,
  );
  
  /// Encode frames to video file
  Future<File> encodeVideo(
    List<VideoFrame> frames,
    VideoExportConfig config,
  );
}

class VideoFrame {
  final Uint8List imageData;
  final Duration timestamp;
  
  VideoFrame(this.imageData, this.timestamp);
}

@freezed
class VideoExportConfig with _$VideoExportConfig {
  const factory VideoExportConfig({
    required int width,
    required int height,
    required int fps,
    required String codec,
    @Default(720) int quality,
  }) = _VideoExportConfig;
}
```

---

**File: `lib/core/video/export_queue.dart`**

```dart
abstract class ExportQueue {
  /// Submit export job
  Future<ExportJob> submitJob(String tripId, VideoTemplate template);
  
  /// Get job status
  Future<ExportJobStatus> getStatus(String jobId);
  
  /// Cancel job
  Future<void> cancelJob(String jobId);
  
  /// Stream job progress
  Stream<double> watchProgress(String jobId);
}

@freezed
class ExportJobStatus with _$ExportJobStatus {
  const factory ExportJobStatus({
    required String jobId,
    required String status, // 'queued' | 'processing' | 'completed' | 'failed'
    required double progress, // 0.0 - 1.0
    String? videoUrl,
    String? errorMessage,
  }) = _ExportJobStatus;
}
```

---

## **📡 State Management (Riverpod 2.x)**

### **Provider Patterns**

**File: `lib/features/create/presentation/providers/editor_provider.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_provider.g.dart';

@riverpod
class EditorController extends _$EditorController {
  @override
  EditorState build() {
    return const EditorState.initial();
  }
  
  void selectPlace(Place place) {
    state = state.copyWith(selectedPlace: place);
  }
  
  void addPlace(Place place) {
    final updated = [...state.places, place];
    state = state.copyWith(places: updated);
  }
  
  Future<void> saveTrip() async {
    state = state.copyWith(saving: true);
    
    final repo = ref.read(tripRepositoryProvider);
    await repo.updateTrip(state.trip);
    
    state = state.copyWith(saving: false);
  }
}

@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    required Trip trip,
    required List<Place> places,
    required List<Route> routes,
    Place? selectedPlace,
    @Default(false) bool saving,
  }) = _EditorState;
  
  const factory EditorState.initial() = _Initial;
}
```

**Usage:**

```dart
class EditorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorControllerProvider);
    final controller = ref.read(editorControllerProvider.notifier);
    
    return Scaffold(
      body: editorState.when(
        initial: () => const LoadingView(),
        data: (state) => EditorView(
          trip: state.trip,
          onAddPlace: controller.addPlace,
        ),
        error: (e, st) => ErrorView(error: e),
      ),
    );
  }
}
```

---

## **⚙️ Configuration & Environment**

**File: `lib/core/config/env_config.dart`**

```dart
class Env {
  Env._();
  
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  static const String mapboxToken = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue: '',
  );
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  
  static bool get isProduction => 
      const String.fromEnvironment('ENVIRONMENT') == 'production';
}
```

**Run with:**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=MAPBOX_TOKEN=pk.xxx \
  --dart-define=API_BASE_URL=https://api.dora.com
```

---

## **🧪 Testing Strategy**

### **Test Structure**

```
test/
├── unit/
│   ├── core/
│   │   ├── map/
│   │   │   └── mapbox_adapter_test.dart
│   │   └── storage/
│   │       └── sync_manager_test.dart
│   ├── features/
│   │   ├── create/
│   │   │   ├── trip_repository_test.dart
│   │   │   └── editor_controller_test.dart
│   │   └── export/
│   │       └── export_queue_test.dart
│   └── utils/
│       └── validators_test.dart
│
├── widget/
│   ├── shared/
│   │   ├── dora_button_test.dart
│   │   └── dora_card_test.dart
│   └── features/
│       ├── feed/
│       │   └── trip_card_test.dart
│       └── create/
│           └── timeline_item_test.dart
│
└── integration/
    └── trip_creation_flow_test.dart
```

---

### **Example Unit Test**

**File: `test/unit/features/create/trip_repository_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTripApi extends Mock implements TripApi {}
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('TripRepository', () {
    late TripRepository repository;
    late MockTripApi mockApi;
    late MockAppDatabase mockDb;
    
    setUp(() {
      mockApi = MockTripApi();
      mockDb = MockAppDatabase();
      repository = TripRepository(mockDb, mockApi, mockSyncManager);
    });
    
    test('getTrip returns cached data if available', () async {
      // Arrange
      final cachedTrip = Trip(id: '1', name: 'Japan');
      when(() => mockDb.tripDao.getTrip('1'))
          .thenAnswer((_) async => cachedTrip);
      
      // Act
      final result = await repository.getTrip('1');
      
      // Assert
      expect(result, cachedTrip);
      verifyNever(() => mockApi.getTrip('1')); // Should not hit API
    });
    
    test('getTrip fetches from API if not cached', () async {
      // Arrange
      when(() => mockDb.tripDao.getTrip('1'))
          .thenAnswer((_) async => null);
      when(() => mockApi.getTrip('1'))
          .thenAnswer((_) async => Trip(id: '1', name: 'Japan'));
      
      // Act
      final result = await repository.getTrip('1');
      
      // Assert
      expect(result?.name, 'Japan');
      verify(() => mockApi.getTrip('1')).called(1);
    });
  });
}
```

---

## **🔒 Critical Rules (Non-Negotiable)**

### **1. No Direct SDK Imports in Domain/Presentation**

```dart
// ❌ FORBIDDEN
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:supabase/supabase.dart';

class TripEditor extends StatelessWidget {
  final MapboxMapController controller; // BAD
}

// ✅ ALLOWED
import 'package:dora/core/map/app_map_controller.dart';

class TripEditor extends StatelessWidget {
  final AppMapController controller; // GOOD
}
```

---

### **2. All Theme Values from Tokens**

```dart
// ❌ FORBIDDEN
Container(
  color: Color(0xFF1F6F78),
  padding: EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(12),
)

// ✅ ALLOWED
Container(
  color: AppColors.accent,
  padding: AppSpacing.allMd,
  decoration: BoxDecoration(
    borderRadius: AppRadius.borderMd,
  ),
)
```

---

### **3. Freezed for All Models**

```dart
// ❌ FORBIDDEN
class Trip {
  String id;
  String name;
  
  Trip({required this.id, required this.name});
}

// ✅ ALLOWED
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String name,
  }) = _Trip;
  
  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
```

---

### **4. Repository Pattern Always**

```dart
// ❌ FORBIDDEN
class TripScreen extends StatelessWidget {
  void loadTrip() async {
    final response = await Dio().get('/trips/123'); // Direct API call
  }
}

// ✅ ALLOWED
class TripScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider('123')); // Through repository
  }
}
```

---

### **5. Offline Sync Metadata Required**

```dart
// Every synced model needs:
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    // ... business fields
    
    // Sync metadata (mandatory)
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus, // 'pending' | 'synced' | 'conflict'
  }) = _Trip;
}
```

---

## **📦 Dependencies (pubspec.yaml)**

```yaml
name: dora
description: Immersive travelogue creator
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Models & Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.1
  
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3
  
  # Networking
  dio: ^5.4.0
  
  # Auth
  supabase_flutter: ^2.0.0
  
  # Map
  mapbox_gl: ^0.16.0
  
  # Location
  geolocator: ^10.1.0
  
  # Media
  image_picker: ^1.0.0
  flutter_image_compress: ^2.1.0
  video_thumbnail: ^0.5.3
  
  # Storage
  shared_preferences: ^2.2.0
  
  # Analytics
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  sentry_flutter: ^7.13.0
  
  # UI
  go_router: ^12.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  drift_dev: ^2.14.0
  
  # Testing
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter
```

---

## **🚀 Getting Started**

### **1. Clone & Setup**

```bash
# Clone repo
git clone <repo-url>
cd dora-mobile

# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, Drift, OpenAPI)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **2. Environment Setup**

```bash
# Create .env file (NOT committed)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
MAPBOX_TOKEN=pk.xxx
API_BASE_URL=http://localhost:8000
```

---

### **3. Run Dev Server**

```bash
# Backend must be running for OpenAPI generation
cd ../backend
uvicorn main:app --reload

# Generate API client
cd ../mobile
flutter pub run build_runner build
```

---

### **4. Run App**

```bash
flutter run \
  --dart-define-from-file=.env
```

---

## **📚 Next Steps**

**With this architecture foundation, you're ready for:**

1. ✅ **Complete Screen Specifications** (12+ screens with wireframes)
2. ✅ **Flutter Phase 1 PRD** (Foundation - 4 weeks)
3. ✅ **Backend Phase A6 PRD** (Video Export Service)
4. ✅ **Flutter Phases 2-6 PRDs** (Feature development)

---

## **✅ Architecture Validation Checklist**

Before proceeding to implementation PRDs:

- [ ] Abstraction layers understood (Map, Video, Storage)
- [ ] Offline-first pattern clear
- [ ] Theme system tokens enforced
- [ ] Repository pattern mandatory
- [ ] Freezed for all models
- [ ] OpenAPI code generation setup
- [ ] Riverpod 2.x state management
- [ ] Drift database schema design
- [ ] Feature-based folder structure
- [ ] No direct SDK imports in domain

---

**END OF FLUTTER ARCHITECTURE DOCUMENT**

---

**Ready for next delivery: Complete Screen Specifications?**

**Proceed with: "Continue with screens"** 🎨