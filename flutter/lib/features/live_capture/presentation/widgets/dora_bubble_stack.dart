import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/core/widgets/dora_speech_bubble.dart';
import 'package:dora/features/live_capture/providers/dora_bubble_provider.dart';

/// Renders the active Dora speech bubble (if any) anchored to the
/// bottom-left of the live screen. One bubble visible at a time;
/// queue managed by [doraBubbleProvider].
///
/// **Position:** stacks just above the action dock so the user can see
/// both the bubble and what they were doing. Pointer triangle leans
/// up-left toward the Dora pill in the top-left corner — the pointer
/// orientation reads as "Dora is talking from up there."
///
/// **Tap handling:** advisory-source bubbles invoke [onAdvisoryTap]
/// with the matching advisory id (host wires this to opening the side
/// panel and focusing the message). All other sources just dismiss
/// the bubble — they're acknowledgements, not navigations.
class DoraBubbleStack extends ConsumerWidget {
  const DoraBubbleStack({
    super.key,
    required this.tripId,
    required this.onAdvisoryTap,
  });

  final String tripId;
  final ValueChanged<String> onAdvisoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doraBubbleProvider(tripId));
    final bubble = state.active;

    return AnimatedSwitcher(
      duration: DoraMotion.reveal,
      switchInCurve: DoraMotion.revealCurve,
      switchOutCurve: DoraMotion.dismissCurve,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: bubble == null
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : _BubbleEntry(
              key: ValueKey(bubble.id),
              bubble: bubble,
              onTap: () {
                final advisoryId = bubble.actionAdvisoryId;
                if (bubble.source == DoraBubbleSource.advisory &&
                    advisoryId != null) {
                  onAdvisoryTap(advisoryId);
                }
                ref
                    .read(doraBubbleProvider(tripId).notifier)
                    .dismiss(id: bubble.id);
              },
            ),
    );
  }
}

class _BubbleEntry extends StatelessWidget {
  const _BubbleEntry({
    super.key,
    required this.bubble,
    required this.onTap,
  });

  final DoraBubble bubble;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(bubble.source);
    return Padding(
      padding: const EdgeInsets.only(
        left: DoraSpacing.lg,
        right: DoraSpacing.xxl,
        bottom: DoraSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DoraSpeechBubble(
          color: color,
          pointerDirection: DoraBubblePointerDirection.up,
          pointerOffset: 0.15,
          maxWidth: 280,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  bubble.message,
                  textScaler: const TextScaler.linear(1.0),
                  style: DoraTypography.bubble.copyWith(
                    color: _textColorOn(color),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (bubble.source == DoraBubbleSource.advisory) ...[
                const SizedBox(width: DoraSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _textColorOn(color).withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorFor(DoraBubbleSource source) {
    switch (source) {
      case DoraBubbleSource.advisory:
        return DoraColors.advisory;
      case DoraBubbleSource.memoryCaptured:
        return DoraColors.surfaceCream;
      case DoraBubbleSource.eventAdded:
        return DoraColors.surfaceCream;
      case DoraBubbleSource.resolverResolved:
        return DoraColors.brandPrimary;
    }
  }

  /// Choose a contrasting text color for the bubble background.
  static Color _textColorOn(Color bg) {
    // Cream / mint backgrounds — dark ink. Brand/advisory backgrounds — white.
    if (bg == DoraColors.surfaceCream || bg == DoraColors.surfaceMint) {
      return DoraColors.inkPrimary;
    }
    return DoraColors.surfaceWhite;
  }
}
