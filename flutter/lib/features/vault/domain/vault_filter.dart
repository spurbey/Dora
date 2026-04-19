import 'package:flutter/foundation.dart';

/// Rolling-window time buckets for the Vault filter.
enum VaultTimeBucket {
  day(Duration(days: 1), 'Day'),
  week(Duration(days: 7), 'Week'),
  month(Duration(days: 30), 'Month'),
  year(Duration(days: 365), 'Year');

  const VaultTimeBucket(this.window, this.label);

  final Duration window;
  final String label;

  /// Returns whether [capturedAt] falls inside a rolling window of [window]
  /// ending at [now]. Non-UTC timestamps are converted before comparison.
  bool contains(DateTime capturedAt, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final captured = capturedAt.toUtc();
    return !captured.isBefore(reference.subtract(window));
  }
}

/// Distance-from-user radius chips.
enum VaultRadiusBucket {
  oneKm(1000, '1 km'),
  fiveKm(5000, '5 km'),
  twentyFiveKm(25000, '25 km'),
  all(null, 'All');

  const VaultRadiusBucket(this.meters, this.label);

  /// Null means "no radius filter".
  final int? meters;
  final String label;

  bool get hasRadius => meters != null;
}

@immutable
class VaultFilter {
  const VaultFilter({
    required this.time,
    required this.radius,
  });

  const VaultFilter.initial()
      : time = VaultTimeBucket.week,
        radius = VaultRadiusBucket.all;

  final VaultTimeBucket time;
  final VaultRadiusBucket radius;

  VaultFilter copyWith({
    VaultTimeBucket? time,
    VaultRadiusBucket? radius,
  }) {
    return VaultFilter(
      time: time ?? this.time,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaultFilter &&
        other.time == time &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(time, radius);
}
