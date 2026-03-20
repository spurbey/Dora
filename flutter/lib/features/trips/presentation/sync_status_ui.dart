import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';

enum TripSyncUiKind {
  localSaved,
  syncing,
  synced,
  failed,
  blocked,
}

class TripSyncBadgeUi {
  const TripSyncBadgeUi({
    required this.kind,
    required this.label,
    required this.color,
  });

  final TripSyncUiKind kind;
  final String label;
  final Color color;
}

class TripsSyncBannerUi {
  const TripsSyncBannerUi({
    required this.message,
    required this.tint,
    this.showRetryAction = false,
  });

  final String message;
  final Color tint;
  final bool showRetryAction;
}

TripSyncBadgeUi resolveTripSyncBadgeUi(String rawStatus) {
  final normalized = rawStatus.trim().toLowerCase();
  switch (normalized) {
    case 'synced':
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.synced,
        label: 'Synced',
        color: AppColors.success,
      );
    case 'pending':
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.localSaved,
        label: 'Saved locally',
        color: AppColors.textSecondary,
      );
    case 'failed':
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.failed,
        label: 'Sync failed',
        color: AppColors.error,
      );
    case 'blocked':
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.blocked,
        label: 'Sync blocked',
        color: AppColors.warning,
      );
    case 'queued':
    case 'deferred':
    case 'in_progress':
    case 'syncing':
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.syncing,
        label: 'Syncing...',
        color: AppColors.accent,
      );
    default:
      return const TripSyncBadgeUi(
        kind: TripSyncUiKind.syncing,
        label: 'Syncing...',
        color: AppColors.accent,
      );
  }
}

TripsSyncBannerUi? resolveTripsSyncBannerUi({
  required Iterable<String> rawStatuses,
  required bool refreshFailed,
}) {
  if (refreshFailed) {
    return const TripsSyncBannerUi(
      message: 'Could not refresh trips. Showing cached data.',
      tint: AppColors.warning,
      showRetryAction: true,
    );
  }

  final kinds = rawStatuses
      .map(resolveTripSyncBadgeUi)
      .map((badge) => badge.kind)
      .where((kind) => kind != TripSyncUiKind.synced)
      .toSet();

  if (kinds.isEmpty) {
    return null;
  }
  if (kinds.contains(TripSyncUiKind.blocked)) {
    return const TripsSyncBannerUi(
      message: 'Some trips are sync blocked. Open the trip to resolve issues.',
      tint: AppColors.warning,
    );
  }
  if (kinds.contains(TripSyncUiKind.failed)) {
    return const TripsSyncBannerUi(
      message: 'Some trips failed to sync.',
      tint: AppColors.error,
      showRetryAction: true,
    );
  }
  if (kinds.contains(TripSyncUiKind.localSaved)) {
    return const TripsSyncBannerUi(
      message: 'Changes are saved locally and waiting to sync.',
      tint: AppColors.accent,
    );
  }
  return const TripsSyncBannerUi(
    message: 'Trips are syncing in the background.',
    tint: AppColors.accent,
  );
}
