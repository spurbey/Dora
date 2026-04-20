import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Canvas-based marker image utilities shared across map controllers.
///
/// Produces PNG [Uint8List] images suitable for Mapbox [PointAnnotation.image].
class MarkerImagePainter {
  MarkerImagePainter._();

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
}
