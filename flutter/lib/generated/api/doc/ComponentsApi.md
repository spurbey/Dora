# dora_api.api.ComponentsApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet**](ComponentsApi.md#getcomponentdetailsapiv1tripstripidcomponentscomponentidget) | **GET** /api/v1/trips/{trip_id}/components/{component_id} | Get component details
[**getComponentsApiV1TripsTripIdComponentsGet**](ComponentsApi.md#getcomponentsapiv1tripstripidcomponentsget) | **GET** /api/v1/trips/{trip_id}/components | Get unified timeline
[**reorderComponentsApiV1TripsTripIdComponentsReorderPatch**](ComponentsApi.md#reordercomponentsapiv1tripstripidcomponentsreorderpatch) | **PATCH** /api/v1/trips/{trip_id}/components/reorder | Bulk reorder components


# **getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet**
> TripComponentDetailResponse getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet(tripId, componentId, authorization)

Get component details

Get full details of a place or route component (auto-detects type)

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getComponentsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String componentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet(tripId, componentId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ComponentsApi->getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **componentId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**TripComponentDetailResponse**](TripComponentDetailResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getComponentsApiV1TripsTripIdComponentsGet**
> TripComponentListResponse getComponentsApiV1TripsTripIdComponentsGet(tripId, authorization)

Get unified timeline

Fetch all places and routes for a trip in chronological order

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getComponentsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getComponentsApiV1TripsTripIdComponentsGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ComponentsApi->getComponentsApiV1TripsTripIdComponentsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**TripComponentListResponse**](TripComponentListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reorderComponentsApiV1TripsTripIdComponentsReorderPatch**
> ComponentReorderResponse reorderComponentsApiV1TripsTripIdComponentsReorderPatch(tripId, authorization, componentReorderRequest)

Bulk reorder components

Reorder places and routes with automatic normalization to 0,1,2,3...

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getComponentsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final ComponentReorderRequest componentReorderRequest = ; // ComponentReorderRequest | 

try {
    final response = api.reorderComponentsApiV1TripsTripIdComponentsReorderPatch(tripId, authorization, componentReorderRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ComponentsApi->reorderComponentsApiV1TripsTripIdComponentsReorderPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **componentReorderRequest** | [**ComponentReorderRequest**](ComponentReorderRequest.md)|  | 

### Return type

[**ComponentReorderResponse**](ComponentReorderResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

