//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/api_util.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/media_response.dart';

class MediaApi {

  final Dio _dio;

  final Serializers _serializers;

  const MediaApi(this._dio, this._serializers);

  /// Delete Media
  /// Delete media.  **Authentication:** Required  **Permissions:** Only owner can delete  **Path Parameters:** - media_id: Media UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own media - 404: Media not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Deletes file from Supabase Storage - Deletes metadata from database - Permanent deletion (no soft delete)  **Warning:** - This action is irreversible - File will be deleted from storage
  ///
  /// Parameters:
  /// * [mediaId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> deleteMediaApiV1MediaMediaIdDelete({ 
    required String mediaId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/media/{media_id}'.replaceAll('{' r'media_id' '}', encodeQueryParameter(_serializers, mediaId, const FullType(String)).toString());
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{
        r'authorization': authorization,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Get Media
  /// Get media detail by ID.          **Authentication:** Required          **Permissions:**     - Owner can always view     - Non-owner can view if trip is public/unlisted          **Path Parameters:**     - media_id: Media UUID          **Returns:**     Media details with file URLs          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;trip_place_id\&quot;: \&quot;456e7890-e12b-12d3-a456-426614174000\&quot;,         \&quot;file_url\&quot;: \&quot;https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\&quot;,         \&quot;thumbnail_url\&quot;: \&quot;https://xxx.supabase.co/.../file.jpg?width&#x3D;200&amp;height&#x3D;200\&quot;,         \&quot;caption\&quot;: \&quot;Beautiful sunset\&quot;,         \&quot;created_at\&quot;: \&quot;2025-01-26T10:00:00Z\&quot;     } &#x60;&#x60;&#x60;          **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Media not found          **Business Logic:**     - Access control based on parent trip&#39;s visibility     - Private trip media only visible to owner     - Public/unlisted trip media visible to anyone
  ///
  /// Parameters:
  /// * [mediaId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MediaResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MediaResponse>> getMediaApiV1MediaMediaIdGet({ 
    required String mediaId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/media/{media_id}'.replaceAll('{' r'media_id' '}', encodeQueryParameter(_serializers, mediaId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'authorization': authorization,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MediaResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MediaResponse),
      ) as MediaResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MediaResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Upload Media
  /// Upload photo to a place.          **Authentication:** Required          **Permissions:** User must own the place (via trip ownership)          **Request:**     - Content-Type: multipart/form-data     - file: Image file (required)     - trip_place_id: UUID of place (required)     - caption: Photo caption (optional, max 500 chars)     - taken_at: When photo was taken (optional, ISO datetime)          **Returns:**     Created media with file URLs          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;trip_place_id\&quot;: \&quot;456e7890-e12b-12d3-a456-426614174000\&quot;,         \&quot;file_url\&quot;: \&quot;https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\&quot;,         \&quot;file_type\&quot;: \&quot;photo\&quot;,         \&quot;file_size_bytes\&quot;: 245678,         \&quot;mime_type\&quot;: \&quot;image/jpeg\&quot;,         \&quot;width\&quot;: 1920,         \&quot;height\&quot;: 1080,         \&quot;thumbnail_url\&quot;: \&quot;https://xxx.supabase.co/.../file.jpg?width&#x3D;200&amp;height&#x3D;200\&quot;,         \&quot;caption\&quot;: \&quot;Beautiful sunset at Eiffel Tower\&quot;,         \&quot;taken_at\&quot;: \&quot;2025-06-15T18:30:00Z\&quot;,         \&quot;created_at\&quot;: \&quot;2025-01-26T10:00:00Z\&quot;     } &#x60;&#x60;&#x60;          **Errors:**     - 400: Invalid file type or size     - 401: Not authenticated     - 403: User does not own place     - 404: Place not found          **Business Logic:**     - File stored in Supabase Storage: photos/{user_id}/{uuid}.{ext}     - Thumbnail auto-generated via Supabase transformations     - Image dimensions extracted via PIL     - Free tier: max 10MB per photo     - Premium tier: max 100MB per photo     - Allowed types: image/jpeg, image/png, image/webp
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [file] - Photo file to upload
  /// * [tripPlaceId] - Place ID to attach media to
  /// * [caption] 
  /// * [takenAt] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MediaResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MediaResponse>> uploadMediaApiV1MediaUploadPost({ 
    required String authorization,
    required MultipartFile file,
    required String tripPlaceId,
    String? caption,
    DateTime? takenAt,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/media/upload';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'authorization': authorization,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      contentType: 'multipart/form-data',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = FormData.fromMap(<String, dynamic>{
        r'file': file,
        r'trip_place_id': encodeFormParameter(_serializers, tripPlaceId, const FullType(String)),
        r'caption': encodeFormParameter(_serializers, caption, const FullType(String)),
        r'taken_at': encodeFormParameter(_serializers, takenAt, const FullType(DateTime)),
      });

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MediaResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MediaResponse),
      ) as MediaResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MediaResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
