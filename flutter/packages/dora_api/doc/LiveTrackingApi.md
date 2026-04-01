# dora_api.api.LiveTrackingApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost**](LiveTrackingApi.md#commitautofinalizeapiv1tripstripidautofinalizecommitpost) | **POST** /api/v1/trips/{trip_id}/auto-finalize/commit | Commit Auto Finalize
[**confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost**](LiveTrackingApi.md#confirmcheckincandidateapiv1checkinscandidateidconfirmpost) | **POST** /api/v1/checkins/{candidate_id}/confirm | Confirm Checkin Candidate
[**createTripMomentApiV1TripsTripIdMomentsPost**](LiveTrackingApi.md#createtripmomentapiv1tripstripidmomentspost) | **POST** /api/v1/trips/{trip_id}/moments | Create Trip Moment
[**deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost**](LiveTrackingApi.md#deactivatedevicetokenapiv1notificationsdevicetokensdeactivatepost) | **POST** /api/v1/notifications/device-tokens/deactivate | Deactivate Device Token
[**getTrackingPathApiV1TripsTripIdTrackingPathGet**](LiveTrackingApi.md#gettrackingpathapiv1tripstripidtrackingpathget) | **GET** /api/v1/trips/{trip_id}/tracking/path | Get Tracking Path
[**ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost**](LiveTrackingApi.md#ingesteventsbatchapiv1tripstripidtrackingeventsbatchpost) | **POST** /api/v1/trips/{trip_id}/tracking/events:batch | Ingest Events Batch
[**ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost**](LiveTrackingApi.md#ingestmediabatchapiv1tripstripidtrackingmediabatchpost) | **POST** /api/v1/trips/{trip_id}/tracking/media:batch | Ingest Media Batch
[**ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost**](LiveTrackingApi.md#ingestpointsbatchapiv1tripstripidtrackingpointsbatchpost) | **POST** /api/v1/trips/{trip_id}/tracking/points:batch | Ingest Points Batch
[**listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet**](LiveTrackingApi.md#listpendingcheckinsapiv1tripstripidcheckinspendingget) | **GET** /api/v1/trips/{trip_id}/checkins/pending | List Pending Checkins
[**listTripMomentsApiV1TripsTripIdMomentsGet**](LiveTrackingApi.md#listtripmomentsapiv1tripstripidmomentsget) | **GET** /api/v1/trips/{trip_id}/moments | List Trip Moments
[**pauseTrackingApiV1TripsTripIdTrackingPausePost**](LiveTrackingApi.md#pausetrackingapiv1tripstripidtrackingpausepost) | **POST** /api/v1/trips/{trip_id}/tracking/pause | Pause Tracking
[**registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost**](LiveTrackingApi.md#registerdevicetokenapiv1notificationsdevicetokensregisterpost) | **POST** /api/v1/notifications/device-tokens/register | Register Device Token
[**rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost**](LiveTrackingApi.md#rejectcheckincandidateapiv1checkinscandidateidrejectpost) | **POST** /api/v1/checkins/{candidate_id}/reject | Reject Checkin Candidate
[**resumeTrackingApiV1TripsTripIdTrackingResumePost**](LiveTrackingApi.md#resumetrackingapiv1tripstripidtrackingresumepost) | **POST** /api/v1/trips/{trip_id}/tracking/resume | Resume Tracking
[**snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost**](LiveTrackingApi.md#snoozecheckincandidateapiv1checkinscandidateidsnoozepost) | **POST** /api/v1/checkins/{candidate_id}/snooze | Snooze Checkin Candidate
[**startTrackingApiV1TripsTripIdTrackingStartPost**](LiveTrackingApi.md#starttrackingapiv1tripstripidtrackingstartpost) | **POST** /api/v1/trips/{trip_id}/tracking/start | Start Tracking
[**stopTrackingApiV1TripsTripIdTrackingStopPost**](LiveTrackingApi.md#stoptrackingapiv1tripstripidtrackingstoppost) | **POST** /api/v1/trips/{trip_id}/tracking/stop | Stop Tracking
[**updateTripMomentApiV1MomentsMomentIdPatch**](LiveTrackingApi.md#updatetripmomentapiv1momentsmomentidpatch) | **PATCH** /api/v1/moments/{moment_id} | Update Trip Moment
[**uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost**](LiveTrackingApi.md#uploadtrackingmediabinaryapiv1tripstripidtrackingmediauploadpost) | **POST** /api/v1/trips/{trip_id}/tracking/media:upload | Upload Tracking Media Binary


# **commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost**
> AutoFinalizeCommitResponse commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost(tripId, xIdempotencyKey, authorization, autoFinalizeCommitRequest)

Commit Auto Finalize

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final AutoFinalizeCommitRequest autoFinalizeCommitRequest = ; // AutoFinalizeCommitRequest | 

try {
    final response = api.commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost(tripId, xIdempotencyKey, authorization, autoFinalizeCommitRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **autoFinalizeCommitRequest** | [**AutoFinalizeCommitRequest**](AutoFinalizeCommitRequest.md)|  | 

### Return type

[**AutoFinalizeCommitResponse**](AutoFinalizeCommitResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost**
> CheckinActionResponse confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost(candidateId, xIdempotencyKey, authorization, checkinConfirmRequest)

Confirm Checkin Candidate

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String candidateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final CheckinConfirmRequest checkinConfirmRequest = ; // CheckinConfirmRequest | 

try {
    final response = api.confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost(candidateId, xIdempotencyKey, authorization, checkinConfirmRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **candidateId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **checkinConfirmRequest** | [**CheckinConfirmRequest**](CheckinConfirmRequest.md)|  | 

### Return type

[**CheckinActionResponse**](CheckinActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTripMomentApiV1TripsTripIdMomentsPost**
> MomentResponse createTripMomentApiV1TripsTripIdMomentsPost(tripId, xIdempotencyKey, authorization, momentCreateRequest)

Create Trip Moment

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final MomentCreateRequest momentCreateRequest = ; // MomentCreateRequest | 

try {
    final response = api.createTripMomentApiV1TripsTripIdMomentsPost(tripId, xIdempotencyKey, authorization, momentCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->createTripMomentApiV1TripsTripIdMomentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **momentCreateRequest** | [**MomentCreateRequest**](MomentCreateRequest.md)|  | 

### Return type

[**MomentResponse**](MomentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost**
> DeviceTokenActionResponse deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost(xIdempotencyKey, authorization, deviceTokenDeactivateRequest)

Deactivate Device Token

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final DeviceTokenDeactivateRequest deviceTokenDeactivateRequest = ; // DeviceTokenDeactivateRequest | 

try {
    final response = api.deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost(xIdempotencyKey, authorization, deviceTokenDeactivateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **deviceTokenDeactivateRequest** | [**DeviceTokenDeactivateRequest**](DeviceTokenDeactivateRequest.md)|  | 

### Return type

[**DeviceTokenActionResponse**](DeviceTokenActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTrackingPathApiV1TripsTripIdTrackingPathGet**
> TrackingPathResponse getTrackingPathApiV1TripsTripIdTrackingPathGet(tripId, authorization, sessionId, limit)

Get Tracking Path

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String sessionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int limit = 56; // int | 

try {
    final response = api.getTrackingPathApiV1TripsTripIdTrackingPathGet(tripId, authorization, sessionId, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->getTrackingPathApiV1TripsTripIdTrackingPathGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **sessionId** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 5000]

### Return type

[**TrackingPathResponse**](TrackingPathResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost**
> TrackingEventsBatchResponse ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost(tripId, xIdempotencyKey, authorization, trackingEventsBatchRequest)

Ingest Events Batch

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingEventsBatchRequest trackingEventsBatchRequest = ; // TrackingEventsBatchRequest | 

try {
    final response = api.ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost(tripId, xIdempotencyKey, authorization, trackingEventsBatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingEventsBatchRequest** | [**TrackingEventsBatchRequest**](TrackingEventsBatchRequest.md)|  | 

### Return type

[**TrackingEventsBatchResponse**](TrackingEventsBatchResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost**
> TrackingMediaBatchResponse ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost(tripId, xIdempotencyKey, authorization, trackingMediaBatchRequest)

Ingest Media Batch

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingMediaBatchRequest trackingMediaBatchRequest = ; // TrackingMediaBatchRequest | 

try {
    final response = api.ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost(tripId, xIdempotencyKey, authorization, trackingMediaBatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingMediaBatchRequest** | [**TrackingMediaBatchRequest**](TrackingMediaBatchRequest.md)|  | 

### Return type

[**TrackingMediaBatchResponse**](TrackingMediaBatchResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost**
> TrackingPointsBatchResponse ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost(tripId, xIdempotencyKey, authorization, trackingPointsBatchRequest)

Ingest Points Batch

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingPointsBatchRequest trackingPointsBatchRequest = ; // TrackingPointsBatchRequest | 

try {
    final response = api.ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost(tripId, xIdempotencyKey, authorization, trackingPointsBatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingPointsBatchRequest** | [**TrackingPointsBatchRequest**](TrackingPointsBatchRequest.md)|  | 

### Return type

[**TrackingPointsBatchResponse**](TrackingPointsBatchResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet**
> PendingCheckinsResponse listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet(tripId, authorization)

List Pending Checkins

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**PendingCheckinsResponse**](PendingCheckinsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTripMomentsApiV1TripsTripIdMomentsGet**
> MomentListResponse listTripMomentsApiV1TripsTripIdMomentsGet(tripId, authorization)

List Trip Moments

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.listTripMomentsApiV1TripsTripIdMomentsGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->listTripMomentsApiV1TripsTripIdMomentsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**MomentListResponse**](MomentListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pauseTrackingApiV1TripsTripIdTrackingPausePost**
> TrackingSessionResponse pauseTrackingApiV1TripsTripIdTrackingPausePost(tripId, xIdempotencyKey, authorization, trackingPauseRequest)

Pause Tracking

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingPauseRequest trackingPauseRequest = ; // TrackingPauseRequest | 

try {
    final response = api.pauseTrackingApiV1TripsTripIdTrackingPausePost(tripId, xIdempotencyKey, authorization, trackingPauseRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->pauseTrackingApiV1TripsTripIdTrackingPausePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingPauseRequest** | [**TrackingPauseRequest**](TrackingPauseRequest.md)|  | 

### Return type

[**TrackingSessionResponse**](TrackingSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost**
> DeviceTokenActionResponse registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost(xIdempotencyKey, authorization, deviceTokenRegisterRequest)

Register Device Token

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final DeviceTokenRegisterRequest deviceTokenRegisterRequest = ; // DeviceTokenRegisterRequest | 

try {
    final response = api.registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost(xIdempotencyKey, authorization, deviceTokenRegisterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **deviceTokenRegisterRequest** | [**DeviceTokenRegisterRequest**](DeviceTokenRegisterRequest.md)|  | 

### Return type

[**DeviceTokenActionResponse**](DeviceTokenActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost**
> CheckinActionResponse rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost(candidateId, xIdempotencyKey, authorization, checkinRejectRequest)

Reject Checkin Candidate

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String candidateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final CheckinRejectRequest checkinRejectRequest = ; // CheckinRejectRequest | 

try {
    final response = api.rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost(candidateId, xIdempotencyKey, authorization, checkinRejectRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **candidateId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **checkinRejectRequest** | [**CheckinRejectRequest**](CheckinRejectRequest.md)|  | 

### Return type

[**CheckinActionResponse**](CheckinActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resumeTrackingApiV1TripsTripIdTrackingResumePost**
> TrackingSessionResponse resumeTrackingApiV1TripsTripIdTrackingResumePost(tripId, xIdempotencyKey, authorization, trackingResumeRequest)

Resume Tracking

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingResumeRequest trackingResumeRequest = ; // TrackingResumeRequest | 

try {
    final response = api.resumeTrackingApiV1TripsTripIdTrackingResumePost(tripId, xIdempotencyKey, authorization, trackingResumeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->resumeTrackingApiV1TripsTripIdTrackingResumePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingResumeRequest** | [**TrackingResumeRequest**](TrackingResumeRequest.md)|  | 

### Return type

[**TrackingSessionResponse**](TrackingSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost**
> CheckinActionResponse snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost(candidateId, xIdempotencyKey, authorization, checkinSnoozeRequest)

Snooze Checkin Candidate

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String candidateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final CheckinSnoozeRequest checkinSnoozeRequest = ; // CheckinSnoozeRequest | 

try {
    final response = api.snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost(candidateId, xIdempotencyKey, authorization, checkinSnoozeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **candidateId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **checkinSnoozeRequest** | [**CheckinSnoozeRequest**](CheckinSnoozeRequest.md)|  | 

### Return type

[**CheckinActionResponse**](CheckinActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startTrackingApiV1TripsTripIdTrackingStartPost**
> TrackingSessionResponse startTrackingApiV1TripsTripIdTrackingStartPost(tripId, xIdempotencyKey, authorization, trackingStartRequest)

Start Tracking

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingStartRequest trackingStartRequest = ; // TrackingStartRequest | 

try {
    final response = api.startTrackingApiV1TripsTripIdTrackingStartPost(tripId, xIdempotencyKey, authorization, trackingStartRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->startTrackingApiV1TripsTripIdTrackingStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingStartRequest** | [**TrackingStartRequest**](TrackingStartRequest.md)|  | 

### Return type

[**TrackingSessionResponse**](TrackingSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stopTrackingApiV1TripsTripIdTrackingStopPost**
> TrackingSessionResponse stopTrackingApiV1TripsTripIdTrackingStopPost(tripId, xIdempotencyKey, authorization, trackingStopRequest)

Stop Tracking

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TrackingStopRequest trackingStopRequest = ; // TrackingStopRequest | 

try {
    final response = api.stopTrackingApiV1TripsTripIdTrackingStopPost(tripId, xIdempotencyKey, authorization, trackingStopRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->stopTrackingApiV1TripsTripIdTrackingStopPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **trackingStopRequest** | [**TrackingStopRequest**](TrackingStopRequest.md)|  | 

### Return type

[**TrackingSessionResponse**](TrackingSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTripMomentApiV1MomentsMomentIdPatch**
> MomentResponse updateTripMomentApiV1MomentsMomentIdPatch(momentId, xIdempotencyKey, authorization, momentUpdateRequest)

Update Trip Moment

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String momentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xIdempotencyKey = xIdempotencyKey_example; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final MomentUpdateRequest momentUpdateRequest = ; // MomentUpdateRequest | 

try {
    final response = api.updateTripMomentApiV1MomentsMomentIdPatch(momentId, xIdempotencyKey, authorization, momentUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->updateTripMomentApiV1MomentsMomentIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **momentId** | **String**|  | 
 **xIdempotencyKey** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **momentUpdateRequest** | [**MomentUpdateRequest**](MomentUpdateRequest.md)|  | 

### Return type

[**MomentResponse**](MomentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost**
> TrackingMediaUploadResponse uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost(tripId, authorization, file)

Upload Tracking Media Binary

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getLiveTrackingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | Tracking media file

try {
    final response = api.uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost(tripId, authorization, file);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LiveTrackingApi->uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **file** | **MultipartFile**| Tracking media file | 

### Return type

[**TrackingMediaUploadResponse**](TrackingMediaUploadResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

