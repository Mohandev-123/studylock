import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/models/models.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/services/services.dart';
import 'package:study_lock/core/storage/storage_service.dart';
import 'package:study_lock/core/theme/app_colors.dart';

// ────────────────────────────────────────────────────────────────────────
// Fake Service implementations (so Hive & MethodChannel are never touched)
// ────────────────────────────────────────────────────────────────────────

class FakeStorageService implements StorageService {
  @override
  List<BlockedApp> getBlockedApps() => [];
  @override
  bool isAppBlocked(String packageName) => false;
  @override
  Future<void> saveBlockedApps(List<BlockedApp> apps) async {}
  @override
  Future<void> removeBlockedApp(String packageName) async {}
  @override
  Future<void> saveTimer(FocusTimer timer) async {}
  @override
  FocusTimer? getActiveTimer() => null;
  @override
  Future<void> clearTimer() async {}
  @override
  bool hasActiveTimer() => false;
  @override
  FocusStats getStats() => FocusStats();
  @override
  Future<void> saveStats(FocusStats stats) async {}
  @override
  Future<FocusStats> updateStats({
    required int durationMinutes,
    required int appsBlocked,
  }) async => FocusStats();
  @override
  T? getSetting<T>(String key) => null;
  @override
  Future<void> saveSetting(String key, dynamic value) async {}
  @override
  bool isFirstLaunch() => false;
  @override
  Future<void> markLaunched() async {}
  @override
  bool isPermissionGranted() => false;
  @override
  Future<void> markPermissionGranted() async {}
  @override
  bool isDarkMode() => true;
  @override
  Future<void> setDarkMode(bool value) async {}
  @override
  bool isNotificationsEnabled() => true;
  @override
  Future<void> setNotifications(bool value) async {}
  @override
  bool isEmergencyUnlockEnabled() => false;
  @override
  Future<void> setEmergencyUnlock(bool value) async {}
  @override
  Future<void> dispose() async {}
}

class FakeMethodChannelService implements MethodChannelService {
  @override
  Stream<String> get onBlockedAppDetected => const Stream.empty();
  @override
  Stream<bool> get onServiceStatusChanged => const Stream.empty();
  @override
  Future<List<InstalledApp>> getInstalledApps() async => [];
  @override
  Future<bool> isAccessibilityEnabled() async => false;
  @override
  Future<void> openAccessibilitySettings() async {}
  @override
  Future<bool> startFocusSession({
    required List<String> packageNames,
    required int durationMinutes,
  }) async => true;
  @override
  Future<bool> stopFocusSession() async => true;
  @override
  Future<bool> saveBlockedPackages(List<String> packageNames) async => true;
  @override
  Future<bool> isServiceRunning() async => false;
  @override
  Future<List<String>> getBlockedPackages() async => [];
  @override
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {}
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  void dispose() {}
}

class FakeTimerService implements TimerService {
  @override
  Stream<FocusTimer> get timerStream => const Stream.empty();
  @override
  Stream<void> get expiryStream => const Stream.empty();
  @override
  Future<FocusTimer> startTimer({
    required int hours,
    required int minutes,
  }) async => FocusTimer.start(hours: hours, minutes: minutes);
  @override
  void resumeIfActive() {}
  @override
  Future<void> stopTimer() async {}
  @override
  Duration getRemainingTime() => Duration.zero;
  @override
  bool isTimerExpired() => true;
  @override
  bool isTimerActive() => false;
  @override
  FocusTimer? getActiveTimer() => null;
  @override
  void dispose() {}
}

// ────────────────────────────────────────────────────────────────────────
// Fake Notifiers
// ────────────────────────────────────────────────────────────────────────

class FakeTimerNotifier extends StateNotifier<TimerState>
    implements TimerNotifier {
  FakeTimerNotifier(super.initial);

  @override
  Future<void> startTimer({required int hours, required int minutes}) async {}

  @override
  Future<void> stopTimer() async => state = const TimerState();
}

class FakeBlockedAppsNotifier extends StateNotifier<List<BlockedApp>>
    implements BlockedAppsNotifier {
  FakeBlockedAppsNotifier(super.initial);

  @override
  Future<void> saveBlockedApps(List<BlockedApp> apps) async => state = apps;
  @override
  Future<void> addApp(BlockedApp app) async => state = [...state, app];
  @override
  Future<void> removeApp(String pkg) async =>
      state = state.where((a) => a.packageName != pkg).toList();
  @override
  bool isBlocked(String pkg) => state.any((a) => a.packageName == pkg);
}

class FakeStatsNotifier extends StateNotifier<FocusStats>
    implements StatsNotifier {
  FakeStatsNotifier(super.initial);

  @override
  void refresh() {}
  @override
  Future<void> recordSession({
    required int durationMinutes,
    required int appsBlocked,
  }) async {}
  @override
  List<double> getDailyFocusHours() => List.filled(7, 0.0);
  @override
  Future<void> resetStats() async => state = FocusStats();
}

class FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  FakeSettingsNotifier(super.initial);

  @override
  Future<void> setDarkMode(bool value) async =>
      state = state.copyWith(darkMode: value);
  @override
  Future<void> setNotifications(bool value) async =>
      state = state.copyWith(notifications: value);
  @override
  Future<void> setEmergencyUnlock(bool value) async =>
      state = state.copyWith(emergencyUnlock: value);
  @override
  Future<void> markLaunched() async =>
      state = state.copyWith(isFirstLaunch: false);
  @override
  Future<void> markPermissionGranted() async =>
      state = state.copyWith(permissionGranted: true);
}

// ────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────

/// Default provider overrides for tests so Hive is never touched.
List<Override> defaultOverrides({
  TimerState? timerState,
  List<BlockedApp>? blockedApps,
  FocusStats? stats,
  SettingsState? settings,
  AsyncValue<List<InstalledApp>>? installedApps,
}) {
  return [
    // Core services
    storageServiceProvider.overrideWithValue(FakeStorageService()),
    methodChannelServiceProvider.overrideWithValue(FakeMethodChannelService()),
    timerServiceProvider.overrideWithValue(FakeTimerService()),
    // Notifiers
    timerProvider.overrideWith(
      (ref) => FakeTimerNotifier(timerState ?? const TimerState()),
    ),
    blockedAppsProvider.overrideWith(
      (ref) => FakeBlockedAppsNotifier(blockedApps ?? []),
    ),
    statsProvider.overrideWith(
      (ref) => FakeStatsNotifier(stats ?? FocusStats()),
    ),
    settingsProvider.overrideWith(
      (ref) => FakeSettingsNotifier(settings ?? const SettingsState()),
    ),
    installedAppsProvider.overrideWith(
      (ref) =>
          installedApps?.when(
            data: (d) => Future.value(d),
            loading: () =>
                Future<List<InstalledApp>>.delayed(const Duration(days: 1)),
            error: (e, s) => Future<List<InstalledApp>>.error(e, s),
          ) ??
          Future.value(<InstalledApp>[]),
    ),
  ];
}

/// Wrap a widget with ProviderScope + MaterialApp for testing.
Widget buildTestableWidget(
  Widget child, {
  List<Override>? overrides,
  bool darkMode = true,
}) {
  return ProviderScope(
    overrides: overrides ?? defaultOverrides(),
    child: MaterialApp(
      theme: darkMode ? AppColors.darkTheme : AppColors.lightTheme,
      home: child,
    ),
  );
}
