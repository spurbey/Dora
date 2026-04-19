import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';
import 'package:dora/shared/widgets/empty_state.dart';

/// Compact Vault entry shown under the Profile "Vault" sub-tab. It only
/// advertises that the Vault exists and renders a short preview of recent
/// captures; tapping anywhere opens the full-screen [VaultScreen] via
/// [Routes.vault] so the map/carousel have the entire viewport.
class VaultTab extends ConsumerWidget {
  const VaultTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
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

    final mediaAsync = ref.watch(vaultAllMediaProvider);
    final preview = mediaAsync.maybeWhen(
      data: (items) => items.take(6).toList(growable: false),
      orElse: () => const <MediaItem>[],
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _VaultCard(
          count: mediaAsync.maybeWhen(
            data: (items) => items.length,
            orElse: () => 0,
          ),
          preview: preview,
          onTap: () => context.push(Routes.vault),
        ),
      ],
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.count,
    required this.preview,
    required this.onTap,
  });

  final int count;
  final List<MediaItem> preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasContent = preview.isNotEmpty;
    return Material(
      color: AppColors.card,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.collections_bookmark_outlined,
                      color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Your Vault', style: AppTypography.h3),
                  const Spacer(),
                  Text(
                    hasContent ? '$count item${count == 1 ? '' : 's'}' : 'Empty',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (hasContent)
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, index) =>
                        _PreviewTile(item: preview[index]),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    'Tap the camera in the nav to capture your first moment.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Open Vault  →',
                  style: AppTypography.body.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage(item);
    return ClipRRect(
      borderRadius: AppRadius.borderSm,
      child: SizedBox(
        width: 72,
        height: 72,
        child: image == null
            ? const ColoredBox(
                color: AppColors.surface,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textSecondary,
                ),
              )
            : Image(image: image, fit: BoxFit.cover),
      ),
    );
  }

  ImageProvider<Object>? _resolveImage(MediaItem item) {
    final thumb = item.thumbnailLocalPath;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http')) return NetworkImage(thumb);
      final file = File(thumb);
      if (file.existsSync()) return FileImage(file);
    }
    final localUri = item.localUri;
    if (localUri != null && localUri.isNotEmpty) {
      final file = File(localUri);
      if (file.existsSync()) return FileImage(file);
    }
    final url = item.remoteUrl;
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return null;
  }
}
