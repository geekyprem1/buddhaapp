import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Drives the Login → OTP flow (PRD FR-2.1–2.9).
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  String? _verificationId;

  /// Starts phone verification and returns once the code has been sent (or
  /// throws on failure). Auto-verification via the SMS Retriever completes
  /// sign-in directly without the caller needing to navigate to OTP entry.
  Future<bool> sendOtp(String phoneNumber) async {
    state = const AsyncLoading();
    await ref.read(analyticsServiceProvider).loginAttempt(method: 'phone');
    final completer = Completer<bool>();

    // Server-side per-number rate limit (FR-2.9, T2.11) — checked before
    // Firebase Phone Auth even starts, since Phone Auth itself has no
    // per-number throttling hook of its own.
    try {
      await ref.read(authFunctionsServiceProvider).guardOtpAbuse(phoneNumber);
    } on FirebaseFunctionsException catch (e, st) {
      await ErrorReporter.instance.record(e, st, reason: 'auth.guardOtp');
      await ref.read(analyticsServiceProvider).loginFail(
            method: 'phone',
            reason: classifyAuthError(e).kind.name,
          );
      state = AsyncError(e, st);
      return false;
    }

    try {
      await ref.read(authServiceProvider).startPhoneVerification(
            phoneNumber: phoneNumber,
            onCodeSent: (verificationId) {
              _verificationId = verificationId;
              state = const AsyncData(null);
              if (!completer.isCompleted) completer.complete(true);
            },
            onAutoVerified: (credential) async {
              await _ensureUserDocument(credential);
              await ref.read(analyticsServiceProvider).loginSuccess(
                    method: 'phone',
                  );
              state = const AsyncData(null);
              if (!completer.isCompleted) completer.complete(false);
            },
            onFailed: (error) {
              ErrorReporter.instance.record(
                error,
                StackTrace.current,
                reason: 'auth.phoneFailed',
              );
              state = AsyncError(error, StackTrace.current);
              if (!completer.isCompleted) completer.complete(false);
            },
          );
    } catch (e, st) {
      await ErrorReporter.instance.record(e, st, reason: 'auth.sendOtp');
      await ref.read(analyticsServiceProvider).loginFail(
            method: 'phone',
            reason: classifyAuthError(e).kind.name,
          );
      state = AsyncError(e, st);
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  Future<void> verifyOtp(String smsCode) async {
    final verificationId = _verificationId;
    if (verificationId == null) {
      state = AsyncError(
        StateError('No OTP request in progress'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    try {
      final credential = await ref
          .read(authServiceProvider)
          .verifyOtp(verificationId: verificationId, smsCode: smsCode);
      await _ensureUserDocument(credential);
      await ref.read(analyticsServiceProvider).loginSuccess(method: 'phone');
      state = const AsyncData(null);
    } catch (e, st) {
      await ErrorReporter.instance.record(e, st, reason: 'auth.verifyOtp');
      await ref.read(analyticsServiceProvider).loginFail(
            method: 'phone',
            reason: classifyAuthError(e).kind.name,
          );
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    await ref.read(analyticsServiceProvider).loginAttempt(method: 'google');
    try {
      // Already initialized (with serverClientId) in bootstrap; re-calling
      // here without it would drop the idToken.
      final account = await GoogleSignIn.instance.authenticate();
      final googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final result = await ref
          .read(authServiceProvider)
          .signInWithGoogleCredential(credential);
      await _ensureUserDocument(result);
      await ref.read(analyticsServiceProvider).loginSuccess(method: 'google');
      state = const AsyncData(null);
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = const AsyncData(null);
        return;
      }
      await ErrorReporter.instance.record(e, st, reason: 'auth.google');
      await ref.read(analyticsServiceProvider).loginFail(
            method: 'google',
            reason: e.code.name,
          );
      state = AsyncError(e, st);
    } catch (e, st) {
      if (classifyAuthError(e).kind == AuthErrorKind.cancelled) {
        state = const AsyncData(null);
        return;
      }
      await ErrorReporter.instance.record(e, st, reason: 'auth.google');
      await ref.read(analyticsServiceProvider).loginFail(
            method: 'google',
            reason: classifyAuthError(e).kind.name,
          );
      state = AsyncError(e, st);
    }
  }

  Future<void> _ensureUserDocument(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;
    final isGoogle = user.providerData.any(
      (p) => p.providerId == 'google.com',
    );
    await ref.read(userRepositoryProvider).ensureUserDocument(
          uid: user.uid,
          authMethod: isGoogle ? 'google' : 'phone',
          phone: user.phoneNumber,
          email: user.email,
          name: user.displayName,
        );
  }
}
