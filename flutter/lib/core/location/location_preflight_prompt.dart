import 'package:flutter/material.dart';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

enum LocationPreflightContext {
  startup,
  cameraFab,
}

Future<LocationAccessState> runLocationPreflightPrompt({
  required BuildContext context,
  required LocationPermissionService permissionService,
  required LocationPreflightContext preflightContext,
}) async {
  var state = await permissionService.ensurePermissionStatus(
    requestIfDenied: true,
  );
  if (!context.mounted) {
    return state;
  }
  if (state == LocationAccessState.granted) {
    return state;
  }

  switch (state) {
    case LocationAccessState.denied:
      final action = await _showLocationDialog(
        context: context,
        title: 'Allow Location Permission',
        message: preflightContext == LocationPreflightContext.startup
            ? 'Location permission is needed for nearby stories and feed relevance. Allow location access to continue with full experience.'
            : 'Location permission is needed for story publishing and trip-linked captures.',
        actions: const [
          _LocationDialogAction.notNow,
          _LocationDialogAction.tryAgain,
          _LocationDialogAction.openSettings,
        ],
      );
      if (!context.mounted) return state;
      if (action == _LocationDialogAction.tryAgain) {
        state = await permissionService.ensurePermissionStatus(
          requestIfDenied: true,
        );
      } else if (action == _LocationDialogAction.openSettings) {
        await permissionService.openAppSettings();
        state = await permissionService.ensurePermissionStatus(
          requestIfDenied: false,
        );
      }
      return state;
    case LocationAccessState.deniedForever:
      final action = await _showLocationDialog(
        context: context,
        title: 'Allow Location Permission',
        message:
            'Location permission is permanently denied. Open app settings to enable location access.',
        actions: const [
          _LocationDialogAction.notNow,
          _LocationDialogAction.openSettings,
        ],
      );
      if (!context.mounted) return state;
      if (action == _LocationDialogAction.openSettings) {
        await permissionService.openAppSettings();
        state = await permissionService.ensurePermissionStatus(
          requestIfDenied: false,
        );
      }
      return state;
    case LocationAccessState.serviceDisabled:
      final action = await _showLocationDialog(
        context: context,
        title: 'Turn On Location Services',
        message: preflightContext == LocationPreflightContext.startup
            ? 'Location services are off. Enable location to use stories and feed discovery properly.'
            : 'Location services are off. Enable location for story publishing and capture routing.',
        actions: const [
          _LocationDialogAction.notNow,
          _LocationDialogAction.openLocationSettings,
        ],
      );
      if (!context.mounted) return state;
      if (action == _LocationDialogAction.openLocationSettings) {
        await permissionService.openLocationSettings();
        state = await permissionService.ensurePermissionStatus(
          requestIfDenied: false,
        );
      }
      return state;
    case LocationAccessState.granted:
      return state;
  }
}

Future<_LocationDialogAction> _showLocationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required List<_LocationDialogAction> actions,
}) async {
  final primaryAction = _primaryAction(actions);
  final secondaryActions = actions
      .where((action) => action != primaryAction)
      .toList(growable: false);

  final action = await showDialog<_LocationDialogAction>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSoft,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: AppColors.accent,
                size: 42,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dora',
              style: AppTypography.h3.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final option in secondaryActions) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(option),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(_actionLabel(option)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(primaryAction),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(_actionLabel(primaryAction)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return action ?? _LocationDialogAction.notNow;
}

_LocationDialogAction _primaryAction(List<_LocationDialogAction> actions) {
  if (actions.contains(_LocationDialogAction.openLocationSettings)) {
    return _LocationDialogAction.openLocationSettings;
  }
  if (actions.contains(_LocationDialogAction.tryAgain)) {
    return _LocationDialogAction.tryAgain;
  }
  if (actions.contains(_LocationDialogAction.openSettings)) {
    return _LocationDialogAction.openSettings;
  }
  return actions.last;
}

String _actionLabel(_LocationDialogAction action) {
  switch (action) {
    case _LocationDialogAction.notNow:
      return 'Not now';
    case _LocationDialogAction.tryAgain:
      return 'Try Again';
    case _LocationDialogAction.openSettings:
      return 'Open Settings';
    case _LocationDialogAction.openLocationSettings:
      return 'Enable Location';
  }
}

enum _LocationDialogAction {
  notNow,
  tryAgain,
  openSettings,
  openLocationSettings,
}
