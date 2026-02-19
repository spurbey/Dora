import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';

class CityDetailForm extends StatefulWidget {
  const CityDetailForm({
    super.key,
    required this.city,
    required this.onSave,
    required this.onDelete,
  });

  final Place city;
  final ValueChanged<Place> onSave;
  final VoidCallback onDelete;

  @override
  State<CityDetailForm> createState() => _CityDetailFormState();
}

class _CityDetailFormState extends State<CityDetailForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.city.name);
    _notesController = TextEditingController(text: widget.city.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant CityDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city.id != widget.city.id) {
      _nameController.text = widget.city.name;
      _notesController.text = widget.city.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.city.copyWith(
      name: _nameController.text.trim(),
      notes: _notesController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City icon + name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: AppTypography.h3,
                  decoration: InputDecoration(
                    hintText: 'City name',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.city.address != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Text(
                widget.city.address!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Notes
          Text('Notes', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add notes about this destination...',
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
                child: const Text('Remove City'),
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
}
