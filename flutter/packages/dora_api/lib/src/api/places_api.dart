//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/api_util.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/place_create.dart';
import 'package:dora_api/src/model/place_list_response.dart';
import 'package:dora_api/src/model/place_response.dart';
import 'package:dora_api/src/model/place_update.dart';

class PlacesApi {

  final Dio _dio;

  final Serializers _serializers;

  const PlacesApi(this._dio, this._serializers);

  /// Create Place
  /// Create a new place in a trip.      **Authentication:** Required      **Permissions:** User must own the trip      **Request Body:**     - trip_id: Parent trip ID (required)     - name: Place name (required, 1-255 chars)     - lat: Latitude (required, -90 to 90)     - lng: Longitude (required, -180 to 180)     - place_type: Category (restaurant, hotel, attraction, etc.)     - user_notes: Personal notes     - user_rating: Rating 1-5 (optional)     - visit_date: Date of visit (optional)     - order_in_trip: Position in itinerary (optional, auto-set if not provided)      **Returns:**     Created place with generated ID      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;trip_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;456e7890-e12b-12d3-a456-426614174000\&quot;,         \&quot;name\&quot;: \&quot;Eiffel Tower\&quot;,         \&quot;place_type\&quot;: \&quot;attraction\&quot;,         \&quot;lat\&quot;: 48.8584,         \&quot;lng\&quot;: 2.2945,         \&quot;user_notes\&quot;: \&quot;Must visit at night!\&quot;,         \&quot;user_rating\&quot;: 5,         \&quot;visit_date\&quot;: \&quot;2025-06-15\&quot;,         \&quot;photos\&quot;: [],         \&quot;videos\&quot;: [],         \&quot;order_in_trip\&quot;: 0,         \&quot;created_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;,         \&quot;updated_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;     } &#x60;&#x60;&#x60;      **Errors:**     - 400: Invalid coordinates or rating     - 401: Not authenticated     - 403: User does not own trip     - 404: Trip not found      **Business Logic:**     - user_id is automatically set from authenticated user     - lat/lng converted to PostGIS Geography POINT (SRID&#x3D;4326;POINT(lng lat))     - If order_in_trip not provided, auto-set to max + 1     - Trip ownership validated before creation
  ///
  /// Parameters:
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [placeCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceResponse>> createPlaceApiV1PlacesPost({ 
    required String authorization,
    required PlaceCreate placeCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places';
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
      const _type = FullType(PlaceCreate);
      _bodyData = _serializers.serialize(placeCreate, specifiedType: _type);

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

    PlaceResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceResponse),
      ) as PlaceResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceResponse>(
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

  /// Delete Place
  /// Delete a place.  **Authentication:** Required  **Permissions:** Only trip owner can delete  **Path Parameters:** - place_id: Place UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own trip - 404: Place not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Permanent deletion (no soft delete) - Order gaps are okay (reordering is separate operation)  **Warning:** - This action is irreversible - Place data including photos metadata will be deleted
  ///
  /// Parameters:
  /// * [placeId] 
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
  Future<Response<void>> deletePlaceApiV1PlacesPlaceIdDelete({ 
    required String placeId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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

  /// Get Nearby Places
  /// Find places near a location using PostGIS spatial query.      **Authentication:** Required      **Query Parameters:**     - lat: Center latitude (required, -90 to 90)     - lng: Center longitude (required, -180 to 180)     - radius: Search radius in km (default: 5.0, max: 50.0)      **Returns:**     List of user&#39;s places within radius, ordered by distance      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;places\&quot;: [             {                 \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,                 \&quot;name\&quot;: \&quot;Eiffel Tower\&quot;,                 \&quot;lat\&quot;: 48.8584,                 \&quot;lng\&quot;: 2.2945,                 \&quot;distance_km\&quot;: 0.0,                 ...             },             {                 \&quot;id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,                 \&quot;name\&quot;: \&quot;Arc de Triomphe\&quot;,                 \&quot;lat\&quot;: 48.8738,                 \&quot;lng\&quot;: 2.2950,                 \&quot;distance_km\&quot;: 2.1,                 ...             }         ],         \&quot;total\&quot;: 2,         \&quot;search_center\&quot;: {\&quot;lat\&quot;: 48.8584, \&quot;lng\&quot;: 2.2945},         \&quot;radius_km\&quot;: 5.0     } &#x60;&#x60;&#x60;      **Errors:**     - 400: Invalid coordinates or radius     - 401: Not authenticated      **Business Logic:**     - Only returns current user&#39;s places     - Uses PostGIS ST_DWithin for efficient spatial search     - Results ordered by distance (closest first)     - Maximum radius capped at 50km     - Uses GIST spatial index for fast queries      **PostGIS Query:**     - ST_DWithin: Find places within radius     - ST_Distance: Calculate distance for ordering     - Geography type: Accurate ellipsoidal calculations
  ///
  /// Parameters:
  /// * [lat] - Search center latitude
  /// * [lng] - Search center longitude
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [radius] - Search radius in kilometers
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceListResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceListResponse>> getNearbyPlacesApiV1PlacesNearbyGet({ 
    required num lat,
    required num lng,
    required String authorization,
    num? radius = 5.0,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/nearby';
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
      r'lat': encodeQueryParameter(_serializers, lat, const FullType(num)),
      r'lng': encodeQueryParameter(_serializers, lng, const FullType(num)),
      if (radius != null) r'radius': encodeQueryParameter(_serializers, radius, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PlaceListResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceListResponse),
      ) as PlaceListResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceListResponse>(
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

  /// Get Place
  /// Get place detail by ID.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted     - Private trips only visible to owner      **Path Parameters:**     - place_id: Place UUID      **Returns:**     Place details with photos and metadata      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;trip_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,         \&quot;user_id\&quot;: \&quot;456e7890-e12b-12d3-a456-426614174000\&quot;,         \&quot;name\&quot;: \&quot;Eiffel Tower\&quot;,         \&quot;place_type\&quot;: \&quot;attraction\&quot;,         \&quot;lat\&quot;: 48.8584,         \&quot;lng\&quot;: 2.2945,         \&quot;user_notes\&quot;: \&quot;Visited at sunset - amazing views!\&quot;,         \&quot;user_rating\&quot;: 5,         \&quot;visit_date\&quot;: \&quot;2025-06-15\&quot;,         \&quot;photos\&quot;: [             {\&quot;url\&quot;: \&quot;https://...\&quot;, \&quot;caption\&quot;: \&quot;From the top\&quot;, \&quot;order\&quot;: 0}         ],         \&quot;videos\&quot;: [],         \&quot;order_in_trip\&quot;: 0,         \&quot;created_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;,         \&quot;updated_at\&quot;: \&quot;2025-01-25T10:30:00Z\&quot;     } &#x60;&#x60;&#x60;      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Place not found      **Business Logic:**     - Access control based on parent trip&#39;s visibility     - Returns full place data including photos/videos
  ///
  /// Parameters:
  /// * [placeId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceResponse>> getPlaceApiV1PlacesPlaceIdGet({ 
    required String placeId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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

    PlaceResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceResponse),
      ) as PlaceResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceResponse>(
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

  /// List Places
  /// List all places for a trip.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted      **Query Parameters:**     - trip_id: Trip ID (required)      **Returns:**     List of places ordered by order_in_trip (itinerary order)      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;places\&quot;: [             {                 \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,                 \&quot;name\&quot;: \&quot;Eiffel Tower\&quot;,                 \&quot;lat\&quot;: 48.8584,                 \&quot;lng\&quot;: 2.2945,                 \&quot;order_in_trip\&quot;: 0,                 ...             },             {                 \&quot;id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;,                 \&quot;name\&quot;: \&quot;Louvre Museum\&quot;,                 \&quot;lat\&quot;: 48.8606,                 \&quot;lng\&quot;: 2.3376,                 \&quot;order_in_trip\&quot;: 1,                 ...             }         ],         \&quot;total\&quot;: 2,         \&quot;trip_id\&quot;: \&quot;987e6543-e21b-12d3-a456-426614174000\&quot;     } &#x60;&#x60;&#x60;      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Access control based on trip visibility     - Results ordered by order_in_trip ASC (itinerary order)     - Empty list if trip has no places
  ///
  /// Parameters:
  /// * [tripId] - Trip ID to list places for
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceListResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceListResponse>> listPlacesApiV1PlacesGet({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places';
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
      r'trip_id': encodeQueryParameter(_serializers, tripId, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PlaceListResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceListResponse),
      ) as PlaceListResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceListResponse>(
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

  /// Update Place
  /// Update an existing place.      **Authentication:** Required      **Permissions:** Only trip owner can update      **Path Parameters:**     - place_id: Place UUID      **Request Body:**     All fields are optional (partial update):     - name: New place name (1-255 chars)     - place_type: New category     - lat: New latitude (-90 to 90)     - lng: New longitude (-180 to 180)     - user_notes: New notes     - user_rating: New rating (1-5)     - visit_date: New visit date     - order_in_trip: New position in itinerary      **Returns:**     Updated place      **Response Example:** &#x60;&#x60;&#x60;json     {         \&quot;id\&quot;: \&quot;123e4567-e89b-12d3-a456-426614174000\&quot;,         \&quot;name\&quot;: \&quot;Eiffel Tower - Updated\&quot;,         \&quot;user_notes\&quot;: \&quot;Updated notes\&quot;,         ...     } &#x60;&#x60;&#x60;      **Errors:**     - 400: Invalid coordinates or rating     - 401: Not authenticated     - 403: User does not own trip     - 404: Place not found      **Business Logic:**     - Only updates provided fields (partial update)     - Ownership check prevents unauthorized updates     - If lat/lng updated, Geography column automatically recalculated     - Cannot update trip_id or user_id     - updated_at timestamp automatically updated
  ///
  /// Parameters:
  /// * [placeId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [placeUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceResponse>> updatePlaceApiV1PlacesPlaceIdPatch({ 
    required String placeId,
    required String authorization,
    required PlaceUpdate placeUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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
      const _type = FullType(PlaceUpdate);
      _bodyData = _serializers.serialize(placeUpdate, specifiedType: _type);

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

    PlaceResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceResponse),
      ) as PlaceResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceResponse>(
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
