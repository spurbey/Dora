import 'package:dora/core/map/models/app_latlng.dart';

class V2TimelineProjectionEntry {
  const V2TimelineProjectionEntry({
    required this.entryId,
    required this.tripLocalId,
    required this.sessionId,
    required this.capturedAt,
    required this.sourceKind,
    required this.sourceId,
    required this.eventType,
    required this.bucketType,
    required this.placeBindKind,
    required this.placeBindId,
    required this.placeBindName,
    required this.decisionSource,
    required this.manualLock,
    required this.anchorLatitude,
    required this.anchorLongitude,
    required this.title,
    required this.subtitle,
    required this.syncChipState,
    required this.displayOrder,
    required this.routeSegmentKey,
    required this.routeDistanceM,
    required this.renderPayloadJson,
    required this.compiledAt,
    required this.compilerVersion,
  });

  final String entryId;
  final String tripLocalId;
  final String sessionId;
  final DateTime capturedAt;
  final String sourceKind;
  final String sourceId;
  final String eventType;
  final String bucketType;
  final String? placeBindKind;
  final String? placeBindId;
  final String? placeBindName;
  final String? decisionSource;
  final int manualLock;
  final double anchorLatitude;
  final double anchorLongitude;
  final String title;
  final String? subtitle;
  final String syncChipState;
  final double displayOrder;
  final String? routeSegmentKey;
  final double? routeDistanceM;
  final String? renderPayloadJson;
  final DateTime compiledAt;
  final int compilerVersion;

  AppLatLng get anchorPosition => AppLatLng(
        latitude: anchorLatitude,
        longitude: anchorLongitude,
      );

  bool get isNeedsReview => bucketType == 'needs_review';
}

class V2TimelineSessionGroup {
  const V2TimelineSessionGroup({
    required this.sessionId,
    required this.entries,
  });

  final String sessionId;
  final List<V2TimelineProjectionEntry> entries;
}

class V2TimelineDayGroup {
  const V2TimelineDayGroup({
    required this.day,
    required this.sessions,
  });

  final DateTime day;
  final List<V2TimelineSessionGroup> sessions;
}

class V2RouteProjectionSegment {
  const V2RouteProjectionSegment({
    required this.segmentKey,
    required this.tripLocalId,
    required this.sessionId,
    required this.startedAt,
    required this.endedAt,
    required this.pointsCount,
    required this.distanceM,
    required this.bboxMinLat,
    required this.bboxMinLon,
    required this.bboxMaxLat,
    required this.bboxMaxLon,
    required this.geometry,
    required this.updatedAt,
    required this.compilerVersion,
  });

  final String segmentKey;
  final String tripLocalId;
  final String sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int pointsCount;
  final double distanceM;
  final double bboxMinLat;
  final double bboxMinLon;
  final double bboxMaxLat;
  final double bboxMaxLon;
  final List<AppLatLng> geometry;
  final DateTime updatedAt;
  final int compilerVersion;
}
