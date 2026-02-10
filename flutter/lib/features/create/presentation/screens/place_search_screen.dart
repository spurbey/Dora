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

class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlace(Place place) {
    ref
        .read(editorControllerProvider(widget.tripId).notifier)
        .addPlace(place);
    if (mounted) {
      context.pop();
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

    _addPlace(Place(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: 'Current Location',
      coordinates: AppLatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
      orderIndex: orderIndex,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    ));
  }

  void _addCustomPlace(String name) {
    final editor =
        ref.read(editorControllerProvider(widget.tripId)).valueOrNull;
    final orderIndex = editor?.places.length ?? 0;

    _addPlace(Place(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: name,
      coordinates: const AppLatLng(latitude: 0, longitude: 0),
      orderIndex: orderIndex,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(placeSearchControllerProvider);
    final searchController =
        ref.read(placeSearchControllerProvider.notifier);
    final editorState = ref.watch(editorControllerProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search or type a place name...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: searchController.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            onPressed: _addCurrentLocation,
          ),
        ],
      ),
      body: searchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildOfflineBody(),
        data: (state) {
          final query = _controller.text.trim();
          final hasQuery = query.isNotEmpty;
          final showSearching = state.searching && state.results.isEmpty;

          return ListView(
            padding: AppSpacing.allMd,
            children: [
              // Quick Add section
              Text('Quick Add', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _addCurrentLocation,
                icon: const Icon(Icons.my_location, color: AppColors.accent),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Custom place button — always visible when user typed something
              if (hasQuery) ...[
                Card(
                  color: AppColors.accentSoft,
                  child: ListTile(
                    leading: const Icon(Icons.add_location,
                        color: AppColors.accent),
                    title: Text('Add "$query"',
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Create place manually'),
                    onTap: () => _addCustomPlace(query),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Offline banner
              if (state.offline) ...[
                Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off,
                          size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Search unavailable offline. Type a name and tap "Add" above.',
                          style: AppTypography.caption
                              .copyWith(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Searching indicator
              if (showSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Results
              if (state.results.isEmpty && !state.offline && !showSearching)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Text(
                    hasQuery
                        ? 'No results found. Tap "Add" above to create manually.'
                        : 'Start typing to search places.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              if (state.results.isNotEmpty) ...[
                Text('Results', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                for (final result in state.results)
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.place, color: AppColors.accent),
                      title: Text(result.name),
                      subtitle: Text(result.address ?? result.category),
                      trailing: TextButton(
                        onPressed: () {
                          final orderIndex =
                              editorState.valueOrNull?.places.length ?? 0;
                          final place = ref
                              .read(placeRepositoryProvider)
                              .createFromSearchResult(
                                tripId: widget.tripId,
                                result: result,
                                orderIndex: orderIndex,
                              );
                          _addPlace(place);
                        },
                        child: const Text('+ Add'),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfflineBody() {
    final query = _controller.text.trim();
    return ListView(
      padding: AppSpacing.allMd,
      children: [
        Text('Quick Add', style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _addCurrentLocation,
          icon: const Icon(Icons.my_location, color: AppColors.accent),
          label: const Text('Use Current Location'),
        ),
        const SizedBox(height: AppSpacing.md),
        if (query.isNotEmpty)
          Card(
            color: AppColors.accentSoft,
            child: ListTile(
              leading:
                  const Icon(Icons.add_location, color: AppColors.accent),
              title: Text('Add "$query"'),
              subtitle: const Text('Create place manually'),
              onTap: () => _addCustomPlace(query),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.allSm,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Search unavailable. Type a name to add places manually.',
                  style: AppTypography.caption
                      .copyWith(color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
