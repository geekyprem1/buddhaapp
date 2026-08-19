import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Newest-first page of `contactMessages/` for the admin inbox (FR-14.5,
/// T1.31).
final adminContactMessagesProvider = FutureProvider<List<ContactMessage>>((ref) {
  return ref.watch(contactRepositoryProvider).fetchAdminPage();
});
