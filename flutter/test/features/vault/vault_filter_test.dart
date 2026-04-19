import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/vault/domain/vault_filter.dart';

void main() {
  group('VaultTimeBucket.contains', () {
    final now = DateTime.utc(2026, 4, 19, 12, 0);

    test('day bucket includes the last 24 hours', () {
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 23));
      final thirtyHoursAgo = now.subtract(const Duration(hours: 30));

      expect(VaultTimeBucket.day.contains(twentyFourHoursAgo, now: now), isTrue);
      expect(VaultTimeBucket.day.contains(thirtyHoursAgo, now: now), isFalse);
    });

    test('week bucket includes the last 7 days', () {
      final sixDaysAgo = now.subtract(const Duration(days: 6));
      final eightDaysAgo = now.subtract(const Duration(days: 8));

      expect(VaultTimeBucket.week.contains(sixDaysAgo, now: now), isTrue);
      expect(VaultTimeBucket.week.contains(eightDaysAgo, now: now), isFalse);
    });

    test('month bucket includes the last 30 days', () {
      final twentyNineDaysAgo = now.subtract(const Duration(days: 29));
      final thirtyOneDaysAgo = now.subtract(const Duration(days: 31));

      expect(
        VaultTimeBucket.month.contains(twentyNineDaysAgo, now: now),
        isTrue,
      );
      expect(
        VaultTimeBucket.month.contains(thirtyOneDaysAgo, now: now),
        isFalse,
      );
    });

    test('year bucket includes the last 365 days', () {
      final earlierThisYear = now.subtract(const Duration(days: 364));
      final twoYearsAgo = now.subtract(const Duration(days: 400));

      expect(VaultTimeBucket.year.contains(earlierThisYear, now: now), isTrue);
      expect(VaultTimeBucket.year.contains(twoYearsAgo, now: now), isFalse);
    });

    test('respects the inclusive boundary', () {
      final exactlyOneWeekAgo = now.subtract(const Duration(days: 7));
      expect(
        VaultTimeBucket.week.contains(exactlyOneWeekAgo, now: now),
        isTrue,
      );
    });

    test('normalises to UTC before comparing', () {
      // Caller may pass a non-UTC DateTime; bucket should still compare
      // correctly after conversion.
      final nowLocal = now.toLocal();
      final sixMinutesAgoLocal = now.subtract(const Duration(minutes: 6)).toLocal();
      expect(
        VaultTimeBucket.day.contains(sixMinutesAgoLocal, now: nowLocal),
        isTrue,
      );
    });
  });

  group('VaultRadiusBucket', () {
    test('all has no radius', () {
      expect(VaultRadiusBucket.all.hasRadius, isFalse);
      expect(VaultRadiusBucket.all.meters, isNull);
    });

    test('numeric buckets expose meters in ascending order', () {
      expect(VaultRadiusBucket.oneKm.meters, 1000);
      expect(VaultRadiusBucket.fiveKm.meters, 5000);
      expect(VaultRadiusBucket.twentyFiveKm.meters, 25000);
    });
  });

  group('VaultFilter', () {
    test('initial state is Week × All', () {
      const initial = VaultFilter.initial();
      expect(initial.time, VaultTimeBucket.week);
      expect(initial.radius, VaultRadiusBucket.all);
    });

    test('copyWith replaces only the supplied fields', () {
      const base = VaultFilter.initial();
      final timeChanged = base.copyWith(time: VaultTimeBucket.day);
      expect(timeChanged.time, VaultTimeBucket.day);
      expect(timeChanged.radius, base.radius);

      final radiusChanged = base.copyWith(radius: VaultRadiusBucket.fiveKm);
      expect(radiusChanged.radius, VaultRadiusBucket.fiveKm);
      expect(radiusChanged.time, base.time);
    });

    test('equality is value-based', () {
      const a = VaultFilter.initial();
      const b = VaultFilter.initial();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.copyWith(time: VaultTimeBucket.day), isFalse);
    });
  });
}
