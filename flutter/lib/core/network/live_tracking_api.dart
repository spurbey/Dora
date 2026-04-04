import 'dart:convert';
import 'dart:io';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora_api/dora_api.dart' as openapi;

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
  DioLiveTrackingApi(
    this._dio, {
    AuthTokenProvider? authTokenProvider,
    openapi.LiveTrackingApi? liveTrackingApi,
    openapi.CompiledProjectionApi? compiledProjectionApi,
  })  : _authTokenProvider = authTokenProvider,
        _liveTrackingApi = liveTrackingApi ??
            openapi.LiveTrackingApi(_dio, openapi.standardSerializers),
        _compiledProjectionApi = compiledProjectionApi ??
            openapi.CompiledProjectionApi(_dio, openapi.standardSerializers);

  final Dio _dio;
  final AuthTokenProvider? _authTokenProvider;
  final openapi.LiveTrackingApi _liveTrackingApi;
  final openapi.CompiledProjectionApi _compiledProjectionApi;

  static const String _apiV1Prefix = '/api/v1';

  static DateTime _toUtc(DateTime value) => value.toUtc();

  static String _v1Path(String path) => '$_apiV1Prefix$path';

  static Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data == null) {
      return <String, dynamic>{};
    }
    if (data is Map<String, dynamic>) {
      return _unwrapBuiltValueEnvelope(data.map(
        (key, value) => MapEntry(key, _normalizeSerializedValue(value)),
      ));
    }
    if (data is Map) {
      return _unwrapBuiltValueEnvelope(data.map(
        (key, value) =>
            MapEntry(key.toString(), _normalizeSerializedValue(value)),
      ));
    }
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return _unwrapBuiltValueEnvelope(decoded.map(
          (key, value) => MapEntry(key, _normalizeSerializedValue(value)),
        ));
      }
      if (decoded is Map) {
        return _unwrapBuiltValueEnvelope(decoded.map(
          (key, value) =>
              MapEntry(key.toString(), _normalizeSerializedValue(value)),
        ));
      }
    }
    try {
      final serialized = openapi.standardSerializers.serialize(data);
      if (serialized is Map<String, dynamic>) {
        return _unwrapBuiltValueEnvelope(serialized.map(
          (key, value) => MapEntry(key, _normalizeSerializedValue(value)),
        ));
      }
      if (serialized is Map) {
        return _unwrapBuiltValueEnvelope(serialized.map(
          (key, value) =>
              MapEntry(key.toString(), _normalizeSerializedValue(value)),
        ));
      }
      if (serialized is List) {
        final mapped = _mapFromSerializedList(serialized);
        if (mapped != null) {
          return _unwrapBuiltValueEnvelope(mapped);
        }
      }
      final normalized = jsonDecode(jsonEncode(serialized));
      if (normalized is Map<String, dynamic>) {
        return _unwrapBuiltValueEnvelope(normalized.map(
          (key, value) => MapEntry(key, _normalizeSerializedValue(value)),
        ));
      }
      if (normalized is Map) {
        return _unwrapBuiltValueEnvelope(normalized.map(
          (key, value) =>
              MapEntry(key.toString(), _normalizeSerializedValue(value)),
        ));
      }
    } catch (_) {
      // Keep compatibility with legacy call-sites by returning empty map.
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? _mapFromSerializedList(List<dynamic> list) {
    if (list.isEmpty || list.length.isOdd) {
      return null;
    }
    final mapped = <String, dynamic>{};
    for (var i = 0; i < list.length; i += 2) {
      final key = list[i];
      if (key is! String) {
        return null;
      }
      mapped[key] = _normalizeSerializedValue(list[i + 1]);
    }
    return mapped;
  }

  static Map<String, dynamic> _unwrapBuiltValueEnvelope(
    Map<String, dynamic> value,
  ) {
    final payload = value[''];
    if (payload is Map<String, dynamic>) {
      return payload.map(
        (key, nested) => MapEntry(key, _normalizeSerializedValue(nested)),
      );
    }
    if (payload is Map) {
      return payload.map(
        (key, nested) =>
            MapEntry(key.toString(), _normalizeSerializedValue(nested)),
      );
    }
    if (payload is List) {
      final mapped = _mapFromSerializedList(payload);
      if (mapped != null) {
        return mapped;
      }
    }
    return value;
  }

  static dynamic _normalizeSerializedValue(dynamic value) {
    if (value is JsonObject) {
      return _normalizeSerializedValue(value.value);
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, nested) => MapEntry(key, _normalizeSerializedValue(nested)),
      );
    }
    if (value is Map) {
      return value.map(
        (key, nested) =>
            MapEntry(key.toString(), _normalizeSerializedValue(nested)),
      );
    }
    if (value is List) {
      final mapped = _mapFromSerializedList(value);
      if (mapped != null) {
        return mapped;
      }
      return value.map(_normalizeSerializedValue).toList(growable: false);
    }
    return value;
  }

  T _deserialize<T>(Map<String, dynamic> data, FullType type) {
    final deserialized = openapi.standardSerializers.deserialize(
      data,
      specifiedType: type,
    );
    return deserialized as T;
  }

  Future<String> _authorizationHeader() async {
    final authTokenProvider = _authTokenProvider;
    if (authTokenProvider != null) {
      final token = await authTokenProvider.getAccessToken();
      if (token != null && token.isNotEmpty) {
        if (token.toLowerCase().startsWith('bearer ')) {
          return token;
        }
        return 'Bearer $token';
      }
    }

    final header = _dio.options.headers['Authorization'] ??
        _dio.options.headers['authorization'];
    if (header is String && header.trim().isNotEmpty) {
      return header.trim();
    }

    return '';
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
    final request = _deserialize<openapi.TrackingStartRequest>(
      <String, dynamic>{
        'client_session_id': clientSessionId,
        'started_at': _toUtc(startedAt).toIso8601String(),
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        'device_context': deviceContext ?? <String, dynamic>{},
      },
      const FullType(openapi.TrackingStartRequest),
    );

    final response =
        await _liveTrackingApi.startTrackingApiV1TripsTripIdTrackingStartPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingStartRequest: request,
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
    final request = _deserialize<openapi.TrackingPauseRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'paused_at': _toUtc(pausedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      const FullType(openapi.TrackingPauseRequest),
    );

    final response =
        await _liveTrackingApi.pauseTrackingApiV1TripsTripIdTrackingPausePost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingPauseRequest: request,
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
    final request = _deserialize<openapi.TrackingResumeRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'resumed_at': _toUtc(resumedAt).toIso8601String(),
      },
      const FullType(openapi.TrackingResumeRequest),
    );

    final response =
        await _liveTrackingApi.resumeTrackingApiV1TripsTripIdTrackingResumePost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingResumeRequest: request,
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
    final request = _deserialize<openapi.TrackingStopRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        'stopped_at': _toUtc(stoppedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      const FullType(openapi.TrackingStopRequest),
    );

    final response =
        await _liveTrackingApi.stopTrackingApiV1TripsTripIdTrackingStopPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingStopRequest: request,
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
    final request = _deserialize<openapi.TrackingPointsBatchRequest>(
      <String, dynamic>{
        'session_id': sessionId,
        'client_batch_id': clientBatchId,
        'sent_at': _toUtc(sentAt).toIso8601String(),
        'points': points,
      },
      const FullType(openapi.TrackingPointsBatchRequest),
    );

    final response = await _liveTrackingApi
        .ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingPointsBatchRequest: request,
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadEventsBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> events,
  }) async {
    final request = _deserialize<openapi.TrackingEventsBatchRequest>(
      <String, dynamic>{'events': events},
      const FullType(openapi.TrackingEventsBatchRequest),
    );

    final response = await _liveTrackingApi
        .ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingEventsBatchRequest: request,
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
    final multipart = await MultipartFile.fromFile(
      filePath,
      filename: resolvedFileName,
    );
    final response = await _liveTrackingApi
        .uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost(
      tripId: tripId,
      authorization: await _authorizationHeader(),
      file: multipart,
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  }) async {
    final request = _deserialize<openapi.TrackingMediaBatchRequest>(
      <String, dynamic>{'media': media},
      const FullType(openapi.TrackingMediaBatchRequest),
    );

    final response = await _liveTrackingApi
        .ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      trackingMediaBatchRequest: request,
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> fetchCompiledProjection({
    required String tripId,
  }) async {
    final response = await _compiledProjectionApi
        .getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet(
      tripId: tripId,
      authorization: await _authorizationHeader(),
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
    final request = _deserialize<openapi.CompiledRebindRequest>(
      <String, dynamic>{
        'source_kind': 'tracking_event',
        'source_event_id': sourceEventId,
        'action': action,
        if (tripPlaceId != null && tripPlaceId.isNotEmpty)
          'trip_place_id': tripPlaceId,
      },
      const FullType(openapi.CompiledRebindRequest),
    );

    final response = await _compiledProjectionApi
        .rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost(
      tripId: tripId,
      authorization: await _authorizationHeader(),
      compiledRebindRequest: request,
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
    final request = _deserialize<openapi.CompiledRebindRequest>(
      <String, dynamic>{
        'source_kind': 'tracking_event_media',
        'source_media_id': sourceMediaId,
        'action': action,
        if (tripPlaceId != null && tripPlaceId.isNotEmpty)
          'trip_place_id': tripPlaceId,
      },
      const FullType(openapi.CompiledRebindRequest),
    );

    final response = await _compiledProjectionApi
        .rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost(
      tripId: tripId,
      authorization: await _authorizationHeader(),
      compiledRebindRequest: request,
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
    final response =
        await _liveTrackingApi.getTrackingPathApiV1TripsTripIdTrackingPathGet(
      tripId: tripId,
      authorization: await _authorizationHeader(),
      sessionId: (sessionId != null && sessionId.isNotEmpty) ? sessionId : null,
      limit: clampedLimit,
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
    final request = _deserialize<openapi.CheckinConfirmRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'confirmed_at': _toUtc(confirmedAt).toIso8601String(),
      },
      const FullType(openapi.CheckinConfirmRequest),
    );

    final response = await _liveTrackingApi
        .confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost(
      candidateId: candidateId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      checkinConfirmRequest: request,
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
    final request = _deserialize<openapi.CheckinRejectRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'rejected_at': _toUtc(rejectedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      const FullType(openapi.CheckinRejectRequest),
    );

    final response = await _liveTrackingApi
        .rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost(
      candidateId: candidateId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      checkinRejectRequest: request,
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
    final request = _deserialize<openapi.CheckinSnoozeRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'snoozed_until': _toUtc(snoozedUntil).toIso8601String(),
      },
      const FullType(openapi.CheckinSnoozeRequest),
    );

    final response = await _liveTrackingApi
        .snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost(
      candidateId: candidateId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      checkinSnoozeRequest: request,
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
    final request = _deserialize<openapi.MomentCreateRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'captured_at': _toUtc(capturedAt).toIso8601String(),
        if (note != null) 'note': note,
        if (location != null) 'location': location,
        'media_refs': mediaRefs ?? <Map<String, dynamic>>[],
        if (linkedTripPlaceId != null && linkedTripPlaceId.isNotEmpty)
          'linked_trip_place_id': linkedTripPlaceId,
        'extra_payload': extraPayload ?? <String, dynamic>{},
      },
      const FullType(openapi.MomentCreateRequest),
    );

    final response =
        await _liveTrackingApi.createTripMomentApiV1TripsTripIdMomentsPost(
      tripId: tripId,
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      momentCreateRequest: request,
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
    // Keep manual payload construction here to preserve explicit-null patch
    // semantics for clear-intent fields (note / linked_trip_place_id).
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
    final request = _deserialize<openapi.DeviceTokenRegisterRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'platform': platform,
        'push_token': pushToken,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        if (appVersion != null && appVersion.isNotEmpty)
          'app_version': appVersion,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
        'seen_at': _toUtc(seenAt ?? DateTime.now()).toIso8601String(),
      },
      const FullType(openapi.DeviceTokenRegisterRequest),
    );

    final response = await _liveTrackingApi
        .registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost(
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      deviceTokenRegisterRequest: request,
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
    final request = _deserialize<openapi.DeviceTokenDeactivateRequest>(
      <String, dynamic>{
        'client_event_id': clientEventId,
        'push_token': pushToken,
        'deactivated_at':
            _toUtc(deactivatedAt ?? DateTime.now()).toIso8601String(),
      },
      const FullType(openapi.DeviceTokenDeactivateRequest),
    );

    final response = await _liveTrackingApi
        .deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost(
      xIdempotencyKey: idempotencyKey,
      authorization: await _authorizationHeader(),
      deviceTokenDeactivateRequest: request,
    );
    return _asJsonMap(response.data);
  }
}
