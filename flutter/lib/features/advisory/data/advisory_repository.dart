import 'package:dio/dio.dart';
import 'package:dora/core/auth/auth_service.dart';
import 'package:dora_api/dora_api.dart';
import 'package:flutter/foundation.dart';

import 'package:dora/features/advisory/data/models/advisory_brain_state.dart';

/// Typed exception for advisory API errors.
class AdvisoryException implements Exception {
  final String message;
  final int? statusCode;
  AdvisoryException(this.message, {this.statusCode});

  @override
  String toString() => 'AdvisoryException($statusCode): $message';
}

/// Wraps the generated [AdvisoryApi] with typed, error-handled methods.
///
/// Follows the same pattern as [FeedApi] / [TripsApi] wrappers: takes
/// the generated API class + [AuthService], builds the Bearer header per
/// call, and rethrows [DioException] as typed [AdvisoryException].
class AdvisoryRepository {
  AdvisoryRepository(this._api, this._authService);

  final AdvisoryApi _api;
  final AuthService _authService;

  Future<String> _auth() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AdvisoryException('Missing auth token');
    }
    return 'Bearer $token';
  }

  // ── Job creation ──────────────────────────────────────────────

  Future<AdvisoryJobResponse> startAdvisory(
    String tripId, {
    AdvisoryJobType jobType = AdvisoryJobType.preTrip,
  }) async {
    try {
      final resp =
          await _api.startAdvisoryApiV1TripsTripIdAdvisoryStartPost(
        tripId: tripId,
        authorization: await _auth(),
        advisoryStartRequest: AdvisoryStartRequest((b) => b
          ..jobType = jobType),
      );
      return resp.data!;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<AdvisoryJobResponse> queryAdvisory(
    String tripId,
    String queryText,
  ) async {
    try {
      final resp =
          await _api.queryAdvisoryApiV1TripsTripIdAdvisoryQueryPost(
        tripId: tripId,
        authorization: await _auth(),
        advisoryQueryRequest:
            AdvisoryQueryRequest((b) => b..queryText = queryText),
      );
      return resp.data!;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ── Queries ───────────────────────────────────────────────────

  Future<AdvisoryInsightListResponse> listInsights(
    String tripId, {
    String? category,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final resp = await _api
          .listAdvisoryInsightsApiV1TripsTripIdAdvisoryInsightsGet(
        tripId: tripId,
        authorization: await _auth(),
        category: category,
        page: page,
        pageSize: pageSize,
      );
      return resp.data!;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<AdvisoryJobListResponse> listJobs(
    String tripId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final resp =
          await _api.listAdvisoryJobsApiV1TripsTripIdAdvisoryJobsGet(
        tripId: tripId,
        authorization: await _auth(),
        status: status,
        page: page,
        pageSize: pageSize,
      );
      return resp.data!;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<AdvisoryActionResponse> recordAction(
    String advisoryId,
    UserActionType action,
  ) async {
    try {
      final resp = await _api
          .recordAdvisoryActionApiV1AdvisoryAdvisoryIdActionPost(
        advisoryId: advisoryId,
        authorization: await _auth(),
        advisoryActionRequest: AdvisoryActionRequest((b) => b
          ..action = action),
      );
      return resp.data!;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ── Brain control ─────────────────────────────────────────────

  Future<void> pauseAdvisory(String tripId) async {
    try {
      await _api.pauseAdvisoryApiV1TripsTripIdAdvisoryPausePost(
        tripId: tripId,
        authorization: await _auth(),
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> resumeAdvisory(String tripId) async {
    try {
      await _api.resumeAdvisoryApiV1TripsTripIdAdvisoryResumePost(
        tripId: tripId,
        authorization: await _auth(),
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<AdvisoryBrainState> getAdvisoryState(String tripId) async {
    try {
      final resp =
          await _api.getAdvisoryStateApiV1TripsTripIdAdvisoryStateGet(
        tripId: tripId,
        authorization: await _auth(),
      );
      final raw = resp.data?.asMap ?? {};
      return AdvisoryBrainState.fromJson(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ── Error handling ────────────────────────────────────────────

  AdvisoryException _wrap(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String msg;
    if (body is Map) {
      msg = body['detail']?.toString() ?? e.message ?? 'Unknown error';
    } else {
      msg = e.message ?? 'Unknown error';
    }
    debugPrint('[AdvisoryRepository] $status: $msg');
    return AdvisoryException(msg, statusCode: status);
  }

  // ── Conversation (chat with Dora) ─────────────────────────────

  Future<ConversationListResponse> listConversation(
    String tripId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final resp = await _api
          .listConversationMessagesApiV1TripsTripIdConversationMessagesGet(
        tripId: tripId,
        authorization: await _auth(),
        limit: limit,
        before: before,
      );
      final data = resp.data;
      if (data == null) {
        throw AdvisoryException('Empty conversation response');
      }
      return data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<SendMessageResponse> sendConversationMessage(
    String tripId,
    String content,
  ) async {
    try {
      final resp = await _api
          .sendConversationMessageApiV1TripsTripIdConversationSendPost(
        tripId: tripId,
        authorization: await _auth(),
        sendMessageRequest: SendMessageRequest(
          (b) => b..content = content,
        ),
      );
      final data = resp.data;
      if (data == null) {
        throw AdvisoryException('Empty send response');
      }
      return data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<AnswerQuestionResponse> answerConversationQuestion(
    String tripId,
    String questionMessageId,
    String answer, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final resp = await _api
          .answerConversationQuestionApiV1TripsTripIdConversationAnswerPost(
        tripId: tripId,
        authorization: await _auth(),
        answerQuestionRequest: AnswerQuestionRequest((b) {
          b
            ..questionMessageId = questionMessageId
            ..answer = answer;
        }),
      );
      final data = resp.data;
      if (data == null) {
        throw AdvisoryException('Empty answer response');
      }
      return data;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }
}
