import 'package:flutter/material.dart';

import 'package:dora/core/theme/dora_theme.dart';

/// Direction the speech bubble's triangle pointer points toward.
///
/// Used for both Dora speech (pointer up-left toward the Dora pill) and
/// map callouts (pointer down toward the map pin).
enum DoraBubblePointerDirection { up, down, left, right }

/// Speech bubble with a [CustomPainter]-drawn triangle pointer.
///
/// The bubble is a rounded rectangle in [color], with a small triangle
/// tab that points toward the source of the speech ([pointerDirection]).
/// The triangle is positioned along the edge specified by [pointerDirection]
/// at [pointerOffset] (a fraction 0.0..1.0 along that edge).
///
/// **Color slots** — purple (`DoraColors.advisory`) for Dora's voice,
/// cream (`DoraColors.surfaceCream`) for memory callouts, amber-tinged
/// (`DoraColors.warn` blended) for warn callouts.
class DoraSpeechBubble extends StatelessWidget {
  const DoraSpeechBubble({
    super.key,
    required this.child,
    this.color = DoraColors.surfaceCream,
    this.pointerDirection = DoraBubblePointerDirection.down,
    this.pointerOffset = 0.5,
    this.pointerSize = 12,
    this.padding = const EdgeInsets.symmetric(
      horizontal: DoraSpacing.lg,
      vertical: DoraSpacing.md,
    ),
    this.maxWidth = 280,
    this.shadows = DoraShadow.soft,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  final Widget child;
  final Color color;
  final DoraBubblePointerDirection pointerDirection;

  /// Fractional position of the pointer along its edge (0.0 = start,
  /// 0.5 = center, 1.0 = end). Clamped internally so the triangle
  /// never sticks out past the bubble's rounded corners.
  final double pointerOffset;
  final double pointerSize;
  final EdgeInsets padding;
  final double maxWidth;
  final List<BoxShadow> shadows;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        pointerDirection: pointerDirection,
        pointerOffset: pointerOffset.clamp(0.0, 1.0),
        pointerSize: pointerSize,
        shadows: shadows,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: _paddingWithPointer,
          child: child,
        ),
      ),
    );
  }

  /// Adjust padding to make room for the triangle pointer on the
  /// appropriate edge — without this, the triangle would overlap content.
  EdgeInsets get _paddingWithPointer {
    switch (pointerDirection) {
      case DoraBubblePointerDirection.up:
        return padding.copyWith(top: padding.top + pointerSize);
      case DoraBubblePointerDirection.down:
        return padding.copyWith(bottom: padding.bottom + pointerSize);
      case DoraBubblePointerDirection.left:
        return padding.copyWith(left: padding.left + pointerSize);
      case DoraBubblePointerDirection.right:
        return padding.copyWith(right: padding.right + pointerSize);
    }
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.color,
    required this.pointerDirection,
    required this.pointerOffset,
    required this.pointerSize,
    required this.shadows,
    required this.borderColor,
    required this.borderWidth,
  });

  final Color color;
  final DoraBubblePointerDirection pointerDirection;
  final double pointerOffset;
  final double pointerSize;
  final List<BoxShadow> shadows;
  final Color? borderColor;
  final double borderWidth;

  static const double _radius = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildBubblePath(size);

    // Draw shadows underneath. Each shadow is a translated, blurred copy
    // of the bubble silhouette in the shadow's color.
    for (final shadow in shadows) {
      final shadowPath = path.shift(shadow.offset);
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
      canvas.drawPath(shadowPath, paint);
    }

    // Fill
    canvas.drawPath(path, Paint()..color = color);

    // Optional stroke for emphasis variants
    if (borderColor != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  /// Builds the bubble silhouette as a rounded rect with a triangular
  /// pointer extruded from one edge. The path is closed so it can be
  /// filled and stroked as a single shape.
  Path _buildBubblePath(Size size) {
    // Shrink the rect on the pointer's side to leave room for the triangle.
    final pad = pointerSize;
    Rect bodyRect;
    switch (pointerDirection) {
      case DoraBubblePointerDirection.up:
        bodyRect = Rect.fromLTRB(0, pad, size.width, size.height);
        break;
      case DoraBubblePointerDirection.down:
        bodyRect =
            Rect.fromLTRB(0, 0, size.width, size.height - pad);
        break;
      case DoraBubblePointerDirection.left:
        bodyRect = Rect.fromLTRB(pad, 0, size.width, size.height);
        break;
      case DoraBubblePointerDirection.right:
        bodyRect =
            Rect.fromLTRB(0, 0, size.width - pad, size.height);
        break;
    }

    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(_radius)));

    // Triangle pointer
    final tri = _trianglePath(bodyRect);
    return Path.combine(PathOperation.union, body, tri);
  }

  Path _trianglePath(Rect bodyRect) {
    final tri = Path();
    // Fraction along the pointer edge, with margin so the tip stays
    // clear of the rounded corner.
    const cornerInset = _radius;
    switch (pointerDirection) {
      case DoraBubblePointerDirection.up:
        final span = bodyRect.width - 2 * cornerInset;
        final cx = bodyRect.left + cornerInset + span * pointerOffset;
        tri
          ..moveTo(cx - pointerSize, bodyRect.top)
          ..lineTo(cx, bodyRect.top - pointerSize)
          ..lineTo(cx + pointerSize, bodyRect.top)
          ..close();
        break;
      case DoraBubblePointerDirection.down:
        final span = bodyRect.width - 2 * cornerInset;
        final cx = bodyRect.left + cornerInset + span * pointerOffset;
        tri
          ..moveTo(cx - pointerSize, bodyRect.bottom)
          ..lineTo(cx, bodyRect.bottom + pointerSize)
          ..lineTo(cx + pointerSize, bodyRect.bottom)
          ..close();
        break;
      case DoraBubblePointerDirection.left:
        final span = bodyRect.height - 2 * cornerInset;
        final cy = bodyRect.top + cornerInset + span * pointerOffset;
        tri
          ..moveTo(bodyRect.left, cy - pointerSize)
          ..lineTo(bodyRect.left - pointerSize, cy)
          ..lineTo(bodyRect.left, cy + pointerSize)
          ..close();
        break;
      case DoraBubblePointerDirection.right:
        final span = bodyRect.height - 2 * cornerInset;
        final cy = bodyRect.top + cornerInset + span * pointerOffset;
        tri
          ..moveTo(bodyRect.right, cy - pointerSize)
          ..lineTo(bodyRect.right + pointerSize, cy)
          ..lineTo(bodyRect.right, cy + pointerSize)
          ..close();
        break;
    }
    return tri;
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return color != oldDelegate.color ||
        pointerDirection != oldDelegate.pointerDirection ||
        pointerOffset != oldDelegate.pointerOffset ||
        pointerSize != oldDelegate.pointerSize ||
        shadows != oldDelegate.shadows ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth;
  }
}
