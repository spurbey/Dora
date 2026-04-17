/// Shared model types for live-tracking, used by both V1 and V2 runtime code.
///
/// Extracted from V1 so that V2 modules can import these types without
/// depending on V1 implementation files that may be removed.

enum LiveTrackingRuntimeState {
  planned,
  active,
  paused,
  ended,
}

class LiveTrackingRuntimeSnapshot {
  const LiveTrackingRuntimeSnapshot({
    required this.tripId,
    required this.state,
    this.sessionId,
    this.remoteSessionId,
    this.startedAt,
    this.pausedAt,
    this.resumedAt,
    this.endedAt,
    this.lastPointAt,
  });

  final String tripId;
  final LiveTrackingRuntimeState state;
  final String? sessionId;
  final String? remoteSessionId;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? resumedAt;
  final DateTime? endedAt;
  final DateTime? lastPointAt;
}

class LiveTrackingBatchingPolicy {
  const LiveTrackingBatchingPolicy({
    this.maxPointsPerBatch = 25,
    this.maxBatchWindow = const Duration(seconds: 20),
    this.minPointCadence = const Duration(seconds: 4),
    this.minDistanceMeters = 8.0,
  });

  final int maxPointsPerBatch;
  final Duration maxBatchWindow;
  final Duration minPointCadence;
  final double minDistanceMeters;
}

class TrackingPointSample {
  const TrackingPointSample({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.speedMps,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMps;
}

class LiveTrackingCommandException implements Exception {
  const LiveTrackingCommandException({
    required this.code,
    required this.message,
    this.retryable = false,
  });

  final String code;
  final String message;
  final bool retryable;

  @override
  String toString() => 'LiveTrackingCommandException($code): $message';
}

enum LiveTrackingEventType {
  note,
  warn,
  tag,
  photo,
  media,
}

/// Lightweight summary of unresolved captures for the live-capture HUD.
/// Originally V1; retained as a UI-level DTO so the live capture screen can
/// display review-required banners without depending on V1 repositories.
class LiveTrackingUnresolvedSummary {
  const LiveTrackingUnresolvedSummary({
    required this.reviewRequiredCount,
    required this.onRouteCount,
    required this.latestReviewRequired,
    required this.reviewHints,
  });

  final int reviewRequiredCount;
  final int onRouteCount;
  final LiveTrackingUnresolvedEvent? latestReviewRequired;
  final List<LiveTrackingPlaceHint> reviewHints;

  bool get hasReviewRequired => reviewRequiredCount > 0;
}

class LiveTrackingUnresolvedEvent {
  const LiveTrackingUnresolvedEvent({
    required this.id,
    this.note,
  });

  final String id;
  final String? note;
}

class LiveTrackingPlaceHint {
  const LiveTrackingPlaceHint({
    required this.placeId,
    required this.name,
    required this.confidence,
  });

  final String placeId;
  final String name;
  final double confidence;
}

class LiveTrackingCaptureException implements Exception {
  const LiveTrackingCaptureException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'LiveTrackingCaptureException($code): $message';
}
