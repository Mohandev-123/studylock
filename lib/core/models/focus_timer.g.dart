// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusTimerAdapter extends TypeAdapter<FocusTimer> {
  @override
  final int typeId = 1;

  @override
  FocusTimer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FocusTimer(
      startTime: fields[0] as DateTime,
      durationMinutes: fields[1] as int,
      unlockTime: fields[2] as DateTime,
      isActive: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, FocusTimer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.durationMinutes)
      ..writeByte(2)
      ..write(obj.unlockTime)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusTimerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
