import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/stories/presentation/providers/stories_providers.dart';
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
          message: 'Tap the camera in the nav to capture your first moment.',
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
        const _VaultStoriesSection(),
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

class _VaultStoriesSection extends ConsumerWidget {
  const _VaultStoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(vaultStoryItemsProvider);
    return storiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: AppSpacing.horizontalMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Stories', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              for (final item in items) ...[
                _VaultStoryCard(item: item),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

class _VaultStoryCard extends ConsumerWidget {
  const _VaultStoryCard({required this.item});

  final VaultStoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.story.visibility.toLowerCase();
    final canPublish = status == 'draft' || status == 'failed';
    final canDelete = status != 'publishing';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StoryThumb(item: item),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.media?.mediaType == 'video'
                      ? 'Video Story'
                      : 'Photo Story',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 2),
                Text(
                  storyStatusLabel(item.story.visibility),
                  style: AppTypography.caption.copyWith(
                    color: status == 'failed'
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
                if ((item.story.lastErrorMessage ?? '').trim().isNotEmpty)
                  Text(
                    item.story.lastErrorMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.caption.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
          if (status == 'publishing')
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (canPublish)
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(storyPublishControllerProvider.notifier)
                      .publishLocalStory(item.story.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Story published')),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Story publish failed. See error below.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Publish'),
            ),
          if (canDelete)
            IconButton(
              onPressed: () async {
                await ref
                    .read(storyPublishControllerProvider.notifier)
                    .deleteStory(item);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Story removed')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}

class _StoryThumb extends StatelessWidget {
  const _StoryThumb({required this.item});

  final VaultStoryItem item;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (item.media?.localUri != null && item.media!.localUri!.isNotEmpty) {
      child = Image.file(
        File(item.media!.localUri!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, color: Colors.white),
      );
    } else if (item.media?.remoteThumbnailUrl != null &&
        item.media!.remoteThumbnailUrl!.isNotEmpty) {
      child = Image.network(
        item.media!.remoteThumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, color: Colors.white),
      );
    } else {
      child = const Icon(Icons.image, color: Colors.white);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 56,
        color: Colors.black26,
        child: child,
      ),
    );
  }
}
