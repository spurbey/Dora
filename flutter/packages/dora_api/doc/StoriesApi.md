# dora_api.api.StoriesApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteStoryApiV1StoriesStoryIdDelete**](StoriesApi.md#deletestoryapiv1storiesstoryiddelete) | **DELETE** /api/v1/stories/{story_id} | Delete Story
[**getStoryApiV1StoriesStoryIdGet**](StoriesApi.md#getstoryapiv1storiesstoryidget) | **GET** /api/v1/stories/{story_id} | Get Story
[**getStoryFeedApiV1StoriesFeedGet**](StoriesApi.md#getstoryfeedapiv1storiesfeedget) | **GET** /api/v1/stories/feed | Get Story Feed
[**markStoryViewedApiV1StoriesStoryIdViewPost**](StoriesApi.md#markstoryviewedapiv1storiesstoryidviewpost) | **POST** /api/v1/stories/{story_id}/view | Mark Story Viewed
[**moderationHideStoryApiV1StoriesStoryIdModerationHidePost**](StoriesApi.md#moderationhidestoryapiv1storiesstoryidmoderationhidepost) | **POST** /api/v1/stories/{story_id}/moderation-hide | Moderation Hide Story
[**muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost**](StoriesApi.md#mutestoryauthorapiv1storiesauthorsauthoridmutepost) | **POST** /api/v1/stories/authors/{author_id}/mute | Mute Story Author
[**publishStoryApiV1StoriesPublishPost**](StoriesApi.md#publishstoryapiv1storiespublishpost) | **POST** /api/v1/stories/publish | Publish Story
[**reportStoryApiV1StoriesStoryIdReportPost**](StoriesApi.md#reportstoryapiv1storiesstoryidreportpost) | **POST** /api/v1/stories/{story_id}/report | Report Story


# **deleteStoryApiV1StoriesStoryIdDelete**
> StoryResponse deleteStoryApiV1StoriesStoryIdDelete(storyId, authorization)

Delete Story

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String storyId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.deleteStoryApiV1StoriesStoryIdDelete(storyId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->deleteStoryApiV1StoriesStoryIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storyId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**StoryResponse**](StoryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStoryApiV1StoriesStoryIdGet**
> StoryResponse getStoryApiV1StoriesStoryIdGet(storyId, authorization)

Get Story

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String storyId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getStoryApiV1StoriesStoryIdGet(storyId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->getStoryApiV1StoriesStoryIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storyId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**StoryResponse**](StoryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStoryFeedApiV1StoriesFeedGet**
> StoryFeedResponse getStoryFeedApiV1StoriesFeedGet(authorization, lat, lng, radiusKm, cursor, limit)

Get Story Feed

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final num lat = 8.14; // num | 
final num lng = 8.14; // num | 
final String radiusKm = radiusKm_example; // String | 1 | 5 | 25 | all
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.getStoryFeedApiV1StoriesFeedGet(authorization, lat, lng, radiusKm, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->getStoryFeedApiV1StoriesFeedGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **lat** | **num**|  | [optional] 
 **lng** | **num**|  | [optional] 
 **radiusKm** | **String**| 1 | 5 | 25 | all | [optional] [default to '5']
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**StoryFeedResponse**](StoryFeedResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markStoryViewedApiV1StoriesStoryIdViewPost**
> StoryResponse markStoryViewedApiV1StoriesStoryIdViewPost(storyId, authorization)

Mark Story Viewed

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String storyId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.markStoryViewedApiV1StoriesStoryIdViewPost(storyId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->markStoryViewedApiV1StoriesStoryIdViewPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storyId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**StoryResponse**](StoryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **moderationHideStoryApiV1StoriesStoryIdModerationHidePost**
> StoryModerationResponse moderationHideStoryApiV1StoriesStoryIdModerationHidePost(storyId, authorization)

Moderation Hide Story

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String storyId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.moderationHideStoryApiV1StoriesStoryIdModerationHidePost(storyId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->moderationHideStoryApiV1StoriesStoryIdModerationHidePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storyId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**StoryModerationResponse**](StoryModerationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost**
> StoryMuteResponse muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost(authorId, authorization)

Mute Story Author

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String authorId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost(authorId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**StoryMuteResponse**](StoryMuteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishStoryApiV1StoriesPublishPost**
> StoryResponse publishStoryApiV1StoriesPublishPost(authorization, clientStoryId, mediaType, centerLat, centerLng, file, durationMs)

Publish Story

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final String clientStoryId = clientStoryId_example; // String | 
final String mediaType = mediaType_example; // String | photo | video
final num centerLat = 8.14; // num | 
final num centerLng = 8.14; // num | 
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 
final int durationMs = 56; // int | 

try {
    final response = api.publishStoryApiV1StoriesPublishPost(authorization, clientStoryId, mediaType, centerLat, centerLng, file, durationMs);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->publishStoryApiV1StoriesPublishPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **clientStoryId** | **String**|  | 
 **mediaType** | **String**| photo | video | 
 **centerLat** | **num**|  | 
 **centerLng** | **num**|  | 
 **file** | **MultipartFile**|  | 
 **durationMs** | **int**|  | [optional] 

### Return type

[**StoryResponse**](StoryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportStoryApiV1StoriesStoryIdReportPost**
> JsonObject reportStoryApiV1StoriesStoryIdReportPost(storyId, authorization, storyReportRequest)

Report Story

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getStoriesApi();
final String storyId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final StoryReportRequest storyReportRequest = ; // StoryReportRequest | 

try {
    final response = api.reportStoryApiV1StoriesStoryIdReportPost(storyId, authorization, storyReportRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling StoriesApi->reportStoryApiV1StoriesStoryIdReportPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storyId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **storyReportRequest** | [**StoryReportRequest**](StoryReportRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

