# dora_api.api.DefaultApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthHealthGet**](DefaultApi.md#healthhealthget) | **GET** /health | Health
[**rootGet**](DefaultApi.md#rootget) | **GET** / | Root


# **healthHealthGet**
> JsonObject healthHealthGet()

Health

Health check endpoint.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getDefaultApi();

try {
    final response = api.healthHealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->healthHealthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rootGet**
> JsonObject rootGet()

Root

API root endpoint.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getDefaultApi();

try {
    final response = api.rootGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->rootGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

