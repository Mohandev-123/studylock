import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'blocked_app.g.dart';

@HiveType(typeId: 0)
class BlockedApp extends HiveObject {
  @HiveField(0)
  final String appName;

  @HiveField(1)
  final String packageName;

  @HiveField(2)
  final Uint8List? appIcon;

  BlockedApp({required this.appName, required this.packageName, this.appIcon});

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'packageName': packageName,
  };

  factory BlockedApp.fromJson(Map<String, dynamic> json) => BlockedApp(
    appName: json['appName'] as String,
    packageName: json['packageName'] as String,
    appIcon: json['appIcon'] as Uint8List?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'BlockedApp($appName, $packageName)';
}
