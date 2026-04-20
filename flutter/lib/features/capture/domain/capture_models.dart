enum CameraLaunchContext {
  fab,
  liveTracking,
}

enum CameraInitialMode {
  photo,
  video,
}

enum CaptureDestination {
  vault,
  storyDraft,
}

enum CapturedMediaKind {
  photo,
  video,
}

enum CapturePersistFailureCode {
  cancelled,
  permissionDenied,
  missingFile,
  locationUnavailable,
  persistFailed,
  unknown,
}

class CameraLaunchArgs {
  const CameraLaunchArgs({
    required this.context,
    this.initialMode = CameraInitialMode.photo,
    this.preferredTripId,
  });

  final CameraLaunchContext context;
  final CameraInitialMode initialMode;
  final String? preferredTripId;
}

class CapturePersistResult {
  const CapturePersistResult({
    required this.mediaId,
    required this.destination,
    required this.kind,
    required this.attachedToTrip,
    this.eventId,
    this.storyId,
    this.tripId,
    this.tripName,
  });

  final String mediaId;
  final CaptureDestination destination;
  final CapturedMediaKind kind;
  final bool attachedToTrip;
  final String? eventId;
  final String? storyId;
  final String? tripId;
  final String? tripName;
}

class CapturePersistException implements Exception {
  const CapturePersistException({
    required this.code,
    required this.message,
  });

  final CapturePersistFailureCode code;
  final String message;

  @override
  String toString() => 'CapturePersistException(${code.name}): $message';
}
