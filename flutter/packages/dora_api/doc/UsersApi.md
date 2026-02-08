# dora_api.api.UsersApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCurrentUserCompleteProfileApiV1UsersMeProfileGet**](UsersApi.md#getcurrentusercompleteprofileapiv1usersmeprofileget) | **GET** /api/v1/users/me/profile | Get Current User Complete Profile
[**getCurrentUserProfileApiV1UsersMeGet**](UsersApi.md#getcurrentuserprofileapiv1usersmeget) | **GET** /api/v1/users/me | Get Current User Profile
[**getCurrentUserStatsApiV1UsersMeStatsGet**](UsersApi.md#getcurrentuserstatsapiv1usersmestatsget) | **GET** /api/v1/users/me/stats | Get Current User Stats
[**updateCurrentUserProfileApiV1UsersMePatch**](UsersApi.md#updatecurrentuserprofileapiv1usersmepatch) | **PATCH** /api/v1/users/me | Update Current User Profile


# **getCurrentUserCompleteProfileApiV1UsersMeProfileGet**
> UserProfileResponse getCurrentUserCompleteProfileApiV1UsersMeProfileGet(authorization)

Get Current User Complete Profile

Get complete user profile with statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     User profile + statistics in single response          **Response Example:** ```json     {         \"user\": {             \"id\": \"123e4567-e89b-12d3-a456-426614174000\",             \"email\": \"user@example.com\",             \"username\": \"traveler123\",             ...         },         \"stats\": {             \"trip_count\": 5,             \"place_count\": 47,             ...         }     } ```          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Combines /me and /me/stats into single response     - Reduces frontend API calls for profile page     - More efficient than two separate requests

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getUsersApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getCurrentUserCompleteProfileApiV1UsersMeProfileGet(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getCurrentUserCompleteProfileApiV1UsersMeProfileGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**UserProfileResponse**](UserProfileResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentUserProfileApiV1UsersMeGet**
> AppSchemasUserUserResponse getCurrentUserProfileApiV1UsersMeGet(authorization)

Get Current User Profile

Get current user profile.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     User profile data          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"email\": \"user@example.com\",         \"username\": \"traveler123\",         \"full_name\": \"John Doe\",         \"avatar_url\": \"https://example.com/avatar.jpg\",         \"bio\": \"Love to travel!\",         \"is_premium\": false,         \"is_verified\": true,         \"created_at\": \"2024-01-15T10:30:00Z\"     } ```          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Returns current user's profile data     - Used by frontend profile page

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getUsersApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getCurrentUserProfileApiV1UsersMeGet(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getCurrentUserProfileApiV1UsersMeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**AppSchemasUserUserResponse**](AppSchemasUserUserResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentUserStatsApiV1UsersMeStatsGet**
> UserStats getCurrentUserStatsApiV1UsersMeStatsGet(authorization)

Get Current User Stats

Get detailed user statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     Detailed statistics about user's content and engagement          **Response Example:** ```json     {         \"trip_count\": 5,         \"place_count\": 47,         \"public_trip_count\": 2,         \"total_views\": 1234,         \"total_saves\": 56,         \"photos_uploaded\": 89     } ```          **Errors:**     - 401: Not authenticated          **Business Logic:**     - Calculates statistics in real-time from database     - Used by dashboard to display user activity     - Premium users get additional stats (future)          **Performance:**     - Uses SQLAlchemy aggregation functions     - Queries optimized with indexes     - Consider caching for high-traffic users

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getUsersApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getCurrentUserStatsApiV1UsersMeStatsGet(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getCurrentUserStatsApiV1UsersMeStatsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**UserStats**](UserStats.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCurrentUserProfileApiV1UsersMePatch**
> AppSchemasUserUserResponse updateCurrentUserProfileApiV1UsersMePatch(authorization, userUpdate)

Update Current User Profile

Update current user profile.          **Authentication:** Required          **Permissions:** Any authenticated user (can only update own profile)          **Request Body:**     All fields are optional (partial update):     - username: New username (3-50 chars, alphanumeric + underscore)     - full_name: New full name     - bio: New bio (max 500 chars)     - avatar_url: New avatar URL          **Returns:**     Updated user profile          **Response Example:** ```json     {         \"id\": \"123e4567-e89b-12d3-a456-426614174000\",         \"username\": \"new_username\",         \"full_name\": \"Updated Name\",         \"bio\": \"Updated bio\",         ...     } ```          **Errors:**     - 400: Username already taken or invalid format     - 401: Not authenticated          **Business Logic:**     - Only updates provided fields (partial update)     - Username must be unique across all users     - Username can only contain letters, numbers, underscore     - Email cannot be changed (use Supabase Auth)

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getUsersApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth
final UserUpdate userUpdate = ; // UserUpdate | 

try {
    final response = api.updateCurrentUserProfileApiV1UsersMePatch(authorization, userUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->updateCurrentUserProfileApiV1UsersMePatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 
 **userUpdate** | [**UserUpdate**](UserUpdate.md)|  | 

### Return type

[**AppSchemasUserUserResponse**](AppSchemasUserUserResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

