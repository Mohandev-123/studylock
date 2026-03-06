import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/installed_app.dart';

/// Flutter ↔ Android Method Channel bridge
class MethodChannelService {
  static const String _channelName = 'timelock_service';

  final MethodChannel _channel = const MethodChannel(_channelName);

  MethodChannelService() {
    // Listen for method calls from native side
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  // ─── Callbacks from native ────────────────────────────────────────

  /// Stream for when a blocked app is detected in the foreground
  final _blockedAppDetectedController = StreamController<String>.broadcast();
  Stream<String> get onBlockedAppDetected =>
      _blockedAppDetectedController.stream;

  /// Stream for service status changes
  final _serviceStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onServiceStatusChanged => _serviceStatusController.stream;

  /// Handle incoming calls from Android native code
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onBlockedAppDetected':
        final packageName = call.arguments as String;
        _blockedAppDetectedController.add(packageName);
        return true;
      case 'onServiceStatusChanged':
        final isRunning = call.arguments as bool;
        _serviceStatusController.add(isRunning);
        return true;
      default:
        return null;
    }
  }

  // ─── Calls to native ──────────────────────────────────────────────

  /// Get all user-installed apps
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result == null) return [];

      final List<dynamic> appsList = result as List<dynamic>;
      return appsList
          .map((app) => InstalledApp.fromMap(app as Map<dynamic, dynamic>))
          .toList()
        ..sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
        );
    } on PlatformException catch (e) {
      debugPrint('Error getting installed apps: ${e.message}');
      return [];
    }
  }

  /// Start the focus session with monitoring
  Future<bool> startFocusSession({
    required List<String> packageNames,
    required int durationMinutes,
  }) async {
    try {
      final result = await _channel.invokeMethod('startFocusSession', {
        'packageNames': packageNames,
        'durationMinutes': durationMinutes,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Error starting focus session: ${e.message}');
      return false;
    }
  }

  /// Stop the focus session
  Future<bool> stopFocusSession() async {
    try {
      final result = await _channel.invokeMethod('stopFocusSession');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Error stopping focus session: ${e.message}');
      return false;
    }
  }

  /// Check if accessibility service is enabled
  Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod('isAccessibilityEnabled');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Error checking accessibility: ${e.message}');
      return false;
    }
  }

  /// Open accessibility settings
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('Error opening settings: ${e.message}');
    }
  }

  /// Check if the monitoring service is running
  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Error checking service: ${e.message}');
      return false;
    }
  }

  /// Get the currently blocked packages from native side
  Future<List<String>> getBlockedPackages() async {
    try {
      final result = await _channel.invokeMethod('getBlockedPackages');
      if (result == null) return [];
      return (result as List<dynamic>).cast<String>();
    } on PlatformException catch (e) {
      debugPrint('Error getting blocked packages: ${e.message}');
      return [];
    }
  }

  /// Save blocked packages to native side
  Future<bool> saveBlockedPackages(List<String> packageNames) async {
    try {
      final result = await _channel.invokeMethod('saveBlockedPackages', {
        'packageNames': packageNames,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Error saving blocked packages: ${e.message}');
      return false;
    }
  }

  /// Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': id,
        'title': title,
        'body': body,
      });
    } on PlatformException catch (e) {
      debugPrint('Error showing notification: ${e.message}');
    }
  }

  /// Cancel a notification by id
  Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
    } on PlatformException catch (e) {
      debugPrint('Error cancelling notification: ${e.message}');
    }
  }

  void dispose() {
    _blockedAppDetectedController.close();
    _serviceStatusController.close();
  }
}
