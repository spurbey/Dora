import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/capture/presentation/widgets/camera_fab_sheet.dart';

/// Center-docked action in [NavigationShell]. Opens the camera capture sheet
/// which branches to either the live-tracking capture flow (when a session is
/// active) or a vault-scope media row.
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
      onPressed: () => _openSheet(context),
      child: const Icon(Icons.camera_alt_outlined, size: 26),
    );
  }

  Future<void> _openSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (_) => const CameraFabSheet(),
    );
  }
}
