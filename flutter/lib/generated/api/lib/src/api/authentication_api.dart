//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/me_response.dart';

class AuthenticationApi {

  final Dio _dio;

  final Serializers _serializers;

  const AuthenticationApi(this._dio, this._serializers);

  /// Get Current User Info
  /// Get current authenticated user with statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     - user: User profile data     - trip_count: Number of trips created     - place_count: Total places across all trips          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;user\&quot;: {             \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,             \&quot;email\&quot;: \&quot;user@example.com\&quot;,             \&quot;username\&quot;: \&quot;traveler123\&quot;,             \&quot;is_premium\&quot;: false,             \&quot;created_at\&quot;: \&quot;2024-01-15T10:30:00Z\&quot;         },         \&quot;trip_count\&quot;: 2,         \&quot;place_count\&quot;: 15     } &#x60;&#x60;&#x60;          **Errors:**     - 401: Not authenticated or invalid token          **Business Logic:**     - Stats calculated in real-time from database     - Used by frontend to display user dashboard     - Premium status determines feature availability
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MeResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeResponse>> getCurrentUserInfoApiV1AuthMeGet({ 
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/auth/me';
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

    MeResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MeResponse),
      ) as MeResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeResponse>(
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
