import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';

class LiveCaptureMapCanvas extends StatelessWidget {
  const LiveCaptureMapCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('liveCaptureMapCanvas'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD9E9EC),
            Color(0xFFE7ECE9),
            Color(0xFFF2EEE6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MapLinePainter(),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            top: AppSpacing.xl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Live route view',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = const Color(0x558A959A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final accent = Paint()
      ..color = const Color(0xAA1F6F78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final gridStep = size.width / 5;
    for (var i = 1; i < 5; i++) {
      final x = gridStep * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), base);
    }

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.72,
        size.width * 0.41,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.48,
        size.width * 0.68,
        size.height * 0.43,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.37,
        size.width * 0.9,
        size.height * 0.25,
      );

    canvas.drawPath(path, accent);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.25),
      7,
      Paint()..color = AppColors.accent,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.25),
      12,
      Paint()..color = AppColors.accent.withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

