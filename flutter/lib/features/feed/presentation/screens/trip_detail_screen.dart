import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';
import 'package:dora/features/feed/presentation/providers/trip_detail_provider.dart';
import 'package:dora/features/feed/presentation/widgets/timeline_place_item.dart';
import 'package:dora/features/feed/presentation/widgets/timeline_route_item.dart';
import 'package:dora/shared/widgets/error_view.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(tripDetailControllerProvider(tripId));

    return Scaffold(
      body: detailState.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorView(
          message: "Couldn't load trip",
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
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 300,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: state.data.trip.coverPhotoUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.textPrimary.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.card),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.card),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.card),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildHeaderCard(state.data.trip),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabHeaderDelegate(
                  child: Container(
                    color: AppColors.surface,
                    child: const TabBar(
                      labelColor: AppColors.accent,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.accent,
                      tabs: [
                        Tab(text: 'Timeline'),
                        Tab(text: 'Map'),
                        Tab(text: 'Photos'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _buildTimeline(context, ref, state),
                _buildPlaceholder('Map view coming soon'),
                _buildPlaceholder('Photos coming soon'),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.xxl + AppSpacing.sm,
            child: Padding(
              padding: AppSpacing.horizontalMd,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderMd,
                  boxShadow: AppShadows.soft,
                ),
                child: Padding(
                  padding: AppSpacing.allMd,
                  child: ElevatedButton(
                    onPressed: () => _copyTrip(context, ref, state),
                    child: const Text('Copy Entire Trip'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(PublicTrip trip) {
    return Container(
      margin: AppSpacing.horizontalMd,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.name, style: AppTypography.h1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'by @${trip.username}',
            style: AppTypography.body.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '📸 ${trip.placeCount} places${trip.duration != null ? " · ${trip.duration} days" : ""}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (trip.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: trip.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.accentSoft,
                      labelStyle:
                          const TextStyle(color: AppColors.accent),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    WidgetRef ref,
    TripDetailState state,
  ) {
    final items = _buildTimelineItems(state.data.places, state.data.routes);

    return ListView.builder(
      padding: AppSpacing.horizontalMd.add(
        EdgeInsets.only(bottom: AppSpacing.xxl + AppSpacing.xl),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.place != null) {
          return TimelinePlaceItem(
            place: item.place!,
            onSave: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          );
        }

        if (item.route != null) {
          return TimelineRouteItem(
            route: item.route!,
            onCopy: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<_TimelineItem> _buildTimelineItems(
    List<TripPlace> places,
    List<TripRoute> routes,
  ) {
    final items = <_TimelineItem>[
      ...places.map(
        (place) => _TimelineItem(
          sortKey: _sortKey(place.dayNumber, place.orderIndex),
          place: place,
        ),
      ),
      ...routes.map(
        (route) => _TimelineItem(
          sortKey: _sortKey(route.dayNumber, 50),
          route: route,
        ),
      ),
    ];

    items.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return items;
  }

  double _sortKey(int? dayNumber, int? orderIndex) {
    final day = (dayNumber ?? 0) * 100;
    final order = orderIndex ?? 0;
    return day + order / 100;
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  void _copyTrip(
    BuildContext context,
    WidgetRef ref,
    TripDetailState state,
  ) {
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
            child: const Text('Create Copy'),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem {
  _TimelineItem({
    required this.sortKey,
    this.place,
    this.route,
  });

  final double sortKey;
  final TripPlace? place;
  final TripRoute? route;
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate({required this.child});

  final Widget child;

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
