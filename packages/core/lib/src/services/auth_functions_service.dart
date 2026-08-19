import 'package:cloud_functions/cloud_functions.dart';

import '../constants/app_constants.dart';

/// Client wrapper for callables the **mobile app** (not the admin panel)
/// invokes — unauthenticated-safe (App Check is the defence), unlike
/// `AdminFunctionsService`.
class AuthFunctionsService {
  AuthFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: AppConstants.functionsRegion);

  final FirebaseFunctions _functions;

  /// Server-side per-number OTP rate limit (FR-2.9, T2.11). Call before
  /// `AuthService.startPhoneVerification`; throws a [FirebaseFunctionsException]
  /// with code `resource-exhausted` when the number has been throttled.
  Future<void> guardOtpAbuse(String phoneNumber) async {
    final callable = _functions.httpsCallable(AppConstants.fnGuardOtpAbuse);
    await callable.call<Map<Object?, Object?>>({'phoneNumber': phoneNumber});
  }
}
