import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/focus_stats.dart';

void main() {
  group('FocusStats', () {
    group('constructor defaults', () {
      test('creates with all zeros and null date', () {
        final stats = FocusStats();
        expect(stats.blockedAppsCount, 0);
        expect(stats.totalFocusMinutes, 0);
        expect(stats.streakDays, 0);
        expect(stats.totalSessions, 0);
        expect(stats.lastSessionDate, null);
      });

      test('dailyFocusMinutes defaults to 7 zeros', () {
        final stats = FocusStats();
        expect(stats.dailyFocusMinutes, [0, 0, 0, 0, 0, 0, 0]);
        expect(stats.dailyFocusMinutes.length, 7);
      });

      test('allows custom initial values', () {
        final date = DateTime(2026, 3, 1);
        final stats = FocusStats(
          blockedAppsCount: 5,
          totalFocusMinutes: 120,
          streakDays: 3,
          totalSessions: 10,
          lastSessionDate: date,
          dailyFocusMinutes: [60, 30, 45, 0, 0, 0, 0],
        );
        expect(stats.blockedAppsCount, 5);
        expect(stats.totalFocusMinutes, 120);
        expect(stats.streakDays, 3);
        expect(stats.totalSessions, 10);
        expect(stats.lastSessionDate, date);
        expect(stats.dailyFocusMinutes, [60, 30, 45, 0, 0, 0, 0]);
      });
    });

    group('focusHours', () {
      test('returns 0.0 for zero minutes', () {
        final stats = FocusStats();
        expect(stats.focusHours, 0.0);
      });

      test('returns 1.0 for 60 minutes', () {
        final stats = FocusStats(totalFocusMinutes: 60);
        expect(stats.focusHours, 1.0);
      });

      test('returns 2.5 for 150 minutes', () {
        final stats = FocusStats(totalFocusMinutes: 150);
        expect(stats.focusHours, 2.5);
      });

      test('returns fractional hours correctly', () {
        final stats = FocusStats(totalFocusMinutes: 90);
        expect(stats.focusHours, 1.5);
      });
    });

    group('updateStreak()', () {
      test('sets streak to 1 when lastSessionDate is null', () {
        final stats = FocusStats();
        stats.updateStreak();
        expect(stats.streakDays, 1);
        expect(stats.lastSessionDate, isNotNull);
      });

      test('increments streak when last session was yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = FocusStats(lastSessionDate: yesterday, streakDays: 5);
        stats.updateStreak();
        expect(stats.streakDays, 6);
      });

      test('keeps streak same when last session was today', () {
        final today = DateTime.now();
        final stats = FocusStats(lastSessionDate: today, streakDays: 3);
        stats.updateStreak();
        expect(stats.streakDays, 3);
      });

      test('resets streak to 1 when gap is 2+ days', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final stats = FocusStats(lastSessionDate: threeDaysAgo, streakDays: 15);
        stats.updateStreak();
        expect(stats.streakDays, 1);
      });

      test('resets streak to 1 when gap is exactly 2 days', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final stats = FocusStats(lastSessionDate: twoDaysAgo, streakDays: 7);
        stats.updateStreak();
        expect(stats.streakDays, 1);
      });

      test('updates lastSessionDate to now', () {
        final before = DateTime.now();
        final stats = FocusStats();
        stats.updateStreak();
        final after = DateTime.now();

        expect(
          stats.lastSessionDate!.isAfter(before) ||
              stats.lastSessionDate == before,
          true,
        );
        expect(
          stats.lastSessionDate!.isBefore(after) ||
              stats.lastSessionDate == after,
          true,
        );
      });
    });

    group('recordSession()', () {
      test('increments totalSessions', () {
        final stats = FocusStats(totalSessions: 5);
        stats.recordSession(durationMinutes: 60, appsBlocked: 3);
        expect(stats.totalSessions, 6);
      });

      test('adds duration to totalFocusMinutes', () {
        final stats = FocusStats(totalFocusMinutes: 100);
        stats.recordSession(durationMinutes: 45, appsBlocked: 2);
        expect(stats.totalFocusMinutes, 145);
      });

      test('updates blockedAppsCount', () {
        final stats = FocusStats(blockedAppsCount: 0);
        stats.recordSession(durationMinutes: 30, appsBlocked: 8);
        expect(stats.blockedAppsCount, 8);
      });

      test('calls updateStreak internally', () {
        final stats = FocusStats();
        stats.recordSession(durationMinutes: 60, appsBlocked: 3);
        expect(stats.streakDays, 1);
        expect(stats.lastSessionDate, isNotNull);
      });

      test('adds minutes to dailyFocusMinutes[0]', () {
        final stats = FocusStats(
          lastSessionDate: DateTime.now(),
          dailyFocusMinutes: [10, 0, 0, 0, 0, 0, 0],
        );
        stats.recordSession(durationMinutes: 50, appsBlocked: 2);
        expect(stats.dailyFocusMinutes[0], 60);
      });

      test('multiple sessions same day accumulate', () {
        final stats = FocusStats(
          lastSessionDate: DateTime.now(),
          dailyFocusMinutes: [0, 0, 0, 0, 0, 0, 0],
        );
        stats.recordSession(durationMinutes: 30, appsBlocked: 2);
        stats.recordSession(durationMinutes: 45, appsBlocked: 2);
        expect(stats.dailyFocusMinutes[0], 75);
      });

      test('shifts daily minutes when day changes', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = FocusStats(
          lastSessionDate: yesterday,
          dailyFocusMinutes: [60, 30, 0, 0, 0, 0, 0],
        );
        stats.recordSession(durationMinutes: 45, appsBlocked: 3);
        // After shift: [45, 60, 30, 0, 0, 0, 0]
        expect(stats.dailyFocusMinutes[0], 45);
        expect(stats.dailyFocusMinutes[1], 60);
        expect(stats.dailyFocusMinutes[2], 30);
      });

      test('keeps dailyFocusMinutes at length 7', () {
        final stats = FocusStats(
          lastSessionDate: DateTime.now().subtract(const Duration(days: 10)),
          dailyFocusMinutes: [10, 20, 30, 40, 50, 60, 70],
        );
        stats.recordSession(durationMinutes: 100, appsBlocked: 1);
        expect(stats.dailyFocusMinutes.length, 7);
      });
    });

    group('JSON serialization', () {
      test('roundtrip preserves all fields', () {
        final date = DateTime(2026, 3, 1, 12, 0);
        final stats = FocusStats(
          blockedAppsCount: 5,
          totalFocusMinutes: 300,
          streakDays: 7,
          totalSessions: 20,
          lastSessionDate: date,
          dailyFocusMinutes: [60, 45, 30, 0, 90, 15, 0],
        );
        final json = stats.toJson();
        final restored = FocusStats.fromJson(json);

        expect(restored.blockedAppsCount, 5);
        expect(restored.totalFocusMinutes, 300);
        expect(restored.streakDays, 7);
        expect(restored.totalSessions, 20);
        expect(restored.lastSessionDate, date);
        expect(restored.dailyFocusMinutes, [60, 45, 30, 0, 90, 15, 0]);
      });

      test('fromJson handles null values with defaults', () {
        final json = <String, dynamic>{};
        final stats = FocusStats.fromJson(json);

        expect(stats.blockedAppsCount, 0);
        expect(stats.totalFocusMinutes, 0);
        expect(stats.streakDays, 0);
        expect(stats.totalSessions, 0);
        expect(stats.lastSessionDate, null);
        expect(stats.dailyFocusMinutes, [0, 0, 0, 0, 0, 0, 0]);
      });

      test('toJson contains expected keys', () {
        final stats = FocusStats();
        final json = stats.toJson();

        expect(json.containsKey('blockedAppsCount'), true);
        expect(json.containsKey('totalFocusMinutes'), true);
        expect(json.containsKey('streakDays'), true);
        expect(json.containsKey('totalSessions'), true);
        expect(json.containsKey('lastSessionDate'), true);
        expect(json.containsKey('dailyFocusMinutes'), true);
      });

      test('toJson with null lastSessionDate', () {
        final stats = FocusStats();
        final json = stats.toJson();
        expect(json['lastSessionDate'], null);
      });
    });

    group('toString()', () {
      test('returns descriptive string', () {
        final stats = FocusStats(
          blockedAppsCount: 3,
          totalFocusMinutes: 90,
          streakDays: 5,
        );
        final str = stats.toString();
        expect(str, contains('FocusStats'));
        expect(str, contains('blocked: 3'));
        expect(str, contains('streak: 5'));
      });
    });
  });
}
