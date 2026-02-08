# dora_api.api.RoutesApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addWaypointApiV1RoutesRouteIdWaypointsPost**](RoutesApi.md#addwaypointapiv1routesrouteidwaypointspost) | **POST** /api/v1/routes/{route_id}/waypoints | Add Waypoint
[**createRouteApiV1TripsTripIdRoutesPost**](RoutesApi.md#createrouteapiv1tripstripidroutespost) | **POST** /api/v1/trips/{trip_id}/routes | Create Route
[**createRouteMetadataApiV1RoutesRouteIdMetadataPost**](RoutesApi.md#createroutemetadataapiv1routesrouteidmetadatapost) | **POST** /api/v1/routes/{route_id}/metadata | Create Route Metadata
[**deleteRouteApiV1RoutesRouteIdDelete**](RoutesApi.md#deleterouteapiv1routesrouteiddelete) | **DELETE** /api/v1/routes/{route_id} | Delete Route
[**deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete**](RoutesApi.md#deleteroutemetadataapiv1routesrouteidmetadatadelete) | **DELETE** /api/v1/routes/{route_id}/metadata | Delete Route Metadata
[**deleteWaypointApiV1WaypointsWaypointIdDelete**](RoutesApi.md#deletewaypointapiv1waypointswaypointiddelete) | **DELETE** /api/v1/waypoints/{waypoint_id} | Delete Waypoint
[**generateRouteApiV1RoutesGeneratePost**](RoutesApi.md#generaterouteapiv1routesgeneratepost) | **POST** /api/v1/routes/generate | Generate Route
[**getRouteApiV1RoutesRouteIdGet**](RoutesApi.md#getrouteapiv1routesrouteidget) | **GET** /api/v1/routes/{route_id} | Get Route
[**getRouteMetadataApiV1RoutesRouteIdMetadataGet**](RoutesApi.md#getroutemetadataapiv1routesrouteidmetadataget) | **GET** /api/v1/routes/{route_id}/metadata | Get Route Metadata
[**listTripRoutesApiV1TripsTripIdRoutesGet**](RoutesApi.md#listtriproutesapiv1tripstripidroutesget) | **GET** /api/v1/trips/{trip_id}/routes | List Trip Routes
[**listWaypointsApiV1RoutesRouteIdWaypointsGet**](RoutesApi.md#listwaypointsapiv1routesrouteidwaypointsget) | **GET** /api/v1/routes/{route_id}/waypoints | List Waypoints
[**updateRouteApiV1RoutesRouteIdPatch**](RoutesApi.md#updaterouteapiv1routesrouteidpatch) | **PATCH** /api/v1/routes/{route_id} | Update Route
[**updateRouteMetadataApiV1RoutesRouteIdMetadataPatch**](RoutesApi.md#updateroutemetadataapiv1routesrouteidmetadatapatch) | **PATCH** /api/v1/routes/{route_id}/metadata | Update Route Metadata
[**updateWaypointApiV1WaypointsWaypointIdPatch**](RoutesApi.md#updatewaypointapiv1waypointswaypointidpatch) | **PATCH** /api/v1/waypoints/{waypoint_id} | Update Waypoint


# **addWaypointApiV1RoutesRouteIdWaypointsPost**
> WaypointResponse addWaypointApiV1RoutesRouteIdWaypointsPost(routeId, authorization, waypointCreate)

Add Waypoint

Add waypoint to a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final WaypointCreate waypointCreate = ; // WaypointCreate | 

try {
    final response = api.addWaypointApiV1RoutesRouteIdWaypointsPost(routeId, authorization, waypointCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->addWaypointApiV1RoutesRouteIdWaypointsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **waypointCreate** | [**WaypointCreate**](WaypointCreate.md)|  | 

### Return type

[**WaypointResponse**](WaypointResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRouteApiV1TripsTripIdRoutesPost**
> RouteResponse createRouteApiV1TripsTripIdRoutesPost(tripId, authorization, routeCreate)

Create Route

Create a route for a trip.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final RouteCreate routeCreate = ; // RouteCreate | 

try {
    final response = api.createRouteApiV1TripsTripIdRoutesPost(tripId, authorization, routeCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->createRouteApiV1TripsTripIdRoutesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **routeCreate** | [**RouteCreate**](RouteCreate.md)|  | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRouteMetadataApiV1RoutesRouteIdMetadataPost**
> RouteMetadataResponse createRouteMetadataApiV1RoutesRouteIdMetadataPost(routeId, authorization, routeMetadataCreate)

Create Route Metadata

Create metadata for a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final RouteMetadataCreate routeMetadataCreate = ; // RouteMetadataCreate | 

try {
    final response = api.createRouteMetadataApiV1RoutesRouteIdMetadataPost(routeId, authorization, routeMetadataCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->createRouteMetadataApiV1RoutesRouteIdMetadataPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **routeMetadataCreate** | [**RouteMetadataCreate**](RouteMetadataCreate.md)|  | 

### Return type

[**RouteMetadataResponse**](RouteMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRouteApiV1RoutesRouteIdDelete**
> deleteRouteApiV1RoutesRouteIdDelete(routeId, authorization)

Delete Route

Delete a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteRouteApiV1RoutesRouteIdDelete(routeId, authorization);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->deleteRouteApiV1RoutesRouteIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete**
> deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete(routeId, authorization)

Delete Route Metadata

Delete metadata for a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete(routeId, authorization);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteWaypointApiV1WaypointsWaypointIdDelete**
> deleteWaypointApiV1WaypointsWaypointIdDelete(waypointId, authorization)

Delete Waypoint

Delete a waypoint.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String waypointId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteWaypointApiV1WaypointsWaypointIdDelete(waypointId, authorization);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->deleteWaypointApiV1WaypointsWaypointIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **waypointId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateRouteApiV1RoutesGeneratePost**
> RouteGenerateResponse generateRouteApiV1RoutesGeneratePost(authorization, routeGenerateRequest)

Generate Route

Auto-generate route from coordinates using Mapbox Directions API.  Requires MAPBOX_ACCESS_TOKEN in environment.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final RouteGenerateRequest routeGenerateRequest = ; // RouteGenerateRequest | 

try {
    final response = api.generateRouteApiV1RoutesGeneratePost(authorization, routeGenerateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->generateRouteApiV1RoutesGeneratePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **routeGenerateRequest** | [**RouteGenerateRequest**](RouteGenerateRequest.md)|  | 

### Return type

[**RouteGenerateResponse**](RouteGenerateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRouteApiV1RoutesRouteIdGet**
> RouteResponse getRouteApiV1RoutesRouteIdGet(routeId, authorization)

Get Route

Get route details.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getRouteApiV1RoutesRouteIdGet(routeId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->getRouteApiV1RoutesRouteIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRouteMetadataApiV1RoutesRouteIdMetadataGet**
> RouteMetadataResponse getRouteMetadataApiV1RoutesRouteIdMetadataGet(routeId, authorization)

Get Route Metadata

Get metadata for a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getRouteMetadataApiV1RoutesRouteIdMetadataGet(routeId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->getRouteMetadataApiV1RoutesRouteIdMetadataGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**RouteMetadataResponse**](RouteMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTripRoutesApiV1TripsTripIdRoutesGet**
> RouteListResponse listTripRoutesApiV1TripsTripIdRoutesGet(tripId, authorization)

List Trip Routes

List routes for a trip.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.listTripRoutesApiV1TripsTripIdRoutesGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->listTripRoutesApiV1TripsTripIdRoutesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**RouteListResponse**](RouteListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listWaypointsApiV1RoutesRouteIdWaypointsGet**
> WaypointListResponse listWaypointsApiV1RoutesRouteIdWaypointsGet(routeId, authorization)

List Waypoints

List waypoints for a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.listWaypointsApiV1RoutesRouteIdWaypointsGet(routeId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->listWaypointsApiV1RoutesRouteIdWaypointsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**WaypointListResponse**](WaypointListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRouteApiV1RoutesRouteIdPatch**
> RouteResponse updateRouteApiV1RoutesRouteIdPatch(routeId, authorization, routeUpdate)

Update Route

Update a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final RouteUpdate routeUpdate = ; // RouteUpdate | 

try {
    final response = api.updateRouteApiV1RoutesRouteIdPatch(routeId, authorization, routeUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->updateRouteApiV1RoutesRouteIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **routeUpdate** | [**RouteUpdate**](RouteUpdate.md)|  | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRouteMetadataApiV1RoutesRouteIdMetadataPatch**
> RouteMetadataResponse updateRouteMetadataApiV1RoutesRouteIdMetadataPatch(routeId, authorization, routeMetadataUpdate)

Update Route Metadata

Update metadata for a route.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final RouteMetadataUpdate routeMetadataUpdate = ; // RouteMetadataUpdate | 

try {
    final response = api.updateRouteMetadataApiV1RoutesRouteIdMetadataPatch(routeId, authorization, routeMetadataUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->updateRouteMetadataApiV1RoutesRouteIdMetadataPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **routeMetadataUpdate** | [**RouteMetadataUpdate**](RouteMetadataUpdate.md)|  | 

### Return type

[**RouteMetadataResponse**](RouteMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateWaypointApiV1WaypointsWaypointIdPatch**
> WaypointResponse updateWaypointApiV1WaypointsWaypointIdPatch(waypointId, authorization, waypointUpdate)

Update Waypoint

Update a waypoint.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getRoutesApi();
final String waypointId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final WaypointUpdate waypointUpdate = ; // WaypointUpdate | 

try {
    final response = api.updateWaypointApiV1WaypointsWaypointIdPatch(waypointId, authorization, waypointUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RoutesApi->updateWaypointApiV1WaypointsWaypointIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **waypointId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **waypointUpdate** | [**WaypointUpdate**](WaypointUpdate.md)|  | 

### Return type

[**WaypointResponse**](WaypointResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

