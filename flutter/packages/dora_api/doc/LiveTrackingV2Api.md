# dora_api.api.LiveTrackingV2Api

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getV2RouteApiV2TripsTripIdRouteGet**](LiveTrackingV2Api.md#getv2routeapiv2tripstripidrouteget) | **GET** /api/v2/trips/{trip_id}/route | Get V2 Route
[**getV2TimelineApiV2TripsTripIdTimelineGet**](LiveTrackingV2Api.md#getv2timelineapiv2tripstripidtimelineget) | **GET** /api/v2/trips/{trip_id}/timeline | Get V2 Timeline
[**publishCommitApiV2TripsTripIdPublishCommitPost**](LiveTrackingV2Api.md#publishcommitapiv2tripstripidpublishcommitpost) | **POST** /api/v2/trips/{trip_id}/publish:commit | Publish Commit
[**publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost**](LiveTrackingV2Api.md#publishmediacompleteapiv2tripstripidpublishmediacompletepost) | **POST** /api/v2/trips/{trip_id}/publish:media-complete | Publish Media Complete
[**publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost**](LiveTrackingV2Api.md#publishpayloadchunkapiv2tripstripidpublishpayloadchunkpost) | **POST** /api/v2/trips/{trip_id}/publish:payload-chunk | Publish Payload Chunk
[**publishStartApiV2TripsTripIdPublishStartPost**](LiveTrackingV2Api.md#publishstartapiv2tripstripidpublishstartpost) | **POST** /api/v2/trips/{trip_id}/publish:start | Publish Start
[**startV2SessionApiV2TripsTripIdSessionsStartPost**](LiveTrackingV2Api.md#startv2sessionapiv2tripstripidsessionsstartpost) | **POST** /api/v2/trips/{trip_id}/sessions:start | Start V2 Session
[**stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost**](LiveTrackingV2Api.md#stopv2sessionapiv2tripstripidsessionsclientsessionidstoppost) | **POST** /api/v2/trips/{trip_id}/sessions/{client_session_id}:stop | Stop V2 Session


# **getV2RouteApiV2TripsTripIdRouteGet**
> V2RouteResponse getV2RouteApiV2TripsTripIdRouteGet(tripId, authorization, cursor, limitSegments)

Get V2 Route

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String cursor = cursor_example; // String | 
final int limitSegments = 56; // int | 

try {
    final response = api.getV2RouteApiV2TripsTripIdRouteGet(tripId, authorization, cursor, limitSegments);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->getV2RouteApiV2TripsTripIdRouteGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **cursor** | **String**|  | [optional] 
 **limitSegments** | **int**|  | [optional] [default to 10]

### Return type

[**V2RouteResponse**](V2RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getV2TimelineApiV2TripsTripIdTimelineGet**
> V2TimelineResponse getV2TimelineApiV2TripsTripIdTimelineGet(tripId, authorization, cursor, limit)

Get V2 Timeline

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.getV2TimelineApiV2TripsTripIdTimelineGet(tripId, authorization, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->getV2TimelineApiV2TripsTripIdTimelineGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]

### Return type

[**V2TimelineResponse**](V2TimelineResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishCommitApiV2TripsTripIdPublishCommitPost**
> V2PublishCommitResponse publishCommitApiV2TripsTripIdPublishCommitPost(tripId, authorization, v2PublishCommitRequest, idempotencyKey)

Publish Commit

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2PublishCommitRequest v2PublishCommitRequest = ; // V2PublishCommitRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.publishCommitApiV2TripsTripIdPublishCommitPost(tripId, authorization, v2PublishCommitRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->publishCommitApiV2TripsTripIdPublishCommitPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2PublishCommitRequest** | [**V2PublishCommitRequest**](V2PublishCommitRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2PublishCommitResponse**](V2PublishCommitResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost**
> V2PublishMediaCompleteResponse publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost(tripId, authorization, v2PublishMediaCompleteRequest, idempotencyKey)

Publish Media Complete

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2PublishMediaCompleteRequest v2PublishMediaCompleteRequest = ; // V2PublishMediaCompleteRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost(tripId, authorization, v2PublishMediaCompleteRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2PublishMediaCompleteRequest** | [**V2PublishMediaCompleteRequest**](V2PublishMediaCompleteRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2PublishMediaCompleteResponse**](V2PublishMediaCompleteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost**
> V2PublishPayloadChunkResponse publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost(tripId, authorization, v2PublishPayloadChunkRequest, idempotencyKey)

Publish Payload Chunk

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2PublishPayloadChunkRequest v2PublishPayloadChunkRequest = ; // V2PublishPayloadChunkRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost(tripId, authorization, v2PublishPayloadChunkRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2PublishPayloadChunkRequest** | [**V2PublishPayloadChunkRequest**](V2PublishPayloadChunkRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2PublishPayloadChunkResponse**](V2PublishPayloadChunkResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishStartApiV2TripsTripIdPublishStartPost**
> V2PublishStartResponse publishStartApiV2TripsTripIdPublishStartPost(tripId, authorization, v2PublishStartRequest, idempotencyKey)

Publish Start

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2PublishStartRequest v2PublishStartRequest = ; // V2PublishStartRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.publishStartApiV2TripsTripIdPublishStartPost(tripId, authorization, v2PublishStartRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->publishStartApiV2TripsTripIdPublishStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2PublishStartRequest** | [**V2PublishStartRequest**](V2PublishStartRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2PublishStartResponse**](V2PublishStartResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startV2SessionApiV2TripsTripIdSessionsStartPost**
> V2SessionResponse startV2SessionApiV2TripsTripIdSessionsStartPost(tripId, authorization, v2SessionStartRequest, idempotencyKey)

Start V2 Session

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2SessionStartRequest v2SessionStartRequest = ; // V2SessionStartRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.startV2SessionApiV2TripsTripIdSessionsStartPost(tripId, authorization, v2SessionStartRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->startV2SessionApiV2TripsTripIdSessionsStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2SessionStartRequest** | [**V2SessionStartRequest**](V2SessionStartRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2SessionResponse**](V2SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost**
> V2SessionResponse stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost(tripId, clientSessionId, authorization, v2SessionStopRequest, idempotencyKey)

Stop V2 Session

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingV2Api();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String clientSessionId = clientSessionId_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final V2SessionStopRequest v2SessionStopRequest = ; // V2SessionStopRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost(tripId, clientSessionId, authorization, v2SessionStopRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingV2Api->stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **clientSessionId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **v2SessionStopRequest** | [**V2SessionStopRequest**](V2SessionStopRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**V2SessionResponse**](V2SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

