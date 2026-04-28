import 'package:flutter/material.dart';

import 'package:dora/core/location/location_permission.dart';

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
  final action = await showDialog<_LocationDialogAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        for (final option in actions)
          TextButton(
            onPressed: () => Navigator.of(context).pop(option),
            child: Text(_actionLabel(option)),
          ),
      ],
    ),
  );
  return action ?? _LocationDialogAction.notNow;
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
