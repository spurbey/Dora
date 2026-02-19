import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:dora/core/config/env_config.dart';
import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';

/// Mapbox Geocoding API implementation.
/// This is the ONLY file that directly calls Mapbox geocoding endpoints.
class MapboxGeocodingAdapter implements AppGeocodingService {
  static const _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  @override
  Future<List<GeocodingResult>> searchCities(
    String query, {
    AppLatLng? proximity,
  }) async {
    if (query.trim().length < 2) return [];

    final token = Env.mapboxToken;
    if (token.isEmpty) return [];

    final params = <String, String>{
      'access_token': token,
      'types': 'place',
      'limit': '8',
      'language': 'en',
    };
    if (proximity != null) {
      params['proximity'] = '${proximity.longitude},${proximity.latitude}';
    }

    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(query)}.json')
        .replace(queryParameters: params);

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];

    return features.map((feature) {
      final props = feature as Map<String, dynamic>;
      final center = props['center'] as List;
      final context = props['context'] as List? ?? [];

      String? country;
      for (final ctx in context) {
        final ctxMap = ctx as Map<String, dynamic>;
        final id = ctxMap['id'] as String? ?? '';
        if (id.startsWith('country')) {
          country = ctxMap['text'] as String?;
          break;
        }
      }

      return GeocodingResult(
        name: props['text'] as String? ?? props['place_name'] as String? ?? '',
        country: country,
        coordinates: AppLatLng(
          latitude: (center[1] as num).toDouble(),
          longitude: (center[0] as num).toDouble(),
        ),
      );
    }).toList();
  }

  @override
  Future<GeocodingResult?> reverseGeocode(AppLatLng coordinates) async {
    final token = Env.mapboxToken;
    if (token.isEmpty) return null;

    final uri = Uri.parse(
      '$_baseUrl/${coordinates.longitude},${coordinates.latitude}.json',
    ).replace(queryParameters: {
      'access_token': token,
      'types': 'place',
      'limit': '1',
      'language': 'en',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];
    if (features.isEmpty) return null;

    final feature = features.first as Map<String, dynamic>;
    final center = feature['center'] as List;

    return GeocodingResult(
      name: feature['text'] as String? ?? '',
      coordinates: AppLatLng(
        latitude: (center[1] as num).toDouble(),
        longitude: (center[0] as num).toDouble(),
      ),
    );
  }
}
