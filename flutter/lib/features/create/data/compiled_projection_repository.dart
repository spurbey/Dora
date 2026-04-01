import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/features/create/domain/compiled_projection.dart';

class CompiledProjectionRepository {
  CompiledProjectionRepository({
    required LiveTrackingApi liveTrackingApi,
  }) : _liveTrackingApi = liveTrackingApi;

  final LiveTrackingApi _liveTrackingApi;

  Future<CompiledProjectionSnapshot> fetchProjection({
    required String tripId,
  }) async {
    final response = await _liveTrackingApi.fetchCompiledProjection(
      tripId: tripId,
    );
    return CompiledProjectionSnapshot.fromJson(response);
  }

  Future<CompiledProjectionSnapshot> rebind({
    required String tripId,
    required String sourceKind,
    required CompiledRebindAction action,
    String? sourceEventId,
    String? sourceMediaId,
    String? tripPlaceId,
  }) async {
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
            tripId: tripId,
            sourceMediaId: selectedSourceId,
            action: action.name,
            tripPlaceId: tripPlaceId,
          )
        : await _liveTrackingApi.rebindCompiledProjection(
            tripId: tripId,
            sourceEventId: selectedSourceId,
            action: action.name,
            tripPlaceId: tripPlaceId,
          );
    return CompiledProjectionSnapshot.fromJson(response);
  }
}

enum CompiledRebindAction {
  bind,
  unbind,
}
