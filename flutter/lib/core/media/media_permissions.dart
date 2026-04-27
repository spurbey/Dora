import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum MediaPermissionState {
  granted,
  denied,
  permanentlyDenied,
}

class MediaPermissions {
  const MediaPermissions();

  Future<MediaPermissionState> ensureCameraPermission({
    bool requestIfDenied = true,
  }) async {
    final status = requestIfDenied
        ? await Permission.camera.request()
        : await Permission.camera.status;
    return _mapStatus(status);
  }

  Future<MediaPermissionState> cameraPermissionStatus({
    bool requestIfDenied = false,
  }) async {
    final status = requestIfDenied
        ? await Permission.camera.request()
        : await Permission.camera.status;
    return _mapStatus(status);
  }

  Future<MediaPermissionState> ensureGalleryPermission({
    bool requestIfDenied = true,
    bool usePhotoManagerForAndroid = false,
  }) async {
    return galleryPermissionStatus(
      requestIfDenied: requestIfDenied,
      usePhotoManagerForAndroid: usePhotoManagerForAndroid,
    );
  }

  Future<MediaPermissionState> galleryPermissionStatus({
    bool requestIfDenied = false,
    bool usePhotoManagerForAndroid = false,
  }) async {
    if (Platform.isAndroid) {
      final statuses = await _androidGalleryStatuses(
        requestIfDenied: requestIfDenied,
      );
      if (statuses.any((status) => status.isGranted || status.isLimited)) {
        return MediaPermissionState.granted;
      }
      if (statuses.any(
        (status) => status.isPermanentlyDenied || status.isRestricted,
      )) {
        return MediaPermissionState.permanentlyDenied;
      }
      return MediaPermissionState.denied;
    }

    final status = requestIfDenied
        ? await Permission.photos.request()
        : await Permission.photos.status;
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

  Future<List<PermissionStatus>> _androidGalleryStatuses({
    required bool requestIfDenied,
  }) async {
    if (requestIfDenied) {
      return <PermissionStatus>[
        await Permission.photos.request(),
        await Permission.videos.request(),
        await Permission.storage.request(),
      ];
    }
    return <PermissionStatus>[
      await Permission.photos.status,
      await Permission.videos.status,
      await Permission.storage.status,
    ];
  }
}
