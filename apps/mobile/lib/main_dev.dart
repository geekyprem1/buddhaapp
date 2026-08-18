import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase/firebase_options_dev.dart';

/// Entry point for the `dev` flavour — connects to the `dhamma-path-dev`
/// Firebase project (Architecture §15). Run with:
///   flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: DhammaPathApp()));
}
