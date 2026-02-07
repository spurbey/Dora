//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/model/app_schemas_user_user_response.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/user_profile_response.dart';
import 'package:dora_api/src/model/user_stats.dart';
import 'package:dora_api/src/model/user_update.dart';

class UsersApi {

  final Dio _dio;

  final Serializers _serializers;

  const UsersApi(this._dio, this._serializers);

  /// Get Current User Complete Profile
  /// Get complete user profile with statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     User profile + statistics in single response          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;user\&quot;: {             \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,             \&quot;email\&quot;: \&quot;user@example.com\&quot;,             \&quot;username\&quot;: \&quot;traveler123\&quot;,             ...         },         \&quot;stats\&quot;: {             \&quot;trip_count\&quot;: 5,             \&quot;place_count\&quot;: 47,             ...         }     } &#x60;&#x60;&#x60;          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Combines /me and /me/stats into single response     - Reduces frontend API calls for profile page     - More efficient than two separate requests
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
  /// Returns a [Future] containing a [Response] with a [UserProfileResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<UserProfileResponse>> getCurrentUserCompleteProfileApiV1UsersMeProfileGet({ 
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/users/me/profile';
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

    UserProfileResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(UserProfileResponse),
      ) as UserProfileResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<UserProfileResponse>(
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

  /// Get Current User Profile
  /// Get current user profile.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     User profile data          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;email\&quot;: \&quot;user@example.com\&quot;,         \&quot;username\&quot;: \&quot;traveler123\&quot;,         \&quot;full_name\&quot;: \&quot;John Doe\&quot;,         \&quot;avatar_url\&quot;: \&quot;https://example.com/avatar.jpg\&quot;,         \&quot;bio\&quot;: \&quot;Love to travel!\&quot;,         \&quot;is_premium\&quot;: false,         \&quot;is_verified\&quot;: true,         \&quot;created_at\&quot;: \&quot;2024-01-15T10:30:00Z\&quot;     } &#x60;&#x60;&#x60;          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Returns current user&#39;s profile data     - Used by frontend profile page
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
  /// Returns a [Future] containing a [Response] with a [AppSchemasUserUserResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AppSchemasUserUserResponse>> getCurrentUserProfileApiV1UsersMeGet({ 
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/users/me';
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

    AppSchemasUserUserResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AppSchemasUserUserResponse),
      ) as AppSchemasUserUserResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AppSchemasUserUserResponse>(
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

  /// Get Current User Stats
  /// Get detailed user statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     Detailed statistics about user&#39;s content and engagement          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;trip_count\&quot;: 5,         \&quot;place_count\&quot;: 47,         \&quot;public_trip_count\&quot;: 2,         \&quot;total_views\&quot;: 1234,         \&quot;total_saves\&quot;: 56,         \&quot;photos_uploaded\&quot;: 89     } &#x60;&#x60;&#x60;          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Calculates statistics in real-time from database     - Used by dashboard to display user activity     - Premium users get additional stats (future)          **Performance:**     - Uses SQLAlchemy aggregation functions     - Queries optimized with indexes     - Consider caching for high-traffic users
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
  /// Returns a [Future] containing a [Response] with a [UserStats] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<UserStats>> getCurrentUserStatsApiV1UsersMeStatsGet({ 
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/users/me/stats';
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

    UserStats? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(UserStats),
      ) as UserStats;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<UserStats>(
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

  /// Update Current User Profile
  /// Update current user profile.          **Authentication:** Required          **Permissions:** Any authenticated user (can only update own profile)          **Request Body:**     All fields are optional (partial update):     - username: New username (3-50 chars, alphanumeric + underscore)     - full_name: New full name     - bio: New bio (max 500 chars)     - avatar_url: New avatar URL          **Returns:**     Updated user profile          **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;username\&quot;: \&quot;new_username\&quot;,         \&quot;full_name\&quot;: \&quot;Updated Name\&quot;,         \&quot;bio\&quot;: \&quot;Updated bio\&quot;,         ...     } &#x60;&#x60;&#x60;          **Errors:**     - 400: Username already taken or invalid format     - 401: Not authenticated          **Business Logic:**     - Only updates provided fields (partial update)     - Username must be unique across all users     - Username can only contain letters, numbers, underscore     - Email cannot be changed (use Supabase Auth)
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [userUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AppSchemasUserUserResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AppSchemasUserUserResponse>> updateCurrentUserProfileApiV1UsersMePatch({ 
    required String authorization,
    required UserUpdate userUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/users/me';
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        r'authorization': authorization,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(UserUpdate);
      _bodyData = _serializers.serialize(userUpdate, specifiedType: _type);

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

    AppSchemasUserUserResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AppSchemasUserUserResponse),
      ) as AppSchemasUserUserResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AppSchemasUserUserResponse>(
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
