import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/profile/presentation/providers/profile_provider.dart';
import 'package:dora/features/profile/presentation/widgets/settings_list_item.dart';
import 'package:dora/features/trips/presentation/providers/trips_provider.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/error_view.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _defaultPrivacy = 'Private';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorView(
          message: "Couldn't load settings",
          onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        ),
        data: (profile) => ListView(
          padding: AppSpacing.verticalMd,
          children: [
            _sectionHeader('ACCOUNT'),
            SettingsListItem(
              title: 'Email',
              value: profile.email,
              onTap: () {},
              trailing: const SizedBox.shrink(),
            ),
            SettingsListItem(
              title: 'Change Password',
              onTap: () => _showToast('Coming soon'),
            ),
            _sectionHeader('PREFERENCES'),
            SettingsListItem(
              title: 'Default Trip Privacy',
              value: _defaultPrivacy,
              onTap: _showPrivacyPicker,
            ),
            SettingsListItem(
              title: 'Offline Map Downloads',
              onTap: () => _showToast('Coming soon'),
            ),
            _sectionHeader('STORAGE'),
            SettingsListItem(
              title: 'Clear Cache',
              value: 'Clear local data',
              onTap: _confirmClearCache,
            ),
            _sectionHeader('ABOUT'),
            SettingsListItem(
              title: 'Privacy Policy',
              onTap: () => _openUrl('https://dora.app/privacy'),
            ),
            SettingsListItem(
              title: 'Terms of Service',
              onTap: () => _openUrl('https://dora.app/terms'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version', style: AppTypography.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '0.1.0+1',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: AppSpacing.horizontalMd,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: _confirmSignOut,
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _showPrivacyPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Private'),
            onTap: () {
              setState(() => _defaultPrivacy = 'Private');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Public'),
            onTap: () {
              setState(() => _defaultPrivacy = 'Public');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCache() async {
    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Clear cache?',
        message: 'This will remove local data from this device.',
        confirmText: 'Clear',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          await ref.read(profileControllerProvider.notifier).clearCache();
          _showToast('Cache cleared');
        },
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final hasPending =
        await ref.read(tripsRepositoryProvider).hasPendingChanges();

    final message = hasPending
        ? 'You have unsaved changes. Sign out anyway?'
        : 'Make sure all changes are synced.';

    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Sign out?',
        message: message,
        confirmText: 'Sign Out',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          await ref.read(profileControllerProvider.notifier).signOut();
          if (mounted) {
            context.go(Routes.login);
          }
        },
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showToast('Could not open link');
    }
  }
}
