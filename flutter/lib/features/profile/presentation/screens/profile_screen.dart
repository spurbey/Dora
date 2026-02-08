import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/profile/presentation/providers/profile_provider.dart';
import 'package:dora/features/profile/presentation/widgets/profile_header.dart';
import 'package:dora/features/profile/presentation/widgets/profile_shimmer.dart';
import 'package:dora/features/profile/presentation/widgets/stats_row.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/domain/trips_state.dart';
import 'package:dora/features/trips/presentation/providers/trips_provider.dart';
import 'package:dora/features/trips/presentation/widgets/trip_grid_card.dart';
import 'package:dora/features/trips/presentation/widgets/trip_shimmer.dart';
import 'package:dora/shared/widgets/empty_state.dart';
import 'package:dora/shared/widgets/error_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final tripsAsync = ref.watch(tripsControllerProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(Routes.settings),
            ),
          ],
        ),
        body: profileAsync.when(
          loading: () => _buildLoading(context),
          error: (e, st) => ErrorView(
            message: "Couldn't load profile",
            onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
          ),
          data: (profile) => Column(
            children: [
              ProfileHeader(
                profile: profile,
                onAvatarTap: () => _showToast(context, 'Coming soon'),
              ),
              StatsRow(stats: profile.stats),
              const SizedBox(height: AppSpacing.sm),
              const TabBar(
                labelColor: AppColors.textPrimary,
                indicatorColor: AppColors.accent,
                tabs: [
                  Tab(text: 'My Trips'),
                  Tab(text: 'Shared'),
                  Tab(text: 'Saved'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TripsTab(
                      tripsAsync: tripsAsync,
                      filter: TripsFilter.all,
                      emptyIcon: Icons.menu_book_outlined,
                      emptyTitle: 'No trips yet',
                      emptyMessage: 'Create a trip to see it here',
                    ),
                    _TripsTab(
                      tripsAsync: tripsAsync,
                      filter: TripsFilter.shared,
                      emptyIcon: Icons.public,
                      emptyTitle: 'No shared trips',
                      emptyMessage: 'Make a trip public to share it',
                    ),
                    _SavedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView(
      padding: AppSpacing.allLg,
      children: const [
        ProfileHeaderShimmer(),
        SizedBox(height: AppSpacing.lg),
        StatsRowShimmer(),
        SizedBox(height: AppSpacing.xl),
        TripGridCardShimmer(),
        SizedBox(height: AppSpacing.md),
        TripGridCardShimmer(),
      ],
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _TripsTab extends ConsumerWidget {
  const _TripsTab({
    required this.tripsAsync,
    required this.filter,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final AsyncValue<TripsState> tripsAsync;
  final TripsFilter filter;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tripsAsync.when(
      loading: () => _buildLoadingGrid(),
      error: (e, st) => ErrorView(
        message: "Couldn't load trips",
        onRetry: () => ref.read(tripsControllerProvider.notifier).refresh(),
      ),
      data: (state) {
        final trips = _filterTrips(state.allTrips, filter);
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            await ref.read(tripsControllerProvider.notifier).refresh();
            await ref.read(profileControllerProvider.notifier).refresh();
          },
          child: trips.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: EmptyState(
                        icon: emptyIcon,
                        title: emptyTitle,
                        message: emptyMessage,
                      ),
                    ),
                  ],
                )
              : GridView.builder(
                  padding: AppSpacing.horizontalMd,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return TripGridCard(
                      trip: trip,
                      onTap: () => context.push(Routes.editorPath(trip.id)),
                    );
                  },
                ),
        );
      },
    );
  }

  List<UserTrip> _filterTrips(List<UserTrip> trips, TripsFilter filter) {
    switch (filter) {
      case TripsFilter.shared:
        return trips.where((trip) => trip.isShared).toList();
      case TripsFilter.all:
      default:
        return trips;
    }
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: AppSpacing.horizontalMd,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const TripGridCardShimmer(),
    );
  }
}

class _SavedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: const EmptyState(
            icon: Icons.bookmark_border,
            title: 'No saved trips yet',
            message: 'Explore the feed to discover journeys',
          ),
        ),
      ],
    );
  }
}
