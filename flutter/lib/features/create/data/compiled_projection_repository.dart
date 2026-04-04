import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/features/create/domain/compiled_projection.dart';

/// Fetches and mutates compiled projections via backend API.
///
/// All public methods accept **local IDs** (canonical in Flutter state).
/// Server ID resolution is handled internally via [resolveServerTripId] and
/// [resolveServerPlaceId]. If a required server ID is missing, the method
/// returns a fallback or throws — it never sends a local ID to the backend.
class CompiledProjectionRepository {
  CompiledProjectionRepository({
    required LiveTrackingApi liveTrackingApi,
    Future<String?> Function(String localTripId)? resolveServerTripId,
    Future<String?> Function(String localPlaceId)? resolveServerPlaceId,
  })  : _liveTrackingApi = liveTrackingApi,
        _resolveServerTripId = resolveServerTripId,
        _resolveServerPlaceId = resolveServerPlaceId;

  final LiveTrackingApi _liveTrackingApi;
  final Future<String?> Function(String localTripId)? _resolveServerTripId;
  final Future<String?> Function(String localPlaceId)? _resolveServerPlaceId;

  /// Fetches the compiled projection for a trip.
  ///
  /// [tripId] is the local trip ID. Resolves to server ID before API call.
  /// Returns empty snapshot if server trip ID is not yet available.
  Future<CompiledProjectionSnapshot> fetchProjection({
    required String tripId,
  }) async {
    final serverTripId = await _requireServerTripId(tripId);
    if (serverTripId == null) {
      return CompiledProjectionSnapshot(
        tripId: tripId,
        compilerVersion: 0,
        stale: true,
        timelineEntries: const <CompiledTimelineEntry>[],
        timelineGroups: const <CompiledTimelineDayGroup>[],
        routeSegments: const <CompiledRouteSegment>[],
      );
    }
    final response = await _liveTrackingApi.fetchCompiledProjection(
      tripId: serverTripId,
    );
    return CompiledProjectionSnapshot.fromJson(response);
  }

  /// Rebinds a compiled projection item to a place.
  ///
  /// All IDs are local. Resolved to server IDs before API call.
  /// Returns null if any required server ID is missing (not yet synced).
  Future<CompiledProjectionSnapshot?> rebind({
    required String tripId,
    required String sourceKind,
    required CompiledRebindAction action,
    String? sourceEventId,
    String? sourceMediaId,
    String? tripPlaceId,
  }) async {
    final serverTripId = await _requireServerTripId(tripId);
    if (serverTripId == null) {
      return null;
    }

    // Resolve place ID if provided.
    String? serverPlaceId;
    if (tripPlaceId != null && tripPlaceId.isNotEmpty) {
      serverPlaceId = await _resolvePlace(tripPlaceId);
      if (serverPlaceId == null) {
        return null; // Place not yet synced — caller should show actionable message.
      }
    }

    final normalizedSourceKind = sourceKind.trim().toLowerCase();
    final selectedSourceId =
        (normalizedSourceKind == 'tracking_event_media'
                ? sourceMediaId
                : sourceEventId)
            ?.trim();
    if (selectedSourceId == null || selectedSourceId.isEmpty) {
      throw ArgumentError(
        'source id is required for compiled projection rebind',
      );
    }
    final response = normalizedSourceKind == 'tracking_event_media'
        ? await _liveTrackingApi.rebindCompiledProjectionMedia(
            tripId: serverTripId,
            sourceMediaId: selectedSourceId,
            action: action.name,
            tripPlaceId: serverPlaceId,
          )
        : await _liveTrackingApi.rebindCompiledProjection(
            tripId: serverTripId,
            sourceEventId: selectedSourceId,
            action: action.name,
            tripPlaceId: serverPlaceId,
          );
    return CompiledProjectionSnapshot.fromJson(response);
  }

  Future<String?> _requireServerTripId(String localTripId) async {
    final resolver = _resolveServerTripId;
    if (resolver == null) return localTripId; // No resolver — assume IDs match.
    return resolver(localTripId);
  }

  Future<String?> _resolvePlace(String localPlaceId) async {
    final resolver = _resolveServerPlaceId;
    if (resolver == null) return localPlaceId; // No resolver — assume IDs match.
    return resolver(localPlaceId);
  }
}

enum CompiledRebindAction {
  bind,
  unbind,
}
