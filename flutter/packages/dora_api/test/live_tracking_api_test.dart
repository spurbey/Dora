import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for LiveTrackingApi
void main() {
  final instance = DoraApi().getLiveTrackingApi();

  group(LiveTrackingApi, () {
    // Commit Auto Finalize
    //
    //Future<AutoFinalizeCommitResponse> commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost(String tripId, String xIdempotencyKey, String authorization, AutoFinalizeCommitRequest autoFinalizeCommitRequest) async
    test('test commitAutoFinalizeApiV1TripsTripIdAutoFinalizeCommitPost', () async {
      // TODO
    });

    // Confirm Checkin Candidate
    //
    //Future<CheckinActionResponse> confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost(String candidateId, String xIdempotencyKey, String authorization, CheckinConfirmRequest checkinConfirmRequest) async
    test('test confirmCheckinCandidateApiV1CheckinsCandidateIdConfirmPost', () async {
      // TODO
    });

    // Create Trip Moment
    //
    //Future<MomentResponse> createTripMomentApiV1TripsTripIdMomentsPost(String tripId, String xIdempotencyKey, String authorization, MomentCreateRequest momentCreateRequest) async
    test('test createTripMomentApiV1TripsTripIdMomentsPost', () async {
      // TODO
    });

    // Deactivate Device Token
    //
    //Future<DeviceTokenActionResponse> deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost(String xIdempotencyKey, String authorization, DeviceTokenDeactivateRequest deviceTokenDeactivateRequest) async
    test('test deactivateDeviceTokenApiV1NotificationsDeviceTokensDeactivatePost', () async {
      // TODO
    });

    // Get Tracking Path
    //
    //Future<TrackingPathResponse> getTrackingPathApiV1TripsTripIdTrackingPathGet(String tripId, String authorization, { String sessionId, int limit }) async
    test('test getTrackingPathApiV1TripsTripIdTrackingPathGet', () async {
      // TODO
    });

    // Ingest Events Batch
    //
    //Future<TrackingEventsBatchResponse> ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost(String tripId, String xIdempotencyKey, String authorization, TrackingEventsBatchRequest trackingEventsBatchRequest) async
    test('test ingestEventsBatchApiV1TripsTripIdTrackingEventsBatchPost', () async {
      // TODO
    });

    // Ingest Media Batch
    //
    //Future<TrackingMediaBatchResponse> ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost(String tripId, String xIdempotencyKey, String authorization, TrackingMediaBatchRequest trackingMediaBatchRequest) async
    test('test ingestMediaBatchApiV1TripsTripIdTrackingMediaBatchPost', () async {
      // TODO
    });

    // Ingest Points Batch
    //
    //Future<TrackingPointsBatchResponse> ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost(String tripId, String xIdempotencyKey, String authorization, TrackingPointsBatchRequest trackingPointsBatchRequest) async
    test('test ingestPointsBatchApiV1TripsTripIdTrackingPointsBatchPost', () async {
      // TODO
    });

    // List Pending Checkins
    //
    //Future<PendingCheckinsResponse> listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet(String tripId, String authorization) async
    test('test listPendingCheckinsApiV1TripsTripIdCheckinsPendingGet', () async {
      // TODO
    });

    // List Trip Moments
    //
    //Future<MomentListResponse> listTripMomentsApiV1TripsTripIdMomentsGet(String tripId, String authorization) async
    test('test listTripMomentsApiV1TripsTripIdMomentsGet', () async {
      // TODO
    });

    // Pause Tracking
    //
    //Future<TrackingSessionResponse> pauseTrackingApiV1TripsTripIdTrackingPausePost(String tripId, String xIdempotencyKey, String authorization, TrackingPauseRequest trackingPauseRequest) async
    test('test pauseTrackingApiV1TripsTripIdTrackingPausePost', () async {
      // TODO
    });

    // Register Device Token
    //
    //Future<DeviceTokenActionResponse> registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost(String xIdempotencyKey, String authorization, DeviceTokenRegisterRequest deviceTokenRegisterRequest) async
    test('test registerDeviceTokenApiV1NotificationsDeviceTokensRegisterPost', () async {
      // TODO
    });

    // Reject Checkin Candidate
    //
    //Future<CheckinActionResponse> rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost(String candidateId, String xIdempotencyKey, String authorization, CheckinRejectRequest checkinRejectRequest) async
    test('test rejectCheckinCandidateApiV1CheckinsCandidateIdRejectPost', () async {
      // TODO
    });

    // Resume Tracking
    //
    //Future<TrackingSessionResponse> resumeTrackingApiV1TripsTripIdTrackingResumePost(String tripId, String xIdempotencyKey, String authorization, TrackingResumeRequest trackingResumeRequest) async
    test('test resumeTrackingApiV1TripsTripIdTrackingResumePost', () async {
      // TODO
    });

    // Snooze Checkin Candidate
    //
    //Future<CheckinActionResponse> snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost(String candidateId, String xIdempotencyKey, String authorization, CheckinSnoozeRequest checkinSnoozeRequest) async
    test('test snoozeCheckinCandidateApiV1CheckinsCandidateIdSnoozePost', () async {
      // TODO
    });

    // Start Tracking
    //
    //Future<TrackingSessionResponse> startTrackingApiV1TripsTripIdTrackingStartPost(String tripId, String xIdempotencyKey, String authorization, TrackingStartRequest trackingStartRequest) async
    test('test startTrackingApiV1TripsTripIdTrackingStartPost', () async {
      // TODO
    });

    // Stop Tracking
    //
    //Future<TrackingSessionResponse> stopTrackingApiV1TripsTripIdTrackingStopPost(String tripId, String xIdempotencyKey, String authorization, TrackingStopRequest trackingStopRequest) async
    test('test stopTrackingApiV1TripsTripIdTrackingStopPost', () async {
      // TODO
    });

    // Update Trip Moment
    //
    //Future<MomentResponse> updateTripMomentApiV1MomentsMomentIdPatch(String momentId, String xIdempotencyKey, String authorization, MomentUpdateRequest momentUpdateRequest) async
    test('test updateTripMomentApiV1MomentsMomentIdPatch', () async {
      // TODO
    });

    // Upload Tracking Media Binary
    //
    //Future<TrackingMediaUploadResponse> uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost(String tripId, String authorization, MultipartFile file) async
    test('test uploadTrackingMediaBinaryApiV1TripsTripIdTrackingMediaUploadPost', () async {
      // TODO
    });

  });
}
