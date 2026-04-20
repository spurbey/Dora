import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for LiveTrackingV2Api
void main() {
  final instance = DoraApi().getLiveTrackingV2Api();

  group(LiveTrackingV2Api, () {
    // Get V2 Route
    //
    //Future<V2RouteResponse> getV2RouteApiV2TripsTripIdRouteGet(String tripId, String authorization, { String cursor, int limitSegments }) async
    test('test getV2RouteApiV2TripsTripIdRouteGet', () async {
      // TODO
    });

    // Get V2 Timeline
    //
    //Future<V2TimelineResponse> getV2TimelineApiV2TripsTripIdTimelineGet(String tripId, String authorization, { String cursor, int limit }) async
    test('test getV2TimelineApiV2TripsTripIdTimelineGet', () async {
      // TODO
    });

    // Publish Commit
    //
    //Future<V2PublishCommitResponse> publishCommitApiV2TripsTripIdPublishCommitPost(String tripId, String authorization, V2PublishCommitRequest v2PublishCommitRequest, { String idempotencyKey }) async
    test('test publishCommitApiV2TripsTripIdPublishCommitPost', () async {
      // TODO
    });

    // Publish Media Complete
    //
    //Future<V2PublishMediaCompleteResponse> publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost(String tripId, String authorization, V2PublishMediaCompleteRequest v2PublishMediaCompleteRequest, { String idempotencyKey }) async
    test('test publishMediaCompleteApiV2TripsTripIdPublishMediaCompletePost', () async {
      // TODO
    });

    // Publish Payload Chunk
    //
    //Future<V2PublishPayloadChunkResponse> publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost(String tripId, String authorization, V2PublishPayloadChunkRequest v2PublishPayloadChunkRequest, { String idempotencyKey }) async
    test('test publishPayloadChunkApiV2TripsTripIdPublishPayloadChunkPost', () async {
      // TODO
    });

    // Publish Start
    //
    //Future<V2PublishStartResponse> publishStartApiV2TripsTripIdPublishStartPost(String tripId, String authorization, V2PublishStartRequest v2PublishStartRequest, { String idempotencyKey }) async
    test('test publishStartApiV2TripsTripIdPublishStartPost', () async {
      // TODO
    });

    // Start V2 Session
    //
    //Future<V2SessionResponse> startV2SessionApiV2TripsTripIdSessionsStartPost(String tripId, String authorization, V2SessionStartRequest v2SessionStartRequest, { String idempotencyKey }) async
    test('test startV2SessionApiV2TripsTripIdSessionsStartPost', () async {
      // TODO
    });

    // Stop V2 Session
    //
    //Future<V2SessionResponse> stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost(String tripId, String clientSessionId, String authorization, V2SessionStopRequest v2SessionStopRequest, { String idempotencyKey }) async
    test('test stopV2SessionApiV2TripsTripIdSessionsClientSessionIdStopPost', () async {
      // TODO
    });

  });
}
