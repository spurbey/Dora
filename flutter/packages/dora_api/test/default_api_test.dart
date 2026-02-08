import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for DefaultApi
void main() {
  final instance = DoraApi().getDefaultApi();

  group(DefaultApi, () {
    // Health
    //
    // Health check endpoint.
    //
    //Future<JsonObject> healthHealthGet() async
    test('test healthHealthGet', () async {
      // TODO
    });

    // Root
    //
    // API root endpoint.
    //
    //Future<JsonObject> rootGet() async
    test('test rootGet', () async {
      // TODO
    });

  });
}
