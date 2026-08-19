import 'package:cloud_functions/cloud_functions.dart';

import '../constants/app_constants.dart';

class SetAdminRoleResult {
  const SetAdminRoleResult({
    required this.uid,
    required this.email,
    required this.role,
  });

  final String uid;
  final String email;

  /// `null` when the role was revoked.
  final String? role;
}

/// Client wrapper for admin-only callables (Architecture §8).
class AdminFunctionsService {
  AdminFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: AppConstants.functionsRegion);

  final FirebaseFunctions _functions;

  /// Grant or revoke an admin custom claim. Super-admin only; audit-logged
  /// server-side (AR-1.2, T1.3).
  Future<SetAdminRoleResult> setAdminRole({
    String? uid,
    String? email,
    required String? role,
    String? name,
  }) async {
    final callable = _functions.httpsCallable(AppConstants.fnSetAdminRole);
    final result = await callable.call<Map<Object?, Object?>>({
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      'role': role,
      if (name != null) 'name': name,
    });
    final data = Map<String, dynamic>.from(result.data);
    return SetAdminRoleResult(
      uid: data['uid'] as String,
      email: data['email'] as String? ?? '',
      role: data['role'] as String?,
    );
  }

  /// Send, schedule, or test-send a push campaign (AR-6, T1.25).
  Future<SendNotificationResult> sendNotification({
    String? campaignId,
    required String title,
    required String body,
    String? imageUrl,
    String? deepLink,
    required String audience,
    DateTime? scheduledAt,
    String? testToken,
  }) async {
    final callable = _functions.httpsCallable(AppConstants.fnSendNotification);
    final result = await callable.call<Map<Object?, Object?>>({
      if (campaignId != null && campaignId.isNotEmpty) 'campaignId': campaignId,
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (deepLink != null) 'deepLink': deepLink,
      'audience': audience,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      if (testToken != null && testToken.isNotEmpty) 'testToken': testToken,
    });
    final data = Map<String, dynamic>.from(result.data);
    return SendNotificationResult(
      campaignId: data['campaignId'] as String? ?? campaignId ?? '',
      status: data['status'] as String? ?? '',
      deliveredCount: (data['deliveredCount'] as num?)?.toInt() ?? 0,
      messageId: data['messageId'] as String?,
    );
  }
}

class SendNotificationResult {
  const SendNotificationResult({
    required this.campaignId,
    required this.status,
    required this.deliveredCount,
    this.messageId,
  });

  final String campaignId;
  final String status;
  final int deliveredCount;
  final String? messageId;
}
