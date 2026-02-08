# Phase 2 PRD

## Notes (Additive)
- Search APIs require lat/lng: add `geolocator` and `core/location` service.
- OpenAPI client lives in `flutter/lib/generated/api` and should be imported via `package:dora_api/...` (path dependency in `flutter/pubspec.yaml`).

# **FLUTTER PHASE 2 PRD: FEED & DISCOVERY**

## **Complete Implementation Guide**

---

## **📋 Phase Overview**

**Phase ID:** Flutter Phase 2  
**Duration:** 3 weeks  
**Dependencies:** Phase 1 (Foundation complete), Backend Phase A complete  
**Goal:** Build discovery feed, search, and public trip viewing

---

## **🎯 Objectives**

**Primary Goal:**  
Users can discover public travelogues, search places, and view trip details.

**What Success Looks Like:**
- Feed loads public trips from backend
- Search works (places + AI suggestions)
- User can view trip details
- User can save places/trips
- Infinite scroll works
- Offline caching functional
- Pull to refresh works

**Phase 1 Foundation Used:**
- ✅ Theme system (all UI uses tokens)
- ✅ Navigation shell (Feed tab populated)
- ✅ Auth (protected routes)
- ✅ API client (fetch trips)
- ✅ Drift DB (cache trips)
- ✅ Riverpod (manage state)

---

## **🏗️ Architecture Alignment**

### **References Architecture Document:**
- Folder Structure (features/feed/)
- Offline-First Architecture (Repository pattern)
- State Management (Riverpod providers)
- OpenAPI Integration (use generated client)

### **References Screen Specifications:**
- Screen 1: Feed (Explore)
- Screen 2: Search (Planner + Advisor)
- Screen 3: Trip Detail (Public View)

### **References Design System:**
- Section 8: Component Rules (Cards, Buttons)
- Section 9: Navigation & Layout Rules

---

## **📁 Deliverables Overview**

**Files to Create: ~30 files**

```
lib/
├── features/
│   └── feed/
│       ├── data/
│       │   ├── feed_repository.dart
│       │   ├── feed_api.dart
│       │   └── models/
│       │       ├── public_trip.dart
│       │       └── trip_filter.dart
│       ├── domain/
│       │   └── feed_state.dart
│       └── presentation/
│           ├── screens/
│           │   ├── feed_screen.dart
│           │   ├── search_screen.dart
│           │   └── trip_detail_screen.dart
│           ├── widgets/
│           │   ├── trip_card.dart
│           │   ├── ongoing_trip_banner.dart
│           │   ├── search_bar_widget.dart
│           │   ├── place_search_result.dart
│           │   ├── timeline_place_item.dart
│           │   ├── timeline_route_item.dart
│           │   └── empty_state.dart
│           └── providers/
│               ├── feed_provider.dart
│               ├── search_provider.dart
│               └── trip_detail_provider.dart
│
├── core/
│   └── storage/
│       └── tables/
│           └── public_trips_table.dart  (new)
│
└── shared/
    └── widgets/
        ├── loading_indicator.dart  (new)
        └── error_view.dart  (new)
```

---

## **🔧 WEEK 1: FEED SCREEN**

### **Goal:** User sees public trip feed with infinite scroll

---

### **W1.1: Data Layer - Models & Repository**

**Create files:**

**1. lib/features/feed/data/models/public_trip.dart**

**Requirements:**
- Freezed model for public trip
- Fields: id, name, description, coverPhotoUrl, userId, username, placeCount, duration, tags, visibility, viewCount, createdAt
- JSON serialization
- Sync metadata (for offline cache)

**Reference:** Architecture Doc (Freezed models), Screen Spec #1 (Trip Card data)

**Pattern:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_trip.freezed.dart';
part 'public_trip.g.dart';

@freezed
class PublicTrip with _$PublicTrip {
  const factory PublicTrip({
    required String id,
    required String name,
    String? description,
    String? coverPhotoUrl,
    required String userId,
    required String username,
    required int placeCount,
    int? duration, // days
    @Default([]) List<String> tags,
    @Default('public') String visibility,
    @Default(0) int viewCount,
    required DateTime createdAt,
    
    // Sync metadata
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('synced') String syncStatus,
  }) = _PublicTrip;
  
  factory PublicTrip.fromJson(Map<String, dynamic> json) => 
      _$PublicTripFromJson(json);
}
```

---

**2. lib/features/feed/data/models/trip_filter.dart**

**Requirements:**
- Filter options for feed
- Duration, budget, travel style

**Pattern:**
```dart
@freezed
class TripFilter with _$TripFilter {
  const factory TripFilter({
    String? duration, // '1-day', '3-days', '1-week', '2-weeks+'
    String? budget, // 'budget', 'mid-range', 'luxury'
    String? travelStyle, // 'adventure', 'relaxed', 'cultural'
  }) = _TripFilter;
  
  factory TripFilter.empty() => const TripFilter();
}
```

---

**3. lib/core/storage/tables/public_trips_table.dart**

**Requirements:**
- Drift table for caching public trips
- Mirror PublicTrip model
- Sync metadata columns

**Reference:** Architecture Doc (Offline-First Architecture)

**Pattern:**
```dart
import 'package:drift/drift.dart';

class PublicTrips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverPhotoUrl => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  IntColumn get placeCount => integer()();
  IntColumn get duration => integer().nullable()();
  TextColumn get tags => text().map(const TagsConverter())(); // JSON array
  TextColumn get visibility => text().withDefault(const Constant('public'))();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();
  
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Converter for tags array
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();
  
  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List).cast<String>();
  }
  
  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}
```

**Update:** `lib/core/storage/drift_database.dart`
- Add `PublicTrips` to tables list
- Run code generation after

---

**4. lib/features/feed/data/feed_api.dart**

**Requirements:**
- Use OpenAPI generated client
- Methods: `getPublicTrips`, `getTripById`, `searchTrips`
- Pagination support
- Filter support

**Reference:** Architecture Doc (OpenAPI Integration)

**Pattern:**
```dart
import 'package:dora/generated/api/api.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';

class FeedApi {
  final DefaultApi _api;
  
  FeedApi(this._api);
  
  /// Get public trips feed (paginated)
  Future<List<PublicTrip>> getPublicTrips({
    int page = 1,
    int limit = 10,
    TripFilter? filter,
  }) async {
    try {
      final response = await _api.tripsPublicGet(
        page: page,
        limit: limit,
        duration: filter?.duration,
        budget: filter?.budget,
        travelStyle: filter?.travelStyle,
      );
      
      // Convert DTOs to domain models
      return response.data!.map((dto) => PublicTrip.fromJson(dto.toJson())).toList();
    } catch (e) {
      throw FeedApiException('Failed to fetch trips: $e');
    }
  }
  
  /// Get single trip by ID
  Future<PublicTrip> getTripById(String id) async {
    try {
      final response = await _api.tripsIdGet(id);
      return PublicTrip.fromJson(response.toJson());
    } catch (e) {
      throw FeedApiException('Failed to fetch trip: $e');
    }
  }
  
  /// Search trips by query
  Future<List<PublicTrip>> searchTrips(String query, {int limit = 20}) async {
    try {
      final response = await _api.tripsSearchGet(query: query, limit: limit);
      return response.data!.map((dto) => PublicTrip.fromJson(dto.toJson())).toList();
    } catch (e) {
      throw FeedApiException('Failed to search trips: $e');
    }
  }
}

class FeedApiException implements Exception {
  final String message;
  FeedApiException(this.message);
}
```

---

**5. lib/features/feed/data/feed_repository.dart**

**Requirements:**
- Offline-first pattern
- Try local DB first, then API
- Cache API responses
- Pagination logic
- Filter application

**Reference:** Architecture Doc (Offline-First Architecture, Repository Pattern)

**Pattern:**
```dart
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/feed/data/feed_api.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';

class FeedRepository {
  final AppDatabase _db;
  final FeedApi _api;
  
  FeedRepository(this._db, this._api);
  
  /// Get public trips (offline-first)
  Future<List<PublicTrip>> getPublicTrips({
    int page = 1,
    int limit = 10,
    TripFilter? filter,
    bool forceRefresh = false,
  }) async {
    // If force refresh, skip cache
    if (!forceRefresh) {
      // Try local cache first
      final cached = await _db.publicTripsDao.getTrips(
        page: page,
        limit: limit,
        filter: filter,
      );
      
      if (cached.isNotEmpty && page == 1) {
        // Return cache immediately for page 1
        // Refresh in background
        _refreshInBackground(filter);
        return cached;
      }
    }
    
    // Fetch from API
    try {
      final trips = await _api.getPublicTrips(
        page: page,
        limit: limit,
        filter: filter,
      );
      
      // Cache for offline
      if (page == 1) {
        // Clear old cache for page 1
        await _db.publicTripsDao.clearAll();
      }
      await _db.publicTripsDao.insertTrips(trips);
      
      return trips;
    } catch (e) {
      // Network error, return cache if available
      final cached = await _db.publicTripsDao.getTrips(
        page: page,
        limit: limit,
        filter: filter,
      );
      
      if (cached.isNotEmpty) {
        return cached;
      }
      
      rethrow;
    }
  }
  
  /// Get single trip (offline-first)
  Future<PublicTrip?> getTripById(String id) async {
    // Try local first
    final local = await _db.publicTripsDao.getTripById(id);
    if (local != null) {
      // Refresh in background
      _refreshTripInBackground(id);
      return local;
    }
    
    // Fetch from API
    try {
      final trip = await _api.getTripById(id);
      
      // Cache
      await _db.publicTripsDao.insertTrip(trip);
      
      return trip;
    } catch (e) {
      return null;
    }
  }
  
  /// Search trips
  Future<List<PublicTrip>> searchTrips(String query) async {
    try {
      final trips = await _api.searchTrips(query);
      return trips;
    } catch (e) {
      throw FeedRepositoryException('Search failed: $e');
    }
  }
  
  void _refreshInBackground(TripFilter? filter) {
    // Fire and forget
    _api.getPublicTrips(page: 1, limit: 10, filter: filter).then((trips) {
      _db.publicTripsDao.clearAll();
      _db.publicTripsDao.insertTrips(trips);
    }).catchError((_) {});
  }
  
  void _refreshTripInBackground(String id) {
    _api.getTripById(id).then((trip) {
      _db.publicTripsDao.insertTrip(trip);
    }).catchError((_) {});
  }
}

class FeedRepositoryException implements Exception {
  final String message;
  FeedRepositoryException(this.message);
}
```

**Also create:** `lib/core/storage/daos/public_trips_dao.dart`
- DAO with CRUD operations for PublicTrips table
- Query methods for filtering, pagination

---

### **W1.2: Domain Layer - State Management**

**Create files:**

**6. lib/features/feed/domain/feed_state.dart**

**Requirements:**
- Freezed state classes
- Loading, data, error states
- Pagination state

**Pattern:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';

part 'feed_state.freezed.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    @Default([]) List<PublicTrip> trips,
    @Default(1) int currentPage,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    TripFilter? filter,
  }) = _FeedState;
}
```

---

**7. lib/features/feed/presentation/providers/feed_provider.dart**

**Requirements:**
- Riverpod AsyncNotifier
- Load trips with pagination
- Pull to refresh
- Apply filters
- Handle loading/error states

**Reference:** Architecture Doc (State Management - Riverpod 2.x)

**Pattern:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dora/features/feed/data/feed_repository.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';
import 'package:dora/features/feed/domain/feed_state.dart';

part 'feed_provider.g.dart';

@riverpod
class FeedController extends _$FeedController {
  static const _pageSize = 10;
  
  @override
  Future<FeedState> build() async {
    final repository = ref.watch(feedRepositoryProvider);
    
    // Load initial page
    final trips = await repository.getPublicTrips(page: 1, limit: _pageSize);
    
    return FeedState(
      trips: trips,
      currentPage: 1,
      hasMore: trips.length >= _pageSize,
    );
  }
  
  /// Load next page
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }
    
    // Set loading state
    state = AsyncData(currentState.copyWith(isLoadingMore: true));
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      final nextPage = currentState.currentPage + 1;
      
      final moreTrips = await repository.getPublicTrips(
        page: nextPage,
        limit: _pageSize,
        filter: currentState.filter,
      );
      
      state = AsyncData(FeedState(
        trips: [...currentState.trips, ...moreTrips],
        currentPage: nextPage,
        hasMore: moreTrips.length >= _pageSize,
        isLoadingMore: false,
        filter: currentState.filter,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  /// Refresh feed (pull to refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      final trips = await repository.getPublicTrips(
        page: 1,
        limit: _pageSize,
        forceRefresh: true,
      );
      
      state = AsyncData(FeedState(
        trips: trips,
        currentPage: 1,
        hasMore: trips.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  /// Apply filter
  Future<void> applyFilter(TripFilter filter) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      final trips = await repository.getPublicTrips(
        page: 1,
        limit: _pageSize,
        filter: filter,
      );
      
      state = AsyncData(FeedState(
        trips: trips,
        currentPage: 1,
        hasMore: trips.length >= _pageSize,
        filter: filter,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
FeedRepository feedRepository(FeedRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(feedApiProvider);
  return FeedRepository(db, api);
}

@riverpod
FeedApi feedApi(FeedApiRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedApi(apiClient.api);
}
```

---

### **W1.3: Presentation Layer - Widgets**

**Create files:**

**8. lib/shared/widgets/loading_indicator.dart**

**Requirements:**
- Reusable loading widget
- Uses accent color
- Centered by default

**Reference:** Design System (accent color)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:dora/core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  
  const LoadingIndicator({Key? key, this.size = 48.0}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }
}
```

---

**9. lib/shared/widgets/error_view.dart**

**Requirements:**
- Show error icon + message
- Retry button
- Uses Dora microcopy

**Reference:** Screen Spec #1 (Error State), Design System (Dora personality)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorView({
    Key? key,
    this.message = "Couldn't load travelogues",
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Check your connection\nand try again',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: onRetry,
                child: Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

**10. lib/features/feed/presentation/widgets/trip_card.dart**

**Requirements:**
- Match Screen Spec #1 layout exactly
- Cover image (335x200)
- Trip name, meta, author
- Tap navigation
- Shadow, rounded corners

**Reference:** Screen Spec #1 (Trip Card component), Design System (Card theme)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';

class TripCard extends StatelessWidget {
  final PublicTrip trip;
  final VoidCallback onTap;
  
  const TripCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 335,
        margin: AppSpacing.verticalMd,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: CachedNetworkImage(
                imageUrl: trip.coverPhotoUrl ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: Center(child: LoadingIndicator(size: 24)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Name
                  Text(
                    trip.name,
                    style: AppTypography.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  
                  // Meta
                  Text(
                    '📸 ${trip.placeCount} places${trip.duration != null ? " · ${trip.duration} days" : ""}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  
                  // Author
                  Text(
                    'by @${trip.username}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**11. lib/features/feed/presentation/widgets/empty_state.dart**

**Requirements:**
- Center-aligned
- Icon, title, description, CTA button
- Dora microcopy

**Reference:** Screen Spec #1 (Empty State)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  
  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### **W1.4: Presentation Layer - Feed Screen**

**Create files:**

**12. lib/features/feed/presentation/screens/feed_screen.dart**

**Requirements:**
- Match Screen Spec #1 layout
- Header with search bar
- Infinite scroll (detect 85% scroll)
- Pull to refresh
- Filter button
- Trip cards
- Empty/loading/error states
- Navigate to search on tap search bar

**Reference:** Screen Spec #1 (Complete layout)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/features/feed/presentation/providers/feed_provider.dart';
import 'package:dora/features/feed/presentation/widgets/trip_card.dart';
import 'package:dora/features/feed/presentation/widgets/empty_state.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';
import 'package:dora/shared/widgets/error_view.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }
  
  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Feed Content
            Expanded(
              child: feedState.when(
                data: (state) => _buildFeedContent(state),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => ErrorView(
                  onRetry: () => ref.refresh(feedControllerProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: AppSpacing.horizontalMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dora', style: AppTypography.h1),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.tune),
                    onPressed: _showFilters,
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => context.push(Routes.search),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          
          // Search Bar (tap to navigate)
          GestureDetector(
            onTap: () => context.push(Routes.search),
            child: Container(
              height: 56,
              padding: AppSpacing.horizontalMd,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.explore, color: AppColors.accent),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Plan, advise, or search...',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedContent(FeedState state) {
    if (state.trips.isEmpty) {
      return EmptyState(
        icon: Icons.public,
        title: 'No travelogues yet',
        description: 'Be the first to share\nyour journey!',
        buttonText: 'Create Your First Trip',
        onButtonPressed: () => context.go(Routes.create),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
      color: AppColors.accent,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.allMd,
        itemCount: state.trips.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.trips.length) {
            // Loading more indicator
            return Padding(
              padding: AppSpacing.allMd,
              child: const LoadingIndicator(size: 24),
            );
          }
          
          final trip = state.trips[index];
          return Center(
            child: TripCard(
              trip: trip,
              onTap: () => context.push('${Routes.tripDetail}/${trip.id}'),
            ),
          );
        },
      ),
    );
  }
  
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(),
    );
  }
}
```

---

### **Week 1 Checkpoint:**

**Deliverable:**
- Feed screen functional
- Public trips load from API
- Trips cached in Drift DB
- Infinite scroll works
- Pull to refresh works
- Empty state shows
- Error handling works
- Tap trip card navigates (to placeholder)

**Test:**
```bash
flutter run

# Should see:
# - Feed loads trips
# - Scroll down → loads more
# - Pull down → refreshes
# - Tap card → navigates
# - Airplane mode → shows cached trips
```

---

## **🔧 WEEK 2: SEARCH & PLACE DISCOVERY**

### **Goal:** User can search places and get AI suggestions

---

### **W2.1: Search Data Layer**

**Create files:**

**13. lib/features/feed/data/models/place_search_result.dart**

**Requirements:**
- Freezed model for place results
- Support Foursquare/Google Places format

**Pattern:**
```dart
@freezed
class PlaceSearchResult with _$PlaceSearchResult {
  const factory PlaceSearchResult({
    required String id,
    required String name,
    required String category,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    String? priceLevel, // '$', '$$', '$$$'
    String? photoUrl,
  }) = _PlaceSearchResult;
  
  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) => 
      _$PlaceSearchResultFromJson(json);
}
```

---

**14. Add to feed_api.dart: Search methods**

```dart
// Add to FeedApi class:

/// Search places (Foursquare/Google)
Future<List<PlaceSearchResult>> searchPlaces(String query) async {
  try {
    final response = await _api.placesSearchGet(query: query);
    return response.data!.map((dto) => 
      PlaceSearchResult.fromJson(dto.toJson())
    ).toList();
  } catch (e) {
    throw FeedApiException('Failed to search places: $e');
  }
}

/// Get nearby places
Future<List<PlaceSearchResult>> getNearbyPlaces({
  required double latitude,
  required double longitude,
  double radius = 1000, // meters
}) async {
  try {
    final response = await _api.placesNearbyGet(
      lat: latitude,
      lng: longitude,
      radius: radius,
    );
    return response.data!.map((dto) => 
      PlaceSearchResult.fromJson(dto.toJson())
    ).toList();
  } catch (e) {
    throw FeedApiException('Failed to get nearby places: $e');
  }
}
```

---

### **W2.2: Search State Management**

**15. lib/features/feed/presentation/providers/search_provider.dart**

**Requirements:**
- Search state management
- Debounced search (300ms)
- Recent searches (local storage)
- Quick actions

**Pattern:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dora/features/feed/data/feed_repository.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_provider.g.dart';

@riverpod
class SearchController extends _$SearchController {
  static const _maxRecentSearches = 10;
  Timer? _debounce;
  
  @override
  Future<SearchState> build() async {
    final recent = await _loadRecentSearches();
    return SearchState(recentSearches: recent);
  }
  
  /// Execute search (debounced)
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncLoading();
      
      try {
        final repository = ref.read(feedRepositoryProvider);
        
        // Search both places and trips
        final places = await repository.searchPlaces(query);
        final trips = await repository.searchTrips(query);
        
        state = AsyncData(SearchState(
          query: query,
          places: places,
          trips: trips,
          recentSearches: state.value?.recentSearches ?? [],
        ));
        
        // Save to recent
        await _saveRecentSearch(query);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }
  
  /// Get nearby places (GPS)
  Future<void> searchNearby(double lat, double lng) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      final places = await repository.getNearbyPlaces(
        latitude: lat,
        longitude: lng,
      );
      
      state = AsyncData(SearchState(
        query: 'Nearby',
        places: places,
        recentSearches: state.value?.recentSearches ?? [],
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  Future<List<String>> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }
  
  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await _loadRecentSearches();
    
    // Add to front, remove duplicates, limit to max
    recent.remove(query);
    recent.insert(0, query);
    if (recent.length > _maxRecentSearches) {
      recent.removeLast();
    }
    
    await prefs.setStringList('recent_searches', recent);
    
    // Update state
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(recentSearches: recent));
    }
  }
  
  void clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(recentSearches: []));
    }
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    String? query,
    @Default([]) List<PlaceSearchResult> places,
    @Default([]) List<PublicTrip> trips,
    @Default([]) List<String> recentSearches,
  }) = _SearchState;
}
```

---

### **W2.3: Search UI Widgets**

**16. lib/features/feed/presentation/widgets/place_search_result.dart**

**Requirements:**
- Place result card
- Name, category, location, rating
- Add button
- Tap for details

**Reference:** Screen Spec #2 (Place Search Result)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';

class PlaceSearchResultCard extends StatelessWidget {
  final PlaceSearchResult place;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  
  const PlaceSearchResultCard({
    Key? key,
    required this.place,
    this.onTap,
    this.onAdd,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.place, color: AppColors.accent),
      title: Text(place.name, style: AppTypography.h3),
      subtitle: Text(
        '${place.category}${place.address != null ? " · ${place.address}" : ""}',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onAdd != null
          ? OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(60, 36),
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('+ Add'),
            )
          : null,
    );
  }
}
```

---

### **W2.4: Search Screen**

**17. lib/features/feed/presentation/screens/search_screen.dart**

**Requirements:**
- Match Screen Spec #2 layout
- Auto-focus search input
- Quick actions (Find Places, Ask Dora, Plan Trip)
- Recent searches
- Live search results
- Place results
- Trip results
- Dora AI suggestion

**Reference:** Screen Spec #2 (Complete layout)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/features/feed/presentation/providers/search_provider.dart';
import 'package:dora/features/feed/presentation/widgets/place_search_result.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(searchControllerProvider.notifier).clearRecent();
            },
            child: Text('Clear'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: AppSpacing.horizontalMd,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Type to search or ask...',
                prefixIcon: Icon(Icons.search, color: AppColors.accent),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderMd,
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderMd,
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  ref.read(searchControllerProvider.notifier).search(query);
                }
              },
            ),
          ),
        ),
      ),
      body: searchState.when(
        data: (state) {
          if (state.query == null || state.query!.isEmpty) {
            return _buildEmptyState(state);
          }
          return _buildSearchResults(state);
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, st) => ErrorView(
          message: 'Search failed',
          onRetry: () => ref.refresh(searchControllerProvider),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(SearchState state) {
    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Text(
            'QUICK ACTIONS',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              Chip(
                label: Text('📍 Find Places'),
                backgroundColor: AppColors.accentSoft,
                onDeleted: () {}, // Dummy to show it's tappable
                deleteIcon: SizedBox.shrink(),
              ),
              Chip(
                label: Text('🤖 Ask Dora'),
                backgroundColor: AppColors.accentSoft,
                onDeleted: () {},
                deleteIcon: SizedBox.shrink(),
              ),
              Chip(
                label: Text('🎯 Plan Trip'),
                backgroundColor: AppColors.accentSoft,
                onDeleted: () {},
                deleteIcon: SizedBox.shrink(),
              ),
            ],
          ),
          
          // Recent Searches
          if (state.recentSearches.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              'RECENT SEARCHES',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...state.recentSearches.map((search) => ListTile(
              leading: Icon(Icons.history, color: AppColors.textSecondary),
              title: Text(search),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () {
                  // Remove individual search
                },
              ),
              onTap: () {
                _searchController.text = search;
                ref.read(searchControllerProvider.notifier).search(search);
              },
            )),
          ],
          
          // Suggestions
          SizedBox(height: AppSpacing.lg),
          Text(
            'SUGGESTIONS',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildSuggestionItem('Hidden gems in Paris'),
          _buildSuggestionItem('Weekend trips from London'),
          _buildSuggestionItem('Budget travel Southeast Asia'),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionItem(String suggestion) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        '• $suggestion',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: () {
        _searchController.text = suggestion;
        ref.read(searchControllerProvider.notifier).search(suggestion);
      },
    );
  }
  
  Widget _buildSearchResults(SearchState state) {
    final hasPlaces = state.places.isNotEmpty;
    final hasTrips = state.trips.isNotEmpty;
    
    if (!hasPlaces && !hasTrips) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No results for "${state.query}"',
        description: 'Try different keywords',
      );
    }
    
    return ListView(
      padding: AppSpacing.allMd,
      children: [
        // Places Section
        if (hasPlaces) ...[
          Text(
            'PLACES (${state.places.length})',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ...state.places.take(5).map((place) => PlaceSearchResultCard(
            place: place,
            onTap: () {
              // Show place details bottom sheet
              _showPlaceDetails(context, place);
            },
            onAdd: () {
              // Add to trip (future: trip selector)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added to trip')),
              );
            },
          )),
          SizedBox(height: AppSpacing.lg),
        ],
        
        // Trips Section
        if (hasTrips) ...[
          Text(
            'TRIPS (${state.trips.length})',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ...state.trips.take(5).map((trip) => ListTile(
            leading: Icon(Icons.map, color: AppColors.accent),
            title: Text(trip.name),
            subtitle: Text('by @${trip.username} · ${trip.placeCount} places'),
            onTap: () => context.push('/trip/${trip.id}'),
          )),
        ],
      ],
    );
  }
  
  void _showPlaceDetails(BuildContext context, PlaceSearchResult place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }
}
```

---

### **Week 2 Checkpoint:**

**Deliverable:**
- Search screen functional
- Place search works (Foursquare/Google)
- Trip search works
- Recent searches saved
- Quick actions visible
- Results grouped correctly
- Empty state shows

**Test:**
```bash
# 1. Tap search bar on Feed
# 2. Search "tokyo restaurants"
# 3. See place results
# 4. Tap place → See details
# 5. Clear search → See recent
```

---

## **🔧 WEEK 3: TRIP DETAIL VIEW**

### **Goal:** User can view public trip details, save places/routes

---

### **W3.1: Trip Detail Data Layer**

**18. Add to feed_repository.dart: Trip detail methods**

```dart
// Add to FeedRepository class:

/// Get trip with full details (places, routes, photos)
Future<TripDetailData> getTripDetail(String id) async {
  try {
    // Fetch trip
    final trip = await getTripById(id);
    if (trip == null) {
      throw FeedRepositoryException('Trip not found');
    }
    
    // Fetch places
    final places = await _api.getTripPlaces(id);
    
    // Fetch routes
    final routes = await _api.getTripRoutes(id);
    
    return TripDetailData(
      trip: trip,
      places: places,
      routes: routes,
    );
  } catch (e) {
    throw FeedRepositoryException('Failed to load trip: $e');
  }
}

/// Copy trip to user's collection
Future<void> copyTrip(String tripId) async {
  try {
    await _api.copyTrip(tripId);
  } catch (e) {
    throw FeedRepositoryException('Failed to copy trip: $e');
  }
}

/// Save place to user's trip
Future<void> savePlace(String placeId, String userTripId) async {
  try {
    await _api.savePlaceToTrip(placeId, userTripId);
  } catch (e) {
    throw FeedRepositoryException('Failed to save place: $e');
  }
}
```

**19. Create model: lib/features/feed/data/models/trip_detail_data.dart**

```dart
@freezed
class TripDetailData with _$TripDetailData {
  const factory TripDetailData({
    required PublicTrip trip,
    required List<TripPlace> places,
    required List<TripRoute> routes,
  }) = _TripDetailData;
}

@freezed
class TripPlace with _$TripPlace {
  const factory TripPlace({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? visitTime, // 'morning', 'afternoon', 'evening'
    int? dayNumber,
    int? orderIndex,
    @Default([]) List<String> photoUrls,
  }) = _TripPlace;
  
  factory TripPlace.fromJson(Map<String, dynamic> json) => 
      _$TripPlaceFromJson(json);
}

@freezed
class TripRoute with _$TripRoute {
  const factory TripRoute({
    required String id,
    required List<AppLatLng> coordinates,
    String? transportMode, // 'car', 'bike', 'walk', 'air'
    double? distance, // km
    int? duration, // minutes
    int? dayNumber,
  }) = _TripRoute;
  
  factory TripRoute.fromJson(Map<String, dynamic> json) => 
      _$TripRouteFromJson(json);
}
```

---

### **W3.2: Trip Detail State Management**

**20. lib/features/feed/presentation/providers/trip_detail_provider.dart**

**Requirements:**
- Load trip with places/routes
- Tab state (Timeline, Map, Photos)
- Save place action
- Copy trip action

**Pattern:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dora/features/feed/data/feed_repository.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

part 'trip_detail_provider.g.dart';

@riverpod
class TripDetailController extends _$TripDetailController {
  @override
  Future<TripDetailState> build(String tripId) async {
    final repository = ref.watch(feedRepositoryProvider);
    final data = await repository.getTripDetail(tripId);
    
    return TripDetailState(
      data: data,
      currentTab: 0, // Timeline
    );
  }
  
  void setTab(int index) {
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(currentTab: index));
    }
  }
  
  Future<void> copyTrip() async {
    if (state.value == null) return;
    
    try {
      final repository = ref.read(feedRepositoryProvider);
      await repository.copyTrip(state.value!.data.trip.id);
      
      // Show success (handled by UI)
    } catch (e) {
      // Show error
      rethrow;
    }
  }
  
  Future<void> savePlace(String placeId, String userTripId) async {
    try {
      final repository = ref.read(feedRepositoryProvider);
      await repository.savePlace(placeId, userTripId);
      
      // Show success
    } catch (e) {
      rethrow;
    }
  }
}

@freezed
class TripDetailState with _$TripDetailState {
  const factory TripDetailState({
    required TripDetailData data,
    @Default(0) int currentTab, // 0: Timeline, 1: Map, 2: Photos
  }) = _TripDetailState;
}
```

---

### **W3.3: Trip Detail UI Widgets**

**21. lib/features/feed/presentation/widgets/timeline_place_item.dart**

**Requirements:**
- Day header
- Place icon, name, notes
- Photo horizontal scroll
- Save button

**Reference:** Screen Spec #3 (Timeline Place Item)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

class TimelinePlaceItem extends StatelessWidget {
  final TripPlace place;
  final VoidCallback onSave;
  
  const TimelinePlaceItem({
    Key? key,
    required this.place,
    required this.onSave,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.verticalMd,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          if (place.dayNumber != null) ...[
            Text(
              'Day ${place.dayNumber}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
          
          // Place Name
          Row(
            children: [
              Icon(Icons.place, color: AppColors.accent, size: 20),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  place.name,
                  style: AppTypography.h3,
                ),
              ),
            ],
          ),
          
          // Notes
          if (place.notes != null && place.notes!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              place.notes!,
              style: AppTypography.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Photos
          if (place.photoUrls.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: place.photoUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: AppRadius.borderSm,
                      child: CachedNetworkImage(
                        imageUrl: place.photoUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Save Button
          SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(120, 36),
              ),
              child: Text('Save to trip'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

**22. lib/features/feed/presentation/widgets/timeline_route_item.dart**

**Requirements:**
- Transport icon (🚗🚴🚶✈️)
- Distance, duration
- Copy button

**Reference:** Screen Spec #3 (Timeline Route Item)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

class TimelineRouteItem extends StatelessWidget {
  final TripRoute route;
  final VoidCallback onCopy;
  
  const TimelineRouteItem({
    Key? key,
    required this.route,
    required this.onCopy,
  }) : super(key: key);
  
  IconData get _transportIcon {
    switch (route.transportMode) {
      case 'bike':
        return Icons.directions_bike;
      case 'walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.flight;
      default:
        return Icons.directions_car;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.verticalMd,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_transportIcon, color: AppColors.accent),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${route.distance?.toStringAsFixed(1) ?? "?"} km',
                  style: AppTypography.h3,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${route.duration ?? "?"} min · ${route.transportMode ?? "car"}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onCopy,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(120, 36),
              ),
              child: Text('Copy route'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### **W3.4: Trip Detail Screen**

**23. lib/features/feed/presentation/screens/trip_detail_screen.dart**

**Requirements:**
- Match Screen Spec #3 layout
- Cover image with overlay
- Header card (overlaps image)
- Tabs (Timeline, Map, Photos)
- Timeline view (places + routes)
- Copy entire trip button (sticky bottom)

**Reference:** Screen Spec #3 (Complete layout)

**Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/features/feed/presentation/providers/trip_detail_provider.dart';
import 'package:dora/features/feed/presentation/widgets/timeline_place_item.dart';
import 'package:dora/features/feed/presentation/widgets/timeline_route_item.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  
  const TripDetailScreen({
    Key? key,
    required this.tripId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(tripDetailControllerProvider(tripId));
    
    return Scaffold(
      body: detailState.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorView(
          message: 'Couldn't load trip',
          onRetry: () => ref.refresh(tripDetailControllerProvider(tripId)),
        ),
      ),
    );
  }
  
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TripDetailState state,
  ) {
    final trip = state.data.trip;
    
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Cover Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: trip.coverPhotoUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                    // Dark gradient
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Share
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // More options
                  },
                ),
              ],
            ),
            
            // Header Card (overlapping)
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -40),
                child: _buildHeaderCard(trip),
              ),
            ),
            
            // Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabHeaderDelegate(
                child: Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: DefaultTabController.of(context),
                    tabs: [
                      Tab(text: 'Timeline'),
                      Tab(text: 'Map'),
                      Tab(text: 'Photos'),
                    ],
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                  ),
                ),
              ),
            ),
            
            // Tab Content
            SliverPadding(
              padding: AppSpacing.allMd,
              sliver: _buildTabContent(context, ref, state),
            ),
            
            // Bottom padding for sticky button
            SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
        
        // Sticky Copy Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _copyTrip(context, ref),
              child: Text('Copy Entire Trip'),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeaderCard(PublicTrip trip) {
    return Container(
      margin: AppSpacing.horizontalMd,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.name, style: AppTypography.h1),
          SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () {
              // Navigate to user profile
            },
            child: Text(
              'by @${trip.username}',
              style: AppTypography.body.copyWith(color: AppColors.accent),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '📸 ${trip.placeCount} places${trip.duration != null ? " · ${trip.duration} days" : ""}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (trip.tags.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: trip.tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: AppColors.accentSoft,
                labelStyle: TextStyle(color: AppColors.accent),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTabContent(
    BuildContext context,
    WidgetRef ref,
    TripDetailState state,
  ) {
    // Timeline Tab (default)
    final places = state.data.places;
    final routes = state.data.routes;
    
    // Merge and sort by day + order
    final items = <dynamic>[...places, ...routes];
    // Sort logic here
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          
          if (item is TripPlace) {
            return TimelinePlaceItem(
              place: item,
              onSave: () {
                // Show trip selector
                _showTripSelector(context, ref, item.id);
              },
            );
          } else if (item is TripRoute) {
            return TimelineRouteItem(
              route: item,
              onCopy: () {
                // Copy route
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Route copied')),
                );
              },
            );
          }
          
          return SizedBox.shrink();
        },
        childCount: items.length,
      ),
    );
  }
  
  void _copyTrip(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Copy "${state.data.trip.name}"?'),
        content: Text(
          'This will create a new trip with:\n'
          '• All ${state.data.places.length} places\n'
          '• All ${state.data.routes.length} routes\n'
          '• Original photos and notes',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(tripDetailControllerProvider(tripId).notifier).copyTrip();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Trip copied! Ready to customize.')),
                  );
                  context.go('/trips'); // Navigate to My Trips
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to copy trip')),
                  );
                }
              }
            },
            child: Text('Create Copy'),
          ),
        ],
      ),
    );
  }
  
  void _showTripSelector(BuildContext context, WidgetRef ref, String placeId) {
    // Future: Show user's trips to select
    // For now: just show toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to trip')),
    );
  }
}

// Tab Header Delegate for sticky tabs
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  
  _TabHeaderDelegate({required this.child});
  
  @override
  double get minExtent => 48;
  
  @override
  double get maxExtent => 48;
  
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
```

---

### **Week 3 Checkpoint:**

**Deliverable:**
- Trip detail screen functional
- Cover image + header card
- Timeline tab shows places/routes
- Save place button works
- Copy trip dialog works
- Navigation works

**Test:**
```bash
# 1. Tap trip card on Feed
# 2. See trip detail
# 3. Scroll timeline
# 4. Tap "Save to trip" → Toast
# 5. Tap "Copy Entire Trip" → Dialog → Confirm
# 6. Navigate to My Trips
```

---

## **✅ Phase 2 Success Criteria**

### **Functional Requirements:**

**Feed:**
- [ ] Public trips load from backend
- [ ] Trips cached offline
- [ ] Infinite scroll works
- [ ] Pull to refresh works
- [ ] Filter button shows (future: functional)
- [ ] Empty state shows
- [ ] Error handling works

**Search:**
- [ ] Search bar auto-focuses
- [ ] Place search works (Foursquare/Google)
- [ ] Trip search works
- [ ] Recent searches saved
- [ ] Quick actions visible
- [ ] Results grouped (Places, Trips)
- [ ] No results state shows

**Trip Detail:**
- [ ] Trip loads with places/routes
- [ ] Cover image displays
- [ ] Header card overlaps
- [ ] Timeline shows chronologically
- [ ] Save place button works
- [ ] Copy trip works
- [ ] Navigation back works

**Code Quality:**
- [ ] All API calls through repository
- [ ] Offline-first pattern followed
- [ ] All theme values from tokens
- [ ] Freezed models used
- [ ] Riverpod providers follow pattern
- [ ] No direct API calls in UI

---

## **🧪 Testing Strategy**

### **Manual Testing Checklist:**

```
FEED SCREEN:
□ Launch app → Feed loads
□ Scroll down → More trips load
□ Pull down → Refreshes
□ Tap search → Navigate to search
□ Tap trip → Navigate to detail
□ Airplane mode → Shows cached trips
□ No trips → Shows empty state
□ Network error → Shows error + retry

SEARCH SCREEN:
□ Tap search bar → Keyboard appears
□ Type "tokyo" → Results appear
□ Clear search → Shows recent
□ Tap recent → Executes search
□ Search places → Places show
□ Search trips → Trips show
□ No results → Shows empty state

TRIP DETAIL:
□ Tap trip card → Detail loads
□ Cover image displays
□ Timeline shows places
□ Tap save → Toast appears
□ Tap copy trip → Dialog shows
□ Confirm copy → Navigates to My Trips
□ Back button → Returns to Feed
```

---

## **📦 Additional Files Needed**

### **Update Navigation Routes:**

**File: lib/core/navigation/routes.dart**

Add:
```dart
static const search = '/search';
static const tripDetail = '/trip';
```

**File: lib/core/navigation/app_router.dart**

Add routes:
```dart
GoRoute(
  path: '/search',
  builder: (context, state) => const SearchScreen(),
),
GoRoute(
  path: '/trip/:id',
  builder: (context, state) => TripDetailScreen(
    tripId: state.pathParameters['id']!,
  ),
),
```

---

### **Update Feed Placeholder:**

**File: lib/features/feed/presentation/screens/feed_screen.dart**

Replace placeholder with actual implementation from this PRD.

---

## **⚠️ Common Pitfalls**

### **1. Forgetting Offline-First**

**Problem:** Directly using API in UI

**Solution:**
```dart
// ❌ WRONG
final trips = await FeedApi().getPublicTrips();

// ✅ CORRECT
final trips = await FeedRepository().getPublicTrips(); // Tries cache first
```

---

### **2. Not Debouncing Search**

**Problem:** API called on every keystroke

**Solution:**
```dart
Timer? _debounce;

void search(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 300), () {
    // Execute search
  });
}
```

---

### **3. Infinite Scroll Triggering Too Early**

**Problem:** Loads more at 50% scroll

**Solution:**
```dart
// Trigger at 85% scroll
final isBottom = currentScroll >= (maxScroll * 0.85);
```

---

### **4. Not Handling Empty Cover Photos**

**Problem:** App crashes on null image URL

**Solution:**
```dart
CachedNetworkImage(
  imageUrl: trip.coverPhotoUrl ?? '',
  errorWidget: (context, url, error) => Placeholder(),
)
```

---

## **📋 Handoff to Phase 3**

**What Phase 3 will build on:**
- ✅ Feed infrastructure (extend with filters)
- ✅ Search infrastructure (add AI advisor)
- ✅ Trip detail (add Map/Photos tabs)
- ✅ Offline caching (extend to user trips)

**What Phase 3 will build:**
- My Trips screen (user's trip library)
- Trip management (edit, delete, duplicate)
- Trip sharing (make public/private)
- Profile screen

---

## **🎯 Phase 2 Completion Definition**

**Phase 2 is complete when:**

1. ✅ All ~30 files created
2. ✅ Code generation runs successfully
3. ✅ Feed loads public trips
4. ✅ Search works (places + trips)
5. ✅ Trip detail shows timeline
6. ✅ Offline caching works
7. ✅ Infinite scroll works
8. ✅ Pull to refresh works
9. ✅ All screens follow design system
10. ✅ Passes manual testing checklist

---

**END OF PHASE 2 PRD**

---

**Next:** Phase 3 PRD (My Trips & Profile - 3 weeks)

**Ready to build Phase 2?** Start with `lib/features/feed/data/models/public_trip.dart` 🚀