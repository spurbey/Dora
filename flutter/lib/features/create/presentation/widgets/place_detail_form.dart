import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';

class PlaceDetailForm extends StatefulWidget {
  const PlaceDetailForm({
    super.key,
    required this.place,
    required this.onSave,
    required this.onDelete,
  });

  final Place place;
  final ValueChanged<Place> onSave;
  final VoidCallback onDelete;

  @override
  State<PlaceDetailForm> createState() => _PlaceDetailFormState();
}

class _PlaceDetailFormState extends State<PlaceDetailForm> {
  late final TextEditingController _notesController;
  String? _visitTime;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.place.notes ?? '');
    _visitTime = widget.place.visitTime;
  }

  @override
  void didUpdateWidget(covariant PlaceDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) {
      _notesController.text = widget.place.notes ?? '';
      _visitTime = widget.place.visitTime;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.place.copyWith(
      notes: _notesController.text.trim(),
      visitTime: _visitTime,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.place.name, style: AppTypography.h3),
          if (widget.place.address != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.place.address!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final url in widget.place.photoUrls)
                  Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderSm,
                      color: AppColors.surface,
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.add, color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Notes', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add your notes...',
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Visit Time', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _visitChip('Morning'),
              _visitChip('Afternoon'),
              _visitChip('Evening'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete Place'),
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

  Widget _visitChip(String value) {
    final selected = _visitTime == value.toLowerCase();
    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _visitTime = value.toLowerCase();
        });
      },
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }
}
