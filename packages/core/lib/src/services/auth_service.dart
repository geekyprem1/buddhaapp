import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Auth for phone OTP and Google sign-in (PRD FR-2.1–2.9).
///
/// Kept intentionally thin: no Google Sign-In SDK is wired here to avoid
/// pulling a heavy platform dependency into `packages/core`. The mobile app
/// obtains a Google [AuthCredential] via `google_sign_in` and passes it to
/// [signInWithGoogleCredential].
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  /// Starts phone verification. [onCodeSent] receives the verificationId to
  /// pass into [verifyOtp]. [onAutoVerified] fires if the SMS Retriever
  /// completes sign-in automatically without the user entering a code
  /// (FR-2.2). [onFailed] surfaces Firebase error codes for the caller to
  /// localise and display (FR-2.7).
  Future<void> startPhoneVerification({
    required String phoneNumber, // E.164, e.g. +919625460555
    required void Function(String verificationId) onCodeSent,
    required void Function(UserCredential credential) onAutoVerified,
    required void Function(FirebaseAuthException error) onFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        onAutoVerified(result);
      },
      verificationFailed: onFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogleCredential(
    AuthCredential credential,
  ) {
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  /// FR-2.8 — actual data deletion happens via the `processDeletionRequest`
  /// Cloud Function; this only ends the local session.
  Future<void> deleteCurrentUserAuthRecord() async {
    await _auth.currentUser?.delete();
  }
}
