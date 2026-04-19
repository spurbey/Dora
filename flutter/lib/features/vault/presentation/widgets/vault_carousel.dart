import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';

/// Horizontally-paged list of media thumbnails at the bottom of the Vault
/// screen. Acts as the counterpart to [VaultMap] — swiping updates the
/// selected media (which the map then flies to), and tapping a map marker
/// animates the carousel to that page.
class VaultCarousel extends ConsumerStatefulWidget {
  const VaultCarousel({super.key});

  @override
  ConsumerState<VaultCarousel> createState() => _VaultCarouselState();
}

class _VaultCarouselState extends ConsumerState<VaultCarousel> {
  late final PageController _controller;
  bool _suppressSelectionNotify = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.42);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _indexForId(List<MediaItem> items, String? id) {
    if (id == null) return null;
    for (var i = 0; i < items.length; i++) {
      if (items[i].id == id) return i;
    }
    return null;
  }

  Future<void> _animateTo(int page) async {
    if (!_controller.hasClients) return;
    _suppressSelectionNotify = true;
    await _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
    _suppressSelectionNotify = false;
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(vaultFilteredMediaProvider);
    final selectedId = ref.watch(vaultSelectedMediaIdProvider);

    // When selection changes from outside (e.g. map marker tap), snap the
    // carousel to that media's page.
    ref.listen<String?>(vaultSelectedMediaIdProvider, (_, next) {
      final index = _indexForId(items, next);
      if (index == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateTo(index);
      });
    });

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _controller,
        itemCount: items.length,
        padEnds: false,
        onPageChanged: (index) {
          if (_suppressSelectionNotify) return;
          final id = items[index].id;
          if (id == selectedId) return;
          ref.read(vaultSelectedMediaIdProvider.notifier).state = id;
        },
        itemBuilder: (context, index) {
          final item = items[index];
          return _CarouselCard(
            item: item,
            selected: item.id == selectedId,
          );
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.item,
    required this.selected,
  });

  final MediaItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage(item);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: selected ? 4 : 10,
      ),
      child: Material(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        elevation: selected ? 3 : 1,
        child: ClipRRect(
          borderRadius: AppRadius.borderMd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image == null)
                const ColoredBox(
                  color: AppColors.surface,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Image(image: image, fit: BoxFit.cover),
              Positioned(
                left: 6,
                bottom: 6,
                child: _CaptureBadge(capturedAt: item.capturedAt),
              ),
            ],
          ),
        ),
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

class _CaptureBadge extends StatelessWidget {
  const _CaptureBadge({required this.capturedAt});

  final DateTime capturedAt;

  @override
  Widget build(BuildContext context) {
    final local = capturedAt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    final label = _formatRelative(diff, local);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatRelative(Duration diff, DateTime capturedAt) {
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${capturedAt.month}/${capturedAt.day}';
  }
}
