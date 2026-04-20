import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/navigation/go_router_refresh_stream.dart';
import 'package:dora/core/navigation/navigation_observers.dart';
import 'package:dora/core/navigation/navigation_shell.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/config/feature_flags.dart';
import 'package:dora/features/auth/presentation/screens/login_screen.dart';
import 'package:dora/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:dora/features/auth/presentation/screens/signup_screen.dart';
import 'package:dora/features/auth/presentation/screens/startup_screen.dart';
import 'package:dora/features/create/presentation/screens/editor_screen.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/capture/presentation/screens/camera_runtime_screen.dart';
import 'package:dora/features/live_capture/presentation/screens/live_capture_screen.dart';
import 'package:dora/features/live_capture/presentation/screens/live_hub_screen.dart';
import 'package:dora/features/create/presentation/screens/city_search_screen.dart';
import 'package:dora/features/create/presentation/screens/media_upload_screen.dart';
import 'package:dora/features/create/presentation/screens/place_search_screen.dart';
import 'package:dora/features/feed/presentation/screens/feed_screen.dart';
import 'package:dora/features/feed/presentation/screens/search_screen.dart';
import 'package:dora/features/feed/presentation/screens/trip_detail_screen.dart';
import 'package:dora/features/export/presentation/screens/export_studio_screen.dart';
import 'package:dora/features/export/presentation/screens/my_trips_export_screen.dart';
import 'package:dora/features/profile/presentation/screens/profile_screen.dart';
import 'package:dora/features/profile/presentation/screens/settings_screen.dart';
import 'package:dora/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:dora/features/vault/presentation/screens/vault_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChanges = Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);

  return GoRouter(
    initialLocation: Routes.startup,
    observers: [
      ref.watch(appRouteObserverProvider),
    ],
    refreshListenable: GoRouterRefreshStream(authChanges),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final location = state.uri.path;
      final isAuthRoute = location == Routes.login || location == Routes.signup;
      final isStartupRoute = location == Routes.startup;
      final isOnboardingRoute = location == Routes.onboarding;
      final isPublicRoute = isAuthRoute || isStartupRoute || isOnboardingRoute;

      if (!isLoggedIn && !isPublicRoute) {
        return Routes.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return Routes.startup;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.startup,
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/trip/:id/advisory',
        redirect: (_, state) =>
            Routes.liveCapturePath(state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.editor,
        builder: (context, state) => EditorScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.liveCapture,
        builder: (context, state) => LiveCaptureScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.placeSearch,
        builder: (context, state) => PlaceSearchScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.citySearch,
        builder: (context, state) => CitySearchScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.mediaUpload,
        builder: (context, state) => MediaUploadScreen(
          tripId: state.pathParameters['tripId']!,
          placeId: state.pathParameters['placeId']!,
        ),
      ),
      GoRoute(
        path: Routes.exportStudio,
        redirect: (_, __) => FeatureFlags.enableExport ? null : Routes.trips,
        builder: (context, state) => ExportStudioScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.vault,
        builder: (context, state) => const VaultScreen(),
      ),
      GoRoute(
        path: Routes.camera,
        builder: (context, state) {
          final args = state.extra is CameraLaunchArgs
              ? state.extra! as CameraLaunchArgs
              : const CameraLaunchArgs(
                  context: CameraLaunchContext.fab,
                  initialMode: CameraInitialMode.photo,
                );
          return CameraRuntimeScreen(args: args);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => NavigationShell(child: child),
        routes: [
          GoRoute(
            path: Routes.feed,
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: Routes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: Routes.tripDetail,
            builder: (context, state) => TripDetailScreen(
              tripId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: Routes.liveHub,
            builder: (context, state) => const LiveHubScreen(),
          ),
          GoRoute(
            path: Routes.trips,
            builder: (context, state) => const MyTripsScreen(),
          ),
          GoRoute(
            path: Routes.tripsExports,
            redirect: (_, __) =>
                FeatureFlags.enableExport ? null : Routes.trips,
            builder: (context, state) => const MyTripsExportScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
