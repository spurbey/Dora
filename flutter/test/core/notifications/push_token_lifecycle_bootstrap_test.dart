import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/notifications/push_token_client.dart';
import 'package:dora/core/notifications/push_token_lifecycle_bootstrap.dart';

class _RegisterCall {
  const _RegisterCall({
    required this.platform,
    required this.pushToken,
    required this.locale,
  });

  final String platform;
  final String pushToken;
  final String? locale;
}

class _DeactivateCall {
  const _DeactivateCall({
    required this.pushToken,
  });

  final String pushToken;
}

class _FakeLiveTrackingApi implements LiveTrackingApi {
  final List<_RegisterCall> registerCalls = <_RegisterCall>[];
  final List<_DeactivateCall> deactivateCalls = <_DeactivateCall>[];
  Completer<void>? registerGate;

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
    final gate = registerGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    registerCalls.add(
      _RegisterCall(
        platform: platform,
        pushToken: pushToken,
        locale: locale,
      ),
    );
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<Map<String, dynamic>> deactivateDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String pushToken,
    DateTime? deactivatedAt,
  }) async {
    deactivateCalls.add(_DeactivateCall(pushToken: pushToken));
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> startTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishMediaCompleteV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required List<Map<String, dynamic>> uploadedMedia,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishCommitV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> pauseTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime pausedAt,
    String? sessionId,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> resumeTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime resumedAt,
    String? sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> stopTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? sessionId,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadPointsBatch({
    required String tripId,
    required String idempotencyKey,
    required String sessionId,
    required String clientBatchId,
    required DateTime sentAt,
    required List<Map<String, dynamic>> points,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadEventsBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> events,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadTrackingMediaBinary({
    required String tripId,
    required String filePath,
    String? fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchCompiledProjection({
    required String tripId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjection({
    required String tripId,
    required String sourceEventId,
    required String action,
    String? tripPlaceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rejectCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime rejectedAt,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> snoozeCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime snoozedUntil,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }
}

class _FakePushTokenClient implements PushTokenClient {
  _FakePushTokenClient({required this.token});

  final StreamController<String> _refreshController =
      StreamController<String>.broadcast();
  String? token;
  bool permissionGranted = true;
  int permissionRequests = 0;

  @override
  Future<bool> ensurePermissionRequested() async {
    permissionRequests += 1;
    return permissionGranted;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => _refreshController.stream;

  void emitTokenRefresh(String token) {
    _refreshController.add(token);
  }

  Future<void> dispose() async {
    await _refreshController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  group('PushTokenLifecycleBootstrap', () {
    test('registers token on start when already signed in', () async {
      final authStateController = StreamController<Object?>.broadcast();
      final fakeApi = _FakeLiveTrackingApi();
      final fakePushClient = _FakePushTokenClient(token: 'push-token-1');
      final bootstrap = PushTokenLifecycleBootstrap(
        authStateChanges: authStateController.stream,
        isSignedIn: () => true,
        liveTrackingApi: fakeApi,
        pushTokenClient: fakePushClient,
        clock: () => DateTime.utc(2026, 3, 25, 10, 0),
        platformResolver: () => 'android',
        localeResolver: () => 'en-US',
      );

      bootstrap.start();
      await settle();

      expect(fakeApi.registerCalls, hasLength(1));
      expect(fakeApi.registerCalls.single.pushToken, 'push-token-1');
      expect(fakeApi.registerCalls.single.platform, 'android');
      expect(fakeApi.registerCalls.single.locale, 'en-US');

      bootstrap.dispose();
      await fakePushClient.dispose();
      await authStateController.close();
    });

    test('refreshes token registration when app resumes', () async {
      final authStateController = StreamController<Object?>.broadcast();
      final fakeApi = _FakeLiveTrackingApi();
      final fakePushClient = _FakePushTokenClient(token: 'push-token-1');
      final bootstrap = PushTokenLifecycleBootstrap(
        authStateChanges: authStateController.stream,
        isSignedIn: () => true,
        liveTrackingApi: fakeApi,
        pushTokenClient: fakePushClient,
        platformResolver: () => 'android',
      );

      bootstrap.start();
      await settle();
      bootstrap.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await settle();

      expect(fakeApi.registerCalls, hasLength(2));

      bootstrap.dispose();
      await fakePushClient.dispose();
      await authStateController.close();
    });

    test('deactivates last token on logout transition', () async {
      final authStateController = StreamController<Object?>.broadcast();
      final fakeApi = _FakeLiveTrackingApi();
      final fakePushClient = _FakePushTokenClient(token: 'push-token-1');
      final bootstrap = PushTokenLifecycleBootstrap(
        authStateChanges: authStateController.stream,
        isSignedIn: () => true,
        liveTrackingApi: fakeApi,
        pushTokenClient: fakePushClient,
        platformResolver: () => 'android',
      );

      bootstrap.start();
      await settle();
      authStateController.add(null);
      await settle();

      expect(fakeApi.registerCalls, hasLength(1));
      expect(fakeApi.deactivateCalls, hasLength(1));
      expect(fakeApi.deactivateCalls.single.pushToken, 'push-token-1');

      bootstrap.dispose();
      await fakePushClient.dispose();
      await authStateController.close();
    });

    test('registers refreshed token when signed in', () async {
      final authStateController = StreamController<Object?>.broadcast();
      final fakeApi = _FakeLiveTrackingApi();
      final fakePushClient = _FakePushTokenClient(token: 'push-token-1');
      final bootstrap = PushTokenLifecycleBootstrap(
        authStateChanges: authStateController.stream,
        isSignedIn: () => true,
        liveTrackingApi: fakeApi,
        pushTokenClient: fakePushClient,
        platformResolver: () => 'android',
      );

      bootstrap.start();
      await settle();
      fakePushClient.emitTokenRefresh('push-token-2');
      await settle();

      expect(fakeApi.registerCalls, hasLength(2));
      expect(fakeApi.registerCalls.last.pushToken, 'push-token-2');

      bootstrap.dispose();
      await fakePushClient.dispose();
      await authStateController.close();
    });

    test('auth generation guard avoids stale deactivate on rapid logout/login',
        () async {
      final authStateController = StreamController<Object?>.broadcast();
      final fakeApi = _FakeLiveTrackingApi();
      final fakePushClient = _FakePushTokenClient(token: 'push-token-1');
      var signedIn = true;
      final bootstrap = PushTokenLifecycleBootstrap(
        authStateChanges: authStateController.stream,
        isSignedIn: () => signedIn,
        liveTrackingApi: fakeApi,
        pushTokenClient: fakePushClient,
        platformResolver: () => 'android',
      );

      fakeApi.registerGate = Completer<void>();
      bootstrap.start();
      await settle();

      signedIn = false;
      authStateController.add(null);
      signedIn = true;
      authStateController.add(Object());

      fakeApi.registerGate?.complete();
      await settle();
      await settle();

      expect(fakeApi.registerCalls.length, greaterThanOrEqualTo(2));
      expect(fakeApi.deactivateCalls, isEmpty);

      bootstrap.dispose();
      await fakePushClient.dispose();
      await authStateController.close();
    });
  });
}
