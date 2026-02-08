import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/data/trips_api.dart';

class MockTripsApi implements TripsApi {
  // TODO: Replace with real API when backend endpoints are available.
  MockTripsApi({required String userId})
      : _userId = userId,
        _trips = _seedTrips(userId);

  final String _userId;
  final List<UserTrip> _trips;

  @override
  Future<List<UserTrip>> getUserTrips({int page = 1, int limit = 20}) async {
    final start = max(0, (page - 1) * limit);
    final end = min(_trips.length, start + limit);
    if (start >= _trips.length) {
      return [];
    }
    return _trips.sublist(start, end);
  }

  @override
  Future<void> deleteTrip(String id) async {
    _trips.removeWhere((trip) => trip.id == id);
  }

  @override
  Future<UserTrip> duplicateTrip(String id) async {
    final original = _trips.firstWhere(
      (trip) => trip.id == id,
      orElse: () => throw TripsApiException('Trip not found'),
    );

    final now = DateTime.now();
    final copy = original.copyWith(
      id: const Uuid().v4(),
      name: _copyName(original.name),
      status: 'editing',
      lastEditedAt: now,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
      createdAt: now,
    );

    _trips.insert(0, copy);
    return copy;
  }

  @override
  Future<UserTrip> updateTripVisibility(String id, String visibility) async {
    final index = _trips.indexWhere((trip) => trip.id == id);
    if (index == -1) {
      throw TripsApiException('Trip not found');
    }

    final now = DateTime.now();
    final updated = _trips[index].copyWith(
      visibility: visibility,
      status: visibility == 'public' ? 'shared' : _trips[index].status,
      lastEditedAt: now,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );

    _trips[index] = updated;
    return updated;
  }

  static List<UserTrip> _seedTrips(String userId) {
    final now = DateTime.now();

    return [
      UserTrip(
        id: 'trip-japan-001',
        userId: userId,
        name: 'Japan Adventure',
        description: 'Tokyo to Kyoto highlights',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1549693578-d683be217e58',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 2)),
        visibility: 'private',
        placeCount: 5,
        status: 'editing',
        lastEditedAt: now.subtract(const Duration(hours: 2)),
        localUpdatedAt: now.subtract(const Duration(hours: 2)),
        serverUpdatedAt: now.subtract(const Duration(hours: 2)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserTrip(
        id: 'trip-iceland-002',
        userId: userId,
        name: 'Iceland Road Trip',
        description: 'Ring Road and waterfalls',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 112)),
        visibility: 'private',
        placeCount: 12,
        status: 'completed',
        lastEditedAt: now.subtract(const Duration(days: 14)),
        localUpdatedAt: now.subtract(const Duration(days: 14)),
        serverUpdatedAt: now.subtract(const Duration(days: 14)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 130)),
      ),
      UserTrip(
        id: 'trip-iberia-003',
        userId: userId,
        name: 'Spain & Portugal Grand Tour',
        description: 'Seville, Porto, Lisbon',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 80)),
        visibility: 'public',
        placeCount: 18,
        status: 'shared',
        lastEditedAt: now.subtract(const Duration(days: 30)),
        localUpdatedAt: now.subtract(const Duration(days: 30)),
        serverUpdatedAt: now.subtract(const Duration(days: 30)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 95)),
      ),
      UserTrip(
        id: 'trip-nyc-004',
        userId: userId,
        name: 'Weekend in NYC',
        description: 'Food, museums, Broadway',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
        startDate: now.subtract(const Duration(days: 45)),
        endDate: now.subtract(const Duration(days: 43)),
        visibility: 'private',
        placeCount: 7,
        status: 'completed',
        lastEditedAt: now.subtract(const Duration(days: 20)),
        localUpdatedAt: now.subtract(const Duration(days: 20)),
        serverUpdatedAt: now.subtract(const Duration(days: 20)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 50)),
      ),
      UserTrip(
        id: 'trip-paris-005',
        userId: userId,
        name: 'Paris Cafes & Museums',
        description: 'Slow mornings, art afternoons',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
        startDate: now.subtract(const Duration(days: 200)),
        endDate: now.subtract(const Duration(days: 195)),
        visibility: 'public',
        placeCount: 9,
        status: 'shared',
        lastEditedAt: now.subtract(const Duration(days: 60)),
        localUpdatedAt: now.subtract(const Duration(days: 60)),
        serverUpdatedAt: now.subtract(const Duration(days: 60)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 210)),
      ),
      UserTrip(
        id: 'trip-patagonia-006',
        userId: userId,
        name: 'Patagonia Hiking Expedition',
        description: 'Torres del Paine loops',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.subtract(const Duration(days: 8)),
        visibility: 'private',
        placeCount: 6,
        status: 'editing',
        lastEditedAt: now.subtract(const Duration(days: 1)),
        localUpdatedAt: now.subtract(const Duration(days: 1)),
        serverUpdatedAt: now.subtract(const Duration(days: 1)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 16)),
      ),
      UserTrip(
        id: 'trip-bali-007',
        userId: userId,
        name: 'Bali Retreat 2024',
        description: 'Beaches, temples, and sunrise hikes',
        coverPhotoUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        startDate: now.subtract(const Duration(days: 320)),
        endDate: now.subtract(const Duration(days: 312)),
        visibility: 'private',
        placeCount: 11,
        status: 'completed',
        lastEditedAt: now.subtract(const Duration(days: 200)),
        localUpdatedAt: now.subtract(const Duration(days: 200)),
        serverUpdatedAt: now.subtract(const Duration(days: 200)),
        syncStatus: 'synced',
        createdAt: now.subtract(const Duration(days: 330)),
      ),
    ];
  }

  static String _copyName(String name) {
    const suffix = ' (Copy)';
    const maxLength = 28;
    final trimmed = name.length > maxLength
        ? name.substring(0, maxLength).trimRight()
        : name;
    return '$trimmed$suffix';
  }
}
