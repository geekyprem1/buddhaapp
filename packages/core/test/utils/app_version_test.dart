import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareAppVersions', () {
    test('orders dotted versions', () {
      expect(compareAppVersions('1.0.0', '1.0.0'), 0);
      expect(compareAppVersions('1.2', '1.2.0'), 0);
      expect(compareAppVersions('0.1.0', '1.0.0'), lessThan(0));
      expect(compareAppVersions('1.2.1', '1.2.0'), greaterThan(0));
    });

    test('strips build metadata', () {
      expect(compareAppVersions('1.0.0+12', '1.0.0'), 0);
    });
  });

  group('needsForceUpdate', () {
    test('stays off unless the flag is set', () {
      expect(
        needsForceUpdate(
          forceUpdate: false,
          minSupportedVersion: '9.0.0',
          installedVersion: '0.1.0',
        ),
        isFalse,
      );
    });

    test('blocks only installs below the minimum', () {
      expect(
        needsForceUpdate(
          forceUpdate: true,
          minSupportedVersion: '1.0.0',
          installedVersion: '0.1.0',
        ),
        isTrue,
      );
      expect(
        needsForceUpdate(
          forceUpdate: true,
          minSupportedVersion: '1.0.0',
          installedVersion: '1.0.0',
        ),
        isFalse,
      );
    });
  });
}
