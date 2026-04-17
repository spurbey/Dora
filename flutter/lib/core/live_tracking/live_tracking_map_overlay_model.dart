import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

/// Data-only model describing the map overlay for a live-tracking session.
///
/// Extracted from the V1 presentation layer so that V2 providers can reference
/// the type without depending on V1 widget/builder code.
class LiveTrackingMapOverlay {
  const LiveTrackingMapOverlay({
    this.pathRoute,
    this.currentMarker,
  });

  final AppRoute? pathRoute;
  final AppMarker? currentMarker;
}
