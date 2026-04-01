# dora_api.model.TrackingSessionResponse

## Load the model package
```dart
import 'package:dora_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sessionId** | **String** |  | 
**tripId** | **String** |  | 
**userId** | **String** |  | 
**state** | **String** |  | 
**clientSessionId** | **String** |  | 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**pausedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**resumedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**endedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**abandonedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**lastPointAt** | [**DateTime**](DateTime.md) |  | [optional] 
**timezone** | **String** |  | [optional] 
**deviceContext** | [**JsonObject**](.md) |  | [optional] 
**tripStatus** | **String** |  | 
**trackingEnabled** | **bool** |  | 
**trackingStartedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**trackingEndedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


