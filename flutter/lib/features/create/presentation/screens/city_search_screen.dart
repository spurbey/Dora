import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/presentation/providers/city_search_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(citySearchControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add a City',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Search for a city or destination...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(citySearchControllerProvider.notifier)
                              .clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
              onChanged: (query) {
                ref
                    .read(citySearchControllerProvider.notifier)
                    .search(query);
                setState(() {});
              },
            ),
          ),

          // Results
          Expanded(
            child: searchState.when(
              data: (results) {
                if (_searchController.text.trim().length < 2) {
                  return _buildHintState();
                }
                if (results.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildResultsList(results);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Something went wrong. Try again.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_city,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search for your destination',
              style: AppTypography.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Type at least 2 characters to search',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'No cities found for "${_searchController.text}"',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildResultsList(List<GeocodingResult> results) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: AppSpacing.md + 40,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final result = results[index];
        return _CityResultTile(
          result: result,
          onTap: () => _addCity(result),
        );
      },
    );
  }

  void _addCity(GeocodingResult result) {
    final editorState = ref.read(editorControllerProvider(widget.tripId));
    final editor = editorState.valueOrNull;

    final now = DateTime.now();
    final nextOrder =
        (editor?.places.length ?? 0) + (editor?.routes.length ?? 0);

    final city = Place(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: result.name,
      address: result.country,
      coordinates: result.coordinates,
      placeType: 'city',
      orderIndex: nextOrder,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );

    ref
        .read(editorControllerProvider(widget.tripId).notifier)
        .addPlace(city);

    Navigator.of(context).pop();
  }
}

class _CityResultTile extends StatelessWidget {
  const _CityResultTile({
    required this.result,
    required this.onTap,
  });

  final GeocodingResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_city,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        result.name,
        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: result.country != null
          ? Text(
              result.country!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.add_circle_outline,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }
}
