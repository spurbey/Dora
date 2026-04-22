import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/domain/unified_timeline_entry.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

final unifiedTimelineProvider = Provider.autoDispose
    .family<AsyncValue<List<UnifiedTimelineEntry>>, String>((ref, tripId) {
  final editorAsync = ref.watch(editorControllerProvider(tripId));
  final projectionAsync = ref.watch(v2TimelineProjectionProvider(tripId));

  return editorAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (editor) => projectionAsync.when(
      loading: () => AsyncValue.data(
        _buildUnifiedEntries(
          places: editor.places,
          routes: editor.routes,
          v2Entries: const <V2TimelineProjectionEntry>[],
        ),
      ),
      error: (_, __) => AsyncValue.data(
        _buildUnifiedEntries(
          places: editor.places,
          routes: editor.routes,
          v2Entries: const <V2TimelineProjectionEntry>[],
        ),
      ),
      data: (v2Entries) => AsyncValue.data(
        _buildUnifiedEntries(
          places: editor.places,
          routes: editor.routes,
          v2Entries: v2Entries,
        ),
      ),
    ),
  );
});

List<UnifiedTimelineEntry> _buildUnifiedEntries({
  required List<Place> places,
  required List<create_route.Route> routes,
  required List<V2TimelineProjectionEntry> v2Entries,
}) {
  final liveEntries = v2Entries
      .where(
          (entry) => entry.sourceKind == 'event' || entry.sourceKind == 'media')
      .toList(growable: false)
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  final merged = <UnifiedTimelineEntry>[
    for (final event in liveEntries)
      UnifiedLiveEventTimelineEntry(
        event: event,
        mediaCount: _extractMediaCount(event.renderPayloadJson),
        displayOrder: event.displayOrder,
      ),
  ];

  final sortedPlaces = List<Place>.from(places)
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  for (final place in sortedPlaces) {
    final index = place.orderIndex.clamp(0, merged.length);
    final order = _displayOrderForInsertion(merged, index);
    merged.insert(
      index,
      UnifiedPlaceTimelineEntry(
        place: place,
        displayOrder: order,
      ),
    );
  }

  final sortedRoutes = List<create_route.Route>.from(routes)
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  for (final route in sortedRoutes) {
    final placeIndexById = <String, int>{};
    for (var i = 0; i < merged.length; i++) {
      final entry = merged[i];
      if (entry is UnifiedPlaceTimelineEntry) {
        placeIndexById[entry.place.id] = i;
      }
    }

    final startIndex =
        route.startPlaceId == null ? null : placeIndexById[route.startPlaceId!];
    final endIndex =
        route.endPlaceId == null ? null : placeIndexById[route.endPlaceId!];

    final targetIndex = _routeInsertionIndex(
      mergedLength: merged.length,
      startIndex: startIndex,
      endIndex: endIndex,
    );
    final order = _displayOrderForInsertion(merged, targetIndex);
    merged.insert(
      targetIndex,
      UnifiedRouteTimelineEntry(
        route: route,
        startPlaceName: _findPlaceName(sortedPlaces, route.startPlaceId),
        endPlaceName: _findPlaceName(sortedPlaces, route.endPlaceId),
        displayOrder: order,
      ),
    );
  }

  return merged;
}

int _extractMediaCount(String? payloadJson) {
  if (payloadJson == null || payloadJson.trim().isEmpty) {
    return 0;
  }
  try {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) {
      return 0;
    }
    final media = decoded['media'];
    if (media is List) {
      return media.length;
    }
    return 0;
  } catch (_) {
    return 0;
  }
}

double _displayOrderForInsertion(
  List<UnifiedTimelineEntry> entries,
  int insertionIndex,
) {
  final previous = insertionIndex > 0 ? entries[insertionIndex - 1] : null;
  final next = insertionIndex < entries.length ? entries[insertionIndex] : null;
  if (previous != null && next != null) {
    return (previous.displayOrder + next.displayOrder) / 2.0;
  }
  if (previous != null) {
    return previous.displayOrder + 1000.0;
  }
  if (next != null) {
    return next.displayOrder - 1000.0;
  }
  return DateTime.now().toUtc().millisecondsSinceEpoch.toDouble();
}

int _routeInsertionIndex({
  required int mergedLength,
  required int? startIndex,
  required int? endIndex,
}) {
  if (startIndex != null && endIndex != null) {
    return (startIndex > endIndex ? startIndex : endIndex)
        .clamp(0, mergedLength);
  }
  if (startIndex != null) {
    return (startIndex + 1).clamp(0, mergedLength);
  }
  if (endIndex != null) {
    return (endIndex + 1).clamp(0, mergedLength);
  }
  return mergedLength;
}

String? _findPlaceName(List<Place> places, String? placeId) {
  if (placeId == null || placeId.isEmpty) {
    return null;
  }
  for (final place in places) {
    if (place.id == placeId) {
      return place.name;
    }
  }
  return null;
}
