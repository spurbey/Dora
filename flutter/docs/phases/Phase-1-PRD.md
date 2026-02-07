# **FLUTTER PHASE 1 PRD: FOUNDATION**

## **Complete Implementation Guide**

---

## **📋 Phase Overview**

**Phase ID:** Flutter Phase 1  
**Duration:** 4 weeks  
**Dependencies:** Backend API (Phase A complete), Design System (Dora)  
**Goal:** Establish robust foundation for all future features

---

## **🎯 Objectives**

**Primary Goal:**  
Build the technical foundation that all features will depend on.

**What Success Looks Like:**
- App launches with Dora theme applied
- User can login/signup via Supabase
- Navigation shell works (bottom tabs)
- OpenAPI client auto-generated from backend
- Offline database (Drift) initialized
- State management (Riverpod) configured
- Feature flags system operational

**This phase builds NO user features, only infrastructure.**

---

## **🏗️ Architecture Alignment**

### **References Architecture Document:**
- Section 4: Theme System
- Section 5: Map Abstraction (stub only, full in Phase 4)
- Section 6: Offline Architecture
- Section 7: Authentication
- Section 8: State Management
- Section 10: Configuration

### **Design System:**
- Dora color palette
- Typography scale
- Spacing tokens (8pt grid)
- Border radius system

---

## **📁 Deliverables Overview**

**Files to Create: ~25 files**

```
lib/
├── main.dart                           (Entry point)
├── app.dart                            (Root widget)
│
├── core/
│   ├── theme/                          (5 files)
│   ├── navigation/                     (3 files)
│   ├── auth/                           (2 files)
│   ├── network/                        (4 files)
│   ├── storage/                        (3 files)
│   ├── config/                         (2 files)
│   └── utils/                          (2 files)
│
└── features/
    └── auth/                           (4 files)
        ├── data/
        ├── domain/
        └── presentation/
```

---

## **🔧 WEEK 1: Theme System & Navigation**

### **Goal:** User sees branded app with working navigation

---

### **W1.1: Theme System**

**Create files:**

**1. lib/core/theme/app_colors.dart**

**Requirements:**
- Define all Dora color tokens as static constants
- Primary palette: `primary`, `surface`, `card`, `textPrimary`, `textSecondary`, `divider`
- Accent palette: `accent`, `accentSoft`
- Dark mode: `darkBg`, `darkSurface`, `darkText`, `darkMuted`
- Semantic: `error`, `success`, `warning`

**Reference:** Design System Section 3 (Color System)

**Pattern:**
```dart
class AppColors {
  AppColors._(); // Private constructor
  
  static const primary = Color(0xFF86726B);
  // ... rest from Design System
}
```

---

**2. lib/core/theme/app_spacing.dart**

**Requirements:**
- 8pt grid system: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`
- EdgeInsets shortcuts: `allMd`, `horizontalMd`, `verticalMd`

**Reference:** Design System Section 5 (Spacing System)

---

**3. lib/core/theme/app_typography.dart**

**Requirements:**
- Type scale: `h1`, `h2`, `h3`, `body`, `caption`
- Font family: 'SF Pro Display'
- Line heights specified

**Reference:** Design System Section 4 (Typography)

---

**4. lib/core/theme/app_radius.dart**

**Requirements:**
- Border radius tokens: `sm`, `md`, `lg`, `xl`
- BorderRadius shortcuts: `borderMd`, `sheetTop`

**Reference:** Design System Section 6 (Border Radius)

---

**5. lib/core/theme/app_theme.dart**

**Requirements:**
- Combine all tokens into Material 3 ThemeData
- Light theme (default)
- Dark theme (export studio mode)
- Apply to: Cards, buttons, inputs, bottom sheets

**Reference:** Architecture Doc Section 4, Design System Section 15

**Critical:**
- Use `useMaterial3: true`
- Apply `fontFamily` globally
- Configure `elevatedButtonTheme`, `cardTheme`, `bottomSheetTheme`

---

### **W1.2: Navigation Shell**

**Create files:**

**6. lib/core/navigation/app_router.dart**

**Requirements:**
- Use GoRouter package
- Define routes for 4 tabs: `/feed`, `/create`, `/trips`, `/profile`
- Nested navigation within tabs
- Deep linking support
- Guard routes (auth required)

**Pattern:**
```dart
final appRouter = GoRouter(
  initialLocation: '/feed',
  routes: [
    ShellRoute(
      builder: (context, state, child) => NavigationShell(child: child),
      routes: [
        GoRoute(path: '/feed', builder: (context, state) => FeedScreen()),
        // ... other tabs
      ],
    ),
  ],
);
```

**Reference:** Architecture Doc Section 3 (Navigation)

---

**7. lib/core/navigation/routes.dart**

**Requirements:**
- Route name constants
- Route path constants
- Type-safe route helpers

**Pattern:**
```dart
class Routes {
  static const feed = '/feed';
  static const create = '/create';
  static const trips = '/trips';
  static const profile = '/profile';
  
  // Nested routes
  static const editor = '/trips/:id/edit';
  static const tripDetail = '/trips/:id';
}
```

---

**8. lib/core/navigation/navigation_shell.dart**

**Requirements:**
- Bottom tab bar with 4 tabs
- Icons: Feed 🏠, Create ➕, Trips 📚, Profile 👤
- Selected state (accent color)
- Preserve tab state on switch

**Reference:** Screen Spec Navigation Architecture, Dora theme

**Pattern:**
```dart
class NavigationShell extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          // ... others
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
```

---

### **W1.3: App Entry Point**

**Create files:**

**9. lib/main.dart**

**Requirements:**
- Initialize Supabase
- Initialize Sentry (error tracking)
- Initialize Firebase Analytics
- Setup Riverpod ProviderScope
- Configure system UI (status bar)

**Pattern:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  
  await SentryFlutter.init(
    (options) => options.dsn = Env.sentryDsn,
    appRunner: () => runApp(
      ProviderScope(child: DoraApp()),
    ),
  );
}
```

**Reference:** Architecture Doc Section 10 (Configuration)

---

**10. lib/app.dart**

**Requirements:**
- Root widget
- Apply AppTheme
- Setup GoRouter
- Handle initial route logic

**Pattern:**
```dart
class DoraApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Dora',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
```

---

### **Week 1 Checkpoint:**

**Deliverable:**
- App launches with Dora branding
- Bottom tabs visible and functional
- Tab switching works
- Tabs show placeholder screens (empty)

**Test:**
```bash
flutter run
# Should see:
# - Dora colors applied
# - Bottom tab bar (4 tabs)
# - Tap tabs → switches
# - No crashes
```

---

## **🔧 WEEK 2: Authentication & State Management**

### **Goal:** User can login/signup, auth state managed globally

---

### **W2.1: Supabase Auth Integration**

**Create files:**

**11. lib/core/auth/auth_service.dart**

**Requirements:**
- Wrapper around Supabase Auth
- Methods: `signInWithEmail`, `signUp`, `signOut`, `currentUser`
- Stream: `authStateChanges`
- Token management: `getAccessToken`

**Reference:** Architecture Doc Section 7 (Authentication)

**Pattern:**
```dart
class AuthService {
  final SupabaseClient _supabase;
  
  Stream<User?> get authStateChanges => 
    _supabase.auth.onAuthStateChange.map((e) => e.session?.user);
  
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // ... other methods
}
```

---

**12. lib/core/auth/token_manager.dart**

**Requirements:**
- Store JWT token in secure storage
- Refresh token logic
- Clear tokens on logout

**Use:** `flutter_secure_storage` package

---

### **W2.2: Riverpod Providers**

**Create files:**

**13. lib/features/auth/presentation/providers/auth_provider.dart**

**Requirements:**
- Use `@riverpod` annotation (code generation)
- Expose auth state stream
- Expose auth actions (login, signup, logout)
- Handle loading/error states

**Reference:** Architecture Doc Section 8 (State Management)

**Pattern:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    final authService = ref.watch(authServiceProvider);
    return authService.authStateChanges;
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(email, password);
      return authService.currentUser;
    });
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(Supabase.instance.client);
}
```

---

### **W2.3: Auth UI**

**Create files:**

**14. lib/features/auth/presentation/screens/login_screen.dart**

**Requirements:**
- Email + password inputs
- Login button
- "Sign up" link
- Loading state
- Error display
- Form validation

**Reference:** Screen specs (not detailed in Phase 1, use standard Material 3)

**Pattern:**
```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    return Scaffold(
      body: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          children: [
            // Email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // Password input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            // Login button
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleLogin() {
    ref.read(authControllerProvider.notifier).signIn(
      _emailController.text,
      _passwordController.text,
    );
  }
}
```

**Dora microcopy:**
- Button: "Sign In"
- Link: "New here? Create account"
- Error: "Couldn't sign in. Check your credentials"

---

**15. lib/features/auth/presentation/screens/signup_screen.dart**

**Requirements:**
- Email + password + confirm password inputs
- Signup button
- "Login" link
- Password strength indicator
- Form validation

**Similar pattern to login_screen.dart**

---

### **Week 2 Checkpoint:**

**Deliverable:**
- User can signup (creates Supabase account)
- User can login (JWT token stored)
- Auth state managed by Riverpod
- Redirect: Logged out → Login, Logged in → Feed

**Test:**
```bash
# 1. Launch app → See login screen
# 2. Tap "Create account" → Signup screen
# 3. Create account → Redirects to feed
# 4. Close app, reopen → Still logged in
# 5. Logout → Back to login
```

---

## **🔧 WEEK 3: API Integration & Database**

### **Goal:** Backend API connected, offline database initialized

---

### **W3.1: OpenAPI Code Generation**

**Setup:**

**16. openapi-generator-config.yaml** (root)

```yaml
generatorName: dart-dio
inputSpec: http://localhost:8000/openapi.json
outputDir: lib/generated/api/
additionalProperties:
  pubName: dora_api
  useEnumExtension: true
```

**Run:**
```bash
# Ensure backend is running
cd ../backend
uvicorn main:app --reload

# Generate API client
cd ../mobile
openapi-generator-cli generate -c openapi-generator-config.yaml
```

**Reference:** Architecture Doc Section 9 (OpenAPI Integration)

**Generated files location:**
```
lib/generated/api/
├── api.dart
├── api_client.dart
└── models/
    ├── trip_dto.dart
    ├── place_dto.dart
    └── ...
```

**Critical rule:** Never edit generated files manually

---

### **W3.2: API Client Wrapper**

**Create files:**

**17. lib/core/network/api_client.dart**

**Requirements:**
- Dio instance configuration
- Base URL from environment
- Interceptors: Auth, retry, logging
- Error handling

**Reference:** Architecture Doc Section 6 (Network)

**Pattern:**
```dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient({required String baseUrl, required AuthService authService}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    
    _dio.interceptors.addAll([
      AuthInterceptor(authService),
      RetryInterceptor(),
      LoggingInterceptor(),
    ]);
  }
  
  Dio get dio => _dio;
}
```

---

**18. lib/core/network/auth_interceptor.dart**

**Requirements:**
- Inject JWT token in Authorization header
- Refresh token if expired
- Handle 401 responses

**Reference:** Architecture Doc Section 7

**Pattern:**
```dart
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  
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

**19. lib/core/network/retry_interceptor.dart**

**Requirements:**
- Auto-retry failed requests (max 3 attempts)
- Exponential backoff
- Only retry on network errors, not 4xx

**Pattern:**
```dart
class RetryInterceptor extends Interceptor {
  static const maxRetries = 3;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: 2 << retryCount));
        // Retry request
      }
    }
    handler.next(err);
  }
}
```

---

**20. lib/core/network/offline_queue.dart**

**Requirements:**
- Queue failed requests when offline
- Persist queue in local DB
- Auto-sync when online

**Reference:** Architecture Doc Section 6

**Stub implementation for now (full in Phase 2)**

---

### **W3.3: Drift Database Setup**

**Create files:**

**21. lib/core/storage/drift_database.dart**

**Requirements:**
- Define database class
- Include tables: Trips, Places, Routes, Media
- DAOs for each table
- Schema version 1

**Reference:** Architecture Doc Section 6 (Offline Architecture)

**Pattern:**
```dart
import 'package:drift/drift.dart';
import 'tables/trips_table.dart';
import 'daos/trip_dao.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Trips, Places, Routes, Media],
  daos: [TripDao, PlaceDao, RouteDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
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

**22. lib/core/storage/tables/trips_table.dart**

**Requirements:**
- Mirror backend Trip model
- Add sync metadata: `localUpdatedAt`, `serverUpdatedAt`, `syncStatus`

**Reference:** Architecture Doc Section 6

**Pattern:**
```dart
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  
  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()(); // 'pending' | 'synced' | 'conflict'
  
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**Create similar tables for:** Places, Routes, Media

---

**23. lib/core/storage/daos/trip_dao.dart**

**Requirements:**
- CRUD operations for trips
- Query helpers (get all, get by ID, get pending sync)

**Pattern:**
```dart
@DriftAccessor(tables: [Trips])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(AppDatabase db) : super(db);
  
  Future<List<Trip>> getAllTrips() => select(trips).get();
  
  Future<Trip?> getTripById(String id) => 
    (select(trips)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertTrip(TripsCompanion trip) => 
    into(trips).insert(trip);
  
  Future<bool> updateTrip(TripsCompanion trip) => 
    update(trips).replace(trip);
}
```

---

### **W3.4: Code Generation**

**Run:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**This generates:**
- `*.g.dart` files for Freezed models
- `*.g.dart` files for Riverpod providers
- `drift_database.g.dart` for Drift
- OpenAPI client files

**Critical:** Run this after every model/provider change

---

### **Week 3 Checkpoint:**

**Deliverable:**
- OpenAPI client generated from backend
- Dio configured with interceptors
- Drift database initialized
- Tables created
- DAOs functional

**Test:**
```bash
# 1. Backend running
# 2. OpenAPI generation works
# 3. App launches (DB initialized)
# 4. Check device: Drift DB file exists
# 5. No crashes
```

---

## **🔧 WEEK 4: Configuration & Polish**

### **Goal:** Feature flags, environment config, error handling

---

### **W4.1: Environment Configuration**

**Create files:**

**24. lib/core/config/env_config.dart**

**Requirements:**
- Load from `--dart-define` flags
- Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `MAPBOX_TOKEN`, `API_BASE_URL`, `SENTRY_DSN`
- Environment detection (dev/staging/production)

**Reference:** Architecture Doc Section 10

**Pattern:**
```dart
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  
  static bool get isProduction => 
    const String.fromEnvironment('ENVIRONMENT') == 'production';
}
```

**Create:** `.env.example` in project root

```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
MAPBOX_TOKEN=pk.xxx
API_BASE_URL=http://localhost:8000
SENTRY_DSN=https://xxx@sentry.io/xxx
ENVIRONMENT=development
```

---

**25. lib/core/config/feature_flags.dart**

**Requirements:**
- Remote config from Firebase Remote Config
- Feature toggles: `enableExport`, `enableRouteDrawing`, etc.
- Fetch on app start
- Cache locally

**Pattern:**
```dart
class FeatureFlags {
  static final FirebaseRemoteConfig _remoteConfig = 
    FirebaseRemoteConfig.instance;
  
  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }
  
  static bool get enableExport => 
    _remoteConfig.getBool('enable_export');
  
  static bool get enableRouteDrawing => 
    _remoteConfig.getBool('enable_route_drawing');
}
```

**Initialize in main.dart before runApp**

---

### **W4.2: Logging & Error Handling**

**Create files:**

**26. lib/core/utils/logger.dart**

**Requirements:**
- Structured logging
- Different levels: debug, info, warning, error
- Send errors to Sentry in production
- Pretty print in development

**Pattern:**
```dart
class Logger {
  static void debug(String message, [dynamic data]) {
    if (!Env.isProduction) {
      print('🐛 DEBUG: $message ${data ?? ''}');
    }
  }
  
  static void error(String message, dynamic error, StackTrace? stack) {
    print('❌ ERROR: $message');
    if (Env.isProduction) {
      Sentry.captureException(error, stackTrace: stack);
    }
  }
}
```

---

**27. lib/core/utils/validators.dart**

**Requirements:**
- Email validation
- Password strength
- URL validation
- Phone number (future)

**Pattern:**
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
```

---

### **W4.3: Placeholder Screens**

**Create:**

**28. lib/features/feed/presentation/screens/feed_screen.dart**
**29. lib/features/create/presentation/screens/create_screen.dart**
**30. lib/features/trips/presentation/screens/trips_screen.dart**
**31. lib/features/profile/presentation/screens/profile_screen.dart**

**Requirements (for now):**
- Centered text showing screen name
- Uses AppTheme
- Scaffold with app bar
- "Coming in Phase 2" message

**Pattern:**
```dart
class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('Feed', style: AppTypography.h2),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Coming in Phase 2',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Dora microcopy:** "Coming in Phase 2"

---

### **Week 4 Checkpoint:**

**Deliverable:**
- Environment variables configurable
- Feature flags operational
- Logging system works
- All 4 tab screens exist (placeholders)
- Error tracking configured

**Test:**
```bash
# Run with env vars
flutter run --dart-define-from-file=.env

# Should see:
# - App launches
# - Login works
# - All tabs functional
# - Sentry receives test error
# - Feature flags fetched
```

---

## **✅ Phase 1 Success Criteria**

### **Functional Requirements:**

**Authentication:**
- [ ] User can signup with email/password
- [ ] User can login
- [ ] User can logout
- [ ] Auth state persists (stay logged in)
- [ ] JWT token auto-refreshes

**Navigation:**
- [ ] Bottom tabs visible
- [ ] All 4 tabs switchable
- [ ] Tab state preserved on switch
- [ ] Deep linking works (test: `/feed`, `/trips`)

**Theme:**
- [ ] Dora colors applied throughout
- [ ] Typography consistent (SF Pro)
- [ ] Spacing follows 8pt grid
- [ ] Dark mode available (for export later)

**Infrastructure:**
- [ ] OpenAPI client generated
- [ ] API calls authenticated (JWT header)
- [ ] Drift database initialized
- [ ] Tables created
- [ ] Environment config works
- [ ] Feature flags fetch

**Code Quality:**
- [ ] No direct Supabase/Dio usage in UI (abstractions)
- [ ] All theme values from tokens (no hardcoded colors)
- [ ] Riverpod providers follow pattern
- [ ] Code generation runs without errors

---

## **🧪 Testing Strategy**

### **Manual Testing Checklist:**

```
□ Fresh install
□ Signup new account → Success
□ Login → Redirects to Feed
□ Tap each tab → Switches correctly
□ Logout → Back to login
□ Close app → Reopen → Still logged in
□ Wrong password → Shows error
□ Network off → Login fails gracefully
□ Check Drift DB file exists (device inspector)
□ Trigger error → Sentry receives
□ Check feature flags console log
```

### **Unit Tests (Optional for Phase 1):**

Create basic tests:
- `test/core/utils/validators_test.dart` - Test email/password validation
- `test/core/theme/app_colors_test.dart` - Verify color values

---

## **📦 Dependencies (pubspec.yaml)**

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Auth
  supabase_flutter: ^2.0.0
  
  # Navigation
  go_router: ^12.1.0
  
  # Network
  dio: ^5.4.0
  
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Analytics
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_remote_config: ^4.3.0
  sentry_flutter: ^7.13.0
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  drift_dev: ^2.14.0
  
  # Testing
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.1
```

---

## **⚠️ Common Pitfalls**

### **1. OpenAPI Generation Fails**

**Problem:** Backend not running or spec not available

**Solution:**
```bash
# Start backend first
cd ../backend
uvicorn main:app --reload

# Verify spec accessible
curl http://localhost:8000/openapi.json

# Then generate
cd ../mobile
openapi-generator-cli generate -c openapi-generator-config.yaml
```

---

### **2. Code Generation Errors**

**Problem:** Riverpod/Drift/Freezed generation fails

**Solution:**
```bash
# Clean build cache
flutter clean
flutter pub get

# Delete old generated files
find . -name "*.g.dart" -delete

# Regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **3. Env Variables Not Loading**

**Problem:** `Env.supabaseUrl` is empty string

**Solution:**
```bash
# Check .env file exists
cat .env

# Run with explicit flag
flutter run --dart-define-from-file=.env

# Or individual flags
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

---

### **4. Theme Not Applied**

**Problem:** App uses default Material colors

**Solution:**
- Check `AppTheme.light` passed to MaterialApp
- Verify tokens imported: `import 'package:dora/core/theme/app_colors.dart'`
- Check no inline `Color(0x...)` in widgets

---

### **5. Auth State Not Persisting**

**Problem:** User logged out after app