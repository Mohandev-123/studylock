import 'package:hive/hive.dart';

part 'focus_timer.g.dart';

@HiveType(typeId: 1)
class FocusTimer extends HiveObject {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final int durationMinutes;

  @HiveField(2)
  final DateTime unlockTime;

  @HiveField(3)
  final bool isActive;

  FocusTimer({
    required this.startTime,
    required this.durationMinutes,
    required this.unlockTime,
    this.isActive = true,
  });

  /// Calculate remaining duration from now
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(unlockTime)) return Duration.zero;
    return unlockTime.difference(now);
  }

  /// Check if the timer has expired
  bool get isExpired => DateTime.now().isAfter(unlockTime);

  /// Remaining hours component
  int get remainingHours => remainingTime.inHours;

  /// Remaining minutes component (after hours)
  int get remainingMinutes => remainingTime.inMinutes % 60;

  /// Remaining seconds component (after minutes)
  int get remainingSeconds => remainingTime.inSeconds % 60;

  /// Progress value from 0.0 (just started) to 1.0 (complete)
  double get progress {
    final totalDuration = Duration(minutes: durationMinutes);
    if (totalDuration.inSeconds == 0) return 1.0;
    final elapsed = DateTime.now().difference(startTime);
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  /// Create a new timer with given hours and minutes
  factory FocusTimer.start({required int hours, required int minutes}) {
    final now = DateTime.now();
    final totalMinutes = hours * 60 + minutes;
    return FocusTimer(
      startTime: now,
      durationMinutes: totalMinutes,
      unlockTime: now.add(Duration(minutes: totalMinutes)),
      isActive: true,
    );
  }

  /// Create a stopped/cancelled copy
  FocusTimer copyWithStopped() => FocusTimer(
    startTime: startTime,
    durationMinutes: durationMinutes,
    unlockTime: unlockTime,
    isActive: false,
  );

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'unlockTime': unlockTime.toIso8601String(),
    'isActive': isActive,
  };

  factory FocusTimer.fromJson(Map<String, dynamic> json) => FocusTimer(
    startTime: DateTime.parse(json['startTime'] as String),
    durationMinutes: json['durationMinutes'] as int,
    unlockTime: DateTime.parse(json['unlockTime'] as String),
    isActive: json['isActive'] as bool? ?? false,
  );

  @override
  String toString() =>
      'FocusTimer(start: $startTime, duration: ${durationMinutes}m, unlock: $unlockTime, active: $isActive)';
}
