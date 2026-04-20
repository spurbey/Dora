import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for AdvisoryApi
void main() {
  final instance = DoraApi().getAdvisoryApi();

  group(AdvisoryApi, () {
    // Get Advisory State
    //
    // Return sanitized brain state for debugging.  Gated: requires owner + settings.EXPOSE_ADVISORY_STATE_ENDPOINT.
    //
    //Future<JsonObject> getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet(String tripId, String authorization) async
    test('test getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet', () async {
      // TODO
    });

    // List Advisory Insights
    //
    // Get advisories for inbox: status IN ('pending', 'delivered').
    //
    //Future<AdvisoryInsightListResponse> listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet(String tripId, String authorization, { String category, int page, int pageSize }) async
    test('test listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet', () async {
      // TODO
    });

    // List Advisory Jobs
    //
    //Future<AdvisoryJobListResponse> listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet(String tripId, String authorization, { String status, int page, int pageSize }) async
    test('test listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet', () async {
      // TODO
    });

    // Pause Advisory
    //
    // Manually pause the advisory brain for this trip (reason='user').  Manual pauses are sticky: only an explicit resume call clears them; incoming advisory actions won't auto-resume the pipeline.
    //
    //Future pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost(String tripId, String authorization) async
    test('test pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost', () async {
      // TODO
    });

    // Query Advisory
    //
    // Submit a natural-language query. Intent parsing happens in the worker, not here.
    //
    //Future<AdvisoryJobResponse> queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost(String tripId, String authorization, AdvisoryQueryRequest advisoryQueryRequest) async
    test('test queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost', () async {
      // TODO
    });

    // Record Advisory Action
    //
    // Record a user engagement action (append-only) and update the brain.
    //
    //Future<AdvisoryActionResponse> recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost(String advisoryId, String authorization, AdvisoryActionRequest advisoryActionRequest) async
    test('test recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost', () async {
      // TODO
    });

    // Resume Advisory
    //
    // Explicit user resume — clears manual pauses.
    //
    //Future resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost(String tripId, String authorization) async
    test('test resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost', () async {
      // TODO
    });

    // Start Advisory
    //
    // Create a pre_trip or location_trigger advisory job.
    //
    //Future<AdvisoryJobResponse> startAdvisoryApiV1TripsTripIdAdvisoryStartPost(String tripId, String authorization, AdvisoryStartRequest advisoryStartRequest) async
    test('test startAdvisoryApiV1TripsTripIdAdvisoryStartPost', () async {
      // TODO
    });

  });
}
