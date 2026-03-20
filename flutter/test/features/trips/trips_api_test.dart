import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/features/trips/data/trips_api.dart';
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

class _FakeOpenApiTripsApi extends openapi.TripsApi {
  _FakeOpenApiTripsApi({
    required this.trips,
  }) : super(
          Dio(),
          openapi.standardSerializers,
        );

  final List<openapi.TripResponse> trips;

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
    final data = openapi.TripListResponse((builder) {
      builder
        ..trips.addAll(trips)
        ..total = trips.length
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

void main() {
  group('OpenApiTripsApi mapping', () {
    test('maps backend placeCount into UserTrip', () async {
      final now = DateTime.utc(2026, 3, 20, 12, 0, 0);
      final openApiTripsApi = _FakeOpenApiTripsApi(
        trips: <openapi.TripResponse>[
          openapi.TripResponse((trip) {
            trip
              ..id = 'trip-1'
              ..userId = 'user-1'
              ..title = 'Trip One'
              ..visibility = 'private'
              ..viewsCount = 4
              ..savesCount = 1
              ..placeCount = 6
              ..createdAt = now
              ..updatedAt = now;
          }),
        ],
      );
      final api = OpenApiTripsApi(
        tripsApi: openApiTripsApi,
        authService: const _FakeAuthService(),
      );

      final trips = await api.getUserTrips(page: 1, limit: 10);

      expect(trips, hasLength(1));
      expect(trips.single.placeCount, 6);
      expect(trips.single.status, 'completed');
    });
  });
}
