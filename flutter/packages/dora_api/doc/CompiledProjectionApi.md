# dora_api.api.CompiledProjectionApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet**](CompiledProjectionApi.md#getcompiledprojectionapiv1tripstripidcompiledprojectionget) | **GET** /api/v1/trips/{trip_id}/compiled/projection | Get Compiled Projection
[**rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost**](CompiledProjectionApi.md#rebindcompiledprojectionitemapiv1tripstripidcompiledrebindpost) | **POST** /api/v1/trips/{trip_id}/compiled/rebind | Rebind Compiled Projection Item


# **getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet**
> CompiledProjectionResponse getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet(tripId, authorization)

Get Compiled Projection

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getCompiledProjectionApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompiledProjectionApi->getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**CompiledProjectionResponse**](CompiledProjectionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost**
> CompiledProjectionResponse rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost(tripId, authorization, compiledRebindRequest)

Rebind Compiled Projection Item

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getCompiledProjectionApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final CompiledRebindRequest compiledRebindRequest = ; // CompiledRebindRequest | 

try {
    final response = api.rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost(tripId, authorization, compiledRebindRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompiledProjectionApi->rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **compiledRebindRequest** | [**CompiledRebindRequest**](CompiledRebindRequest.md)|  | 

### Return type

[**CompiledProjectionResponse**](CompiledProjectionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

