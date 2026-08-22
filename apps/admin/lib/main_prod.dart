import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/accessibility/application/zoom_controller.dart';
import 'firebase/bootstrap.dart';
import 'firebase/firebase_config_prod.dart';

/// Prod flavour — `dhamma-path-prod`.
///   flutter build web -t lib/main_prod.dart --release
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(ProdFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DhammaPathAdminApp(),
    ),
  );
}
