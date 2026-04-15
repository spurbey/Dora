import 'package:dora/core/network/live_tracking_api.dart';

class V2StartCommandResult {
  const V2StartCommandResult({
    required this.remoteSessionId,
    required this.startedAt,
  });

  final String remoteSessionId;
  final DateTime? startedAt;
}

abstract class V2CommandApi {
  Future<V2StartCommandResult> start({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  });

  Future<void> stop({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientSessionId,
    required int sealVersion,
    required String stopClientEventId,
    required DateTime stoppedAt,
    String? reason,
  });
}

class V2BridgeCommandApi implements V2CommandApi {
  const V2BridgeCommandApi({
    required LiveTrackingApi liveTrackingApi,
  }) : _liveTrackingApi = liveTrackingApi;

  final LiveTrackingApi _liveTrackingApi;

  @override
  Future<V2StartCommandResult> start({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    final payload = await _liveTrackingApi.startTrackingV2(
      tripId: remoteTripId,
      idempotencyKey: idempotencyKey,
      clientSessionId: clientSessionId,
      startedAt: startedAt,
      timezone: timezone,
      deviceContext: deviceContext,
    );
    final remoteSessionId = payload['session_server_id']?.toString().trim() ??
        payload['session_id']?.toString().trim() ??
        '';
    if (remoteSessionId.isEmpty) {
      throw const V2CommandTransportException(
        code: 'missing_remote_session_id',
        message: 'Start response missing session_server_id.',
      );
    }
    final startedAtRaw = payload['started_at']?.toString();
    final parsedStartedAt = startedAtRaw == null || startedAtRaw.isEmpty
        ? null
        : DateTime.tryParse(startedAtRaw)?.toUtc();
    return V2StartCommandResult(
      remoteSessionId: remoteSessionId,
      startedAt: parsedStartedAt,
    );
  }

  @override
  Future<void> stop({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientSessionId,
    required int sealVersion,
    required String stopClientEventId,
    required DateTime stoppedAt,
    String? reason,
  }) async {
    await _liveTrackingApi.stopTrackingV2(
      tripId: remoteTripId,
      idempotencyKey: idempotencyKey,
      clientSessionId: clientSessionId,
      sealVersion: sealVersion,
      stopClientEventId: stopClientEventId,
      stoppedAt: stoppedAt,
      reason: reason,
    );
  }
}

class V2CommandTransportException implements Exception {
  const V2CommandTransportException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'V2CommandTransportException($code): $message';
}
