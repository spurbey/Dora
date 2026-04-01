# dora_api.model.CompiledProjectionResponse

## Load the model package
```dart
import 'package:dora_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**tripId** | **String** |  | 
**compilerVersion** | **int** |  | 
**stale** | **bool** |  | 
**compiledAt** | [**DateTime**](DateTime.md) |  | [optional] 
**timelineEntries** | [**BuiltList&lt;CompiledTimelineEntry&gt;**](CompiledTimelineEntry.md) |  | [optional] 
**timelineGroups** | [**BuiltList&lt;CompiledTimelineDayGroup&gt;**](CompiledTimelineDayGroup.md) |  | [optional] 
**routeSegments** | [**BuiltList&lt;CompiledRouteSegment&gt;**](CompiledRouteSegment.md) |  | [optional] 
**stats** | [**CompiledProjectionStats**](CompiledProjectionStats.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


