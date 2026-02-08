//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/api_util.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/place_metadata_create.dart';
import 'package:dora_api/src/model/place_metadata_response.dart';
import 'package:dora_api/src/model/place_metadata_update.dart';
import 'package:dora_api/src/model/trip_metadata_create.dart';
import 'package:dora_api/src/model/trip_metadata_response.dart';
import 'package:dora_api/src/model/trip_metadata_update.dart';

class MetadataApi {

  final Dio _dio;

  final Serializers _serializers;

  const MetadataApi(this._dio, this._serializers);

  /// Create Place Metadata
  /// Create metadata for a place.  **Authentication:** Required  **Permissions:** Place owner only  **Request Body:** - component_type: Type of component (city, place, activity, accommodation, food, transport) - experience_tags: Array of experience descriptors - best_for: Array of audience types - budget_per_person: Estimated cost per person (USD) - duration_hours: Recommended time to spend (hours) - difficulty_rating: Physical difficulty (1-5) - physical_demand: Physical demand level (low, medium, high) - best_time: Optimal time to visit - is_public: Whether place can be discovered publicly (default: false)  **Returns:** Created place metadata  **Errors:** - 404: Place not found - 403: User doesn&#39;t own this place - 409: Metadata already exists (use PATCH to update) - 422: Invalid enum values or ranges
  ///
  /// Parameters:
  /// * [placeId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [placeMetadataCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceMetadataResponse>> createPlaceMetadataApiV1PlacesPlaceIdMetadataPost({ 
    required String placeId,
    required String authorization,
    required PlaceMetadataCreate placeMetadataCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}/metadata'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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
      const _type = FullType(PlaceMetadataCreate);
      _bodyData = _serializers.serialize(placeMetadataCreate, specifiedType: _type);

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

    PlaceMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceMetadataResponse),
      ) as PlaceMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceMetadataResponse>(
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

  /// Create Trip Metadata
  /// Create metadata for a trip.  **Authentication:** Required  **Permissions:** Trip owner only  **Request Body:** - traveler_type: Array of traveler types (solo, couple, family, group) - age_group: Target age group (gen-z, millennial, gen-x, boomer) - travel_style: Array of travel styles (adventure, luxury, budget, cultural, relaxed) - difficulty_level: Overall difficulty (easy, moderate, challenging, extreme) - budget_category: Budget level (budget, mid-range, luxury) - activity_focus: Array of activity types (hiking, food, photography, nightlife, beaches) - is_discoverable: Whether trip can be found in public search (default: false) - tags: User-defined tags  **Returns:** Created trip metadata  **Errors:** - 404: Trip not found - 403: User doesn&#39;t own this trip - 409: Metadata already exists (use PATCH to update) - 422: Invalid enum values
  ///
  /// Parameters:
  /// * [tripId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [tripMetadataCreate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripMetadataResponse>> createTripMetadataApiV1TripsTripIdMetadataPost({ 
    required String tripId,
    required String authorization,
    required TripMetadataCreate tripMetadataCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}/metadata'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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
      const _type = FullType(TripMetadataCreate);
      _bodyData = _serializers.serialize(tripMetadataCreate, specifiedType: _type);

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

    TripMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripMetadataResponse),
      ) as TripMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripMetadataResponse>(
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

  /// Delete Place Metadata
  /// Delete metadata for a place.  **Authentication:** Required  **Permissions:** Place owner only  **Returns:** 204 No Content on success  **Errors:** - 404: Place or metadata not found - 403: User doesn&#39;t own this place  **Note:** Place itself is NOT deleted, only its metadata.
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
  Future<Response<void>> deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete({ 
    required String placeId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}/metadata'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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

  /// Delete Trip Metadata
  /// Delete metadata for a trip.  **Authentication:** Required  **Permissions:** Trip owner only  **Returns:** 204 No Content on success  **Errors:** - 404: Trip or metadata not found - 403: User doesn&#39;t own this trip  **Note:** Trip itself is NOT deleted, only its metadata.
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
  Future<Response<void>> deleteTripMetadataApiV1TripsTripIdMetadataDelete({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}/metadata'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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

  /// Get Place Metadata
  /// Get metadata for a place.  **Authentication:** Required  **Permissions:** - Place owner: Always allowed - Others: Only if parent trip is public or unlisted  **Returns:** Place metadata  **Errors:** - 404: Place or metadata not found - 403: Trip is private and user is not owner
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
  /// Returns a [Future] containing a [Response] with a [PlaceMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceMetadataResponse>> getPlaceMetadataApiV1PlacesPlaceIdMetadataGet({ 
    required String placeId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}/metadata'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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

    PlaceMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceMetadataResponse),
      ) as PlaceMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceMetadataResponse>(
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

  /// Get Trip Metadata
  /// Get metadata for a trip.  **Authentication:** Required  **Permissions:** - Trip owner: Always allowed - Others: Only if trip is public or unlisted  **Returns:** Trip metadata  **Errors:** - 404: Trip or metadata not found - 403: Trip is private and user is not owner
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
  /// Returns a [Future] containing a [Response] with a [TripMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripMetadataResponse>> getTripMetadataApiV1TripsTripIdMetadataGet({ 
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}/metadata'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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

    TripMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripMetadataResponse),
      ) as TripMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripMetadataResponse>(
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

  /// Update Place Metadata
  /// Update metadata for a place (partial update).  **Authentication:** Required  **Permissions:** Place owner only  **Request Body:** All fields are optional. Only provided fields will be updated.  **Returns:** Updated place metadata  **Errors:** - 404: Place or metadata not found - 403: User doesn&#39;t own this place - 422: Invalid enum values or ranges
  ///
  /// Parameters:
  /// * [placeId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [placeMetadataUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlaceMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PlaceMetadataResponse>> updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch({ 
    required String placeId,
    required String authorization,
    required PlaceMetadataUpdate placeMetadataUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/places/{place_id}/metadata'.replaceAll('{' r'place_id' '}', encodeQueryParameter(_serializers, placeId, const FullType(String)).toString());
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
      const _type = FullType(PlaceMetadataUpdate);
      _bodyData = _serializers.serialize(placeMetadataUpdate, specifiedType: _type);

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

    PlaceMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlaceMetadataResponse),
      ) as PlaceMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PlaceMetadataResponse>(
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

  /// Update Trip Metadata
  /// Update metadata for a trip (partial update).  **Authentication:** Required  **Permissions:** Trip owner only  **Request Body:** All fields are optional. Only provided fields will be updated.  **Returns:** Updated trip metadata  **Errors:** - 404: Trip or metadata not found - 403: User doesn&#39;t own this trip - 422: Invalid enum values
  ///
  /// Parameters:
  /// * [tripId] 
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [tripMetadataUpdate] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripMetadataResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripMetadataResponse>> updateTripMetadataApiV1TripsTripIdMetadataPatch({ 
    required String tripId,
    required String authorization,
    required TripMetadataUpdate tripMetadataUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/trips/{trip_id}/metadata'.replaceAll('{' r'trip_id' '}', encodeQueryParameter(_serializers, tripId, const FullType(String)).toString());
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
      const _type = FullType(TripMetadataUpdate);
      _bodyData = _serializers.serialize(tripMetadataUpdate, specifiedType: _type);

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

    TripMetadataResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripMetadataResponse),
      ) as TripMetadataResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripMetadataResponse>(
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
