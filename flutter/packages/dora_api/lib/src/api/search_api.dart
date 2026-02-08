//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:dora_api/src/api_util.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/search_response.dart';

class SearchApi {

  final Dio _dio;

  final Serializers _serializers;

  const SearchApi(this._dio, this._serializers);

  /// Search Places
  /// Search for places from multiple sources.  **Authentication:** Required  **Strategy:** - Searches local database first (user-contributed places) - Falls back to Foursquare API if needed - Deduplicates results (local priority) - Ranks by relevance score - Logs search event for learning  **Query Parameters:** - &#x60;query&#x60;: Search text (e.g., \&quot;coffee shop\&quot;) - &#x60;lat&#x60;: Search center latitude - &#x60;lng&#x60;: Search center longitude - &#x60;radius_km&#x60;: Search radius in kilometers (default: 5.0) - &#x60;limit&#x60;: Maximum results to return (default: 10) - &#x60;debug&#x60;: Include score breakdown in results (default: false)  **Response:** - &#x60;results&#x60;: List of ranked results with scores - &#x60;count&#x60;: Number of results returned - &#x60;query&#x60;: Original search query (echoed back)  **Errors:** - 400: Invalid parameters (bad coordinates, empty query) - 401: Not authenticated - 500: Internal server error
  ///
  /// Parameters:
  /// * [query] - Search text
  /// * [lat] - Search center latitude
  /// * [lng] - Search center longitude
  /// * [authorization] - Bearer token from Supabase Auth
  /// * [radiusKm] - Search radius in km
  /// * [limit] - Max results
  /// * [debug] - Include score breakdown
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SearchResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SearchResponse>> searchPlacesApiV1SearchPlacesGet({ 
    required String query,
    required num lat,
    required num lng,
    required String authorization,
    num? radiusKm = 5.0,
    int? limit = 10,
    bool? debug = false,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/search/places';
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
      r'query': encodeQueryParameter(_serializers, query, const FullType(String)),
      r'lat': encodeQueryParameter(_serializers, lat, const FullType(num)),
      r'lng': encodeQueryParameter(_serializers, lng, const FullType(num)),
      if (radiusKm != null) r'radius_km': encodeQueryParameter(_serializers, radiusKm, const FullType(num)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (debug != null) r'debug': encodeQueryParameter(_serializers, debug, const FullType(bool)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SearchResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SearchResponse),
      ) as SearchResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SearchResponse>(
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
