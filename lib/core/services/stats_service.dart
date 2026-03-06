import '../models/focus_stats.dart';
import '../storage/storage_service.dart';

/// Service to manage focus statistics
class StatsService {
  final StorageService _storage;

  StatsService({required StorageService storage}) : _storage = storage;

  /// Get current statistics
  FocusStats getStats() {
    return _storage.getStats();
  }

  /// Update stats after a focus session
  Future<FocusStats> recordSession({
    required int durationMinutes,
    required int appsBlocked,
  }) async {
    return _storage.updateStats(
      durationMinutes: durationMinutes,
      appsBlocked: appsBlocked,
    );
  }

  /// Get daily focus data for chart (last 7 days)
  List<double> getDailyFocusHours() {
    final stats = _storage.getStats();
    return stats.dailyFocusMinutes
        .map((m) => m / 60.0)
        .toList()
        .reversed
        .toList();
  }

  /// Reset all statistics
  Future<void> resetStats() async {
    await _storage.saveStats(FocusStats());
  }
}
