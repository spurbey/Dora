import 'package:flutter/material.dart';

import 'package:dora/core/theme/dora_theme.dart';

/// Base storybook card — soft shadow, 24px radius, slot-based content.
///
/// Used as the visual foundation for every floating UI surface on the live
/// screen: advisory cards, callouts, detail sheets, timeline rows.
///
/// **Shape language:** 24px corners, soft drop shadow, optional border for
/// emphasis variants. No hard outlines. No gradients on the card itself
/// (gradients live on the Dora pill and the warn pulse).
class DoraCard extends StatelessWidget {
  const DoraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DoraSpacing.lg),
    this.margin,
    this.background = DoraColors.surfaceWhite,
    this.borderColor,
    this.borderWidth = 1.5,
    this.shadows = DoraShadow.soft,
    this.radius = DoraRadius.cardAll,
    this.constraints,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color background;

  /// Optional border color. Use sparingly — only for emphasis (active
  /// advisory card, focused timeline row). Most cards have no border.
  final Color? borderColor;
  final double borderWidth;

  final List<BoxShadow> shadows;
  final BorderRadius radius;
  final BoxConstraints? constraints;

  /// Optional tap handler. When provided, wraps the card in [InkWell] for
  /// the standard ripple feedback. Tap target is the entire card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: background,
      borderRadius: radius,
      boxShadow: shadows,
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: borderWidth),
    );

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    Widget result = Container(
      margin: margin,
      decoration: decoration,
      // Clip to radius so InkWell ripple respects the rounded corners.
      child: ClipRRect(borderRadius: radius, child: content),
    );

    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints!, child: result);
    }

    return result;
  }
}
