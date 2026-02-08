import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/presentation/providers/search_provider.dart';
import 'package:dora/features/feed/presentation/widgets/empty_state.dart';
import 'package:dora/features/feed/presentation/widgets/place_search_result.dart';
import 'package:dora/features/feed/presentation/widgets/trip_card.dart';
import 'package:dora/shared/widgets/error_view.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            Padding(
              padding: AppSpacing.horizontalMd,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                onChanged: controller.search,
                onSubmitted: controller.search,
                decoration: InputDecoration(
                  hintText: 'Type to search or ask...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                  filled: true,
                  fillColor: AppColors.card,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: const BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: searchState.when(
                loading: () => const LoadingIndicator(),
                error: (e, st) => ErrorView(
                  message: 'Search failed',
                  onRetry: () => controller.search(_controller.text),
                ),
                data: (state) => _buildBody(context, state, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SearchController controller,
  ) {
    return Padding(
      padding: AppSpacing.horizontalMd,
      child: SizedBox(
        height: AppSpacing.xxl + AppSpacing.sm,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _controller.clear();
                controller.search('');
                FocusScope.of(context).requestFocus(_focusNode);
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchState state,
    SearchController controller,
  ) {
    if (state.query == null || state.query!.isEmpty) {
      return ListView(
        padding: AppSpacing.horizontalMd,
        children: [
          Text(
            'QUICK ACTIONS',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ActionChip(
                label: const Text('Find Places'),
                avatar: const Icon(Icons.place, size: 18),
                backgroundColor: AppColors.accentSoft,
                onPressed: () => controller.searchNearby(),
              ),
              ActionChip(
                label: const Text('Ask Dora'),
                avatar: const Icon(Icons.chat_bubble_outline, size: 18),
                backgroundColor: AppColors.accentSoft,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  );
                },
              ),
              ActionChip(
                label: const Text('Plan Trip'),
                avatar: const Icon(Icons.flag, size: 18),
                backgroundColor: AppColors.accentSoft,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'RECENT SEARCHES',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.recentSearches.isEmpty)
            Text(
              'No recent searches yet',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...state.recentSearches.map(
              (item) => ListTile(
                leading: const Icon(Icons.history,
                    color: AppColors.textSecondary),
                title: Text(item, style: AppTypography.body),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.removeRecent(item),
                ),
                onTap: () {
                  _controller.text = item;
                  controller.search(item);
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'SUGGESTIONS',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _suggestion('Hidden gems in Paris'),
          _suggestion('Weekend trips from London'),
          _suggestion('Budget travel Southeast Asia'),
        ],
      );
    }

    if (state.places.isEmpty && state.trips.isEmpty) {
      return EmptyState(
        icon: Icons.search,
        title: 'No results for "${state.query}"',
        message: 'Try different keywords',
        actionLabel: 'Ask Dora',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          );
        },
      );
    }

    return ListView(
      padding: AppSpacing.horizontalMd,
      children: [
        if (state.places.isNotEmpty) ...[
          Text('PLACES', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          ...state.places.map(
            (place) => PlaceSearchResultCard(
              place: place,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
              onAdd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (state.trips.isNotEmpty) ...[
          Text('TRIPS', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          ...state.trips.map(
            (trip) => TripCard(
              trip: trip,
              onTap: () => context.go(Routes.tripDetailPath(trip.id)),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _suggestion(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        '• $text',
        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
