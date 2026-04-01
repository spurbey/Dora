import 'dart:convert';
import 'dart:io';

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

  Future<Map<String, dynamic>> uploadEventsBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> events,
  });

  Future<Map<String, dynamic>> uploadTrackingMediaBinary({
    required String tripId,
    required String filePath,
    String? fileName,
  });

  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  });

  Future<Map<String, dynamic>> fetchCompiledProjection({
    required String tripId,
  });

  Future<Map<String, dynamic>> rebindCompiledProjection({
    required String tripId,
    required String sourceEventId,
    required String action,
    String? tripPlaceId,
  });

  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
  }) {
    return rebindCompiledProjection(
      tripId: tripId,
      sourceEventId: sourceMediaId,
      action: action,
      tripPlaceId: tripPlaceId,
    );
  }

  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
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
    bool includeNote = false,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    bool includeLinkedTripPlaceId = false,
    Map<String, dynamic>? extraPayload,
  });

  Future<Map<String, dynamic>> registerDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String platform,
    required String pushToken,
    DateTime? seenAt,
    String? deviceId,
    String? appVersion,
    String? locale,
  });

  Future<Map<String, dynamic>> deactivateDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String pushToken,
    DateTime? deactivatedAt,
  });
}

class DioLiveTrackingApi implements LiveTrackingApi {
  DioLiveTrackingApi(this._dio);

  final Dio _dio;
  static const String _apiV1Prefix = '/api/v1';

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

  static String _v1Path(String path) => '$_apiV1Prefix$path';

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
      _v1Path('/trips/$tripId/tracking/start'),
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
      _v1Path('/trips/$tripId/tracking/pause'),
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
      _v1Path('/trips/$tripId/tracking/resume'),
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
      _v1Path('/trips/$tripId/tracking/stop'),
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
      _v1Path('/trips/$tripId/tracking/points:batch'),
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
  Future<Map<String, dynamic>> uploadEventsBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> events,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/trips/$tripId/tracking/events:batch'),
      data: <String, dynamic>{
        'events': events,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadTrackingMediaBinary({
    required String tripId,
    required String filePath,
    String? fileName,
  }) async {
    final resolvedFileName = (fileName != null && fileName.trim().isNotEmpty)
        ? fileName.trim()
        : filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap(
      <String, dynamic>{
        'file': await MultipartFile.fromFile(
          filePath,
          filename: resolvedFileName,
        ),
      },
    );
    final response = await _dio.post<dynamic>(
      _v1Path('/trips/$tripId/tracking/media:upload'),
      data: formData,
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/trips/$tripId/tracking/media:batch'),
      data: <String, dynamic>{
        'media': media,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchCompiledProjection({
    required String tripId,
  }) async {
    final response = await _dio.get<dynamic>(
      _v1Path('/trips/$tripId/compiled/projection'),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjection({
    required String tripId,
    required String sourceEventId,
    required String action,
    String? tripPlaceId,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/trips/$tripId/compiled/rebind'),
      data: <String, dynamic>{
        'source_kind': 'tracking_event',
        'source_event_id': sourceEventId,
        'action': action,
        if (tripPlaceId != null && tripPlaceId.isNotEmpty)
          'trip_place_id': tripPlaceId,
      },
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/trips/$tripId/compiled/rebind'),
      data: <String, dynamic>{
        'source_kind': 'tracking_event_media',
        'source_media_id': sourceMediaId,
        'action': action,
        if (tripPlaceId != null && tripPlaceId.isNotEmpty)
          'trip_place_id': tripPlaceId,
      },
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) async {
    final clampedLimit = limit.clamp(1, 10000);
    final response = await _dio.get<dynamic>(
      _v1Path('/trips/$tripId/tracking/path'),
      queryParameters: <String, dynamic>{
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'limit': clampedLimit,
      },
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
      _v1Path('/checkins/$candidateId/confirm'),
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
      _v1Path('/checkins/$candidateId/reject'),
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
      _v1Path('/checkins/$candidateId/snooze'),
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
      _v1Path('/trips/$tripId/moments'),
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
    bool includeNote = false,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    bool includeLinkedTripPlaceId = false,
    Map<String, dynamic>? extraPayload,
  }) async {
    final response = await _dio.patch<dynamic>(
      _v1Path('/moments/$momentId'),
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        if (capturedAt != null)
          'captured_at': _toUtc(capturedAt).toIso8601String(),
        if (includeNote || note != null) 'note': note,
        if (location != null) 'location': location,
        if (mediaRefs != null) 'media_refs': mediaRefs,
        if (includeLinkedTripPlaceId ||
            (linkedTripPlaceId != null && linkedTripPlaceId.isNotEmpty))
          'linked_trip_place_id': linkedTripPlaceId,
        if (extraPayload != null) 'extra_payload': extraPayload,
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> registerDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String platform,
    required String pushToken,
    DateTime? seenAt,
    String? deviceId,
    String? appVersion,
    String? locale,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/notifications/device-tokens/register'),
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'platform': platform,
        'push_token': pushToken,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        if (appVersion != null && appVersion.isNotEmpty)
          'app_version': appVersion,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
        'seen_at': _toUtc(seenAt ?? DateTime.now()).toIso8601String(),
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> deactivateDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String pushToken,
    DateTime? deactivatedAt,
  }) async {
    final response = await _dio.post<dynamic>(
      _v1Path('/notifications/device-tokens/deactivate'),
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'push_token': pushToken,
        'deactivated_at':
            _toUtc(deactivatedAt ?? DateTime.now()).toIso8601String(),
      },
      options: _idempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }
}
