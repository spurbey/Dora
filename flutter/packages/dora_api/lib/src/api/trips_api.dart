//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:built_value/json_object.dart';
import 'package:dora_api/src/api_util.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/trip_create.dart';
import 'package:dora_api/src/model/trip_list_response.dart';
import 'package:dora_api/src/model/trip_response.dart';
import 'package:dora_api/src/model/trip_update.dart';

class TripsApi {

  final Dio _dio;

  final Serializers _serializers;

  const TripsApi(this._dio, this._serializers);

  /// Create Trip
  /// Create a new trip.      **Authentication:** Required      **Permissions:** Any authenticated user      **Request Body:**     - title: Trip title (required, 1-255 chars)     - description: Optional trip description     - start_date: Optional trip start date (YYYY-MM-DD)     - end_date: Optional trip end date (YYYY-MM-DD)     - cover_photo_url: Optional cover photo URL     - visibility: private | unlisted | public (default: private)      **Returns:**     Created trip with generated ID      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;title\&quot;: \&quot;Summer Europe Trip\&quot;,         \&quot;description\&quot;: \&quot;Backpacking across Europe\&quot;,         \&quot;start_date\&quot;: \&quot;2025-06-01\&quot;,         \&quot;end_date\&quot;: \&quot;2025-06-30\&quot;,         \&quot;visibility\&quot;: \&quot;private\&quot;,         \&quot;views_count\&quot;: 0,         \&quot;saves_count\&quot;: 0,         \&quot;created_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;,         \&quot;updated_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;     } &#x60;&#x60;&#x60;      **Errors:**     - 400: Invalid date range (end_date &lt; start_date) or invalid visibility     - 401: Not authenticated     - 403: Free tier limit reached (3 trips max)      **Business Logic:**     - user_id is automatically set from authenticated user     - Free tier users: max 3 trips     - Premium users: unlimited trips     - Default visibility is \&quot;private\&quot;     - views_count and saves_count initialized to 0
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [tripCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripResponse>> createTripApiV1TripsPost({ 
    required String authorization,
    required TripCreate tripCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips';
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(TripCreate);
      _bodyData = _serializers.serialize(tripCreate, specifiedType: _type);

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

    TripResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripResponse),
      ) as TripResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripResponse>(
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

  /// Delete Trip
  /// Delete a trip.  **Authentication:** Required  **Permissions:** Only trip owner can delete  **Path Parameters:** - trip_id: Trip UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own trip - 404: Trip not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Cascades to related records:   - All trip_places deleted (via ON DELETE CASCADE)   - All trip_routes deleted (via ON DELETE CASCADE) - Permanent deletion (no soft delete)  **Warning:** - This action is irreversible - All associated places and routes will be deleted
  ///
  /// Parameters:
  /// * [tripId] 
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
  Future<Response<void>> deleteTripApiV1TripsTripIdDelete({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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

  /// Get Trip
  /// Get trip detail by ID.      **Authentication:** Required      **Permissions:**     - Owner can always view their trip     - Non-owners can view if trip is public or unlisted     - Private trips only visible to owner      **Path Parameters:**     - trip_id: Trip UUID      **Returns:**     Trip details      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;title\&quot;: \&quot;Summer Europe Trip\&quot;,         \&quot;description\&quot;: \&quot;Backpacking across Europe\&quot;,         \&quot;start_date\&quot;: \&quot;2025-06-01\&quot;,         \&quot;end_date\&quot;: \&quot;2025-06-30\&quot;,         \&quot;visibility\&quot;: \&quot;public\&quot;,         \&quot;views_count\&quot;: 142,         \&quot;saves_count\&quot;: 23,         \&quot;created_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;,         \&quot;updated_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;     } &#x60;&#x60;&#x60;      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Increments views_count if viewer is NOT the owner     - Access control based on visibility:       - private: Only owner can view       - unlisted: Owner + anyone with link can view       - public: Anyone can view
  ///
  /// Parameters:
  /// * [tripId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripResponse>> getTripApiV1TripsTripIdGet({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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

    TripResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripResponse),
      ) as TripResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripResponse>(
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

  /// Get Trip Bounds
  /// Get geographic bounding box for a trip based on its places.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted      **Path Parameters:**     - trip_id: Trip UUID      **Returns:**     Bounding box with min/max coordinates and center point, or null if no places      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;min_lat\&quot;: 48.8530,         \&quot;min_lng\&quot;: 2.2945,         \&quot;max_lat\&quot;: 48.8738,         \&quot;max_lng\&quot;: 2.3499,         \&quot;center_lat\&quot;: 48.8634,         \&quot;center_lng\&quot;: 2.3222     } &#x60;&#x60;&#x60;      **Null Response (no places):** &#x60;&#x60;&#x60;json     null &#x60;&#x60;&#x60;      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Calculates bounding box from all places in trip     - Returns null if trip has no places     - Access control based on trip visibility     - Useful for auto-centering map on trip     - Center is simple average of bounds (not geographic centroid)      **Use Cases:**     - Auto-fit map to show all places in trip     - Calculate zoom level for trip map view     - Determine trip geographic span
  ///
  /// Parameters:
  /// * [tripId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [JsonObject] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<JsonObject>> getTripBoundsApiV1TripsTripIdBoundsGet({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}/bounds'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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

    JsonObject? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(JsonObject),
      ) as JsonObject;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<JsonObject>(
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

  /// List Trips
  /// List current user&#39;s trips with pagination.      **Authentication:** Required      **Permissions:** Any authenticated user (only sees own trips)      **Query Parameters:**     - page: Page number (default: 1, min: 1)     - page_size: Items per page (default: 20, max: 100)     - visibility: Optional filter by visibility (private|unlisted|public)      **Returns:**     Paginated list of trips with metadata      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;trips\&quot;: [             {                 \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,                 \&quot;title\&quot;: \&quot;Summer Europe Trip\&quot;,                 ...             },             {                 \&quot;id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,                 \&quot;title\&quot;: \&quot;Winter Japan Trip\&quot;,                 ...             }         ],         \&quot;total\&quot;: 15,         \&quot;page\&quot;: 1,         \&quot;page_size\&quot;: 20,         \&quot;total_pages\&quot;: 1     } &#x60;&#x60;&#x60;      **Errors:**     - 401: Not authenticated      **Business Logic:**     - Only returns trips owned by current user     - Results ordered by created_at DESC (newest first)     - Page size automatically capped at 100     - Empty list if user has no trips
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [page] - Page number (1-indexed)
  /// * [pageSize] - Items per page (max 100)
  /// * [visibility] - Filter by visibility (private|unlisted|public)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripListResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripListResponse>> listTripsApiV1TripsGet({ 
    required String authorization,
    int? page = 1,
    int? pageSize = 20,
    String? visibility,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips';
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

    final _queryParameters = <String, dynamic>{
      if (page != null) r'page': encodeQueryParameter(_serializers, page, const FullType(int)),
      if (pageSize != null) r'page_size': encodeQueryParameter(_serializers, pageSize, const FullType(int)),
      r'visibility': encodeQueryParameter(_serializers, visibility, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripListResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripListResponse),
      ) as TripListResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripListResponse>(
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

  /// Update Trip
  /// Update an existing trip.      **Authentication:** Required      **Permissions:** Only trip owner can update      **Path Parameters:**     - trip_id: Trip UUID      **Request Body:**     All fields are optional (partial update):     - title: New trip title (1-255 chars)     - description: New description     - start_date: New start date     - end_date: New end date     - cover_photo_url: New cover photo URL     - visibility: New visibility (private|unlisted|public)      **Returns:**     Updated trip      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;title\&quot;: \&quot;Updated Trip Title\&quot;,         \&quot;description\&quot;: \&quot;Updated description\&quot;,         ...     } &#x60;&#x60;&#x60;      **Errors:**     - 400: Invalid date range (end_date &lt; start_date)     - 401: Not authenticated     - 403: User does not own trip     - 404: Trip not found      **Business Logic:**     - Only updates provided fields (partial update)     - Ownership check prevents unauthorized updates     - Date validation ensures end_date &gt;&#x3D; start_date     - Cannot update user_id or engagement metrics (views, saves)     - updated_at timestamp automatically updated
  ///
  /// Parameters:
  /// * [tripId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [tripUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripResponse>> updateTripApiV1TripsTripIdPatch({ 
    required String tripId,
    required String authorization,
    required TripUpdate tripUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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
      const _type = FullType(TripUpdate);
      _bodyData = _serializers.serialize(tripUpdate, specifiedType: _type);

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

    TripResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripResponse),
      ) as TripResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripResponse>(
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
