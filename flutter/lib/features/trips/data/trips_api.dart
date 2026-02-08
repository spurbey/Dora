import 'package:built_collection/built_collection.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora_api/dora_api.dart' as openapi;

abstract class TripsApi {
  Future<List<UserTrip>> getUserTrips({int page = 1, int limit = 20});
  Future<void> deleteTrip(String id);
  Future<UserTrip> duplicateTrip(String id);
  Future<UserTrip> updateTripVisibility(String id, String visibility);
}

class OpenApiTripsApi implements TripsApi {
  OpenApiTripsApi({
    required openapi.TripsApi tripsApi,
    required AuthService authService,
  })  : _tripsApi = tripsApi,
        _authService = authService;

  final openapi.TripsApi _tripsApi;
  final AuthService _authService;

  Future<String> _authorizationHeader() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw TripsApiException('Missing auth token');
    }
    return 'Bearer $token';
  }

  @override
  Future<List<UserTrip>> getUserTrips({int page = 1, int limit = 20}) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _tripsApi.listTripsApiV1TripsGet(
        authorization: auth,
        page: page,
        pageSize: limit,
      );
      final trips = response.data?.trips ?? BuiltList<openapi.TripResponse>();
      return trips.map(_mapTrip).toList();
    } catch (e) {
      throw TripsApiException('Failed to fetch trips: $e');
    }
  }

  @override
  Future<void> deleteTrip(String id) async {
    try {
      final auth = await _authorizationHeader();
      await _tripsApi.deleteTripApiV1TripsTripIdDelete(
        tripId: id,
        authorization: auth,
      );
    } catch (e) {
      throw TripsApiException('Failed to delete trip: $e');
    }
  }

  @override
  Future<UserTrip> duplicateTrip(String id) async {
    throw TripsApiException('Duplicate trip is not supported yet.');
  }

  @override
  Future<UserTrip> updateTripVisibility(String id, String visibility) async {
    try {
      final auth = await _authorizationHeader();
      final payload = openapi.TripUpdate(
        (b) => b..visibility = visibility,
      );
      final response = await _tripsApi.updateTripApiV1TripsTripIdPatch(
        tripId: id,
        authorization: auth,
        tripUpdate: payload,
      );
      final trip = response.data;
      if (trip == null) {
        throw TripsApiException('Trip not found');
      }
      return _mapTrip(trip);
    } catch (e) {
      throw TripsApiException('Failed to update visibility: $e');
    }
  }

  UserTrip _mapTrip(openapi.TripResponse trip) {
    final now = DateTime.now();
    final status = trip.visibility == 'public' ? 'shared' : 'completed';
    return UserTrip(
      id: trip.id,
      userId: trip.userId,
      name: trip.title,
      description: trip.description,
      coverPhotoUrl: trip.coverPhotoUrl,
      startDate: trip.startDate?.toDateTime(),
      endDate: trip.endDate?.toDateTime(),
      visibility: trip.visibility,
      placeCount: 0,
      status: status,
      lastEditedAt: trip.updatedAt,
      localUpdatedAt: now,
      serverUpdatedAt: trip.updatedAt,
      syncStatus: 'synced',
      createdAt: trip.createdAt,
    );
  }
}

class TripsApiException implements Exception {
  TripsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
