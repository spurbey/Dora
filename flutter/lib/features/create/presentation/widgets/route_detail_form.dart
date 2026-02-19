import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;

class RouteDetailForm extends StatefulWidget {
  const RouteDetailForm({
    super.key,
    required this.route,
    required this.onSave,
    required this.onDelete,
  });

  final create_route.Route route;
  final ValueChanged<create_route.Route> onSave;
  final VoidCallback onDelete;

  @override
  State<RouteDetailForm> createState() => _RouteDetailFormState();
}

class _RouteDetailFormState extends State<RouteDetailForm> {
  late String _mode;

  @override
  void initState() {
    super.initState();
    _mode = _normalizeTransportMode(widget.route.transportMode);
  }

  @override
  void didUpdateWidget(covariant RouteDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _mode = _normalizeTransportMode(widget.route.transportMode);
    }
  }

  void _save() {
    widget.onSave(widget.route.copyWith(transportMode: _mode));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Details', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Distance: ${widget.route.distance?.toStringAsFixed(1) ?? '--'} km',
            style: AppTypography.body,
          ),
          Text(
            'Duration: ${widget.route.duration ?? '--'} mins',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Transport', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _modeChip('car', 'Car'),
              _modeChip('bike', 'Bike'),
              _modeChip('foot', 'Walk'),
              _modeChip('air', 'Air'),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete Route'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String value, String label) {
    final selected = _mode == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _mode = value),
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }

  String _normalizeTransportMode(String mode) {
    if (mode == 'walk') {
      return 'foot';
    }
    return mode;
  }
}
