import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';

/// Lightweight DTO for the Camera FAB sheet banner — we only need trip id,
/// trip name, and the session state.
class ActiveLiveSessionSummary {
  const ActiveLiveSessionSummary({
    required this.tripId,
    required this.tripName,
    required this.sessionId,
    required this.controlState,
  });

  final String tripId;
  final String tripName;
  final String sessionId;
  final String controlState;
}

/// Watches `session_journal` for any active/paused session (the newest one
/// wins when several exist) and joins the trip name from `trips`. Emits `null`
/// when no live session is in progress.
final activeLiveSessionProvider =
    StreamProvider.autoDispose<ActiveLiveSessionSummary?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT
      s.session_id AS session_id,
      s.control_state AS control_state,
      s.trip_local_id AS trip_id,
      t.name AS trip_name,
      s.updated_at AS session_updated_at
    FROM session_journal AS s
    INNER JOIN trips AS t ON t.id = s.trip_local_id
    WHERE s.control_state IN ('active', 'paused')
    ORDER BY s.updated_at DESC
    LIMIT 1
    ''',
    variables: const [],
    readsFrom: {db.sessionJournal, db.trips},
  );

  return query.watch().map((rows) {
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return ActiveLiveSessionSummary(
      tripId: row.read<String>('trip_id'),
      tripName: row.read<String?>('trip_name') ?? 'your trip',
      sessionId: row.read<String>('session_id'),
      controlState: row.read<String>('control_state'),
    );
  });
});

