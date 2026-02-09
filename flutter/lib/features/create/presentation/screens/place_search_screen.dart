import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
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

  Future<void> _addCurrentLocation() async {
    final position =
        await ref.read(locationServiceProvider).getCurrentPosition();
    if (position == null) {
      return;
    }
    final editor = ref.read(editorControllerProvider(widget.tripId)).valueOrNull;
    final orderIndex = editor?.places.length ?? 0;

    final place = Place(
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
    );

    ref.read(editorControllerProvider(widget.tripId).notifier).addPlace(place);
    if (mounted) {
      context.pop();
    }
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
            hintText: 'Search places...',
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: searchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'Search failed',
            style: AppTypography.caption,
          ),
        ),
        data: (state) {
          return ListView(
            padding: AppSpacing.allMd,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text('Quick Add', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _addCurrentLocation,
                icon: const Icon(Icons.place, color: AppColors.accent),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.results.isEmpty)
                Text(
                  'Start typing to search places.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else ...[
                Text('Results', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                for (final result in state.results)
                  Card(
                    child: ListTile(
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
                          ref
                              .read(editorControllerProvider(widget.tripId).notifier)
                              .addPlace(place);
                          context.pop();
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
}
