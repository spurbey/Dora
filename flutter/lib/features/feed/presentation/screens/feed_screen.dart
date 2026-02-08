import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/utils/date_time_utils.dart';
import 'package:dora/features/feed/presentation/providers/feed_provider.dart';
import 'package:dora/features/feed/presentation/widgets/empty_state.dart';
import 'package:dora/features/feed/presentation/widgets/ongoing_trip_banner.dart';
import 'package:dora/features/feed/presentation/widgets/search_bar_widget.dart';
import 'package:dora/features/feed/presentation/widgets/trip_card.dart';
import 'package:dora/shared/widgets/error_view.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      body: feedState.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorView(
          message: "Couldn't load travelogues",
          onRetry: () => ref.read(feedControllerProvider.notifier).refresh(),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              final isBottom = metrics.pixels >= metrics.maxScrollExtent * 0.85;
              if (isBottom) {
                ref.read(feedControllerProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.md),
                SearchBarWidget(
                  onTap: () => context.go(Routes.search),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.activeTrip != null)
                  Padding(
                    padding: AppSpacing.horizontalMd,
                    child: OngoingTripBanner(
                      title:
                          '${state.activeTrip!.name} (${state.activeTrip!.placeCount} places)',
                      subtitle:
                          'Last edited ${DateTimeUtils.formatRelativeTime(state.activeTrip!.lastEditedAt ?? state.activeTrip!.localUpdatedAt)}',
                      onTap: () =>
                          context.push(Routes.editorPath(state.activeTrip!.id)),
                    ),
                  ),
                Padding(
                  padding: AppSpacing.horizontalMd,
                  child: Text('Discover Travelogues', style: AppTypography.h2),
                ),
                if (state.trips.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: EmptyState(
                      icon: Icons.public,
                      title: 'No travelogues yet',
                      message: 'Be the first to share your journey!',
                      actionLabel: 'Create Your First Trip',
                      onAction: () => context.go(Routes.create),
                    ),
                  )
                else
                  Padding(
                    padding: AppSpacing.horizontalMd,
                    child: Column(
                      children: [
                        for (final trip in state.trips)
                          TripCard(
                            trip: trip,
                            onTap: () =>
                                context.go(Routes.tripDetailPath(trip.id)),
                          ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: LoadingIndicator(size: 28),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: AppSpacing.horizontalMd,
        child: SizedBox(
          height: AppSpacing.xxl + AppSpacing.xl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dora', style: AppTypography.h1),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    color: AppColors.textPrimary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filters coming soon')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: AppColors.textPrimary,
                    onPressed: () => context.go(Routes.search),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
