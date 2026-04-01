import 'package:dora/core/navigation/routes.dart';

enum LiveEntryIntent {
  fromCreate,
  fromTab,
  fromDeepLink,
}

enum DeepLinkTarget {
  live,
  editor,
}

DeepLinkTarget deepLinkTargetForSessionState(String? sessionState) {
  final normalized = sessionState?.trim().toLowerCase();
  if (normalized == 'active' || normalized == 'paused') {
    return DeepLinkTarget.live;
  }
  return DeepLinkTarget.editor;
}

String deepLinkRouteForTrip({
  required String tripId,
  required String? sessionState,
}) {
  final target = deepLinkTargetForSessionState(sessionState);
  switch (target) {
    case DeepLinkTarget.live:
      return Routes.liveCapturePath(tripId);
    case DeepLinkTarget.editor:
      return Routes.editorPath(tripId);
  }
}
