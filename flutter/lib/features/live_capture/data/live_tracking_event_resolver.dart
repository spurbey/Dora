import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/place_dao.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/live_capture/domain/resolved_place_decision.dart';

class LiveTrackingEventResolver {
  LiveTrackingEventResolver({
    required TrackingEventDao trackingEventDao,
    required PlaceDao placeDao,
    required SyncTaskDao syncTaskDao,
    required AppGeocodingService geocodingService,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingEventDao = trackingEventDao,
        _placeDao = placeDao,
        _syncTaskDao = syncTaskDao,
        _geocodingService = geocodingService,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingEventDao _trackingEventDao;
  final PlaceDao _placeDao;
  final SyncTaskDao _syncTaskDao;
  final AppGeocodingService _geocodingService;
  final DateTime Function() _now;
  final Uuid _uuid;

  static const int resolverVersion = 1;
  static const double _resolvedThreshold = 0.75;
  static const double _reviewThreshold = 0.45;
  static const int _tripPlaceRadiusM = 50;
  static const int _anchorRadiusM = 80;
  static const int _reverseRadiusM = 100;
  static const int _poiRadiusM = 150;

  // Route-media association keeps geotag media near nearby route segments.
  static const double _manualResolvedConfidence = 1.0;

  Future<ResolvedPlaceDecision> resolveEventNow(String eventId) async {
    final row = await _trackingEventDao.getEventById(eventId);
    if (row == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    final localDecision = await _resolveLocally(row);
    await _persistDecision(eventId: row.id, decision: localDecision);

    if (!_shouldRunNetworkFallback(localDecision: localDecision, row: row)) {
      return localDecision;
    }

    final networkDecision = await _resolveWithNetworkFallback(row);
    final finalDecision = _preferDecision(
      localDecision: localDecision,
      networkDecision: networkDecision,
    );
    if (finalDecision != localDecision) {
      await _persistDecision(eventId: row.id, decision: finalDecision);
    }
    return finalDecision;
  }

  Future<int> reconcileUnresolved(
    String tripId, {
    int limit = 20,
  }) async {
    final unresolved = await _trackingEventDao.getUnresolvedEventsForTrip(
      tripId,
      limit: limit,
    );
    var resolvedCount = 0;
    for (final row in unresolved) {
      final decision = await resolveEventNow(row.id);
      if (decision.state == 'resolved') {
        resolvedCount++;
      }
    }
    return resolvedCount;
  }

  Future<ResolvedPlaceDecision> confirmPlaceForEvent({
    required String eventId,
    String? tripPlaceId,
    String? suggestedName,
    AppLatLng? suggestedCoordinate,
  }) async {
    final row = await _trackingEventDao.getEventById(eventId);
    if (row == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    final places = await _placeDao.getPlacesForTrip(row.tripId);
    String? resolvedPlaceId = _normalizeText(tripPlaceId);
    if (resolvedPlaceId != null &&
        !places.any((place) => place.id == resolvedPlaceId)) {
      resolvedPlaceId = null;
    }

    if (resolvedPlaceId == null &&
        suggestedCoordinate != null &&
        _normalizeText(suggestedName) != null) {
      resolvedPlaceId = await _ensureDraftPlace(
        tripId: row.tripId,
        candidate: _ResolverCandidate(
          placeId: null,
          name: _normalizeText(suggestedName)!,
          coordinate: suggestedCoordinate,
          score: _manualResolvedConfidence,
          reasonCode: 'manual_confirm_place',
        ),
        capturedAt: row.createdAt,
        existingPlaces: places,
      );
    }

    if (resolvedPlaceId == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    final decision = ResolvedPlaceDecision(
      state: 'resolved',
      confidence: _manualResolvedConfidence,
      reasonCode: 'manual_confirm_place',
      placeId: resolvedPlaceId,
      hintJson: row.resolutionHintJson,
    );
    await _persistDecision(eventId: row.id, decision: decision);
    return decision;
  }

  Future<ResolvedPlaceDecision> keepEventOnRoute(String eventId) async {
    final row = await _trackingEventDao.getEventById(eventId);
    if (row == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }
    final decision = ResolvedPlaceDecision(
      state: 'on_route_unresolved',
      confidence: row.bindConfidence ?? 0,
      reasonCode: 'manual_keep_on_route',
      placeId: null,
      hintJson: row.resolutionHintJson,
    );
    await _persistDecision(eventId: row.id, decision: decision);
    return decision;
  }

  Future<ResolvedPlaceDecision> _resolveLocally(TrackingEventRow row) async {
    final center = _eventCoordinate(row);
    if (center == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    final places = await _placeDao.getPlacesForTrip(row.tripId);
    final anchors = await _trackingEventDao.getRecentResolvedAnchors(row.tripId);
    final candidates = <_ResolverCandidate>[
      ..._tripPlaceCandidates(center: center, places: places),
      ..._anchorCandidates(center: center, anchors: anchors),
    ];

    if (candidates.isEmpty) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    final best = candidates.first;
    if (best.score >= _resolvedThreshold && best.placeId != null) {
      return ResolvedPlaceDecision(
        state: 'resolved',
        confidence: best.score,
        reasonCode: best.reasonCode,
        placeId: best.placeId,
        hintJson: _encodeHints(candidates),
      );
    }
    if (best.score >= _reviewThreshold) {
      return ResolvedPlaceDecision(
        state: 'review_required',
        confidence: best.score,
        reasonCode: 'ambiguous_candidates',
        hintJson: _encodeHints(candidates),
      );
    }
    return ResolvedPlaceDecision(
      state: 'on_route_unresolved',
      confidence: best.score,
      reasonCode: 'no_candidate',
      hintJson: _encodeHints(candidates),
    );
  }

  Future<ResolvedPlaceDecision> _resolveWithNetworkFallback(
    TrackingEventRow row,
  ) async {
    final center = _eventCoordinate(row);
    if (center == null) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    final places = await _placeDao.getPlacesForTrip(row.tripId);
    final anchors = await _trackingEventDao.getRecentResolvedAnchors(row.tripId);
    final temporal = _temporalConsistency(center: center, anchors: anchors);

    final reverse = await _safeReverseGeocode(center);
    final nearbyPoi = await _safeSearchNearbyPoi(center);

    final rawCandidates = <_ResolverCandidate?>[
      if (reverse != null)
        _networkCandidate(
          name: reverse.name,
          coordinate: reverse.coordinates,
          center: center,
          radiusMeters: _reverseRadiusM,
          sourceQuality: 0.24,
          temporalConsistency: temporal,
          reasonCode: 'reverse_geocode_match',
        ),
      ...nearbyPoi.map(
        (poi) => _networkCandidate(
          name: poi.name,
          coordinate: poi.coordinates,
          center: center,
          radiusMeters: _poiRadiusM,
          sourceQuality: 0.30,
          temporalConsistency: temporal,
          reasonCode: 'poi_match',
        ),
      ),
    ];
    final candidates = _dedupeCandidates(
      rawCandidates.whereType<_ResolverCandidate>().toList(growable: false),
    );

    if (candidates.isEmpty) {
      return const ResolvedPlaceDecision(
        state: 'on_route_unresolved',
        confidence: 0,
        reasonCode: 'no_candidate',
      );
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    final best = candidates.first;
    if (best.score >= _resolvedThreshold) {
      final placeId = await _ensureDraftPlace(
        tripId: row.tripId,
        candidate: best,
        capturedAt: row.createdAt,
        existingPlaces: places,
      );
      return ResolvedPlaceDecision(
        state: 'resolved',
        confidence: best.score,
        reasonCode: 'poi_auto_created',
        placeId: placeId,
        hintJson: _encodeHints(candidates),
      );
    }
    if (best.score >= _reviewThreshold) {
      return ResolvedPlaceDecision(
        state: 'review_required',
        confidence: best.score,
        reasonCode: 'ambiguous_candidates',
        hintJson: _encodeHints(candidates),
      );
    }
    return ResolvedPlaceDecision(
      state: 'on_route_unresolved',
      confidence: best.score,
      reasonCode: 'no_candidate',
      hintJson: _encodeHints(candidates),
    );
  }

  List<_ResolverCandidate> _tripPlaceCandidates({
    required AppLatLng center,
    required List<PlaceRow> places,
  }) {
    final candidates = <_ResolverCandidate>[];
    for (final place in places) {
      final distance = _distanceMeters(center, place.coordinates);
      if (distance > _tripPlaceRadiusM) {
        continue;
      }
      final score = _score(
        distanceMeters: distance,
        radiusMeters: _tripPlaceRadiusM,
        sourceQuality: 0.35,
        temporalConsistency: 0.20,
      );
      candidates.add(
        _ResolverCandidate(
          placeId: place.id,
          name: place.name,
          coordinate: place.coordinates,
          score: score,
          reasonCode: 'trip_place_radius_match',
        ),
      );
    }
    return candidates;
  }

  List<_ResolverCandidate> _anchorCandidates({
    required AppLatLng center,
    required List<TrackingEventRow> anchors,
  }) {
    final candidates = <_ResolverCandidate>[];
    for (final anchor in anchors) {
      final lat = anchor.latitude;
      final lng = anchor.longitude;
      final placeId = anchor.resolvedPlaceId;
      if (lat == null || lng == null || placeId == null) {
        continue;
      }
      final distance = _distanceMeters(
        center,
        AppLatLng(latitude: lat, longitude: lng),
      );
      if (distance > _anchorRadiusM) {
        continue;
      }
      final score = _score(
        distanceMeters: distance,
        radiusMeters: _anchorRadiusM,
        sourceQuality: 0.35,
        temporalConsistency: 0.20,
      );
      candidates.add(
        _ResolverCandidate(
          placeId: placeId,
          name: anchor.note ?? 'Anchor',
          coordinate: AppLatLng(latitude: lat, longitude: lng),
          score: score,
          reasonCode: 'anchor_match',
        ),
      );
    }
    return candidates;
  }

  _ResolverCandidate? _networkCandidate({
    required String name,
    required AppLatLng coordinate,
    required AppLatLng center,
    required int radiusMeters,
    required double sourceQuality,
    required double temporalConsistency,
    required String reasonCode,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return null;
    }
    final distance = _distanceMeters(center, coordinate);
    if (distance > radiusMeters) {
      return null;
    }
    final score = _score(
      distanceMeters: distance,
      radiusMeters: radiusMeters,
      sourceQuality: sourceQuality,
      temporalConsistency: temporalConsistency,
    );
    return _ResolverCandidate(
      placeId: null,
      name: normalizedName,
      coordinate: coordinate,
      score: score,
      reasonCode: reasonCode,
    );
  }

  List<_ResolverCandidate> _dedupeCandidates(List<_ResolverCandidate> input) {
    final byKey = <String, _ResolverCandidate>{};
    for (final candidate in input) {
      final key =
          '${_normalizedName(candidate.name)}:${candidate.coordinate.latitude.toStringAsFixed(4)}:${candidate.coordinate.longitude.toStringAsFixed(4)}';
      final current = byKey[key];
      if (current == null || candidate.score > current.score) {
        byKey[key] = candidate;
      }
    }
    return byKey.values.toList(growable: false);
  }

  Future<String> _ensureDraftPlace({
    required String tripId,
    required _ResolverCandidate candidate,
    required DateTime capturedAt,
    required List<PlaceRow> existingPlaces,
  }) async {
    final existingMatch = existingPlaces.where((place) {
      if (_normalizedName(place.name) != _normalizedName(candidate.name)) {
        return false;
      }
      final distance = _distanceMeters(place.coordinates, candidate.coordinate);
      return distance <= 40;
    }).toList(growable: false);
    if (existingMatch.isNotEmpty) {
      return existingMatch.first.id;
    }

    final now = _now().toUtc();
    final placeId = _uuid.v4();
    final nextOrderIndex = existingPlaces.isEmpty
        ? 0
        : existingPlaces
                .map((place) => place.orderIndex)
                .fold<int>(0, math.max) +
            1;
    await _placeDao.insertPlace(
      PlacesCompanion.insert(
        id: placeId,
        tripId: tripId,
        name: candidate.name,
        coordinates: candidate.coordinate,
        orderIndex: nextOrderIndex,
        address: const Value(null),
        notes: const Value('Auto-resolved from live tracking.'),
        visitTime: Value(capturedAt.toIso8601String()),
        dayNumber: const Value(null),
        photoUrls: const Value(<String>[]),
        placeType: const Value('auto_resolved'),
        rating: const Value(null),
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'pending',
        serverPlaceId: const Value(null),
      ),
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.place,
      entityId: placeId,
      operation: 'create',
      dependsOnEntityType: SyncEntityTypes.trip,
      dependsOnEntityId: tripId,
    );
    return placeId;
  }

  bool _shouldRunNetworkFallback({
    required ResolvedPlaceDecision localDecision,
    required TrackingEventRow row,
  }) {
    if (row.latitude == null || row.longitude == null) {
      return false;
    }
    if (localDecision.state == 'resolved' &&
        (localDecision.reasonCode == 'trip_place_radius_match' ||
            localDecision.reasonCode == 'anchor_match')) {
      return false;
    }
    return true;
  }

  Future<GeocodingResult?> _safeReverseGeocode(AppLatLng center) async {
    try {
      return await _geocodingService
          .reverseGeocode(center)
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {
      return null;
    }
  }

  Future<List<GeocodingResult>> _safeSearchNearbyPoi(AppLatLng center) async {
    try {
      return await _geocodingService
          .searchNearbyPoi(
            center,
            radiusMeters: _poiRadiusM,
            limit: 6,
          )
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {
      return const <GeocodingResult>[];
    }
  }

  Future<void> _persistDecision({
    required String eventId,
    required ResolvedPlaceDecision decision,
  }) {
    return _trackingEventDao.updateResolverDecision(
      eventId: eventId,
      resolvedPlaceId: decision.placeId,
      bindConfidence: decision.confidence,
      resolverReasonCode: decision.reasonCode,
      resolverState: decision.state,
      resolverVersion: resolverVersion,
      resolutionHintJson: decision.hintJson,
    );
  }

  ResolvedPlaceDecision _preferDecision({
    required ResolvedPlaceDecision localDecision,
    required ResolvedPlaceDecision networkDecision,
  }) {
    final localRank = _stateRank(localDecision.state);
    final networkRank = _stateRank(networkDecision.state);
    if (networkRank > localRank) {
      return networkDecision;
    }
    if (networkRank < localRank) {
      return localDecision;
    }
    if (networkDecision.confidence >= localDecision.confidence) {
      return networkDecision;
    }
    return localDecision;
  }

  int _stateRank(String state) {
    switch (state) {
      case 'resolved':
        return 2;
      case 'review_required':
        return 1;
      default:
        return 0;
    }
  }

  AppLatLng? _eventCoordinate(TrackingEventRow row) {
    final lat = row.latitude;
    final lng = row.longitude;
    if (lat == null || lng == null) {
      return null;
    }
    return AppLatLng(latitude: lat, longitude: lng);
  }

  double _score({
    required double distanceMeters,
    required int radiusMeters,
    required double sourceQuality,
    required double temporalConsistency,
  }) {
    final normalizedDistance = (radiusMeters - distanceMeters) / radiusMeters;
    final distanceScore = normalizedDistance.clamp(0, 1) * 0.45;
    final quality = sourceQuality.clamp(0, 0.35);
    final temporal = temporalConsistency.clamp(0, 0.20);
    return (distanceScore + quality + temporal).clamp(0, 1).toDouble();
  }

  double _temporalConsistency({
    required AppLatLng center,
    required List<TrackingEventRow> anchors,
  }) {
    double? nearest;
    for (final anchor in anchors) {
      final lat = anchor.latitude;
      final lng = anchor.longitude;
      if (lat == null || lng == null) {
        continue;
      }
      final distance = _distanceMeters(
        center,
        AppLatLng(latitude: lat, longitude: lng),
      );
      nearest = nearest == null ? distance : math.min(nearest, distance);
    }
    if (nearest == null) {
      return 0.0;
    }
    if (nearest <= 120) {
      return 0.20;
    }
    if (nearest <= 250) {
      return 0.10;
    }
    return 0.0;
  }

  String _encodeHints(List<_ResolverCandidate> candidates) {
    final top = candidates
        .take(3)
        .map(
          (candidate) => <String, dynamic>{
            if (candidate.placeId != null &&
                candidate.placeId!.trim().isNotEmpty)
              'place_id': candidate.placeId,
            'name': candidate.name,
            'latitude': candidate.coordinate.latitude,
            'longitude': candidate.coordinate.longitude,
            'confidence': candidate.score,
            'reason': candidate.reasonCode,
          },
        )
        .toList(growable: false);
    try {
      return jsonEncode(top);
    } catch (_) {
      return '[]';
    }
  }

  static String _normalizedName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? _normalizeText(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static double _distanceMeters(AppLatLng a, AppLatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLon = _toRadians(b.longitude - a.longitude);
    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    final sinLat = math.sin(dLat / 2);
    final sinLon = math.sin(dLon / 2);
    final h = sinLat * sinLat +
        math.cos(lat1) * math.cos(lat2) * sinLon * sinLon;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadius * c;
  }

  static double _toRadians(double value) => value * (math.pi / 180.0);
}

class _ResolverCandidate {
  const _ResolverCandidate({
    required this.placeId,
    required this.name,
    required this.coordinate,
    required this.score,
    required this.reasonCode,
  });

  final String? placeId;
  final String name;
  final AppLatLng coordinate;
  final double score;
  final String reasonCode;
}
