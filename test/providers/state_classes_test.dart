import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/providers/providers.dart';

void main() {
  group('TimerState', () {
    group('constructor defaults', () {
      test('creates with all defaults', () {
        const state = TimerState();
        expect(state.timer, null);
        expect(state.isActive, false);
        expect(state.remaining, Duration.zero);
        expect(state.progress, 0.0);
      });
    });

    group('copyWith()', () {
      test('copies with new isActive', () {
        const state = TimerState(isActive: false);
        final copied = state.copyWith(isActive: true);
        expect(copied.isActive, true);
        expect(copied.timer, null);
        expect(copied.remaining, Duration.zero);
        expect(copied.progress, 0.0);
      });

      test('copies with new remaining', () {
        const state = TimerState();
        final copied = state.copyWith(remaining: const Duration(minutes: 30));
        expect(copied.remaining, const Duration(minutes: 30));
      });

      test('copies with new progress', () {
        const state = TimerState();
        final copied = state.copyWith(progress: 0.75);
        expect(copied.progress, 0.75);
      });

      test('preserves unset fields', () {
        const state = TimerState(
          isActive: true,
          remaining: Duration(hours: 1),
          progress: 0.5,
        );
        final copied = state.copyWith(progress: 0.6);
        expect(copied.isActive, true);
        expect(copied.remaining, const Duration(hours: 1));
        expect(copied.progress, 0.6);
      });
    });
  });

  group('SettingsState', () {
    group('constructor defaults', () {
      test('creates with all defaults', () {
        const state = SettingsState();
        expect(state.darkMode, true);
        expect(state.notifications, true);
        expect(state.emergencyUnlock, false);
        expect(state.isFirstLaunch, true);
        expect(state.permissionGranted, false);
      });
    });

    group('copyWith()', () {
      test('copies with new darkMode', () {
        const state = SettingsState(darkMode: true);
        final copied = state.copyWith(darkMode: false);
        expect(copied.darkMode, false);
        // Other fields preserved
        expect(copied.notifications, true);
        expect(copied.emergencyUnlock, false);
        expect(copied.isFirstLaunch, true);
        expect(copied.permissionGranted, false);
      });

      test('copies with new notifications', () {
        const state = SettingsState(notifications: true);
        final copied = state.copyWith(notifications: false);
        expect(copied.notifications, false);
      });

      test('copies with new emergencyUnlock', () {
        const state = SettingsState(emergencyUnlock: false);
        final copied = state.copyWith(emergencyUnlock: true);
        expect(copied.emergencyUnlock, true);
      });

      test('copies with new isFirstLaunch', () {
        const state = SettingsState(isFirstLaunch: true);
        final copied = state.copyWith(isFirstLaunch: false);
        expect(copied.isFirstLaunch, false);
      });

      test('copies with new permissionGranted', () {
        const state = SettingsState(permissionGranted: false);
        final copied = state.copyWith(permissionGranted: true);
        expect(copied.permissionGranted, true);
      });

      test('preserves unset fields when copying one field', () {
        const state = SettingsState(
          darkMode: false,
          notifications: false,
          emergencyUnlock: true,
          isFirstLaunch: false,
          permissionGranted: true,
        );
        final copied = state.copyWith(darkMode: true);
        expect(copied.darkMode, true);
        expect(copied.notifications, false);
        expect(copied.emergencyUnlock, true);
        expect(copied.isFirstLaunch, false);
        expect(copied.permissionGranted, true);
      });

      test('copies multiple fields at once', () {
        const state = SettingsState();
        final copied = state.copyWith(
          darkMode: false,
          notifications: false,
          isFirstLaunch: false,
          permissionGranted: true,
        );
        expect(copied.darkMode, false);
        expect(copied.notifications, false);
        expect(copied.isFirstLaunch, false);
        expect(copied.permissionGranted, true);
        expect(copied.emergencyUnlock, false); // Unchanged
      });
    });
  });
}
