/// Typed model for the advisory brain state returned by
/// `GET /trips/{id}/advisory/state`.
class AdvisoryBrainState {
  final String lifecycleState;
  final String tripClass;
  final int cadenceSeconds;
  final String mode;
  final DateTime? lastCycleAt;
  final DateTime? nextEligibleAt;
  final DateTime? lastSeedAt;
  final String? lastSeedReason;
  final int ignoreStreak;
  final int advisedLocalitiesCount;
  final int advisedPoisCount;
  final List<String> pendingReseedReasons;
  final String? pausedReason;
  final DateTime? pausedAt;
  final int brightdataCallCount;

  const AdvisoryBrainState({
    required this.lifecycleState,
    required this.tripClass,
    required this.cadenceSeconds,
    required this.mode,
    this.lastCycleAt,
    this.nextEligibleAt,
    this.lastSeedAt,
    this.lastSeedReason,
    this.ignoreStreak = 0,
    this.advisedLocalitiesCount = 0,
    this.advisedPoisCount = 0,
    this.pendingReseedReasons = const [],
    this.pausedReason,
    this.pausedAt,
    this.brightdataCallCount = 0,
  });

  factory AdvisoryBrainState.fromJson(Map<String, dynamic> json) {
    return AdvisoryBrainState(
      lifecycleState: json['lifecycle_state'] as String? ?? 'unknown',
      tripClass: json['trip_class'] as String? ?? 'unclassified',
      cadenceSeconds: (json['cadence_seconds'] as num?)?.toInt() ?? 3600,
      mode: json['mode'] as String? ?? 'route',
      lastCycleAt: _parseDateTime(json['last_cycle_at']),
      nextEligibleAt: _parseDateTime(json['next_eligible_at']),
      lastSeedAt: _parseDateTime(json['last_seed_at']),
      lastSeedReason: json['last_seed_reason'] as String?,
      ignoreStreak: (json['ignore_streak'] as num?)?.toInt() ?? 0,
      advisedLocalitiesCount:
          (json['advised_localities_count'] as num?)?.toInt() ?? 0,
      advisedPoisCount: (json['advised_pois_count'] as num?)?.toInt() ?? 0,
      pendingReseedReasons: (json['pending_reseed_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pausedReason: json['paused_reason'] as String?,
      pausedAt: _parseDateTime(json['paused_at']),
      brightdataCallCount:
          (json['brightdata_call_count'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  bool get isActive => lifecycleState == 'active';
  bool get isPaused => lifecycleState == 'paused';
  bool get isSeeded => lifecycleState == 'seeded';
}
