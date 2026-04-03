import 'package:flutter/material.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_typography.dart';

enum DoraButtonVariant { filled, outlined }

/// Dora-branded pill button with scale-on-tap feedback.
///
/// [filled]: accent background, white text, scale 1.0→0.95 on tap.
/// [outlined]: accent border + text, transparent background, same tap feedback.
class DoraButton extends StatefulWidget {
  const DoraButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = DoraButtonVariant.filled,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final DoraButtonVariant variant;

  @override
  State<DoraButton> createState() => _DoraButtonState();
}

class _DoraButtonState extends State<DoraButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isFilled = widget.variant == DoraButtonVariant.filled;

    final textColor = isFilled
        ? Colors.white
        : (enabled
            ? AppColors.accent
            : AppColors.accent.withValues(alpha: 0.45));
    final bgColor = isFilled
        ? (enabled ? AppColors.accent : AppColors.accent.withValues(alpha: 0.45))
        : Colors.transparent;
    final borderColor = enabled
        ? AppColors.accent
        : AppColors.accent.withValues(alpha: 0.35);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: (_pressed && enabled) ? 0.95 : 1.0,
        duration: AnimationTokens.fast,
        curve: AnimationTokens.standard,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.55,
          duration: AnimationTokens.fast,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
              border: isFilled
                  ? null
                  : Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: textColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label,
                  style: AppTypography.body.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
