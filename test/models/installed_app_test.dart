import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/installed_app.dart';

void main() {
  group('InstalledApp', () {
    group('constructor', () {
      test('creates with required fields', () {
        const app = InstalledApp(
          appName: 'Chrome',
          packageName: 'com.android.chrome',
        );
        expect(app.appName, 'Chrome');
        expect(app.packageName, 'com.android.chrome');
        expect(app.appIcon, null);
      });

      test('creates with appIcon', () {
        final icon = Uint8List.fromList([0xFF, 0xAA, 0xBB]);
        final app = InstalledApp(
          appName: 'Chrome',
          packageName: 'com.android.chrome',
          appIcon: icon,
        );
        expect(app.appIcon, icon);
      });
    });

    group('fromMap()', () {
      test('creates from valid map', () {
        final map = <dynamic, dynamic>{
          'appName': 'YouTube',
          'packageName': 'com.google.android.youtube',
        };
        final app = InstalledApp.fromMap(map);
        expect(app.appName, 'YouTube');
        expect(app.packageName, 'com.google.android.youtube');
      });

      test('handles null appName with default "Unknown"', () {
        final map = <dynamic, dynamic>{'packageName': 'com.test.app'};
        final app = InstalledApp.fromMap(map);
        expect(app.appName, 'Unknown');
      });

      test('handles null packageName with default empty string', () {
        final map = <dynamic, dynamic>{'appName': 'Test'};
        final app = InstalledApp.fromMap(map);
        expect(app.packageName, '');
      });

      test('handles appIcon bytes', () {
        final icon = Uint8List.fromList([1, 2, 3]);
        final map = <dynamic, dynamic>{
          'appName': 'Test',
          'packageName': 'com.test',
          'appIcon': icon,
        };
        final app = InstalledApp.fromMap(map);
        expect(app.appIcon, icon);
      });

      test('handles null appIcon', () {
        final map = <dynamic, dynamic>{
          'appName': 'Test',
          'packageName': 'com.test',
          'appIcon': null,
        };
        final app = InstalledApp.fromMap(map);
        expect(app.appIcon, null);
      });
    });

    group('toMap()', () {
      test('contains appName and packageName', () {
        const app = InstalledApp(
          appName: 'Maps',
          packageName: 'com.google.android.maps',
        );
        final map = app.toMap();
        expect(map['appName'], 'Maps');
        expect(map['packageName'], 'com.google.android.maps');
      });
    });

    group('equality', () {
      test('equal when same packageName', () {
        const app1 = InstalledApp(appName: 'App', packageName: 'com.test.app');
        const app2 = InstalledApp(
          appName: 'Different Name',
          packageName: 'com.test.app',
        );
        expect(app1 == app2, true);
      });

      test('not equal when different packageName', () {
        const app1 = InstalledApp(appName: 'App', packageName: 'com.test.app1');
        const app2 = InstalledApp(appName: 'App', packageName: 'com.test.app2');
        expect(app1 == app2, false);
      });

      test('hashCode consistent with equality', () {
        const app1 = InstalledApp(appName: 'A', packageName: 'com.same');
        const app2 = InstalledApp(appName: 'B', packageName: 'com.same');
        expect(app1.hashCode, app2.hashCode);
      });

      test('works correctly in Set', () {
        const app1 = InstalledApp(appName: 'A', packageName: 'com.same');
        const app2 = InstalledApp(appName: 'B', packageName: 'com.same');
        const app3 = InstalledApp(appName: 'C', packageName: 'com.different');
        final set = {app1, app2, app3};
        expect(set.length, 2);
      });
    });

    group('toString()', () {
      test('returns descriptive string', () {
        const app = InstalledApp(
          appName: 'Spotify',
          packageName: 'com.spotify.music',
        );
        expect(app.toString(), contains('InstalledApp'));
        expect(app.toString(), contains('Spotify'));
        expect(app.toString(), contains('com.spotify.music'));
      });
    });
  });
}
