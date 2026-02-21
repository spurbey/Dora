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
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted && !status.isPermanentlyDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

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
