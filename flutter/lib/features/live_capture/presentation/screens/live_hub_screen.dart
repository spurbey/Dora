import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';

final liveHubActiveSessionProvider =
    StreamProvider.autoDispose<LiveHubActiveSession?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;
  if (userId == null || userId.isEmpty) {
    return Stream<LiveHubActiveSession?>.value(null);
  }
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT s.trip_id, s.state, s.local_updated_at, t.name
    FROM tracking_sessions s
    INNER JOIN trips t ON t.id = s.trip_id
    WHERE t.user_id = ?
      AND s.state IN ('active', 'paused')
    ORDER BY s.local_updated_at DESC
    LIMIT 1
    ''',
    variables: [Variable<String>(userId)],
    readsFrom: {db.trackingSessions, db.trips},
  );
  return query.watchSingleOrNull().map((row) {
    if (row == null) {
      return null;
    }
    return LiveHubActiveSession(
      tripId: row.read<String>('trip_id'),
      tripName: row.read<String>('name'),
      state: row.read<String>('state'),
      updatedAt: row.read<DateTime>('local_updated_at'),
    );
  });
});

final liveHubRecentTripsProvider =
    StreamProvider.autoDispose<List<LiveHubTripItem>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;
  if (userId == null || userId.isEmpty) {
    return Stream<List<LiveHubTripItem>>.value(const <LiveHubTripItem>[]);
  }

  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT id, name, sync_status, local_updated_at
    FROM trips
    WHERE user_id = ?
    ORDER BY local_updated_at DESC
    LIMIT 20
    ''',
    variables: [Variable<String>(userId)],
    readsFrom: {db.trips},
  );
  return query.watch().map((rows) {
    return rows
        .map(
          (row) => LiveHubTripItem(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            syncStatus: row.read<String>('sync_status'),
            localUpdatedAt: row.read<DateTime>('local_updated_at'),
          ),
        )
        .toList(growable: false);
  });
});

class LiveHubScreen extends ConsumerWidget {
  const LiveHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(liveHubActiveSessionProvider);
    final tripsAsync = ref.watch(liveHubRecentTripsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(liveHubActiveSessionProvider);
            ref.invalidate(liveHubRecentTripsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 120));
          },
          child: ListView(
            padding: AppSpacing.allMd,
            children: [
              const Text('Live', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Start or resume live capture for any trip.',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              activeSessionAsync.when(
                loading: () => const _LiveHubCardSkeleton(),
                error: (_, __) => const _LiveHubCardError(),
                data: (session) => _LiveHubPrimaryCard(session: session),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Recent trips', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              tripsAsync.when(
                loading: () => const _LiveHubTripListSkeleton(),
                error: (_, __) => const _LiveHubTripListError(),
                data: (trips) {
                  if (trips.isEmpty) {
                    return _LiveHubEmptyTrips(
                      onCreateTrip: () => context.go(Routes.create),
                    );
                  }
                  return Column(
                    children: trips
                        .map(
                          (trip) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _LiveHubTripTile(
                              trip: trip,
                              onTap: () =>
                                  context.go(Routes.liveCapturePath(trip.id)),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveHubPrimaryCard extends StatelessWidget {
  const _LiveHubPrimaryCard({required this.session});

  final LiveHubActiveSession? session;

  @override
  Widget build(BuildContext context) {
    final hasSession = session != null;
    final isPaused = session?.state == 'paused';
    final title = hasSession
        ? (isPaused ? 'Paused session ready' : 'Live session in progress')
        : 'Start a live trip';
    final subtitle = hasSession
        ? '${session!.tripName} is ${isPaused ? 'paused' : 'active'}.'
        : 'Pick a trip and begin runtime capture.';
    final actionLabel = hasSession ? 'Resume Live' : 'Start Live';

    return Container(
      key: const ValueKey('liveHubPrimaryCard'),
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('liveHubPrimaryAction'),
              onPressed: hasSession
                  ? () => context.go(Routes.liveCapturePath(session!.tripId))
                  : null,
              icon: Icon(
                  hasSession ? Icons.play_arrow : Icons.location_searching),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveHubTripTile extends StatelessWidget {
  const _LiveHubTripTile({
    required this.trip,
    required this.onTap,
  });

  final LiveHubTripItem trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final syncStatusLabel =
        trip.syncStatus == 'synced' ? 'Ready' : 'Sync required';
    final syncStatusColor =
        trip.syncStatus == 'synced' ? AppColors.success : AppColors.warning;
    return Material(
      color: AppColors.card,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        key: ValueKey('liveHubTripTile-${trip.id}'),
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allMd,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.name, style: AppTypography.body),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      syncStatusLabel,
                      style: AppTypography.caption.copyWith(
                        color: syncStatusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.tonal(
                onPressed: onTap,
                child: const Text('Open Live'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveHubEmptyTrips extends StatelessWidget {
  const _LiveHubEmptyTrips({required this.onCreateTrip});

  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('liveHubEmptyTrips'),
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('No trips yet', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a trip first, then you can start a live session.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onCreateTrip,
            child: const Text('Create trip'),
          ),
        ],
      ),
    );
  }
}

class _LiveHubCardSkeleton extends StatelessWidget {
  const _LiveHubCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
    );
  }
}

class _LiveHubTripListSkeleton extends StatelessWidget {
  const _LiveHubTripListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.divider),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveHubCardError extends StatelessWidget {
  const _LiveHubCardError();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('liveHubPrimaryError'),
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Unable to load live session state. Pull to refresh.',
        style: AppTypography.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _LiveHubTripListError extends StatelessWidget {
  const _LiveHubTripListError();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('liveHubTripsError'),
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Unable to load trips right now.',
        style: AppTypography.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class LiveHubActiveSession {
  const LiveHubActiveSession({
    required this.tripId,
    required this.tripName,
    required this.state,
    required this.updatedAt,
  });

  final String tripId;
  final String tripName;
  final String state;
  final DateTime updatedAt;
}

class LiveHubTripItem {
  const LiveHubTripItem({
    required this.id,
    required this.name,
    required this.syncStatus,
    required this.localUpdatedAt,
  });

  final String id;
  final String name;
  final String syncStatus;
  final DateTime localUpdatedAt;
}
