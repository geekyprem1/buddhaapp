import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Newest-first page of `users/` for the admin table (AR-5.1, T1.23).
///
/// Search/filter on this screen run client-side over whatever this provider
/// loads, so the page size is the real search ceiling: a smaller cap made
/// older users un-findable even though `_matches` was correct. We load the
/// same 500 the dashboard already reads for launch volumes; the repository's
/// cursor pagination remains for a future "load more" if the base grows past
/// that.
final adminUsersProvider = FutureProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).fetchAdminPage(pageSize: 500);
});

/// Deletion-request queue (T1.24, AR-5.5). Raw maps — the request doc has no
/// dedicated model since the admin panel is its only reader.
final adminDeletionRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).fetchDeletionRequests();
});
