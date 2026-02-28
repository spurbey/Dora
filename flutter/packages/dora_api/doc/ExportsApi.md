# dora_api.api.ExportsApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelExportApiV1ExportsJobIdCancelPost**](ExportsApi.md#cancelexportapiv1exportsjobidcancelpost) | **POST** /api/v1/exports/{job_id}/cancel | Cancel Export
[**createExportApiV1TripsTripIdExportPost**](ExportsApi.md#createexportapiv1tripstripidexportpost) | **POST** /api/v1/trips/{trip_id}/export | Create Export
[**getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet**](ExportsApi.md#getexportdownloadurlapiv1exportsjobiddownloadurlget) | **GET** /api/v1/exports/{job_id}/download-url | Get Export Download Url
[**getExportShareUrlApiV1ExportsJobIdShareGet**](ExportsApi.md#getexportshareurlapiv1exportsjobidshareget) | **GET** /api/v1/exports/{job_id}/share | Get Export Share Url
[**getExportStatusApiV1ExportsJobIdGet**](ExportsApi.md#getexportstatusapiv1exportsjobidget) | **GET** /api/v1/exports/{job_id} | Get Export Status


# **cancelExportApiV1ExportsJobIdCancelPost**
> ExportCancelResponse cancelExportApiV1ExportsJobIdCancelPost(jobId, authorization)

Cancel Export

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getExportsApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.cancelExportApiV1ExportsJobIdCancelPost(jobId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->cancelExportApiV1ExportsJobIdCancelPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**ExportCancelResponse**](ExportCancelResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExportApiV1TripsTripIdExportPost**
> ExportCreateResponse createExportApiV1TripsTripIdExportPost(tripId, authorization, exportCreateRequest)

Create Export

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getExportsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final ExportCreateRequest exportCreateRequest = ; // ExportCreateRequest | 

try {
    final response = api.createExportApiV1TripsTripIdExportPost(tripId, authorization, exportCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->createExportApiV1TripsTripIdExportPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **exportCreateRequest** | [**ExportCreateRequest**](ExportCreateRequest.md)|  | 

### Return type

[**ExportCreateResponse**](ExportCreateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet**
> ExportDownloadUrlResponse getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet(jobId, authorization)

Get Export Download Url

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getExportsApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet(jobId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**ExportDownloadUrlResponse**](ExportDownloadUrlResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExportShareUrlApiV1ExportsJobIdShareGet**
> ExportShareUrlResponse getExportShareUrlApiV1ExportsJobIdShareGet(jobId, authorization)

Get Export Share Url

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getExportsApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getExportShareUrlApiV1ExportsJobIdShareGet(jobId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->getExportShareUrlApiV1ExportsJobIdShareGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**ExportShareUrlResponse**](ExportShareUrlResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExportStatusApiV1ExportsJobIdGet**
> ExportStatusResponse getExportStatusApiV1ExportsJobIdGet(jobId, authorization)

Get Export Status

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getExportsApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getExportStatusApiV1ExportsJobIdGet(jobId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->getExportStatusApiV1ExportsJobIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**ExportStatusResponse**](ExportStatusResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

