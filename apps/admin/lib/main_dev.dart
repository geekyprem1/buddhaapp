import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase/bootstrap.dart';
import 'firebase/firebase_config_dev.dart';

/// Dev flavour — `dhamma-path-dev`.
///   flutter run -d chrome -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(DevFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: DhammaPathAdminApp()));
}
