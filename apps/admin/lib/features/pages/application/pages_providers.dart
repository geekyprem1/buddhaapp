import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pages_providers.g.dart';

@riverpod
Stream<List<StaticPage>> adminStaticPages(Ref ref) {
  return ref.watch(staticPageRepositoryProvider).watchAll();
}

@riverpod
Future<StaticPage?> adminStaticPage(Ref ref, String slug) {
  return ref.watch(staticPageRepositoryProvider).get(slug);
}
