import 'package:hive/hive.dart';

part 'focus_stats.g.dart';

@HiveType(typeId: 2)
class FocusStats extends HiveObject {
  @HiveField(0)
  int blockedAppsCount;

  @HiveField(1)
  int totalFocusMinutes;

  @HiveField(2)
  int streakDays;

  @HiveField(3)
  int totalSessions;

  @HiveField(4)
  DateTime? lastSessionDate;

  @HiveField(5)
  List<int> dailyFocusMinutes; // Last 7 days

  FocusStats({
    this.blockedAppsCount = 0,
    this.totalFocusMinutes = 0,
    this.streakDays = 0,
    this.totalSessions = 0,
    this.lastSessionDate,
    List<int>? dailyFocusMinutes,
  }) : dailyFocusMinutes = dailyFocusMinutes ?? List.filled(7, 0);

  /// Focus hours as a double
  double get focusHours => totalFocusMinutes / 60.0;

  /// Update streak based on current date
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastSessionDate == null) {
      streakDays = 1;
    } else {
      final lastDate = DateTime(
        lastSessionDate!.year,
        lastSessionDate!.month,
        lastSessionDate!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Same day, no streak change
      } else if (difference == 1) {
        streakDays++;
      } else {
        streakDays = 1; // Reset streak
      }
    }
    lastSessionDate = now;
  }

  /// Record a completed focus session
  void recordSession({required int durationMinutes, required int appsBlocked}) {
    totalSessions++;
    totalFocusMinutes += durationMinutes;
    blockedAppsCount = appsBlocked;

    // Save previous lastSessionDate BEFORE updateStreak() overwrites it
    final previousSessionDate = lastSessionDate;
    updateStreak();

    // Shift daily focus and add today's minutes
    final now = DateTime.now();
    if (previousSessionDate != null) {
      final daysBetween = DateTime(now.year, now.month, now.day)
          .difference(
            DateTime(
              previousSessionDate.year,
              previousSessionDate.month,
              previousSessionDate.day,
            ),
          )
          .inDays;
      if (daysBetween > 0) {
        // Shift the list
        for (int i = 0; i < daysBetween && i < 7; i++) {
          dailyFocusMinutes.insert(0, 0);
          if (dailyFocusMinutes.length > 7) {
            dailyFocusMinutes.removeLast();
          }
        }
      }
    }
    dailyFocusMinutes[0] += durationMinutes;
  }

  Map<String, dynamic> toJson() => {
    'blockedAppsCount': blockedAppsCount,
    'totalFocusMinutes': totalFocusMinutes,
    'streakDays': streakDays,
    'totalSessions': totalSessions,
    'lastSessionDate': lastSessionDate?.toIso8601String(),
    'dailyFocusMinutes': dailyFocusMinutes,
  };

  factory FocusStats.fromJson(Map<String, dynamic> json) => FocusStats(
    blockedAppsCount: json['blockedAppsCount'] as int? ?? 0,
    totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
    streakDays: json['streakDays'] as int? ?? 0,
    totalSessions: json['totalSessions'] as int? ?? 0,
    lastSessionDate: json['lastSessionDate'] != null
        ? DateTime.parse(json['lastSessionDate'] as String)
        : null,
    dailyFocusMinutes:
        (json['dailyFocusMinutes'] as List?)?.cast<int>() ?? List.filled(7, 0),
  );

  @override
  String toString() =>
      'FocusStats(blocked: $blockedAppsCount, hours: ${focusHours.toStringAsFixed(1)}, streak: $streakDays)';
}
