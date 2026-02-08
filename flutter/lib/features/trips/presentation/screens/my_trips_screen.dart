import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/domain/trips_state.dart';
import 'package:dora/features/trips/presentation/providers/trips_provider.dart';
import 'package:dora/features/trips/presentation/widgets/filter_chip_bar.dart';
import 'package:dora/features/trips/presentation/widgets/trip_context_menu.dart';
import 'package:dora/features/trips/presentation/widgets/trip_grid_card.dart';
import 'package:dora/features/trips/presentation/widgets/trip_list_card.dart';
import 'package:dora/features/trips/presentation/widgets/trip_shimmer.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/empty_state.dart';
import 'package:dora/shared/widgets/error_view.dart';
import 'package:dora/shared/widgets/view_mode_toggle.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsControllerProvider);
    final controller = ref.read(tripsControllerProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.create),
        icon: const Icon(Icons.add),
        label: const Text('Create New Trip'),
        backgroundColor: AppColors.accent,
      ),
      body: SafeArea(
        child: tripsAsync.when(
          loading: () => _buildLoading(controller),
          error: (e, st) => ErrorView(
            message: "Couldn't load trips",
            onRetry: () => controller.refresh(),
          ),
          data: (state) => _buildContent(state, controller),
        ),
      ),
    );
  }

  Widget _buildLoading(TripsController controller) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(
          viewMode: TripsViewMode.grid,
          onViewModeChanged: (mode) {},
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSearchBar(controller),
        const SizedBox(height: AppSpacing.md),
        FilterChipBar(
          selected: TripsFilter.all,
          onChanged: (_) {},
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: AppSpacing.horizontalMd,
          child: _buildGridShimmer(),
        ),
      ],
    );
  }

  Widget _buildContent(TripsState state, TripsController controller) {
    final hasPendingSync =
        state.allTrips.any((trip) => trip.syncStatus == 'pending');
    final hasSyncFailed = state.syncFailed ||
        state.allTrips.any((trip) => trip.syncStatus == 'failed');

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => controller.refresh(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(
            viewMode: state.viewMode,
            onViewModeChanged: (mode) {
              if (mode != state.viewMode) {
                controller.toggleViewMode();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSearchBar(controller),
          const SizedBox(height: AppSpacing.md),
          FilterChipBar(
            selected: state.currentFilter,
            onChanged: controller.applyFilter,
          ),
          if (hasSyncFailed)
            _buildSyncBanner(
              message: 'Sync failed. Check your connection.',
              actionLabel: 'Retry',
              onAction: controller.refresh,
            )
          else if (hasPendingSync)
            _buildSyncBanner(
              message: 'Offline changes pending sync.',
            ),
          const SizedBox(height: AppSpacing.md),
          if (state.trips.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No trips yet',
                message:
                    'Create your first travelogue and start sharing your adventures',
                actionLabel: 'Create Your First Trip',
                onAction: () => context.go(Routes.create),
              ),
            )
          else
            Padding(
              padding: AppSpacing.horizontalMd,
              child: state.viewMode == TripsViewMode.grid
                  ? _buildGrid(state.trips)
                  : _buildList(state.trips),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required TripsViewMode viewMode,
    required ValueChanged<TripsViewMode> onViewModeChanged,
  }) {
    return Padding(
      padding: AppSpacing.horizontalMd,
      child: SizedBox(
        height: AppSpacing.xxl + AppSpacing.lg,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Trips', style: AppTypography.h1),
            ViewModeToggle(
              viewMode: viewMode,
              onChanged: onViewModeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(TripsController controller) {
    return Padding(
      padding: AppSpacing.horizontalMd,
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search trips...',
        leading: const Icon(Icons.search, color: AppColors.accent),
        backgroundColor: MaterialStateProperty.all(AppColors.card),
        elevation: const MaterialStatePropertyAll(0),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
        ),
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  Widget _buildGrid(List<UserTrip> trips) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return GestureDetector(
          onLongPress: () => _showTripMenu(trip),
          child: TripGridCard(
            trip: trip,
            onTap: () => context.push(Routes.editorPath(trip.id)),
          ),
        );
      },
    );
  }

  Widget _buildList(List<UserTrip> trips) {
    return Column(
      children: [
        for (final trip in trips)
          GestureDetector(
            onLongPress: () => _showTripMenu(trip),
            child: TripListCard(
              trip: trip,
              onTap: () => context.push(Routes.editorPath(trip.id)),
              onMenuTap: () => _showTripMenu(trip),
            ),
          ),
      ],
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) => const TripGridCardShimmer(),
    );
  }

  Widget _buildSyncBanner({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: AppSpacing.horizontalMd,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTripMenu(UserTrip trip) async {
    final controller = ref.read(tripsControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (_) => TripContextMenu(
        trip: trip,
        onEdit: () => context.push(Routes.editorPath(trip.id)),
        onDuplicate: () => _handleDuplicate(controller, trip.id),
        onShare: () => _handleShare(controller, trip),
        onExport: _handleExport,
        onDelete: () => _confirmDelete(controller, trip),
      ),
    );
  }

  Future<void> _handleDuplicate(
    TripsController controller,
    String tripId,
  ) async {
    final success = await controller.duplicateTrip(tripId);
    _showToast(success ? 'Trip duplicated' : "Couldn't duplicate trip");
  }

  Future<void> _handleShare(
    TripsController controller,
    UserTrip trip,
  ) async {
    final nextVisibility = trip.visibility == 'public' ? 'private' : 'public';
    final success = await controller.updateVisibility(trip.id, nextVisibility);
    if (success) {
      _showToast(nextVisibility == 'public'
          ? 'Visibility changed'
          : 'Trip set to private');
    } else {
      _showToast("Couldn't update visibility");
    }
  }

  void _handleExport() {
    _showToast('Export studio coming soon');
  }

  Future<void> _confirmDelete(TripsController controller, UserTrip trip) async {
    final message = 'This will permanently delete:\n'
        '- All places and routes\n'
        '- Photos and notes\n'
        '- Export history\n\n'
        'This cannot be undone.';

    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete "${trip.name}"?',
        message: message,
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          final success = await controller.deleteTrip(trip.id);
          _showToast(success ? 'Trip deleted' : "Couldn't delete trip");
        },
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
