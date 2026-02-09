import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class TagSelector extends StatefulWidget {
  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.suggestions,
    required this.onTagsChanged,
    this.maxTags = 5,
  });

  final List<String> selectedTags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onTagsChanged;
  final int maxTags;

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  Future<void> _addCustomTag() async {
    if (widget.selectedTags.length >= widget.maxTags) {
      return;
    }
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add tag', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Adventure'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) {
      return;
    }

    if (!widget.selectedTags.contains(result)) {
      widget.onTagsChanged([...widget.selectedTags, result]);
    }
  }

  void _toggleTag(String tag) {
    final selected = widget.selectedTags.contains(tag);
    if (selected) {
      widget.onTagsChanged(
        widget.selectedTags.where((t) => t != tag).toList(),
      );
    } else {
      if (widget.selectedTags.length >= widget.maxTags) {
        return;
      }
      widget.onTagsChanged([...widget.selectedTags, tag]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      ...widget.suggestions,
      ...widget.selectedTags.where((tag) => !widget.suggestions.contains(tag)),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final tag in chips)
          ChoiceChip(
            label: Text(tag),
            selected: widget.selectedTags.contains(tag),
            selectedColor: AppColors.accentSoft,
            labelStyle: AppTypography.caption.copyWith(
              color: widget.selectedTags.contains(tag)
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderSm,
              side: BorderSide(
                color: widget.selectedTags.contains(tag)
                    ? AppColors.accent
                    : AppColors.divider,
              ),
            ),
            onSelected: (_) => _toggleTag(tag),
          ),
        ActionChip(
          label: const Text('+ Custom'),
          labelStyle: AppTypography.caption.copyWith(color: AppColors.accent),
          backgroundColor: AppColors.accentSoft,
          onPressed: _addCustomTag,
        ),
      ],
    );
  }
}
