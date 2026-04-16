# dora_api.model.CheckinCandidateResponse

## Load the model package
```dart
import 'package:dora_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**tripId** | **String** |  | 
**userId** | **String** |  | 
**sessionId** | **String** |  | [optional] 
**fingerprint** | **String** |  | 
**status** | **String** |  | 
**confidence** | **num** |  | 
**suggestedName** | **String** |  | [optional] 
**suggestedLatitude** | **num** |  | [optional] 
**suggestedLongitude** | **num** |  | [optional] 
**startedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**endedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**confirmedTripPlaceId** | **String** |  | [optional] 
**rejectedReason** | **String** |  | [optional] 
**snoozedUntil** | [**DateTime**](DateTime.md) |  | [optional] 
**cooldownUntil** | [**DateTime**](DateTime.md) |  | [optional] 
**payload** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


