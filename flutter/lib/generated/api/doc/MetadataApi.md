# dora_api.api.MetadataApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPlaceMetadataApiV1PlacesPlaceIdMetadataPost**](MetadataApi.md#createplacemetadataapiv1placesplaceidmetadatapost) | **POST** /api/v1/places/{place_id}/metadata | Create Place Metadata
[**createTripMetadataApiV1TripsTripIdMetadataPost**](MetadataApi.md#createtripmetadataapiv1tripstripidmetadatapost) | **POST** /api/v1/trips/{trip_id}/metadata | Create Trip Metadata
[**deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete**](MetadataApi.md#deleteplacemetadataapiv1placesplaceidmetadatadelete) | **DELETE** /api/v1/places/{place_id}/metadata | Delete Place Metadata
[**deleteTripMetadataApiV1TripsTripIdMetadataDelete**](MetadataApi.md#deletetripmetadataapiv1tripstripidmetadatadelete) | **DELETE** /api/v1/trips/{trip_id}/metadata | Delete Trip Metadata
[**getPlaceMetadataApiV1PlacesPlaceIdMetadataGet**](MetadataApi.md#getplacemetadataapiv1placesplaceidmetadataget) | **GET** /api/v1/places/{place_id}/metadata | Get Place Metadata
[**getTripMetadataApiV1TripsTripIdMetadataGet**](MetadataApi.md#gettripmetadataapiv1tripstripidmetadataget) | **GET** /api/v1/trips/{trip_id}/metadata | Get Trip Metadata
[**updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch**](MetadataApi.md#updateplacemetadataapiv1placesplaceidmetadatapatch) | **PATCH** /api/v1/places/{place_id}/metadata | Update Place Metadata
[**updateTripMetadataApiV1TripsTripIdMetadataPatch**](MetadataApi.md#updatetripmetadataapiv1tripstripidmetadatapatch) | **PATCH** /api/v1/trips/{trip_id}/metadata | Update Trip Metadata


# **createPlaceMetadataApiV1PlacesPlaceIdMetadataPost**
> PlaceMetadataResponse createPlaceMetadataApiV1PlacesPlaceIdMetadataPost(placeId, authorization, placeMetadataCreate)

Create Place Metadata

Create metadata for a place.  **Authentication:** Required  **Permissions:** Place owner only  **Request Body:** - component_type: Type of component (city, place, activity, accommodation, food, transport) - experience_tags: Array of experience descriptors - best_for: Array of audience types - budget_per_person: Estimated cost per person (USD) - duration_hours: Recommended time to spend (hours) - difficulty_rating: Physical difficulty (1-5) - physical_demand: Physical demand level (low, medium, high) - best_time: Optimal time to visit - is_public: Whether place can be discovered publicly (default: false)  **Returns:** Created place metadata  **Errors:** - 404: Place not found - 403: User doesn't own this place - 409: Metadata already exists (use PATCH to update) - 422: Invalid enum values or ranges

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final PlaceMetadataCreate placeMetadataCreate = ; // PlaceMetadataCreate | 

try {
    final response = api.createPlaceMetadataApiV1PlacesPlaceIdMetadataPost(placeId, authorization, placeMetadataCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->createPlaceMetadataApiV1PlacesPlaceIdMetadataPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **placeMetadataCreate** | [**PlaceMetadataCreate**](PlaceMetadataCreate.md)|  | 

### Return type

[**PlaceMetadataResponse**](PlaceMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTripMetadataApiV1TripsTripIdMetadataPost**
> TripMetadataResponse createTripMetadataApiV1TripsTripIdMetadataPost(tripId, authorization, tripMetadataCreate)

Create Trip Metadata

Create metadata for a trip.  **Authentication:** Required  **Permissions:** Trip owner only  **Request Body:** - traveler_type: Array of traveler types (solo, couple, family, group) - age_group: Target age group (gen-z, millennial, gen-x, boomer) - travel_style: Array of travel styles (adventure, luxury, budget, cultural, relaxed) - difficulty_level: Overall difficulty (easy, moderate, challenging, extreme) - budget_category: Budget level (budget, mid-range, luxury) - activity_focus: Array of activity types (hiking, food, photography, nightlife, beaches) - is_discoverable: Whether trip can be found in public search (default: false) - tags: User-defined tags  **Returns:** Created trip metadata  **Errors:** - 404: Trip not found - 403: User doesn't own this trip - 409: Metadata already exists (use PATCH to update) - 422: Invalid enum values

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TripMetadataCreate tripMetadataCreate = ; // TripMetadataCreate | 

try {
    final response = api.createTripMetadataApiV1TripsTripIdMetadataPost(tripId, authorization, tripMetadataCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->createTripMetadataApiV1TripsTripIdMetadataPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **tripMetadataCreate** | [**TripMetadataCreate**](TripMetadataCreate.md)|  | 

### Return type

[**TripMetadataResponse**](TripMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete**
> deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete(placeId, authorization)

Delete Place Metadata

Delete metadata for a place.  **Authentication:** Required  **Permissions:** Place owner only  **Returns:** 204 No Content on success  **Errors:** - 404: Place or metadata not found - 403: User doesn't own this place  **Note:** Place itself is NOT deleted, only its metadata.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete(placeId, authorization);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->deletePlaceMetadataApiV1PlacesPlaceIdMetadataDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTripMetadataApiV1TripsTripIdMetadataDelete**
> deleteTripMetadataApiV1TripsTripIdMetadataDelete(tripId, authorization)

Delete Trip Metadata

Delete metadata for a trip.  **Authentication:** Required  **Permissions:** Trip owner only  **Returns:** 204 No Content on success  **Errors:** - 404: Trip or metadata not found - 403: User doesn't own this trip  **Note:** Trip itself is NOT deleted, only its metadata.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteTripMetadataApiV1TripsTripIdMetadataDelete(tripId, authorization);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->deleteTripMetadataApiV1TripsTripIdMetadataDelete: $e\n');
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

# **getPlaceMetadataApiV1PlacesPlaceIdMetadataGet**
> PlaceMetadataResponse getPlaceMetadataApiV1PlacesPlaceIdMetadataGet(placeId, authorization)

Get Place Metadata

Get metadata for a place.  **Authentication:** Required  **Permissions:** - Place owner: Always allowed - Others: Only if parent trip is public or unlisted  **Returns:** Place metadata  **Errors:** - 404: Place or metadata not found - 403: Trip is private and user is not owner

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getPlaceMetadataApiV1PlacesPlaceIdMetadataGet(placeId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->getPlaceMetadataApiV1PlacesPlaceIdMetadataGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**PlaceMetadataResponse**](PlaceMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTripMetadataApiV1TripsTripIdMetadataGet**
> TripMetadataResponse getTripMetadataApiV1TripsTripIdMetadataGet(tripId, authorization)

Get Trip Metadata

Get metadata for a trip.  **Authentication:** Required  **Permissions:** - Trip owner: Always allowed - Others: Only if trip is public or unlisted  **Returns:** Trip metadata  **Errors:** - 404: Trip or metadata not found - 403: Trip is private and user is not owner

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getTripMetadataApiV1TripsTripIdMetadataGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->getTripMetadataApiV1TripsTripIdMetadataGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**TripMetadataResponse**](TripMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch**
> PlaceMetadataResponse updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch(placeId, authorization, placeMetadataUpdate)

Update Place Metadata

Update metadata for a place (partial update).  **Authentication:** Required  **Permissions:** Place owner only  **Request Body:** All fields are optional. Only provided fields will be updated.  **Returns:** Updated place metadata  **Errors:** - 404: Place or metadata not found - 403: User doesn't own this place - 422: Invalid enum values or ranges

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final PlaceMetadataUpdate placeMetadataUpdate = ; // PlaceMetadataUpdate | 

try {
    final response = api.updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch(placeId, authorization, placeMetadataUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->updatePlaceMetadataApiV1PlacesPlaceIdMetadataPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **placeMetadataUpdate** | [**PlaceMetadataUpdate**](PlaceMetadataUpdate.md)|  | 

### Return type

[**PlaceMetadataResponse**](PlaceMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTripMetadataApiV1TripsTripIdMetadataPatch**
> TripMetadataResponse updateTripMetadataApiV1TripsTripIdMetadataPatch(tripId, authorization, tripMetadataUpdate)

Update Trip Metadata

Update metadata for a trip (partial update).  **Authentication:** Required  **Permissions:** Trip owner only  **Request Body:** All fields are optional. Only provided fields will be updated.  **Returns:** Updated trip metadata  **Errors:** - 404: Trip or metadata not found - 403: User doesn't own this trip - 422: Invalid enum values

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getMetadataApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TripMetadataUpdate tripMetadataUpdate = ; // TripMetadataUpdate | 

try {
    final response = api.updateTripMetadataApiV1TripsTripIdMetadataPatch(tripId, authorization, tripMetadataUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetadataApi->updateTripMetadataApiV1TripsTripIdMetadataPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **tripMetadataUpdate** | [**TripMetadataUpdate**](TripMetadataUpdate.md)|  | 

### Return type

[**TripMetadataResponse**](TripMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

