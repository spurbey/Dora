# dora_api.api.MediaApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteMediaApiV1MediaMediaIdDelete**](MediaApi.md#deletemediaapiv1mediamediaiddelete) | **DELETE** /api/v1/media/{media_id} | Delete Media
[**getMediaApiV1MediaMediaIdGet**](MediaApi.md#getmediaapiv1mediamediaidget) | **GET** /api/v1/media/{media_id} | Get Media
[**uploadMediaApiV1MediaUploadPost**](MediaApi.md#uploadmediaapiv1mediauploadpost) | **POST** /api/v1/media/upload | Upload Media


# **deleteMediaApiV1MediaMediaIdDelete**
> deleteMediaApiV1MediaMediaIdDelete(mediaId, authorization)

Delete Media

Delete media.  **Authentication:** Required  **Permissions:** Only owner can delete  **Path Parameters:** - media_id: Media UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own media - 404: Media not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Deletes file from Supabase Storage - Deletes metadata from database - Permanent deletion (no soft delete)  **Warning:** - This action is irreversible - File will be deleted from storage

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMediaApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteMediaApiV1MediaMediaIdDelete(mediaId, authorization);
} on DioException catch (e) {
    print('Exception when calling MediaApi->deleteMediaApiV1MediaMediaIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMediaApiV1MediaMediaIdGet**
> MediaResponse getMediaApiV1MediaMediaIdGet(mediaId, authorization)

Get Media

Get media detail by ID.          **Authentication:** Required          **Permissions:**     - Owner can always view     - Non-owner can view if trip is public/unlisted          **Path Parameters:**     - media_id: Media UUID          **Returns:**     Media details with file URLs          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"trip_place_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"file_url\": \"https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\",         \"thumbnail_url\": \"https://xxx.supabase.co/.../file.jpg?width=200&height=200\",         \"caption\": \"Beautiful sunset\",         \"created_at\": \"2025-01-26T10:00:00Z\"     } ```          **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Media not found          **Business Logic:**     - Access control based on parent trip's visibility     - Private trip media only visible to owner     - Public/unlisted trip media visible to anyone

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMediaApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getMediaApiV1MediaMediaIdGet(mediaId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MediaApi->getMediaApiV1MediaMediaIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**MediaResponse**](MediaResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadMediaApiV1MediaUploadPost**
> MediaResponse uploadMediaApiV1MediaUploadPost(authorization, file, tripPlaceId, caption, takenAt)

Upload Media

Upload photo to a place.          **Authentication:** Required          **Permissions:** User must own the place (via trip ownership)          **Request:**     - Content-Type: multipart/form-data     - file: Image file (required)     - trip_place_id: UUID of place (required)     - caption: Photo caption (optional, max 500 chars)     - taken_at: When photo was taken (optional, ISO datetime)          **Returns:**     Created media with file URLs          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"trip_place_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"file_url\": \"https://xxx.supabase.co/storage/v1/object/public/photos/user_id/file.jpg\",         \"file_type\": \"photo\",         \"file_size_bytes\": 245678,         \"mime_type\": \"image/jpeg\",         \"width\": 1920,         \"height\": 1080,         \"thumbnail_url\": \"https://xxx.supabase.co/.../file.jpg?width=200&height=200\",         \"caption\": \"Beautiful sunset at Eiffel Tower\",         \"taken_at\": \"2025-06-15T18:30:00Z\",         \"created_at\": \"2025-01-26T10:00:00Z\"     } ```          **Errors:**     - 400: Invalid file type or size     - 401: Not authenticated     - 403: User does not own place     - 404: Place not found          **Business Logic:**     - File stored in Supabase Storage: photos/{user_id}/{uuid}.{ext}     - Thumbnail auto-generated via Supabase transformations     - Image dimensions extracted via PIL     - Free tier: max 10MB per photo     - Premium tier: max 100MB per photo     - Allowed types: image/jpeg, image/png, image/webp

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMediaApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | Photo file to upload
final String tripPlaceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Place ID to attach media to
final String caption = caption_example; // String | 
final DateTime takenAt = 2013-10-20T19:20:30+01:00; // DateTime | 

try {
    final response = api.uploadMediaApiV1MediaUploadPost(authorization, file, tripPlaceId, caption, takenAt);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MediaApi->uploadMediaApiV1MediaUploadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **file** | **MultipartFile**| Photo file to upload | 
 **tripPlaceId** | **String**| Place ID to attach media to | 
 **caption** | **String**|  | [optional] 
 **takenAt** | **DateTime**|  | [optional] 

### Return type

[**MediaResponse**](MediaResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

