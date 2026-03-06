import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/focus_stats.dart';

void main() {
  group('FocusStats', () {
    test('creates with default values', () {
      final stats = FocusStats();

      expect(stats.blockedAppsCount, 0);
      expect(stats.totalFocusMinutes, 0);
      expect(stats.streakDays, 0);
      expect(stats.totalSessions, 0);
      expect(stats.lastSessionDate, isNull);
      expect(stats.dailyFocusMinutes.length, 7);
    });

    test('focusHours calculates correctly', () {
      final stats = FocusStats(totalFocusMinutes: 150);
      expect(stats.focusHours, 2.5);
    });

    test('recordSession increments totalSessions', () {
      final stats = FocusStats();
      stats.recordSession(durationMinutes: 60, appsBlocked: 3);

      expect(stats.totalSessions, 1);
      expect(stats.totalFocusMinutes, 60);
      expect(stats.blockedAppsCount, 3);
    });

    test('recordSession updates streak on first session', () {
      final stats = FocusStats();
      stats.recordSession(durationMinutes: 60, appsBlocked: 3);

      expect(stats.streakDays, 1);
      expect(stats.lastSessionDate, isNotNull);
    });

    test('updateStreak keeps streak on same day', () {
      final stats = FocusStats(lastSessionDate: DateTime.now(), streakDays: 5);
      stats.updateStreak();

      expect(stats.streakDays, 5); // No change, same day
    });

    test('updateStreak increments on consecutive day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final stats = FocusStats(lastSessionDate: yesterday, streakDays: 3);
      stats.updateStreak();

      expect(stats.streakDays, 4);
    });

    test('updateStreak resets on gap day', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final stats = FocusStats(lastSessionDate: twoDaysAgo, streakDays: 10);
      stats.updateStreak();

      expect(stats.streakDays, 1); // Reset
    });

    test('multiple sessions accumulate focus minutes', () {
      final stats = FocusStats();
      stats.recordSession(durationMinutes: 60, appsBlocked: 3);
      stats.recordSession(durationMinutes: 120, appsBlocked: 5);

      expect(stats.totalFocusMinutes, 180);
      expect(stats.totalSessions, 2);
      expect(stats.blockedAppsCount, 5); // Last session's count
    });

    test('dailyFocusMinutes accumulates for same day', () {
      final stats = FocusStats();
      stats.recordSession(durationMinutes: 60, appsBlocked: 2);
      stats.recordSession(durationMinutes: 30, appsBlocked: 2);

      expect(stats.dailyFocusMinutes[0], 90);
    });

    test('toJson and fromJson roundtrip', () {
      final stats = FocusStats(
        blockedAppsCount: 5,
        totalFocusMinutes: 300,
        streakDays: 7,
        totalSessions: 12,
        lastSessionDate: DateTime(2024, 6, 15),
        dailyFocusMinutes: [10, 20, 30, 40, 50, 60, 70],
      );

      final json = stats.toJson();
      final restored = FocusStats.fromJson(json);

      expect(restored.blockedAppsCount, 5);
      expect(restored.totalFocusMinutes, 300);
      expect(restored.streakDays, 7);
      expect(restored.totalSessions, 12);
      expect(restored.dailyFocusMinutes, [10, 20, 30, 40, 50, 60, 70]);
    });

    test('toString contains relevant info', () {
      final stats = FocusStats(
        blockedAppsCount: 3,
        totalFocusMinutes: 120,
        streakDays: 5,
      );
      final str = stats.toString();

      expect(str, contains('3'));
      expect(str, contains('5'));
    });
  });
}
