import 'dart:typed_data';

/// Represents an installed app on the device
class InstalledApp {
  final String appName;
  final String packageName;
  final Uint8List? appIcon;

  const InstalledApp({
    required this.appName,
    required this.packageName,
    this.appIcon,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) => InstalledApp(
    appName: map['appName'] as String? ?? 'Unknown',
    packageName: map['packageName'] as String? ?? '',
    appIcon: map['appIcon'] as Uint8List?,
  );

  Map<String, dynamic> toMap() => {
    'appName': appName,
    'packageName': packageName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'InstalledApp($appName, $packageName)';
}
