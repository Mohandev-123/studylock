import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../storage/storage_service.dart';

// ─── Core Service Providers ─────────────────────────────────────────

/// Storage service singleton
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Method channel service singleton
final methodChannelServiceProvider = Provider<MethodChannelService>((ref) {
  final service = MethodChannelService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// App discovery service
final appServiceProvider = Provider<AppService>((ref) {
  return AppService(channel: ref.read(methodChannelServiceProvider));
});

/// Timer service
final timerServiceProvider = Provider<TimerService>((ref) {
  final service = TimerService(
    storage: ref.read(storageServiceProvider),
    channel: ref.read(methodChannelServiceProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stats service
final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(storage: ref.read(storageServiceProvider));
});

// ─── Installed Apps Provider ────────────────────────────────────────

/// Fetches installed apps from the device
final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) async {
  final appService = ref.read(appServiceProvider);
  return appService.getInstalledApps();
});

// ─── Blocked Apps Provider ──────────────────────────────────────────

/// Manages the list of blocked apps
class BlockedAppsNotifier extends StateNotifier<List<BlockedApp>> {
  final StorageService _storage;
  final MethodChannelService _channel;

  BlockedAppsNotifier(this._storage, this._channel)
    : super(_storage.getBlockedApps());

  /// Save selected apps as blocked
  Future<void> saveBlockedApps(List<BlockedApp> apps) async {
    await _storage.saveBlockedApps(apps);
    final packageNames = apps.map((a) => a.packageName).toList();
    await _channel.saveBlockedPackages(packageNames);
    state = apps;
  }

  /// Add an app to the blocked list
  Future<void> addApp(BlockedApp app) async {
    final updated = [...state, app];
    await saveBlockedApps(updated);
  }

  /// Remove an app from the blocked list
  Future<void> removeApp(String packageName) async {
    final updated = state.where((a) => a.packageName != packageName).toList();
    await saveBlockedApps(updated);
  }

  /// Check if a package is blocked
  bool isBlocked(String packageName) {
    return state.any((a) => a.packageName == packageName);
  }
}

final blockedAppsProvider =
    StateNotifierProvider<BlockedAppsNotifier, List<BlockedApp>>((ref) {
      return BlockedAppsNotifier(
        ref.read(storageServiceProvider),
        ref.read(methodChannelServiceProvider),
      );
    });

// ─── Timer Provider ─────────────────────────────────────────────────

/// Timer state holder
class TimerState {
  final FocusTimer? timer;
  final bool isActive;
  final Duration remaining;
  final double progress;

  const TimerState({
    this.timer,
    this.isActive = false,
    this.remaining = Duration.zero,
    this.progress = 0.0,
  });

  TimerState copyWith({
    FocusTimer? timer,
    bool? isActive,
    Duration? remaining,
    double? progress,
  }) => TimerState(
    timer: timer ?? this.timer,
    isActive: isActive ?? this.isActive,
    remaining: remaining ?? this.remaining,
    progress: progress ?? this.progress,
  );
}

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerService _timerService;
  final MethodChannelService _channel;
  final StorageService _storage;
  StreamSubscription? _tickSub;
  StreamSubscription? _expirySub;
  Timer? _uiTimer;

  TimerNotifier(this._timerService, this._channel, this._storage)
    : super(const TimerState()) {
    _init();
  }

  void _init() {
    // Check if there's an active timer persisted
    final activeTimer = _timerService.getActiveTimer();
    if (activeTimer != null && activeTimer.isActive && !activeTimer.isExpired) {
      state = TimerState(
        timer: activeTimer,
        isActive: true,
        remaining: activeTimer.remainingTime,
        progress: activeTimer.progress,
      );
      _timerService.resumeIfActive();
      _startUIUpdates();
    }

    // Listen for expiry
    _expirySub = _timerService.expiryStream.listen((_) {
      state = const TimerState();
      _uiTimer?.cancel();
      // Send notification if enabled
      if (_storage.isNotificationsEnabled()) {
        _channel.showNotification(
          title: 'Focus Session Complete!',
          body: 'Great job staying focused. Keep up the good work!',
          id: 1,
        );
      }
    });
  }

  void _startUIUpdates() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final timer = _timerService.getActiveTimer();
      if (timer == null || timer.isExpired) {
        state = const TimerState();
        _uiTimer?.cancel();
        return;
      }
      state = TimerState(
        timer: timer,
        isActive: true,
        remaining: timer.remainingTime,
        progress: timer.progress,
      );
    });
  }

  /// Start a new focus timer
  Future<void> startTimer({required int hours, required int minutes}) async {
    final timer = await _timerService.startTimer(
      hours: hours,
      minutes: minutes,
    );
    state = TimerState(
      timer: timer,
      isActive: true,
      remaining: timer.remainingTime,
      progress: 0.0,
    );
    _startUIUpdates();

    // Send notification if enabled
    if (_storage.isNotificationsEnabled()) {
      final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      _channel.showNotification(
        title: 'Focus Session Started',
        body: 'Stay focused for $durationText. You got this!',
        id: 0,
      );
    }
  }

  /// Stop the current timer
  Future<void> stopTimer() async {
    await _timerService.stopTimer();
    _uiTimer?.cancel();
    state = const TimerState();
    _channel.cancelNotification(0);
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _expirySub?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(
    ref.read(timerServiceProvider),
    ref.read(methodChannelServiceProvider),
    ref.read(storageServiceProvider),
  );
});

// ─── Stats Provider ─────────────────────────────────────────────────

class StatsNotifier extends StateNotifier<FocusStats> {
  final StatsService _statsService;

  StatsNotifier(this._statsService) : super(_statsService.getStats());

  /// Refresh stats from storage
  void refresh() {
    state = _statsService.getStats();
  }

  /// Record a focus session
  Future<void> recordSession({
    required int durationMinutes,
    required int appsBlocked,
  }) async {
    state = await _statsService.recordSession(
      durationMinutes: durationMinutes,
      appsBlocked: appsBlocked,
    );
  }

  /// Get daily chart data
  List<double> getDailyFocusHours() {
    return _statsService.getDailyFocusHours();
  }

  /// Reset stats
  Future<void> resetStats() async {
    await _statsService.resetStats();
    state = FocusStats();
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, FocusStats>((ref) {
  return StatsNotifier(ref.read(statsServiceProvider));
});

// ─── Settings Provider ──────────────────────────────────────────────

class SettingsState {
  final bool darkMode;
  final bool notifications;
  final bool emergencyUnlock;
  final bool isFirstLaunch;
  final bool permissionGranted;

  const SettingsState({
    this.darkMode = true,
    this.notifications = true,
    this.emergencyUnlock = false,
    this.isFirstLaunch = true,
    this.permissionGranted = false,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notifications,
    bool? emergencyUnlock,
    bool? isFirstLaunch,
    bool? permissionGranted,
  }) => SettingsState(
    darkMode: darkMode ?? this.darkMode,
    notifications: notifications ?? this.notifications,
    emergencyUnlock: emergencyUnlock ?? this.emergencyUnlock,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    permissionGranted: permissionGranted ?? this.permissionGranted,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storage;

  SettingsNotifier(this._storage)
    : super(
        SettingsState(
          darkMode: _storage.isDarkMode(),
          notifications: _storage.isNotificationsEnabled(),
          emergencyUnlock: _storage.isEmergencyUnlockEnabled(),
          isFirstLaunch: _storage.isFirstLaunch(),
          permissionGranted: _storage.isPermissionGranted(),
        ),
      );

  Future<void> setDarkMode(bool value) async {
    await _storage.setDarkMode(value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setNotifications(bool value) async {
    await _storage.setNotifications(value);
    state = state.copyWith(notifications: value);
  }

  Future<void> setEmergencyUnlock(bool value) async {
    await _storage.setEmergencyUnlock(value);
    state = state.copyWith(emergencyUnlock: value);
  }

  Future<void> markLaunched() async {
    await _storage.markLaunched();
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> markPermissionGranted() async {
    await _storage.markPermissionGranted();
    state = state.copyWith(permissionGranted: true);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref.read(storageServiceProvider));
  },
);

// ─── Accessibility Permission Provider ──────────────────────────────

final accessibilityEnabledProvider = FutureProvider<bool>((ref) async {
  final channel = ref.read(methodChannelServiceProvider);
  return channel.isAccessibilityEnabled();
});

// ─── Blocked App Detection Provider ────────────────────────────────

final blockedAppDetectedProvider = StreamProvider<String>((ref) {
  final channel = ref.read(methodChannelServiceProvider);
  return channel.onBlockedAppDetected;
});

// ─── Tab Navigation Provider ────────────────────────────────────────

/// Controls which tab is active in MainShell
final currentTabProvider = StateProvider<int>((ref) => 0);
