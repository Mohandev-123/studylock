import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/blocked_app.dart';

void main() {
  group('BlockedApp', () {
    group('constructor', () {
      test('creates with required fields', () {
        final app = BlockedApp(
          appName: 'Instagram',
          packageName: 'com.instagram.android',
        );
        expect(app.appName, 'Instagram');
        expect(app.packageName, 'com.instagram.android');
        expect(app.appIcon, null);
      });

      test('creates with optional appIcon', () {
        final icon = Uint8List.fromList([1, 2, 3, 4]);
        final app = BlockedApp(
          appName: 'YouTube',
          packageName: 'com.google.android.youtube',
          appIcon: icon,
        );
        expect(app.appIcon, icon);
      });
    });

    group('equality', () {
      test('equal when same packageName', () {
        final app1 = BlockedApp(
          appName: 'Instagram',
          packageName: 'com.instagram.android',
        );
        final app2 = BlockedApp(
          appName: 'Instagram Updated',
          packageName: 'com.instagram.android',
        );
        expect(app1 == app2, true);
      });

      test('not equal when different packageName', () {
        final app1 = BlockedApp(
          appName: 'Instagram',
          packageName: 'com.instagram.android',
        );
        final app2 = BlockedApp(
          appName: 'Instagram',
          packageName: 'com.instagram.lite',
        );
        expect(app1 == app2, false);
      });

      test('hashCode based on packageName', () {
        final app1 = BlockedApp(appName: 'App', packageName: 'com.test.app');
        final app2 = BlockedApp(
          appName: 'Different Name',
          packageName: 'com.test.app',
        );
        expect(app1.hashCode, app2.hashCode);
      });

      test('can be used in Set correctly', () {
        final app1 = BlockedApp(appName: 'App', packageName: 'com.test.app');
        final app2 = BlockedApp(
          appName: 'App Copy',
          packageName: 'com.test.app',
        );
        final set = {app1, app2};
        expect(set.length, 1);
      });
    });

    group('JSON serialization', () {
      test('toJson contains appName and packageName', () {
        final app = BlockedApp(
          appName: 'WhatsApp',
          packageName: 'com.whatsapp',
        );
        final json = app.toJson();
        expect(json['appName'], 'WhatsApp');
        expect(json['packageName'], 'com.whatsapp');
      });

      test('fromJson creates correct instance', () {
        final json = {
          'appName': 'Twitter',
          'packageName': 'com.twitter.android',
        };
        final app = BlockedApp.fromJson(json);
        expect(app.appName, 'Twitter');
        expect(app.packageName, 'com.twitter.android');
      });

      test('roundtrip preserves fields', () {
        final app = BlockedApp(
          appName: 'Reddit',
          packageName: 'com.reddit.frontpage',
        );
        final json = app.toJson();
        final restored = BlockedApp.fromJson(json);
        expect(restored.appName, app.appName);
        expect(restored.packageName, app.packageName);
      });

      test('fromJson handles appIcon as null', () {
        final json = {
          'appName': 'Snap',
          'packageName': 'com.snapchat.android',
          'appIcon': null,
        };
        final app = BlockedApp.fromJson(json);
        expect(app.appIcon, null);
      });
    });

    group('toString()', () {
      test('returns descriptive string', () {
        final app = BlockedApp(
          appName: 'TikTok',
          packageName: 'com.zhiliaoapp.musically',
        );
        final str = app.toString();
        expect(str, contains('BlockedApp'));
        expect(str, contains('TikTok'));
        expect(str, contains('com.zhiliaoapp.musically'));
      });
    });
  });
}
