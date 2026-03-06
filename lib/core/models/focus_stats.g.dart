// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusStatsAdapter extends TypeAdapter<FocusStats> {
  @override
  final int typeId = 2;

  @override
  FocusStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FocusStats(
      blockedAppsCount: fields[0] as int? ?? 0,
      totalFocusMinutes: fields[1] as int? ?? 0,
      streakDays: fields[2] as int? ?? 0,
      totalSessions: fields[3] as int? ?? 0,
      lastSessionDate: fields[4] as DateTime?,
      dailyFocusMinutes: (fields[5] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, FocusStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.blockedAppsCount)
      ..writeByte(1)
      ..write(obj.totalFocusMinutes)
      ..writeByte(2)
      ..write(obj.streakDays)
      ..writeByte(3)
      ..write(obj.totalSessions)
      ..writeByte(4)
      ..write(obj.lastSessionDate)
      ..writeByte(5)
      ..write(obj.dailyFocusMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
