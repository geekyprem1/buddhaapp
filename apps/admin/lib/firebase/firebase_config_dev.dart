import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Public web client config for `dhamma-path-dev` (Firebase API keys are
/// not secrets; security is App Check + Auth + rules).
class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('The admin panel is a Flutter Web target only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBq3r2jkTyfsZz80kgI8xRnjOk-CFPKJbo',
    appId: '1:1083535979129:web:63da4ea6cb11fb31c7daa8',
    messagingSenderId: '1083535979129',
    projectId: 'dhamma-path-dev',
    authDomain: 'dhamma-path-dev.firebaseapp.com',
    storageBucket: 'dhamma-path-dev.firebasestorage.app',
  );
}
