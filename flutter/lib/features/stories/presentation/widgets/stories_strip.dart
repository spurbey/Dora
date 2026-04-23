import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/stories/data/models/story_models.dart';
import 'package:dora/features/stories/presentation/providers/stories_providers.dart';
import 'package:dora/features/stories/presentation/screens/story_viewer_screen.dart';

class StoriesStrip extends ConsumerWidget {
  const StoriesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(storyFeedControllerProvider);

    return stateAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (error, _) => Padding(
        padding: AppSpacing.horizontalMd,
        child: Row(
          children: [
            const Icon(Icons.auto_stories_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Stories unavailable',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(storyFeedControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.horizontalMd,
              child: Row(
                children: [
                  Text('Stories', style: AppTypography.h3),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: StoryRadiusFilter.values.map((radius) {
                      final selected = state.radius == radius;
                      return ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(radius.label),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(storyFeedControllerProvider.notifier)
                            .setRadius(radius),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: AppSpacing.horizontalMd,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _StoryBubble(
                    item: item,
                    onTap: () => _openViewer(context, state.items, index),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: state.items.length,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  Future<void> _openViewer(
    BuildContext context,
    List<StoryFeedItem> items,
    int initialIndex,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerScreen(
          items: items,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.item,
    required this.onTap,
  });

  final StoryFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = item.thumbnailUrl ?? item.mediaUrl;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: item.isOwn
                  ? const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentSoft],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE87722), Color(0xFFF4C542)],
                    ),
            ),
            child: ClipOval(
              child: thumb == null
                  ? Container(
                      color: Colors.black26,
                      child: Icon(
                        item.mediaType == StoryMediaType.video
                            ? Icons.play_circle_fill
                            : Icons.image,
                        color: Colors.white,
                      ),
                    )
                  : Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black26,
                        child:
                            const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              item.isOwn ? 'You' : '@${item.authorUserId.substring(0, 6)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
