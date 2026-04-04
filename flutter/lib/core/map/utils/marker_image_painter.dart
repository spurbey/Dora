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
}
