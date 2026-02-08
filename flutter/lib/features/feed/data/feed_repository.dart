import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/feed/data/feed_api.dart';
import 'package:dora/features/feed/data/mock_feed_data.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';
import 'package:dora_api/dora_api.dart';

class FeedRepository {
  FeedRepository(this._db, this._api);

  final AppDatabase _db;
  final FeedApi _api;

  Future<List<PublicTrip>> getPublicTrips({
    int page = 1,
    int limit = 10,
    TripFilter? filter,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _db.publicTripsDao.getTrips(
        page: page,
        limit: limit,
        filter: filter,
      );
      if (cached.isNotEmpty && page == 1) {
        _refreshInBackground(limit: limit, filter: filter);
        return cached;
      }
    }

    try {
      final trips = MockFeedData.getPublicTrips(page: page, limit: limit);
      if (page == 1) {
        await _db.publicTripsDao.clearAll();
      }
      await _db.publicTripsDao.insertTrips(trips);
      return trips;
    } catch (e) {
      final cached = await _db.publicTripsDao.getTrips(
        page: page,
        limit: limit,
        filter: filter,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      throw FeedRepositoryException('Failed to load trips: $e');
    }
  }

  Future<PublicTrip?> getTripById(String id) async {
    final local = await _db.publicTripsDao.getTripById(id);
    if (local != null) {
      _refreshTripInBackground(id);
      return local;
    }

    if (MockFeedData.isMockId(id)) {
      try {
        return MockFeedData.getPublicTrips(page: 1, limit: 50)
            .firstWhere((trip) => trip.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final trip = await _api.getTripById(id);
      final mapped = _mapTripResponse(trip);
      await _db.publicTripsDao.insertTrip(mapped);
      return mapped;
    } catch (_) {
      return null;
    }
  }

  Future<TripDetailData> getTripDetail(String id) async {
    final mock = MockFeedData.getTripDetail(id);
    if (mock != null) {
      return mock;
    }

    try {
      final tripResponse = await _api.getTripById(id);
      final places = await _api.getTripPlaces(id);
      final routes = await _api.getTripRoutes(id);

      final trip = _mapTripResponse(
        tripResponse,
        placeCount: places.length,
      );

      return TripDetailData(
        trip: trip,
        places: places,
        routes: routes,
      );
    } catch (e) {
      throw FeedRepositoryException('Failed to load trip: $e');
    }
  }

  Future<List<PlaceSearchResult>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
  }) {
    return _api.searchPlaces(
      query: query,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<PlaceSearchResult>> getNearbyPlaces({
    required double latitude,
    required double longitude,
  }) {
    return _api.getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<PublicTrip>> searchTrips(String query) async {
    return MockFeedData.searchTrips(query);
  }

  Future<void> copyTrip(String tripId) async {
    // TODO: Replace with API when backend endpoints are available.
  }

  Future<void> savePlace(String placeId, String userTripId) async {
    // TODO: Replace with API when backend endpoints are available.
  }

  Future<void> copyRoute(String routeId, String userTripId) async {
    // TODO: Replace with API when backend endpoints are available.
  }

  void _refreshInBackground({
    int limit = 10,
    TripFilter? filter,
  }) {
    Future(() async {
      final trips = MockFeedData.getPublicTrips(page: 1, limit: limit);
      await _db.publicTripsDao.clearAll();
      await _db.publicTripsDao.insertTrips(trips);
    }).catchError((_) {});
  }

  void _refreshTripInBackground(String id) {
    if (MockFeedData.isMockId(id)) {
      return;
    }

    Future(() async {
      final trip = await _api.getTripById(id);
      final mapped = _mapTripResponse(trip);
      await _db.publicTripsDao.insertTrip(mapped);
    }).catchError((_) {});
  }

  PublicTrip _mapTripResponse(TripResponse trip, {int? placeCount}) {
    final duration = _calculateDuration(trip.startDate, trip.endDate);
    return PublicTrip(
      id: trip.id,
      name: trip.title,
      description: trip.description,
      coverPhotoUrl: trip.coverPhotoUrl,
      userId: trip.userId,
      username: 'User-${trip.userId.substring(0, 4)}',
      placeCount: placeCount ?? 0,
      duration: duration,
      tags: const [],
      visibility: trip.visibility,
      viewCount: trip.viewsCount,
      createdAt: trip.createdAt,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: trip.updatedAt,
      syncStatus: 'synced',
    );
  }

  int? _calculateDuration(Date? start, Date? end) {
    if (start == null || end == null) {
      return null;
    }

    final startDate = start.toDateTime();
    final endDate = end.toDateTime();
    final diff = endDate.difference(startDate).inDays;
    return diff >= 0 ? diff + 1 : null;
  }
}

class FeedRepositoryException implements Exception {
  FeedRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
