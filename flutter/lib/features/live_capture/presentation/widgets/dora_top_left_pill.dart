import 'dart:math' as math;

import 'package:dora_api/dora_api.dart' as openapi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/core/widgets/dora_pill.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';

/// Top-left Dora pill — the always-visible avatar surface for the V3
/// live screen. Three states drive the visual:
///
/// - **Idle** — gentle 4s breathing pulse on the gradient disc.
/// - **Thinking** — a soft shimmer when a scrape job is in flight for
///   this trip (advisoryJobsProvider has a `processing` job).
/// - **Has-message** — amber dot badge when there are unread (pending)
///   advisory insights waiting in the inbox.
///
/// Tap → invokes [onTap], which the host wires to toggle the existing
/// AdvisorySidePanel.
class DoraTopLeftPill extends ConsumerWidget {
  const DoraTopLeftPill({
    super.key,
    required this.tripId,
    required this.onTap,
  });

  final String tripId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = _unreadCount(ref);
    final thinking = _thinking(ref);

    return DoraPill(
      size: 60,
      pulse: !thinking,
      onTap: onTap,
      semanticsLabel: 'Open Dora chat',
      badgeColor: unreadCount > 0 ? DoraColors.warn : null,
      child: thinking
          ? const _ShimmerCompass()
          : const _CompassRose(color: DoraColors.surfaceWhite),
    );
  }

  int _unreadCount(WidgetRef ref) {
    final async = ref.watch(advisoryInsightsProvider(tripId));
    final list = async.valueOrNull;
    if (list == null) return 0;
    var count = 0;
    for (final insight in list.insights) {
      if (insight.status == openapi.AdvisoryDeliveryStatus.pending) {
        count++;
      }
    }
    return count;
  }

  bool _thinking(WidgetRef ref) {
    final async = ref.watch(advisoryJobsProvider(tripId));
    final list = async.valueOrNull;
    if (list == null) return false;
    for (final job in list.jobs) {
      if (job.status == openapi.AdvisoryJobStatus.processing) return true;
    }
    return false;
  }
}

/// Compass-rose icon — 4 thin rays N/E/S/W with center dot. Drawn in
/// vector via [CustomPaint] so it renders identically on every device.
class _CompassRose extends StatelessWidget {
  const _CompassRose({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _CompassRosePainter(color: color),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  _CompassRosePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final inner = Offset(
        center.dx + math.sin(angle) * 4,
        center.dy - math.cos(angle) * 4,
      );
      final outer = Offset(
        center.dx + math.sin(angle) * 11,
        center.dy - math.cos(angle) * 11,
      );
      canvas.drawLine(inner, outer, paint);
    }
    canvas.drawCircle(center, 2.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CompassRosePainter old) => old.color != color;
}

/// "Thinking" variant — compass rose with a sweeping shimmer overlay.
/// Cheap rotation animation on the radial gradient — no extra layers.
class _ShimmerCompass extends StatefulWidget {
  const _ShimmerCompass();

  @override
  State<_ShimmerCompass> createState() => _ShimmerCompassState();
}

class _ShimmerCompassState extends State<_ShimmerCompass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Cycle alpha 0.35 → 1.0 → 0.35
        final t = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final alpha = 0.35 + 0.65 * t;
        return _CompassRose(
          color: DoraColors.surfaceWhite.withValues(alpha: alpha),
        );
      },
    );
  }
}
