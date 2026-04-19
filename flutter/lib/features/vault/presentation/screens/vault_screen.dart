import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';
import 'package:dora/features/vault/presentation/widgets/vault_carousel.dart';
import 'package:dora/features/vault/presentation/widgets/vault_filter_bar.dart';
import 'package:dora/features/vault/presentation/widgets/vault_map.dart';
import 'package:dora/shared/widgets/empty_state.dart';
import 'package:dora/shared/widgets/error_view.dart';

/// Full-screen Vault experience. Pushed from the "Vault" entry point inside
/// Profile. Map on top, thumbnail grid below — carousel + filter bar land in
/// the follow-up tasks.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return _scaffold(
        context,
        child: const _SignedOut(),
      );
    }

    final mediaAsync = ref.watch(vaultAllMediaProvider);
    return _scaffold(
      context,
      child: mediaAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => ErrorView(
          message: "Couldn't load vault",
          onRetry: () => ref.invalidate(vaultAllMediaProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _emptyState(context);
          }
          return const _VaultBody();
        },
      ),
    );
  }

  Widget _scaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
      ),
      body: child,
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(
          icon: Icons.photo_library_outlined,
          title: 'No media yet',
          message:
              'Tap the camera in the nav to capture your first moment.',
        ),
      ),
    );
  }
}

class _VaultBody extends ConsumerWidget {
  const _VaultBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(vaultFilteredMediaProvider);
    return Column(
      children: [
        const Expanded(
          child: VaultMap(),
        ),
        const VaultFilterBar(),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: _FilteredEmptyState(),
          )
        else ...[
          const VaultCarousel(),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No captures match this filter.',
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Sign in to see your Vault',
          message: 'Your captures show up here once you sign in',
        ),
      ),
    );
  }
}
