import 'package:dora_api/dora_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/advisory/presentation/widgets/dora_avatar.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';

/// Category → emoji + label + tint color.
class _CategoryDisplay {
  final String emoji;
  final String label;
  final Color tint;
  const _CategoryDisplay(this.emoji, this.label, this.tint);
}

const Map<String, _CategoryDisplay> _categoryMap = {
  'safety_warning': _CategoryDisplay('⚠️', 'Safety', Color(0xFFF59E0B)),
  'scam_alert': _CategoryDisplay('🚨', 'Scam Alert', Color(0xFFDC2626)),
  'food_tip': _CategoryDisplay('🍜', 'Food', Color(0xFFEA580C)),
  'photo_spot': _CategoryDisplay('📸', 'Photo Spot', Color(0xFF7C3AED)),
  'transport_tip': _CategoryDisplay('🚌', 'Transport', Color(0xFF2563EB)),
  'accommodation': _CategoryDisplay('🏨', 'Stay', Color(0xFF0891B2)),
  'cultural_etiquette': _CategoryDisplay('🙏', 'Culture', Color(0xFF7C3AED)),
  'must_do': _CategoryDisplay('🎯', 'Must Do', Color(0xFF059669)),
  'avoid': _CategoryDisplay('🚫', 'Avoid', Color(0xFFDC2626)),
  'general_tip': _CategoryDisplay('💡', 'Tip', AppColors.accent),
};

_CategoryDisplay _displayFor(String? category) {
  return _categoryMap[category ?? 'general_tip'] ??
      _categoryMap['general_tip']!;
}

/// Floating card shown above the bottom panel when a pending advisory exists.
///
/// Google-Maps-style compact suggestion card with Dora branding. Three
/// actions: Save (like), Navigate (open in external Maps), Dismiss. Swipe
/// right to dismiss. Tap body to open full detail in the bottom sheet.
class AdvisoryActiveCard extends ConsumerWidget {
  const AdvisoryActiveCard({
    super.key,
    required this.localTripId,
    required this.advisory,
    required this.onOpenDetail,
  });

  final String localTripId;
  final AdvisoryInsightResponse advisory;
  final VoidCallback onOpenDetail;

  Future<void> _openInMaps() async {
    final lat = advisory.placeLat;
    final lng = advisory.placeLng;
    final name = advisory.placeName ?? advisory.title;
    final Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}',
      );
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = _displayFor(advisory.category.name);
    final title = advisory.placeName?.trim().isNotEmpty == true
        ? advisory.placeName!
        : (advisory.title.isNotEmpty ? advisory.title : display.label);
    final body = advisory.body.trim();

    return Dismissible(
      key: ValueKey('advisory_card_${advisory.id}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        ref
            .read(advisoryActionNotifierProvider(localTripId).notifier)
            .recordAction(advisory.id, UserActionType.dismissed);
      },
      child: AnimatedContainer(
        duration: AnimationTokens.normal,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderLg,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenDetail,
              splashColor: display.tint.withValues(alpha: 0.1),
              highlightColor: display.tint.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Accent stripe + category chip
                    Container(
                      width: 4,
                      height: 56,
                      decoration: BoxDecoration(
                        color: display.tint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Category emoji
                    _CategoryBadge(emoji: display.emoji, tint: display.tint),
                    const SizedBox(width: AppSpacing.sm),
                    // Title + preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const DoraAvatar(size: 16),
                              const SizedBox(width: 4),
                              Text(
                                display.label,
                                style: AppTypography.caption.copyWith(
                                  color: display.tint,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          if (body.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    _ActionIcon(
                      icon: Icons.bookmark_outline,
                      tooltip: 'Save',
                      onTap: () {
                        ref
                            .read(advisoryActionNotifierProvider(localTripId)
                                .notifier)
                            .recordAction(
                              advisory.id,
                              UserActionType.liked,
                            );
                      },
                    ),
                    if (advisory.placeLat != null ||
                        advisory.placeName != null)
                      _ActionIcon(
                        icon: Icons.directions_outlined,
                        tooltip: 'Open in Maps',
                        onTap: _openInMaps,
                      ),
                    _ActionIcon(
                      icon: Icons.close,
                      tooltip: 'Dismiss',
                      onTap: () {
                        ref
                            .read(advisoryActionNotifierProvider(localTripId)
                                .notifier)
                            .recordAction(
                              advisory.id,
                              UserActionType.dismissed,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.emoji, required this.tint});

  final String emoji;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
