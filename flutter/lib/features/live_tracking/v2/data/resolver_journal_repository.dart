import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/resolver_attempt_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2ResolverJournalRepository {
  const V2ResolverJournalRepository({
    required ResolverCandidateJournalDao resolverCandidateDao,
    required ResolverAttemptJournalDao resolverAttemptDao,
  })  : _resolverCandidateDao = resolverCandidateDao,
        _resolverAttemptDao = resolverAttemptDao;

  final ResolverCandidateJournalDao _resolverCandidateDao;
  final ResolverAttemptJournalDao _resolverAttemptDao;

  Future<int> upsertCandidate({
    required String candidateId,
    required String eventId,
    required int candidateVersion,
    required String provider,
    String? providerPlaceId,
    required String name,
    String? label,
    required double latitude,
    required double longitude,
    double? confidenceScore,
    double? distanceM,
    required int rankIndex,
    int isTopTied = 0,
    String? rawJson,
    required DateTime createdAt,
  }) {
    return _resolverCandidateDao.upsertCandidate(
      ResolverCandidateJournalCompanion.insert(
        candidateId: candidateId,
        eventId: eventId,
        candidateVersion: candidateVersion,
        provider: provider,
        providerPlaceId: Value(providerPlaceId),
        name: name,
        label: Value(label),
        latitude: latitude,
        longitude: longitude,
        confidenceScore: Value(confidenceScore),
        distanceM: Value(distanceM),
        rankIndex: rankIndex,
        isTopTied: Value(isTopTied),
        rawJson: Value(rawJson),
        createdAt: createdAt.toUtc(),
      ),
    );
  }

  Future<List<ResolverCandidateJournalRow>> listCandidatesForEvent(
    String eventId,
  ) =>
      _resolverCandidateDao.listCandidatesForEvent(eventId);

  Future<List<ResolverCandidateJournalRow>> listLatestCandidatesForEvent(
    String eventId, {
    int limit = 3,
  }) =>
      _resolverCandidateDao.listLatestCandidatesForEvent(
        eventId,
        limit: limit,
      );

  Stream<List<ResolverCandidateJournalRow>> watchLatestCandidatesForEvent(
    String eventId, {
    int limit = 3,
  }) =>
      _resolverCandidateDao.watchLatestCandidatesForEvent(
        eventId,
        limit: limit,
      );

  Future<List<ResolverCandidateJournalRow>> listCandidatesForEvents(
    List<String> eventIds,
  ) =>
      _resolverCandidateDao.listCandidatesForEvents(eventIds);

  Future<int> upsertAttempt({
    required String attemptId,
    required String eventId,
    required int attemptNo,
    required String triggerReason,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String resultKind,
    String? errorCode,
    String? errorMessage,
  }) {
    return _resolverAttemptDao.upsertAttempt(
      ResolverAttemptJournalCompanion.insert(
        attemptId: attemptId,
        eventId: eventId,
        attemptNo: attemptNo,
        triggerReason: triggerReason,
        startedAt: startedAt.toUtc(),
        finishedAt: Value(finishedAt?.toUtc()),
        resultKind: resultKind,
        errorCode: Value(errorCode),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<ResolverAttemptJournalRow?> getAttemptById(String attemptId) =>
      _resolverAttemptDao.getAttemptById(attemptId);

  Future<List<ResolverAttemptJournalRow>> listAttemptsForEvent(
          String eventId) =>
      _resolverAttemptDao.listAttemptsForEvent(eventId);

  Stream<List<ResolverAttemptJournalRow>> watchAttemptsForEvent(
    String eventId,
  ) =>
      _resolverAttemptDao.watchAttemptsForEvent(eventId);
}
