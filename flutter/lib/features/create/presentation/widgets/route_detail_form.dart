import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _mode = _normalizeTransportMode(widget.route.transportMode);
    _nameController = TextEditingController(text: widget.route.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.route.description ?? '');
  }

  @override
  void didUpdateWidget(covariant RouteDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _mode = _normalizeTransportMode(widget.route.transportMode);
      _nameController.text = widget.route.name ?? '';
      _descriptionController.text = widget.route.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.route.copyWith(
      transportMode: _mode,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Details', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),

          // Route name
          Text('Name', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Give this route a name...',
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Distance & Duration
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Distance',
                  value:
                      '${widget.route.distance?.toStringAsFixed(1) ?? '--'} km',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InfoTile(
                  label: 'Duration',
                  value: '${widget.route.duration ?? '--'} min',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Transport mode
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
          const SizedBox(height: AppSpacing.md),

          // Description
          Text('Description', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe this route...',
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete Route'),
              ),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }
}
