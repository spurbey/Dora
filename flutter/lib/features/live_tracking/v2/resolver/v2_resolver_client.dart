import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:dora/core/config/env_config.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

class V2ResolverProviderException implements Exception {
  const V2ResolverProviderException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'V2ResolverProviderException($code): $message';
}

class V2ResolverClient {
  V2ResolverClient({
    http.Client? httpClient,
    Duration timeout = const Duration(milliseconds: 1500),
    String baseUrl = 'https://api.openrouteservice.org/geocode/reverse',
    String? apiKeyOverride,
  })  : _httpClient = httpClient ?? http.Client(),
        _timeout = timeout,
        _baseUrl = baseUrl,
        _apiKeyOverride = apiKeyOverride;

  final http.Client _httpClient;
  final Duration _timeout;
  final String _baseUrl;
  final String? _apiKeyOverride;

  Future<List<V2ResolverCandidate>> fetchReverseCandidates({
    required AppLatLng location,
    int size = 5,
  }) async {
    final apiKey = (_apiKeyOverride ?? Env.effectiveOrsApiKey).trim();
    if (apiKey.isEmpty) {
      throw const V2ResolverProviderException(
        code: 'ors_api_key_missing',
        message: 'ORS key not configured.',
      );
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: <String, String>{
        'api_key': apiKey,
        'point.lat': '${location.latitude}',
        'point.lon': '${location.longitude}',
        'size': '${size.clamp(1, 10)}',
        'layers': 'venue,address,street',
      },
    );

    http.Response response;
    try {
      response = await _httpClient.get(uri).timeout(_timeout);
    } on http.ClientException catch (error) {
      throw V2ResolverProviderException(
        code: 'ors_client_error',
        message: error.message,
      );
    } on Exception {
      throw const V2ResolverProviderException(
        code: 'ors_timeout',
        message: 'ORS resolver request timed out.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw V2ResolverProviderException(
        code: 'ors_http_${response.statusCode}',
        message: 'ORS resolver returned ${response.statusCode}.',
      );
    }

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('response is not object');
      }
      payload = decoded;
    } on Exception {
      throw const V2ResolverProviderException(
        code: 'ors_parse_error',
        message: 'Failed to parse ORS response.',
      );
    }

    final features = payload['features'];
    if (features is! List) {
      return const <V2ResolverCandidate>[];
    }

    final candidates = <V2ResolverCandidate>[];
    for (final feature in features) {
      final parsed = _parseFeature(
        feature: feature,
        origin: location,
      );
      if (parsed != null) {
        candidates.add(parsed);
      }
    }
    candidates.sort((a, b) {
      final score = b.confidenceScore.compareTo(a.confidenceScore);
      if (score != 0) {
        return score;
      }
      return a.distanceM.compareTo(b.distanceM);
    });
    return candidates;
  }

  V2ResolverCandidate? _parseFeature({
    required Object? feature,
    required AppLatLng origin,
  }) {
    if (feature is! Map<String, dynamic>) {
      return null;
    }
    final geometry = feature['geometry'];
    final properties = feature['properties'];
    if (geometry is! Map<String, dynamic> ||
        properties is! Map<String, dynamic>) {
      return null;
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) {
      return null;
    }
    final lon = _asDouble(coordinates[0]);
    final lat = _asDouble(coordinates[1]);
    if (lat == null || lon == null) {
      return null;
    }
    final candidateLocation = AppLatLng(latitude: lat, longitude: lon);
    final name = _asNonEmptyString(properties['name']) ??
        _asNonEmptyString(properties['label']);
    if (name == null) {
      return null;
    }
    final confidence = _asDouble(properties['confidence']) ?? 0.0;
    final distance = _asDouble(properties['distance']) ??
        _distanceMeters(origin: origin, destination: candidateLocation);
    return V2ResolverCandidate(
      providerPlaceId: _asNonEmptyString(properties['gid']),
      name: name,
      label: _asNonEmptyString(properties['label']),
      coordinates: candidateLocation,
      confidenceScore: confidence,
      distanceM: distance,
      rawJson: feature,
    );
  }

  String? _asNonEmptyString(Object? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  double _distanceMeters({
    required AppLatLng origin,
    required AppLatLng destination,
  }) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(destination.latitude - origin.latitude);
    final dLon = _toRadians(destination.longitude - origin.longitude);
    final lat1 = _toRadians(origin.latitude);
    final lat2 = _toRadians(destination.latitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double value) => value * (math.pi / 180.0);
}
