import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Shared Firebase init for both flavours. Persistence is off so admins
/// never act on a stale cache (Architecture §10).
Future<void> bootstrapFirebase(FirebaseOptions options) async {
  await Firebase.initializeApp(options: options);

  await _activateAppCheck();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  const useEmulator = bool.fromEnvironment('USE_EMULATOR');
  if (useEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFunctions.instanceFor(
      region: AppConstants.functionsRegion,
    ).useFunctionsEmulator('localhost', 5001);
  }
}

Future<void> _activateAppCheck() async {
  const recaptchaKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
  try {
    await FirebaseAppCheck.instance.activate(
      webProvider: recaptchaKey.isEmpty
          ? null
          : ReCaptchaEnterpriseProvider(recaptchaKey),
    );
  } catch (error) {
    debugPrint('Admin App Check activate failed: $error');
  }
}
