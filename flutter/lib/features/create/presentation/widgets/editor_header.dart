import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class EditorHeader extends StatefulWidget {
  const EditorHeader({
    super.key,
    required this.tripName,
    required this.saving,
    required this.onBack,
    required this.onNameChanged,
    required this.onExport,
    required this.onMore,
  });

  final String tripName;
  final bool saving;
  final VoidCallback onBack;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onExport;
  final VoidCallback onMore;

  @override
  State<EditorHeader> createState() => _EditorHeaderState();
}

class _EditorHeaderState extends State<EditorHeader> {
  late final TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tripName);
  }

  @override
  void didUpdateWidget(covariant EditorHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripName != widget.tripName && !_editing) {
      _controller.text = widget.tripName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty && value != widget.tripName) {
      widget.onNameChanged(value);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _controller,
                    autofocus: true,
                    style: AppTypography.h2,
                    onSubmitted: (_) => _submit(),
                    onEditingComplete: _submit,
                  )
                : GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.tripName,
                            style: AppTypography.h2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (widget.saving)
                          Text(
                            'Saving...',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          Text(
                            'All changes saved',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          IconButton(
            onPressed: widget.onExport,
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            onPressed: widget.onMore,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
