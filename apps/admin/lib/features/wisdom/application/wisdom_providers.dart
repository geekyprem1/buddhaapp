import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wisdom_providers.g.dart';

@riverpod
Stream<List<Wisdom>> adminWisdoms(Ref ref) {
  return ref.watch(wisdomRepositoryProvider).watchAll();
}

@riverpod
Future<Wisdom?> adminWisdom(Ref ref, String id) {
  return ref.watch(wisdomRepositoryProvider).getById(id);
}
