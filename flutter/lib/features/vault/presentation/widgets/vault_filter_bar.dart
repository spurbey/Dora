import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/vault/domain/vault_filter.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';

/// Two rows of choice chips — time (always visible) and radius (visible only
/// when location permission is granted). When permission is missing or
/// denied, the radius row is replaced with a compact "Enable location" CTA.
class VaultFilterBar extends ConsumerWidget {
  const VaultFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(vaultFilterProvider);
    final locationAsync = ref.watch(vaultLocationProvider);

    return Material(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipRow(
              label: 'Time',
              children: [
                for (final bucket in VaultTimeBucket.values)
                  _VaultChip(
                    label: bucket.label,
                    selected: filter.time == bucket,
                    onSelected: () => ref
                        .read(vaultFilterProvider.notifier)
                        .setTime(bucket),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            locationAsync.when(
              data: (state) => state.hasPosition
                  ? _ChipRow(
                      label: 'Radius',
                      children: [
                        for (final bucket in VaultRadiusBucket.values)
                          _VaultChip(
                            label: bucket.label,
                            selected: filter.radius == bucket,
                            onSelected: () => ref
                                .read(vaultFilterProvider.notifier)
                                .setRadius(bucket),
                          ),
                      ],
                    )
                  : _LocationPrompt(accessState: state.accessState),
              loading: () => const SizedBox(
                height: 36,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              error: (_, __) =>
                  const _LocationPrompt(accessState: LocationAccessState.denied),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultChip extends StatelessWidget {
  const _VaultChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppColors.accent : AppColors.divider,
        ),
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LocationPrompt extends ConsumerWidget {
  const _LocationPrompt({required this.accessState});

  final LocationAccessState accessState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isForever = accessState == LocationAccessState.deniedForever ||
        accessState == LocationAccessState.serviceDisabled;
    return Row(
      children: [
        const SizedBox(width: 52),
        const Icon(
          Icons.my_location_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isForever
                ? 'Enable location in Settings to filter by radius'
                : 'Enable location to filter by radius',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        TextButton(
          onPressed: () async {
            if (isForever) {
              await Geolocator.openAppSettings();
            }
            await ref
                .read(vaultLocationProvider.notifier)
                .requestPermission();
          },
          child: Text(isForever ? 'Open' : 'Grant'),
        ),
      ],
    );
  }
}
