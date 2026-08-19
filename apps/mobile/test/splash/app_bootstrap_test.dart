import 'package:core/core.dart';
import 'package:dhamma_path/features/splash/application/app_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses Firestore config when fetch succeeds', () async {
    final loader = AppBootstrapLoader(
      installedVersion: '1.0.0',
      minWait: Duration.zero,
      fetchFirestore: () async => const AppConfig(latestVersion: '2.0.0'),
    );
    final boot = await loader.load();
    expect(boot.config.latestVersion, '2.0.0');
    expect(boot.gate, AppGate.ready);
  });

  test('falls back to cache when Firestore throws', () async {
    final loader = AppBootstrapLoader(
      installedVersion: '1.0.0',
      minWait: Duration.zero,
      fetchFirestore: () async => throw Exception('offline'),
      readCache: () => const AppConfig(latestVersion: '1.4.0'),
    );
    final boot = await loader.load();
    expect(boot.config.latestVersion, '1.4.0');
  });

  test('force-update wins over maintenance', () async {
    final loader = AppBootstrapLoader(
      installedVersion: '0.1.0',
      minWait: Duration.zero,
      fetchFirestore: () async => const AppConfig(
        forceUpdate: true,
        minSupportedVersion: '1.0.0',
        maintenanceMode: true,
      ),
    );
    final boot = await loader.load();
    expect(boot.gate, AppGate.forceUpdate);
  });

  test('maintenance gate when update is not required', () async {
    final loader = AppBootstrapLoader(
      installedVersion: '1.0.0',
      minWait: Duration.zero,
      fetchFirestore: () async => const AppConfig(maintenanceMode: true),
    );
    final boot = await loader.load();
    expect(boot.gate, AppGate.maintenance);
  });

  test('Remote Config overlay can raise the force-update flag', () async {
    final loader = AppBootstrapLoader(
      installedVersion: '0.1.0',
      minWait: Duration.zero,
      fetchFirestore: () async => const AppConfig(minSupportedVersion: '1.0.0'),
      fetchRemoteOverlay: (current) async => current.copyWith(forceUpdate: true),
    );
    final boot = await loader.load();
    expect(boot.gate, AppGate.forceUpdate);
  });
}
