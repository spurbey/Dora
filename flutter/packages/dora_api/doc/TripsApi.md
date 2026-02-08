# dora_api.api.TripsApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createTripApiV1TripsPost**](TripsApi.md#createtripapiv1tripspost) | **POST** /api/v1/trips | Create Trip
[**deleteTripApiV1TripsTripIdDelete**](TripsApi.md#deletetripapiv1tripstripiddelete) | **DELETE** /api/v1/trips/{trip_id} | Delete Trip
[**getTripApiV1TripsTripIdGet**](TripsApi.md#gettripapiv1tripstripidget) | **GET** /api/v1/trips/{trip_id} | Get Trip
[**getTripBoundsApiV1TripsTripIdBoundsGet**](TripsApi.md#gettripboundsapiv1tripstripidboundsget) | **GET** /api/v1/trips/{trip_id}/bounds | Get Trip Bounds
[**listTripsApiV1TripsGet**](TripsApi.md#listtripsapiv1tripsget) | **GET** /api/v1/trips | List Trips
[**updateTripApiV1TripsTripIdPatch**](TripsApi.md#updatetripapiv1tripstripidpatch) | **PATCH** /api/v1/trips/{trip_id} | Update Trip


# **createTripApiV1TripsPost**
> TripResponse createTripApiV1TripsPost(authorization, tripCreate)

Create Trip

Create a new trip.      **Authentication:** Required      **Permissions:** Any authenticated user      **Request Body:**     - title: Trip title (required, 1-255 chars)     - description: Optional trip description     - start_date: Optional trip start date (YYYY-MM-DD)     - end_date: Optional trip end date (YYYY-MM-DD)     - cover_photo_url: Optional cover photo URL     - visibility: private | unlisted | public (default: private)      **Returns:**     Created trip with generated ID      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"title\": \"Summer Europe Trip\",         \"description\": \"Backpacking across Europe\",         \"start_date\": \"2025-06-01\",         \"end_date\": \"2025-06-30\",         \"visibility\": \"private\",         \"views_count\": 0,         \"saves_count\": 0,         \"created_at\": \"2025-01-25T10:30:00Z\",         \"updated_at\": \"2025-01-25T10:30:00Z\"     } ```      **Errors:**     - 400: Invalid date range (end_date < start_date) or invalid visibility     - 401: Not authenticated     - 403: Free tier limit reached (3 trips max)      **Business Logic:**     - user_id is automatically set from authenticated user     - Free tier users: max 3 trips     - Premium users: unlimited trips     - Default visibility is \"private\"     - views_count and saves_count initialized to 0

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TripCreate tripCreate = ; // TripCreate | 

try {
    final response = api.createTripApiV1TripsPost(authorization, tripCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TripsApi->createTripApiV1TripsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **tripCreate** | [**TripCreate**](TripCreate.md)|  | 

### Return type

[**TripResponse**](TripResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTripApiV1TripsTripIdDelete**
> deleteTripApiV1TripsTripIdDelete(tripId, authorization)

Delete Trip

Delete a trip.  **Authentication:** Required  **Permissions:** Only trip owner can delete  **Path Parameters:** - trip_id: Trip UUID  **Returns:** 204 No Content on success  **Errors:** - 401: Not authenticated - 403: User does not own trip - 404: Trip not found  **Business Logic:** - Ownership check prevents unauthorized deletion - Cascades to related records:   - All trip_places deleted (via ON DELETE CASCADE)   - All trip_routes deleted (via ON DELETE CASCADE) - Permanent deletion (no soft delete)  **Warning:** - This action is irreversible - All associated places and routes will be deleted

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    api.deleteTripApiV1TripsTripIdDelete(tripId, authorization);
} on DioException catch (e) {
    print('Exception when calling TripsApi->deleteTripApiV1TripsTripIdDelete: $e\n');
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

# **getTripApiV1TripsTripIdGet**
> TripResponse getTripApiV1TripsTripIdGet(tripId, authorization)

Get Trip

Get trip detail by ID.      **Authentication:** Required      **Permissions:**     - Owner can always view their trip     - Non-owners can view if trip is public or unlisted     - Private trips only visible to owner      **Path Parameters:**     - trip_id: Trip UUID      **Returns:**     Trip details      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"user_id\": \"987e6543-e21b-12d3-a456-426614174000\",         \"title\": \"Summer Europe Trip\",         \"description\": \"Backpacking across Europe\",         \"start_date\": \"2025-06-01\",         \"end_date\": \"2025-06-30\",         \"visibility\": \"public\",         \"views_count\": 142,         \"saves_count\": 23,         \"created_at\": \"2025-01-25T10:30:00Z\",         \"updated_at\": \"2025-01-25T10:30:00Z\"     } ```      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Increments views_count if viewer is NOT the owner     - Access control based on visibility:       - private: Only owner can view       - unlisted: Owner + anyone with link can view       - public: Anyone can view

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getTripApiV1TripsTripIdGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TripsApi->getTripApiV1TripsTripIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**TripResponse**](TripResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTripBoundsApiV1TripsTripIdBoundsGet**
> JsonObject getTripBoundsApiV1TripsTripIdBoundsGet(tripId, authorization)

Get Trip Bounds

Get geographic bounding box for a trip based on its places.      **Authentication:** Required      **Permissions:**     - Trip owner can always view     - Non-owner can view if trip is public/unlisted      **Path Parameters:**     - trip_id: Trip UUID      **Returns:**     Bounding box with min/max coordinates and center point, or null if no places      **Response Example:** ```json     {         \"min_lat\": 48.8530,         \"min_lng\": 2.2945,         \"max_lat\": 48.8738,         \"max_lng\": 2.3499,         \"center_lat\": 48.8634,         \"center_lng\": 2.3222     } ```      **Null Response (no places):** ```json     null ```      **Errors:**     - 401: Not authenticated     - 403: Trip is private and user is not owner     - 404: Trip not found      **Business Logic:**     - Calculates bounding box from all places in trip     - Returns null if trip has no places     - Access control based on trip visibility     - Useful for auto-centering map on trip     - Center is simple average of bounds (not geographic centroid)      **Use Cases:**     - Auto-fit map to show all places in trip     - Calculate zoom level for trip map view     - Determine trip geographic span

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getTripBoundsApiV1TripsTripIdBoundsGet(tripId, authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TripsApi->getTripBoundsApiV1TripsTripIdBoundsGet: $e\n');
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

# **listTripsApiV1TripsGet**
> TripListResponse listTripsApiV1TripsGet(authorization, page, pageSize, visibility)

List Trips

List current user's trips with pagination.      **Authentication:** Required      **Permissions:** Any authenticated user (only sees own trips)      **Query Parameters:**     - page: Page number (default: 1, min: 1)     - page_size: Items per page (default: 20, max: 100)     - visibility: Optional filter by visibility (private|unlisted|public)      **Returns:**     Paginated list of trips with metadata      **Response Example:** ```json     {         \"trips\": [             {                 \"id\": \"123e4567-e89b-12d3-a456-426614174000\",                 \"title\": \"Summer Europe Trip\",                 ...             },             {                 \"id\": \"987e6543-e21b-12d3-a456-426614174000\",                 \"title\": \"Winter Japan Trip\",                 ...             }         ],         \"total\": 15,         \"page\": 1,         \"page_size\": 20,         \"total_pages\": 1     } ```      **Errors:**     - 401: Not authenticated      **Business Logic:**     - Only returns trips owned by current user     - Results ordered by created_at DESC (newest first)     - Page size automatically capped at 100     - Empty list if user has no trips

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final int page = 56; // int | Page number (1-indexed)
final int pageSize = 56; // int | Items per page (max 100)
final String visibility = visibility_example; // String | Filter by visibility (private|unlisted|public)

try {
    final response = api.listTripsApiV1TripsGet(authorization, page, pageSize, visibility);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TripsApi->listTripsApiV1TripsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **page** | **int**| Page number (1-indexed) | [optional] [default to 1]
 **pageSize** | **int**| Items per page (max 100) | [optional] [default to 20]
 **visibility** | **String**| Filter by visibility (private|unlisted|public) | [optional] 

### Return type

[**TripListResponse**](TripListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTripApiV1TripsTripIdPatch**
> TripResponse updateTripApiV1TripsTripIdPatch(tripId, authorization, tripUpdate)

Update Trip

Update an existing trip.      **Authentication:** Required      **Permissions:** Only trip owner can update      **Path Parameters:**     - trip_id: Trip UUID      **Request Body:**     All fields are optional (partial update):     - title: New trip title (1-255 chars)     - description: New description     - start_date: New start date     - end_date: New end date     - cover_photo_url: New cover photo URL     - visibility: New visibility (private|unlisted|public)      **Returns:**     Updated trip      **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"title\": \"Updated Trip Title\",         \"description\": \"Updated description\",         ...     } ```      **Errors:**     - 400: Invalid date range (end_date < start_date)     - 401: Not authenticated     - 403: User does not own trip     - 404: Trip not found      **Business Logic:**     - Only updates provided fields (partial update)     - Ownership check prevents unauthorized updates     - Date validation ensures end_date >= start_date     - Cannot update user_id or engagement metrics (views, saves)     - updated_at timestamp automatically updated

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getTripsApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final TripUpdate tripUpdate = ; // TripUpdate | 

try {
    final response = api.updateTripApiV1TripsTripIdPatch(tripId, authorization, tripUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TripsApi->updateTripApiV1TripsTripIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **tripUpdate** | [**TripUpdate**](TripUpdate.md)|  | 

### Return type

[**TripResponse**](TripResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

