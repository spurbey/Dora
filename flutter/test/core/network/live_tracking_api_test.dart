import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';

class _CaptureAdapter implements HttpClientAdapter {
  final List<RequestOptions> captured = <RequestOptions>[];
  static final String _isoNow =
      DateTime.utc(2026, 3, 23, 10, 0, 0).toIso8601String();

  Map<String, dynamic> _payloadForPath(String path) {
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

void main() {
  group('DioLiveTrackingApi', () {
    test('uses /api/v1-prefixed routes for live-tracking endpoints', () async {
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
        final startSnapshot = await api.startTracking(
          tripId: 'trip-1',
          idempotencyKey: 'idem-1',
          clientSessionId: 'session-1',
          startedAt: now,
        );
        expect(startSnapshot['state'], 'active');
        expect(startSnapshot['session_id'], 'session-1');
        expect(startSnapshot['trip_id'], 'trip-1');
        await api.uploadPointsBatch(
          tripId: 'trip-1',
          idempotencyKey: 'idem-2',
          sessionId: 'remote-session-1',
          clientBatchId: 'batch-1',
          sentAt: now,
          points: const <Map<String, dynamic>>[
            <String, dynamic>{
              'point_id': 'p-1',
              'recorded_at': '2026-03-23T10:00:00Z',
              'latitude': 27.7,
              'longitude': 85.3,
            },
          ],
        );
        await api.uploadEventsBatch(
          tripId: 'trip-1',
          idempotencyKey: 'idem-2b',
          events: const <Map<String, dynamic>>[
            <String, dynamic>{
              'client_event_id': 'evt-live-1',
              'event_type': 'note',
              'captured_at': '2026-03-23T10:00:00Z',
            },
          ],
        );
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
        await api.fetchCompiledProjection(tripId: 'trip-1');
        await api.rebindCompiledProjection(
          tripId: 'trip-1',
          sourceEventId: 'event-1',
          action: 'bind',
          tripPlaceId: 'place-1',
        );
        await api.fetchTrackingPath(
          tripId: 'trip-1',
          sessionId: 'session-1',
          limit: 99999,
        );
        await api.confirmCheckin(
          candidateId: 'candidate-1',
          idempotencyKey: 'idem-3',
          clientEventId: 'evt-1',
          confirmedAt: now,
        );
        await api.createMoment(
          tripId: 'trip-1',
          idempotencyKey: 'idem-4',
          clientEventId: 'evt-2',
          capturedAt: now,
        );
        await api.updateMoment(
          momentId: 'moment-1',
          idempotencyKey: 'idem-5',
          clientEventId: 'evt-3',
          note: 'updated',
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
          '/api/v1/trips/trip-1/tracking/start',
          '/api/v1/trips/trip-1/tracking/points:batch',
          '/api/v1/trips/trip-1/tracking/events:batch',
          '/api/v1/trips/trip-1/tracking/media:upload',
          '/api/v1/trips/trip-1/tracking/media:batch',
          '/api/v1/trips/trip-1/compiled/projection',
          '/api/v1/trips/trip-1/compiled/rebind',
          '/api/v1/trips/trip-1/tracking/path',
          '/api/v1/checkins/candidate-1/confirm',
          '/api/v1/trips/trip-1/moments',
          '/api/v1/moments/moment-1',
          '/api/v1/notifications/device-tokens/register',
          '/api/v1/notifications/device-tokens/deactivate',
        ],
      );

      final pathRequest = adapter.captured.firstWhere(
        (request) => request.path == '/api/v1/trips/trip-1/tracking/path',
      );
      expect(pathRequest.queryParameters['session_id'], 'session-1');
      expect(pathRequest.queryParameters['limit'], 10000);
    });

    test('updateMoment sends explicit clear fields only with include flags',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final adapter = _CaptureAdapter();
      dio.httpClientAdapter = adapter;
      final api = DioLiveTrackingApi(dio);

      await api.updateMoment(
        momentId: 'moment-1',
        idempotencyKey: 'idem-a',
        clientEventId: 'evt-a',
        note: null,
        linkedTripPlaceId: null,
      );
      await api.updateMoment(
        momentId: 'moment-1',
        idempotencyKey: 'idem-b',
        clientEventId: 'evt-b',
        note: null,
        includeNote: true,
        linkedTripPlaceId: null,
        includeLinkedTripPlaceId: true,
      );

      final firstPayload = adapter.captured[0].data as Map<String, dynamic>;
      expect(firstPayload.containsKey('note'), isFalse);
      expect(firstPayload.containsKey('linked_trip_place_id'), isFalse);

      final secondPayload = adapter.captured[1].data as Map<String, dynamic>;
      expect(secondPayload.containsKey('note'), isTrue);
      expect(secondPayload['note'], isNull);
      expect(secondPayload.containsKey('linked_trip_place_id'), isTrue);
      expect(secondPayload['linked_trip_place_id'], isNull);
    });
  });
}
