import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/navigation/go_router_refresh_stream.dart';
import 'package:dora/core/navigation/navigation_shell.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/features/auth/presentation/screens/login_screen.dart';
import 'package:dora/features/auth/presentation/screens/signup_screen.dart';
import 'package:dora/features/create/presentation/screens/create_screen.dart';
import 'package:dora/features/create/presentation/screens/editor_screen.dart';
import 'package:dora/features/feed/presentation/screens/feed_screen.dart';
import 'package:dora/features/feed/presentation/screens/search_screen.dart';
import 'package:dora/features/feed/presentation/screens/trip_detail_screen.dart';
import 'package:dora/features/profile/presentation/screens/profile_screen.dart';
import 'package:dora/features/profile/presentation/screens/settings_screen.dart';
import 'package:dora/features/trips/presentation/screens/my_trips_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChanges = Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);

  return GoRouter(
    initialLocation: Routes.feed,
    refreshListenable: GoRouterRefreshStream(authChanges),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn =
          Supabase.instance.client.auth.currentSession != null;
      final location = state.uri.path;
      final isAuthRoute =
          location == Routes.login || location == Routes.signup;

      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return Routes.feed;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.editor,
        builder: (context, state) => EditorScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
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
            path: Routes.create,
            builder: (context, state) => const CreateScreen(),
          ),
          GoRoute(
            path: Routes.trips,
            builder: (context, state) => const MyTripsScreen(),
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
