# dora_api.model.PlaceResponse

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
**name** | **String** |  | 
**placeType** | **String** |  | [optional] 
**lat** | **num** |  | 
**lng** | **num** |  | 
**userNotes** | **String** |  | [optional] 
**userRating** | **int** |  | [optional] 
**visitDate** | [**Date**](Date.md) |  | [optional] 
**photos** | [**BuiltList&lt;MediaResponse&gt;**](MediaResponse.md) |  | [optional] [default to ListBuilder()]
**videos** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;&gt;**](BuiltMap.md) |  | [optional] [default to ListBuilder()]
**externalData** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**orderInTrip** | **int** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


