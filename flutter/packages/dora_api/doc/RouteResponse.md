# dora_api.model.RouteResponse

## Load the model package
```dart
import 'package:dora_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**transportMode** | **String** |  | 
**routeCategory** | **String** |  | 
**startPlaceId** | **String** |  | [optional] 
**endPlaceId** | **String** |  | [optional] 
**orderInTrip** | **int** |  | [optional] [default to 0]
**id** | **String** |  | 
**tripId** | **String** |  | 
**userId** | **String** |  | 
**routeGeojson** | [**JsonObject**](.md) |  | 
**polylineEncoded** | **String** |  | [optional] 
**distanceKm** | **num** |  | [optional] 
**durationMins** | **int** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


