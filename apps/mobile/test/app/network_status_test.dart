import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dhamma_path/app/network_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('none-only is offline', () {
    expect(isOnlineFromResults(const [ConnectivityResult.none]), isFalse);
    expect(isOnlineFromResults(const []), isFalse);
  });

  test('wifi or mobile is online', () {
    expect(isOnlineFromResults(const [ConnectivityResult.wifi]), isTrue);
    expect(
      isOnlineFromResults(const [
        ConnectivityResult.none,
        ConnectivityResult.mobile,
      ]),
      isTrue,
    );
  });
}
