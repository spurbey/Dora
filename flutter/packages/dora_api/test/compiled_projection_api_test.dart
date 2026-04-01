import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for CompiledProjectionApi
void main() {
  final instance = DoraApi().getCompiledProjectionApi();

  group(CompiledProjectionApi, () {
    // Get Compiled Projection
    //
    //Future<CompiledProjectionResponse> getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet(String tripId, String authorization) async
    test('test getCompiledProjectionApiV1TripsTripIdCompiledProjectionGet', () async {
      // TODO
    });

    // Rebind Compiled Projection Item
    //
    //Future<CompiledProjectionResponse> rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost(String tripId, String authorization, CompiledRebindRequest compiledRebindRequest) async
    test('test rebindCompiledProjectionItemApiV1TripsTripIdCompiledRebindPost', () async {
      // TODO
    });

  });
}
