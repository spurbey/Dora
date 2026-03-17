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

  Future<List<TripResponse>> getTrips({
    int page = 1,
    int limit = 10,
    String? visibility,
    bool publicOnly = true,
  }) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _tripsApi.listTripsApiV1TripsGet(
        authorization: auth,
        page: page,
        pageSize: limit,
        visibility: visibility,
        publicOnly: publicOnly,
      );
      final trips = response.data?.trips;
      if (trips == null || trips.isEmpty) {
        return const <TripResponse>[];
      }
      return trips.toList();
    } catch (e) {
      throw FeedApiException('Failed to fetch trips: $e');
    }
  }

  Future<List<TripPlace>> getTripPlaces(String tripId) async {
    try {
      final auth = await _authorizationHeader();
      final response = await _placesApi.listPlacesApiV1PlacesGet(
        tripId: tripId,
        authorization: auth,
      );
      final places = response.data?.places;
      if (places == null || places.isEmpty) {
        return const <TripPlace>[];
      }
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
      final routes = response.data?.routes;
      if (routes == null || routes.isEmpty) {
        return const <TripRoute>[];
      }
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
      final results = response.data?.results;
      if (results == null || results.isEmpty) {
        return const <PlaceSearchResult>[];
      }
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
      final places = response.data?.places;
      if (places == null || places.isEmpty) {
        return const <PlaceSearchResult>[];
      }
      return places.map(_mapNearbyPlace).toList();
    } catch (e) {
      throw FeedApiException('Failed to get nearby places: $e');
    }
  }

  TripPlace _mapPlace(PlaceResponse place) {
    final photos = place.photos;
    return TripPlace(
      id: place.id,
      name: place.name,
      latitude: place.lat.toDouble(),
      longitude: place.lng.toDouble(),
      notes: place.userNotes,
      orderIndex: place.orderInTrip,
      photoUrls:
          photos == null ? const <String>[] : photos.map((photo) => photo.fileUrl).toList(),
    );
  }

  TripRoute _mapRoute(RouteResponse route) {
    final coordinates = _extractRouteCoordinates(route);
    return TripRoute(
      id: route.id,
      coordinates: coordinates,
      transportMode: route.transportMode.name,
      distance: route.distanceKm?.toDouble(),
      duration: route.durationMins,
      polyline: route.polylineEncoded,
      dayNumber: route.orderInTrip,
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

  List<TripLatLng> _extractRouteCoordinates(RouteResponse route) {
    final raw = route.routeGeojson.value;
    final map = raw is Map ? raw : null;
    final type = map?['type'];
    final coordinates = map?['coordinates'];

    if (type == 'LineString' && coordinates is List) {
      final parsed = <TripLatLng>[];
      for (final point in coordinates) {
        if (point is! List || point.length < 2) {
          continue;
        }
        final lng = _toDouble(point[0]);
        final lat = _toDouble(point[1]);
        if (lat == null || lng == null) {
          continue;
        }
        parsed.add(TripLatLng(latitude: lat, longitude: lng));
      }
      if (parsed.length >= 2) {
        return parsed;
      }
    }

    final polyline = route.polylineEncoded;
    if (polyline != null && polyline.isNotEmpty) {
      final decoded = _decodePolyline(polyline);
      if (decoded.length >= 2) {
        return decoded;
      }
    }

    return const <TripLatLng>[];
  }

  List<TripLatLng> _decodePolyline(String encoded) {
    final points = <TripLatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      final latResult = _decodePolylineChunk(encoded, index);
      lat += latResult.value;
      index = latResult.nextIndex;

      if (index >= encoded.length) {
        break;
      }

      final lngResult = _decodePolylineChunk(encoded, index);
      lng += lngResult.value;
      index = lngResult.nextIndex;

      points.add(
        TripLatLng(
          latitude: lat / 1e5,
          longitude: lng / 1e5,
        ),
      );
    }

    return points;
  }

  _PolylineChunk _decodePolylineChunk(String encoded, int startIndex) {
    var result = 0;
    var shift = 0;
    var index = startIndex;

    while (index < encoded.length) {
      final codeUnit = encoded.codeUnitAt(index) - 63;
      index += 1;
      result |= (codeUnit & 0x1f) << shift;
      shift += 5;
      if (codeUnit < 0x20) {
        break;
      }
    }

    final value = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    return _PolylineChunk(value: value, nextIndex: index);
  }

  double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class _PolylineChunk {
  const _PolylineChunk({
    required this.value,
    required this.nextIndex,
  });

  final int value;
  final int nextIndex;
}

class FeedApiException implements Exception {
  FeedApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
