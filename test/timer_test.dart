import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/focus_timer.dart';

void main() {
  group('FocusTimer', () {
    test('start() creates timer with correct unlock time', () {
      final timer = FocusTimer.start(hours: 2, minutes: 30);
      final expectedDuration = const Duration(hours: 2, minutes: 30);

      expect(timer.durationMinutes, 150);
      expect(timer.isActive, true);
      expect(
        timer.unlockTime.difference(timer.startTime).inMinutes,
        expectedDuration.inMinutes,
      );
    });

    test('start() with zero duration creates zero-length timer', () {
      final timer = FocusTimer.start(hours: 0, minutes: 0);

      expect(timer.durationMinutes, 0);
      // unlockTime == startTime, so isAfter returns false at same instant
      // but progress should be 1.0 meaning complete
      expect(timer.progress, 1.0);
      expect(timer.remainingTime, Duration.zero);
    });

    test('isExpired is false when unlock time is in the future', () {
      final timer = FocusTimer(
        startTime: DateTime.now(),
        durationMinutes: 60,
        unlockTime: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
      );

      expect(timer.isExpired, false);
    });

    test('isExpired is true when unlock time is in the past', () {
      final timer = FocusTimer(
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        durationMinutes: 60,
        unlockTime: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      );

      expect(timer.isExpired, true);
    });

    test('remainingTime returns correct duration', () {
      final now = DateTime.now();
      final timer = FocusTimer(
        startTime: now,
        durationMinutes: 120,
        unlockTime: now.add(const Duration(hours: 2)),
        isActive: true,
      );

      // Should be approximately 2 hours (within 2 seconds tolerance)
      expect(timer.remainingTime.inMinutes, closeTo(120, 1));
    });

    test('remainingTime returns zero when expired', () {
      final timer = FocusTimer(
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        durationMinutes: 60,
        unlockTime: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      );

      expect(timer.remainingTime, Duration.zero);
    });

    test('remainingHours and remainingMinutes are correct', () {
      final now = DateTime.now();
      final timer = FocusTimer(
        startTime: now,
        durationMinutes: 150, // 2h 30m
        unlockTime: now.add(const Duration(hours: 2, minutes: 30)),
        isActive: true,
      );

      expect(timer.remainingHours, 2);
      expect(timer.remainingMinutes, closeTo(30, 1));
    });

    test('progress is 0.0 at start', () {
      final timer = FocusTimer.start(hours: 1, minutes: 0);
      expect(timer.progress, closeTo(0.0, 0.01));
    });

    test('progress is 1.0 when expired', () {
      final timer = FocusTimer(
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        durationMinutes: 60,
        unlockTime: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      );

      expect(timer.progress, 1.0);
    });

    test('copyWithStopped creates inactive copy', () {
      final timer = FocusTimer.start(hours: 1, minutes: 0);
      final stopped = timer.copyWithStopped();

      expect(stopped.isActive, false);
      expect(stopped.startTime, timer.startTime);
      expect(stopped.durationMinutes, timer.durationMinutes);
      expect(stopped.unlockTime, timer.unlockTime);
    });

    test('toJson and fromJson roundtrip', () {
      final timer = FocusTimer.start(hours: 5, minutes: 15);
      final json = timer.toJson();
      final restored = FocusTimer.fromJson(json);

      expect(restored.durationMinutes, timer.durationMinutes);
      expect(restored.isActive, timer.isActive);
      expect(
        restored.startTime.millisecondsSinceEpoch,
        closeTo(timer.startTime.millisecondsSinceEpoch, 1000),
      );
    });
  });
}
