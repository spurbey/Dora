import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/capture/domain/capture_models.dart';

/// Center-docked action in [NavigationShell]. Opens the full-screen in-app
/// camera runtime.
class CameraFab extends ConsumerWidget {
  const CameraFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'dora-camera-fab',
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      tooltip: 'Capture',
      onPressed: () => _openCamera(context),
      child: const Icon(Icons.camera_alt_outlined, size: 26),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final result = await context.push<CapturePersistResult>(
      Routes.cameraPath(),
      extra: const CameraLaunchArgs(
        context: CameraLaunchContext.fab,
        initialMode: CameraInitialMode.photo,
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          result.destination == CaptureDestination.storyDraft
              ? 'Saved as story draft'
              : result.attachedToTrip
                  ? 'Attached to ${result.tripName ?? 'active trip'}'
                  : 'Saved to Vault',
        ),
      ),
    );
  }
}
