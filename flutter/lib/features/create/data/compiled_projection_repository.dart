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
    required String sourceEventId,
    required CompiledRebindAction action,
    String? tripPlaceId,
  }) async {
    final response = await _liveTrackingApi.rebindCompiledProjection(
      tripId: tripId,
      sourceEventId: sourceEventId,
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
