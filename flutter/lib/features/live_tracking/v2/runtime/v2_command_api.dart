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
    required String clientEventId,
    required DateTime stoppedAt,
    String? remoteSessionId,
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
    final payload = await _liveTrackingApi.startTracking(
      tripId: remoteTripId,
      idempotencyKey: idempotencyKey,
      clientSessionId: clientSessionId,
      startedAt: startedAt,
      timezone: timezone,
      deviceContext: deviceContext,
    );
    final remoteSessionId = payload['session_id']?.toString().trim() ?? '';
    if (remoteSessionId.isEmpty) {
      throw const V2CommandTransportException(
        code: 'missing_remote_session_id',
        message: 'Start response missing session_id.',
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
    required String clientEventId,
    required DateTime stoppedAt,
    String? remoteSessionId,
    String? reason,
  }) async {
    await _liveTrackingApi.stopTracking(
      tripId: remoteTripId,
      idempotencyKey: idempotencyKey,
      clientEventId: clientEventId,
      stoppedAt: stoppedAt,
      sessionId: remoteSessionId,
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
