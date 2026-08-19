import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_session.g.dart';

/// Set when the 12h idle timer fires so LoginPage can show the reason.
final idleSignOutProvider = StateProvider<bool>((ref) => false);

/// Latest ID-token role for the signed-in user, or `null` if they have no
/// admin claim. Force-refreshed so a just-granted claim is visible.
@Riverpod(keepAlive: true)
Future<String?> adminRole(Ref ref) async {
  final auth = ref.watch(authStateProvider);
  final user = auth.valueOrNull;
  if (user == null) return null;
  final token = await user.getIdTokenResult(true);
  final role = AdminRole.fromClaims(token.claims);
  return AdminRole.isAdmin(role) ? role : null;
}

@riverpod
User? adminAuthUser(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
}
