import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/core/widgets/dora_pill.dart';
import 'package:dora/features/live_capture/map/live_capture_map_controller.dart';

/// Top-right toggle that switches the live screen's map between
/// [MapDimensionalMode.standard] and [MapDimensionalMode.cinematic].
///
/// Renders a [DoraPill] with a vector cube/square icon — drawn in
/// [CustomPaint] so it renders identically on every device, no font
/// dependency.
///
/// **First-switch hint:** the very first time a user enters cinematic
/// mode, a SnackBar appears with a battery-life caveat. Tracked via
/// [SharedPreferences] so it shows once per install.
class DimensionalModeToggle extends StatefulWidget {
  const DimensionalModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  /// Current mode — drives the icon (square = standard, cube =
  /// cinematic). The widget is stateless on the mode itself; the
  /// parent owns the truth.
  final MapDimensionalMode mode;

  /// Called with the new mode after a tap. Parent calls
  /// [LiveCaptureMapController.setDimensionalMode] with this value
  /// AND updates whatever state drives [mode] back into this widget.
  final ValueChanged<MapDimensionalMode> onChanged;

  @override
  State<DimensionalModeToggle> createState() => _DimensionalModeToggleState();
}

class _DimensionalModeToggleState extends State<DimensionalModeToggle> {
  static const String _firstSwitchPrefKey = 'dora.live_v3.first_cinematic_seen';

  @override
  Widget build(BuildContext context) {
    final isCinematic = widget.mode == MapDimensionalMode.cinematic;
    return DoraPill(
      size: 48,
      shadows: DoraShadow.tight,
      gradientColors: isCinematic
          ? const [DoraColors.brandAccent, DoraColors.brandPrimary]
          : const [DoraColors.surfaceWhite, DoraColors.surfaceMint],
      onTap: () => _handleTap(context, isCinematic),
      semanticsLabel: isCinematic
          ? 'Switch to standard map'
          : 'Switch to cinematic map',
      child: CustomPaint(
        size: const Size(22, 22),
        painter: _DimensionalIconPainter(
          isCinematic: isCinematic,
          color: isCinematic
              ? DoraColors.surfaceWhite
              : DoraColors.brandPrimary,
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, bool wasCinematic) async {
    final next = wasCinematic
        ? MapDimensionalMode.standard
        : MapDimensionalMode.cinematic;
    widget.onChanged(next);

    // First-time cinematic enter — show the battery hint once.
    if (next == MapDimensionalMode.cinematic) {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(_firstSwitchPrefKey) ?? false;
      if (!seen && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cinematic uses more battery on long trips.'),
            duration: Duration(seconds: 3),
            backgroundColor: DoraColors.inkPrimary,
          ),
        );
        await prefs.setBool(_firstSwitchPrefKey, true);
      }
    }
  }
}

/// Vector painter for the dimensional-mode icon. In standard mode,
/// renders a flat rounded square; in cinematic mode, renders a 3D-cube
/// outline (front face + receding top + receding right) so the icon
/// itself reads as "more dimensional."
class _DimensionalIconPainter extends CustomPainter {
  _DimensionalIconPainter({required this.isCinematic, required this.color});

  final bool isCinematic;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    if (!isCinematic) {
      // Flat rounded square
      final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
      return;
    }

    // Cube — drawn in three quad strokes for a clean isometric outline.
    // Coordinates roughly: 22×22 box, corners derived as fractions.
    final w = size.width;
    final h = size.height;

    // Front face
    final frontTopLeft = Offset(w * 0.15, h * 0.40);
    final frontTopRight = Offset(w * 0.65, h * 0.40);
    final frontBottomRight = Offset(w * 0.65, h * 0.85);
    final frontBottomLeft = Offset(w * 0.15, h * 0.85);

    final frontPath = Path()
      ..moveTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(frontBottomLeft.dx, frontBottomLeft.dy)
      ..close();
    canvas.drawPath(frontPath, paint);

    // Top face (receding up-right)
    final topBackLeft = Offset(w * 0.35, h * 0.20);
    final topBackRight = Offset(w * 0.85, h * 0.20);
    final topPath = Path()
      ..moveTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(topBackLeft.dx, topBackLeft.dy)
      ..lineTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy);
    canvas.drawPath(topPath, paint);

    // Right face (receding up-right). Just two more strokes — top-back-
    // right is shared with the top face, bottom-back-right is the new
    // corner we need to extend down to.
    final rightBackBottom = Offset(w * 0.85, h * 0.65);
    final rightPath = Path()
      ..moveTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(rightBackBottom.dx, rightBackBottom.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy);
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(_DimensionalIconPainter old) =>
      old.isCinematic != isCinematic || old.color != color;
}
