# dora_api.api.SearchApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchPlacesApiV1SearchPlacesGet**](SearchApi.md#searchplacesapiv1searchplacesget) | **GET** /api/v1/search/places | Search Places


# **searchPlacesApiV1SearchPlacesGet**
> SearchResponse searchPlacesApiV1SearchPlacesGet(query, lat, lng, authorization, radiusKm, limit, debug)

Search Places

Search for places from multiple sources.  **Authentication:** Required  **Strategy:** - Searches local database first (user-contributed places) - Falls back to Foursquare API if needed - Deduplicates results (local priority) - Ranks by relevance score - Logs search event for learning  **Query Parameters:** - `query`: Search text (e.g., \"coffee shop\") - `lat`: Search center latitude - `lng`: Search center longitude - `radius_km`: Search radius in kilometers (default: 5.0) - `limit`: Maximum results to return (default: 10) - `debug`: Include score breakdown in results (default: false)  **Response:** - `results`: List of ranked results with scores - `count`: Number of results returned - `query`: Original search query (echoed back)  **Errors:** - 400: Invalid parameters (bad coordinates, empty query) - 401: Not authenticated - 500: Internal server error

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getSearchApi();
final String query = query_example; // String | Search text
final num lat = 8.14; // num | Search center latitude
final num lng = 8.14; // num | Search center longitude
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final num radiusKm = 8.14; // num | Search radius in km
final int limit = 56; // int | Max results
final bool debug = true; // bool | Include score breakdown

try {
    final response = api.searchPlacesApiV1SearchPlacesGet(query, lat, lng, authorization, radiusKm, limit, debug);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SearchApi->searchPlacesApiV1SearchPlacesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **query** | **String**| Search text | 
 **lat** | **num**| Search center latitude | 
 **lng** | **num**| Search center longitude | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **radiusKm** | **num**| Search radius in km | [optional] [default to 5.0]
 **limit** | **int**| Max results | [optional] [default to 10]
 **debug** | **bool**| Include score breakdown | [optional] [default to false]

### Return type

[**SearchResponse**](SearchResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

