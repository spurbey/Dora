import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/media/app_media_uploader.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class DoraMediaUploader implements AppMediaUploader {
  DoraMediaUploader({
    required openapi.MediaApi mediaApi,
    required AuthService authService,
  })  : _mediaApi = mediaApi,
        _authService = authService;

  final openapi.MediaApi _mediaApi;
  final AuthService _authService;

  @override
  Future<void> deleteMedia({
    required String mediaId,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const MediaUploadAuthException('Missing auth token for delete');
    }

    await _mediaApi.deleteMediaApiV1MediaMediaIdDelete(
      mediaId: mediaId,
      authorization: 'Bearer $token',
    );
  }

  @override
  Future<UploadedPhotoResult> uploadPhoto(UploadPhotoRequest request) async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const MediaUploadAuthException('Missing auth token for upload');
    }

    final file = await MultipartFile.fromFile(request.filePath);
    final response = await _mediaApi.uploadMediaApiV1MediaUploadPost(
      authorization: 'Bearer $token',
      file: file,
      tripPlaceId: request.tripPlaceId,
      caption: request.caption,
      takenAt: request.takenAt,
      onSendProgress: (sent, total) {
        if (total <= 0) {
          return;
        }
        request.onProgress?.call(sent / total);
      },
    );

    final data = response.data;
    if (data == null) {
      throw const MediaUploadContractException(
          'Upload response payload is empty');
    }

    return UploadedPhotoResult(
      mediaId: data.id,
      fileUrl: data.fileUrl,
      fileType: data.fileType,
      tripId: data.tripId,
      tripPlaceId: data.tripPlaceId,
      createdAt: data.createdAt,
      thumbnailUrl: data.thumbnailUrl,
      mimeType: data.mimeType,
      fileSizeBytes: data.fileSizeBytes,
      width: data.width,
      height: data.height,
    );
  }
}

class MediaUploadAuthException implements Exception {
  const MediaUploadAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediaUploadContractException implements Exception {
  const MediaUploadContractException(this.message);

  final String message;

  @override
  String toString() => message;
}
