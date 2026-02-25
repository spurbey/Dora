import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/trip_repository.dart';

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => 'test-token';

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
}

void main() {
  group('TripRepository.setEditorViewport', () {
    late AppDatabase database;
    late TripRepository repository;
    late SyncTaskDao syncTaskDao;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = TripRepository(
        database,
        const _FakeAuthService(),
      );
      syncTaskDao = SyncTaskDao(database);

      final now = DateTime.utc(2026, 2, 25);
      await database.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-vp-1',
          serverTripId: const drift.Value('remote-trip-1'),
          userId: 'user-1',
          name: 'Viewport Trip',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          centerPoint: const drift.Value(
            AppLatLng(latitude: 12.9716, longitude: 77.5946),
          ),
          zoom: const drift.Value(10.0),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('persists viewport locally without enqueueing sync tasks', () async {
      final beforeTasks = await syncTaskDao.getActiveTasks(limit: 20);
      expect(beforeTasks, isEmpty);

      await repository.setEditorViewport(
        tripId: 'trip-vp-1',
        centerPoint: const AppLatLng(latitude: 28.6139, longitude: 77.2090),
        zoom: 13.5,
      );

      final trip = await repository.getTrip('trip-vp-1');
      expect(trip, isNotNull);
      expect(trip!.centerPoint, const AppLatLng(latitude: 28.6139, longitude: 77.2090));
      expect(trip.zoom, 13.5);

      final afterTasks = await syncTaskDao.getActiveTasks(limit: 20);
      expect(afterTasks, isEmpty);
    });
  });
}
