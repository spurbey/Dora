import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class PlaceRepository {
  PlaceRepository(
    this._db, {
    openapi.SearchApi? searchApi,
    AuthService? authService,
  })  : _searchApi = searchApi,
        _authService = authService;

  final AppDatabase _db;
  final openapi.SearchApi? _searchApi;
  final AuthService? _authService;

  Future<List<Place>> getPlaces(String tripId) async {
    final rows = await _db.placeDao.getPlacesForTrip(tripId);
    return rows.map(_mapRow).toList();
  }

  Future<Place?> getPlace(String id) async {
    final row = await _db.placeDao.getPlaceById(id);
    return row == null ? null : _mapRow(row);
  }

  Future<Place> addPlace(Place place) async {
    final now = DateTime.now();
    final updated = place.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.insertPlace(_toCompanion(updated));
    await _updatePlaceCount(updated.tripId);
    return updated;
  }

  Future<void> updatePlace(Place place) async {
    final now = DateTime.now();
    final updated = place.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.updatePlace(_toCompanion(updated));
    await _updatePlaceCount(updated.tripId);
  }

  Future<void> deletePlace(String id) async {
    final existing = await _db.placeDao.getPlaceById(id);
    if (existing == null) {
      return;
    }
    await _db.placeDao.deletePlace(id);
    await _updatePlaceCount(existing.tripId);
  }

  Future<void> savePlaces(List<Place> places) async {
    if (places.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final companions = places
        .map((place) => _toCompanion(
              place.copyWith(
                localUpdatedAt: now,
                syncStatus: 'pending',
              ),
            ))
        .toList();
    await _db.placeDao.insertPlaces(companions);
    await _updatePlaceCount(places.first.tripId);
  }

  Place createFromSearchResult({
    required String tripId,
    required PlaceSearchResult result,
    required int orderIndex,
  }) {
    final now = DateTime.now();
    return Place(
      id: const Uuid().v4(),
      tripId: tripId,
      name: result.name,
      address: result.address,
      coordinates: AppLatLng(
        latitude: result.latitude ?? 0,
        longitude: result.longitude ?? 0,
      ),
      orderIndex: orderIndex,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  Future<List<PlaceSearchResult>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 10,
  }) async {
    final api = _searchApi;
    final authService = _authService;
    if (api == null || authService == null) {
      return [];
    }
    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }
    final response = await api.searchPlacesApiV1SearchPlacesGet(
      query: query,
      lat: latitude,
      lng: longitude,
      authorization: 'Bearer $token',
      radiusKm: radiusKm,
      limit: limit,
    );
    final results = response.data?.results ?? BuiltList();
    return results.map(_mapSearchResult).toList();
  }

  PlaceSearchResult _mapSearchResult(openapi.SearchResult result) {
    return PlaceSearchResult(
      id: result.id ?? '',
      name: result.name,
      category: result.source_,
      address: result.address,
      latitude: result.lat.toDouble(),
      longitude: result.lng.toDouble(),
      rating: result.rating?.toDouble(),
      reviewCount: result.popularity,
      priceLevel: null,
      photoUrl: null,
    );
  }

  Place _mapRow(PlaceRow row) {
    return Place(
      id: row.id,
      tripId: row.tripId,
      name: row.name,
      address: row.address,
      coordinates: row.coordinates,
      notes: row.notes,
      visitTime: row.visitTime,
      dayNumber: row.dayNumber,
      orderIndex: row.orderIndex,
      photoUrls: row.photoUrls,
      placeType: row.placeType,
      rating: row.rating,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  PlacesCompanion _toCompanion(Place place) {
    return PlacesCompanion(
      id: Value(place.id),
      tripId: Value(place.tripId),
      name: Value(place.name),
      address: Value(place.address),
      coordinates: Value(place.coordinates),
      notes: Value(place.notes),
      visitTime: Value(place.visitTime),
      dayNumber: Value(place.dayNumber),
      orderIndex: Value(place.orderIndex),
      photoUrls: Value(place.photoUrls),
      placeType: Value(place.placeType),
      rating: Value(place.rating),
      localUpdatedAt: Value(place.localUpdatedAt),
      serverUpdatedAt: Value(place.serverUpdatedAt),
      syncStatus: Value(place.syncStatus),
    );
  }

  Future<void> _updatePlaceCount(String tripId) async {
    final places = await _db.placeDao.getPlacesForTrip(tripId);
    final userTrip = await _db.userTripsDao.getTripById(tripId);
    if (userTrip == null) {
      return;
    }
    final now = DateTime.now();
    await _db.userTripsDao.updateTrip(userTrip.copyWith(
      placeCount: places.length,
      lastEditedAt: now,
      localUpdatedAt: now,
      syncStatus: 'pending',
    ));
  }
}
