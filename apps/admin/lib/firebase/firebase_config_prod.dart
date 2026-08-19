import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Public web client config for `dhamma-path-prod`.
class ProdFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('The admin panel is a Flutter Web target only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDRWGavJW2t1GZl_jtaavmim1UqubJwUSU',
    appId: '1:649045912737:web:92dbe5789b53eb5d3094e0',
    messagingSenderId: '649045912737',
    projectId: 'dhamma-path-prod',
    authDomain: 'dhamma-path-prod.firebaseapp.com',
    storageBucket: 'dhamma-path-prod.firebasestorage.app',
  );
}
