import 'package:flutter/foundation.dart';

@immutable
class UploadPhotoRequest {
  const UploadPhotoRequest({
    required this.tripPlaceId,
    required this.filePath,
    this.caption,
    this.takenAt,
    this.onProgress,
  });

  final String tripPlaceId;
  final String filePath;
  final String? caption;
  final DateTime? takenAt;
  final void Function(double progress)? onProgress;
}

@immutable
class UploadedPhotoResult {
  const UploadedPhotoResult({
    required this.mediaId,
    required this.fileUrl,
    required this.fileType,
    required this.tripId,
    required this.tripPlaceId,
    required this.createdAt,
    this.thumbnailUrl,
    this.mimeType,
    this.fileSizeBytes,
    this.width,
    this.height,
  });

  final String mediaId;
  final String fileUrl;
  final String fileType;
  final String tripId;
  final String tripPlaceId;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? width;
  final int? height;
}

abstract class AppMediaUploader {
  Future<UploadedPhotoResult> uploadPhoto(UploadPhotoRequest request);

  Future<void> deleteMedia({
    required String mediaId,
  });
}
