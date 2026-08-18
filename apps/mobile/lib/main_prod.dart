import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase/firebase_options_prod.dart';

/// Entry point for the `prod` flavour — connects to the `dhamma-path-prod`
/// Firebase project (Architecture §15). Run with:
///   flutter run --flavor prod -t lib/main_prod.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: DhammaPathApp()));
}
