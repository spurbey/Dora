import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/features/feed/data/feed_api.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> refreshAccessToken({bool force = false}) async =>
      'test-token';

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }
}

class _PublicOnlyCompatTripsApi extends openapi.TripsApi {
  _PublicOnlyCompatTripsApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  final List<bool?> capturedPublicOnly = <bool?>[];
  int calls = 0;

  @override
  Future<Response<openapi.TripListResponse>> listTripsApiV1TripsGet({
    required String authorization,
    int? page = 1,
    int? pageSize = 20,
    String? visibility,
    bool? publicOnly = false,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls += 1;
    capturedPublicOnly.add(publicOnly);

    if (calls == 1 && publicOnly == true) {
      final request = RequestOptions(path: '/api/v1/trips');
      final response = Response<dynamic>(
        requestOptions: request,
        statusCode: 422,
        statusMessage: 'Unprocessable Entity',
        data: <String, dynamic>{
          'detail': 'Unexpected query parameter: public_only',
        },
      );
      throw DioException(
        requestOptions: request,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'public_only unsupported',
      );
    }

    final now = DateTime.utc(2026, 3, 20, 12, 0, 0);
    final data = openapi.TripListResponse((builder) {
      builder
        ..trips.add(
          openapi.TripResponse((trip) {
            trip
              ..id = 'trip-public-1'
              ..userId = 'user-1'
              ..title = 'Public Trip'
              ..visibility = 'public'
              ..viewsCount = 10
              ..savesCount = 2
              ..createdAt = now
              ..updatedAt = now;
          }),
        )
        ..total = 1
        ..page = page ?? 1
        ..pageSize = pageSize ?? 20
        ..totalPages = 1;
    });

    return Response<openapi.TripListResponse>(
      data: data,
      requestOptions: RequestOptions(path: '/api/v1/trips'),
      statusCode: 200,
    );
  }
}

class _ServerErrorTripsApi extends openapi.TripsApi {
  _ServerErrorTripsApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  int calls = 0;

  @override
  Future<Response<openapi.TripListResponse>> listTripsApiV1TripsGet({
    required String authorization,
    int? page = 1,
    int? pageSize = 20,
    String? visibility,
    bool? publicOnly = false,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls += 1;
    final request = RequestOptions(path: '/api/v1/trips');
    final response = Response<dynamic>(
      requestOptions: request,
      statusCode: 500,
      statusMessage: 'Server Error',
      data: <String, dynamic>{'detail': 'Internal server error'},
    );
    throw DioException(
      requestOptions: request,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'server error',
    );
  }
}

void main() {
  group('FeedApi getTrips compatibility', () {
    test('retries without public_only when backend does not support it',
        () async {
      final tripsApi = _PublicOnlyCompatTripsApi();
      final api = FeedApi(
        tripsApi: tripsApi,
        placesApi: openapi.PlacesApi(Dio(), openapi.standardSerializers),
        routesApi: openapi.RoutesApi(Dio(), openapi.standardSerializers),
        searchApi: openapi.SearchApi(Dio(), openapi.standardSerializers),
        authService: const _FakeAuthService(),
      );

      final trips = await api.getTrips(page: 1, limit: 10, publicOnly: true);

      expect(trips, hasLength(1));
      expect(trips.single.id, 'trip-public-1');
      expect(tripsApi.capturedPublicOnly, <bool?>[true, null]);
    });

    test('does not fallback on non-compatibility server failures', () async {
      final tripsApi = _ServerErrorTripsApi();
      final api = FeedApi(
        tripsApi: tripsApi,
        placesApi: openapi.PlacesApi(Dio(), openapi.standardSerializers),
        routesApi: openapi.RoutesApi(Dio(), openapi.standardSerializers),
        searchApi: openapi.SearchApi(Dio(), openapi.standardSerializers),
        authService: const _FakeAuthService(),
      );

      await expectLater(
        api.getTrips(page: 1, limit: 10, publicOnly: true),
        throwsA(isA<FeedApiException>()),
      );
      expect(tripsApi.calls, 1);
    });
  });
}
