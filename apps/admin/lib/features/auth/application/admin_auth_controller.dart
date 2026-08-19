import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'admin_session.dart';

part 'admin_auth_controller.g.dart';

class AdminAccessDenied implements Exception {
  const AdminAccessDenied(this.message);
  final String message;

  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
class AdminAuthController extends _$AdminAuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.loginAttempt(method: 'email');
    try {
      final credential = await ref
          .read(authServiceProvider)
          .signInWithEmail(email: email.trim(), password: password);
      final user = credential.user;
      if (user == null) {
        throw const AdminAccessDenied('Sign-in returned no user.');
      }

      // Role is enforced by the router + security rules. Do not read
      // Firestore here — a missing listener or a mid-login redirect
      // used to dispose this notifier and surface a generic failure.
      ref.invalidate(adminRoleProvider);
      await analytics.loginSuccess(method: 'email');
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('admin sign-in failed: $e\n$st');
      if (e is! AdminAccessDenied) {
        await analytics.loginFail(
          method: 'email',
          reason: e is FirebaseAuthException ? e.code : e.runtimeType.toString(),
        );
      }
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    ref.invalidate(adminRoleProvider);
  }

  Future<void> reauthenticate(String password) {
    return ref.read(authServiceProvider).reauthenticateWithPassword(password);
  }
}
