import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bodhi_ai_providers.g.dart';

@riverpod
Stream<BodhiAiConfig> adminBodhiAiConfig(Ref ref) {
  return ref.watch(configRepositoryProvider).watchBodhiAiConfig();
}
