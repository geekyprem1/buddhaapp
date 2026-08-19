import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/notifications/application/fcm_background.dart';
import 'features/player/application/dhamma_audio_handler.dart';
import 'features/prarthana/application/alarm_local_store.dart';
import 'firebase/firebase_options_dev.dart';

/// Entry point for the `dev` flavour — connects to the `dhamma-path-dev`
/// Firebase project (Architecture §15). Run with:
///   flutter run --flavor dev -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await AlarmLocalStore.init();
  await initAudioHandler();
  runApp(const ProviderScope(child: DhammaPathApp()));
}
