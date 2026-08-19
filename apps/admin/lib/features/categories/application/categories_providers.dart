import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_providers.g.dart';

@riverpod
Stream<List<Category>> adminCategories(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
}

@riverpod
Future<Category?> adminCategory(Ref ref, String id) {
  return ref.watch(categoryRepositoryProvider).getById(id);
}
