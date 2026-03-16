import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/place_search_provider.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';

class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _searchFocusNode;
  AppLatLng? _searchOrigin;
  static const _defaultSearchOrigin = AppLatLng(
    latitude: 20.5937,
    longitude: 78.9629,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapSearchOrigin();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addPlace(Place place) {
    ref.read(editorControllerProvider(widget.tripId).notifier).addPlace(place);
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _bootstrapSearchOrigin() async {
    final editorOrigin = _resolveEditorOrigin();
    if (editorOrigin != null) {
      _setSearchOrigin(editorOrigin);
    }

    final position =
        await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted || position == null) {
      return;
    }
    _setSearchOrigin(AppLatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }

  AppLatLng? _resolveEditorOrigin() {
    final editor =
        ref.read(editorControllerProvider(widget.tripId)).valueOrNull;
    final centerPoint = editor?.trip.centerPoint;
    if (centerPoint != null) {
      return centerPoint;
    }
    if ((editor?.places ?? const <Place>[]).isNotEmpty) {
      return editor!.places.first.coordinates;
    }
    return null;
  }

  void _setSearchOrigin(AppLatLng origin) {
    _searchOrigin = origin;
    final notifier = ref.read(placeSearchControllerProvider.notifier);
    notifier.setSearchOrigin(origin);
    final query = _controller.text.trim();
    if (query.length >= 2) {
      notifier.search(query);
    }
  }

  Future<void> _addCurrentLocation() async {
    final position =
        await ref.read(locationServiceProvider).getCurrentPosition();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
      return;
    }
    final editor =
        ref.read(editorControllerProvider(widget.tripId)).valueOrNull;
    final orderIndex = editor?.places.length ?? 0;
    final currentCoordinates = AppLatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    _setSearchOrigin(currentCoordinates);

    _addPlace(Place(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: 'Current Location',
      coordinates: currentCoordinates,
      orderIndex: orderIndex,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    ));
  }

  void _addCustomPlace(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final editor =
        ref.read(editorControllerProvider(widget.tripId)).valueOrNull;
    final orderIndex = editor?.places.length ?? 0;
    final coordinates =
        _searchOrigin ?? _resolveEditorOrigin() ?? _defaultSearchOrigin;

    _addPlace(Place(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: trimmed,
      coordinates: coordinates,
      orderIndex: orderIndex,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(placeSearchControllerProvider);
    final searchController = ref.read(placeSearchControllerProvider.notifier);
    final editorState = ref.watch(editorControllerProvider(widget.tripId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Add Place'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Use current location',
            icon: const Icon(Icons.gps_fixed),
            onPressed: _addCurrentLocation,
          ),
        ],
      ),
      body: searchAsync.when(
        loading: () => _buildBody(
          state: const PlaceSearchState(searching: true),
          searchController: searchController,
          editorState: editorState,
        ),
        error: (_, __) => _buildBody(
          state: const PlaceSearchState(offline: true),
          searchController: searchController,
          editorState: editorState,
        ),
        data: (state) => _buildBody(
          state: state,
          searchController: searchController,
          editorState: editorState,
        ),
      ),
    );
  }

  Widget _buildBody({
    required PlaceSearchState state,
    required PlaceSearchController searchController,
    required AsyncValue editorState,
  }) {
    final query = _controller.text.trim();
    final hasQuery = query.isNotEmpty;
    final showSearching = state.searching && state.results.isEmpty;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.08),
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.divider.withOpacity(0.7)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find a place or add one manually',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                focusNode: _searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search cafes, attractions, hotels...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: hasQuery
                      ? IconButton(
                          onPressed: () {
                            _controller.clear();
                            searchController.search('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  searchController.search(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionChip(
                      icon: Icons.my_location_outlined,
                      label: 'Current Location',
                      onTap: _addCurrentLocation,
                    ),
                  ),
                  if (hasQuery) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _QuickActionChip(
                          key: ValueKey(query),
                          icon: Icons.add_location_alt_outlined,
                          label: 'Add "$query"',
                          accent: true,
                          onTap: () => _addCustomPlace(query),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _buildResultBody(
              key: ValueKey(
                '${state.offline}_${state.searching}_${state.results.length}_$query',
              ),
              state: state,
              hasQuery: hasQuery,
              showSearching: showSearching,
              editorState: editorState,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBody({
    required Key key,
    required PlaceSearchState state,
    required bool hasQuery,
    required bool showSearching,
    required AsyncValue editorState,
  }) {
    if (showSearching) {
      return Center(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Searching nearby places...',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.offline) {
      return _InfoPanel(
        key: key,
        icon: Icons.cloud_off,
        title: 'Search is offline right now',
        subtitle: hasQuery
            ? 'Tap "Add \"${_controller.text.trim()}\"" '
                'above to create this place manually.'
            : 'Type a place name and add it manually from the quick action.',
      );
    }

    if (state.results.isEmpty) {
      return _InfoPanel(
        key: key,
        icon: hasQuery ? Icons.search_off : Icons.travel_explore_outlined,
        title: hasQuery ? 'No matching places' : 'Start typing to search',
        subtitle: hasQuery
            ? 'Try a shorter keyword, or add this place manually.'
            : 'We will show nearby matches as you type.',
      );
    }

    return ListView.builder(
      key: key,
      padding: AppSpacing.allMd,
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final result = state.results[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 180 + (index * 35).clamp(0, 260)),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SearchResultCard(
              result: result,
              distanceLabel: _distanceLabel(result),
              onAdd: () {
                final orderIndex = editorState.valueOrNull?.places.length ?? 0;
                final place =
                    ref.read(placeRepositoryProvider).createFromSearchResult(
                          tripId: widget.tripId,
                          result: result,
                          orderIndex: orderIndex,
                        );
                _addPlace(place);
              },
            ),
          ),
        );
      },
    );
  }

  String? _distanceLabel(PlaceSearchResult result) {
    final origin = _searchOrigin;
    final lat = result.latitude;
    final lng = result.longitude;
    if (origin == null || lat == null || lng == null) {
      return null;
    }
    final km = _distanceInKm(
      origin.latitude,
      origin.longitude,
      lat,
      lng,
    );
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double degree) => degree * (math.pi / 180);
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: accent ? AppColors.accent : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent ? AppColors.accent : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: accent ? Colors.white : AppColors.accent,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: accent ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Container(
          width: double.infinity,
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: AppColors.accent),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.distanceLabel,
    required this.onAdd,
  });

  final PlaceSearchResult result;
  final String? distanceLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        (result.address != null && result.address!.trim().isNotEmpty)
            ? result.address!
            : result.category;
    final ratingText =
        result.rating == null ? null : result.rating!.toStringAsFixed(1);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: AppColors.divider.withOpacity(0.7)),
      ),
      child: Padding(
        padding: AppSpacing.allSm,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.place_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MetaBadge(label: result.category.toUpperCase()),
                      if (distanceLabel != null)
                        _MetaBadge(
                          icon: Icons.near_me_outlined,
                          label: distanceLabel!,
                        ),
                      if (ratingText != null)
                        _MetaBadge(
                          icon: Icons.star_rounded,
                          label: ratingText,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(68, 36),
                elevation: 0,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
