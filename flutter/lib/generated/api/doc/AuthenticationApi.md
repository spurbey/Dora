# dora_api.api.AuthenticationApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCurrentUserInfoApiV1AuthMeGet**](AuthenticationApi.md#getcurrentuserinfoapiv1authmeget) | **GET** /api/v1/auth/me | Get Current User Info


# **getCurrentUserInfoApiV1AuthMeGet**
> MeResponse getCurrentUserInfoApiV1AuthMeGet(authorization)

Get Current User Info

Get current authenticated user with statistics.          **Authentication:** Required          **Permissions:** Any authenticated user          **Returns:**     - user: User profile data     - trip_count: Number of trips created     - place_count: Total places across all trips          **Response Example:** ```json     {         \"user\": {             \"id\": \"123e4567-e89b-12d3-a456-426614174000\",             \"email\": \"user@example.com\",             \"username\": \"traveler123\",             \"is_premium\": false,             \"created_at\": \"2024-01-15T10:30:00Z\"         },         \"trip_count\": 2,         \"place_count\": 15     } ```          **Errors:**     - 401: Not authenticated or invalid token          **Business Logic:**     - Stats calculated in real-time from database     - Used by frontend to display user dashboard     - Premium status determines feature availability

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getAuthenticationApi();
final String authorization = authorization_example; // String | Bearer token from Supabase Auth

try {
    final response = api.getCurrentUserInfoApiV1AuthMeGet(authorization);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthenticationApi->getCurrentUserInfoApiV1AuthMeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**| Bearer token from Supabase Auth | 

### Return type

[**MeResponse**](MeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

