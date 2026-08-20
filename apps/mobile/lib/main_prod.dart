import 'package:flutter/foundation.dart';

import 'app/bootstrap.dart';
import 'firebase/firebase_options_prod.dart';

/// Entry point for the `prod` flavour — connects to the `dhamma-path-prod`
/// Firebase project (Architecture §15). Run with:
///   flutter run --flavor prod -t lib/main_prod.dart
Future<void> main() {
  return bootstrapAndRun(
    options: DefaultFirebaseOptions.currentPlatform,
    // `flutter run --flavor prod` is still a debug build — Play Integrity
    // only in real release binaries.
    debugAppCheck: kDebugMode,
    // Web OAuth client (client_type 3) from src/prod/google-services.json.
    googleServerClientId:
        '649045912737-g1pdlr07slh9lat4u54d7tahkkd9lu25.apps.googleusercontent.com',
  );
}
