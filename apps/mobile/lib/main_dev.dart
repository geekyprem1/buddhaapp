import 'app/bootstrap.dart';
import 'firebase/firebase_options_dev.dart';

/// Entry point for the `dev` flavour — connects to the `dhamma-path-dev`
/// Firebase project (Architecture §15). Run with:
///   flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() {
  return bootstrapAndRun(
    options: DefaultFirebaseOptions.currentPlatform,
    debugAppCheck: true,
    // Web OAuth client (client_type 3) from src/dev/google-services.json.
    googleServerClientId:
        '1083535979129-sr2p0i8udtl0dkqrfp4800k7q8nudnn7.apps.googleusercontent.com',
  );
}
