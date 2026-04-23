import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/live_tracking_api.dart';

class _CaptureAdapter implements HttpClientAdapter {
  final List<RequestOptions> captured = <RequestOptions>[];
  static final String _isoNow =
      DateTime.utc(2026, 3, 23, 10, 0, 0).toIso8601String();

  Map<String, dynamic> _payloadForPath(String path) {
    if (path.contains('/sessions:start') ||
        (path.contains('/sessions/') && path.contains(':stop'))) {
      return <String, dynamic>{
        'session_server_id': 'session-server-1',
        'trip_id': 'trip-1',
        'client_session_id': 'session-1',
        'status': 'sealed',
        'started_at': _isoNow,
        'ended_at': _isoNow,
        'stop_server_pending': false,
        'stop_client_event_id': 'stop-evt-1',
        'seal_version': 1,
      };
    }
    if (path.contains('/tracking/start') ||
        path.contains('/tracking/pause') ||
        path.contains('/tracking/resume') ||
        path.contains('/tracking/stop')) {
      return <String, dynamic>{
        'session_id': 'session-1',
        'trip_id': 'trip-1',
        'user_id': 'user-1',
        'state': 'active',
        'client_session_id': 'session-1',
        'started_at': _isoNow,
        'trip_status': 'planned',
        'tracking_enabled': true,
      };
    }
    if (path.contains('/tracking/points:batch')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'session_id': 'session-1',
        'client_batch_id': 'batch-1',
        'accepted_points': 1,
        'duplicate_points': 0,
        'ingest_job_id': 'job-1',
        'idempotency_replayed': false,
      };
    }
    if (path.contains('/tracking/events:batch')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'accepted': const <dynamic>[],
        'rejected': const <dynamic>[],
        'accepted_count': 1,
        'rejected_count': 0,
        'idempotency_replayed': false,
      };
    }
    if (path.contains('/tracking/media:upload')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'upload_ref': 'upload://ref-1',
        'mime_type': 'image/jpeg',
        'file_size_bytes': 4,
      };
    }
    if (path.contains('/tracking/media:batch')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'accepted': const <dynamic>[],
        'rejected': const <dynamic>[],
        'accepted_count': 1,
        'rejected_count': 0,
        'idempotency_replayed': false,
      };
    }
    if (path.contains('/compiled/projection') ||
        path.contains('/compiled/rebind')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'compiler_version': 1,
        'stale': false,
      };
    }
    if (path.contains('/tracking/path')) {
      return <String, dynamic>{
        'trip_id': 'trip-1',
        'session_id': 'session-1',
        'points_count': 0,
        'points': const <dynamic>[],
      };
    }
    if (path.contains('/checkins/')) {
      return <String, dynamic>{
        'candidate': <String, dynamic>{
          'id': 'candidate-1',
          'trip_id': 'trip-1',
          'user_id': 'user-1',
          'fingerprint': 'fp-1',
          'status': 'pending',
          'confidence': 0.91,
          'created_at': _isoNow,
          'updated_at': _isoNow,
        },
        'idempotency_replayed': false,
      };
    }
    if (path.contains('/moments')) {
      return <String, dynamic>{
        'id': 'moment-1',
        'trip_id': 'trip-1',
        'user_id': 'user-1',
        'source': 'manual',
        'captured_at': _isoNow,
        'created_at': _isoNow,
        'updated_at': _isoNow,
      };
    }
    if (path.contains('/notifications/device-tokens/')) {
      return <String, dynamic>{
        'token': <String, dynamic>{
          'id': 'token-1',
          'user_id': 'user-1',
          'platform': 'android',
          'is_active': true,
          'failure_count': 0,
          'last_seen_at': _isoNow,
          'created_at': _isoNow,
          'updated_at': _isoNow,
        },
        'idempotency_replayed': false,
      };
    }
    return <String, dynamic>{};
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured.add(options);
    final payload = _payloadForPath(options.path);
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SequenceAuthTokenProvider implements AuthTokenProvider {
  _SequenceAuthTokenProvider(this._tokens);

  final List<String?> _tokens;
  int _cursor = 0;

  @override
  Future<String?> getAccessToken() async {
    if (_cursor >= _tokens.length) {
      return _tokens.isEmpty ? null : _tokens.last;
    }
    return _tokens[_cursor++];
  }

  @override
  Future<String?> refreshAccessToken({bool force = false}) async {
    return getAccessToken();
  }
}

void main() {
  group('DioLiveTrackingApi', () {
    test('uses expected endpoints for media + push token APIs', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final adapter = _CaptureAdapter();
      dio.httpClientAdapter = adapter;
      final api = DioLiveTrackingApi(dio);
      final now = DateTime.utc(2026, 3, 23, 10);
      final tempFile = File(
        '${Directory.systemTemp.path}/live-tracking-api-test-${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(<int>[1, 2, 3, 4]);

      try {
        await api.uploadTrackingMediaBinary(
          tripId: 'trip-1',
          filePath: tempFile.path,
          fileName: 'capture.jpg',
        );
        await api.uploadMediaBatch(
          tripId: 'trip-1',
          idempotencyKey: 'idem-2c',
          media: const <Map<String, dynamic>>[
            <String, dynamic>{
              'client_media_id': 'media-1',
              'client_event_id': 'evt-live-1',
              'media_type': 'photo',
              'bind_mode': 'route',
              'captured_at': '2026-03-23T10:00:00Z',
              'location': <String, dynamic>{
                'latitude': 27.7,
                'longitude': 85.3,
              },
              'upload_ref': 'upload://ref-1',
            },
          ],
        );
        await api.registerDeviceToken(
          idempotencyKey: 'idem-6',
          clientEventId: 'evt-4',
          platform: 'android',
          pushToken: 'push-token-12345678',
          seenAt: now,
        );
        await api.deactivateDeviceToken(
          idempotencyKey: 'idem-7',
          clientEventId: 'evt-5',
          pushToken: 'push-token-12345678',
          deactivatedAt: now,
        );
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      final paths = adapter.captured.map((r) => r.path).toList(growable: false);
      expect(
        paths,
        <String>[
          '/api/v1/trips/trip-1/tracking/media/upload',
          '/api/v1/trips/trip-1/tracking/media/batch',
          '/api/v1/notifications/device-tokens/register',
          '/api/v1/notifications/device-tokens/deactivate',
        ],
      );
    });

    test('deactivate uses cached auth header when provider has signed out',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final adapter = _CaptureAdapter();
      dio.httpClientAdapter = adapter;
      final api = DioLiveTrackingApi(
        dio,
        authTokenProvider: _SequenceAuthTokenProvider(<String?>[
          'token-abc',
          null,
        ]),
      );
      final now = DateTime.utc(2026, 3, 23, 10);

      await api.registerDeviceToken(
        idempotencyKey: 'idem-auth-1',
        clientEventId: 'evt-auth-1',
        platform: 'android',
        pushToken: 'push-token-auth-1',
        seenAt: now,
      );
      await api.deactivateDeviceToken(
        idempotencyKey: 'idem-auth-2',
        clientEventId: 'evt-auth-2',
        pushToken: 'push-token-auth-1',
        deactivatedAt: now,
      );

      expect(adapter.captured, hasLength(2));
      expect(
        adapter.captured.first.headers['Authorization'],
        'Bearer token-abc',
      );
      expect(
        adapter.captured.last.headers['Authorization'],
        'Bearer token-abc',
      );
    });

    test('uses /api/v2 session routes for V2 command lane', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final adapter = _CaptureAdapter();
      dio.httpClientAdapter = adapter;
      final api = DioLiveTrackingApi(dio);
      final now = DateTime.utc(2026, 3, 23, 10);

      final startPayload = await api.startTrackingV2(
        tripId: 'trip-1',
        idempotencyKey: 'idem-v2-start',
        clientSessionId: 'session-1',
        startedAt: now,
        timezone: 'Asia/Kathmandu',
      );
      expect(startPayload['session_server_id'], 'session-server-1');

      await api.stopTrackingV2(
        tripId: 'trip-1',
        idempotencyKey: 'idem-v2-stop',
        clientSessionId: 'session-1',
        sealVersion: 1,
        stopClientEventId: 'stop-evt-1',
        stoppedAt: now,
        reason: 'user_stop',
      );

      expect(
        adapter.captured.map((r) => r.path).toList(growable: false),
        <String>[
          '/api/v2/trips/trip-1/sessions:start',
          '/api/v2/trips/trip-1/sessions/session-1:stop',
        ],
      );

      final startRequest = adapter.captured.first;
      expect(startRequest.headers['Idempotency-Key'], 'idem-v2-start');
      final startBody = startRequest.data as Map<String, dynamic>;
      expect(startBody['client_session_id'], 'session-1');
      expect(startBody['timezone'], 'Asia/Kathmandu');

      final stopRequest = adapter.captured.last;
      expect(stopRequest.headers['Idempotency-Key'], 'idem-v2-stop');
      final stopBody = stopRequest.data as Map<String, dynamic>;
      expect(stopBody['seal_version'], 1);
      expect(stopBody['stop_client_event_id'], 'stop-evt-1');
      expect(stopBody['reason'], 'user_stop');
    });
  });
}
