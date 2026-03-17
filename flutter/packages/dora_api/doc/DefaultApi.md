# dora_api.api.DefaultApi

## Load the API package
```dart
import 'package:dora_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthHealthGet**](DefaultApi.md#healthhealthget) | **GET** /health | Health
[**readyReadyGet**](DefaultApi.md#readyreadyget) | **GET** /ready | Ready
[**rootGet**](DefaultApi.md#rootget) | **GET** / | Root


# **healthHealthGet**
> JsonObject healthHealthGet()

Health

Liveness probe — lightweight, always 200 if process is running. Railway health check should point here to avoid restart loops during transient DB blips.

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

# **readyReadyGet**
> JsonObject readyReadyGet()

Ready

Readiness probe — checks DB connectivity. Use for monitoring/alerting, not for container restarts.

### Example
```dart
import 'package:dora_api/api.dart';

final api = DoraApi().getDefaultApi();

try {
    final response = api.readyReadyGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->readyReadyGet: $e\n');
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

