import 'dart:convert';
import 'dart:io';

import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora_api/dora_api.dart' as openapi;

abstract class LiveTrackingApi {
  // ─── V2 Session Control ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> startTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  });

  Future<Map<String, dynamic>> stopTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required int sealVersion,
    required String stopClientEventId,
    required DateTime stoppedAt,
    String? reason,
  });

  Future<Map<String, dynamic>> publishStartV2({
    required String tripId,
    required String idempotencyKey,
    required String clientJobId,
    required int schemaVersion,
    required Map<String, dynamic> publishSummary,
    required List<Map<String, dynamic>> mediaManifest,
    required String mediaManifestDigest,
  });

  Future<Map<String, dynamic>> publishMediaCompleteV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required List<Map<String, dynamic>> uploadedMedia,
  });

  Future<Map<String, dynamic>> publishPayloadChunkV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required int chunkIndex,
    required int totalChunks,
    required String chunkContentHash,
    required String chunkJson,
  });

  Future<Map<String, dynamic>> publishCommitV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
  });

  Future<Map<String, dynamic>> getTimelineV2({
    required String tripId,
    String? cursor,
    int limit = 200,
  });

  Future<Map<String, dynamic>> getRouteV2({
    required String tripId,
    String? cursor,
    int limitSegments = 20,
  });

  // ─── Media Upload ───────────────────────────────────────────────────────────

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

  // ─── Push Notifications ─────────────────────────────────────────────────────

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
  }) : _authTokenProvider = authTokenProvider;

  final Dio _dio;
  final AuthTokenProvider? _authTokenProvider;

  static const String _apiV2Prefix = '/api/v2';

  static DateTime _toUtc(DateTime value) => value.toUtc();

  static String _v2Path(String path) => '$_apiV2Prefix$path';

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

  Options _v2IdempotentOptions(String key) {
    return Options(
      headers: <String, dynamic>{
        'Idempotency-Key': key,
      },
    );
  }

  // ─── V2 Session Control ─────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> startTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/sessions:start'),
      data: <String, dynamic>{
        'client_session_id': clientSessionId,
        'started_at': _toUtc(startedAt).toIso8601String(),
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        'device_context': deviceContext ?? <String, dynamic>{},
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> stopTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required int sealVersion,
    required String stopClientEventId,
    required DateTime stoppedAt,
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/sessions/$clientSessionId:stop'),
      data: <String, dynamic>{
        'seal_version': sealVersion,
        'stop_client_event_id': stopClientEventId,
        'stopped_at': _toUtc(stoppedAt).toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> publishStartV2({
    required String tripId,
    required String idempotencyKey,
    required String clientJobId,
    required int schemaVersion,
    required Map<String, dynamic> publishSummary,
    required List<Map<String, dynamic>> mediaManifest,
    required String mediaManifestDigest,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/publish:start'),
      data: <String, dynamic>{
        'client_job_id': clientJobId,
        'schema_version': schemaVersion,
        'publish_summary': publishSummary,
        'media_manifest': mediaManifest,
        'media_manifest_digest': mediaManifestDigest,
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> publishMediaCompleteV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required List<Map<String, dynamic>> uploadedMedia,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/publish:media-complete'),
      data: <String, dynamic>{
        'publish_token': publishToken,
        'client_job_id': clientJobId,
        'schema_version': schemaVersion,
        'uploaded_media': uploadedMedia,
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> publishPayloadChunkV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required int chunkIndex,
    required int totalChunks,
    required String chunkContentHash,
    required String chunkJson,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/publish:payload-chunk'),
      data: <String, dynamic>{
        'publish_token': publishToken,
        'client_job_id': clientJobId,
        'schema_version': schemaVersion,
        'chunk_index': chunkIndex,
        'total_chunks': totalChunks,
        'chunk_content_hash': chunkContentHash,
        'chunk_json': chunkJson,
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> publishCommitV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
  }) async {
    final response = await _dio.post<dynamic>(
      _v2Path('/trips/$tripId/publish:commit'),
      data: <String, dynamic>{
        'publish_token': publishToken,
        'client_job_id': clientJobId,
        'schema_version': schemaVersion,
      },
      options: _v2IdempotentOptions(idempotencyKey),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> getTimelineV2({
    required String tripId,
    String? cursor,
    int limit = 200,
  }) async {
    final response = await _dio.get<dynamic>(
      _v2Path('/trips/$tripId/timeline'),
      queryParameters: <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> getRouteV2({
    required String tripId,
    String? cursor,
    int limitSegments = 20,
  }) async {
    final response = await _dio.get<dynamic>(
      _v2Path('/trips/$tripId/route'),
      queryParameters: <String, dynamic>{
        'limit_segments': limitSegments,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    return _asJsonMap(response.data);
  }

  // ─── Media Upload ───────────────────────────────────────────────────────────

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
    final authorization = await _authorizationHeader();
    final response = await _dio.post<dynamic>(
      '/api/v1/trips/$tripId/tracking/media/upload',
      data: FormData.fromMap(<String, dynamic>{
        'file': multipart,
      }),
      options: Options(
        headers: <String, dynamic>{
          if (authorization.isNotEmpty) 'Authorization': authorization,
        },
      ),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  }) async {
    final authorization = await _authorizationHeader();
    final response = await _dio.post<dynamic>(
      '/api/v1/trips/$tripId/tracking/media/batch',
      data: <String, dynamic>{
        'media': media,
      },
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey,
          if (authorization.isNotEmpty) 'Authorization': authorization,
        },
      ),
    );
    return _asJsonMap(response.data);
  }

  // ─── Push Notifications ─────────────────────────────────────────────────────

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
    final authorization = await _authorizationHeader();
    final response = await _dio.post<dynamic>(
      '/api/v1/notifications/device-tokens/register',
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
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey,
          if (authorization.isNotEmpty) 'Authorization': authorization,
        },
      ),
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
    final authorization = await _authorizationHeader();
    final response = await _dio.post<dynamic>(
      '/api/v1/notifications/device-tokens/deactivate',
      data: <String, dynamic>{
        'client_event_id': clientEventId,
        'push_token': pushToken,
        'deactivated_at':
            _toUtc(deactivatedAt ?? DateTime.now()).toIso8601String(),
      },
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey,
          if (authorization.isNotEmpty) 'Authorization': authorization,
        },
      ),
    );
    return _asJsonMap(response.data);
  }
}
