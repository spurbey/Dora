# dora_api.model.AdvisoryInsightResponse

## Load the model package
```dart
import 'package:dora_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**category** | [**AdvisoryCategory**](AdvisoryCategory.md) |  | 
**source_** | [**AdvisorySource**](AdvisorySource.md) |  | 
**title** | **String** |  | 
**body** | **String** |  | 
**placeName** | **String** |  | [optional] 
**placeLat** | **num** |  | [optional] 
**placeLng** | **num** |  | [optional] 
**confidenceScore** | **num** |  | 
**contextSignal** | **String** |  | [optional] 
**bestFor** | **String** |  | [optional] 
**sourceUrls** | **BuiltList&lt;String&gt;** |  | [optional] 
**sourceCount** | **int** |  | [optional] [default to 1]
**status** | [**AdvisoryDeliveryStatus**](AdvisoryDeliveryStatus.md) |  | 
**observedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**deliveredAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


