import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_providers.g.dart';

@riverpod
Future<List<ContentItem>> adminContentList(Ref ref, String collection) {
  return ref.watch(contentRepositoryProvider(collection)).fetchAdminPage();
}

@riverpod
Future<ContentItem?> adminContentItem(
  Ref ref,
  (String collection, String id) key,
) {
  return ref.watch(contentRepositoryProvider(key.$1)).getById(key.$2);
}
