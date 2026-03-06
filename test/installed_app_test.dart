import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/installed_app.dart';

void main() {
  group('InstalledApp', () {
    test('creates with required fields', () {
      const app = InstalledApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
      );

      expect(app.appName, 'Instagram');
      expect(app.packageName, 'com.instagram.android');
      expect(app.appIcon, isNull);
    });

    test('equality is based on packageName', () {
      const app1 = InstalledApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
      );
      const app2 = InstalledApp(
        appName: 'Instagram v2',
        packageName: 'com.instagram.android',
      );

      expect(app1, equals(app2));
    });

    test('fromMap creates correct object', () {
      final map = <dynamic, dynamic>{
        'appName': 'YouTube',
        'packageName': 'com.google.android.youtube',
        'appIcon': null,
      };

      final app = InstalledApp.fromMap(map);
      expect(app.appName, 'YouTube');
      expect(app.packageName, 'com.google.android.youtube');
    });

    test('fromMap handles missing appName', () {
      final map = <dynamic, dynamic>{'packageName': 'com.test.app'};

      final app = InstalledApp.fromMap(map);
      expect(app.appName, 'Unknown');
    });

    test('toMap creates correct map', () {
      const app = InstalledApp(
        appName: 'Reddit',
        packageName: 'com.reddit.frontpage',
      );

      final map = app.toMap();
      expect(map['appName'], 'Reddit');
      expect(map['packageName'], 'com.reddit.frontpage');
    });
  });
}
