import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_providers.g.dart';

@riverpod
Stream<AppConfig> adminAppConfig(Ref ref) {
  return ref.watch(configRepositoryProvider).watchAppConfig();
}

@riverpod
Stream<HomeLayout> adminHomeLayout(Ref ref) {
  return ref.watch(configRepositoryProvider).watchHomeLayout();
}
