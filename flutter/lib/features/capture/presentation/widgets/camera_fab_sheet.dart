import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/capture/presentation/providers/active_live_session_provider.dart';
import 'package:dora/features/capture/presentation/providers/camera_capture_controller.dart';

/// Bottom sheet shown when the user taps the Camera FAB. Offers three entry
/// points (photo / video / gallery) and surfaces an active-trip banner when a
/// live session is in progress.
class CameraFabSheet extends ConsumerWidget {
  const CameraFabSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeLiveSessionProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            activeSession.maybeWhen(
              data: (session) => session == null
                  ? const SizedBox.shrink()
                  : _ActiveSessionBanner(tripName: session.tripName),
              orElse: () => const SizedBox.shrink(),
            ),
            _SheetAction(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () => _handleTap(context, ref, CaptureKind.photo),
            ),
            _SheetAction(
              icon: Icons.videocam_outlined,
              label: 'Record Video',
              onTap: () => _handleTap(context, ref, CaptureKind.video),
            ),
            _SheetAction(
              icon: Icons.photo_library_outlined,
              label: 'Pick from Gallery',
              onTap: () => _handleTap(context, ref, CaptureKind.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    CaptureKind kind,
  ) async {
    Navigator.of(context).maybePop();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await ref
        .read(cameraCaptureControllerProvider.notifier)
        .captureAndPersist(kind: kind);
    if (messenger == null) {
      return;
    }
    final snack = _snackFor(result);
    if (snack != null) {
      messenger.showSnackBar(SnackBar(content: Text(snack)));
    }
  }

  String? _snackFor(CameraCaptureResult result) {
    switch (result.kind) {
      case CameraCaptureResultKind.cancelled:
        return null;
      case CameraCaptureResultKind.savedToVault:
        return 'Saved to Vault';
      case CameraCaptureResultKind.attachedToTrip:
        final name = result.tripName ?? 'your trip';
        return 'Attached to $name';
      case CameraCaptureResultKind.permissionDenied:
        return 'Permission required to capture media';
      case CameraCaptureResultKind.error:
        return result.errorMessage ?? 'Capture failed';
    }
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.tripName});

  final String tripName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_checked_outlined,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Attaching to $tripName',
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label, style: AppTypography.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
