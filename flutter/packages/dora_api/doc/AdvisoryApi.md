# dora_api.api.AdvisoryApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**answerConversationQuestionApiV1TripsTripIdConversationAnswerPost**](AdvisoryApi.md#answerconversationquestionapiv1tripstripidconversationanswerpost) | **POST** /api/v1/trips/{trip_id}/conversation/answer | Answer Conversation Question
[**getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet**](AdvisoryApi.md#getadvisorystateapiv1tripstripidadvisorystateget) | **GET** /api/v1/trips/{trip_id}/advisory/state | Get Advisory State
[**listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet**](AdvisoryApi.md#listadvisoryinsightsapiv1tripstripidadvisoryinsightsget) | **GET** /api/v1/trips/{trip_id}/advisory/insights | List Advisory Insights
[**listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet**](AdvisoryApi.md#listadvisoryjobsapiv1tripstripidadvisoryjobsget) | **GET** /api/v1/trips/{trip_id}/advisory/jobs | List Advisory Jobs
[**listConversationMessagesApiV1TripsTripIdConversationMessagesGet**](AdvisoryApi.md#listconversationmessagesapiv1tripstripidconversationmessagesget) | **GET** /api/v1/trips/{trip_id}/conversation/messages | List Conversation Messages
[**pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost**](AdvisoryApi.md#pauseadvisoryapiv1tripstripidadvisorypausepost) | **POST** /api/v1/trips/{trip_id}/advisory/pause | Pause Advisory
[**queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost**](AdvisoryApi.md#queryadvisoryapiv1tripstripidadvisoryquerypost) | **POST** /api/v1/trips/{trip_id}/advisory/query | Query Advisory
[**recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost**](AdvisoryApi.md#recordadvisoryactionapiv1advisoryadvisoryidactionpost) | **POST** /api/v1/advisory/{advisory_id}/action | Record Advisory Action
[**resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost**](AdvisoryApi.md#resumeadvisoryapiv1tripstripidadvisoryresumepost) | **POST** /api/v1/trips/{trip_id}/advisory/resume | Resume Advisory
[**sendConversationMessageApiV1TripsTripIdConversationSendPost**](AdvisoryApi.md#sendconversationmessageapiv1tripstripidconversationsendpost) | **POST** /api/v1/trips/{trip_id}/conversation/send | Send Conversation Message
[**startAdvisoryApiV1TripsTripIdAdvisoryStartPost**](AdvisoryApi.md#startadvisoryapiv1tripstripidadvisorystartpost) | **POST** /api/v1/trips/{trip_id}/advisory/start | Start Advisory


# **answerConversationQuestionApiV1TripsTripIdConversationAnswerPost**
> AnswerQuestionResponse answerConversationQuestionApiV1TripsTripIdConversationAnswerPost(tripId, authorization, answerQuestionRequest)

Answer Conversation Question

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final AnswerQuestionRequest answerQuestionRequest = ; // AnswerQuestionRequest | 

try {
    final response = api.answerConversationQuestionApiV1TripsTripIdConversationAnswerPost(tripId, authorization, answerQuestionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->answerConversationQuestionApiV1TripsTripIdConversationAnswerPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **answerQuestionRequest** | [**AnswerQuestionRequest**](AnswerQuestionRequest.md)|  | 

### Return type

[**AnswerQuestionResponse**](AnswerQuestionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet**
> JsonObject getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet(tripId, authorization)

Get Advisory State

Return sanitized brain state for debugging.  Gated: requires owner + settings.EXPOSE_ADVISORY_STATE_ENDPOINT.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet**
> AdvisoryInsightListResponse listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet(tripId, authorization, category, page, pageSize)

List Advisory Insights

Get advisories for inbox: status IN ('pending', 'delivered').

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String category = category_example; // String | 
final int page = 56; // int | 
final int pageSize = 56; // int | 

try {
    final response = api.listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet(tripId, authorization, category, page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **category** | **String**|  | [optional] 
 **page** | **int**|  | [optional] [default to 1]
 **pageSize** | **int**|  | [optional] [default to 50]

### Return type

[**AdvisoryInsightListResponse**](AdvisoryInsightListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet**
> AdvisoryJobListResponse listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet(tripId, authorization, status, page, pageSize)

List Advisory Jobs

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String status = status_example; // String | 
final int page = 56; // int | 
final int pageSize = 56; // int | 

try {
    final response = api.listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet(tripId, authorization, status, page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **status** | **String**|  | [optional] 
 **page** | **int**|  | [optional] [default to 1]
 **pageSize** | **int**|  | [optional] [default to 20]

### Return type

[**AdvisoryJobListResponse**](AdvisoryJobListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listConversationMessagesApiV1TripsTripIdConversationMessagesGet**
> ConversationListResponse listConversationMessagesApiV1TripsTripIdConversationMessagesGet(tripId, authorization, limit, before)

List Conversation Messages

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final int limit = 56; // int | 
final DateTime before = 2013-10-20T19:20:30+01:00; // DateTime | 

try {
    final response = api.listConversationMessagesApiV1TripsTripIdConversationMessagesGet(tripId, authorization, limit, before);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->listConversationMessagesApiV1TripsTripIdConversationMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **limit** | **int**|  | [optional] [default to 50]
 **before** | **DateTime**|  | [optional] 

### Return type

[**ConversationListResponse**](ConversationListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost**
> pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost(tripId, authorization)

Pause Advisory

Manually pause the advisory brain for this trip (reason='user').  Manual pauses are sticky: only an explicit resume call clears them; incoming advisory actions won't auto-resume the pipeline.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost(tripId, authorization);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost**
> AdvisoryJobResponse queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost(tripId, authorization, advisoryQueryRequest)

Query Advisory

Submit a natural-language query. Intent parsing happens in the worker, not here.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final AdvisoryQueryRequest advisoryQueryRequest = ; // AdvisoryQueryRequest | 

try {
    final response = api.queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost(tripId, authorization, advisoryQueryRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **advisoryQueryRequest** | [**AdvisoryQueryRequest**](AdvisoryQueryRequest.md)|  | 

### Return type

[**AdvisoryJobResponse**](AdvisoryJobResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost**
> AdvisoryActionResponse recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost(advisoryId, authorization, advisoryActionRequest)

Record Advisory Action

Record a user engagement action (append-only) and update the brain.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String advisoryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final AdvisoryActionRequest advisoryActionRequest = ; // AdvisoryActionRequest | 

try {
    final response = api.recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost(advisoryId, authorization, advisoryActionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **advisoryId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **advisoryActionRequest** | [**AdvisoryActionRequest**](AdvisoryActionRequest.md)|  | 

### Return type

[**AdvisoryActionResponse**](AdvisoryActionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost**
> resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost(tripId, authorization)

Resume Advisory

Explicit user resume — clears manual pauses.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost(tripId, authorization);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendConversationMessageApiV1TripsTripIdConversationSendPost**
> SendMessageResponse sendConversationMessageApiV1TripsTripIdConversationSendPost(tripId, authorization, sendMessageRequest)

Send Conversation Message

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final SendMessageRequest sendMessageRequest = ; // SendMessageRequest | 

try {
    final response = api.sendConversationMessageApiV1TripsTripIdConversationSendPost(tripId, authorization, sendMessageRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->sendConversationMessageApiV1TripsTripIdConversationSendPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **sendMessageRequest** | [**SendMessageRequest**](SendMessageRequest.md)|  | 

### Return type

[**SendMessageResponse**](SendMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startAdvisoryApiV1TripsTripIdAdvisoryStartPost**
> AdvisoryJobResponse startAdvisoryApiV1TripsTripIdAdvisoryStartPost(tripId, authorization, advisoryStartRequest)

Start Advisory

Create a pre_trip or location_trigger advisory job.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAdvisoryApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final AdvisoryStartRequest advisoryStartRequest = ; // AdvisoryStartRequest | 

try {
    final response = api.startAdvisoryApiV1TripsTripIdAdvisoryStartPost(tripId, authorization, advisoryStartRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdvisoryApi->startAdvisoryApiV1TripsTripIdAdvisoryStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **advisoryStartRequest** | [**AdvisoryStartRequest**](AdvisoryStartRequest.md)|  | 

### Return type

[**AdvisoryJobResponse**](AdvisoryJobResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

