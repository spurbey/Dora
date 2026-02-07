# dora_api.api.PlacesApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPlaceApiV1PlacesPost**](PlacesApi.md#createplaceapiv1placespost) | **POST** /api/v1/places | Create Place
[**deletePlaceApiV1PlacesPlaceIdDelete**](PlacesApi.md#deleteplaceapiv1placesplaceiddelete) | **DELETE** /api/v1/places/{place_id} | Delete Place
[**getNearbyPlacesApiV1PlacesNearbyGet**](PlacesApi.md#getnearbyplacesapiv1placesnearbyget) | **GET** /api/v1/places/nearby | Get Nearby Places
[**getPlaceApiV1PlacesPlaceIdGet**](PlacesApi.md#getplaceapiv1placesplaceidget) | **GET** /api/v1/places/{place_id} | Get Place
[**listPlacesApiV1PlacesGet**](PlacesApi.md#listplacesapiv1placesget) | **GET** /api/v1/places | List Places
[**updatePlaceApiV1PlacesPlaceIdPatch**](PlacesApi.md#updateplaceapiv1placesplaceidpatch) | **PATCH** /api/v1/places/{place_id} | Update Place


# **createPlaceApiV1PlacesPost**
> PlaceResponse createPlaceApiV1PlacesPost(authorization, placeCreate)

Create Place

Create a new place in a trip.      **Authentication:** Required      **Permissions:** User must own the trip      **Request Body:**     - trip_id: Parent trip ID (required)     - name: Place name (required, 1-255 chars)     - lat: Latitude (required, -90 to 90)     - lng: Longitude (required, -180 to 180)     - place_type: Category (restaurant, hotel, attraction, etc.)     - user_notes: Personal notes     - user_rating: Rating 1-5 (optional)     - visit_date: Date of visit (optional)     - order_in_trip: Position in itinerary (optional, auto-set if not provided)      **Returns:**     Created place with generated ID      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"trip_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"user_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"name\": \"Eiffel Tower\",         \"place_type\": \"attraction\",         \"lat\": 48.8584,         \"lng\": 2.2945,         \"user_notes\": \"Must visit at night!\",         \"user_rating\": 5,         \"visit_date\": \"2025-06-15\",         \"photos\": [],         \"videos\": [],         \"order_in_trip\": 0,         \"created_at\": \"2025-01-25T10:30:00Z\",         \"updated_at\": \"2025-01-25T10:30:00Z\"     } ```      **Errors:**     - 400: Invalid coordinates or rating     - 401: Not authenticated     - 403: User does not own trip     - 404: Trip not found      **Business Logic:**     - user_id is automatically set from authenticated user     - lat/lng converted to PostGIS Geography POINT (SRID=4326;POINT(lng lat))     - If order_in_trip not provided, auto-set to max + 1     - Trip ownership validated before creation

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final PlaceCreate placeCreate = ; // PlaceCreate | 

try {
    final response = api.createPlaceApiV1PlacesPost(authorization, placeCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->createPlaceApiV1PlacesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **placeCreate** | [**PlaceCreate**](PlaceCreate.md)|  | 

### Return type

[**PlaceResponse**](PlaceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlaceApiV1PlacesPlaceIdDelete**
> deletePlaceApiV1PlacesPlaceIdDelete(placeId, authorization)

Delete Place

Delete a place.  **Authentication:** Required  **Permissions:** Only trip owner can delete  **Path Parameters:** - place_id: Place UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own trip - 404: Place not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Permanent deletion (no soft delete) - Order gaps are okay (reordering is separate operation)  **Warning:** - This action is irreversible - Place data including photos metadata will be deleted

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deletePlaceApiV1PlacesPlaceIdDelete(placeId, authorization);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->deletePlaceApiV1PlacesPlaceIdDelete: $e\n');
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

# **getNearbyPlacesApiV1PlacesNearbyGet**
> PlaceListResponse getNearbyPlacesApiV1PlacesNearbyGet(lat, lng, authorization, radius)

Get Nearby Places

Find places near a location using PostGIS spatial query.      **Authentication:** Required      **Query Parameters:**     - lat: Center latitude (required, -90 to 90)     - lng: Center longitude (required, -180 to 180)     - radius: Search radius in km (default: 5.0, max: 50.0)      **Returns:**     List of user's places within radius, ordered by distance      **Response Example:** ```json     {         \"places\": [             {                 \"id\": \"123e4567-e89b-12d3-a456-426614174000\",                 \"name\": \"Eiffel Tower\",                 \"lat\": 48.8584,                 \"lng\": 2.2945,                 \"distance_km\": 0.0,                 ...             },             {                 \"id\": \"987e6543-e21b-12d3-a456-426614174000\",                 \"name\": \"Arc de Triomphe\",                 \"lat\": 48.8738,                 \"lng\": 2.2950,                 \"distance_km\": 2.1,                 ...             }         ],         \"total\": 2,         \"search_center\": {\"lat\": 48.8584, \"lng\": 2.2945},         \"radius_km\": 5.0     } ```      **Errors:**     - 400: Invalid coordinates or radius     - 401: Not authenticated      **Business Logic:**     - Only returns current user's places     - Uses PostGIS ST_DWithin for efficient spatial search     - Results ordered by distance (closest first)     - Maximum radius capped at 50km     - Uses GIST spatial index for fast queries      **PostGIS Query:**     - ST_DWithin: Find places within radius     - ST_Distance: Calculate distance for ordering     - Geography type: Accurate ellipsoidal calculations

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final num lat = 8.14; // num | Search center latitude
final num lng = 8.14; // num | Search center longitude
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final num radius = 8.14; // num | Search radius in kilometers

try {
    final response = api.getNearbyPlacesApiV1PlacesNearbyGet(lat, lng, authorization, radius);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->getNearbyPlacesApiV1PlacesNearbyGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**| Search center latitude | 
 **lng** | **num**| Search center longitude | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **radius** | **num**| Search radius in kilometers | [optional] [default to 5.0]

### Return type

[**PlaceListResponse**](PlaceListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlaceApiV1PlacesPlaceIdGet**
> PlaceResponse getPlaceApiV1PlacesPlaceIdGet(placeId, authorization)

Get Place

Get place detail by ID.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted     - Private trips only visible to owner      **Path Parameters:**     - place_id: Place UUID      **Returns:**     Place details with photos and metadata      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"trip_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"user_id\": \"456e7890-e12b-12d3-a456-426614174000\",         \"name\": \"Eiffel Tower\",         \"place_type\": \"attraction\",         \"lat\": 48.8584,         \"lng\": 2.2945,         \"user_notes\": \"Visited at sunset - amazing views!\",         \"user_rating\": 5,         \"visit_date\": \"2025-06-15\",         \"photos\": [             {\"url\": \"https://...\", \"caption\": \"From the top\", \"order\": 0}         ],         \"videos\": [],         \"order_in_trip\": 0,         \"created_at\": \"2025-01-25T10:30:00Z\",         \"updated_at\": \"2025-01-25T10:30:00Z\"     } ```      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Place not found      **Business Logic:**     - Access control based on parent trip's visibility     - Returns full place data including photos/videos

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getPlaceApiV1PlacesPlaceIdGet(placeId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->getPlaceApiV1PlacesPlaceIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**PlaceResponse**](PlaceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlacesApiV1PlacesGet**
> PlaceListResponse listPlacesApiV1PlacesGet(tripId, authorization)

List Places

List all places for a trip.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted      **Query Parameters:**     - trip_id: Trip ID (required)      **Returns:**     List of places ordered by order_in_trip (itinerary order)      **Response Example:** ```json     {         \"places\": [             {                 \"id\": \"123e4567-e89b-12d3-a456-426614174000\",                 \"name\": \"Eiffel Tower\",                 \"lat\": 48.8584,                 \"lng\": 2.2945,                 \"order_in_trip\": 0,                 ...             },             {                 \"id\": \"987e6543-e21b-12d3-a456-426614174000\",                 \"name\": \"Louvre Museum\",                 \"lat\": 48.8606,                 \"lng\": 2.3376,                 \"order_in_trip\": 1,                 ...             }         ],         \"total\": 2,         \"trip_id\": \"987e6543-e21b-12d3-a456-426614174000\"     } ```      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Access control based on trip visibility     - Results ordered by order_in_trip ASC (itinerary order)     - Empty list if trip has no places

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Trip ID to list places for
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.listPlacesApiV1PlacesGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->listPlacesApiV1PlacesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**| Trip ID to list places for | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**PlaceListResponse**](PlaceListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlaceApiV1PlacesPlaceIdPatch**
> PlaceResponse updatePlaceApiV1PlacesPlaceIdPatch(placeId, authorization, placeUpdate)

Update Place

Update an existing place.      **Authentication:** Required      **Permissions:** Only trip owner can update      **Path Parameters:**     - place_id: Place UUID      **Request Body:**     All fields are optional (partial update):     - name: New place name (1-255 chars)     - place_type: New category     - lat: New latitude (-90 to 90)     - lng: New longitude (-180 to 180)     - user_notes: New notes     - user_rating: New rating (1-5)     - visit_date: New visit date     - order_in_trip: New position in itinerary      **Returns:**     Updated place      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"name\": \"Eiffel Tower - Updated\",         \"user_notes\": \"Updated notes\",         ...     } ```      **Errors:**     - 400: Invalid coordinates or rating     - 401: Not authenticated     - 403: User does not own trip     - 404: Place not found      **Business Logic:**     - Only updates provided fields (partial update)     - Ownership check prevents unauthorized updates     - If lat/lng updated, Geography column automatically recalculated     - Cannot update trip_id or user_id     - updated_at timestamp automatically updated

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getPlacesApi();
final String placeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final PlaceUpdate placeUpdate = ; // PlaceUpdate | 

try {
    final response = api.updatePlaceApiV1PlacesPlaceIdPatch(placeId, authorization, placeUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->updatePlaceApiV1PlacesPlaceIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **placeUpdate** | [**PlaceUpdate**](PlaceUpdate.md)|  | 

### Return type

[**PlaceResponse**](PlaceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

