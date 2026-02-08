# dora_api.model.RouteCreate

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
**routeGeojson** | [**JsonObject**](.md) | Must be valid GeoJSON LineString | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


