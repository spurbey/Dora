import 'package:drift/drift.dart';

@TableIndex(
  name: 'resolver_candidate_journal_event_version_rank_idx',
  columns: {#eventId, #candidateVersion, #rankIndex},
)
@TableIndex(
  name: 'resolver_candidate_journal_event_version_tie_idx',
  columns: {#eventId, #candidateVersion, #isTopTied},
)
@DataClassName('ResolverCandidateJournalRow')
class ResolverCandidateJournal extends Table {
  @override
  String get tableName => 'resolver_candidate_journal';

  TextColumn get candidateId => text()();
  TextColumn get eventId => text()();
  IntColumn get candidateVersion => integer()();
  TextColumn get provider => text()();
  TextColumn get providerPlaceId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get label => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get confidenceScore => real().nullable()();
  RealColumn get distanceM => real().nullable()();
  IntColumn get rankIndex => integer()();
  IntColumn get isTopTied => integer().withDefault(const Constant(0))();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {candidateId};
}
