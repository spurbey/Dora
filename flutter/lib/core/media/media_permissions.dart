import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum MediaPermissionState {
  granted,
  denied,
  permanentlyDenied,
}

class MediaPermissions {
  const MediaPermissions();

  Future<MediaPermissionState> ensureCameraPermission() async {
    final status = await Permission.camera.request();
    return _mapStatus(status);
  }

  Future<MediaPermissionState> ensureGalleryPermission() async {
    if (Platform.isAndroid) {
      // Android photo picker can work without explicit runtime storage permission.
      // Keep flow non-blocking to avoid manifest mismatch loops from permission_handler.
      return MediaPermissionState.granted;
    }

    final status = await Permission.photos.request();
    return _mapStatus(status);
  }

  Future<bool> openSettings() => openAppSettings();

  MediaPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return MediaPermissionState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MediaPermissionState.permanentlyDenied;
    }
    return MediaPermissionState.denied;
  }
}
