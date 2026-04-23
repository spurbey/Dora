import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/profile/data/models/user_profile.dart';
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
  bool _isDeletingAccount = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5EFE8),
              Color(0xFFE7F3F4),
              Color(0xFFF9F4EE),
            ],
          ),
        ),
        child: profileAsync.when(
          loading: () => const LoadingIndicator(
            size: 52,
            label: 'Preparing your settings...',
          ),
          error: (e, st) => ErrorView(
            message: "Couldn't load settings",
            onRetry: () =>
                ref.read(profileControllerProvider.notifier).refresh(),
          ),
          data: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          _buildHero(profile),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Account',
            subtitle: 'Manage credentials and account access.',
            children: [
              SettingsListItem(
                icon: Icons.alternate_email_rounded,
                title: 'Email',
                value: profile.email,
                onTap: () {},
                trailing: const SizedBox.shrink(),
              ),
              const _SectionDivider(),
              SettingsListItem(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: () => _showToast('Coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Preferences',
            subtitle: 'Shape how your trips are created and stored.',
            children: [
              SettingsListItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Default Trip Privacy',
                value: _defaultPrivacy,
                onTap: _showPrivacyPicker,
              ),
              const _SectionDivider(),
              SettingsListItem(
                icon: Icons.map_outlined,
                title: 'Offline Map Downloads',
                onTap: () => _showToast('Coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Storage',
            subtitle: 'Control local data and cache behavior.',
            children: [
              SettingsListItem(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear Cache',
                value: 'Clear local data',
                onTap: _confirmClearCache,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'About Dora',
            subtitle: 'Terms, privacy, and build information.',
            children: [
              SettingsListItem(
                icon: Icons.verified_user_outlined,
                title: 'Privacy Policy',
                onTap: () =>
                    _openUrl('https://doratravelapp.netlify.app/privacy_policy.html'),
              ),
              const _SectionDivider(),
              SettingsListItem(
                icon: Icons.gavel_outlined,
                title: 'Terms of Service',
                onTap: () => _openUrl(
                    'https://doratravelapp.netlify.app/terms_conditions.html'),
              ),
              const _SectionDivider(),
              SettingsListItem(
                icon: Icons.info_outline,
                title: 'Version',
                value: '0.1.0+1',
                onTap: () {},
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildHero(UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: AppSpacing.allLg,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderLg,
              border:
                  Border.all(color: AppColors.accent.withValues(alpha: 0.24)),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Dora Account',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: AppTypography.h3.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'These actions impact your account and cannot always be undone.',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: _confirmSignOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: _isDeletingAccount ? null : _confirmDeleteAccount,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(
                _isDeletingAccount ? 'Deleting account...' : 'Delete Account',
              ),
            ),
          ),
        ],
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
    if (!mounted) {
      return;
    }

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

  Future<void> _confirmDeleteAccount() async {
    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete account?',
        message:
            'This permanently deletes your account and all associated trip data. '
            'This action cannot be undone.',
        confirmText: 'Delete Account',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          await _deleteAccount();
        },
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) {
      return;
    }

    setState(() => _isDeletingAccount = true);

    try {
      await ref.read(profileControllerProvider.notifier).deleteAccount();
      if (mounted) {
        context.go(Routes.login);
      }
    } catch (_) {
      if (mounted) {
        _showToast('Failed to delete account. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(
        color: AppColors.divider.withValues(alpha: 0.75),
        height: 1,
      ),
    );
  }
}
