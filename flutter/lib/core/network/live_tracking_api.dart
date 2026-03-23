import 'dart:convert';

import 'package:dio/dio.dart';

abstract class LiveTrackingApi {
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  });

  Future<Map<String, dynamic>> pauseTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime pausedAt,
    String? sessionId,
    String? reason,
  });

  Future<Map<String, dynamic>> resumeTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime resumedAt,
    String? sessionId,
  });

  Future<Map<String, dynamic>> stopTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? sessionId,
    String? reason,
  });

  Future<Map<String, dynamic>> uploadPointsBatch({
    required String tripId,
    required String idempotencyKey,
    required String sessionId,
    required String clientBatchId,
    required DateTime sentAt,
    required List<Map<String, dynamic>> points,
  });

  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  });

  Future<Map<String, dynamic>> rejectCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime rejectedAt,
    String? reason,
  });

  Future<Map<String, dynamic>> snoozeCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime snoozedUntil,
  });

  Future<Map<String, dynamic>> createMoment({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  });

  Future<Map<String, dynamic>> updateMoment({
    required String momentId,
    required String idempotencyKey,
    required String clientEventId,
    DateTime? capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  });
}

class DioLiveTrackingApi implements LiveTrackingApi {
  DioLiveTrackingApi(this._dio);

  final Dio _dio;

  static DateTime _toUtc(DateTime value) => value.toUtc();

  static Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return <String, dynamic>{};
  }

  Options _idempotentOptions(String key) {
    return Options(
      headers: <String, dynamic>{
        'X-Idempotency-Key': key,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/tracking/start',
      data: <String, dynamic>{
        'client_session_id': clientSessionId,
        'started_at': _toUtc(startedAt).toIso8601String(),
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        'device_context': deviceContext ?? <String, dynamic>{},
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> pauseTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime pausedAt,
    String? sessionId,
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/tracking/pause',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'paused_at': _toUtc(pausedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> resumeTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime resumedAt,
    String? sessionId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/tracking/resume',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'resumed_at': _toUtc(resumedAt).toIso8601String(),
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> stopTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? sessionId,
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/tracking/stop',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'stopped_at': _toUtc(stoppedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadPointsBatch({
    required String tripId,
    required String idempotencyKey,
    required String sessionId,
    required String clientBatchId,
    required DateTime sentAt,
    required List<Map<String, dynamic>> points,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/tracking/points:batch',
      data: <String, dynamic>{
        'session_id': sessionId,
        'client_batch_id': clientBatchId,
        'sent_at': _toUtc(sentAt).toIso8601String(),
        'points': points,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  }) async {
    final response = await _dio.post<dynamic>(
      '/checkins/$candidateId/confirm',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'confirmed_at': _toUtc(confirmedAt).toIso8601String(),
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> rejectCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime rejectedAt,
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      '/checkins/$candidateId/reject',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'rejected_at': _toUtc(rejectedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> snoozeCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime snoozedUntil,
  }) async {
    final response = await _dio.post<dynamic>(
      '/checkins/$candidateId/snooze',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'snoozed_until': _toUtc(snoozedUntil).toIso8601String(),
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> createMoment({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  }) async {
    final response = await _dio.post<dynamic>(
      '/trips/$tripId/moments',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'captured_at': _toUtc(capturedAt).toIso8601String(),
        if (note != null) 'note': note,
        if (location != null) 'location': location,
        'media_refs': mediaRefs ?? <Map<String, dynamic>>[],
        if (linkedTripPlaceId != null && linkedTripPlaceId.isNotEmpty)
          'linked_trip_place_id': linkedTripPlaceId,
        'extra_payload': extraPayload ?? <String, dynamic>{},
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateMoment({
    required String momentId,
    required String idempotencyKey,
    required String clientEventId,
    DateTime? capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/moments/$momentId',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        if (capturedAt != null) 'captured_at': _toUtc(capturedAt).toIso8601String(),
        if (note != null) 'note': note,
        if (location != null) 'location': location,
        if (mediaRefs != null) 'media_refs': mediaRefs,
        if (linkedTripPlaceId != null && linkedTripPlaceId.isNotEmpty)
          'linked_trip_place_id': linkedTripPlaceId,
        if (extraPayload != null) 'extra_payload': extraPayload,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }
}
