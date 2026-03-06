import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/focus_timer.dart';
import 'package:study_lock/core/models/focus_stats.dart';

/// Tests for edge cases like reboot, timer expiry while phone locked, etc.
void main() {
  group('Edge Cases', () {
    test('Timer survives simulated reboot (serialization roundtrip)', () {
      // Timer starts, phone reboots, timer is restored from storage
      final timer = FocusTimer.start(hours: 10, minutes: 0);
      final json = timer.toJson();

      // Simulate restoring timer after reboot
      final restored = FocusTimer.fromJson(json);

      expect(restored.durationMinutes, 600);
      expect(restored.isActive, true);
      expect(restored.isExpired, false);
      expect(restored.remainingTime.inMinutes, closeTo(600, 1));
    });

    test('Timer expires while phone is locked/off', () {
      // Simulate a timer that was set 5 hours ago for 2 hours
      final timer = FocusTimer(
        startTime: DateTime.now().subtract(const Duration(hours: 5)),
        durationMinutes: 120,
        unlockTime: DateTime.now().subtract(const Duration(hours: 3)),
        isActive: true,
      );

      expect(timer.isExpired, true);
      expect(timer.remainingTime, Duration.zero);
      expect(timer.progress, 1.0);
    });

    test('Timer with very long duration (24 hours)', () {
      final timer = FocusTimer.start(hours: 24, minutes: 0);

      expect(timer.durationMinutes, 1440);
      expect(timer.isExpired, false);
      expect(timer.remainingHours, closeTo(24, 1));
    });

    test('Timer start and immediate check', () {
      final timer = FocusTimer.start(hours: 1, minutes: 0);

      // Should not be expired right after creation
      expect(timer.isExpired, false);
      expect(timer.isActive, true);
      expect(timer.progress, closeTo(0.0, 0.01));
    });

    test('Stopped timer reports inactive', () {
      final timer = FocusTimer.start(hours: 5, minutes: 0);
      final stopped = timer.copyWithStopped();

      expect(stopped.isActive, false);
      // Even though unlock time hasn't passed, the timer was stopped
    });

    test('FocusStats streak resets after 2+ day gap', () {
      // User was active 3 days ago
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final stats = FocusStats(lastSessionDate: threeDaysAgo, streakDays: 15);

      stats.updateStreak();
      expect(stats.streakDays, 1); // Reset to 1 (today's new streak)
    });

    test('FocusStats handles null lastSessionDate', () {
      final stats = FocusStats();
      stats.updateStreak();

      expect(stats.streakDays, 1);
      expect(stats.lastSessionDate, isNotNull);
    });
  });
}
