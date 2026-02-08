import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for ComponentsApi
void main() {
  final instance = DoraApi().getComponentsApi();

  group(ComponentsApi, () {
    // Get component details
    //
    // Get full details of a place or route component (auto-detects type)
    //
    //Future<TripComponentDetailResponse> getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet(String tripId, String componentId, String authorization) async
    test('test getComponentDetailsApiV1TripsTripIdComponentsComponentIdGet', () async {
      // TODO
    });

    // Get unified timeline
    //
    // Fetch all places and routes for a trip in chronological order
    //
    //Future<TripComponentListResponse> getComponentsApiV1TripsTripIdComponentsGet(String tripId, String authorization) async
    test('test getComponentsApiV1TripsTripIdComponentsGet', () async {
      // TODO
    });

    // Bulk reorder components
    //
    // Reorder places and routes with automatic normalization to 0,1,2,3...
    //
    //Future<ComponentReorderResponse> reorderComponentsApiV1TripsTripIdComponentsReorderPatch(String tripId, String authorization, ComponentReorderRequest componentReorderRequest) async
    test('test reorderComponentsApiV1TripsTripIdComponentsReorderPatch', () async {
      // TODO
    });

  });
}
