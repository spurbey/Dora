import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/compiled_projection.dart';
import 'package:dora/features/create/presentation/providers/compiled_projection_provider.dart';

class CapturedStorylinePanel extends StatelessWidget {
  const CapturedStorylinePanel({
    super.key,
    required this.view,
    required this.resolvePlaceName,
    required this.onAssignPlace,
  });

  final CompiledProjectionView view;
  final String? Function(String placeId) resolvePlaceName;
  final void Function(CompiledTimelineEntry entry) onAssignPlace;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: AppSpacing.allSm,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, size: 16, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Captured Storyline',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (view.remoteUnavailable)
                _StatusChip(
                  label: 'Local only',
                  tint: AppColors.warning,
                )
              else if (view.stale)
                _StatusChip(
                  label: 'Stale',
                  tint: AppColors.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (!view.hasEntries)
            Text(
              'No captured storyline items yet.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: view.dayGroups.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final dayGroup = view.dayGroups[index];
                  return _DayGroupSection(
                    day: dayGroup.day,
                    entries: dayGroup.entries,
                    resolvePlaceName: resolvePlaceName,
                    onAssignPlace: onAssignPlace,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DayGroupSection extends StatelessWidget {
  const _DayGroupSection({
    required this.day,
    required this.entries,
    required this.resolvePlaceName,
    required this.onAssignPlace,
  });

  final DateTime day;
  final List<CompiledTimelineEntry> entries;
  final String? Function(String placeId) resolvePlaceName;
  final void Function(CompiledTimelineEntry entry) onAssignPlace;

  @override
  Widget build(BuildContext context) {
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$date/$month/${day.year}',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...entries.take(4).map(
          (entry) {
            final placeName = _resolvePlaceName(entry, resolvePlaceName);
            final badgeLabel =
                placeName == null ? 'On Route' : 'Near $placeName';
            final canAssign = entry.isOnRoute && !entry.isLocalPending;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _iconForEventType(entry.eventType),
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (entry.subtitle != null &&
                              entry.subtitle!.trim().isNotEmpty)
                            Text(
                              entry.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _StatusChip(
                                label: badgeLabel,
                                tint: placeName == null
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                              if (entry.isLocalPending)
                                _StatusChip(
                                  label: 'Pending',
                                  tint: AppColors.accent,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (canAssign)
                      TextButton(
                        onPressed: () => onAssignPlace(entry),
                        child: const Text('Assign Place'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String? _resolvePlaceName(
    CompiledTimelineEntry entry,
    String? Function(String placeId) resolver,
  ) {
    if (entry.placeName != null && entry.placeName!.trim().isNotEmpty) {
      return entry.placeName!.trim();
    }
    if (entry.placeId == null || entry.placeId!.trim().isEmpty) {
      return null;
    }
    return resolver(entry.placeId!.trim());
  }

  IconData _iconForEventType(String eventType) {
    switch (eventType) {
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'tag':
        return Icons.bookmark_added_outlined;
      default:
        return Icons.note_alt_outlined;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.tint,
  });

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
