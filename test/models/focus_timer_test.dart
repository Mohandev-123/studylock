import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/focus_timer.dart';

void main() {
  group('FocusTimer', () {
    group('factory FocusTimer.start()', () {
      test('creates timer with correct duration in minutes', () {
        final timer = FocusTimer.start(hours: 2, minutes: 30);
        expect(timer.durationMinutes, 150);
      });

      test('creates timer with only hours', () {
        final timer = FocusTimer.start(hours: 5, minutes: 0);
        expect(timer.durationMinutes, 300);
      });

      test('creates timer with only minutes', () {
        final timer = FocusTimer.start(hours: 0, minutes: 45);
        expect(timer.durationMinutes, 45);
      });

      test('creates timer that is active', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.isActive, true);
      });

      test('creates timer that is not expired', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.isExpired, false);
      });

      test('sets startTime to approximately now', () {
        final before = DateTime.now();
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        final after = DateTime.now();

        expect(
          timer.startTime.isAfter(before) || timer.startTime == before,
          true,
        );
        expect(
          timer.startTime.isBefore(after) || timer.startTime == after,
          true,
        );
      });

      test('sets unlockTime to duration after startTime', () {
        final timer = FocusTimer.start(hours: 2, minutes: 0);
        final expected = timer.startTime.add(const Duration(hours: 2));
        expect(timer.unlockTime, expected);
      });

      test('handles zero hours and zero minutes', () {
        final timer = FocusTimer.start(hours: 0, minutes: 0);
        expect(timer.durationMinutes, 0);
      });

      test('handles maximum 24 hours', () {
        final timer = FocusTimer.start(hours: 24, minutes: 0);
        expect(timer.durationMinutes, 1440);
      });
    });

    group('remainingTime', () {
      test('returns positive duration for future unlock time', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.remainingTime.inSeconds, greaterThan(0));
      });

      test('returns approximately full duration for just-created timer', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.remainingTime.inMinutes, closeTo(60, 1));
      });

      test('returns Duration.zero for expired timer', () {
        final timer = FocusTimer(
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          durationMinutes: 60,
          unlockTime: DateTime.now().subtract(const Duration(hours: 2)),
          isActive: true,
        );
        expect(timer.remainingTime, Duration.zero);
      });
    });

    group('isExpired', () {
      test('returns false for future unlock time', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.isExpired, false);
      });

      test('returns true for past unlock time', () {
        final timer = FocusTimer(
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          durationMinutes: 60,
          unlockTime: DateTime.now().subtract(const Duration(hours: 2)),
          isActive: true,
        );
        expect(timer.isExpired, true);
      });
    });

    group('remainingHours / remainingMinutes / remainingSeconds', () {
      test('returns correct components for active timer', () {
        final timer = FocusTimer.start(hours: 2, minutes: 30);
        expect(timer.remainingHours, 2);
        expect(timer.remainingMinutes, closeTo(30, 1));
      });

      test('returns zero components for expired timer', () {
        final timer = FocusTimer(
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          durationMinutes: 60,
          unlockTime: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(timer.remainingHours, 0);
        expect(timer.remainingMinutes, 0);
        expect(timer.remainingSeconds, 0);
      });
    });

    group('progress', () {
      test('returns near 0.0 for just-created timer', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.progress, closeTo(0.0, 0.02));
      });

      test('returns 1.0 for fully expired timer', () {
        final timer = FocusTimer(
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          durationMinutes: 60,
          unlockTime: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(timer.progress, 1.0);
      });

      test('returns approximately 0.5 for half-elapsed timer', () {
        final now = DateTime.now();
        final timer = FocusTimer(
          startTime: now.subtract(const Duration(minutes: 30)),
          durationMinutes: 60,
          unlockTime: now.add(const Duration(minutes: 30)),
        );
        expect(timer.progress, closeTo(0.5, 0.02));
      });

      test('returns 1.0 for zero-duration timer', () {
        final timer = FocusTimer.start(hours: 0, minutes: 0);
        expect(timer.progress, 1.0);
      });

      test('clamps to 1.0 for over-elapsed timer', () {
        final timer = FocusTimer(
          startTime: DateTime.now().subtract(const Duration(hours: 10)),
          durationMinutes: 60,
          unlockTime: DateTime.now().subtract(const Duration(hours: 9)),
        );
        expect(timer.progress, 1.0);
      });
    });

    group('copyWithStopped()', () {
      test('returns timer with isActive = false', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        final stopped = timer.copyWithStopped();
        expect(stopped.isActive, false);
      });

      test('preserves other fields', () {
        final timer = FocusTimer.start(hours: 2, minutes: 30);
        final stopped = timer.copyWithStopped();
        expect(stopped.startTime, timer.startTime);
        expect(stopped.durationMinutes, timer.durationMinutes);
        expect(stopped.unlockTime, timer.unlockTime);
      });
    });

    group('JSON serialization', () {
      test('roundtrip preserves all fields', () {
        final timer = FocusTimer.start(hours: 3, minutes: 15);
        final json = timer.toJson();
        final restored = FocusTimer.fromJson(json);

        expect(restored.startTime, timer.startTime);
        expect(restored.durationMinutes, timer.durationMinutes);
        expect(restored.unlockTime, timer.unlockTime);
        expect(restored.isActive, timer.isActive);
      });

      test('toJson contains expected keys', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        final json = timer.toJson();

        expect(json.containsKey('startTime'), true);
        expect(json.containsKey('durationMinutes'), true);
        expect(json.containsKey('unlockTime'), true);
        expect(json.containsKey('isActive'), true);
      });

      test('fromJson handles missing isActive with default false', () {
        final json = {
          'startTime': DateTime.now().toIso8601String(),
          'durationMinutes': 60,
          'unlockTime': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
        };
        final timer = FocusTimer.fromJson(json);
        expect(timer.isActive, false);
      });

      test('survives simulated reboot (serialization roundtrip)', () {
        final timer = FocusTimer.start(hours: 10, minutes: 0);
        final json = timer.toJson();
        final restored = FocusTimer.fromJson(json);

        expect(restored.durationMinutes, 600);
        expect(restored.isActive, true);
        expect(restored.isExpired, false);
        expect(restored.remainingTime.inMinutes, closeTo(600, 1));
      });
    });

    group('toString()', () {
      test('returns descriptive string', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        final str = timer.toString();
        expect(str, contains('FocusTimer'));
        expect(str, contains('60m'));
        expect(str, contains('active: true'));
      });
    });

    group('edge cases', () {
      test('timer expires while phone is locked/off', () {
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

      test('very long duration timer (24 hours)', () {
        final timer = FocusTimer.start(hours: 24, minutes: 0);
        expect(timer.durationMinutes, 1440);
        expect(timer.isExpired, false);
        expect(timer.remainingHours, closeTo(24, 1));
      });

      test('start and immediate check', () {
        final timer = FocusTimer.start(hours: 1, minutes: 0);
        expect(timer.isExpired, false);
        expect(timer.isActive, true);
        expect(timer.progress, closeTo(0.0, 0.01));
      });
    });
  });
}
