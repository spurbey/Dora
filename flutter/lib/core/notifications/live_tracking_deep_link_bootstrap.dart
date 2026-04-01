import 'dart:async';

import 'package:dora/core/navigation/live_deep_link_route_decider.dart';

typedef NotificationPayloadLoader = Future<Map<String, dynamic>?> Function();
typedef NotificationPayloadTripResolver = Future<String?> Function(
  String tripIdentity,
);
typedef NotificationPayloadSessionResolver = Future<String?> Function(
  String localTripId,
);
typedef NotificationRouteNavigator = void Function(String route);

class LiveTrackingDeepLinkBootstrap {
  LiveTrackingDeepLinkBootstrap({
    required Stream<Map<String, dynamic>> openedPayloads,
    required NotificationPayloadLoader loadInitialPayload,
    required NotificationPayloadTripResolver resolveLocalTripId,
    required NotificationPayloadSessionResolver resolveSessionState,
    required NotificationRouteNavigator navigateToRoute,
  })  : _openedPayloads = openedPayloads,
        _loadInitialPayload = loadInitialPayload,
        _resolveLocalTripId = resolveLocalTripId,
        _resolveSessionState = resolveSessionState,
        _navigateToRoute = navigateToRoute;

  final Stream<Map<String, dynamic>> _openedPayloads;
  final NotificationPayloadLoader _loadInitialPayload;
  final NotificationPayloadTripResolver _resolveLocalTripId;
  final NotificationPayloadSessionResolver _resolveSessionState;
  final NotificationRouteNavigator _navigateToRoute;

  StreamSubscription<Map<String, dynamic>>? _openedSub;
  final Set<String> _handledIntentKeys = <String>{};
  bool _started = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _openedSub = _openedPayloads.listen(
      (payload) => unawaited(_handlePayload(payload)),
      onError: (_) {},
    );
    unawaited(_consumeInitialPayload());
  }

  void dispose() {
    if (!_started) {
      return;
    }
    _started = false;
    unawaited(_openedSub?.cancel());
    _openedSub = null;
  }

  Future<void> _consumeInitialPayload() async {
    try {
      final payload = await _loadInitialPayload();
      if (payload == null || payload.isEmpty) {
        return;
      }
      await _handlePayload(payload);
    } catch (_) {
      // Best-effort deep-link bootstrap; ignore startup message parse failures.
    }
  }

  Future<void> _handlePayload(Map<String, dynamic> payload) async {
    final tripIdentity = extractTripIdentity(payload);
    if (tripIdentity == null) {
      return;
    }
    final intentKey = _intentKey(payload, tripIdentity);
    if (!_handledIntentKeys.add(intentKey)) {
      return;
    }

    final localTripId = await _resolveLocalTripId(tripIdentity);
    if (localTripId == null || localTripId.isEmpty) {
      return;
    }
    final sessionState = await _resolveSessionState(localTripId);
    final route =
        deepLinkRouteForTrip(tripId: localTripId, sessionState: sessionState);
    _navigateToRoute(route);
  }

  String _intentKey(Map<String, dynamic> payload, String tripIdentity) {
    final messageId = _normalizedString(payload['message_id']);
    if (messageId != null) {
      return 'message:$messageId';
    }
    final notificationId = _normalizedString(payload['notification_id']);
    if (notificationId != null) {
      return 'notification:$notificationId';
    }
    return 'trip:$tripIdentity:${_normalizedString(payload['session_state']) ?? 'unknown'}';
  }
}

String? extractTripIdentity(Map<String, dynamic> payload) {
  return _normalizedString(payload['local_trip_id']) ??
      _normalizedString(payload['trip_local_id']) ??
      _normalizedString(payload['trip_id']) ??
      _normalizedString(payload['server_trip_id']);
}

String? _normalizedString(dynamic value) {
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return null;
}
