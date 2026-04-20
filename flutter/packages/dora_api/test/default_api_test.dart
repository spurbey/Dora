import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for DefaultApi
void main() {
  final instance = DoraApi().getDefaultApi();

  group(DefaultApi, () {
    // Health
    //
    // Liveness probe — lightweight, always 200 if process is running. Railway health check should point here to avoid restart loops during transient DB blips.
    //
    //Future<JsonObject> healthHealthGet() async
    test('test healthHealthGet', () async {
      // TODO
    });

    // Ready
    //
    // Readiness probe — checks DB connectivity. Use for monitoring/alerting, not for container restarts.
    //
    //Future<JsonObject> readyReadyGet() async
    test('test readyReadyGet', () async {
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
