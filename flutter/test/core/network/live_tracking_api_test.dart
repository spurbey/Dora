import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';

class _CaptureAdapter implements HttpClientAdapter {
  final List<RequestOptions> captured = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured.add(options);
    return ResponseBody.fromString(
      '{}',
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

      await api.startTracking(
        tripId: 'trip-1',
        idempotencyKey: 'idem-1',
        clientSessionId: 'session-1',
        startedAt: now,
      );
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

      final paths = adapter.captured.map((r) => r.path).toList(growable: false);
      expect(
        paths,
        <String>[
          '/api/v1/trips/trip-1/tracking/start',
          '/api/v1/trips/trip-1/tracking/points:batch',
          '/api/v1/trips/trip-1/tracking/path',
          '/api/v1/checkins/candidate-1/confirm',
          '/api/v1/trips/trip-1/moments',
          '/api/v1/moments/moment-1',
          '/api/v1/notifications/device-tokens/register',
          '/api/v1/notifications/device-tokens/deactivate',
        ],
      );

      final pathRequest = adapter.captured[2];
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
