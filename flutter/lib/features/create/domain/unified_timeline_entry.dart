import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';

enum UnifiedTimelineEntryType {
  place,
  liveEvent,
  route,
}

sealed class UnifiedTimelineEntry {
  UnifiedTimelineEntry({
    required this.id,
    required this.displayOrder,
    required this.type,
    required this.draggable,
  });

  final String id;
  final double displayOrder;
  final UnifiedTimelineEntryType type;
  final bool draggable;
}

class UnifiedPlaceTimelineEntry extends UnifiedTimelineEntry {
  UnifiedPlaceTimelineEntry({
    required this.place,
    required super.displayOrder,
  }) : super(
          id: 'place:${place.id}',
          type: UnifiedTimelineEntryType.place,
          draggable: true,
        );

  final Place place;
}

class UnifiedLiveEventTimelineEntry extends UnifiedTimelineEntry {
  UnifiedLiveEventTimelineEntry({
    required this.event,
    required this.mediaCount,
    required super.displayOrder,
  }) : super(
          id: 'event:${event.entryId}',
          type: UnifiedTimelineEntryType.liveEvent,
          draggable: false,
        );

  final V2TimelineProjectionEntry event;
  final int mediaCount;
}

class UnifiedRouteTimelineEntry extends UnifiedTimelineEntry {
  UnifiedRouteTimelineEntry({
    required this.route,
    required this.startPlaceName,
    required this.endPlaceName,
    required super.displayOrder,
  }) : super(
          id: 'route:${route.id}',
          type: UnifiedTimelineEntryType.route,
          draggable: false,
        );

  final create_route.Route route;
  final String? startPlaceName;
  final String? endPlaceName;
}
