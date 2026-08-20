import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when the device has any non-none interface (T2.5 offline banner).
/// This is link-state, not a probe of Firestore — good enough to warn.
bool isOnlineFromResults(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

final networkOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield isOnlineFromResults(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isOnlineFromResults);
});
