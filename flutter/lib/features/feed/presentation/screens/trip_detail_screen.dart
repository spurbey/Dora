import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/app_map_view.dart';
import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/navigation/routes.dart';
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
    final previewMarkers = _buildMapMarkers(state.data.places);
    final previewRoutes = _buildMapRoutes(state.data.places, state.data.routes);
    final previewCenter =
        _resolveInitialCenter(state.data.places, previewRoutes);
    final previewBounds = _computeBounds(state.data.places, previewRoutes);

    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 260,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroPreview(
                        trip: state.data.trip,
                        markers: previewMarkers,
                        routes: previewRoutes,
                        center: previewCenter,
                        bounds: previewBounds,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.textPrimary.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.card),
                  onPressed: () => _handleBackNavigation(context),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
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
                _buildMapTab(state),
                _buildPhotosTab(state),
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.xxl + AppSpacing.sm,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => _copyTrip(context, ref, state),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
                child: const Text('Copy Entire Trip'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPreview({
    required PublicTrip trip,
    required List<AppMarker> markers,
    required List<AppRoute> routes,
    required AppLatLng center,
    required AppLatLngBounds? bounds,
  }) {
    if (markers.isNotEmpty || routes.isNotEmpty) {
      return AppMapView(
        initialCenter: center,
        initialZoom: bounds != null ? 3 : 11,
        markers: markers,
        routes: routes,
        showUserLocation: false,
        showCompass: false,
        enableScrollGestures: false,
        enableRotateGestures: false,
        enableTiltGestures: false,
        enableZoomGestures: false,
        onMapCreated: bounds != null
            ? (controller) {
                controller.fitBounds(
                  bounds,
                  padding: const EdgeInsets.fromLTRB(36, 72, 36, 32),
                );
              }
            : null,
      );
    }

    final coverUrl = trip.coverPhotoUrl?.trim();
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl,
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: AppColors.divider,
      child: const Icon(
        Icons.landscape,
        size: 44,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildHeaderCard(PublicTrip trip) {
    final metaParts = <String>[];
    if (trip.placeCount > 0) {
      metaParts.add('${trip.placeCount} places');
    }
    if (trip.duration != null && trip.duration! > 0) {
      metaParts.add('${trip.duration} days');
    }

    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
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
          Row(
            children: [
              if (metaParts.isNotEmpty) ...[
                Icon(Icons.place, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  metaParts.join(' | '),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (metaParts.isNotEmpty && trip.viewCount > 0)
                const SizedBox(width: AppSpacing.md),
              if (trip.viewCount > 0) ...[
                Icon(Icons.visibility_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatCount(trip.viewCount),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (trip.description != null &&
              trip.description!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              trip.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (trip.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: trip.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.accentSoft,
                      labelStyle: const TextStyle(color: AppColors.accent),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  Widget _buildTimeline(
    BuildContext context,
    WidgetRef ref,
    TripDetailState state,
  ) {
    final items = _buildTimelineItems(state.data.places, state.data.routes);

    return ListView.builder(
      padding: AppSpacing.horizontalMd.add(
        const EdgeInsets.only(bottom: AppSpacing.xxl + AppSpacing.xl),
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
    final sortedPlaces = [...places]..sort(
        (a, b) => (a.orderIndex ?? 1 << 20).compareTo(b.orderIndex ?? 1 << 20),
      );
    final sortedRoutes = [...routes]..sort(
        (a, b) => (a.dayNumber ?? 1 << 20).compareTo(b.dayNumber ?? 1 << 20),
      );

    final items = <_TimelineItem>[
      ...sortedPlaces.map(
        (place) => _TimelineItem(
          sortKey: _placeSortKey(place.orderIndex),
          place: place,
        ),
      ),
      ...sortedRoutes.map(
        (route) => _TimelineItem(
          sortKey: _routeSortKey(route.dayNumber),
          route: route,
        ),
      ),
    ];

    items.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return items;
  }

  double _placeSortKey(int? orderIndex) {
    final order = (orderIndex ?? 1 << 20).toDouble();
    return order * 2;
  }

  double _routeSortKey(int? orderInTrip) {
    final order = (orderInTrip ?? 1 << 20).toDouble();
    return order * 2 + 1;
  }

  Widget _buildMapTab(TripDetailState state) {
    final markers = _buildMapMarkers(state.data.places);
    final routes = _buildMapRoutes(state.data.places, state.data.routes);
    final initialCenter = _resolveInitialCenter(state.data.places, routes);
    final bounds = _computeBounds(state.data.places, routes);

    if (markers.isEmpty && routes.isEmpty) {
      return _buildPlaceholder('No route data available for this trip.');
    }

    return Padding(
      padding: AppSpacing.horizontalMd,
      child: ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: AppMapView(
          initialCenter: initialCenter,
          initialZoom: bounds != null ? 3 : 11,
          markers: markers,
          routes: routes,
          showUserLocation: false,
          onMapCreated: bounds != null
              ? (AppMapController controller) {
                  controller.fitBounds(
                    bounds,
                    padding: const EdgeInsets.all(60),
                  );
                }
              : null,
        ),
      ),
    );
  }

  AppLatLngBounds? _computeBounds(
    List<TripPlace> places,
    List<AppRoute> routes,
  ) {
    final allPoints = <AppLatLng>[];
    for (final place in places) {
      allPoints.add(
        AppLatLng(latitude: place.latitude, longitude: place.longitude),
      );
    }
    for (final route in routes) {
      allPoints.addAll(route.coordinates);
    }
    if (allPoints.length < 2) return null;

    var minLat = allPoints.first.latitude;
    var maxLat = allPoints.first.latitude;
    var minLng = allPoints.first.longitude;
    var maxLng = allPoints.first.longitude;

    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return AppLatLngBounds(
      southwest: AppLatLng(latitude: minLat, longitude: minLng),
      northeast: AppLatLng(latitude: maxLat, longitude: maxLng),
    );
  }

  List<AppMarker> _buildMapMarkers(List<TripPlace> places) {
    if (places.isEmpty) {
      return const <AppMarker>[];
    }

    final sorted = [...places]..sort(
        (a, b) => (a.orderIndex ?? 1 << 20).compareTo(b.orderIndex ?? 1 << 20),
      );

    var placeCounter = 0;
    return sorted.map((place) {
      placeCounter += 1;
      return AppMarker(
        id: place.id,
        position:
            AppLatLng(latitude: place.latitude, longitude: place.longitude),
        title: place.name,
        markerType: 'place',
        label: '$placeCounter',
        color: AppColors.accent,
      );
    }).toList();
  }

  List<AppRoute> _buildMapRoutes(
      List<TripPlace> places, List<TripRoute> routes) {
    final mappedRoutes = <AppRoute>[];
    for (final route in routes) {
      if (route.coordinates.length < 2) {
        continue;
      }
      mappedRoutes.add(
        AppRoute(
          id: route.id,
          coordinates: route.coordinates
              .map(
                (point) => AppLatLng(
                  latitude: point.latitude,
                  longitude: point.longitude,
                ),
              )
              .toList(),
          color: _routeColor(route.transportMode),
          width: route.transportMode == 'air' ? 2.5 : 4,
          dashed: route.transportMode == 'air',
        ),
      );
    }

    if (mappedRoutes.isNotEmpty) {
      return mappedRoutes;
    }

    // Fallback connector lines when backend has no route geometries.
    final sortedPlaces = [...places]..sort(
        (a, b) => (a.orderIndex ?? 1 << 20).compareTo(b.orderIndex ?? 1 << 20),
      );

    for (var i = 0; i < sortedPlaces.length - 1; i += 1) {
      final start = sortedPlaces[i];
      final end = sortedPlaces[i + 1];
      mappedRoutes.add(
        AppRoute(
          id: 'connector_${start.id}_${end.id}',
          coordinates: [
            AppLatLng(latitude: start.latitude, longitude: start.longitude),
            AppLatLng(latitude: end.latitude, longitude: end.longitude),
          ],
          color: const Color(0xFFCCCCCC),
          width: 2,
          dashed: true,
        ),
      );
    }
    return mappedRoutes;
  }

  Color _routeColor(String? transportMode) {
    switch (transportMode) {
      case 'bike':
        return const Color(0xFF1D9A6C);
      case 'foot':
      case 'walk':
      case 'walking':
        return const Color(0xFFB96B2B);
      case 'air':
        return const Color(0xFF4F46E5);
      default:
        return AppColors.accent;
    }
  }

  AppLatLng _resolveInitialCenter(
      List<TripPlace> places, List<AppRoute> routes) {
    if (places.isNotEmpty) {
      final sorted = [...places]..sort(
          (a, b) =>
              (a.orderIndex ?? 1 << 20).compareTo(b.orderIndex ?? 1 << 20),
        );
      final first = sorted.first;
      return AppLatLng(latitude: first.latitude, longitude: first.longitude);
    }
    if (routes.isNotEmpty && routes.first.coordinates.isNotEmpty) {
      return routes.first.coordinates.first;
    }
    return const AppLatLng(latitude: 0, longitude: 0);
  }

  Widget _buildPhotosTab(TripDetailState state) {
    final photoItems = <_PhotoItem>[
      for (final place in state.data.places)
        for (final photoUrl in place.photoUrls)
          _PhotoItem(url: photoUrl, placeName: place.name),
    ];

    if (photoItems.isEmpty) {
      return _buildPlaceholder('No photos uploaded for this trip yet.');
    }

    return GridView.builder(
      padding: AppSpacing.horizontalMd.add(
        const EdgeInsets.only(bottom: AppSpacing.xl),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photoItems.length,
      itemBuilder: (context, index) {
        final item = photoItems[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: AppRadius.borderSm,
              child: CachedNetworkImage(
                imageUrl: item.url,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(
                  color: AppColors.divider,
                ),
                errorWidget: (context, _, __) => Container(
                  color: AppColors.divider,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    item.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
          '- All ${state.data.places.length} places\n'
          '- All ${state.data.routes.length} routes\n'
          '- Original photos and notes',
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

  void _handleBackNavigation(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.feed);
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

class _PhotoItem {
  const _PhotoItem({
    required this.url,
    required this.placeName,
  });

  final String url;
  final String placeName;
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
