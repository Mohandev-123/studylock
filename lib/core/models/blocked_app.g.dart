// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockedAppAdapter extends TypeAdapter<BlockedApp> {
  @override
  final int typeId = 0;

  @override
  BlockedApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BlockedApp(
      appName: fields[0] as String,
      packageName: fields[1] as String,
      appIcon: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, BlockedApp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.appName)
      ..writeByte(1)
      ..write(obj.packageName)
      ..writeByte(2)
      ..write(obj.appIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
