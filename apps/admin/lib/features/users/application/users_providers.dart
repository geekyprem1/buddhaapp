import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Newest-first page of `users/` for the admin table (AR-5.1, T1.23). 100 is
/// enough for launch volumes — the cursor pagination exists in the
/// repository for when a "load more" is needed.
final adminUsersProvider = FutureProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).fetchAdminPage();
});

/// Deletion-request queue (T1.24, AR-5.5). Raw maps — the request doc has no
/// dedicated model since the admin panel is its only reader.
final adminDeletionRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).fetchDeletionRequests();
});
