import 'package:hive_flutter/hive_flutter.dart';
import '../models/blocked_app.dart';
import '../models/focus_timer.dart';
import '../models/focus_stats.dart';

/// Manages all local storage using Hive
class StorageService {
  static const String _blockedAppsBox = 'blocked_apps';
  static const String _timerBox = 'timer';
  static const String _statsBox = 'stats';
  static const String _settingsBox = 'settings';

  static const String _activeTimerKey = 'active_timer';
  static const String _statsKey = 'focus_stats';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BlockedAppAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FocusTimerAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FocusStatsAdapter());
    }

    // Open boxes
    await Hive.openBox<BlockedApp>(_blockedAppsBox);
    await Hive.openBox(_timerBox);
    await Hive.openBox(_statsBox);
    await Hive.openBox(_settingsBox);
  }

  // ─── BLOCKED APPS ─────────────────────────────────────────────────

  /// Save a list of blocked apps (replaces existing)
  Future<void> saveBlockedApps(List<BlockedApp> apps) async {
    final box = Hive.box<BlockedApp>(_blockedAppsBox);
    await box.clear();
    for (final app in apps) {
      await box.put(app.packageName, app);
    }
  }

  /// Get all blocked apps
  List<BlockedApp> getBlockedApps() {
    final box = Hive.box<BlockedApp>(_blockedAppsBox);
    return box.values.toList();
  }

  /// Check if a specific package is blocked
  bool isAppBlocked(String packageName) {
    final box = Hive.box<BlockedApp>(_blockedAppsBox);
    return box.containsKey(packageName);
  }

  /// Remove a specific app from blocked list
  Future<void> removeBlockedApp(String packageName) async {
    final box = Hive.box<BlockedApp>(_blockedAppsBox);
    await box.delete(packageName);
  }

  // ─── TIMER ────────────────────────────────────────────────────────

  /// Save the active timer
  Future<void> saveTimer(FocusTimer timer) async {
    final box = Hive.box(_timerBox);
    await box.put(_activeTimerKey, timer);
  }

  /// Get the active timer (null if none)
  FocusTimer? getActiveTimer() {
    final box = Hive.box(_timerBox);
    return box.get(_activeTimerKey) as FocusTimer?;
  }

  /// Clear the active timer
  Future<void> clearTimer() async {
    final box = Hive.box(_timerBox);
    await box.delete(_activeTimerKey);
  }

  /// Check if there is an active, non-expired timer
  bool hasActiveTimer() {
    final timer = getActiveTimer();
    return timer != null && timer.isActive && !timer.isExpired;
  }

  // ─── STATS ────────────────────────────────────────────────────────

  /// Get focus statistics
  FocusStats getStats() {
    final box = Hive.box(_statsBox);
    final stats = box.get(_statsKey);
    if (stats is FocusStats) return stats;
    return FocusStats();
  }

  /// Save focus statistics
  Future<void> saveStats(FocusStats stats) async {
    final box = Hive.box(_statsBox);
    await box.put(_statsKey, stats);
  }

  /// Update stats with a completed session
  Future<FocusStats> updateStats({
    required int durationMinutes,
    required int appsBlocked,
  }) async {
    final stats = getStats();
    stats.recordSession(
      durationMinutes: durationMinutes,
      appsBlocked: appsBlocked,
    );
    await saveStats(stats);
    return stats;
  }

  // ─── SETTINGS ─────────────────────────────────────────────────────

  /// Get a setting value
  T? getSetting<T>(String key) {
    final box = Hive.box(_settingsBox);
    return box.get(key) as T?;
  }

  /// Save a setting value
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  /// Check if this is the first app launch
  bool isFirstLaunch() {
    return getSetting<bool>('has_launched') != true;
  }

  /// Mark the app as launched
  Future<void> markLaunched() async {
    await saveSetting('has_launched', true);
  }

  /// Check if accessibility permission was granted
  bool isPermissionGranted() {
    return getSetting<bool>('permission_granted') == true;
  }

  /// Mark permission as granted
  Future<void> markPermissionGranted() async {
    await saveSetting('permission_granted', true);
  }

  /// Get dark mode preference
  bool isDarkMode() {
    return getSetting<bool>('dark_mode') ?? true;
  }

  /// Set dark mode preference
  Future<void> setDarkMode(bool value) async {
    await saveSetting('dark_mode', value);
  }

  /// Get notification preference
  bool isNotificationsEnabled() {
    return getSetting<bool>('notifications') ?? true;
  }

  /// Set notification preference
  Future<void> setNotifications(bool value) async {
    await saveSetting('notifications', value);
  }

  /// Get emergency unlock preference
  bool isEmergencyUnlockEnabled() {
    return getSetting<bool>('emergency_unlock') ?? false;
  }

  /// Set emergency unlock preference
  Future<void> setEmergencyUnlock(bool value) async {
    await saveSetting('emergency_unlock', value);
  }

  /// Close all boxes
  Future<void> dispose() async {
    await Hive.close();
  }
}
