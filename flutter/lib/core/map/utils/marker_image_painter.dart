import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:dora/core/theme/dora_theme.dart';

/// Canvas-based marker image utilities shared across map controllers.
///
/// Produces PNG [Uint8List] images suitable for Mapbox [PointAnnotation.image]
/// and for `style.addStyleImage` sprite registration on V3 GeoJSON layers.
class MarkerImagePainter {
  MarkerImagePainter._();

  /// Renders [paint] to a PNG byte array of size [size]×[size]. Shared
  /// rendering plumbing for every sprite below.
  static Future<Uint8List> _toPng({
    required int size,
    required void Function(Canvas canvas, double size) paint,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, size.toDouble());
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  /// Paints a 56×56 circular GPS position dot in [color].
  ///
  /// Layers (bottom to top): glow shadow → outer translucent ring
  /// → solid fill circle → white ring → inner accent dot.
  /// Symmetric image — bearing rotation is applied via [PointAnnotation.iconRotate].
  static Future<Uint8List> drawLivePositionDot({
    required Color color,
  }) async {
    const int size = 56;
    const center = ui.Offset(size / 2, size / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Soft glow
    canvas.drawCircle(
      center.translate(0, 1),
      15,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );

    // Outer translucent ring
    canvas.drawCircle(center, 16, Paint()..color = color.withValues(alpha: 0.25));

    // Solid circle
    canvas.drawCircle(center, 11, Paint()..color = color);

    // White inner ring
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);

    // Inner accent dot
    canvas.drawCircle(center, 4, Paint()..color = color);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  /// Darkens [color] by [amount] (0.0–1.0).
  static Color darken(Color color, [double amount = 0.2]) {
    final factor = 1.0 - amount.clamp(0.0, 1.0);
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round(),
      (color.green * factor).round(),
      (color.blue * factor).round(),
    );
  }

  /// Paints an advisory POI marker with a category emoji inside a circle.
  ///
  /// [accepted] true → solid filled circle (user saved/acted on it).
  /// [accepted] false → white fill with accent stroke (suggested by Dora).
  static Future<Uint8List> drawAdvisoryMarker({
    required String emoji,
    required Color tint,
    required bool accepted,
  }) async {
    const int size = 88;
    const center = ui.Offset(size / 2, size / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Soft halo shadow
    canvas.drawCircle(
      center.translate(0, 2),
      accepted ? 26 : 24,
      Paint()
        ..color = tint.withValues(alpha: accepted ? 0.32 : 0.18)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
    );

    if (accepted) {
      // Solid filled circle
      canvas.drawCircle(center, 22, Paint()..color = tint);
      // White inner ring for contrast
      canvas.drawCircle(
        center,
        22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      );
    } else {
      // Outer accent ring (translucent)
      canvas.drawCircle(
        center,
        22,
        Paint()..color = tint.withValues(alpha: 0.14),
      );
      // White center disc
      canvas.drawCircle(center, 18, Paint()..color = Colors.white);
      // Accent stroke
      canvas.drawCircle(
        center,
        18,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = tint,
      );
    }

    // Emoji centered
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 22,
          color: accepted ? Colors.white : tint,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      ui.Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  // ── V3 Live screen sprites ─────────────────────────────────────────────────
  //
  // Vector-only — no emoji glyphs, no platform fonts. All shapes rendered
  // with Canvas primitives so they render identically on every device.

  /// V3 user position pin — 56×56 disc with vector compass-rose centerpiece.
  ///
  /// Replaces [drawLivePositionDot] for V3. Shows brand teal disc with white
  /// inner ring and 4-ray compass rose (N/E/S/W) centered. Bearing rotation
  /// is applied by the controller via icon rotation, NOT baked into this
  /// image — the disc and ring stay symmetric, only the compass rotates.
  static Future<Uint8List> drawDoraUserPin() async {
    return _toPng(
      size: 56,
      paint: (canvas, size) {
        final center = Offset(size / 2, size / 2);

        // Soft glow
        canvas.drawCircle(
          center.translate(0, 1),
          16,
          Paint()
            ..color = DoraColors.brandPrimary.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        // Outer translucent ring
        canvas.drawCircle(
          center,
          18,
          Paint()..color = DoraColors.brandPrimary.withValues(alpha: 0.18),
        );

        // Solid disc with radial gradient
        canvas.drawCircle(
          center,
          14,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.3),
              radius: 1.0,
              colors: [
                DoraColors.brandAccent,
                DoraColors.brandPrimary,
              ],
            ).createShader(Rect.fromCircle(center: center, radius: 14)),
        );

        // White inner ring
        canvas.drawCircle(
          center,
          14,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = DoraColors.surfaceWhite,
        );

        // Vector compass rose: 4 thin rays N/E/S/W
        final rayPaint = Paint()
          ..color = DoraColors.surfaceWhite
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          final inner = Offset(
            center.dx + math.sin(angle) * 4,
            center.dy - math.cos(angle) * 4,
          );
          final outer = Offset(
            center.dx + math.sin(angle) * 9,
            center.dy - math.cos(angle) * 9,
          );
          canvas.drawLine(inner, outer, rayPaint);
        }
        // Center white dot
        canvas.drawCircle(
          center,
          2,
          Paint()..color = DoraColors.surfaceWhite,
        );
      },
    );
  }

  /// V3 captured-photo polaroid pin — 64×80 generic frame.
  ///
  /// Per the Phase 0 plan, this is a SINGLE generic frame registered once via
  /// `style.addStyleImage`. Per-feature thumbnails go in the callout, NOT on
  /// the pin itself (pin sprite is shared across all memories).
  ///
  /// Composition: white frame with cream-mint inner panel where a thumbnail
  /// would normally live. Bottom band has a subtle "Polaroid" texture cue.
  /// The whole pin sits on a soft drop shadow.
  static Future<Uint8List> drawPolaroidPin() async {
    return _toPng(
      size: 80,
      paint: (canvas, size) {
        final frameRect = Rect.fromLTWH(8, 6, size - 16, size - 16);

        // Drop shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            frameRect.translate(0, 2),
            const Radius.circular(4),
          ),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );

        // Outer white frame
        canvas.drawRRect(
          RRect.fromRectAndRadius(frameRect, const Radius.circular(4)),
          Paint()..color = DoraColors.surfaceWhite,
        );

        // Inner panel (where the thumbnail would go) — mint placeholder
        final innerRect = Rect.fromLTWH(
          frameRect.left + 4,
          frameRect.top + 4,
          frameRect.width - 8,
          frameRect.width - 8, // Square inner area; bottom band is separate
        );
        canvas.drawRect(
          innerRect,
          Paint()..color = DoraColors.surfaceMint,
        );

        // Tiny camera glyph in inner panel — vector silhouette
        final glyphCenter = innerRect.center;
        final glyphPaint = Paint()
          ..color = DoraColors.brandPrimary.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        // Camera body
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: glyphCenter, width: 22, height: 14),
            const Radius.circular(2),
          ),
          glyphPaint,
        );
        // Lens
        canvas.drawCircle(
          glyphCenter,
          4,
          Paint()..color = DoraColors.surfaceWhite,
        );
        canvas.drawCircle(
          glyphCenter,
          4,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = DoraColors.brandPrimary.withValues(alpha: 0.4),
        );
      },
    );
  }

  /// V3 note pin — 48×48 cream-card silhouette with pencil stroke icon.
  static Future<Uint8List> drawNotePin() async {
    return _toPng(
      size: 48,
      paint: (canvas, size) {
        final cardRect = Rect.fromLTWH(4, 6, size - 8, size - 14);

        // Drop shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            cardRect.translate(0, 1),
            const Radius.circular(8),
          ),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.14)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        // Cream card
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(8)),
          Paint()..color = DoraColors.surfaceCream,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(8)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = DoraColors.inkPrimary.withValues(alpha: 0.85),
        );

        // Three "lines of text" (horizontal strokes) — feels like a note
        final linePaint = Paint()
          ..color = DoraColors.inkPrimary.withValues(alpha: 0.75)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        final lineX1 = cardRect.left + 6;
        final lineX2 = cardRect.right - 10;
        for (int i = 0; i < 3; i++) {
          final y = cardRect.top + 9 + i * 6;
          canvas.drawLine(
            Offset(lineX1, y),
            Offset(lineX2, y),
            linePaint,
          );
        }
      },
    );
  }

  /// V3 warn pin — 48×48 amber triangle with vector-drawn "!" glyph.
  ///
  /// Animated pulse ring underneath is a SEPARATE Mapbox CircleLayer
  /// (animated via runtime paint property updates), NOT baked into this
  /// sprite — keeping the static sprite small and the pulse smooth.
  static Future<Uint8List> drawWarnPin() async {
    return _toPng(
      size: 48,
      paint: (canvas, size) {
        final centerX = size / 2;
        final triangleHeight = size - 12;
        final triangleBase = size - 12;
        const triangleTop = 4.0;

        // Drop shadow
        final shadowPath = Path()
          ..moveTo(centerX, triangleTop + 2)
          ..lineTo(centerX - triangleBase / 2, triangleTop + triangleHeight + 2)
          ..lineTo(centerX + triangleBase / 2, triangleTop + triangleHeight + 2)
          ..close();
        canvas.drawPath(
          shadowPath,
          Paint()
            ..color = DoraColors.warn.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );

        // Amber triangle
        final trianglePath = Path()
          ..moveTo(centerX, triangleTop)
          ..lineTo(centerX - triangleBase / 2, triangleTop + triangleHeight)
          ..lineTo(centerX + triangleBase / 2, triangleTop + triangleHeight)
          ..close();
        canvas.drawPath(
          trianglePath,
          Paint()..color = DoraColors.warn,
        );

        // Triangle outline
        canvas.drawPath(
          trianglePath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = DoraColors.inkPrimary,
        );

        // Vector "!" glyph — vertical bar + dot below
        final glyphCenterX = centerX;
        final glyphCenterY = triangleTop + triangleHeight * 0.62;
        final glyphPaint = Paint()
          ..color = DoraColors.inkPrimary
          ..strokeCap = StrokeCap.round;
        // Vertical bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(glyphCenterX, glyphCenterY - 5),
              width: 2.5,
              height: 12,
            ),
            const Radius.circular(1.5),
          ),
          glyphPaint,
        );
        // Dot
        canvas.drawCircle(
          Offset(glyphCenterX, glyphCenterY + 5),
          1.8,
          glyphPaint,
        );
      },
    );
  }

  /// V3 geotag pin — 48×56 teal teardrop with white inner dot.
  static Future<Uint8List> drawGeotagPin() async {
    return _toPng(
      size: 56,
      paint: (canvas, size) {
        final centerX = size / 2;
        const topY = 4.0;
        const bodyRadius = 12.0;
        const bodyCenterY = topY + bodyRadius;
        final tipY = size - 4;

        // Drop shadow
        final shadowPath = _buildTeardropPath(
          centerX: centerX,
          bodyCenterY: bodyCenterY + 1,
          bodyRadius: bodyRadius,
          tipY: tipY + 1,
        );
        canvas.drawPath(
          shadowPath,
          Paint()
            ..color = DoraColors.brandPrimary.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );

        // Teardrop body — teal gradient
        final bodyPath = _buildTeardropPath(
          centerX: centerX,
          bodyCenterY: bodyCenterY,
          bodyRadius: bodyRadius,
          tipY: tipY,
        );
        canvas.drawPath(
          bodyPath,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DoraColors.brandAccent,
                DoraColors.brandPrimary,
              ],
            ).createShader(Rect.fromLTWH(0, 0, size, size)),
        );

        // Outline
        canvas.drawPath(
          bodyPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = DoraColors.inkPrimary.withValues(alpha: 0.4),
        );

        // White inner dot
        canvas.drawCircle(
          Offset(centerX, bodyCenterY),
          5,
          Paint()..color = DoraColors.surfaceWhite,
        );
      },
    );
  }

  /// V3 cluster stack — 80×80 stacked polaroids for cluster pins.
  ///
  /// Used as the cluster icon for memories. Drawn as 3 overlapping polaroid
  /// rectangles with slight rotation, top one centered, two underneath
  /// fanning out. Cluster count is rendered by Mapbox text layer on top
  /// (the controller wires `text-field` from the `point_count` property).
  static Future<Uint8List> drawClusterStack() async {
    return _toPng(
      size: 80,
      paint: (canvas, size) {
        final center = Offset(size / 2, size / 2);

        // Three card layers, fanning out
        for (int i = 2; i >= 0; i--) {
          final angle = (i - 1) * 0.18; // -0.18, 0, 0.18 rad
          final dx = (i - 1) * 4.0;
          final dy = -(i - 1).abs() * 1.0;
          final cardCenter = Offset(center.dx + dx, center.dy + dy);

          canvas.save();
          canvas.translate(cardCenter.dx, cardCenter.dy);
          canvas.rotate(angle);

          final cardRect = Rect.fromCenter(
            center: Offset.zero,
            width: 44,
            height: 50,
          );

          // Shadow
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              cardRect.translate(0, 1.5),
              const Radius.circular(3),
            ),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.12)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );

          // White card
          canvas.drawRRect(
            RRect.fromRectAndRadius(cardRect, const Radius.circular(3)),
            Paint()..color = DoraColors.surfaceWhite,
          );

          // Mint inner panel
          final innerRect = Rect.fromLTRB(
            cardRect.left + 3,
            cardRect.top + 3,
            cardRect.right - 3,
            cardRect.bottom - 8,
          );
          canvas.drawRect(
            innerRect,
            Paint()..color = DoraColors.surfaceMint,
          );

          canvas.restore();
        }
      },
    );
  }

  /// Builds a teardrop silhouette: circle on top, tapering to a point
  /// at [tipY]. Used by [drawGeotagPin].
  static Path _buildTeardropPath({
    required double centerX,
    required double bodyCenterY,
    required double bodyRadius,
    required double tipY,
  }) {
    final path = Path();
    // Circle minus the bottom slice, then tangent lines down to the tip.
    // Tangent angle from circle center to a tangent point at the bottom.
    // Geometry: tangent from external point P below; for a teardrop we want
    // straight lines from where the circle's tangent equals the slope to P.
    final dy = tipY - bodyCenterY;
    final dist = dy; // straight down
    // Half-angle from vertical at which tangent line just clears the circle.
    final theta = math.acos(bodyRadius / dist);
    // Tangent points on the circle
    final leftTangent = Offset(
      centerX - bodyRadius * math.sin(theta),
      bodyCenterY + bodyRadius * math.cos(theta),
    );
    final rightTangent = Offset(
      centerX + bodyRadius * math.sin(theta),
      bodyCenterY + bodyRadius * math.cos(theta),
    );
    // Top of arc → around clockwise to leftTangent → down to tip → up to
    // rightTangent → around back to start.
    path.moveTo(centerX, bodyCenterY - bodyRadius);
    // Arc clockwise from top, around left side, to leftTangent.
    path.arcToPoint(
      leftTangent,
      radius: Radius.circular(bodyRadius),
      clockwise: false,
      largeArc: false,
    );
    path.lineTo(centerX, tipY);
    path.lineTo(rightTangent.dx, rightTangent.dy);
    path.arcToPoint(
      Offset(centerX, bodyCenterY - bodyRadius),
      radius: Radius.circular(bodyRadius),
      clockwise: false,
      largeArc: false,
    );
    path.close();
    return path;
  }
}
