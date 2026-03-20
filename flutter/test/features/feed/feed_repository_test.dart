import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/feed/data/feed_api.dart';
import 'package:dora/features/feed/data/feed_repository.dart';
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

class _FakeFeedApi extends FeedApi {
  _FakeFeedApi({
    required this.trips,
  }) : super(
          tripsApi: openapi.TripsApi(Dio(), openapi.standardSerializers),
          placesApi: openapi.PlacesApi(Dio(), openapi.standardSerializers),
          routesApi: openapi.RoutesApi(Dio(), openapi.standardSerializers),
          searchApi: openapi.SearchApi(Dio(), openapi.standardSerializers),
          authService: const _FakeAuthService(),
        );

  final List<openapi.TripResponse> trips;

  @override
  Future<List<openapi.TripResponse>> getTrips({
    int page = 1,
    int limit = 10,
    String? visibility,
    bool publicOnly = true,
  }) async {
    return trips;
  }
}

void main() {
  group('FeedRepository mapping', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('uses backend placeCount when mapping public trips', () async {
      final now = DateTime.utc(2026, 3, 20, 12, 0, 0);
      final api = _FakeFeedApi(
        trips: <openapi.TripResponse>[
          openapi.TripResponse((trip) {
            trip
              ..id = 'trip-1'
              ..userId = 'user-1'
              ..title = 'Mapped Trip'
              ..visibility = 'public'
              ..viewsCount = 20
              ..savesCount = 3
              ..placeCount = 9
              ..createdAt = now
              ..updatedAt = now;
          }),
        ],
      );
      final repository = FeedRepository(database, api);

      final trips = await repository.getPublicTrips(
        page: 1,
        limit: 10,
        forceRefresh: true,
      );

      expect(trips, hasLength(1));
      expect(trips.single.placeCount, 9);
    });
  });
}
