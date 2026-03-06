import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/blocked_app.dart';

void main() {
  group('BlockedApp', () {
    test('creates with required fields', () {
      final app = BlockedApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
      );

      expect(app.appName, 'Instagram');
      expect(app.packageName, 'com.instagram.android');
      expect(app.appIcon, isNull);
    });

    test('equality is based on packageName', () {
      final app1 = BlockedApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
      );
      final app2 = BlockedApp(
        appName: 'Instagram (Different)',
        packageName: 'com.instagram.android',
      );

      expect(app1, equals(app2));
      expect(app1.hashCode, app2.hashCode);
    });

    test('different packageNames are not equal', () {
      final app1 = BlockedApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
      );
      final app2 = BlockedApp(
        appName: 'YouTube',
        packageName: 'com.google.android.youtube',
      );

      expect(app1, isNot(equals(app2)));
    });

    test('toJson creates correct map', () {
      final app = BlockedApp(
        appName: 'YouTube',
        packageName: 'com.google.android.youtube',
      );

      final json = app.toJson();
      expect(json['appName'], 'YouTube');
      expect(json['packageName'], 'com.google.android.youtube');
    });

    test('fromJson creates correct object', () {
      final json = {
        'appName': 'TikTok',
        'packageName': 'com.zhiliaoapp.musically',
      };

      final app = BlockedApp.fromJson(json);
      expect(app.appName, 'TikTok');
      expect(app.packageName, 'com.zhiliaoapp.musically');
    });

    test('toString contains relevant info', () {
      final app = BlockedApp(appName: 'Test', packageName: 'com.test');

      expect(app.toString(), contains('Test'));
      expect(app.toString(), contains('com.test'));
    });
  });
}
