import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@riverpod
Stream<HomeLayout> homeLayout(Ref ref) {
  return ref.watch(configRepositoryProvider).watchHomeLayout();
}
