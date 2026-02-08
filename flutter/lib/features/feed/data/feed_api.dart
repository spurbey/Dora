import 'package:built_collection/built_collection.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';
import 'package:dora_api/dora_api.dart';

class FeedApi {
  FeedApi({
    required TripsApi tripsApi,
    required PlacesApi placesApi,
    required RoutesApi routesApi,
    required SearchApi searchApi,
    required AuthService authService,
  })  : _tripsApi = tripsApi,
        _placesApi = placesApi,
        _routesApi = routesApi,
        _searchApi = searchApi,
        _authService = authService;

  final TripsApi _tripsApi;
  final PlacesApi _placesApi;
  final RoutesApi _routesApi;
  final SearchApi _searchApi;
  final AuthService _authService;

  Future<String> _authorizationHeader() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw FeedApiException('Missing auth token');
    }
    return 'Bearer $token';
  }

  Future<TripResponse> getTripById(String id) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _tripsApi.getTripApiV1TripsTripIdGet(
        tripId: id,
        authorization: auth,
      );
      final trip = response.data;
      if (trip == null) {
        throw FeedApiException('Trip not found');
      }
      return trip;
    } catch (e) {
      throw FeedApiException('Failed to fetch trip: $e');
    }
  }

  Future<List<TripPlace>> getTripPlaces(String tripId) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _placesApi.listPlacesApiV1PlacesGet(
        tripId: tripId,
        authorization: auth,
      );
      final places = response.data?.places ?? BuiltList();
      return places.map(_mapPlace).toList();
    } catch (e) {
      throw FeedApiException('Failed to fetch places: $e');
    }
  }

  Future<List<TripRoute>> getTripRoutes(String tripId) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _routesApi.listTripRoutesApiV1TripsTripIdRoutesGet(
        tripId: tripId,
        authorization: auth,
      );
      final routes = response.data?.routes ?? BuiltList();
      return routes.map(_mapRoute).toList();
    } catch (e) {
      throw FeedApiException('Failed to fetch routes: $e');
    }
  }

  Future<List<PlaceSearchResult>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 10,
  }) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _searchApi.searchPlacesApiV1SearchPlacesGet(
        query: query,
        lat: latitude,
        lng: longitude,
        authorization: auth,
        radiusKm: radiusKm,
        limit: limit,
      );
      final results = response.data?.results ?? BuiltList();
      return results.map(_mapSearchResult).toList();
    } catch (e) {
      throw FeedApiException('Failed to search places: $e');
    }
  }

  Future<List<PlaceSearchResult>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _placesApi.getNearbyPlacesApiV1PlacesNearbyGet(
        lat: latitude,
        lng: longitude,
        authorization: auth,
        radius: radiusKm,
      );
      final places = response.data?.places ?? BuiltList();
      return places.map(_mapNearbyPlace).toList();
    } catch (e) {
      throw FeedApiException('Failed to get nearby places: $e');
    }
  }

  TripPlace _mapPlace(PlaceResponse place) {
    final photos = place.photos ?? BuiltList();
    return TripPlace(
      id: place.id,
      name: place.name,
      latitude: place.lat.toDouble(),
      longitude: place.lng.toDouble(),
      notes: place.userNotes,
      orderIndex: place.orderInTrip,
      photoUrls: photos.map((photo) => photo.fileUrl).toList(),
    );
  }

  TripRoute _mapRoute(RouteResponse route) {
    return TripRoute(
      id: route.id,
      transportMode: route.transportMode.name,
      distance: route.distanceKm?.toDouble(),
      duration: route.durationMins,
      polyline: route.polylineEncoded,
      dayNumber: null,
    );
  }

  PlaceSearchResult _mapSearchResult(SearchResult result) {
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

  PlaceSearchResult _mapNearbyPlace(PlaceResponse place) {
    return PlaceSearchResult(
      id: place.id,
      name: place.name,
      category: place.placeType ?? 'Place',
      address: null,
      latitude: place.lat.toDouble(),
      longitude: place.lng.toDouble(),
      rating: place.userRating?.toDouble(),
      reviewCount: null,
      priceLevel: null,
      photoUrl: null,
    );
  }
}

class FeedApiException implements Exception {
  FeedApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
