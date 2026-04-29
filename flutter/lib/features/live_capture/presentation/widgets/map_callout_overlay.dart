import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/core/widgets/dora_speech_bubble.dart';

/// Identifies which type of feature was tapped on the map. The widget
/// uses this to choose the correct content for the callout (memory
/// thumbnail vs note/warn/geotag preview vs cluster expansion hint).
enum MapCalloutKind { memory, note, warn, geotag, cluster }

/// State payload for a single active map callout.
///
/// Held in the live screen's [State] (or a Riverpod state-notifier in
/// Phase 2) and passed to [MapCalloutOverlay]. One callout at a time —
/// when the user taps a different pin, the active callout is replaced.
class MapCalloutData {
  const MapCalloutData({
    required this.id,
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.subtitle,
    this.thumbnailLocalPath,
    this.thumbnailUrl,
    this.clusterCount,
  });

  /// Stable identifier — usually the feature's `media_id` / `event_id`,
  /// or `cluster:<cluster_id>` for clusters. Used as a re-render key so
  /// the bubble doesn't flash when the same callout updates position.
  final String id;
  final MapCalloutKind kind;
  final double latitude;
  final double longitude;

  /// First line of the callout — for memories: "12 min ago"; for events:
  /// the preview text; for clusters: "<count> memories here".
  final String title;
  final String? subtitle;

  // Memory-specific fields. Both null is a legitimate state (callout
  // shows a polished fallback silhouette). Local takes precedence when
  // present.
  final String? thumbnailLocalPath;
  final String? thumbnailUrl;

  // Cluster-specific.
  final int? clusterCount;
}

/// Floating callout pinned to a map coordinate.
///
/// Subscribes to camera changes (via the externally-supplied
/// [cameraChangeStream]) and recomputes its on-screen pixel position
/// every tick so it stays anchored to its world coord while the user
/// pans / zooms / rotates the map.
///
/// One callout at a time — if you want to swap content, change [data]
/// and the widget animates the existing bubble to the new position
/// (rather than fading the old one out and the new one in, which feels
/// jumpy when tapping nearby pins quickly).
///
/// Tap [onTap] → typically opens the bottom-sheet detail (Phase 2).
/// Tap-elsewhere is handled by the parent (it nulls [data] when the
/// user taps the map background).
class MapCalloutOverlay extends StatefulWidget {
  const MapCalloutOverlay({
    super.key,
    required this.data,
    required this.mapboxMap,
    required this.cameraChangeStream,
    this.onTap,
  });

  /// Active callout data. When null, nothing is rendered.
  final MapCalloutData? data;

  /// Map controller used for the world-coord → screen-pixel projection.
  /// May be null briefly during map initialization; in that case the
  /// overlay simply doesn't render until the controller arrives.
  final MapboxMap? mapboxMap;

  /// Stream of camera-change events. The widget computes screen pixels
  /// each time this fires. The stream's payload is unused — it just
  /// signals "the camera moved, re-project."
  final Stream<void> cameraChangeStream;

  final VoidCallback? onTap;

  @override
  State<MapCalloutOverlay> createState() => _MapCalloutOverlayState();
}

class _MapCalloutOverlayState extends State<MapCalloutOverlay> {
  StreamSubscription<void>? _sub;
  ScreenCoordinate? _pixel;
  bool _projecting = false;

  @override
  void initState() {
    super.initState();
    _subscribeToCamera();
    _project();
  }

  @override
  void didUpdateWidget(covariant MapCalloutOverlay old) {
    super.didUpdateWidget(old);
    if (old.cameraChangeStream != widget.cameraChangeStream) {
      _sub?.cancel();
      _subscribeToCamera();
    }
    if (old.data?.id != widget.data?.id ||
        old.data?.latitude != widget.data?.latitude ||
        old.data?.longitude != widget.data?.longitude ||
        old.mapboxMap != widget.mapboxMap) {
      _project();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribeToCamera() {
    _sub = widget.cameraChangeStream.listen((_) => _project());
  }

  Future<void> _project() async {
    if (_projecting) return;
    final data = widget.data;
    final map = widget.mapboxMap;
    if (data == null || map == null) {
      if (_pixel != null && mounted) {
        setState(() => _pixel = null);
      }
      return;
    }
    _projecting = true;
    try {
      final px = await map.pixelForCoordinate(
        Point(coordinates: Position(data.longitude, data.latitude)),
      );
      if (!mounted) return;
      setState(() => _pixel = px);
    } catch (_) {
      // Off-screen or controller mid-tear-down — drop the projection
      // silently; next camera tick will retry.
    } finally {
      _projecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final pixel = _pixel;
    if (data == null || pixel == null) {
      return const SizedBox.shrink();
    }

    // The callout bubble points down at the pin, so its pointer tip sits
    // at (pixel.x, pixel.y - 12). The bubble itself is laid out above
    // that anchor.
    const pointerGap = 12.0;
    const bubbleEstimatedHeight = 80.0;

    final left = pixel.x - 120; // half of maxWidth (240)
    final top = pixel.y - pointerGap - bubbleEstimatedHeight;

    return Positioned(
      left: left.clamp(8.0, double.infinity),
      top: top.clamp(8.0, double.infinity),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSwitcher(
          duration: DoraMotion.reveal,
          switchInCurve: DoraMotion.revealCurve,
          switchOutCurve: DoraMotion.dismissCurve,
          child: KeyedSubtree(
            key: ValueKey(data.id),
            child: _CalloutContent(data: data),
          ),
        ),
      ),
    );
  }
}

/// Inner content of the callout, swapped via AnimatedSwitcher when the
/// active callout id changes.
class _CalloutContent extends StatelessWidget {
  const _CalloutContent({required this.data});
  final MapCalloutData data;

  @override
  Widget build(BuildContext context) {
    return DoraSpeechBubble(
      pointerDirection: DoraBubblePointerDirection.down,
      pointerOffset: 0.5,
      maxWidth: 240,
      color: DoraColors.surfaceWhite,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LeadingThumbnail(data: data),
          if (_LeadingThumbnail._renders(data))
            const SizedBox(width: DoraSpacing.md),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DoraTypography.callout,
                ),
                if (data.subtitle != null && data.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DoraTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: DoraSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: DoraColors.inkTertiary,
          ),
        ],
      ),
    );
  }
}

/// Small leading visual — thumbnail for memories, type icon for events.
///
/// **Fallback rule:** if a memory's local path AND remote URL are both
/// missing, render a polished silhouette (cream polaroid frame with a
/// camera glyph) — never a broken-image icon.
class _LeadingThumbnail extends StatelessWidget {
  const _LeadingThumbnail({required this.data});
  final MapCalloutData data;

  /// Whether the thumbnail slot renders anything (vs collapses to zero
  /// width). Used by the parent to decide whether to insert the gap.
  static bool _renders(MapCalloutData data) =>
      data.kind == MapCalloutKind.memory ||
      data.kind == MapCalloutKind.cluster;

  @override
  Widget build(BuildContext context) {
    if (!_renders(data)) return const SizedBox.shrink();

    if (data.kind == MapCalloutKind.cluster) {
      return _ClusterBadge(count: data.clusterCount ?? 0);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: SizedBox(
        width: 44,
        height: 44,
        child: _MemoryThumbnail(
          localPath: data.thumbnailLocalPath,
          remoteUrl: data.thumbnailUrl,
        ),
      ),
    );
  }
}

class _MemoryThumbnail extends StatelessWidget {
  const _MemoryThumbnail({this.localPath, this.remoteUrl});
  final String? localPath;
  final String? remoteUrl;

  @override
  Widget build(BuildContext context) {
    if (localPath != null && localPath!.isNotEmpty) {
      return Image(
        image: FileImage(File(localPath!)),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
      );
    }
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return Image.network(
        remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _ThumbnailFallback();
        },
      );
    }
    return const _ThumbnailFallback();
  }
}

/// Cream polaroid silhouette + camera glyph. Used when no thumbnail is
/// available — never shows a broken-image icon.
class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DoraColors.surfaceMint,
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          size: 20,
          color: DoraColors.brandPrimary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

/// Cluster count badge — small teal pill with the count.
class _ClusterBadge extends StatelessWidget {
  const _ClusterBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: DoraColors.surfaceMint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: DoraTypography.label.copyWith(
          color: DoraColors.brandPrimary,
        ),
      ),
    );
  }
}

