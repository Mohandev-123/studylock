import 'dart:async';
import '../models/focus_timer.dart';
import '../storage/storage_service.dart';
import 'method_channel_service.dart';

/// Service to manage focus timer logic
class TimerService {
  final StorageService _storage;
  final MethodChannelService _channel;
  Timer? _tickTimer;

  /// Stream controller for timer ticks (emits remaining time)
  final _timerController = StreamController<FocusTimer>.broadcast();
  Stream<FocusTimer> get timerStream => _timerController.stream;

  /// Stream controller for timer expiry events
  final _expiryController = StreamController<void>.broadcast();
  Stream<void> get expiryStream => _expiryController.stream;

  TimerService({
    required StorageService storage,
    required MethodChannelService channel,
  }) : _storage = storage,
       _channel = channel;

  /// Start a new focus timer
  Future<FocusTimer> startTimer({
    required int hours,
    required int minutes,
  }) async {
    // Create timer
    final timer = FocusTimer.start(hours: hours, minutes: minutes);

    // Persist timer
    await _storage.saveTimer(timer);

    // Start native monitoring service
    final blockedApps = _storage.getBlockedApps();
    final packageNames = blockedApps.map((a) => a.packageName).toList();
    await _channel.startFocusSession(
      packageNames: packageNames,
      durationMinutes: timer.durationMinutes,
    );

    // Start tick timer for UI updates
    _startTicking(timer);

    return timer;
  }

  /// Resume timer on app restart (e.g., after reboot)
  void resumeIfActive() {
    final timer = _storage.getActiveTimer();
    if (timer != null && timer.isActive && !timer.isExpired) {
      _startTicking(timer);
    } else if (timer != null && (timer.isExpired || !timer.isActive)) {
      // Timer has expired while app was closed
      _handleExpiry();
    }
  }

  /// Stop the current timer
  Future<void> stopTimer() async {
    _tickTimer?.cancel();
    _tickTimer = null;

    final timer = _storage.getActiveTimer();
    if (timer != null) {
      // Record stats before clearing
      final elapsed = DateTime.now().difference(timer.startTime).inMinutes;
      final blockedCount = _storage.getBlockedApps().length;
      await _storage.updateStats(
        durationMinutes: elapsed,
        appsBlocked: blockedCount,
      );

      await _storage.saveTimer(timer.copyWithStopped());
    }

    // Stop native monitoring
    await _channel.stopFocusSession();

    await _storage.clearTimer();
  }

  /// Get remaining time as a Duration
  Duration getRemainingTime() {
    final timer = _storage.getActiveTimer();
    if (timer == null || !timer.isActive) return Duration.zero;
    return timer.remainingTime;
  }

  /// Check if timer has expired
  bool isTimerExpired() {
    final timer = _storage.getActiveTimer();
    if (timer == null) return true;
    return timer.isExpired;
  }

  /// Check if timer is currently active
  bool isTimerActive() {
    return _storage.hasActiveTimer();
  }

  /// Get the active timer
  FocusTimer? getActiveTimer() {
    return _storage.getActiveTimer();
  }

  void _startTicking(FocusTimer timer) {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timer.isExpired) {
        _handleExpiry();
      } else {
        _timerController.add(timer);
      }
    });
  }

  Future<void> _handleExpiry() async {
    _tickTimer?.cancel();
    _tickTimer = null;

    final timer = _storage.getActiveTimer();
    if (timer != null) {
      // Record completed session stats
      await _storage.updateStats(
        durationMinutes: timer.durationMinutes,
        appsBlocked: _storage.getBlockedApps().length,
      );
    }

    await _storage.clearTimer();
    await _channel.stopFocusSession();
    _expiryController.add(null);
  }

  void dispose() {
    _tickTimer?.cancel();
    _timerController.close();
    _expiryController.close();
  }
}
