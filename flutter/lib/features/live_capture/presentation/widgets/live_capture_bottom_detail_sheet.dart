import 'package:dora_api/dora_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';

/// Sealed content types rendered by [LiveCaptureBottomDetailSheet].
sealed class BottomSheetContent {
  const BottomSheetContent();
}

class AdvisoryPoiDetail extends BottomSheetContent {
  const AdvisoryPoiDetail(this.advisory);
  final AdvisoryInsightResponse advisory;
}

class CapturedMediaDetail extends BottomSheetContent {
  const CapturedMediaDetail({required this.eventId, required this.title});
  final String eventId;
  final String title;
}

class PlaceDetail extends BottomSheetContent {
  const PlaceDetail({required this.placeId, required this.placeName});
  final String placeId;
  final String placeName;
}

const Map<String, (String, Color)> _categoryMap = {
  'safety_warning': ('⚠️ Safety', Color(0xFFF59E0B)),
  'scam_alert': ('🚨 Scam Alert', Color(0xFFDC2626)),
  'food_tip': ('🍜 Food', Color(0xFFEA580C)),
  'photo_spot': ('📸 Photo Spot', Color(0xFF7C3AED)),
  'transport_tip': ('🚌 Transport', Color(0xFF2563EB)),
  'accommodation': ('🏨 Stay', Color(0xFF0891B2)),
  'cultural_etiquette': ('🙏 Culture', Color(0xFF7C3AED)),
  'must_do': ('🎯 Must Do', Color(0xFF059669)),
  'avoid': ('🚫 Avoid', Color(0xFFDC2626)),
  'general_tip': ('💡 Tip', AppColors.accent),
};

/// Draggable bottom sheet that slides up with POI / photo / place detail.
///
/// Tapped map marker or active card triggers this sheet. Dismissable by
/// drag-down or tap-outside (via [onDismiss]).
class LiveCaptureBottomDetailSheet extends ConsumerWidget {
  const LiveCaptureBottomDetailSheet({
    super.key,
    required this.localTripId,
    required this.content,
    required this.onDismiss,
  });

  final String localTripId;
  final BottomSheetContent content;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Backdrop (tap to close)
        GestureDetector(
          onTap: onDismiss,
          child: AnimatedContainer(
            duration: AnimationTokens.normal,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ),
        // Draggable sheet
        DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.2,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.45, 0.92],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _DragHandle(),
                  Expanded(
                    child: _buildContent(
                      context,
                      ref,
                      scrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    return switch (content) {
      AdvisoryPoiDetail(advisory: final a) => _AdvisoryDetailView(
          advisory: a,
          localTripId: localTripId,
          scrollController: scrollController,
          onDismiss: onDismiss,
        ),
      CapturedMediaDetail(eventId: final _, title: final title) =>
        _SimpleDetailPlaceholder(
          title: title,
          subtitle: 'Photo review coming soon',
          scrollController: scrollController,
        ),
      PlaceDetail(placeId: final _, placeName: final name) =>
        _SimpleDetailPlaceholder(
          title: name,
          subtitle: 'Place detail coming soon',
          scrollController: scrollController,
        ),
    };
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.only(top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Advisory detail
// ──────────────────────────────────────────────────────────────────

class _AdvisoryDetailView extends ConsumerWidget {
  const _AdvisoryDetailView({
    required this.advisory,
    required this.localTripId,
    required this.scrollController,
    required this.onDismiss,
  });

  final AdvisoryInsightResponse advisory;
  final String localTripId;
  final ScrollController scrollController;
  final VoidCallback onDismiss;

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
    final categoryKey = advisory.category.name;
    final tuple = _categoryMap[categoryKey] ?? _categoryMap['general_tip']!;
    final label = tuple.$1;
    final tint = tuple.$2;
    final placeName = advisory.placeName?.trim();
    final title = (placeName?.isNotEmpty == true) ? placeName! : advisory.title;
    final confidence = advisory.confidenceScore;
    final sourceLabel = _formatSource(advisory.source_);

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTypography.h2),
          const SizedBox(height: 4),
          Row(
            children: [
              _ConfidenceDot(confidence: confidence.toDouble()),
              const SizedBox(width: 6),
              Text(
                '${(confidence * 100).round()}% confident',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Source: $sourceLabel',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            advisory.body,
            style: AppTypography.body.copyWith(height: 1.5),
          ),
          if (advisory.contextSignal?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      advisory.contextSignal!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          // Actions
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.bookmark_outline,
                  label: 'Save',
                  filled: true,
                  onTap: () {
                    ref
                        .read(advisoryActionNotifierProvider(localTripId)
                            .notifier)
                        .recordAction(advisory.id, UserActionType.liked);
                    onDismiss();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (advisory.placeLat != null || advisory.placeName != null)
                Expanded(
                  child: _ActionButton(
                    icon: Icons.directions_outlined,
                    label: 'Navigate',
                    filled: false,
                    onTap: _openInMaps,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButton(
            icon: Icons.close,
            label: 'Not interested',
            filled: false,
            destructive: true,
            onTap: () {
              ref
                  .read(advisoryActionNotifierProvider(localTripId).notifier)
                  .recordAction(advisory.id, UserActionType.dismissed);
              onDismiss();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatSource(AdvisorySource s) {
    switch (s.name) {
      case 'reddit':
        return 'Reddit';
      case 'tripadvisor':
        return 'TripAdvisor';
      case 'google_maps':
        return 'Google Maps';
      case 'combined':
        return 'Multiple';
      default:
        return s.name;
    }
  }
}

class _ConfidenceDot extends StatelessWidget {
  const _ConfidenceDot({required this.confidence});
  final double confidence;

  Color _color() {
    if (confidence >= 0.7) return AppColors.success;
    if (confidence >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _color(),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? AppColors.error : AppColors.accent;
    return SizedBox(
      height: 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Placeholder for photo / place details (future slices)
// ──────────────────────────────────────────────────────────────────

class _SimpleDetailPlaceholder extends StatelessWidget {
  const _SimpleDetailPlaceholder({
    required this.title,
    required this.subtitle,
    required this.scrollController,
  });

  final String title;
  final String subtitle;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.body
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
