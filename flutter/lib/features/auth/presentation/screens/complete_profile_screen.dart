import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/auth/presentation/providers/profile_completion_provider.dart';
import 'package:dora/features/auth/presentation/widgets/auth_shell.dart';
import 'package:dora/features/profile/presentation/providers/profile_provider.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSaving = false;
  bool _seeded = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(profileCompletionStatusProvider);

    return statusAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: LoadingIndicator(
            label: 'Preparing your profile setup...',
          ),
        ),
      ),
      error: (error, _) => AuthShell(
        title: 'Complete your profile',
        subtitle: 'We could not fetch your profile details right now.',
        form: _ErrorCard(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileCompletionStatusProvider),
        ),
        footer: const SizedBox.shrink(),
      ),
      data: (status) {
        if (!status.requiresCompletion) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(Routes.feed);
            }
          });
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(label: 'Redirecting...'),
            ),
          );
        }

        _seedInitialValues(status);
        return AuthShell(
          title: 'Complete your profile',
          subtitle:
              'One last step before you continue. Set your public name details.',
          form: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Full name',
                    Icons.badge_outlined,
                  ),
                  validator: _validateFullName,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _inputDecoration(
                    'Username',
                    Icons.alternate_email_rounded,
                  ),
                  validator: _validateUsername,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Username can contain letters, numbers, and underscores.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const _ActionProgress(label: 'Saving profile...')
                        : const Text('Save and Continue'),
                  ),
                ),
              ],
            ),
          ),
          footer: const SizedBox.shrink(),
        );
      },
    );
  }

  void _seedInitialValues(ProfileCompletionStatus status) {
    if (_seeded) {
      return;
    }
    _fullNameController.text = status.fullName;
    _usernameController.text = status.username;
    _seeded = true;
  }

  String? _validateFullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Full name is required';
    }
    if (trimmed.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (trimmed.length > 255) {
      return 'Full name is too long';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < 3 || trimmed.length > 50) {
      return 'Username must be 3-50 characters';
    }
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(trimmed)) {
      return 'Use letters, numbers, and underscores only';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(profileCompletionRepositoryProvider);
      await repository.completeProfile(
        username: _usernameController.text,
        fullName: _fullNameController.text,
      );
      ref.invalidate(profileCompletionStatusProvider);
      ref.invalidate(profileControllerProvider);
      if (!mounted) {
        return;
      }
      context.go(Routes.feed);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionProgress extends StatelessWidget {
  const _ActionProgress({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 32,
          child: LoadingIndicator(
            size: 14,
            color: Colors.white,
            centered: false,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
