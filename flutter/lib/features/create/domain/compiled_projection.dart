import 'package:dora/core/map/models/app_latlng.dart';

class CompiledProjectionSnapshot {
  const CompiledProjectionSnapshot({
    required this.tripId,
    required this.compilerVersion,
    required this.stale,
    required this.timelineEntries,
    required this.timelineGroups,
    required this.routeSegments,
    this.compiledAt,
  });

  final String tripId;
  final int compilerVersion;
  final bool stale;
  final DateTime? compiledAt;
  final List<CompiledTimelineEntry> timelineEntries;
  final List<CompiledTimelineDayGroup> timelineGroups;
  final List<CompiledRouteSegment> routeSegments;

  factory CompiledProjectionSnapshot.fromJson(Map<String, dynamic> json) {
    final entries = _asJsonList(json['timeline_entries'])
        .map(CompiledTimelineEntry.fromJson)
        .toList(growable: false);
    final groups = _asJsonList(json['timeline_groups'])
        .map(CompiledTimelineDayGroup.fromJson)
        .toList(growable: false);
    final segments = _asJsonList(json['route_segments'])
        .map(CompiledRouteSegment.fromJson)
        .toList(growable: false);
    return CompiledProjectionSnapshot(
      tripId: _asString(json['trip_id']) ?? '',
      compilerVersion: _asInt(json['compiler_version']) ?? 1,
      stale: _asBool(json['stale']) ?? false,
      compiledAt: _parseDateTime(json['compiled_at']),
      timelineEntries: entries,
      timelineGroups: groups,
      routeSegments: segments,
    );
  }
}

class CompiledTimelineDayGroup {
  const CompiledTimelineDayGroup({
    required this.day,
    required this.placeEntries,
    required this.onRouteEntries,
  });

  final DateTime day;
  final List<CompiledTimelineEntry> placeEntries;
  final List<CompiledTimelineEntry> onRouteEntries;

  factory CompiledTimelineDayGroup.fromJson(Map<String, dynamic> json) {
    final fallbackDay = DateTime.utc(1970, 1, 1);
    return CompiledTimelineDayGroup(
      day: _parseDate(json['day']) ?? fallbackDay,
      placeEntries: _asJsonList(json['place_entries'])
          .map(CompiledTimelineEntry.fromJson)
          .toList(growable: false),
      onRouteEntries: _asJsonList(json['on_route_entries'])
          .map(CompiledTimelineEntry.fromJson)
          .toList(growable: false),
    );
  }
}

class CompiledTimelineEntry {
  const CompiledTimelineEntry({
    required this.entryId,
    required this.sourceKind,
    required this.sourceId,
    required this.eventType,
    required this.capturedAt,
    required this.bucketType,
    required this.bindSource,
    required this.title,
    required this.payload,
    this.placeId,
    this.placeName,
    this.bindConfidence,
    this.reasonCode,
    this.subtitle,
    this.clientEventId,
    this.isLocalPending = false,
  });

  final String entryId;
  final String sourceKind;
  final String sourceId;
  final String eventType;
  final DateTime capturedAt;
  final String bucketType;
  final String? placeId;
  final String? placeName;
  final String bindSource;
  final double? bindConfidence;
  final String? reasonCode;
  final String title;
  final String? subtitle;
  final Map<String, dynamic> payload;
  final String? clientEventId;
  final bool isLocalPending;

  bool get isOnRoute => bucketType == 'on_route';

  factory CompiledTimelineEntry.fromJson(Map<String, dynamic> json) {
    final payload = _asJsonMap(json['payload']);
    final sourceId = _asString(json['source_id']) ?? '';
    final capturedAt = _parseDateTime(json['captured_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return CompiledTimelineEntry(
      entryId: _asString(json['entry_id']) ?? 'unknown',
      sourceKind: _asString(json['source_kind']) ?? 'tracking_event',
      sourceId: sourceId,
      eventType: _asString(json['event_type']) ?? 'note',
      capturedAt: capturedAt,
      bucketType: _asString(json['bucket_type']) ?? 'on_route',
      placeId: _asString(json['place_id']),
      placeName: _asString(json['place_name']),
      bindSource: _asString(json['bind_source']) ?? 'none',
      bindConfidence: _asDouble(json['bind_confidence']),
      reasonCode: _asString(json['reason_code']),
      title: (_asString(json['title']) ?? '').trim().isEmpty
          ? 'Captured item'
          : (_asString(json['title']) ?? '').trim(),
      subtitle: _asString(json['subtitle']),
      payload: payload,
      clientEventId: _asString(payload['client_event_id']),
    );
  }

  CompiledTimelineEntry copyWith({
    String? entryId,
    String? sourceKind,
    String? sourceId,
    String? eventType,
    DateTime? capturedAt,
    String? bucketType,
    String? placeId,
    String? placeName,
    String? bindSource,
    double? bindConfidence,
    String? reasonCode,
    String? title,
    String? subtitle,
    Map<String, dynamic>? payload,
    String? clientEventId,
    bool? isLocalPending,
  }) {
    return CompiledTimelineEntry(
      entryId: entryId ?? this.entryId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceId: sourceId ?? this.sourceId,
      eventType: eventType ?? this.eventType,
      capturedAt: capturedAt ?? this.capturedAt,
      bucketType: bucketType ?? this.bucketType,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      bindSource: bindSource ?? this.bindSource,
      bindConfidence: bindConfidence ?? this.bindConfidence,
      reasonCode: reasonCode ?? this.reasonCode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      payload: payload ?? this.payload,
      clientEventId: clientEventId ?? this.clientEventId,
      isLocalPending: isLocalPending ?? this.isLocalPending,
    );
  }
}

class CompiledRouteSegment {
  const CompiledRouteSegment({
    required this.segmentId,
    required this.startedAt,
    required this.endedAt,
    required this.distanceM,
    required this.rawPointCount,
    required this.simplifiedPointCount,
    required this.coordinates,
    this.sessionId,
  });

  final String segmentId;
  final String? sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceM;
  final int rawPointCount;
  final int simplifiedPointCount;
  final List<AppLatLng> coordinates;

  factory CompiledRouteSegment.fromJson(Map<String, dynamic> json) {
    final geometry = _asJsonMap(json['geometry']);
    final coordinates = <AppLatLng>[];
    for (final pair in _asList(geometry['coordinates'])) {
      if (pair is! List || pair.length < 2) {
        continue;
      }
      final lng = _asDouble(pair[0]);
      final lat = _asDouble(pair[1]);
      if (lat == null || lng == null) {
        continue;
      }
      coordinates.add(AppLatLng(latitude: lat, longitude: lng));
    }
    return CompiledRouteSegment(
      segmentId: _asString(json['segment_id']) ?? 'segment',
      sessionId: _asString(json['session_id']),
      startedAt: _parseDateTime(json['started_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endedAt: _parseDateTime(json['ended_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      distanceM: _asDouble(json['distance_m']) ?? 0,
      rawPointCount: _asInt(json['raw_point_count']) ?? 0,
      simplifiedPointCount: _asInt(json['simplified_point_count']) ?? 0,
      coordinates: coordinates,
    );
  }
}

List<Map<String, dynamic>> _asJsonList(dynamic value) {
  if (value is List) {
    return value.map(_asJsonMap).toList(growable: false);
  }
  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}

String? _asString(dynamic value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return text;
}

int? _asInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value == null) {
    return null;
  }
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  final text = _asString(value);
  if (text == null) {
    return null;
  }
  return DateTime.tryParse(text)?.toUtc();
}

DateTime? _parseDate(dynamic value) {
  final text = _asString(value);
  if (text == null) {
    return null;
  }
  final parsed = DateTime.tryParse(text);
  if (parsed == null) {
    return null;
  }
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}
